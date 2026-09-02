package main

import SDL "vendor:sdl3"
import "core:fmt"

State :: struct {
    running: bool,
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    texture: ^SDL.Texture,
    pixels: [dynamic]u32,
    width: i32,
    height: i32,
}

state: State


stateInit :: proc(width: i32 = 600, height: i32 = 400) {

    width: i32 = WIDTH
    height: i32 = HEIGHT

    window := SDL.CreateWindow("CPU Raytracer", width, height, {})
    if window == nil {
        fmt.eprintln("CreateWindow failed:", SDL.GetError())
    }

    renderer := SDL.CreateRenderer(window, nil)
    if renderer == nil {
        fmt.eprintln("CreateRenderer failed:", SDL.GetError())
    }

    texture := SDL.CreateTexture(renderer, .RGBA8888, .STREAMING, width, height)
    if texture == nil {
        fmt.eprintln("CreateTexture failed:", SDL.GetError())
    }

    state = {
        running  = true,
        window   = window,
        renderer = renderer,
        texture  = texture,
        width    = width,
        height   = height,
    }

    resize(&state.pixels, width * height)
}

stateFree :: proc() {
    SDL.DestroyWindow(state.window)
    SDL.DestroyRenderer(state.renderer)
    SDL.DestroyTexture(state.texture)
    delete(state.pixels)
}