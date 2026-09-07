package world


import "core:path/filepath"
import "core:math/rand"
import "core:math"
import "core:fmt"

BLOCK_LENGTH :: 8

Player :: struct {

    x: f32,
    y: f32,
    direction: f32,
}

Grid :: struct {
    blocks: [dynamic]u64,
    debugValue: [dynamic]u8,
    width: int,
    height: int,
    blockLength: int, 
    player: Player,
}


gridInit :: proc(width: int, height: int) -> (levelMap: Grid) {

    levelMap = {
        height = height * BLOCK_LENGTH,   
        width = width * BLOCK_LENGTH,
        blockLength = BLOCK_LENGTH,
    }
    resize(&levelMap.blocks, height * width)
    resize(&levelMap.debugValue, height*BLOCK_LENGTH * width*BLOCK_LENGTH)

    levelMap.player.x = f32(width * BLOCK_LENGTH) /2  
    levelMap.player.y = f32(height * BLOCK_LENGTH) /2
    levelMap.player.direction = 0
    
    return levelMap
}

gridFree :: proc(levelMap: ^Grid) {

    delete(levelMap.blocks)
    delete(levelMap.debugValue)
}

gridGetBlockHitIndex :: proc(levelMap: ^Grid, x: int, y: int) -> (index: int){
    return x * levelMap.width/BLOCK_LENGTH + y
}

gridGetHit :: proc(levelMap: ^Grid, x: int, y: int) -> (hit: bool) {

    gridX: = int(x/BLOCK_LENGTH)
    gridY: = int(y/BLOCK_LENGTH)

    blockX: = int(x % BLOCK_LENGTH)
    blockY: = int(y % BLOCK_LENGTH)
    bit: = u8(blockX * BLOCK_LENGTH + blockY)

    return levelMap.blocks[gridGetBlockHitIndex(levelMap, gridX, gridY)] & (1 << bit) > 0
}

gridGetBlockIndex :: proc(levelMap: ^Grid, x: int, y: int) -> (index: int){
    return x * levelMap.width + y
}

gridGetDebugValue :: proc(levelMap: ^Grid, x: int, y: int) -> (value: u8){
    return levelMap.debugValue[gridGetBlockIndex(levelMap, x, y)]
}

gridSetDebugValue :: proc(levelMap: ^Grid, x: int, y: int, debugValue: u8){
    levelMap.debugValue[gridGetBlockIndex(levelMap, x, y)] = debugValue
}

gridSetHit :: proc(levelMap: ^Grid, x: int, y: int) {

    gridX: = int(x/BLOCK_LENGTH)
    gridY: = int(y/BLOCK_LENGTH)

    blockX: = int(x % BLOCK_LENGTH)
    blockY: = int(y % BLOCK_LENGTH)
    bit: = u8(blockX * BLOCK_LENGTH + blockY)

    levelMap.blocks[gridGetBlockHitIndex(levelMap, gridX, gridY)] |= (1 << bit)
}

gridLoad :: proc(levelMap: ^Grid, filepath: string) {

    for x in 0..<levelMap.width {
        for y in 0..<levelMap.width {

            if ( y % 10 < 5 && x % 10 < 5){
                gridSetDebugValue(levelMap, x, y, 2)
                gridSetHit(levelMap, x, y) 
            }
        }
    }
}

gridAddSphere :: proc(levelMap: ^Grid, x: f32, y: f32, radius: f32){

    for i in (x-radius)..<(x+radius) {

        for j in (y-radius)..<(y+radius){

            gridSetDebugValue(levelMap, int(i), int(j), 1)
            gridSetHit(levelMap, int(i), int(j))
        }
    }

}

clearDebugValue :: proc(levelMap: ^Grid, debugValue: u8){

    for x in 0..<levelMap.width {
        for y in 0..<levelMap.width {

            if ( gridGetDebugValue(levelMap, x, y) == debugValue){
                gridSetDebugValue(levelMap, x, y, 0)
            }
        }
    }
}


updateDebugMap :: proc(levelMap: ^Grid){

    clearDebugValue(levelMap, 3)
    gridSetDebugValue(levelMap, int(levelMap.player.x), int(levelMap.player.y), 3)
}

playerMove :: proc(player: ^Player, levelMap: ^Grid, distance: f32, angle: f32){
    tempX: f32 = player.x + distance*math.cos(angle + player.direction)
    tempY: f32 = player.y + distance*math.sin(angle + player.direction)

    xInBounds: bool = tempX >= 0 && tempX < f32(levelMap.width) -1
    yInBounds: bool = tempY >= 0 && tempY < f32(levelMap.height) -1

    if (!gridGetHit(levelMap, int(tempX), int(tempY)) && yInBounds && xInBounds){
        player.x = tempX
        player.y = tempY
    }
}