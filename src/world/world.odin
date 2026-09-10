package world

import "core:c"
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
