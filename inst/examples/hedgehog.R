devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 600)

ui <- game$ui()

server <- function(input, output, session) {
  score <- 0
  level_passed <- FALSE

  game$set_shiny_session()

  grass <- game$add_static_group(
    name = "grass",
    url = "assets/hedgehog/terrain/grass.png"
  )

  for (x in seq(100, 900, by = 200)) {
    for (y in seq(80, 560, by = 160)) {
      grass$create(x = x, y = y)
    }
  }

  hedgehog <- game$add_sprite(
    name = "hedgehog",
    url = "assets/hedgehog/sprites/hedgehog_32.png",
    x = 120,
    y = 300,
    frameWidth = 32,
    frameHeight = 32,
    frameCount = 5,
    frameRate = 6
  )

  hedgehog$add_animation(
    suffix = "move_left",
    url = "assets/hedgehog/sprites/hedgehog_move_left_32.png",
    frameWidth = 32, frameHeight = 32, frameRate = 4
  )
  hedgehog$add_animation(
    suffix = "move_right",
    url = "assets/hedgehog/sprites/hedgehog_move_right_32.png",
    frameWidth = 32, frameHeight = 32, frameRate = 4
  )

  hedgehog$add_animation(
    suffix = "move_up",
    url = "assets/hedgehog/sprites/hedgehog_move_up_32.png",
    frameWidth = 32, frameHeight = 32, frameRate = 4
  )
  hedgehog$add_animation(
    suffix = "move_down",
    url = "assets/hedgehog/sprites/hedgehog_move_down_32.png",
    frameWidth = 32, frameHeight = 32, frameRate = 4
  )

  apples <- game$add_static_group(
    name = "apples",
    url = "assets/hedgehog/perks/apple_20.png"
  )

  apple_positions <- data.frame(
    x = c(250, 820, 700, 140, 480, 900),
    y = c(120, 180, 460, 520, 300, 80)
  )

  for (i in seq_len(nrow(apple_positions))) {
    apples$create(x = apple_positions$x[i], y = apple_positions$y[i])
  }

  total_apples <- nrow(apple_positions)

  score_text <- game$add_text(
    text = "score: 0",
    id = "score_text",
    x = 30,
    y = 30
  )

  hedgehog$add_player_controls(
    directions = c("left", "right", "up", "down"),
    speed = 250
  )

  Sys.sleep(0.1)

  shiny::observeEvent(input$close_game, {
    shiny::removeModal()
    shiny::stopApp()
  })

  game$add_overlap(
    object_one_name = "hedgehog",
    group_name = "apples",
    callback_fun = function(evt) {
      score <<- score + 1
      score_text$set(paste0("score: ", score))
      apples$disable(evt)

      if (!level_passed && score >= total_apples) {
        level_passed <<- TRUE
        shiny::showModal(
          shiny::modalDialog(
            title = "Level passed!",
            "Congratulations! You collected all apples.",
            footer = shiny::actionButton("close_game", "OK"),
            easyClose = FALSE
          )
        )
      }
    },
    input = input
  )
}

shiny::shinyApp(ui, server)
