module extending;

import std.math;
import dlib.core.memory;
import dlib.math.vector;
import dgl.core.api;
import dgl.core.interfaces;
import dgl.core.event;
import dgl.core.application;
import dgl.templates.app3d;
import dgl.templates.freeview;

class ShapeDisk: Drawable
{
    uint displayList;
    
    this(float radius, uint steps)
    {
        displayList = glGenLists(1);
        glNewList(displayList, GL_COMPILE);
        glBegin(GL_TRIANGLE_FAN);
        glNormal3f(0, 0, 1);
        glVertex3f(0, 0, 0);
        float stepAngle = (2 * PI) / steps;
        foreach(i; 0..steps+1)
        {
            float angle = i * stepAngle;
            Vector3f v = Vector3f(cos(angle) * radius, sin(angle) * radius, 0.0f);
            glVertex3fv(v.arrayof.ptr);
        }
        glEnd();
        glEndList();
    }

    override void draw(double dt)
    {
        glCallList(displayList);
    }
    
    ~this()
    {
        glDeleteLists(displayList, 1);
    }
}

class Simple3DApp: Application3D
{
    Freeview freeview;
    
    this()
    {
        super();
        
        freeview = New!Freeview(eventManager);
        registerObject("freeview", freeview);
        
        auto disk = New!ShapeDisk(5, 20);
        registerObject("disk", disk);
        createEntity3D(disk);
        
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

