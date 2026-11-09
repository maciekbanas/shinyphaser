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
  has_key <- FALSE
  completed <- FALSE
  life_points <- 100
  enemy_max_hit_points <- c(mushroom = 6, skeleton = 8)
  enemy_labels <- c(mushroom = "Mushroom", skeleton = "Skeleton")
  enemy_hit_points <- enemy_max_hit_points
  enemy_in_range <- stats::setNames(rep(FALSE, 2), names(enemy_max_hit_points))
  last_attack <- -Inf
  last_damage <- -Inf
  enemy_hurt_until <- stats::setNames(rep(-Inf, 2), names(enemy_max_hit_points))
  combat_generation <- 0L
  notice <- shiny::reactiveVal("Find the gold key in the south of the clearing.")
  output$status <- shiny::renderText(notice())

  sys.source(file.path(example_dir, "modules", "navigation_setup.R"), environment())
  sys.source(file.path(example_dir, "modules", "hero.R"), environment())
  sys.source(file.path(example_dir, "modules", "scenery.R"), environment())
  sys.source(file.path(example_dir, "modules", "combat.R"), environment())
  sys.source(file.path(example_dir, "modules", "navigation.R"), environment())
  sys.source(file.path(example_dir, "modules", "saving.R"), environment())
}

shiny::shinyApp(ui, server)
