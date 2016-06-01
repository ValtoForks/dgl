module props;

import std.stdio;
import std.ascii;
import std.conv;
import dlib.core.memory;
import dlib.container.array;
import dlib.container.dict;
import dlib.text.utils;
import dlib.math.vector;
import dlib.image.color;
import dgl3.slicelexer;

enum PropType
{
    Undefined,
    Number,
    Vector,
    String
}

struct Property
{
    PropType type;
    string data;

    string toString()
    {
        return data;
    }

    double toDouble()
    {
        return to!double(data);
    }

    float toFloat()
    {
        return to!float(data);
    }

    int toInt()
    {
        return to!int(data);
    }
    
    int toUInt()
    {
        return to!uint(data);
    }

    bool toBool()
    {
        return cast(bool)cast(int)(to!float(data));
    }

    Vector3f toVector3f()
    {
        return Vector3f(data);
    }

    Vector4f toVector4f()
    {
        return Vector4f(data);
    }

    Color4f toColor4f()
    {
        return Color4f(Vector4f(data));
    }
}

class Properties
{
    protected Dict!(Property, string) props;
    
    this()
    {
        props = dict!(Property, string);
    }
    
    bool parse(string input)
    {
        return parseProperties(input, props);
    }
    
    Property opIndex(string name)
    {
        if (name in props)
            return props[name];
        else
            return Property(PropType.Undefined, "");
    }
    
    Property opDispatch(string s)()
    {
        if (s in props)
            return props[s];
        else
            return Property(PropType.Undefined, "");
    }
    
    Property* opIn_r(string k)
    {
        return (k in props);
    }
    
    int opApply(int delegate(string, ref Property) dg)
    {
        foreach(k, v; props)
        {
            dg(k, v);
        }

        return 0;
    }
    
    ~this()
    {
        foreach(k, v; props)
        {
            Delete(k);
            Delete(v.data);
        }
        Delete(props);
    }
}

bool isWhiteStr(string s)
{
    bool res;
    foreach(c; s)
    {
        res = false;
        foreach(w; std.ascii.whitespace)
        {
            if (c == w)
                res = true;
        }
        
        if (c == '\n' || c == '\r')
            res = true;
    }
    return res;
}

bool isValidIdentifier(string s)
{
    return (isAlpha(s[0]) || s[0] == '_');
}

string copyStr(T)(T[] s)
{
    auto res = New!(char[])(s.length);
    foreach(i, c; s)
        res[i] = c;
    return cast(string)res;
}

bool parseProperties(string input, Dict!(Property, string) props)
{
    enum Expect
    {
        PropName,
        Colon,
        Semicolon,
        Value,
        String,
        Vector,
        Number
    }

    bool res = true;
    auto lexer = New!SliceLexer(input, [":", ";", "\"", "[", "]", ","]);
    lexer.ignoreNewlines = true;
    
    Expect expect = Expect.PropName;
    string propName;
    DynamicArray!char propValue;
    PropType propType;
    
    while(true)
    {
        auto lexeme = lexer.getLexeme();
        if (lexeme.length == 0) 
        {
            if (expect != Expect.PropName)
            {
                writefln("Error: unexpected end of string");
                res = false;
            }
            break;
        }
        
        if (isWhiteStr(lexeme) && expect != Expect.String)
            continue;
        
        if (expect == Expect.PropName)
        {
            if (!isValidIdentifier(lexeme))
            {
                writefln("Error: illegal identifier name \"%s\"", lexeme);
                res = false;
                break;
            }
            
            propName = lexeme;
            expect = Expect.Colon;
        }
        else if (expect == Expect.Colon)
        {
            if (lexeme != ":")
            {
                writefln("Error: expected \":\", got \"%s\"", lexeme);
                res = false;
                break;
            }
            
            expect = Expect.Value;
        }
        else if (expect == Expect.Semicolon)
        {
            if (lexeme != ";")
            {
                writefln("Error: expected \";\", got \"%s\"", lexeme);
                res = false;
                break;
            }
            
            auto nameCopy = copyStr(propName);
            auto valueCopy = copyStr(propValue.data);
            props[nameCopy] = Property(propType, valueCopy);
            
            expect = Expect.PropName;
            propName = "";
            propValue.free();
        }
        else if (expect == Expect.Value)
        {
            if (lexeme == "\"")
            {
                propType = PropType.String;
                expect = Expect.String;
            }
            else if (lexeme == "[")
            {
                propType = PropType.Vector;
                expect = Expect.Vector;
                propValue.append(lexeme);
            }
            else
            {
                propType = PropType.Number;
                propValue.append(lexeme);
                expect = Expect.Semicolon;
            }
        }
        else if (expect == Expect.String)
        {
            if (lexeme == "\"")
                expect = Expect.Semicolon;
            else
                propValue.append(lexeme);
        }
        else if (expect == Expect.Vector)
        {
            if (lexeme == "]")
                expect = Expect.Semicolon;

            propValue.append(lexeme);
        }
    }
    
    propValue.free();
    Delete(lexer);
    
    return res;
}
