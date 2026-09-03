package world

State :: struct {
    running: bool,
    width: i32,
    height: i32,
    topDown: bool,
    mouseX: f32,
    mouseY: f32,
}
state: State


stateInit :: proc(width: i32 = 600, height: i32 = 400) {

    state = {
        running  = true,
        width    = width,
        height   = height,
        topDown  = false,
        mouseX   = 0,
        mouseY   = 0,
    }

}
