#' Create an assets folder
#'
#' @description Creates an assets directory at the user-supplied `path` if it
#'   doesn't exist. Useful for storing your game's graphic assets.
#'
#' @param path Character. Directory path to create. No default is provided so
#'   the function does not write to the user's working directory unless a path
#'   is explicitly supplied.
#'
#' @examples
#' assets_dir <- file.path(tempdir(), "shinyphaser-assets")
#' phaser_create_assets(assets_dir)
#'
#' @export
phaser_create_assets <- function(path) {
  if (missing(path)) {
    stop("`path` must be supplied.", call. = FALSE)
  }

  if (!is.character(path) || length(path) != 1L || is.na(path) || !nzchar(path)) {
    stop("`path` must be a non-empty character string.", call. = FALSE)
  }

  if (file.exists(path) && !dir.exists(path)) {
    stop("`path` exists but is not a directory.", call. = FALSE)
  }

  if (!dir.exists(path)) {
    if (!dir.create(path, recursive = TRUE)) {
      stop("Failed to create directory: ", path, call. = FALSE)
    }
    message("Created directory: ", path)
  } else {
    message("Directory already exists: ", path)
  }

  invisible(normalizePath(path, winslash = "/", mustWork = TRUE))
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
