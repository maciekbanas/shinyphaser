library(shiny)
library(shinyphaser)

game <- PhaserGame$new(width = 512, height = 384)
ui <- tagList(tags$p("Arrow keys: move the orange square. Walls block movement."),
              game$use_phaser())

server <- function(input, output, session) {
  game <- PhaserGame$new(width = 512, height = 384)
  game$set_shiny_session(session)
  game$set_world_bounds(512, 384)
  game$add_map(
    map_key = "room", map_url = "room.json",
    tileset_urls = c("floor.png", "wall.png"),
    tileset_names = c("floor", "wall"), layer_name = "terrain"
  )
  player <- game$add_sprite(
    "player", "player.png", x = 96, y = 96,
    frame_width = 32, frame_height = 32, frame_count = 1, frame_rate = 1
  )
  player$add_player_controls(speed = 140)
  game$enable_terrain_collision("player")
}

shinyApp(ui, server)
