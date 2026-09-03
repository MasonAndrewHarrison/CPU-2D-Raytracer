package main

import "core:fmt" 
import "world"
import SDL "vendor:sdl3"

eventHandling :: proc(event: ^SDL.Event, window: ^SDL.Window, deltaTime: f64) {

    state := &world.state

    for SDL.PollEvent(event) {
        #partial switch event.type {
        case .QUIT:
            state.running = false
        case .KEY_DOWN:
            eventButtonPress(event)
        case .MOUSE_MOTION:
            eventMouseMotion(event)
        case .MOUSE_WHEEL:
            eventMouseWheel(event)
        case .WINDOW_RESIZED:
            SDL.GetWindowSizeInPixels(window, &state.width, &state.height)
        }     
    }
    eventButtomHold(0)

}

eventButtonPress :: proc(event: ^SDL.Event){

    state := &world.state

    switch (event.key.key){

        case SDL.K_ESCAPE:
            state.running = false

        case SDL.K_TAB:
            state.topDown = !state.topDown

    }
}

eventMouseMotion :: proc(event: ^SDL.Event){

    state := &world.state

    mouseButtonFlags:= SDL.GetMouseState(&state.mouseX, &state.mouseY)
}

eventMouseWheel :: proc(event: ^SDL.Event){
}

eventButtomHold :: proc(deltaTime: f64){

}