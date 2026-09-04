package main
import "core:math"
import "world"
import "entity"


playerMove :: proc(player: ^entity.Player, levelMap: ^world.Grid, distance: f32, angle: f32){
    tempX: f32 = player.x + distance*math.cos(angle + player.direction)
    tempY: f32 = player.y + distance*math.sin(angle + player.direction)

    if (!world.gridGetHit(levelMap, int(tempX), int(tempY))){
        player.x = tempX
        player.y = tempY
    }
}