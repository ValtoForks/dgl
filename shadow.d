module shadow;

import dlib.core.memory;
import dlib.math.vector;
import dlib.math.quaternion;
import dlib.math.utils;
import dgl.core.api;
import dgl.core.event;
import dgl.core.application;
import dgl.templates.app3d;
import dgl.templates.freeview;
import dgl.graphics.shapes;
import dgl.graphics.shadow;
import dgl.graphics.state;

enum SHADOW_GROUP = 100;

class ShadowApp: Application3D
{
    Freeview freeview;
    ShadowMapPass shadowPass;
    
    this()
    {
        super();
        
        PipelineState.shadowMapSize = 512;
        shadowPass = New!ShadowMapPass(512, 512, scene3d, SHADOW_GROUP, eventManager);
        addPass3D(shadowPass);
        shadowPass.lightRotation = rotationQuaternion(0, degtorad(-80.0f));
        
        setDefaultLoadingImage("media/loading.png");
        mountDirectory("media");
        string model = "simple.dgl2";
        addModelResource(model);
        loadResources();
        
        foreach(name, entity; getModel(model).entitiesByName)
        {            
            entity.groupID = SHADOW_GROUP;
        }
        
        addLightsFromModel(model);
        addEntitiesFromModel(model);
        
        freeview = New!Freeview(eventManager);
        registerObject("freeview", freeview);
    }
    
    override void onUpdate(double dt)
    {
        super.onUpdate(dt);
        
        freeview.update();
        setCameraMatrix(freeview.getCameraMatrix());
        
        shadowPass.update(dt);
    }
    
    override void onRedraw(double dt)
    {
        shadowPass.bind(freeview.camera.getTransformation());       
        super.onRedraw(dt);
        shadowPass.unbind();
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
    auto app = New!ShadowApp();
    app.run();
    Delete(app);
    deinitDGL();
}
