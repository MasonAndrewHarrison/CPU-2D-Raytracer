package main 

import "core:fmt" 
import "world"
import "entity"
import "core:math"
import SDL "vendor:sdl3"

eventHandling :: proc(program: ^Program, levelMap: ^world.Grid, deltaTime: f64) {

    state := &world.state
    keyBoard: = SDL.GetKeyboardState(nil)
    for SDL.PollEvent(&program.event) {
        #partial switch program.event.type {
        case .QUIT:
            state.running = false
        case .KEY_DOWN:
            eventButtonPress(&program.event)
        case .MOUSE_MOTION:
            eventMouseMotion(&program.event, levelMap)
        case .MOUSE_WHEEL:
            eventMouseWheel(&program.event)
        case .WINDOW_RESIZED:
            SDL.GetWindowSizeInPixels(program.window, &state.width, &state.height)
        }     
    }
    eventButtomHold(keyBoard, levelMap, 0)
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

eventMouseMotion :: proc(event: ^SDL.Event, levelMap: ^world.Grid){

    state := &world.state
    mouseButtonFlags:= SDL.GetMouseState(&state.mouseX, &state.mouseY)

    imagePixelSize: = f32(state.height)*state.mapImagePercentage
    imageXStart: = (f32(state.width) - imagePixelSize)/2
    imageYStart: = (f32(state.height) - imagePixelSize)/2

    y: f32 = ((state.mouseY - imageYStart) / imagePixelSize) * f32(levelMap.height-1)
    x: f32 = ((state.mouseX - imageXStart) / imagePixelSize) * f32(levelMap.width-1)
    
    if .LEFT in mouseButtonFlags{

        if state.topDown && x > 0 && y > 0 && x < f32(levelMap.width) && y < f32(levelMap.height){
            world.gridAddSphere(levelMap, x, y, 1)
        } 
    }
}

eventMouseWheel :: proc(event: ^SDL.Event){
}

eventButtomHold :: proc(keyBoard: [^]bool, levelMap: ^world.Grid, deltaTime: f64){

    if keyBoard[SDL.Scancode.W] {
        playerMove(levelMap.player, levelMap, 1, -math.PI/2)
    }
    if keyBoard[SDL.Scancode.S] {
        playerMove(levelMap.player, levelMap, 1, math.PI/2)  
    }
    if keyBoard[SDL.Scancode.A] {
        playerMove(levelMap.player, levelMap, 1, math.PI)  
    }
    if keyBoard[SDL.Scancode.D] {
        playerMove(levelMap.player, levelMap, 1, 0)  
    }
}