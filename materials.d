module materials;

import std.stdio;
import dlib.core.memory;
import dlib.core.stream;
import dlib.math.vector;

import dlib.filesystem.filesystem;

import dgl.core.api;
import dgl.core.event;
import dgl.core.application;
import dgl.templates.app3d;
import dgl.templates.freeview;
import dgl.graphics.entity;

import dlib.image.color;
import dgl.graphics.material;
import dgl.graphics.texture;

import dlib.math.quaternion;
import dlib.math.utils;
import dgl.graphics.shader;
import dgl.graphics.shadow;
import dgl.graphics.state;
import dgl.graphics.light;
import dgl.asset.dgl3;

enum SHADOW_GROUP = 100;

class Simple3DApp: Application3D
{
    Freeview freeview;
    DGL3Resource model;
    
    ShadowMapPass shadowPass;
    
    this()
    {
        super();
        
        Quaternionf sunLightRot = rotationQuaternion(0, degtorad(-45.0f));
        if (useShadows)
        {
            PipelineState.shadowMapSize = 512;
            shadowPass = New!ShadowMapPass(PipelineState.shadowMapSize, scene3d, SHADOW_GROUP, eventManager);
            addPass3D(shadowPass);
            shadowPass.lightRotation = sunLightRot;
        }
        
        LightManager.sunEnabled = true;
        LightManager.sunPosition = Vector4f(sunLightRot.rotate(Vector3f(0, 0, 1)));
        LightManager.sunPosition.w = 0.0f;
        LightManager.sunColor = Color4f(0.9, 0.8, 0.7, 1);
        
        mountDirectory("data");
        mountDirectory("data/prefabs");
        setDefaultLoadingImage("data/loading.png");

        model = addModelResource("materials_test.dgl3");
        loadResources();
        addEntitiesFromModel(model);

        freeview = New!Freeview(eventManager);
    }

    ~this()
    {
        Delete(freeview);
    }
    
    override void onUpdate(double dt)
    {
        super.onUpdate(dt);
        
        freeview.update();
        setCameraMatrix(freeview.getCameraMatrix());
        
        if (shadowPass)
            shadowPass.update(dt);
    }
    
    override void onRedraw(double dt)
    {
        if (shadowPass)
            shadowPass.bind(freeview.camera.getTransformation());       
        super.onRedraw(dt);
        if (shadowPass)
            shadowPass.unbind();
    }

    void addEntitiesFromModel(DGL3Resource model)
    {
        foreach(e; model.entities)
        {
            if (useShadows)
                e.groupID = SHADOW_GROUP;

            addEntity3D(e);

            if (e.material)
            {
                if (useShaders)
                    e.material.setShader(); 
                else
                {
                    e.material.textures[1] = null;
                    e.material.textures[2] = null;
                }
            }
        }
    }

    override void onKeyDown(int key)
    {
        if (key == SDLK_ESCAPE)
        {
            exit();
        }
    }
}

void main()
{
    writefln("Allocated memory: %s byte(s)", allocatedMemory);
    initDGL();
    auto app = New!Simple3DApp();
    app.run();
    Delete(app);
    deinitDGL();
    writefln("Allocated memory: %s byte(s)", allocatedMemory);
}

