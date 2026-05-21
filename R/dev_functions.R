#' Create assets folder in your project
#'
#' @description Creates the default `inst/examples/assets/` directory in your package project
#'   if it doesn't exist. Useful for storing your game's graphic assets.
#' @export
phaser_create_assets <- function() {
  assets_dir <- file.path("inst", "examples", "assets")

  if (!dir.exists(assets_dir)) {
    dir.create(assets_dir, recursive = TRUE)
    message("Created directory: ", assets_dir)
  } else {
    message("Directory already exists: ", assets_dir)
  }
}

#' Run the packaged shinyphaser sample app
#'
#' @description Launches the sample Shiny application bundled with the package.
#' This is a quick way to see a working `shinyphaser` game setup.
#'
#' @export
run_sample_app <- function() {
  app_dir <- system.file("sample_app", package = "shinyphaser")

  if (app_dir == "") {
    stop("Sample app not found in installed shinyphaser package.", call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}
