devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 600)

ui <- shiny::tagList(
  shinyalert::useShinyalert(),
  game$ui()
)

server <- function(input, output, session) {
  state <- new.env(parent = emptyenv())
  state$score <- 0
  state$current_level <- 1
  state$game_over <- FALSE
  state$level2_initialized <- FALSE
  state$attackers_lvl1 <- list()
  state$attackers_lvl2 <- list()

  level_config <- list(
    `1` = list(
      apples = data.frame(
        x = c(250, 820, 700, 140, 480, 900),
        y = c(120, 180, 460, 520, 300, 80)
      ),
      attackers = 4,
      speed = c(30, 40, 50),
      distance = c(80, 110, 120, 150)
    ),
    `2` = list(
      apples = data.frame(
        x = c(120, 220, 340, 480, 620, 760, 860, 930, 520),
        y = c(90, 520, 200, 430, 100, 510, 260, 430, 300)
      ),
      attackers = 7,
      speed = c(45, 55, 65, 75),
      distance = c(100, 130, 150, 180)
    )
  )

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

  hedgehog$add_animation(suffix = "move_left", url = "assets/hedgehog/sprites/hedgehog_move_left_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)
  hedgehog$add_animation(suffix = "move_right", url = "assets/hedgehog/sprites/hedgehog_move_right_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)
  hedgehog$add_animation(suffix = "move_up", url = "assets/hedgehog/sprites/hedgehog_move_up_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)
  hedgehog$add_animation(suffix = "move_down", url = "assets/hedgehog/sprites/hedgehog_move_down_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)

  hedgehog$add_player_controls(directions = c("left", "right", "up", "down"), speed = 250)

  apples_lvl1 <- game$add_static_group(name = "apples_lvl1", url = "assets/hedgehog/perks/apple_20.png")
  apples_lvl2 <- game$add_static_group(name = "apples_lvl2", url = "assets/hedgehog/perks/apple_20.png")

  for (i in seq_len(nrow(level_config[["1"]]$apples))) {
    apples_lvl1$create(x = level_config[["1"]]$apples$x[i], y = level_config[["1"]]$apples$y[i])
  }


  start_level_two <- function() {
    if (!state$level2_initialized) {
      for (i in seq_len(nrow(level_config[["2"]]$apples))) {
        apples_lvl2$create(x = level_config[["2"]]$apples$x[i], y = level_config[["2"]]$apples$y[i])
      }

      state$attackers_lvl2 <- create_attackers("attacker_lvl2_", level_config[["2"]]$attackers)
      for (i in seq_along(state$attackers_lvl2)) {
        add_enemy_overlap(paste0("attacker_lvl2_", i), 2)
      }

      state$level2_initialized <- TRUE
    }

    state$score <- 0
    state$current_level <- 2
    state$attackers_lvl1 <- list()
    score_text$set("Level 2 score: 0")

    # Rebind controls after modal close to ensure keyboard input works on level 2.
    hedgehog$add_player_controls(directions = c("left", "right", "up", "down"), speed = 250)
  }

  score_text <- game$add_text(text = "Level 1 score: 0", id = "score_text", x = 30, y = 30)

  create_attackers <- function(prefix, n) {
    lapply(seq_len(n), function(i) {
      spawn_side <- sample(c("left", "right", "top", "bottom"), 1)
      spawn_point <- switch(
        spawn_side,
        left = list(x = 20, y = sample(40:560, 1)),
        right = list(x = 980, y = sample(40:560, 1)),
        top = list(x = sample(40:960, 1), y = 20),
        bottom = list(x = sample(40:960, 1), y = 580)
      )

      enemy <- game$add_sprite(
        name = paste0(prefix, i),
        url = "assets/hedgehog/sprites/badger_left_50.png",
        x = spawn_point$x,
        y = spawn_point$y,
        frameWidth = 50,
        frameHeight = 50,
        frameCount = 1,
        frameRate = 1
      )

      enemy$add_animation(suffix = "move_left", url = "assets/hedgehog/sprites/badger_left_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy$add_animation(suffix = "move_right", url = "assets/hedgehog/sprites/badger_right_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy$add_animation(suffix = "move_up", url = "assets/hedgehog/sprites/badger_right_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy$add_animation(suffix = "move_down", url = "assets/hedgehog/sprites/badger_left_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)

      enemy
    })
  }

  state$attackers_lvl1 <- create_attackers("attacker_lvl1_", level_config[["1"]]$attackers)

  level_completed <- c(`1` = FALSE, `2` = FALSE)

  shiny::observe({
    shiny::invalidateLater(700, session)
    if (state$game_over) return(invisible(NULL))

    attackers <- if (state$current_level == 1) state$attackers_lvl1 else state$attackers_lvl2
    if (length(attackers) == 0) return(invisible(NULL))
    cfg <- level_config[[as.character(state$current_level)]]

    for (enemy in attackers) {
      dir <- sample(list(c(-1, 0), c(1, 0), c(0, -1), c(0, 1)), 1)[[1]]
      enemy$set_in_motion(
        dirX = dir[1],
        dirY = dir[2],
        speed = sample(cfg$speed, 1),
        distance = sample(cfg$distance, 1),
        lag = 0
      )
    }
  })

  check_level_complete <- function() {
    total <- nrow(level_config[[as.character(state$current_level)]]$apples)
    if (!level_completed[[as.character(state$current_level)]] && state$score >= total) {
      level_completed[[as.character(state$current_level)]] <- TRUE

      if (state$current_level == 1) {
        shinyalert::shinyalert(
          title = "Level 1 passed!",
          text = "Great! Click OK to start harder level 2 (more apples, more badgers).",
          type = "success",
          closeOnClickOutside = FALSE,
          showCancelButton = FALSE,
          callbackR = function(value) {
            for (enemy in state$attackers_lvl1) {
              enemy$destroy()
            }

            start_level_two()

          }
        )
      } else {
        shinyalert::shinyalert(
          title = "You won!",
          text = "Great job! You finished both levels and collected all apples.",
          type = "success",
          closeOnClickOutside = FALSE,
          showCancelButton = FALSE,
          callbackR = function(value) {
            shiny::stopApp()
          }
        )
      }
    }
  }

  game$add_overlap("hedgehog", group_name = "apples_lvl1", callback_fun = function(evt) {
    if (state$current_level != 1 || state$game_over) return(invisible(NULL))
    state$score <- state$score + 1
    score_text$set(paste0("Level 1 score: ", state$score))
    apples_lvl1$disable(evt)
    check_level_complete()
  }, input = input)

  game$add_overlap("hedgehog", group_name = "apples_lvl2", callback_fun = function(evt) {
    if (state$current_level != 2 || state$game_over) return(invisible(NULL))
    state$score <- state$score + 1
    score_text$set(paste0("Level 2 score: ", state$score))
    apples_lvl2$disable(evt)
    check_level_complete()
  }, input = input)

  add_enemy_overlap <- function(name, level_id) {
    game$add_overlap("hedgehog", object_two_name = name, callback_fun = function(evt) {
      if (state$game_over || state$current_level != level_id) return(invisible(NULL))
      state$game_over <- TRUE
      shinyalert::shinyalert(
        title = "Game over",
        text = "A badger caught the hedgehog. Try again!",
        type = "error",
        closeOnClickOutside = FALSE,
        showCancelButton = FALSE,
        callbackR = function(value) {
          shiny::stopApp()
        }
      )
    }, input = input)
  }

  for (i in seq_along(state$attackers_lvl1)) add_enemy_overlap(paste0("attacker_lvl1_", i), 1)

  shinyalert::shinyalert(
    title = "Welcome to the game!",
    text = "Collect apples and avoid badgers. Finish both levels to win!",
    type = "info",
    closeOnClickOutside = FALSE,
    showCancelButton = FALSE
  )
}

shiny::shinyApp(ui, server)
