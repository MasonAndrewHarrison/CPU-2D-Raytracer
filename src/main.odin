package main

import "world"

WIDTH :: 1920/1.5
HEIGHT :: 1080/1.5

main :: proc() {

    world.stateInit(WIDTH, HEIGHT)
    this: Program = programInit("Raytracer Engine")
    programMainLoop(&this)
    programClose(&this)

}  