3. Model Loading
================
DGL provides a convenient way to load 3D models from files. The file format for this is DGL2, an easy to read and write binary chunk-based format (read dgl2-specification.md to learn more about it). We provide Blender exporter for DGL2, so you can use Blender as an asset creation tool for your games - install `io_export_dgl2.py` from `tools` folder.

Creating the asset
------------------
Let's start with an empty Blender scene without any objects (select all, then delete). Add Monkey object and add material to it. DGL supports materials with diffuse and specular colors, emittance, shadeless property, and up to 8 texture slots. Textures are assigned via object properties, not UV/Image editor. Default DGL shader accepts first texture as diffuse map, second texture as normal map, and third texture as emission map (specular maps are not currently supported, but you always can write your own shader if you want them). Path to the texture should be relative to your asset file (*.dgl2).

Exporting
---------
Select File -> Export -> DGL Scene (.dgl2) and save your asset somewhere - for example, in `media` folder inside your game directory. Because DGL supports only triangular polygons, all meshes will be triangulated if necessary. All object and material names will be kept, so you can later access them in the game.

Loading
-------
DGL offers a threaded procedure of asset loading. For `Application3D` it looks as simple as follows:

```d
setDefaultLoadingImage("media/loading.png");
mountDirectory("media");
string modelFile = "suzanne.dgl2";
addModelResource(modelFile);
loadResources();
```

`media/loading.png` is an image that should be drawn while assets are loaded. You can override default loading screen with your own rendering code, we will surely return to this feature later.

`mountDirectory` defines a local directory where the asset manager should look for *.dgl2 files - in this example, it is `media`. You can mount several directories - they will be searched for assets from first one to last one (first has highest priority).

`addModelResource` adds a *.dgl2 file to the list of assets that should be loaded. Actual loading is done by `loadResources`.

Now when asset is loaded, we can add it to the scene: 

```d
addEntitiesFromModel(modelFile);
```

You would also want to add a light source (if you don't have one in your model):

```d
addPointLight(Vector3f(0, 5, 5));
```

Viola, you now have your Blender scene in DGL. Have Fun!