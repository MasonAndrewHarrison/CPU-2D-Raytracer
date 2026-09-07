package graphics

import "vendor:vulkan"
import "../world"
import "core:fmt"
import "core:math"
import "core:math/linalg"

sideViewDrawer :: proc(pixels: [dynamic]u32, worldMap: ^world.World){

    state := &world.state
    horizonalBuffer := world.renderHorizonalBuffer(worldMap, int(state.width), math.PI/4)
    playerPos: [2]f32 = {world.getCurrentLevel(worldMap).player.x, world.getCurrentLevel(worldMap).player.y}

    clearAllPixel(pixels)

    for x in 0..<state.width {
        distance := linalg.distance(horizonalBuffer[x], playerPos)
        wallHeight := math.clamp(int(800/distance), 0, int(state.height/2))

        pixelColumnDrawer(int(x), pixels, int(state.height/2)-wallHeight, int(state.height/2)+wallHeight)
    }
}

pixelColumnDrawer :: proc(x: int, pixels: [dynamic]u32, start: int, end: int) {

    state := &world.state

    for y in start..<end {

        color: u32 = 0xFF0000_FF

        pixels[y * int(state.width) + x] = color
    }
}

clearAllPixel :: proc(pixels: [dynamic]u32) {

    state := &world.state

    for x in 0..<state.width {
        for y in 0..<state.height {
            pixels[int(y) * int(state.width) + int(x)] = 0x222222_FF
        }
    }
}

bilinearInterpolationHitMap :: proc(levelMap: ^world.Grid, x:f32, y:f32) -> (color: u32){

    tx, ty: f32
    maxX, maxY, minX, minY: int
    topLeft, topRight, botLeft, botRight: f32
    botAvg, topAvg, valAvg: f32

    fy:f32 = y * f32(levelMap.height-1)
    fx:f32 = x * f32(levelMap.width-1)

    minY = auto_cast math.floor(fy)
    minX = auto_cast math.floor(fx)
    maxY = minY + 1
    maxX = minX + 1

    topLeft = auto_cast int(world.gridGetHit(levelMap, minX, minY))
    topRight = auto_cast int(world.gridGetHit(levelMap, maxX, minY))
    botRight = auto_cast int(world.gridGetHit(levelMap, maxX, maxY))
    botLeft = auto_cast int(world.gridGetHit(levelMap, minX, maxY))

    ty = fy - f32(minY)
    tx = fx - f32(minX)

    botAvg = botLeft*(1-tx) + botRight*tx
    topAvg = topLeft*(1-tx) + topRight*tx
    valAvg = botAvg*(ty) + topAvg*(1-ty)

    intensity := u8(valAvg * 255)
    return u32(intensity) | u32(intensity)<<8 | u32(intensity)<<16 | 0xFF<<24
}

bilinearInterpolationDebugMap :: proc(levelMap: ^world.Grid, x:f32, y:f32) -> (color: u32){

    tx, ty: f32
    maxX, maxY, minX, minY: int
    topLeft, topRight, botLeft, botRight: f32
    botAvg, topAvg, valAvg: f32

    fy:f32 = y * f32(levelMap.height-1)
    fx:f32 = x * f32(levelMap.width-1)

    minY = auto_cast math.floor(fy)
    minX = auto_cast math.floor(fx)

    debugValue: u8 = world.gridGetDebugValue(levelMap, minX, minY)

    if ( debugValue == 2 ) {
        color = 0xFF00FF_FF
    }
    else if ( debugValue == 1 ) {
        color = 0x00FFFF_FF
    }
    else if ( debugValue == 3 ) {
        color = 0x00FF00_FF
    }

    return color
}

drawLineOver :: proc(color: ^u32, x:f32, y:f32, xStart: f32, yStart: f32, xEnd: f32, yEnd: f32){


    line := [2]f32{xEnd - xStart, yEnd - yStart}
    pixelToOrigin := [2]f32{x - xStart, y - yStart}

    t := linalg.dot(line, pixelToOrigin) / linalg.dot(line, line)
    t = math.clamp(t, 0, 1)
    tRay := t * line
    sdf := linalg.distance(tRay, pixelToOrigin)

    if sdf < 0.2 {
        color^ = 0xFFBB00_FF
    }
}

topDownDrawer :: proc(pixels: [dynamic]u32, levelMap: ^world.Grid){

    state := &world.state

    imagePixelSize: = f32(state.height)*state.mapImagePercentage
    imageXStart: = (f32(state.width) - imagePixelSize)/2
    imageYStart: = (f32(state.height) - imagePixelSize)/2
    color: u32
    x, y: f32

    playerX, playerY, playerDir: f32
    playerX = levelMap.player.x
    playerY = levelMap.player.y
    playerDir = levelMap.player.direction
    voxelHit: [2]f32 = world.getRayHitDDA(levelMap, playerX, playerY, playerDir)

    for i in imageYStart..<imageYStart+imagePixelSize {
        for j in imageXStart..<imageXStart+imagePixelSize {

            y = ((i - imageYStart) / imagePixelSize)
            x = ((j - imageXStart) / imagePixelSize)
            color = bilinearInterpolationHitMap(levelMap, x, y)
            color = bilinearInterpolationDebugMap(levelMap, x, y)
            drawLineOver(&color, x * f32(levelMap.height-1), y * f32(levelMap.width-1), playerX+.5, playerY+.5    , voxelHit.x, voxelHit.y)

            pixels[int(i) * int(state.width) + int(j)] = color
        }
    }
}