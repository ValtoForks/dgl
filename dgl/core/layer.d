module dgl.core.layer;

import std.stdio;
import std.conv;

import dlib.core.memory;
import dlib.container.array;

import derelict.opengl.gl;
import derelict.opengl.glu;
import derelict.sdl.sdl;

import dgl.core.event;
import dgl.core.interfaces;
import dgl.core.application;

enum LayerType
{
    Layer2D,
    Layer3D
}

class Layer: EventListener, Drawable
{
    LayerType type;
    float aspectRatio;
    
    DynamicArray!Drawable drawables;
    DynamicArray!Modifier modifiers;
        
    this(EventManager emngr, LayerType type)
    {
        super(emngr);
        this.type = type;
        this.aspectRatio = cast(float)emngr.windowWidth / cast(float)emngr.windowHeight;
    }
    
    void addDrawable(Drawable d)
    {
        drawables.append(d);
    }
    
    void addModifier(Modifier m)
    {
        modifiers.append(m);
    }
    
    void draw(double dt)
    {       
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
        glLoadIdentity();

        if (type == LayerType.Layer2D)
            glOrtho(0, eventManager.windowWidth, 0, eventManager.windowHeight, -1, 1);
        else
            gluPerspective(60, aspectRatio, 0.1, 400.0);
        glMatrixMode(GL_MODELVIEW);
        
        glLoadIdentity();

        foreach(i, m; modifiers.data)
            m.bind(dt);
        foreach(i, drw; drawables.data)
            drw.draw(dt);
        foreach(i, m; modifiers.data)
            m.unbind();
        
        glMatrixMode(GL_PROJECTION);
        glPopMatrix();
        glMatrixMode(GL_MODELVIEW);
    }
    
    void freeContent()
    {
        writefln("Deleting %s drawable(s) in layer...", drawables.length);
        foreach(i, drw; drawables.data)
            drw.free();
        drawables.free();
    }
    
    override void free()
    {
        freeContent();
        Delete(this);
    }
    
    override void onResize(int width, int height)
    {
        aspectRatio = cast(float)width / cast(float)height;
    }
}
