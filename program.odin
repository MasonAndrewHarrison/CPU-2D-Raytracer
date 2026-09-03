package main

import SDL "vendor:sdl3"
import "core:fmt"
import "core:os"


Program :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    texture: ^SDL.Texture,
}


programInit :: proc(title: string) -> (program: Program) {

    os.set_env("SDL_VIDEODRIVER", "wayland,x11")

    if !SDL.Init({.VIDEO}) {
        fmt.eprintln("SDL Launch Failed: ", SDL.GetError())
    }
    
    program.window = SDL.CreateWindow("CPU Raytracer", state.width, state.height, {})
    if program.window == nil {
        fmt.eprintln("CreateWindow failed:", SDL.GetError())
    }

    program.renderer = SDL.CreateRenderer(program.window, nil)
    if program.renderer == nil {
        fmt.eprintln("CreateRenderer failed:", SDL.GetError())
    }

    program.texture = SDL.CreateTexture(program.renderer, .RGBA8888, .STREAMING, state.width, state.height)
    if program.texture == nil {
        fmt.eprintln("CreateTexture failed:", SDL.GetError())
    }

    return program
}

programMainLoop :: proc(program: ^Program) {

    pixels: [dynamic]u32
    resize(&pixels, state.width * state.height)
    defer delete(pixels)

    for state.running {
        eventHandling()

        frameBufferDrawer(pixels)

        SDL.UpdateTexture(program.texture, nil, raw_data(pixels), state.width * size_of(u32))

        SDL.RenderClear(program.renderer)
        SDL.RenderTexture(program.renderer, program.texture, nil, nil)
        SDL.RenderPresent(program.renderer)
    }
}

programClose :: proc(program: ^Program) {
    SDL.Quit()
    SDL.DestroyWindow(program.window)
    SDL.DestroyRenderer(program.renderer)
    SDL.DestroyTexture(program.texture)
}