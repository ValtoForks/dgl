DGL/GC-free
===========
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language and built on top of OpenGL and SDL. This is an experimental version of the project with manual memory management. When finished, it probably will replace DGL master.

Features:
* Fully GC-free
* Supports Windows, Linux and Mac OS X
* Event system with user-defined events and Unicode keyboard input
* Resource manager (resources are loading in a separate thread)
* Own scene file format (DGL2) with Blender exporter
* Loading textures from PNG
* Dynamic shadows
* Unlimited number of dynamic light sources
* GLSL shaders
* Shader-based materials with normal mapping and parallax mapping
* Antialiasing
* Geometric shapes
* Text rendering with TTF fonts and Unicode support
* VFS
* Configuration system

TODO:
* Billboards and 2D sprites
* Actors, IQM format loading
* Particle system
* I8n

Screenshots
-----------
[![Screenshot1](/screenshots/003_thumb.jpg)](/screenshots/003.jpg)

License
-------
Copyright (c) 2013-2015 Timur Gafarov. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).
