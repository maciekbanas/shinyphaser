library(shiny)
library(shinyphaser)

# Resolve paths from the sourced file, or Shiny's app working directory.
example_dir <- local({
  paths <- vapply(sys.frames(), function(frame) {
    if (is.null(frame$ofile)) "" else as.character(frame$ofile)[1]
  }, character(1))
  paths <- paths[nzchar(paths)]
  if (length(paths)) dirname(normalizePath(tail(paths, 1), mustWork = TRUE)) else getwd()
})
shiny::addResourcePath("geometry-dash-assets", file.path(example_dir, "www"))

# A short, fixed course. All movement and collision reactions run in the browser.
course_width <- 3600
game <- PhaserGame$new(width = 960, height = 480, gravity_y = 1400)

ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background: #101629; color: #e9f5ff; font-family: sans-serif; }
    .dash { max-width: 960px; margin: 24px auto; }
    #phaser_game { width: 100% !important; height: auto !important; }
    #phaser_game canvas { max-width: 100%; height: auto !important; }
    button { background: #59f5d0; color: #101629; border: 0;
             border-radius: 6px; padding: 10px 18px; cursor: pointer; }
  "))),
  div(class = "dash",
    h2("Geometry Dash — shinyphaser"),
    p("Space / Up / tap the game to jump. Avoid the pink spikes and reach the finish."),
    tags$button(type = "button", onclick = "window.location.reload()", "Restart"),
    game$use_phaser()
  ),
  # Translate pointer input to the same browser-side control as the keyboard.
  tags$script(HTML("
    document.addEventListener('keydown', function (event) {
      if (event.code === 'Space' || event.code === 'ArrowUp') event.preventDefault();
    });
    document.getElementById('phaser_game').addEventListener('pointerdown', function (event) {
      event.preventDefault();
      document.dispatchEvent(new KeyboardEvent('keydown', {code: 'Space'}));
    });
  "))
)

server <- function(input, output, session) {
  # Keep the bridge and all game state private to this browser session.
  game <- PhaserGame$new(width = 960, height = 480, gravity_y = 1400)
  game$set_shiny_session(session)
  game$set_world_bounds(course_width, 480)

  alive <- game$add_state("dash_alive", TRUE)
  grounded <- game$add_state("dash_grounded", FALSE)

  game$add_rectangle("sky", course_width / 2, 240, course_width, 480, "0x101629")
  for (x in seq(0, course_width, by = 120)) {
    game$add_rectangle(paste0("grid_", x), x, 200, 1, 400, "0x202c48")
  }
  game$add_rectangle("floor_art", course_width / 2, 440, course_width, 80, "0x243750")
  game$add_rectangle("floor_edge", course_width / 2, 402, course_width, 4, "0x59f5d0")
  game$add_collision_rectangle("floor", course_width / 2, 440, course_width, 80)

  player <- game$add_sprite("cube", "geometry-dash-assets/cube.png", 120, 384,
                            frame_width = 32, frame_height = 32)
  player$set_depth(10)
  player$follow_camera()

  status <- game$add_text("Press Space / Up / tap to start", "status", 24, 24,
                         style = list(fontSize = "24px", color = "#59f5d0"))
  status$set_depth(20)$set_scroll_factor(0)

  game$add_collider("cube", "floor", browser_action = browser_actions({
    grounded$set(TRUE)
  }))

  for (key in c("Space", "ArrowUp")) {
    game$add_control(key, browser_action = browser_actions({
      if (alive$is_true() && grounded$is_true()) {
        grounded$set(FALSE)
        player$set_velocity_x(260)
        player$set_velocity_y(-480)
        status$set("Keep jumping! Reach the green finish.")
      }
    }))
  }

  # The inset rectangular hitboxes sit inside the triangular artwork.
  for (i in seq_along(c(560, 900, 1240, 1580, 1920, 2260, 2600, 2940))) {
    x <- c(560, 900, 1240, 1580, 1920, 2260, 2600, 2940)[i]
    name <- paste0("spike_", i)
    game$add_image(paste0(name, "_art"), "geometry-dash-assets/spike.png", x, 380)
    game$add_collision_rectangle(name, x, 385, 20, 30)
    game$add_overlap("cube", name, browser_action = browser_actions({
      if (alive$is_true()) {
        alive$set(FALSE)
        player$stop_motion()
        status$set("Crashed! Click Restart to try again.")
      }
    }))
  }

  game$add_rectangle("finish_art", 3300, 300, 8, 200, "0x59f5d0")
  game$add_text("FINISH", "finish_label", 3240, 165,
                style = list(fontSize = "24px", color = "#59f5d0"))
  game$add_collision_rectangle("finish", 3300, 300, 8, 200)
  game$add_overlap("cube", "finish", browser_action = browser_actions({
    if (alive$is_true()) {
      alive$set(FALSE)
      player$stop_motion()
      status$set("Level complete! Click Restart to play again.")
    }
  }))
}

shinyApp(ui, server)
