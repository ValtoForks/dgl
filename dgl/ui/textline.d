/*
Copyright (c) 2014 Timur Gafarov 

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

module dgl.ui.textline;

private
{
    import derelict.opengl.gl;
    import derelict.opengl.glu;
    import derelict.freetype.ft;

    import dlib.math.vector;
    import dlib.image.color;

    import dgl.core.drawable;
    import dgl.ui.font;
}

enum Alignment
{
    Left,
    Right,
    Center
}

class TextLine: Drawable
{
    Font font;
    Vector2f position;
    Alignment alignment;
    Color4f color;
    string text;
    float textWidth;

    this(Font font, string text, Vector2f position = Vector2f(0, 0))
    {
        this.font = font;
        this.text = text;
        this.position = position;
        this.textWidth = font.textWidth(text);
        this.alignment = Alignment.Left;
        this.color = Color4f(0, 0, 0);
    }

    override void draw(double dt)
    {
        glPushAttrib(GL_LIST_BIT | GL_CURRENT_BIT  | GL_ENABLE_BIT | GL_TRANSFORM_BIT);    
        glDisable(GL_LIGHTING);
        glEnable(GL_TEXTURE_2D);
        glDisable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        // glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

        glColor4f(color.r, color.g, color.b, color.a);

        glPushMatrix();
        glTranslatef(position.x, position.y, 0);
        if (alignment == Alignment.Center)
            glTranslatef(-textWidth * 0.5f, 0, 0);
        if (alignment == Alignment.Right)
            glTranslatef(-textWidth, 0, 0);
        font.draw(text);
        glPopMatrix();
        glPopAttrib();
    }

    override void free() { }

    void setText(string text)
    {
        this.text = text;
        this.textWidth = font.textWidth(text);
    }

    void setPosition(Vector2f pos) 
    {
        this.position = pos;
    }

    void setPosition(float x, float y) 
    {
        this.position.x = x;
        this.position.y = y;
    }
}

