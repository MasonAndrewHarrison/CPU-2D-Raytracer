package world

Grid :: struct {
    blocks: [dynamic]u64,
    width: int,
    height: int,
}


gridInit :: proc(width: int, height: int) -> (gridLevel: Grid) {

    gridLevel = {
        height = 128,   
        width = 128,
    }
    resize(&gridLevel.blocks, gridLevel.height * gridLevel.width)
    gridLevel.blocks[1] = 1

    return gridLevel
}

gridFree :: proc(gridLevel: ^Grid) {

    delete(gridLevel.blocks)
}