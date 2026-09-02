package main

import "core:fmt"
import "core:os"
import SDL "vendor:sdl3"

WIDTH :: 1920/2
HEIGHT :: 1080/2

main :: proc() {

    os.set_env("SDL_VIDEODRIVER", "wayland,x11")

    if !SDL.Init({.VIDEO}) {
        fmt.eprintln("SDL Launch Failed: ", SDL.GetError())
    }
    defer SDL.Quit()
    stateInit(WIDTH, HEIGHT)
    defer stateFree()

    for state.running {
        eventHandling()

        for y in 0..<state.height {
            for x in 0..<state.width {
                state.pixels[y * state.width + x] = 0xFF00_00FF
            }
        }

        SDL.UpdateTexture(state.texture, nil, raw_data(state.pixels), state.width * size_of(u32))

        SDL.RenderClear(state.renderer)
        SDL.RenderTexture(state.renderer, state.texture, nil, nil)
        SDL.RenderPresent(state.renderer)
    }

}  