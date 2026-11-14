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
  mushroom_spawns <- data.frame(
    id = c("mushroom", "mushroom_2", "mushroom_3", "mushroom_4"),
    x = c(650, 1150, 450, 850), y = c(350, 250, 750, 850)
  )
  skeleton_spawns <- data.frame(
    id = c("skeleton", "skeleton_2", "skeleton_3", "skeleton_4"),
    x = c(1350, 1450, 450, 750), y = c(1100, 750, 250, 350),
    realm = c("mushroom_swamps", "mushroom_swamps", "crypt", "crypt")
  )
  enemy_realm <- c(stats::setNames(rep("mushroom_swamps", nrow(mushroom_spawns)), mushroom_spawns$id),
    stats::setNames(skeleton_spawns$realm, skeleton_spawns$id))
  enemy_max_hit_points <- c(stats::setNames(rep(6, nrow(mushroom_spawns)), mushroom_spawns$id),
    stats::setNames(rep(8, nrow(skeleton_spawns)), skeleton_spawns$id))
  enemy_labels <- c(stats::setNames(paste("Mushroom", seq_len(nrow(mushroom_spawns))), mushroom_spawns$id),
    stats::setNames(paste("Skeleton", seq_len(nrow(skeleton_spawns))), skeleton_spawns$id))
  enemy_hit_points <- enemy_max_hit_points
  enemy_in_range <- stats::setNames(rep(FALSE, length(enemy_max_hit_points)), names(enemy_max_hit_points))
  last_attack <- -Inf
  last_damage <- -Inf
  enemy_hurt_until <- stats::setNames(rep(-Inf, length(enemy_max_hit_points)), names(enemy_max_hit_points))
  combat_generation <- 0L
  notice <- shiny::reactiveVal("Enter the crypt in the south and rescue the mushroom spirit.")
  show_dialog <- function(title, text, type = "info") {
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
      title = title, text = text, type = type,
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
  show_objective <- function() {
    show_dialog(
      title = if (completed) "You won!" else "Rescue the mushroom spirit",
      text = if (completed) {
        "The mushroom spirit is safe. You won the game! Explore or start a new game."
      } else {
        "Find the stone crypt entrance at the bottom of the clearing. Rescue the mushroom spirit inside to win. Move with the arrow keys and press Space to fight enemies at close range."
      },
      type = if (completed) "success" else "info"
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
