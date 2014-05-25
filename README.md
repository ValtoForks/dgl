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
* Materials and textures
* GLSL and ARB shaders
* Text rendering with TrueType fonts and full Unicode support (UTF-8)
* Internationalization functionality

Dependencies
------------
* Derelict2 (bundled)
* dlib (http://github.com/gecko0307/dlib)

License
-------
Copyright (c) 2013-2014 Timur Gafarov. Distributed under the Boost Software License, Version 1.0. (See accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt)

