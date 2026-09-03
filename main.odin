package main

import "core:fmt"
import "core:os"
import SDL "vendor:sdl3"

WIDTH :: 1920/1.5
HEIGHT :: 1080/1.5

main :: proc() {

    stateInit()
    this: Program = programInit("Raytracer Engine")
    programMainLoop(&this)
    programClose(&this)


}  