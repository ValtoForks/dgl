DGL
===
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language. It is a (very) thin wrapper on top of OpenGL and SDL.

Features
--------
* Very modest system requirements - requires OpenGL 1.2 of higher. Should work on virtually any PC
* Supports Windows and all POSIX-compliant operating systems 
* Object-oriented design
* Event system
* Layer-based rendering system. You can break up scenes to any number of 2D and 3D layers, each with it's own logics and drawable objects
* Built-in 3D layer with trackball-style camera
* Built-in geometric shapes (sphere, box, cylinder, cone, ellipsoid)
* Skeletal animation (IQM model format support)
* Materials and textures
* Virtual light system with any number of dynamic light sources
* GLSL and ARB shaders
* Multitexturing
* Text rendering with TrueType fonts and full Unicode support (UTF-8)
* Full-featured virtual filesystem with ZIP archive support
* Own scene file format (Blender exporter supplied)
* Internationalization functionality

Dependencies
------------
* OpenGL / Mesa 1.2 or higher (2.0 recommended)
* SDL and FreeType (binaries for Windows and Linux are provided)
* Derelict2 (bundled)
* [dlib](http://github.com/gecko0307/dlib)

Also check out [dmech](http://github.com/gecko0307/dmech) - the only native 3D physics engine written in D, which nicely complements DGL applications.

What is missing yet
-------------------
* Terrain rendering
* Shader-based material system
* Screen-space shaders and effects (via FBO)
* Built-in CD/physics support (deeper dmech integration or, better, some form of generic physics interface)
* Frustum culling, BSP, BVH or some other method of drawing optimization
* Configuration system
* Probably some kind of game UI

License
-------
Copyright (c) 2013-2014 Timur Gafarov. Distributed under the Boost Software License, Version 1.0. (See accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt)

