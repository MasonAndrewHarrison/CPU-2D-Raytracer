package world

import "core:path/filepath"
import "core:math/rand"
import "core:fmt"

BLOCK_WIDTH :: 8

Grid :: struct {
    blocks: [dynamic]u64,
    width: int,
    height: int,
}


gridInit :: proc(width: int, height: int) -> (levelMap: Grid) {

    levelMap = {
        height = height * BLOCK_WIDTH,   
        width = width * BLOCK_WIDTH,
    }
    resize(&levelMap.blocks, height * width)
    
    return levelMap
}

gridFree :: proc(levelMap: ^Grid) {

    delete(levelMap.blocks)
}

gridGetBlockIndex :: proc(levelMap: ^Grid, x: int, y: int) -> (index: int){

    return x * levelMap.width/BLOCK_WIDTH + y
}

gridGetHit :: proc(levelMap: ^Grid, x: int, y: int) -> (hit: bool) {

    gridX: = int(x/BLOCK_WIDTH)
    gridY: = int(y/BLOCK_WIDTH)

    blockX: = int(x % BLOCK_WIDTH)
    blockY: = int(y % BLOCK_WIDTH)
    bit: = u8(blockX * BLOCK_WIDTH + blockY)

    return levelMap.blocks[gridGetBlockIndex(levelMap, gridX, gridY)] & (1 << bit) > 0
}

gridSetHit :: proc(levelMap: ^Grid, x: int, y: int) {

    gridX: = int(x/BLOCK_WIDTH)
    gridY: = int(y/BLOCK_WIDTH)

    blockX: = int(x % BLOCK_WIDTH)
    blockY: = int(y % BLOCK_WIDTH)
    bit: = u8(blockX * BLOCK_WIDTH + blockY)

    levelMap.blocks[gridGetBlockIndex(levelMap, gridX, gridY)] |= (1 << bit)
}

gridLoad :: proc(levelMap: ^Grid, filepath: string) {

    for x in 0..<levelMap.width {
        for y in 0..<levelMap.width {

            if ( y % 10 < 5 && x % 10 < 5){
                gridSetHit(levelMap, x, y) 
            }
        }
    }
}