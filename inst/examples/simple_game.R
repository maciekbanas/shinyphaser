devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 600)

ui <- game$ui()

server <- function(input, output, session) {
  score <- 0

  game$set_shiny_session()

  grass <- game$add_static_group(
    name = "grass",
    url = "assets/bear_game/terrain/grass.png"
  )

  for (x in seq(100, 900, by = 200)) {
    for (y in seq(80, 560, by = 160)) {
      grass$create(x = x, y = y)
    }
  }

  player <- game$add_sprite(
    name = "player",
    url = "assets/rpg_game/sprites/hero_idle.png",
    x = 120,
    y = 300,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 1,
    frameRate = 1
  )

  apples <- game$add_static_group(
    name = "apples",
    url = "assets/bear_game/perks/apple.png"
  )

  apples$create(x = 250, y = 120)
  apples$create(x = 820, y = 180)
  apples$create(x = 700, y = 460)

  score_text <- game$add_text(
    text = "score: 0",
    id = "score_text",
    x = 30,
    y = 30
  )

  player$add_player_controls(
    directions = c("left", "right", "up", "down"),
    speed = 250
  )

  Sys.sleep(0.1)

  game$add_overlap(
    object_one_name = "player",
    group_name = "apples",
    callback_fun = function(evt) {
      score <<- score + 1
      score_text$set(paste0("score: ", score))
      apples$disable(evt)
    },
    input = input
  )
}

shiny::shinyApp(ui, server)
