module dgl.asset.scene;

import std.stdio;

import dlib.core.memory;
import dlib.container.aarray;

import dgl.core.interfaces;
import dgl.graphics.texture;
import dgl.graphics.material;
import dgl.graphics.lightmanager;
import dgl.ui.font;
import dgl.asset.entity;
import dgl.asset.mesh;

class Scene: Drawable
{
    LightManager lm;
    AArray!Entity entities;
    AArray!Drawable drawables;
    AArray!Mesh meshes;
    AArray!Texture textures;
    AArray!Material materials;
    AArray!Font fonts;

    this()
    {
        lm = New!LightManager();
        lm.lightsVisible = true;

        entities = New!(AArray!Entity)();
        drawables = New!(AArray!Drawable)();
        meshes = New!(AArray!Mesh)();
        textures = New!(AArray!Texture)();
        materials = New!(AArray!Material)();
        fonts = New!(AArray!Font)();
    }

    void resolveLinks()
    {
        foreach(ei, e; entities)
        {
            foreach(mi, material; materials)
            {
                if (e.materialId == material.id)
                {
                    e.modifier = material;
                    break;
                }
            }

            foreach(mi, mesh; meshes)
            {
                if (e.meshId == mesh.id)
                {
                    e.drawable = mesh;
                    break;
                }
            }
        }

        foreach(mi, mesh; meshes)
        {
            mesh.genFaceGroups(this);
        }
    }

    Entity addEntity(string name, Entity e)
    {
        entities[name] = e;
        lm.addObject(e);
        return e;
    }
    
    Drawable addDrawable(string name, Drawable d)
    {
        drawables[name] = d;
        return d;
    }

    Mesh addMesh(string name, Mesh m)
    {
        meshes[name] = m;
        return m;
    }

    Texture addTexture(string name, Texture t)
    {
        textures[name] = t;
        return t;
    }

    Material addMaterial(string name, Material m)
    {
        materials[name] = m;
        return m;
    }
    
    Font addFont(string name, Font f)
    {
        fonts[name] = f;
        return f;
    }

    Drawable getDrawable(string name)
    {
        return drawables[name];
    }
    
    Font getFont(string name)
    {
        return fonts[name];
    }

    Material getMaterialById(int id)
    {
        Material res = null;
        foreach(mi, mat; materials)
        {
            if (mat.id == id)
            {
                res = mat;
                break;
            }
        }
        return res;
    }

    void freeEntities()
    {
        entities.free();
    }
    
    void freeDrawables()
    {
        foreach(i, d; drawables)
            d.free();
        drawables.free();
    }

    void freeMeshes()
    {
        foreach(i, m; meshes)
            m.free();
        meshes.free();
    }
    
    void freeTextures()
    {
        foreach(i, t; textures)
            t.free();
        textures.free();
    }

    void freeMaterials()
    {
        foreach(i, m; materials)
            m.free();
        materials.free();
    }
    
    void freeFonts()
    {
        foreach(i, f; fonts)
            f.free();
        fonts.free();
    }

    void freeContent()
    {
        lm.free();
        freeEntities();
        freeDrawables();
        freeMeshes();
        freeTextures();
        freeMaterials();
        freeFonts();
    }

    void draw(double dt)
    {
        lm.draw(dt);
    }

    void free()
    {
        freeContent();
        Delete(this);
    }

    mixin ManualModeImpl;
}

