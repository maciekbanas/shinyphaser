devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 600)

moves <- c("move_left", "move_right", "move_up", "move_down")

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
  state$collected <- list()
  state$is_boosting <- FALSE

  base_speed <- 250
  boost_speed <- 650
  boost_duration <- 1

  level_config <- list(
    `1` = list(
      apples = data.frame(x = c(250, 820, 700, 140, 480, 900), y = c(120, 180, 460, 520, 300, 80)),
      attackers = 4,
      enemy_name = "badger",
      speed = c(30, 40, 50),
      distance = c(80, 110, 120, 150)
    ),
    `2` = list(
      apples = data.frame(x = c(120, 220, 340, 480, 620, 760, 860, 930, 520), y = c(90, 520, 200, 430, 100, 510, 260, 430, 300)),
      attackers = 7,
      enemy_name = "badger",
      speed = c(45, 55, 65, 75),
      distance = c(100, 130, 150, 180)
    ),
    `3` = list(
      apples = data.frame(x = c(80, 180, 300, 420, 560, 700, 820, 940, 260, 640, 520), y = c(80, 240, 120, 500, 280, 460, 160, 340, 540, 90, 380)),
      attackers = 9,
      enemy_name = "fox",
      speed = c(80, 95, 110, 125),
      distance = c(120, 150, 190, 220)
    )
  )

  game$set_shiny_session()

  grass <- game$add_static_group(name = "grass", url = "assets/hedgehog/terrain/grass.png")
  for (x in seq(100, 900, by = 200)) for (y in seq(80, 560, by = 160)) grass$create(x = x, y = y)

  hedgehog <- game$add_sprite(
    name = "hedgehog", url = "assets/hedgehog/sprites/hedgehog_32.png",
    x = 120, y = 300, frameWidth = 32, frameHeight = 32, frameCount = 5, frameRate = 6
  )
  purrr::walk(moves, function(move) {
    hedgehog$add_animation(
      suffix = move, 
      url = paste0("assets/hedgehog/sprites/hedgehog_", move, "_32.png"), 
      frameWidth = 32, 
      frameHeight = 32, 
      frameRate = 4
    )
  })  
  
  score_text <- game$add_text(text = "Level 1 score: 0", id = "score_text", x = 30, y = 30)

  create_attackers <- function(prefix, n, enemy_name) {
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
        url = paste0("assets/hedgehog/sprites/", enemy_name, "_move_left_50.png"),
        x = spawn_point$x, 
        y = spawn_point$y, 
        frameWidth = 50, 
        frameHeight = 50, 
        frameCount = 1, 
        frameRate = 1
      )
      purrr::walk(moves, function(move) {
        enemy$add_animation(
          suffix = move, 
          url = paste0("assets/hedgehog/sprites/", enemy_name, "_", move, "_50.png"), 
          frameWidth = 50,
          frameHeight = 50, 
          frameRate = 4
        )
      })
      enemy
    })
  }

  add_enemy_overlap <- function(name, level_id, enemy_name) {
    game$add_overlap("hedgehog", object_two_name = name, callback_fun = function(evt) {
      if (!state$started || state$game_over || state$current_level != level_id) return(invisible(NULL))
      state$game_over <- TRUE
      shinyalert::shinyalert(
        title = "Game over", text = paste0("A ", enemy_name, " caught the hedgehog. Try again!"), type = "error",
        closeOnClickOutside = FALSE, showCancelButton = FALSE,
        callbackR = function(value) shiny::stopApp()
      )
    }, input = input)
  }

  pause_gameplay <- function(level_id = state$current_level) {
    state$started <- FALSE
    hedgehog$set_velocity_x(0)
    hedgehog$set_velocity_y(0)

    current <- state$levels[[as.character(level_id)]]
    if (!is.null(current) && length(current$attackers) > 0) {
      for (enemy in current$attackers) {
        enemy$set_velocity_x(0)
        enemy$set_velocity_y(0)
      }
    }
  }

  init_level <- function(level_id) {
    shinyalert::shinyalert(
      title = paste0("Welcome to level", level_id, "!"),
      text = "Collect apples and avoid attackers. Finish all levels to win! Click OK to start.",
      type = "info", closeOnClickOutside = FALSE, showCancelButton = FALSE,
      callbackR = function(value) {
        state$started <- TRUE
        hedgehog$add_player_controls(directions = c("left", "right", "up", "down"), speed = base_speed)
      }
    )
    cfg <- level_config[[as.character(level_id)]]
    apples_group <- game$add_static_group(name = paste0("apples_lvl", level_id), url = "assets/hedgehog/perks/apple_20.png")
    for (i in seq_len(nrow(cfg$apples))) apples_group$create(x = cfg$apples$x[i], y = cfg$apples$y[i])

    attackers <- create_attackers(paste0("attacker_lvl", level_id, "_"), cfg$attackers, cfg$enemy_name)
    for (i in seq_along(attackers)) add_enemy_overlap(paste0("attacker_lvl", level_id, "_", i), level_id, cfg$enemy_name)

    game$add_overlap("hedgehog", group_name = paste0("apples_lvl", level_id), callback_fun = function(evt) {
      if (!state$started || state$current_level != level_id || state$game_over) return(invisible(NULL))

      apple_key <- paste(evt$x2, evt$y2, sep = ":")
      if (isTRUE(state$collected[[apple_key]])) return(invisible(NULL))
      state$collected[[apple_key]] <- TRUE

      state$score <- state$score + 1
      score_text$set(paste0("Level ", level_id, " score: ", state$score))
      apples_group$disable(evt)

      if (state$score >= nrow(cfg$apples)) {
        pause_gameplay(level_id)
        if (level_id < length(level_config)) {
          shinyalert::shinyalert(
            title = paste("Level", level_id, "passed!"),
            text = paste("Great! Click OK to move to level", level_id + 1, "."),
            type = "success", closeOnClickOutside = FALSE, showCancelButton = FALSE,
            callbackR = function(value) {
              for (enemy in state$levels[[as.character(level_id)]]$attackers) enemy$destroy()
              next_level <- level_id + 1
              if (is.null(state$levels[[as.character(next_level)]])) {
                state$levels[[as.character(next_level)]] <- init_level(next_level)
              }
              state$score <- 0
              state$collected <- list()
              state$current_level <- next_level
              score_text$set(paste0("Level ", state$current_level, " score: 0"))
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


  game$add_control("Space", action = function() {
    if (!state$started || state$game_over || state$is_boosting) return(invisible(NULL))

    state$is_boosting <- TRUE
    hedgehog$add_player_controls(directions = c("left", "right", "up", "down"), speed = boost_speed)

    later::later(function() {
      state$is_boosting <- FALSE
      if (state$started && !state$game_over) {
        hedgehog$add_player_controls(directions = c("left", "right", "up", "down"), speed = base_speed)
      }
    }, delay = boost_duration)
  }, input = input)

  state$levels[["1"]] <- init_level(1)

  shiny::observe({
    shiny::invalidateLater(700, session)
    if (state$game_over || !state$started) return(invisible(NULL))

    current <- state$levels[[as.character(state$current_level)]]
    if (is.null(current) || length(current$attackers) == 0) return(invisible(NULL))
    attackers <- current$attackers
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
}

shiny::shinyApp(ui, server)
