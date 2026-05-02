devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 600)

ui <- game$ui()

server <- function(input, output, session) {
  score <- 0

  game$set_shiny_session()

  game$add_image(
    name = "sky",
    url = "assets/bear_game/terrain/sky.png",
    x = 500,
    y = 250
  )

  grass <- game$add_static_sprite(
    name = "grass",
    url = "assets/bear_game/terrain/grass.png",
    x = 500,
    y = 560
  )

  player <- game$add_sprite(
    name = "player",
    url = "assets/rpg_game/sprites/hero_idle.png",
    x = 120,
    y = 470,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 1,
    frameRate = 1
  )

  apples <- game$add_static_group(
    name = "apples",
    url = "assets/bear_game/perks/apple.png"
  )

  apples$create(x = 350, y = 520)
  apples$create(x = 550, y = 520)
  apples$create(x = 750, y = 520)

  score_text <- game$add_text(
    text = "score: 0",
    id = "score_text",
    x = 30,
    y = 30
  )

  Sys.sleep(0.1)

  game$add_collider(
    object_one_name = "player",
    object_two_name = "grass"
  )

  game$add_control(
    "ArrowLeft",
    action = function() {
      player$move(dirX = -1, dirY = 0, speed = 300, distance = 60)
    },
    input
  )

  game$add_control(
    "ArrowRight",
    action = function() {
      player$move(dirX = 1, dirY = 0, speed = 300, distance = 60)
    },
    input
  )

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
