module dgl.dml.dml;

import std.stdio;
import std.conv;
import dlib.core.memory;
import dlib.math.vector;
import dlib.image.color;
import dgl.dml.lexer;

struct DMLValue
{
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

    bool toBool()
    {
        return cast(bool)to!int(data);
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

//TODO: rewrite without GC
struct DMLStruct
{
    DMLValue[string] data;

    bool addKeyValue(Lexeme key, Lexeme val)
    {
        string k = key.str.data.to!string;
        string v = val.str.data[1..$-1].to!string;
        DMLValue dmlval = DMLValue(v);

        if (k in data)
            return false;
        else
        {
            data[k] = dmlval;
            return true;
        }
    }
}

//TODO: rewrite without GC
struct DMLData
{
    DMLStruct root;
    alias root this;
}

bool parseDML(string text, DMLData* data)
{
    Lexer lexer = Lexer(text);

    Lexeme lexeme;
    lexeme = lexer.get();
    if (lexeme.valid)
    {
        if (lexeme.str.data == "{")
        {
            lexeme.free();
            return parseStruct(&lexer, &data.root);
        }
        else
        {
            lexeme.valid = false;
            writefln("DML error at line %s: expected \"{\", not \"%s\"", lexer.line, lexeme.str.data);
            return false;
        }
    }
    else
    {
        writeln("DML error: empty string");
        return false;
    }
}

bool parseStruct(Lexer* lexer, DMLStruct* stru)
{
    //writeln("Parsing struct...");
    Lexeme lexeme = lexer.current;
    bool noError = true;
    while(noError && lexeme.valid && lexeme.str.data != "}")
    {
        lexeme = lexer.get();
        if (lexeme.str.data != "}")
        {
            noError = parseStatement(lexer, stru);
            lexeme = lexer.current;
        }
    }

    if (lexeme.str.data != "}")
    {
        lexeme.free();
        writefln("DML syntax error at line %s: missing \"}\"", lexer.line);
        return false;
    }

    lexeme.free();
    return noError;
}

bool parseStatement(Lexer* lexer, DMLStruct* stru)
{
    Lexeme id, value;
    Lexeme lexeme = lexer.current;
    // TODO: assert identifier

    id = lexeme;
    lexeme = lexer.get();
    if (lexeme.str.data != "=")
    {
        writefln("DML syntax error at line %s: \"=\" expected, got \"%s\"", lexer.line, lexeme.str.data);
        lexeme.free();
        return false;
    }
    lexeme.free();
    lexeme = lexer.get();
    if (!isString(lexeme))
    {
        writefln("DML syntax error at line %s: string expected, got \"%s\"", lexer.line, lexeme.str.data);
        lexeme.free();
        return false;
    }
    value = lexeme;
    lexeme = lexer.get();
    if (lexeme.str.data != ";")
    {
        writefln("DML syntax error at line %s: \";\" expected, got \"%s\"", lexer.line, lexeme.str.data);
        lexeme.free();
        return false;
    }
    lexeme.free();

    //writefln("Parsed statement: %s = %s", id.str.data, value.str.data);
    stru.addKeyValue(id, value);
    id.free();
    value.free();

    return true;
}

bool isString(Lexeme lexeme)
{
    return lexeme.str.data[0] == '\"' &&
           lexeme.str.data[$-1] == '\"';
}

