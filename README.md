DGL/GC-free
===========
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language and built on top of OpenGL and SDL. This is an experimental version of the project with manual memory management. When finished, it probably will replace DGL master.

Main changes:
* Everything assumes manual class allocation/deleting
* New event system. Any object can be event listener
* Unicode keyboard input
* User-defined events
* Room system
* Resource manager
* DGL2 scene file format without JSON dependency
* Dynamic shadows
* Shader-based materials with normal mapping
* Billboards and 2D sprites
* Own data markup language - DML

What already ported from ~master:
* Core functionality and interfaces (event system, application, layers, rooms)
* Light manager
* Trackball camera
* Materials and textures
* GLSL and ARB shaders
* Geometric shapes
* Font/Text rendering
* VFS (without ZIP archives support for now)

TODO:
* Configuration files
* Actors, IQM format loading
* I8n
* CD/physics support

Screenshots
-----------
[![Screenshot1](/screenshots/001_thumb.jpg)](/screenshots/001.jpg)

Screenshot is taken from [Atrium](http://github.com/gecko0307/atrium), a physics-based action game built upon DGL.

License
-------
Copyright (c) 2013-2014 Timur Gafarov. Distributed under the Boost Software License, Version 1.0. (See accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt)
