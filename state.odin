package main

import SDL "vendor:sdl3"
import "core:fmt"

State :: struct {
    running: bool,
    width: i32,
    height: i32,
}

state: State


stateInit :: proc(width: i32 = 600, height: i32 = 400) {

    width: i32 = WIDTH
    height: i32 = HEIGHT

    state = {
        running  = true,
        width    = width,
        height   = height,
    }

}
