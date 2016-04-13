DGL/GC-free
===========
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language and built on top of OpenGL and SDL. This is an experimental version of the project with manual memory management. When finished, it probably will replace DGL master.

Screenshots
-----------
[![Screenshot1](/screenshots/005_thumb.jpg)](/screenshots/005.jpg)
[![Screenshot2](/screenshots/004_thumb.jpg)](/screenshots/004.jpg)

To see what DGL is capable to, check out [Atrium](https://github.com/gecko0307/atrium), a work-in-progress sci-fi first person puzzle based on physics simulation.

Features
--------
* Fully GC-free
* Supports Windows, Linux and Mac OS X
* Event system with user-defined events and Unicode keyboard input
* Resource manager (resources are loaded in a separate thread)
* Own scene file format (DGL2) with Blender exporter
* Loading textures from PNG
* Dynamic soft shadows
* Unlimited number of dynamic light sources
* GLSL shaders
* Built-in uber shader with normal mapping and parallax mapping
* Unlimited number of render passes, 2D or 3D
* Render to texture
* Antialiasing
* Built-in trackball camera
* 3D geometric shapes
* 2D sprites, including animated ones
* 2D text rendering with TTF fonts and Unicode support
* VFS
* Configuration system

TODO:
* Billboards
* Actors, IQM format loading
* Particle system
* I8n
* Terrain rendering
* Water rendering

Demos
-----
DGL comes with a number of usage examples. To build one, run `dub build --config=demoname`, where `demoname` can be `minimal`, `simple3d`, `loading`, `materials`, `shadow`, `extending`, `textio`.
* minimal.d - 'Hello, World' application, demonstrates how to create a window and print text with TrueType font
* simple3d.d - basic 3D graphics examplem, rendering a cube
* loading.d - loading an asset from DGL2 file
* materials.d - same as loading.d, but renders more interesting scene with different materials
* shadow.d - dynamic soft shadows demo
* extending.d - shows how to add new object types to DGL
* textio.d - text input demo (with support for international keyboard layouts)

Documentation
-------------
* [Introduction to DGL](/tutorials/001-intro.md)
* [Basic 3D Graphics](/tutorials/002-3d-graphics.md)
* [Model Loading](/tutorials/003-model-loading.md)
* [Extending DGL](/tutorials/004-extending-dgl.md)
* [Event System](/tutorials/005-event-system.md)

License
-------
Copyright (c) 2013-2016 Timur Gafarov. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).
