package main

import SDL "vendor:sdl3"
import "core:fmt"
import "core:os"
import "graphics"
import "world"

Program :: struct {
    window: ^SDL.Window,
    renderer: ^SDL.Renderer,
    texture: ^SDL.Texture,
    event: SDL.Event,
    horizonalBuffer: [dynamic][2]f32,
    pixels: [dynamic]u32,
    worldMap: world.World,
}

@(require_results)
programInit :: proc(title: string) -> (program: Program) {

    state := &world.state

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

    result := SDL.SetWindowRelativeMouseMode(program.window, true)

    resize(&program.pixels, state.width * state.height)
    program.worldMap = world.worldInit(32)
    program.horizonalBuffer = world.horizonalBufferInit(int(state.width))

    return program
}

programMainLoop :: proc(program: ^Program) {

    state := &world.state

    deltaTime: f32
    lastTime: u64 = SDL.GetTicks()
    lastTimeFPS: u64 = SDL.GetTicks()
    curTime: u64 
    elapsedTimeFPS: u64
    frameCount: int = 0

    for state.running {   

        curTime = SDL.GetTicks()
        deltaTime = f32(curTime - lastTime)/1000
        lastTime = curTime

        frameCount += 1
        elapsedTimeFPS = curTime - lastTimeFPS
        if elapsedTimeFPS >= 1000 {
            fmt.println(f32(frameCount * 1000) / f32(elapsedTimeFPS))
            frameCount = 0
            lastTimeFPS = curTime
        }

        eventHandling(program, world.getCurrentLevel(&program.worldMap), deltaTime)
        world.worldUpdate(&program.worldMap)

        if state.topDown == true { graphics.topDownDrawer(program.pixels, world.getCurrentLevel(&program.worldMap)) }
        else { graphics.sideViewDrawer(program.pixels, program.horizonalBuffer, &program.worldMap) }

        SDL.UpdateTexture(program.texture, nil, raw_data(program.pixels), state.width * size_of(u32))

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
    delete(program.pixels)
    world.worldFree(&program.worldMap)
    world.horizonalBufferFree(program.horizonalBuffer)
}