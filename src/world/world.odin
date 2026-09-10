package world

import "core:math"
import "core:math/linalg"
import "core:fmt"

World :: struct {
    levelMap: [10]Grid,
    currentLevel: int,
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

getRayHitDDA :: proc(levelMap: ^Grid, xOrigin: f32, yOrigin: f32, direction: f32) -> (voxelHit: [2]f32){

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
        horizonalBuffer[i] = getRayHit(curLevel, curPlayer.x, curPlayer.y, curDirection)
    }

}
