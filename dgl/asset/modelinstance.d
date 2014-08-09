module dgl.asset.modelinstance;

import derelict.opengl.gl;

import dgl.core.drawable;
import dgl.graphics.material;
import dgl.asset.dat;
import dgl.asset.fgroup;

class ModelInstance: Drawable
{
    DatObject dat;
    FaceGroup[int] fgroups;

    this(DatObject dat)
    {
        this.dat = dat;
        this.fgroups = createFGroups(dat);
    }

    override void draw(double dt)
    {
        foreach(fgroup; fgroups)
        {
            Material* mat = fgroup.materialIndex in dat.materialByIndex;
            if (mat !is null)
                mat.bind(dt);
            // TODO: else bind default material
            glCallList(fgroup.displayList);
            if (mat !is null)
                mat.unbind();
        }
    }
    
    override void free() { }
}
