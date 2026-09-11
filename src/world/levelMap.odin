package world


import "core:path/filepath"
import "core:math/rand"
import "core:math"
import "core:fmt"
import "core:math/linalg"

BLOCK_LENGTH :: 8

Player :: struct {

    x: f32,
    y: f32,
    direction: f32,
}

World :: struct {
    levelMap: [10]Grid,
    currentLevel: int,
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
    levelMap.player.direction = -math.PI/2
    
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

    x := math.clamp(x, 0, levelMap.width*levelMap.blockLength)
    y := math.clamp(y, 0, levelMap.height*levelMap.blockLength)
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

            if ( y % 15 < 5 && x % 15 < 5){
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

worldInit :: proc(resolution: int) -> (worldMap: World){
    for i in 0..<10 {
        worldMap.levelMap[i] = gridInit(resolution, resolution)
        gridLoad(&worldMap.levelMap[i], "..")
    }
    return worldMap
} 

worldFree :: proc(worldMap: ^World) {
    for i in 0..<10 {
        gridFree(&worldMap.levelMap[i])
    }
}

worldUpdate :: proc(worldMap: ^World) {
    updateDebugMap(&worldMap.levelMap[worldMap.currentLevel])
}

getCurrentLevel :: proc(worldMap: ^World) -> (currentLevelMap: ^Grid){
    return &worldMap.levelMap[worldMap.currentLevel]
}


getRayHit :: proc(levelMap: ^Grid, xOrigin: f32, yOrigin: f32, direction: f32) -> (voxelHit: [2]f32){

    voxelHit.x = 100000 * math.cos(direction) + xOrigin
    voxelHit.y = 100000 * math.sin(direction) + yOrigin

    t: f32 = 0
    step: f32 = 0.05
    worldPos: [2]f32 = {xOrigin, yOrigin}

    for i in 0..<10000 {
        worldPos.x += step * math.cos(direction)
        worldPos.y += step * math.sin(direction)
        if(worldPos.x > f32(levelMap.width)-1 || worldPos.y > f32(levelMap.height)-1 || worldPos.x <= 0 || worldPos.y < 0){
            return voxelHit
        }
        if(gridGetHit(levelMap, int(worldPos.x), int(worldPos.y))){ 
            voxelHit.x = worldPos.x
            voxelHit.y = worldPos.y
            return voxelHit
        }   
    }

    return voxelHit
}

getRayHitDDA :: proc(levelMap: ^Grid, xOrigin: f32, yOrigin: f32, direction: f32) -> (voxelHit: [2]f32) {

    rayDirX := math.cos(direction)
    rayDirY := math.sin(direction)

    xUnitDistance := math.sqrt(1 + math.pow(rayDirY / rayDirX, 2))
    yUnitDistance := math.sqrt(1 + math.pow(rayDirX / rayDirY, 2))

    mapCheck: [2]f32 = {math.trunc(xOrigin), math.trunc(yOrigin)}
    rayLength1D: [2]f32 = {0, 0}
    step: [2]f32

    if rayDirX < 0 {
        step.x = -1
        rayLength1D.x = (xOrigin - mapCheck.x) * xUnitDistance
    } else {
        step.x = 1
        rayLength1D.x = (mapCheck.x + 1 - xOrigin) * xUnitDistance
    }

    if rayDirY < 0 {
        step.y = -1
        rayLength1D.y = (yOrigin - mapCheck.y) * yUnitDistance
    } else {
        step.y = 1
        rayLength1D.y = (mapCheck.y + 1 - yOrigin) * yUnitDistance
    }

    maxDistance: f32 = 10000
    distance: f32 = 0
    tileFound := false

    for distance < maxDistance {
        if rayLength1D.x < rayLength1D.y {
            mapCheck.x += step.x
            distance = rayLength1D.x
            rayLength1D.x += xUnitDistance
        } else {
            mapCheck.y += step.y
            distance = rayLength1D.y
            rayLength1D.y += yUnitDistance
        }

        if int(mapCheck.x) >= 0 && int(mapCheck.x) < levelMap.width && int(mapCheck.y) >= 0 && int(mapCheck.y) < levelMap.height {
            if gridGetHit(levelMap, int(mapCheck.x), int(mapCheck.y)) {
                tileFound = true
                break
            }
        } else {
            break
        }
    }

    if tileFound {
        voxelHit.x = xOrigin + rayDirX * distance
        voxelHit.y = yOrigin + rayDirY * distance
    }
    else {
        voxelHit.x = math.INF_F32
        voxelHit.y = math.INF_F32
    }

    return voxelHit
}

horizonalBufferInit :: proc(resolutionWidth: int) -> (horizonalBuffer: [dynamic][2]f32) {
    resize(&horizonalBuffer, resolutionWidth)
    return horizonalBuffer
}

horizonalBufferFree :: proc(horizonalBuffer: [dynamic][2]f32){
    delete(horizonalBuffer)
}

renderHorizonalBuffer :: proc(world: ^World, horizonalBuffer: [dynamic][2]f32, pov: f32) {

    curLevel: ^Grid = getCurrentLevel(world)
    curPlayer: Player = curLevel.player
    curDirection: f32 = curPlayer.direction - (pov/2)
    resolutionWidth := len(horizonalBuffer)

    for i in 0..<resolutionWidth {
        curDirection += (pov/f32(resolutionWidth))
        horizonalBuffer[i] = getRayHitDDA(curLevel, curPlayer.x, curPlayer.y, curDirection)
    }

}
