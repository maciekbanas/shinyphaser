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
  state$started <- FALSE
  state$levels <- list()

  level_config <- list(
    `1` = list(
      apples = data.frame(x = c(250, 820, 700, 140, 480, 900), y = c(120, 180, 460, 520, 300, 80)),
      attackers = 4,
      speed = c(30, 40, 50),
      distance = c(80, 110, 120, 150)
    ),
    `2` = list(
      apples = data.frame(x = c(120, 220, 340, 480, 620, 760, 860, 930, 520), y = c(90, 520, 200, 430, 100, 510, 260, 430, 300)),
      attackers = 7,
      speed = c(45, 55, 65, 75),
      distance = c(100, 130, 150, 180)
    )
  )

  game$set_shiny_session()

  grass <- game$add_static_group(name = "grass", url = "assets/hedgehog/terrain/grass.png")
  for (x in seq(100, 900, by = 200)) for (y in seq(80, 560, by = 160)) grass$create(x = x, y = y)

  hedgehog <- game$add_sprite(
    name = "hedgehog", url = "assets/hedgehog/sprites/hedgehog_32.png",
    x = 120, y = 300, frameWidth = 32, frameHeight = 32, frameCount = 5, frameRate = 6
  )
  hedgehog$add_animation(suffix = "move_left", url = "assets/hedgehog/sprites/hedgehog_move_left_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)
  hedgehog$add_animation(suffix = "move_right", url = "assets/hedgehog/sprites/hedgehog_move_right_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)
  hedgehog$add_animation(suffix = "move_up", url = "assets/hedgehog/sprites/hedgehog_move_up_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)
  hedgehog$add_animation(suffix = "move_down", url = "assets/hedgehog/sprites/hedgehog_move_down_32.png", frameWidth = 32, frameHeight = 32, frameRate = 4)

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
        name = paste0(prefix, i), url = "assets/hedgehog/sprites/badger_left_50.png",
        x = spawn_point$x, y = spawn_point$y, frameWidth = 50, frameHeight = 50, frameCount = 1, frameRate = 1
      )
      enemy$add_animation(suffix = "move_left", url = "assets/hedgehog/sprites/badger_left_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy$add_animation(suffix = "move_right", url = "assets/hedgehog/sprites/badger_right_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy$add_animation(suffix = "move_up", url = "assets/hedgehog/sprites/badger_right_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy$add_animation(suffix = "move_down", url = "assets/hedgehog/sprites/badger_left_50.png", frameWidth = 50, frameHeight = 50, frameRate = 4)
      enemy
    })
  }

  add_enemy_overlap <- function(name, level_id) {
    game$add_overlap("hedgehog", object_two_name = name, callback_fun = function(evt) {
      if (!state$started || state$game_over || state$current_level != level_id) return(invisible(NULL))
      state$game_over <- TRUE
      shinyalert::shinyalert(
        title = "Game over", text = "A badger caught the hedgehog. Try again!", type = "error",
        closeOnClickOutside = FALSE, showCancelButton = FALSE,
        callbackR = function(value) shiny::stopApp()
      )
    }, input = input)
  }

  init_level <- function(level_id) {
    cfg <- level_config[[as.character(level_id)]]
    apples_group <- game$add_static_group(name = paste0("apples_lvl", level_id), url = "assets/hedgehog/perks/apple_20.png")
    for (i in seq_len(nrow(cfg$apples))) apples_group$create(x = cfg$apples$x[i], y = cfg$apples$y[i])

    attackers <- create_attackers(paste0("attacker_lvl", level_id, "_"), cfg$attackers)
    for (i in seq_along(attackers)) add_enemy_overlap(paste0("attacker_lvl", level_id, "_", i), level_id)

    game$add_overlap("hedgehog", group_name = paste0("apples_lvl", level_id), callback_fun = function(evt) {
      if (!state$started || state$current_level != level_id || state$game_over) return(invisible(NULL))
      state$score <- state$score + 1
      score_text$set(paste0("Level ", level_id, " score: ", state$score))
      apples_group$disable(evt)

      if (state$score >= nrow(cfg$apples)) {
        if (level_id < length(level_config)) {
          shinyalert::shinyalert(
            title = paste("Level", level_id, "passed!"),
            text = paste("Great! Click OK to move to level", level_id + 1, "."),
            type = "success", closeOnClickOutside = FALSE, showCancelButton = FALSE,
            callbackR = function(value) {
              for (enemy in state$levels[[as.character(level_id)]]$attackers) enemy$destroy()
              state$score <- 0
              state$current_level <- level_id + 1
              score_text$set(paste0("Level ", state$current_level, " score: 0"))

              if (is.null(state$levels[[as.character(state$current_level)]])) {
                state$levels[[as.character(state$current_level)]] <- init_level(state$current_level)
              }
            }
          )
        } else {
          shinyalert::shinyalert(
            title = "You won!", text = "Great job! You finished all levels and collected all apples.",
            type = "success", closeOnClickOutside = FALSE, showCancelButton = FALSE,
            callbackR = function(value) shiny::stopApp()
          )
        }
      }
    }, input = input)

    list(apples = apples_group, attackers = attackers)
  }

  state$levels[["1"]] <- init_level(1)

  shiny::observe({
    shiny::invalidateLater(700, session)
    if (state$game_over || !state$started) return(invisible(NULL))

    attackers <- state$levels[[as.character(state$current_level)]]$attackers
    cfg <- level_config[[as.character(state$current_level)]]
    for (enemy in attackers) {
      dir <- sample(list(c(-1, 0), c(1, 0), c(0, -1), c(0, 1)), 1)[[1]]
      enemy$set_in_motion(dirX = dir[1], dirY = dir[2], speed = sample(cfg$speed, 1), distance = sample(cfg$distance, 1), lag = 0)
    }
  })

  shinyalert::shinyalert(
    title = "Welcome to the game!",
    text = "Collect apples and avoid badgers. Finish all levels to win! Click OK to start.",
    type = "info", closeOnClickOutside = FALSE, showCancelButton = FALSE,
    callbackR = function(value) {
      state$started <- TRUE
      hedgehog$add_player_controls(directions = c("left", "right", "up", "down"), speed = 250)
    }
  )
}

shiny::shinyApp(ui, server)
