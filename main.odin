package main

import "core:fmt"
import "core:os"
import SDL "vendor:sdl3"

WIDTH :: 1920/1.5
HEIGHT :: 1080/1.5

main :: proc() {

    os.set_env("SDL_VIDEODRIVER", "wayland,x11")

    if !SDL.Init({.VIDEO}) {
        fmt.eprintln("SDL Launch Failed: ", SDL.GetError())
    }
    defer SDL.Quit()
    stateInit(WIDTH, HEIGHT)
    defer stateFree()

    pixels: [dynamic]u32
    resize(&pixels, state.width * state.height)
    defer delete(pixels)

    for state.running {
        eventHandling()

        frameBufferDrawer(pixels)

        SDL.UpdateTexture(state.texture, nil, raw_data(pixels), state.width * size_of(u32))

        SDL.RenderClear(state.renderer)
        SDL.RenderTexture(state.renderer, state.texture, nil, nil)
        SDL.RenderPresent(state.renderer)
    }


}  