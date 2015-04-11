module dgl.asset.scene;

import std.stdio;

import dlib.core.memory;
import dlib.container.aarray;

import dgl.core.interfaces;
import dgl.graphics.material;
import dgl.graphics.texture;
import dgl.graphics.lightmanager;
import dgl.asset.resman;
import dgl.asset.entity;
import dgl.asset.mesh;
import dgl.asset.dgl2;

/*
 * Scene class stores a number of entities
 * together with their meshes and materials.
 * Textures are stored separately, in ResourceManager
 * (because textures may be shared between several
 * Scenes).
 * Scene is bind to ResourceManager.
 * Scene data is loaded from DGL2 file.
 */

class Scene: Drawable
{
    ResourceManager rm;
    AArray!Entity entities;
    AArray!Mesh meshes;
    AArray!Material materials;

    this(ResourceManager rm)
    {
        this.rm = rm;
        entities = New!(AArray!Entity)();
        meshes = New!(AArray!Mesh)();
        materials = New!(AArray!Material)();
    }

    void load(string filename)
    {
        // TODO: free the data
        auto fstrm = rm.fs.openForInput(filename);
        loadDGL2(fstrm, this);
        fstrm.free();
        resolveLinks();
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
        rm.lm.addObject(e);
        return e;
    }

    Mesh addMesh(string name, Mesh m)
    {
        meshes[name] = m;
        return m;
    }

    Material addMaterial(string name, Material m)
    {
        materials[name] = m;
        return m;
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

    Texture getTexture(string filename)
    {
        return rm.getTexture(filename);
    }

    void freeEntities()
    {
        entities.free();
    }

    void freeMeshes()
    {
        foreach(i, m; meshes)
            m.free();
        meshes.free();
    }

    void freeMaterials()
    {
        foreach(i, m; materials)
            m.free();
        materials.free();
    }

    void freeContent()
    {
        freeEntities();
        freeMeshes();
        freeMaterials();
    }

    void draw(double dt)
    {
        // TODO: draw only entities
        rm.lm.draw(dt);
    }

    void free()
    {
        freeContent();
        Delete(this);
    }

    mixin ManualModeImpl;
}

