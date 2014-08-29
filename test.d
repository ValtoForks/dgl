module main;

import std.stdio;
import std.conv;

import derelict.sdl.sdl;
import derelict.opengl.gl;

import dlib.math.vector;
import dlib.image.color;

import dgl.core.application;
import dgl.core.layer;
import dgl.ui.ftfont;
import dgl.ui.textline;
import dgl.ui.i18n;
import dgl.templates.freeview;

class TestApp: Application
{
    alias eventManager this;
    FreeTypeFont font;
    TextLine fpsText;

    Layer layer3d;
    Layer layer2d;

    this()
    {
        super(640, 480, "DGL Test App");

        clearColor = Color4f(0.5f, 0.5f, 0.5f);

        layer3d = new FreeviewLayer(videoWidth, videoHeight);
        addLayer(layer3d);

        layer2d = addLayer2D();

        font = new FreeTypeFont("data/fonts/droid/DroidSans.ttf", 27);

        fpsText = new TextLine(font, localizef("FPS: %s", fps), Vector2f(10, 10));
        fpsText.alignment = Alignment.Left;
        fpsText.color = Color4f(1, 1, 1);
        layer2d.addDrawable(fpsText);
    }

    override void onQuit()
    {
        super.onQuit();
    }
    
    override void onKeyDown()
    {
        super.onKeyDown();
    }
    
    override void onMouseButtonDown()
    {
        super.onMouseButtonDown();
    }
    
    override void onUpdate()
    {
        super.onUpdate();

        fpsText.setText(localizef("FPS: %s", fps));
    }
}

void main()
{
    Locale.readLang("locale");
    auto app = new TestApp();
    app.run();
}

