/*
Copyright (c) 2014-2015 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dgl.core.application;

import std.stdio;
import std.conv;
import std.process;
import std.string;

import dlib.core.memory;
import dlib.image.color;

import derelict.opengl.gl;
import derelict.opengl.glu;
import derelict.sdl.sdl;
import derelict.freetype.ft;

import dgl.core.interfaces;
import dgl.core.event;

/*
 * Basic SDL/OpenGL application.
 * GC-free, but may throw on initialization failure
 */
class Application: EventListener
{
    Color4f clearColor;
    
    // TODO: configuration manager
    this(
        uint width, 
        uint height, 
        string caption = "DGL application", 
        bool unicodeInput = true, 
        bool showCursor = true,
        bool resizableWindow = true)
    {
        if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK) < 0)
            throw new Exception("Failed to init SDL: " ~ to!string(SDL_GetError()));
            
        SDL_EnableUNICODE(unicodeInput);
        
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 5);
        SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 5);
        SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 5);
        SDL_GL_SetAttribute(SDL_GL_BUFFER_SIZE, 32);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 16);
        
        environment["SDL_VIDEO_WINDOW_POS"] = "";
        environment["SDL_VIDEO_CENTERED"] = "1";
        
        auto screen = SDL_SetVideoMode(width, height, 0, SDL_OPENGL | SDL_RESIZABLE);
        if (screen is null)
            throw new Exception("Failed to set video mode: " ~ to!string(SDL_GetError()));
            
        SDL_WM_SetCaption(toStringz(caption), null);
        SDL_ShowCursor(showCursor);
        
        DerelictGL.loadClassicVersions(GLVersion.GL12); 
        DerelictGL.loadExtensions();
        
        clearColor = Color4f(0, 0, 0);
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        glEnable(GL_NORMALIZE);
        glShadeModel(GL_SMOOTH);
        glAlphaFunc(GL_GREATER, 0.0);
        glEnable(GL_ALPHA_TEST);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        glEnable(GL_CULL_FACE);
        
        EventManager emngr = New!EventManager(width, height);
        super(emngr);
    }
    
    void run()
    {
        while(eventManager.running)
        {
            eventManager.update();
            processEvents();
            glViewport(0, 0, eventManager.windowWidth, eventManager.windowHeight);
            glClearColor(clearColor.r, clearColor.g, clearColor.b, clearColor.a);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            glLoadIdentity();
            
            onUpdate();           
            onRedraw();
            
            SDL_GL_SwapBuffers();
        }

        SDL_Quit();
    }
    
    // Override me
    void onUpdate() {}
    
    // Override me
    void onRedraw() {}
    
    // Override me
    override void onKeyDown(int key)
    {    
        if (key == SDLK_ESCAPE)
        {
            eventManager.running = false;
            onQuit();
        }
    }
    
    override void onResize(int width, int height)
    {
        writefln("Application resized to %s, %s", eventManager.windowWidth, eventManager.windowHeight);
        SDL_Surface* screen = SDL_SetVideoMode(eventManager.windowWidth, 
                                               eventManager.windowHeight, 
                                               0, SDL_OPENGL | SDL_RESIZABLE);
        if (screen is null)
            throw new Exception("failed to set video mode: " ~ to!string(SDL_GetError()));
    }
    
    void freeContent()
    {
        Delete(eventManager);
    }
    
    override void free()
    {
        freeContent();
        Delete(this);
    }
}

// TODO:
// Under Linunx, user should be able to select
// between system libraries and local ones 
void loadLibraries()
{
    version(Windows)
    {
        enum sharedLibSDL = "SDL.dll";
        enum sharedLibFT = "freetype.dll";
    }
    version(linux)
    {
        enum sharedLibSDL = "./libsdl.so";
        enum sharedLibFT = "./libfreetype.so";
    }
    
    DerelictGL.load();
    DerelictGLU.load();
    DerelictSDL.load(sharedLibSDL);
    DerelictFT.load(sharedLibFT);
}
