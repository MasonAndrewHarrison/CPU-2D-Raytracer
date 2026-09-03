package main

import "core:fmt"


sideViewDrawer :: proc(pixels: [dynamic]u32){

    for x in 0..<state.width {
        pixelColumnDrawer(x, pixels, 0, state.height)
    }
}

pixelColumnDrawer :: proc(x: i32, pixels: [dynamic]u32, start: i32, end: i32) {

    for y in start..<end {

        color: u32 = 0xFF00_00FF
        color += u32(x)
        pixels[y * state.width + x] = color
    }
}


topDownDrawer :: proc(pixels: [dynamic]u32){

    for y in 0..<state.height {
        for x in 0..<state.width {

            pixels[y * state.width + x] = 0xFF00_00FF
        }
    }
}