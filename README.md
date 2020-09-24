# GLFW in Assembly language
This project was started Friday 9/18/20 and through a lot of segfaults and other issues, it is brought to (sort of) life on 9/20/20.

This project is based on the tutorials in [opengl-tutorials/ogl](https://github.com/opengl-tutorials/ogl)

Check the releases page for snapshots of the code that correspond to the tutorials

This project is written specifically for linux, it should be compatible with all GLFW backends (X11/wayland)

## Dependencies
- linux (tested with kernel 5.8.9 on arch)
- cglm 0.7.8<sup>1</sup>
- openGL 4.5
- GLFW3 3.3.2

<sup>1</sup> cglm is on the AUR not the regular repos.

## Why?
Why not? This was just a "it can be done in ASM so why not try it?" project.

## Fun facts
There are exactly 1155 lines of code for the (current) working implementation.

This was hand written assembly code. All except the parts I wrote then duplicated and edited.

No external assembly code was used, the allocation function is my own design and it (mostly) works.

The shader loading is an almost exact c++ to ASM translation from the tutorial, same with the main.asm file
