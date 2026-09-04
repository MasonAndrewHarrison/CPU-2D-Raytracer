package world


import "core:path/filepath"
import "core:math/rand"
import "core:fmt"
import "../entity"

BLOCK_LENGTH :: 8

Grid :: struct {
    blocks: [dynamic]u64,
    debugValue: [dynamic]u8,
    width: int,
    height: int,
    blockLength: int, 
    player: ^entity.Player,
}


gridInit :: proc(width: int, height: int) -> (levelMap: Grid) {

    levelMap = {
        height = height * BLOCK_LENGTH,   
        width = width * BLOCK_LENGTH,
        blockLength = BLOCK_LENGTH,
    }
    resize(&levelMap.blocks, height * width)
    resize(&levelMap.debugValue, height*BLOCK_LENGTH * width*BLOCK_LENGTH)
    
    return levelMap
}

gridFree :: proc(levelMap: ^Grid) {

    delete(levelMap.blocks)
    delete(levelMap.blocks)
}

gridGetBlockHitIndex :: proc(levelMap: ^Grid, x: int, y: int) -> (index: int){
    return x * levelMap.width/BLOCK_LENGTH + y
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

gridGetHit :: proc(levelMap: ^Grid, x: int, y: int) -> (hit: bool) {

    gridX: = int(x/BLOCK_LENGTH)
    gridY: = int(y/BLOCK_LENGTH)

    blockX: = int(x % BLOCK_LENGTH)
    blockY: = int(y % BLOCK_LENGTH)
    bit: = u8(blockX * BLOCK_LENGTH + blockY)

    return levelMap.blocks[gridGetBlockHitIndex(levelMap, gridX, gridY)] & (1 << bit) > 0
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


addPlayer :: proc(levelMap: ^Grid, player: ^entity.Player, centerPlayer: bool){
    if centerPlayer {
        player.x = f32(levelMap.width) /2
        player.y = f32(levelMap.height) /2
    }
    levelMap.player = player
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