module dgl3.trimesh;

import std.algorithm;
import dlib.core.memory;
import dlib.math.vector;
import dlib.geometry.aabb;
import dlib.geometry.sphere;
import dgl.core.api;
import dgl.core.interfaces;

class Trimesh: Drawable
{
    int id;
    string name;
    Vector3f[] vertices;
    Vector3f[] normals;
    Vector2f[] texcoords;
    Vector2f[] lightmapTexcoords;
    Vector4f[] tangents;
    int[3][] triangles;
    Vector3f centroid;
    AABB boundingBox;
    Sphere boundingSphere;

    uint displayList;
    bool wireframe = false;
    bool debugDraw = false;
    bool drawTangentSpace = false;
    float drawTangentSpaceSize = 0.1f;
    bool drawBoundingBox = false;
    bool drawCentroid = false;

    void makeDisplayList()
    {
        if (glIsList(displayList))
            return;

        if (!vertices.length || !normals.length ||
            !texcoords.length || !triangles.length)
            return;

        displayList = glGenLists(1);
        glNewList(displayList, GL_COMPILE);
        drawTriangles();
        glEndList();
    }

    void drawTriangles()
    {
        glBegin(GL_TRIANGLES);
        foreach(tri; triangles)
        {
            glNormal3fv(normals[tri[0]].arrayof.ptr);
            glMultiTexCoord2fvARB(GL_TEXTURE0_ARB, texcoords[tri[0]].arrayof.ptr);
            if (tangents.length)
                glMultiTexCoord4fvARB(GL_TEXTURE2_ARB, tangents[tri[0]].arrayof.ptr);
            glVertex3fv(vertices[tri[0]].arrayof.ptr);

            glNormal3fv(normals[tri[1]].arrayof.ptr);
            glMultiTexCoord2fvARB(GL_TEXTURE0_ARB, texcoords[tri[1]].arrayof.ptr);
            if (tangents.length)
                glMultiTexCoord4fvARB(GL_TEXTURE2_ARB, tangents[tri[1]].arrayof.ptr);
            glVertex3fv(vertices[tri[1]].arrayof.ptr);

            glNormal3fv(normals[tri[2]].arrayof.ptr);
            glMultiTexCoord2fvARB(GL_TEXTURE0_ARB, texcoords[tri[2]].arrayof.ptr);
            if (tangents.length)
                glMultiTexCoord4fvARB(GL_TEXTURE2_ARB, tangents[tri[2]].arrayof.ptr);
            glVertex3fv(vertices[tri[2]].arrayof.ptr);
        }
        glEnd();
    }

    void generateTangents()
    {
        if (!vertices.length  || !normals.length ||
            !texcoords.length || !triangles.length)
            return;

        Vector3f[] sTan = New!(Vector3f[])(vertices.length);
        Vector3f[] tTan = New!(Vector3f[])(vertices.length);
        
        foreach(i, v; sTan)
        {
            sTan[i] = Vector3f(0.0f, 0.0f, 0.0f);
            tTan[i] = Vector3f(0.0f, 0.0f, 0.0f);
        }

        foreach(tri; triangles)
        {
            uint i0 = tri[0];
            uint i1 = tri[1];
            uint i2 = tri[2];

            Vector3f v0 = vertices[i0];
            Vector3f v1 = vertices[i1];
            Vector3f v2 = vertices[i2];

            Vector2f w0 = texcoords[i0];
            Vector2f w1 = texcoords[i1];
            Vector2f w2 = texcoords[i2];

            float x1 = v1.x - v0.x;
            float x2 = v2.x - v0.x;
            float y1 = v1.y - v0.y;
            float y2 = v2.y - v0.y;
            float z1 = v1.z - v0.z;
            float z2 = v2.z - v0.z;

            float s1 = w1[0] - w0[0];
            float s2 = w2[0] - w0[0];
            float t1 = w1[1] - w0[1];
            float t2 = w2[1] - w0[1];

            float r = (s1 * t2) - (s2 * t1);

            // Prevent division by zero
            if (r == 0.0f)
                r = 1.0f;

            float oneOverR = 1.0f / r;

            Vector3f sDir = Vector3f((t2 * x1 - t1 * x2) * oneOverR,
                                     (t2 * y1 - t1 * y2) * oneOverR,
                                     (t2 * z1 - t1 * z2) * oneOverR);
            Vector3f tDir = Vector3f((s1 * x2 - s2 * x1) * oneOverR,
                                     (s1 * y2 - s2 * y1) * oneOverR,
                                     (s1 * z2 - s2 * z1) * oneOverR);

            sTan[i0] += sDir;
            tTan[i0] += tDir;

            sTan[i1] += sDir;
            tTan[i1] += tDir;

            sTan[i2] += sDir;
            tTan[i2] += tDir;
        }

        tangents = New!(Vector4f[])(vertices.length);

        // Calculate vertex tangent
        foreach(i, v; tangents)
        {
            Vector3f n = normals[i];
            Vector3f t = sTan[i];

            // Gram-Schmidt orthogonalize
            Vector3f tangent = (t - n * dot(n, t));
            tangent.normalize();
            
            tangents[i].x = tangent.x;
            tangents[i].y = tangent.y;
            tangents[i].z = tangent.z;

            // Calculate handedness
            if (dot(cross(n, t), tTan[i]) < 0.0f)
	            tangents[i].w = -1.0f;
            else
                tangents[i].w = 1.0f;
        }

        Delete(sTan);
        Delete(tTan);
    }

    void calcBoundingGeometry()
    {
        Vector3f pmin = Vector3f(float.max, float.max, float.max);
        Vector3f pmax = Vector3f(-float.max, -float.max, -float.max);

        foreach(v; vertices)
        {
            if (v.x < pmin.x) pmin.x = v.x;
            if (v.x > pmax.x) pmax.x = v.x;
            if (v.y < pmin.y) pmin.y = v.y;
            if (v.y > pmax.y) pmax.y = v.y;
            if (v.z < pmin.z) pmin.z = v.z;
            if (v.z > pmax.z) pmax.z = v.z;
        }

        boundingBox = boxFromMinMaxPoints(pmin, pmax);
        centroid = boundingBox.center;
        float radius = max(boundingBox.size.x, boundingBox.size.y, boundingBox.size.z);
        boundingSphere = Sphere(centroid, radius);
    }

    override void draw(double dt)
    {
        if (wireframe)
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

        if (!tangents.length)
            generateTangents();

        if (glIsList(displayList))
            glCallList(displayList);
        else
            makeDisplayList();

        if (wireframe)
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);

        if (drawTangentSpace || debugDraw)
        {
            glDisable(GL_LIGHTING); 
            Vector3f p1, p2;
            foreach(tri; triangles)
            foreach(i; 0..3)
            {
                p1 = vertices[tri[i]];

                p2 = p1 + normals[tri[i]] * drawTangentSpaceSize;
                glColor4f(0, 0, 1, 1);
                glBegin(GL_LINES);
                glVertex3fv(p1.arrayof.ptr);
                glVertex3fv(p2.arrayof.ptr);
                glEnd();

                p2 = p1 + tangents[tri[i]].xyz * drawTangentSpaceSize;
                glColor4f(1, 0, 0, 1);
                glBegin(GL_LINES);
                glVertex3fv(p1.arrayof.ptr);
                glVertex3fv(p2.arrayof.ptr);
                glEnd();
            }
            glColor4f(1, 1, 1, 1);
            glEnable(GL_LIGHTING);
        }

        if (drawBoundingBox || debugDraw)
        {
            glColor4f(1, 1, 1, 1);
            glDisable(GL_LIGHTING);
            drawAABB(boundingBox);
            glEnable(GL_LIGHTING);
        }

        if (drawCentroid || debugDraw)
        {
            glColor4f(1, 1, 0, 1);
            glDisable(GL_LIGHTING);
            glDisable(GL_DEPTH_TEST);
            glPointSize(5.0f);
            glBegin(GL_POINTS);
            glVertex3fv(centroid.arrayof.ptr);
            glEnd();
            glPointSize(1.0f);
            glEnable(GL_DEPTH_TEST);
            glEnable(GL_LIGHTING);
        }
    }

    ~this()
    {
        if (glIsList(displayList))
            glDeleteLists(displayList, 1);

        if (name.length)
            Delete(name);
        if (vertices.length)
            Delete(vertices);
        if (normals.length)
            Delete(normals);
        if (texcoords.length)
            Delete(texcoords);
        if (tangents.length)
            Delete(tangents);
        if (lightmapTexcoords.length)
            Delete(lightmapTexcoords);
        if (triangles.length)
            Delete(triangles);
    }
}

void drawAABB(AABB aabb)
{
    glBegin(GL_LINE_STRIP);
    glVertex3f(aabb.pmin.x, aabb.pmin.y, aabb.pmin.z);
    glVertex3f(aabb.pmax.x, aabb.pmin.y, aabb.pmin.z);
    glVertex3f(aabb.pmax.x, aabb.pmax.y, aabb.pmin.z);
    glVertex3f(aabb.pmin.x, aabb.pmax.y, aabb.pmin.z);
    glVertex3f(aabb.pmin.x, aabb.pmin.y, aabb.pmin.z);
    glEnd();

    glBegin(GL_LINE_STRIP);
    glVertex3f(aabb.pmin.x, aabb.pmin.y, aabb.pmax.z);
    glVertex3f(aabb.pmax.x, aabb.pmin.y, aabb.pmax.z);
    glVertex3f(aabb.pmax.x, aabb.pmax.y, aabb.pmax.z);
    glVertex3f(aabb.pmin.x, aabb.pmax.y, aabb.pmax.z);
    glVertex3f(aabb.pmin.x, aabb.pmin.y, aabb.pmax.z);
    glEnd();

    glBegin(GL_LINE_STRIP);
    glVertex3f(aabb.pmin.x, aabb.pmin.y, aabb.pmin.z);
    glVertex3f(aabb.pmin.x, aabb.pmin.y, aabb.pmax.z);
    glEnd();

    glBegin(GL_LINE_STRIP);
    glVertex3f(aabb.pmin.x, aabb.pmax.y, aabb.pmin.z);
    glVertex3f(aabb.pmin.x, aabb.pmax.y, aabb.pmax.z);
    glEnd();

    glBegin(GL_LINE_STRIP);
    glVertex3f(aabb.pmax.x, aabb.pmin.y, aabb.pmin.z);
    glVertex3f(aabb.pmax.x, aabb.pmin.y, aabb.pmax.z);
    glEnd();

    glBegin(GL_LINE_STRIP);
    glVertex3f(aabb.pmax.x, aabb.pmax.y, aabb.pmin.z);
    glVertex3f(aabb.pmax.x, aabb.pmax.y, aabb.pmax.z);
    glEnd();
}

