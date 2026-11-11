library(shinyphaser)

# Resolve assets when Shiny runs the directory or app.R is sourced elsewhere.
example_dir <- local({
  paths <- vapply(sys.frames(), function(frame) {
    if (is.null(frame$ofile)) "" else as.character(frame$ofile)[1]
  }, character(1))
  paths <- paths[nzchar(paths)]
  if (length(paths)) dirname(normalizePath(tail(paths, 1), mustWork = TRUE)) else getwd()
})
shiny::addResourcePath("swamps-rpg-assets", file.path(example_dir, "www"))
asset <- function(path) paste0("swamps-rpg-assets/", path)
source(file.path(example_dir, "modules", "scenery_layout.R"), local = TRUE)

ui_game <- PhaserGame$new(width = 960, height = 600)
source(file.path(example_dir, "ui.R"), local = TRUE)

server <- function(input, output, session) {
  # Keep each visitor's game and save slot independent.
  game <- PhaserGame$new(width = 960, height = 600)
  game$set_shiny_session(session)
  save_directory <- tempfile("swamp-save-")
  session$onSessionEnded(function() unlink(save_directory, recursive = TRUE))
  realm <- "mushroom_swamps"
  spirit_rescued <- FALSE
  completed <- FALSE
  life_points <- 100
  skeleton_spawns <- data.frame(
    id = c("skeleton", "skeleton_2", "skeleton_3", "skeleton_4"),
    x = c(1450, 450, 1150, 850), y = c(750, 750, 150, 1050)
  )
  enemy_max_hit_points <- c(mushroom = 6,
    stats::setNames(rep(8, nrow(skeleton_spawns)), skeleton_spawns$id))
  enemy_labels <- c(mushroom = "Mushroom",
    stats::setNames(paste("Skeleton", seq_len(nrow(skeleton_spawns))), skeleton_spawns$id))
  enemy_hit_points <- enemy_max_hit_points
  enemy_in_range <- stats::setNames(rep(FALSE, length(enemy_max_hit_points)), names(enemy_max_hit_points))
  last_attack <- -Inf
  last_damage <- -Inf
  enemy_hurt_until <- stats::setNames(rep(-Inf, length(enemy_max_hit_points)), names(enemy_max_hit_points))
  combat_generation <- 0L
  notice <- shiny::reactiveVal("Rescue the good spirit in the south to unlock the crypt.")
  show_objective <- function() {
    # Let the initial loader finish before pausing its scene.
    session$sendCustomMessage("phaser", list(js = paste0(
      "window.swampsObjectiveOpen = true;",
      "(function pauseWhenReady() {",
      "if (!window.swampsObjectiveOpen) return;",
      "if (typeof scene !== 'undefined' && scene && scene.hero && scene.skeleton_4 &&",
      "GameBridge.maps.crypt && !scene.load.isLoading()) scene.scene.pause();",
      "else window.setTimeout(pauseWhenReady, 50);",
      "})();"
    )))
    shinyalert::shinyalert(
      title = if (spirit_rescued) "Enter the crypt" else "Rescue the good spirit",
      text = if (spirit_rescued) {
        "The spirit is safe! Enter the blue crypt doorway in the north-east of the clearing."
      } else {
        "Find and rescue the good spirit in the south of the clearing. Move with the arrow keys and press Space to fight enemies at close range."
      },
      type = if (spirit_rescued) "success" else "info",
      confirmButtonText = "Continue", closeOnEsc = FALSE,
      closeOnClickOutside = FALSE,
      callbackJS = "function() {
        window.swampsObjectiveOpen = false;
        if (typeof scene !== 'undefined' && scene && scene.scene) {
          scene.input.keyboard.resetKeys();
          scene.scene.resume();
        }
      }", session = session
    )
  }
  session$onFlushed(function() show_objective(), once = TRUE)

  sys.source(file.path(example_dir, "modules", "navigation_setup.R"), environment())
  sys.source(file.path(example_dir, "modules", "hero.R"), environment())
  sys.source(file.path(example_dir, "modules", "scenery.R"), environment())
  sys.source(file.path(example_dir, "modules", "combat.R"), environment())
  sys.source(file.path(example_dir, "modules", "navigation.R"), environment())
  sys.source(file.path(example_dir, "modules", "saving.R"), environment())
}

shiny::shinyApp(ui, server)
