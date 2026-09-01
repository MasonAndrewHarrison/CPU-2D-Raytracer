package main

import "core:fmt"
import SDL "vendor:sdl3"

WIDTH :: 640
HEIGHT :: 480

main :: proc() {

    if !SDL.Init({.VIDEO}) {
        fmt.eprintln("SDL Launch Failed: ", SDL.GetError())
    }
    defer SDL.Quit()


    window := SDL.CreateWindow("CPU Raytracer", WIDTH, HEIGHT, {})
    defer SDL.DestroyWindow(window)

    renderer := SDL.CreateRenderer(window, nil)
    defer SDL.DestroyRenderer(renderer)

    texture := SDL.CreateTexture(
        renderer,
        .RGBA8888,
        .STREAMING,
        WIDTH, HEIGHT,
    )
    defer SDL.DestroyTexture(texture)


    pixels: [dynamic]u32
    resize(&pixels, WIDTH * HEIGHT)
    defer delete(pixels)

    running := true
    for running {
        event: SDL.Event
        for SDL.PollEvent(&event) {
            #partial switch event.type {
            case .QUIT:
                running = false
            case .KEY_DOWN:
                if event.key.key == SDL.K_ESCAPE {
                    running = false
                }
            }
        }

        for y in 0..<HEIGHT {
            for x in 0..<WIDTH {
                pixels[y * WIDTH + x] = 0xFF00_00FF
            }
        }


        SDL.UpdateTexture(texture, nil, raw_data(pixels), WIDTH * size_of(u32))

        SDL.RenderClear(renderer)
        SDL.RenderTexture(renderer, texture, nil, nil)
        SDL.RenderPresent(renderer)
    }

}  