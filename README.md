DGL/GC-free
===========
DGL is a minimalistic 3D and 2D real-time graphics engine written in D language. It is a (very) thin wrapper on top of OpenGL and SDL. This is an experimental version of the project with manual memory management. When finished, it probably will replace DGL master.

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
* Configuration files support
* Own data markup language - DML

What already done:
* Core functionality and interfaces (event system, application, layers, rooms)
* Light manager
* Trackball camera
* Materials and textures
* GLSL and ARB shaders
* Some geometric shapes
* Font/Text rendering
* VFS (without ZIP archives support for now)

TODO:
* Actors, IQM format loading
* I8n
* CD/physics support
