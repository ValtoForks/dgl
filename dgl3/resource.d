module dgl3.resource;

import std.stdio;
import dlib.core.memory;
import dlib.core.stream;
import dlib.filesystem.stdfs;
import dlib.math.vector;
import dlib.math.quaternion;
import dgl.asset.resource;
import dgl3.serialization;
import dgl3.trimesh;
import dgl3.entity;
/*
class DGL3Resource: Resource
{
    bool loadThreadSafePart(InputStream istrm);
    bool loadThreadUnsafePart();
}
*/
class DGL3Resource: Resource
{
    string name;
    string creator;
    ubyte[] metadata;
    Trimesh[] meshes;
    DGL3Entity[] entities;

    bool loadThreadSafePart(InputStream istrm)
    {
        readDGL3(istrm, this);
        return true;
    }

    bool loadThreadUnsafePart()
    {
        return true;
    }

    ~this()
    {
        if (name.length)
            Delete(name);
        if (creator.length)
            Delete(creator);
        if (metadata.length)
            Delete(metadata);

        foreach(mesh; meshes)
            Delete(mesh);
        if (meshes.length)
            Delete(meshes);
        foreach(entity; entities)
            Delete(entity);
        if (entities.length)
            Delete(entities);
    }
}

Vector2f readVector2f(InputStream istrm)
{
    ubyte[2*4] bytes;
    istrm.fillArray(bytes);
    return *cast(Vector2f*)bytes.ptr;
}

Vector3f readVector3f(InputStream istrm)
{
    ubyte[3*4] bytes;
    istrm.fillArray(bytes);
    return *cast(Vector3f*)bytes.ptr;
}

Vector4f readVector4f(InputStream istrm)
{
    ubyte[4*4] bytes;
    istrm.fillArray(bytes);
    return *cast(Vector4f*)bytes.ptr;
}

Quaternionf readQuaternionf(InputStream istrm)
{
    ubyte[4*4] bytes;
    istrm.fillArray(bytes);
    return *cast(Quaternionf*)bytes.ptr;
}

string readString(InputStream istrm, int len)
{
    auto rawData = New!(ubyte[])(len);
    istrm.fillArray(rawData);
    return cast(string)rawData[0..$];
}

ubyte[] readRawData(InputStream istrm, int len)
{
    auto rawData = New!(ubyte[])(len);
    istrm.fillArray(rawData);
    return rawData;
}

void readMesh(InputStream istrm, Trimesh mesh)
{
    mesh.id = istrm.read!int;
    int meshNameSize = istrm.read!int;  
    mesh.name = istrm.readString(meshNameSize);
    int meshIsExternal = istrm.read!int;
    string externalMeshFilename;
    if (meshIsExternal)
    {
        int externalMeshFilenameSize = istrm.read!int;
        if (externalMeshFilenameSize)
        {
            externalMeshFilename = istrm.readString(externalMeshFilenameSize);
            // TODO
            Delete(externalMeshFilename);
        }
    }
    else
    {
        int numVertices = istrm.read!int;
        if (numVertices)
        {
            ubyte[] verticesBytes = istrm.readRawData(numVertices * 12); // 3x4 bytes per vertex
            mesh.vertices = cast(Vector3f[])verticesBytes;

            ubyte[] normalsBytes = istrm.readRawData(numVertices * 12); // 3x4 bytes per vertex
            mesh.normals = cast(Vector3f[])normalsBytes;

            ubyte[] texcoordsBytes = istrm.readRawData(numVertices * 8); // 2x4 bytes per vertex
            mesh.texcoords = cast(Vector2f[])texcoordsBytes;

            int haveLightmapTexCoords = istrm.read!int;
            if (haveLightmapTexCoords)
            {
                ubyte[] haveLightmapTexCoordsBytes = istrm.readRawData(numVertices * 8);
                mesh.lightmapTexcoords = cast(Vector2f[])haveLightmapTexCoordsBytes;
            }
        }

        int numTriangles = istrm.read!int;
        if (numTriangles)
        {
            ubyte[] trianglesBytes = istrm.readRawData(numTriangles * 12); // 3x4 bytes per triangle
            mesh.triangles = cast(int[3][])trianglesBytes;
        }

        int haveSkeletalAnimation = istrm.read!int;
        int haveMorphTargetAnimation = istrm.read!int;  
    }
}

//version = DGL3Debug;

void readEntity(InputStream istrm, DGL3Entity entity)
{
    entity.id = istrm.read!int;
    int entityNameSize = istrm.read!int;  
    string entityName = istrm.readString(entityNameSize);
    int entityIsExternal = istrm.read!int;
    string externalEntityFilename;
    if (entityIsExternal)
    {
        int externalEntityFilenameSize = istrm.read!int;
        if (externalEntityFilenameSize)
        {
            externalEntityFilename = istrm.readString(externalEntityFilenameSize);
            // TODO
            Delete(externalEntityFilename);
        }
    }
    int entityMeshId = istrm.read!int; 

    version(DGL3Debug)
    {
        writefln("entity.id: %s", entity.id);
        writefln("entityName: %s", entityName);
        writefln("entityMeshId: %s", entityMeshId);
    }

    Vector3f position = istrm.readVector3f;
    Quaternionf rotation = istrm.readQuaternionf;
    Vector3f scaling = istrm.readVector3f;

    entity.setTransformation(position, rotation, scaling);
    entity.meshID = entityMeshId;

    version(DGL3Debug)
    {
        writefln("entity.position: %s", entity.position);
        writefln("entity.rotation: %s", entity.rotation);
        writefln("entity.scaling: %s", entity.scaling);
    }

    int numCustomProperties = istrm.read!int;

    if (numCustomProperties)
    {
        foreach(propi; 0..numCustomProperties)
        {
            int propNameSize = istrm.read!int;
            string propName = istrm.readString(propNameSize);
            int propType = istrm.read!int;
            Property prop;
            if (propType == 0)
                prop = Property(istrm.read!int);
            else if (propType == 1)
                prop = Property(istrm.read!float);
            else if (propType == 2)
                prop = Property(istrm.readVector2f);
            else if (propType == 3)
                prop = Property(istrm.readVector3f);
            else if (propType == 4)
                prop = Property(istrm.readVector4f);
            else if (propType == 5)
            {
                int propStrSize = istrm.read!int;
                prop = Property(istrm.readString(propStrSize));
            }
            version(DGL3Debug)
            {
                writefln("entity.%s = %s", propName, prop);
            }
            entity.props[propName] = prop;
        }
    }

    if (entityName.length)
        Delete(entityName);
}

void readDGL3(InputStream istrm, DGL3Resource scene)
{
    // Read magic string
    char[4] magic;
    istrm.fillArray(magic);
    version(DGL3Debug)
    {
        writeln(magic);
    }
    assert(magic == "DGL3");
    
    // Read file header
    int formatVersion = istrm.read!int;
    version(DGL3Debug)
    {
        writefln("formatVersion: %s", formatVersion);
    }
    assert(formatVersion == 300);
    
    int nameSize = istrm.read!int;   
    int creatorNameSize = istrm.read!int;    
    int dataSize = istrm.read!int;
    
    version(DGL3Debug)
    {
        writefln("nameSize: %s", nameSize);
        writefln("creatorNameSize: %s", creatorNameSize);
        writefln("dataSize: %s", dataSize);
    }

    if (nameSize)
        scene.name = istrm.readString(nameSize);
    
    if (creatorNameSize)
        scene.creator = istrm.readString(creatorNameSize);
    
    if (dataSize)
        scene.metadata = istrm.readRawData(dataSize);

    version(DGL3Debug)
    {
        writefln("scene.name: %s", scene.name);
        writefln("scene.creator: %s", scene.creator);
        writefln("scene.metadata: %s", scene.metadata);
    }

    // Read scene header
    int numMeshes = istrm.read!int;
    int numEntities = istrm.read!int;
    int numLights = istrm.read!int;

    version(DGL3Debug)
    {
        writefln("numMeshes: %s", numMeshes);
        writefln("numEntities: %s", numEntities);
        writefln("numLights: %s", numLights);
    }

    // Read meshes
    scene.meshes = New!(Trimesh[])(numMeshes);
    foreach(i; 0..numMeshes)
    {
        version(DGL3Debug)
        {
            writeln("-----");
        }

        Trimesh mesh = New!Trimesh;
        readMesh(istrm, mesh);
        mesh.generateTangents();
        mesh.calcBoundingGeometry();

        version(DGL3Debug)
        {
            writefln("mesh.id: %s", mesh.id);
            writefln("mesh.name: %s", mesh.name);
            writefln("mesh.vertices.length: %s", mesh.vertices.length);
            writefln("mesh.triangles.length: %s", mesh.triangles.length);
        }

        scene.meshes[i] = mesh;
    }

    // Read entities
    scene.entities = New!(DGL3Entity[])(numEntities);
    foreach(i; 0..numEntities)
    {
        version(DGL3Debug)
        {
            writeln("-----");
        }

        DGL3Entity entity = New!DGL3Entity;
        readEntity(istrm, entity);
        entity.model = scene.meshes[entity.meshID];
        scene.entities[i] = entity;
    }
}

