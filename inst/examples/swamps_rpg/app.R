library(shinyphaser)

# Resolve paths from the sourced file, or Shiny's app working directory.
example_dir <- local({
  paths <- vapply(sys.frames(), function(frame) {
    if (is.null(frame$ofile)) "" else as.character(frame$ofile)[1]
  }, character(1))
  paths <- paths[nzchar(paths)]
  if (length(paths)) dirname(normalizePath(tail(paths, 1), mustWork = TRUE)) else getwd()
})
shiny::addResourcePath("swamps-rpg-assets", file.path(example_dir, "www"))

game <- PhaserGame$new(width = 1600, height = 800)
map_tile_size <- 100
map_tile_width <- 32
map_tile_height <- 64
world_width <- map_tile_width * map_tile_size
world_height <- map_tile_height * map_tile_size
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))

# Each module is evaluated in the app or server environment so the example stays
# easy to read while retaining the shared state expected by its Shiny callbacks.
source(file.path(example_dir, "ui.R"), local = TRUE)

server <- function(input, output, session) {
  server_env <- environment()
  modules <- c(
    "game_state.R",
    "navigation_setup.R",
    "hero.R",
    file.path("realms", "mushroom_swamps_world.R"),
    "navigation.R",
    "saving.R"
  )
  # These files intentionally live outside an R/ directory. Shiny automatically
  # sources R/ before it evaluates app.R, when `game` does not exist yet.
  for (module in file.path(example_dir, "modules", modules)) {
    sys.source(module, envir = server_env)
  }
}

shiny::shinyApp(ui, server)
