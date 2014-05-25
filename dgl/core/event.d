/*
Copyright (c) 2014 Timur Gafarov 

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/

module dgl.core.event;

private
{
    import core.memory;
    import std.conv;
    import std.stdio;
    
    import derelict.sdl.sdl;
}

public:

enum EventType
{
    KeyDown,
    KeyUp,
    MouseMotion,
    MouseButtonDown,
    MouseButtonUp,
    MouseDoubleClick,
    JoystickButtonDown,
    JoystickButtonUp,
    JoystickAxisChange,
    Resize,
    Quit,
    Enter,
    Leave,
    Drop,
    UserEvent1,
    UserEvent2,
    UserEvent3,
    UserEvent4
}

alias void delegate() Action;

final class EventManager
{
    private:

    Action[int] onKeyDown;
    Action[int] onKeyUp;
    Action[int] onMouseMotion;
    Action[int] onMouseButtonDown;
    Action[int] onMouseButtonUp;
    Action[int] onMouseDoubleClick;
    Action[int] onJoystickButtonDown;
    Action[int] onJoystickButtonUp;
    Action[int] onJoystickAxisChange;
    Action[int] onResize;
    Action[int] onQuit;
    Action[int] onEnter;
    Action[int] onLeave;
    Action[int] onDrop;
    Action[int] onUserEvent1;
    Action[int] onUserEvent2;
    Action[int] onUserEvent3;
    Action[int] onUserEvent4;

    int onKeyDownMaxID = 0;
    int onKeyUpMaxID = 0;
    int onMouseMotionMaxID = 0;
    int onMouseButtonDownMaxID = 0;
    int onMouseButtonUpMaxID = 0;
    int onMouseDoubleClickMaxID = 0;
    int onJoystickButtonDownMaxID = 0;
    int onJoystickButtonUpMaxID = 0;
    int onJoystickAxisChangeMaxID = 0;
    int onResizeMaxID = 0;
    int onQuitMaxID = 0;
    int onEnterMaxID = 0;
    int onLeaveMaxID = 0;
    int onDropMaxID = 0;
    int onUserEvent1MaxID = 0;
    int onUserEvent2MaxID = 0;
    int onUserEvent3MaxID = 0;
    int onUserEvent4MaxID = 0;

    bool beenReset = true;

    bool doubleClickCounterEnabled = false;
    uint doubleClickCounter = 0;
    
    struct Joystick
    {
        SDL_Joystick* sdl_joystick;
        string name;
        int id;
    }
    
    Joystick[int] joysticks;

    public:

    bool running = true;

    bool key_pressed[512] = false;
    int mouse_x = 0;
    int mouse_y = 0;
    bool lmb_pressed = false;
    bool rmb_pressed = false;
    bool mmb_pressed = false;
    bool jbutton_pressed[256] = false;
    short jaxis[256] = 0;

    int event_key = 0;
    int event_button = 0;
    int event_jbutton = 0;
    int event_jaxis = 0;
    short event_jaxisval = 0;
    int event_x = 0;
    int event_y = 0;
    int event_width = 0;
    int event_height = 0;
    string event_file = "";

    float position_x;
    float position_y;
    float rel_position_x;
    float rel_position_y;

    float scale_x = 1.0f;
    float scale_y = 1.0f;

    int window_width;
    int window_height;

    int max_window_width;
    int max_window_height;

    double deltaTime = 0.0;
    double averageDelta = 0.0;
    uint delta_ms = 0;
    int fps = 0;

    string fps_string = "0";

    private:

    void onMouseMotionPersonal()
    {
        mouse_x = event_x;
        mouse_y = event_y;
    }

    void onMouseButtonDownPersonal()
    {
        if (event_button == SDL_BUTTON_LEFT) lmb_pressed = true;
        if (event_button == SDL_BUTTON_RIGHT) rmb_pressed = true;
        if (event_button == SDL_BUTTON_MIDDLE) mmb_pressed = true;
    }

    void onMouseButtonUpPersonal()
    {
        if (event_button == SDL_BUTTON_LEFT) lmb_pressed = false;
        if (event_button == SDL_BUTTON_RIGHT) rmb_pressed = false;
        if (event_button == SDL_BUTTON_MIDDLE) mmb_pressed = false;
    }

    void onMouseDoubleClickPersonal()
    {

    }
    
    void onJButtonDownPersonal()
    {
        jbutton_pressed[event_jbutton] = true;
    }
    
    void onJButtonUpPersonal()
    {
        jbutton_pressed[event_jbutton] = false;
    }
    
    void onJAxisChangePersonal()
    {
        jaxis[event_jaxis] = event_jaxisval;
    }

    public:

    this (int winwidth, int winheight)
    {
        GC.disable();
        
        bindActionToEvent(EventType.MouseMotion, &onMouseMotionPersonal);
        bindActionToEvent(EventType.MouseButtonDown, &onMouseButtonDownPersonal);
        bindActionToEvent(EventType.MouseButtonUp, &onMouseButtonUpPersonal);
        bindActionToEvent(EventType.MouseDoubleClick, &onMouseDoubleClickPersonal);
        bindActionToEvent(EventType.JoystickButtonDown, &onJButtonDownPersonal);
        bindActionToEvent(EventType.JoystickButtonUp, &onJButtonUpPersonal);
        bindActionToEvent(EventType.JoystickAxisChange, &onJAxisChangePersonal);
        
        window_width = winwidth;
        window_height = winheight;

        position_x = window_width / 2;
        position_y = window_height / 2;
        rel_position_x = window_width / 2;
        rel_position_y = window_height / 2;

        auto videoInfo = SDL_GetVideoInfo();
        max_window_width = videoInfo.current_w;
        max_window_height = videoInfo.current_h;
        
        if (SDL_WasInit(SDL_INIT_JOYSTICK))
        {
        bool joysticksDetected = SDL_NumJoysticks() > 0;
        if (joysticksDetected)
        {
            writefln("Number of joysticks: %s", SDL_NumJoysticks());
            foreach(i; 0..SDL_NumJoysticks())
            {
                Joystick joystick;
                joystick.id = i;
                joystick.name = to!string(SDL_JoystickName(0));
                writefln("Joystick %s: %s", joystick.id, joystick.name);
                joystick.sdl_joystick = SDL_JoystickOpen(joystick.id);
                if (joystick.sdl_joystick is null)
                {
                    writefln("Failed to open joystick %s", joystick.id);
                }
                else
                {
                    joysticks[joystick.id] = joystick;
                }
            }
        }
        }
    }
    
    void free()
    {
        foreach(j; joysticks)
        {
            SDL_JoystickClose(j.sdl_joystick);
        }
    }

    int bindActionToEvent(EventType event_type, Action action)
    {
        switch (event_type)
        {
            case EventType.KeyDown: 
                onKeyDown[onKeyDownMaxID] = action;
                return onKeyDownMaxID++;

            case EventType.KeyUp: 
                onKeyUp[onKeyUpMaxID] = action;
                return onKeyUpMaxID++;

            case EventType.MouseMotion: 
                onMouseMotion[onMouseMotionMaxID] = action;
                return onMouseMotionMaxID++;

            case EventType.MouseButtonDown: 
                onMouseButtonDown[onMouseButtonDownMaxID] = action;
                return onMouseButtonDownMaxID++;

            case EventType.MouseButtonUp: 
                onMouseButtonUp[onMouseButtonUpMaxID] = action;
                return onMouseButtonUpMaxID++;

            case EventType.MouseDoubleClick: 
                onMouseDoubleClick[onMouseDoubleClickMaxID] = action;
                return onMouseDoubleClickMaxID++;
                
            case EventType.JoystickButtonDown: 
                onJoystickButtonDown[onJoystickButtonDownMaxID] = action;
                return onJoystickButtonDownMaxID++;
                
            case EventType.JoystickButtonUp: 
                onJoystickButtonUp[onJoystickButtonUpMaxID] = action;
                return onJoystickButtonUpMaxID++;
                
            case EventType.JoystickAxisChange: 
                onJoystickAxisChange[onJoystickAxisChangeMaxID] = action;
                return onJoystickAxisChangeMaxID++;

            case EventType.Resize: 
                onResize[onResizeMaxID] = action;
                return onResizeMaxID++;

            case EventType.Quit: 
                onQuit[onQuitMaxID] = action;
                return onQuitMaxID++;

            case EventType.Enter: 
                onEnter[onEnterMaxID] = action;
                return onEnterMaxID++;

            case EventType.Leave: 
                onLeave[onLeaveMaxID] = action;
                return onLeaveMaxID++;

            case EventType.Drop: 
                onDrop[onDropMaxID] = action;
                return onDropMaxID++;

            case EventType.UserEvent1: 
                onUserEvent1[onUserEvent1MaxID] = action;
                return onUserEvent1MaxID++;

            case EventType.UserEvent2: 
                onUserEvent2[onUserEvent2MaxID] = action;
                return onUserEvent2MaxID++;

            case EventType.UserEvent3: 
                onUserEvent3[onUserEvent3MaxID] = action;
                return onUserEvent3MaxID++;

            case EventType.UserEvent4: 
                onUserEvent4[onUserEvent4MaxID] = action;
                return onUserEvent4MaxID++;

            default:
                assert (false);
        }
    }

    void unbindActionFromEvent(EventType event_type, int action_id)
    {
        switch (event_type)
        {
            case EventType.KeyDown:
                onKeyDown.remove(action_id);
                break;

            case EventType.KeyUp: 
                onKeyUp.remove(action_id);
                break;

            case EventType.MouseMotion: 
                onMouseMotion.remove(action_id);
                break;

            case EventType.MouseButtonDown: 
                onMouseButtonDown.remove(action_id);
                break;

            case EventType.MouseButtonUp: 
                onMouseButtonUp.remove(action_id);
                break;

            case EventType.MouseDoubleClick: 
                onMouseDoubleClick.remove(action_id);
                break;
                
            case EventType.JoystickButtonDown: 
                onJoystickButtonDown.remove(action_id);
                break;
                
            case EventType.JoystickButtonUp: 
                onJoystickButtonUp.remove(action_id);
                break;
                
            case EventType.JoystickAxisChange: 
                onJoystickAxisChange.remove(action_id);
                break;

            case EventType.Resize: 
                onResize.remove(action_id);
                break;

            case EventType.Quit: 
                onQuit.remove(action_id);
                break;

            case EventType.Enter: 
                onEnter.remove(action_id);
                break;

            case EventType.Leave: 
                onLeave.remove(action_id);
                break;

            case EventType.Drop: 
                onDrop.remove(action_id);
                break;

            case EventType.UserEvent1: 
                onUserEvent1.remove(action_id);
                break;

            case EventType.UserEvent2: 
                onUserEvent2.remove(action_id);
                break;

            case EventType.UserEvent3: 
                onUserEvent3.remove(action_id);
                break;

            case EventType.UserEvent4: 
                onUserEvent4.remove(action_id);
                break;

            default:
                assert (false);
        }
    }

    void reset()
    {
        if (!beenReset)
        {
            beenReset = true;

            key_pressed[] = false;
            mouse_x = 0;
            mouse_y = 0;
            lmb_pressed = false;
            rmb_pressed = false;
            mmb_pressed = false;
            jbutton_pressed[] = false;
            jaxis[] = 0;

            doubleClickCounterEnabled = false;
            doubleClickCounter = 0;
        }
    }

    void update()
    {
        static int currentTime;
        static int lastTime;

        static int FPSTickCounter;
        static int FPSCounter = 0;

        currentTime = SDL_GetTicks();
        auto elapsedTime = currentTime - lastTime;
        lastTime = currentTime;
        delta_ms = elapsedTime;
        deltaTime = cast(double)(elapsedTime) * 0.001;

        FPSTickCounter += elapsedTime;
        FPSCounter++;
        if (FPSTickCounter >= 1000) // 1 sec interval
        {
            fps = FPSCounter;
            //fps_string = to!string(fps);
            FPSCounter = 0;
            FPSTickCounter = 0;
			averageDelta = 1.0 / cast(double)(fps);
	    }

        beenReset = false;
        if (doubleClickCounterEnabled) 
            doubleClickCounter++;
        if (doubleClickCounter > 50)
        { 
            doubleClickCounterEnabled = false;
            doubleClickCounter = 0;
        }
        
        if (SDL_WasInit(SDL_INIT_JOYSTICK))
            SDL_JoystickUpdate();

        SDL_Event event;

        while ( SDL_PollEvent(&event) )
        {
            switch (event.type)
            {
                case SDL_KEYDOWN:
                    event_key = event.key.keysym.sym;
                    foreach(action; onKeyDown) action();
                    key_pressed[event.key.keysym.sym] = true;
                    break;

                case SDL_KEYUP:
                    event_key = event.key.keysym.sym;
                    foreach(action; onKeyUp) action();
                    key_pressed[event.key.keysym.sym] = false;
                    break;

                case SDL_MOUSEMOTION:
                    event_x = event.motion.x;
                    event_y = window_height - event.motion.y;
                    foreach(action; onMouseMotion) action();
                    break;

                case SDL_MOUSEBUTTONDOWN:
                    event_button = event.button.button;
                    if (!doubleClickCounterEnabled) doubleClickCounterEnabled = true;
                    else
                    {
                        doubleClickCounterEnabled = false;
                        doubleClickCounter = 0;
                        foreach(action; onMouseDoubleClick) action();
                    }
                    foreach(action; onMouseButtonDown) action();
                    break;

                case SDL_MOUSEBUTTONUP:
                    event_button = event.button.button;
                    foreach(action; onMouseButtonUp) action();
                    break;
                    
                case SDL_JOYBUTTONDOWN:
                    event_jbutton = event.jbutton.button+1;
                    foreach(action; onJoystickButtonDown) action();
                    break;
                    
                case SDL_JOYBUTTONUP:
                    event_jbutton = event.jbutton.button+1;
                    foreach(action; onJoystickButtonUp) action();
                    break;
                    
                case SDL_JOYAXISMOTION:
                    event_jaxis = event.jaxis.axis;
                    event_jaxisval = event.jaxis.value;
                    foreach(action; onJoystickAxisChange) action();
                    break;

                case SDL_QUIT:
                    foreach(action; onQuit) action();
                    break;

                case SDL_VIDEORESIZE:
                    window_width = event_width = event.resize.w;
                    window_height = event_height = event.resize.h;
                    foreach(action; onResize) action();
                    break;

                case SDL_ACTIVEEVENT:
                    //If the window was iconified or restored
                    if (event.active.state & SDL_APPACTIVE)
                    {
                        //If the application is no longer active
                        //if (event.active.gain == 0)
                        //    GC.collect();
                    }
                    break;

                default:
                    break;
            }
        }
    }

    bool mouseInRegion(int x, int y, int w, int h)
    {
        return (mouse_x - position_x >= x * scale_x && 
                mouse_y - position_y >= y * scale_y && 
                mouse_x - position_x < x * scale_x + w * scale_x && 
		mouse_y - position_y < y * scale_y + h * scale_y);
    }

    bool mouseInRegionGlobal(int x, int y, int w, int h)
    {
        return (mouse_x >= x && 
                mouse_y >= (y) && 
                mouse_x < x + w && 
		mouse_y < (y + h));
    }
}

