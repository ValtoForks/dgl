DGL/GC-free
===========
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language and built on top of OpenGL and SDL. This is an experimental version of the project with manual memory management. When finished, it probably will replace DGL master.

Features:
* Fully GC-free
* Supports Windows and Linux
* Event system with user-defined events and Unicode keyboard input
* Resource manager
* Own scene file format (DGL2) with Blender exporter
* Dynamic shadows
* Unlimited number of dynamic light sources
* Shader-based materials with normal mapping and parallax mapping
* Loading textures from PNG
* GLSL and ARB shaders
* Geometric shapes
* Billboards and 2D sprites, including animated ones
* Text rendering with TTF fonts and Unicode support
* VFS

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
