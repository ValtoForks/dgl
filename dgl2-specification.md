DGL2 Format Specification, version 2.0
======================================
DGL2 is a simple chunk-based binary model format for DGL. It is a successor of DGL format (DGL1). Main change from DGL1 is the usage of DML (DGL Markup Language) instead of JSON for serializing properties. DGL2 supports meshes, entities and per-polygon materials. You can use DGL2 to store single objects or entire game levels.

DGL2 format is highly extendable, you can encode almost any kind of game-specific and engine-specific data into it.

Terms
-----
Being highly extendable, DGL2 allows the user of the format specify his own meaning (semantics) for some types of data. We use the following terms to describe such data:

* "Game-specific" means that semantics of some data is not defined by the format specification, but rather defined by the game that uses DGL. Such semantics is a convention between game programmers and game asset creators. However, this should not break compatibility with DGL itself.
* "Engine-specific" has a very close meaning to above. Semantics of some data is not defined by the format specification, but rather by the engine that implements DGL2 support. The main difference from "game-specific" is that such supersets of DGL2 are not necessarily need to be compatible with DGL engine, they are specific to engines that use them.
* "Editor-specific" means that semantics of some data is not defined by the format specification, but rather defined by the editor that created DGL2 file (this can be DGL2 exporter for a general-purpose 3D editor, or a tool that is specially designed for working with DGL2). It should not break compatibility with DGL, and can be ignored by the game or the engine.

Data Types
----------
Built-in data types of the format are the following:

    ubyte  - unsigned 8-bit byte
    ushort - unsigned 2-byte integer, little-endian
    uint   - unsigned 4-byte integer, little-endian
    int    - signed 4-byte integer, little-endian
    float  - IEEE single precision floating point number
    vec2   - vector of two floats (layout is XY)
    vec3   - vector of three floats (layout is XYZ)
    quat   - quaternion represented as vector of four floats (layout is XYZW)
    T[N]   - array of N values of type T

Objects
-------
DML2 defines three basic object types: Trimesh, Material, and Entity. 

Trimesh is a set of triangles defined in object space (e.g., should be transformed to world space). Each triangle has its own material, three normals and two sets of UV coordinates.

Material is a set of properties used to render triangles (color, textures and so on).

Entity is an object with transformation, which renders Trimesh linked to it.

DML Markup Language
-------------------
DML stands for "DGL Markup Language". It is a human-readable text format that is used in DGL2 to store properties and their values. It consists of name/value pairs written in the following syntax:

    propertyName = "propertyValue";

Parsing DML strings is not strictly mandatory to successfully read DGL2 file, but is highly recommended due to the fact that game-specific and engine-specific properties of the objects are stored as DML. All Material properties are also stored as DML, allowing to define engine-specific materials in the editor.

`propertyValue` can be integer, floating point number, text, or vector. Vector has the following syntax: `[0, 0, 0, 0]`.

Chunk
-----
DGL2 file consists of a series of chunks. Each chunk is variable-length and encodes a portion of model data (TRIMESH, ENTITY, MATERIAL). There are also two service chunks, HEADER and END, which mark start and end of a file, respectively.
Each chunk has the following binary layout:

    type     - ushort
    id       - int
    nameSize - ushort
    dataSize - uint
    name     - ubyte[nameSize], UTF-8 encoded name. Maximum size is 65535.
    data     - ubyte[dataSize], raw data
    
`type` can be one of the following:

    0 - HEADER
    1 - END
    2 - TRIMESH
    3 - MATERIAL
    4 - ENTITY
    
Other type values are reserved for future use. HEADER chunk is expected to appear at the beginning of the file, END chunk marks the end of the file.

HEADER Chunk
------------
HEADER chunk has `type` field equal to `0` and `id` field equal to `-1`. It also defines model name in the `name` field. `data` field may be empty (dataSize == 0) of may store arbitrary editor-specific data.

END Chunk
---------
END chunk has `type` field equal to `1` and `id` field equal to `-1`. It does not define `name` nor `data` (`nameSize == 0`, `dataSize == 0`).

TRIMESH
-------
TRIMESH chunk has `type` field equal to `2` and a unique `id`, usually beginning from `0`. It should define unique `name`. `data` field consists of an array of Triangle structs:

    materialId  - int
    vertices    - vec3[3], vertices
    normals     - vec3[3], vertex normals
    uv1         - vec2[3], vertex UV coordinates set 1
    uv2         - vec2[3], vertex UV coordinates set 2

Total number of triangles can be determined by dividing `dataSize` with `124` (Triangle struct size).

MATERIAL
--------
MATERIAL chunk has `type` field equal to `3` and a unique `id`, usually beginning from `0`. It should define unique `name`. `data` field optionally contains UTF-8 encoded DML string. There is no strict definition of what DML properties should be stored in it, however DGL internally supports the following:

    diffuseColor = "[r,g,b,a]"
    specularColor = "[r,g,b,a]"
    shadeless = "0" or "1"
    texturesNum = from "0" to "8"
    texture* ("texture0", "texture1"... up to "texture8") = path to the texture

`"[r,g,b,a]"` values are floats in the range `0..1`. 

`shadeless` defines whether material should be affected by lighting (`1` = should not). 

`texturesNum` defines how many textures are used in the material. DGL supports up to 8 texture slots. Paths to the textures should be relative to directory containing DGL2 file. The only supported image format for the textures is currently PNG (this limitation is in the engine, not in DGL2; image formats support is engine-specific).

Any Material can define any number of additional custom DML properties, which are game-, engine- and editor-specific.

ENTITY
------
ENTITY chunk has `type` field equal to `4` and a unique `id`, usually beginning from `0`. It should define unique `name`. `data` field begins with the following mandatory structure:

    type       - uint
    materialID - int
    meshID     - int
    position   - vec3
    rotation   - quat
    scaling    - vec3
    DMLsize    - uint

`type` field is game-specific. Reserved values are `0` (normal entity) and `1` (point light source). 

`materialID` and `meshID` fields point to corresponding Material and Trimesh defined in the file. There is no strict order in which Materials, Trimeshes and Entities should appear in the file.

`position`, `rotation` and `scaling` define affine transformation which should be used to render the Trimesh. The application order of these is the following: translate, rotate, then scale. Rotation is defined as XYZW quaternion.

If `DMLsize` is larger than `0`, this structure is immediately followed by UTF-8 encoded DML string of size `DMLsize`. There is no strict definition of what DML properties should be stored in it, however DGL internally supports the following:

    visible = "0" or "1"
    transparent = "0" or "1"

`visible` defines whether entity should be rendered or not. `transparent` defines whether entity does alpha blending and should participate in transparency sorting (e.g., rendered after non-transparent entities). There properties are purely optional, by default entities are visible and non-transparent.

Any Entity can define any number of additional custom DML properties, which are game-, engine- and editor-specific.

