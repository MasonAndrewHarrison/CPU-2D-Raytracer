package main

import "core:fmt"
import "core:os"


frameBufferDrawer :: proc(pixels: [dynamic]u32){

    for x in 0..<state.width {
        pixelColumnDrawer(x, pixels)
    }
}

pixelColumnDrawer :: proc(x: i32, pixels: [dynamic]u32) {

    for y in 0..<state.height {

        color: u32 = 0xFFFF_00FF
        if ( x > state.width/2 ){ color = 0xFF00_FF00}
        pixels[y * state.width + x] = color
    }
    
}