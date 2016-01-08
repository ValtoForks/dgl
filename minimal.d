module minimal;

import dlib.core.memory;
import dgl.core.api;
import dgl.core.event;
import dgl.core.application;
import dgl.templates.app3d;
import dgl.ui.ftfont;
import dgl.ui.textline;

class SimpleApp: Application3D
{
    this()
    {
        super();
        
        auto font = New!FreeTypeFont("media/DroidSans.ttf", 20);
        registerObject("font", font);
        
        auto text = New!TextLine(font, "Hello, World!");
        registerObject("text", text);
        auto entityText = createEntity2D(text);
        entityText.position.x = 10;
        entityText.position.y = 10;
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
    auto app = New!SimpleApp();
    app.run();
    Delete(app);
    deinitDGL();
}

