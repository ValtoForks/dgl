module loading;

import dlib.core.memory;
import dlib.math.vector;
import dgl.core.api;
import dgl.core.event;
import dgl.core.application;
import dgl.templates.app3d;
import dgl.templates.freeview;
import dgl.graphics.shapes;

class Simple3DApp: Application3D
{
    Freeview freeview;
    
    this()
    {
        super();
        
        setDefaultLoadingImage("media/loading.png");
        mountDirectory("media");
        string model = "materials.dgl2";
        addModelResource(model);
        loadResources();
        
        addLightsFromModel(model);
        addEntitiesFromModel(model);
        
        freeview = New!Freeview(eventManager);
        registerObject("freeview", freeview);
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

void main(string[] args)
{
    initDGL();
    auto app = New!Simple3DApp();
    app.run();
    Delete(app);
    deinitDGL();
}

