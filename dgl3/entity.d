module dgl3.entity;

import std.conv;
import dlib.core.memory;
import dlib.container.dict;
import dlib.math.vector;
import dlib.math.quaternion;
import dgl.graphics.entity;

enum PropType
{
    Undefined,
    Int,
    Float,
    Vec2f,
    Vec3f,
    Vec4f,
    String
}

struct Property
{
    PropType type = PropType.Undefined;

    this(int v)
    {
        type = PropType.Int;
        asInt = v;
    }

    this(float v)
    {
        type = PropType.Float;
        asFloat = v;
    }

    this(Vector2f v)
    {
        type = PropType.Vec2f;
        asVector2f = v;
    }

    this(Vector3f v)
    {
        type = PropType.Vec3f;
        asVector3f = v;
    }

    this(Vector4f v)
    {
        type = PropType.Vec4f;
        asVector4f = v;
    }

    this(string v)
    {
        type = PropType.String;
        asString = v;
    }

    union
    {
        int asInt;
        float asFloat;
        Vector2f asVector2f;
        Vector3f asVector3f;
        Vector4f asVector4f;
        string asString;
    }

    string toString()
    {
        if (type == PropType.Int)
            return to!string(asInt);
        else if (type == PropType.Float)
            return to!string(asFloat);
        else if (type == PropType.Vec2f)
            return asVector2f.toString;
        else if (type == PropType.Vec3f)
            return asVector3f.toString;
        else if (type == PropType.Vec4f)
            return asVector4f.toString;
        else if (type == PropType.String)
            return asString;
        else
            return "Undefined";
    }

    void free()
    {
        if (type == PropType.String)
        {
            if (asString.length)
                Delete(asString);
        }
    }
}

class DGL3Entity: Entity
{
    Dict!(Property, string) props;

    this()
    {
        super();
        props = dict!(Property, string);
    }

    ~this()
    {
        foreach(k, v; props)
        {
            v.free();
            Delete(k);
        }
        Delete(props);
    }
}

