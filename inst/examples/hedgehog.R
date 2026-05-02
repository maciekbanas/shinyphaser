devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 600)

ui <- shiny::tagList(
  shinyalert::useShinyalert(),
  game$ui()
)

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

  attackers <- lapply(seq_len(4), function(i) {
    spawn_side <- sample(c("left", "right", "top", "bottom"), 1)
    spawn_point <- switch(
      spawn_side,
      left = list(x = 20, y = sample(40:560, 1)),
      right = list(x = 980, y = sample(40:560, 1)),
      top = list(x = sample(40:960, 1), y = 20),
      bottom = list(x = sample(40:960, 1), y = 580)
    )

    enemy <- game$add_sprite(
      name = paste0("attacker_", i),
      url = "assets/hedgehog/sprites/hedgehog_move_right_32.png",
      x = spawn_point$x,
      y = spawn_point$y,
      frameWidth = 32,
      frameHeight = 32,
      frameCount = 5,
      frameRate = 6
    )

    enemy$add_animation(
      suffix = "move_left",
      url = "assets/hedgehog/sprites/hedgehog_move_left_32.png",
      frameWidth = 32, frameHeight = 32, frameRate = 6
    )
    enemy$add_animation(
      suffix = "move_right",
      url = "assets/hedgehog/sprites/hedgehog_move_right_32.png",
      frameWidth = 32, frameHeight = 32, frameRate = 6
    )
    enemy$add_animation(
      suffix = "move_up",
      url = "assets/hedgehog/sprites/hedgehog_move_up_32.png",
      frameWidth = 32, frameHeight = 32, frameRate = 6
    )
    enemy$add_animation(
      suffix = "move_down",
      url = "assets/hedgehog/sprites/hedgehog_move_down_32.png",
      frameWidth = 32, frameHeight = 32, frameRate = 6
    )

    enemy
  })

  game_over <- FALSE

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

  shiny::observe({
    shiny::invalidateLater(700, session)
    if (game_over) {
      return(invisible(NULL))
    }

    for (enemy in attackers) {
      dir <- sample(list(c(-1, 0), c(1, 0), c(0, -1), c(0, 1)), 1)[[1]]
      enemy$set_in_motion(
        dirX = dir[1],
        dirY = dir[2],
        speed = sample(c(120, 160, 200), 1),
        distance = sample(c(60, 90, 120, 150), 1),
        lag = 0
      )
    }
  })

  Sys.sleep(0.1)

  game$add_overlap(
    object_one_name = "hedgehog",
    group_name = "apples",
    callback_fun = function(evt) {
      score <<- score + 1
      score_text$set(paste0("score: ", score))
      apples$disable(evt)

      if (!level_passed && score >= total_apples) {
        level_passed <<- TRUE
        shinyalert::shinyalert(
          title = "Level passed!",
          text = "Congratulations! You collected all apples.",
          type = "success",
          closeOnClickOutside = FALSE,
          showCancelButton = FALSE,
          callbackR = function(value) {
            shiny::stopApp()
          }
        )
      }
    },
    input = input
  )

  for (i in seq_along(attackers)) {
    game$add_overlap(
      object_one_name = "hedgehog",
      object_two_name = paste0("attacker_", i),
      callback_fun = function(evt) {
        if (game_over) {
          return(invisible(NULL))
        }
        game_over <<- TRUE
        shinyalert::shinyalert(
          title = "Game over",
          text = "An attacker caught your hedgehog. This is the end of the game.",
          type = "error",
          closeOnClickOutside = FALSE,
          showCancelButton = FALSE,
          callbackR = function(value) {
            shiny::stopApp()
          }
        )
      },
      input = input
    )
  }

}

shiny::shinyApp(ui, server)
