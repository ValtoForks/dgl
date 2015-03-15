module dgl.core.room;

import std.stdio;
import dlib.core.memory;
import dlib.image.color;
import dlib.container.array;
import dlib.container.aarray;
import dgl.core.application;
import dgl.core.event;
import dgl.core.layer;

class Room: EventListener
{
    RoomApplication app;
    DynamicArray!Layer layers;
    
    this(EventManager em, RoomApplication app)
    {
        super(em);
        this.app = app;
    }
    
    // Add window-aligned layer
    Layer addLayer(LayerType type)
    {
        Layer layer = New!Layer(
            eventManager, 
            type);
        layers.append(layer);
        return layer;
    }
    
    // Add user layer
    Layer addLayer(Layer layer)
    {
        layers.append(layer);
        return layer;
    }
    
    void onUpdate()
    {
        processEvents();
        foreach(i, layer; layers.data)
        {
            layer.processEvents();
        }
    }
    
    void onRedraw()
    {
        foreach(i, layer; layers.data)
        {
            layer.draw(eventManager.deltaTime);
        }
    }
    
    void freeContent()
    {
        writefln("Deleting %s layer(s) in Room...", layers.length);
        foreach(i, layer; layers.data)
            layer.free();
        layers.free();
    }
    
    override void free()
    {
        freeContent();
        Delete(this);
    }
}

class RoomApplication: Application
{    
    AArray!Room rooms;
    Room currentRoom;
    string currentRoomName;

    // TODO: configuration manager
    this(
        uint width = 800, 
        uint height = 600, 
        string caption = "DGL application", 
        bool unicodeInput = true, 
        bool showCursor = true,
        bool resizableWindow = true)
    {
        super(width, height, caption, unicodeInput, showCursor, resizableWindow);
    }
    
    Room getRoom(string name)
    {
        return rooms[name];
    }
    
    void addRoom(string name, Room room)
    {
        if (name in rooms)
        {
            rooms[name].free();
            rooms.remove(name);
        }
        rooms[name] = room;
    }
    
    void loadRoom(string name, bool deleteCurrent = false)
    {
        setCurrentRoom(name, deleteCurrent);
    }
    
    void setCurrentRoom(string name, bool deleteCurrent = false)
    {
        if (currentRoom)
        {
            if (deleteCurrent)
            {
                currentRoom.free();
                rooms.remove(currentRoomName);
            }
        }
        currentRoom = rooms[name];
        currentRoomName = name;
    }
    
    override void onUpdate()
    {
        if (currentRoom)
            currentRoom.onUpdate();
    }
    
    override void onRedraw()
    {
        if (currentRoom)
            currentRoom.onRedraw();
    }
    
    override void freeContent()
    {
        super.freeContent();
        
        writefln("Deleting RoomApplication...");
        
        foreach(i, room; rooms)
            room.free();
        Delete(rooms);
    }
    
    override void free()
    {
        freeContent();
        Delete(this);
    }
}