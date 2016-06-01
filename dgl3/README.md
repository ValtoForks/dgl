DGL3 format
===========
DGL3 is a new experimental model format for DGL. It is far more effective than its predecessor, DGL2, when dealing with mid-poly and high-poly meshes (>1000 triangles). It is not finished yet (no materials support).

Usage
-----
```d
import dlib.core.memory;
import dlib.math;
import dgl.core.api;
import dgl.core.application;
import dgl.templates.app3d;
import dgl.templates.freeview;
import dgl3.resource;

class Simple3DApp: Application3D
{
    Freeview freeview;
    DGL3Resource res;
    
    this()
    {
        super();
        
        setDefaultLoadingImage("media/loading.png");
        mountDirectory("media");
        res = New!DGL3Resource;
        resourceManager.addResource("model.dgl3", res);
        loadResources();

        freeview = New!Freeview(eventManager);
        registerObject("freeview", freeview);

        foreach(e; res.entities)
            addEntity3D(e);
        
        auto light = addPointLight(Vector3f(3, 3, 3));
    }
    
    override void onUpdate(double dt)
    {
        super.onUpdate(dt);
        
        freeview.update();
        setCameraMatrix(freeview.getCameraMatrix());
    }

    override void onKeyDown(int key)
    {
        if (key == SDLK_ESCAPE)
        {
            exit();
        }
    }
}
```