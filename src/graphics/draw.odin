package graphics

import "../world"
import "core:fmt"
import "core:math"

sideViewDrawer :: proc(pixels: [dynamic]u32){

    state := &world.state

    for x in 0..<state.width {
        pixelColumnDrawer(int(x), pixels, 0, int(state.height))
    }
}

pixelColumnDrawer :: proc(x: int, pixels: [dynamic]u32, start: int, end: int) {

    state := &world.state

    for y in start..<end {

        color: u32 = 0x222222_FF

        pixels[y * int(state.width) + x] = color
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

topDownDrawer :: proc(pixels: [dynamic]u32, worldGrid: ^world.Grid){

    state := &world.state

    imagePixelSize: = f32(state.height)*state.mapImagePercentage
    imageXStart: = (f32(state.width) - imagePixelSize)/2
    imageYStart: = (f32(state.height) - imagePixelSize)/2
    color: u32
    x, y: f32

    for i in imageYStart..<imageYStart+imagePixelSize {
        for j in imageXStart..<imageXStart+imagePixelSize {

            y = ((i - imageYStart) / imagePixelSize)
            x = ((j - imageXStart) / imagePixelSize)
            //color = bilinearInterpolationHitMap(worldGrid, x, y)
            color = bilinearInterpolationDebugMap(worldGrid, x, y)

            pixels[int(i) * int(state.width) + int(j)] = color
        }
    }
}