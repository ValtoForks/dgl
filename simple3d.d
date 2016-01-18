module simple3d;

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
        
        freeview = New!Freeview(eventManager);
        registerObject("freeview", freeview);
        
        auto box = New!ShapeBox(Vector3f(1, 1, 1));
        registerObject("box", box);
        createEntity3D(box);
        
        addPointLight(Vector3f(3, 3, 3));
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

