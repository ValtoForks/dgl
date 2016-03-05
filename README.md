DGL/GC-free
===========
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language and built on top of OpenGL and SDL. This is an experimental version of the project with manual memory management. When finished, it probably will replace DGL master.

Features:
* Fully GC-free
* Supports Windows, Linux and Mac OS X
* Event system with user-defined events and Unicode keyboard input
* Resource manager (resources are loaded in a separate thread)
* Own scene file format (DGL2) with Blender exporter
* Loading textures from PNG
* Dynamic shadows
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

Screenshots
-----------
[![Screenshot1](/screenshots/003_thumb.jpg)](/screenshots/003.jpg)
[![Screenshot2](/screenshots/004_thumb.jpg)](/screenshots/004.jpg)

Give it a shot!
---------------
To see what DGL is capable to, check out [Atrium](https://github.com/gecko0307/atrium), a work-in-progress sci-fi first person puzzle based on physics simulation.

Documentation
-------------
See [tutorials](/tutorials).

License
-------
Copyright (c) 2013-2016 Timur Gafarov. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at http://www.boost.org/LICENSE_1_0.txt).
