/*
Copyright (c) 2013-2015 Timur Gafarov 

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

module dgl.graphics.glslshader;

private
{
    import std.stdio;
    import std.string;
    
    import derelict.opengl.gl;
    import derelict.opengl.glext;
    
    import dgl.graphics.shader;
}

final class GLSLShader: Shader
{
    GLenum shaderVert;
    GLenum shaderFrag;
    GLenum shaderProg;
    bool _supported;

    this(string vertexProgram, string fragmentProgram)
    {
        _supported = supported;

        if (_supported)
        {
            shaderProg = glCreateProgramObjectARB();
            shaderVert = glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB);
            shaderFrag = glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);

            int len;
            char* srcptr;

            len = vertexProgram.length;
            srcptr = cast(char*)vertexProgram.ptr;
            glShaderSourceARB(shaderVert, 1, &srcptr, &len);

            len = fragmentProgram.length;
            srcptr = cast(char*)fragmentProgram.ptr;
            glShaderSourceARB(shaderFrag, 1, &srcptr, &len);

            glCompileShaderARB(shaderVert);
            glCompileShaderARB(shaderFrag);
            glAttachObjectARB(shaderProg, shaderVert);
            glAttachObjectARB(shaderProg, shaderFrag);
            glLinkProgramARB(shaderProg);

            char[1000] infobuffer = 0;
            int infobufferlen = 0;

            glGetInfoLogARB(shaderVert, 999, &infobufferlen, infobuffer.ptr);
            if (infobuffer[0] != 0)
                writefln("vp@shader.glsl.modifier: %s\n",infobuffer);

            glGetInfoLogARB(shaderFrag, 999, &infobufferlen, infobuffer.ptr);
            if (infobuffer[0] != 0)
                writefln("fp@shader.glsl.modifier:%s\n",infobuffer);
        }
    }

    override @property bool supported()
    {
        return DerelictGL.isExtensionSupported("GL_ARB_shading_language_100");
    }

    override void bind(double delta)
    {
        if (_supported)
        {
            glUseProgramObjectARB(shaderProg);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture0")), 0);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture1")), 1);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture2")), 2);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture3")), 3);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture4")), 4);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture5")), 5);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture6")), 6);
            glUniform1iARB(glGetUniformLocationARB(shaderProg, toStringz("dgl_Texture7")), 7);
        }
    }

    override void unbind()
    {
        if (_supported)
        {
            glUseProgramObjectARB(0);
        }
    }

    override void free()
    {
    }
}
