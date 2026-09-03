package graphics

import "../world"
import "core:fmt"


sideViewDrawer :: proc(pixels: [dynamic]u32){

    state := &world.state

    for x in 0..<state.width {
        pixelColumnDrawer(x, pixels, 0, state.height)
    }
}

pixelColumnDrawer :: proc(x: i32, pixels: [dynamic]u32, start: i32, end: i32) {

    state := &world.state

    for y in start..<end {

        color: u32 = 0xFF00_00FF
        color += u32(x+1)
        pixels[y * state.width + x] = color
    }
}


topDownDrawer :: proc(pixels: [dynamic]u32, worldGrid: ^world.Grid){

    state := &world.state

    color: u32
    for y in 0..<state.height {
        for x in 0..<state.width {
            if (worldGrid.blocks[int(y) * worldGrid.width + int(x)] == 0 && int(y) < worldGrid.height && int(x) < worldGrid.width) {
                color = 0xFF00_00FF
            }
            else {color = 0x00FF_FF00}
            
            pixels[y * state.width + x] = color
        }
    }
}