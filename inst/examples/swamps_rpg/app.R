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
ui <- shiny::fluidPage(
  shiny::tags$style("body {max-width:1000px;margin:auto;background:#f5f4ee;}
    #phaser_game {width:100% !important;height:auto !important;}
    canvas {max-width:100%;} #status {min-height:48px;}"),
  shiny::h2("Swamp clearing"),
  shiny::p("Move with the arrow keys. Find the gold key, avoid the mushroom,
           then enter the blue doorway. Walk behind the trees to try the depth effect."),
  shiny::fluidRow(
    shiny::column(8, shiny::actionButton("restart", "New game"),
      shiny::actionButton("save", "Save"), shiny::actionButton("load", "Load")),
    shiny::column(4, shiny::checkboxInput("sound", "Sound", TRUE))
  ),
  shiny::textOutput("status"),
  ui_game$use_phaser(),
  shiny::p("A small feature demo: two maps, scenery footprints, enemy sight,
           sound, and session-local saving. Contact resets your position; there is no combat.")
)

server <- function(input, output, session) {
  # Keep each visitor's game and save slot independent.
  game <- PhaserGame$new(width = 960, height = 600)
  game$set_shiny_session(session)
  save_directory <- tempfile("swamp-save-")
  session$onSessionEnded(function() unlink(save_directory, recursive = TRUE))
  realm <- "mushroom_swamps"
  has_key <- FALSE
  completed <- FALSE
  notice <- shiny::reactiveVal("Find the gold key in the south-west of the clearing.")
  output$status <- shiny::renderText(notice())

  sys.source(file.path(example_dir, "modules", "navigation_setup.R"), environment())
  sys.source(file.path(example_dir, "modules", "hero.R"), environment())
  sys.source(file.path(example_dir, "modules", "scenery.R"), environment())
  sys.source(file.path(example_dir, "modules", "navigation.R"), environment())
  sys.source(file.path(example_dir, "modules", "saving.R"), environment())
}

shiny::shinyApp(ui, server)
