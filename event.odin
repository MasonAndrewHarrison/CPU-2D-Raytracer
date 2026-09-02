package main

import "core:fmt"
import SDL "vendor:sdl3"

eventHandling :: proc() {
    event: SDL.Event
    for SDL.PollEvent(&event) {
        #partial switch event.type {
        case .QUIT:
            state.running = false
        case .KEY_DOWN:
            if event.key.key == SDL.K_ESCAPE {
                state.running = false
            }
        }
    }

}