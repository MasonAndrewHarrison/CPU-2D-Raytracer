package world

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