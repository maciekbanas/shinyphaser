test_that("game examples resolve their own assets when sourced elsewhere", {
  lapply(c("geometry_dash", "hedgehog", "swamps_rpg"), function(name) {
    app_dir <- system.file("examples", name, package = "shinyphaser")
    app_file <- file.path(app_dir, "app.R")
    prefix <- paste0(gsub("_", "-", name), "-assets")
    previous <- shiny::resourcePaths()[prefix]
    withr::defer({
      shiny::removeResourcePath(prefix)
      if (length(previous) && !is.na(previous)) {
        shiny::addResourcePath(prefix, previous)
      }
    }, envir = environment())

    app <- withr::with_dir(tempdir(), {
      source(app_file, local = new.env(parent = globalenv()))$value
    })
    expect_s3_class(app, "shiny.appobj")
    expect_identical(
      normalizePath(unname(shiny::resourcePaths()[prefix]), winslash = "/"),
      normalizePath(file.path(app_dir, "www"), winslash = "/")
    )
    expect_true(length(list.files(file.path(app_dir, "www"), recursive = TRUE)) > 0)
  })
})
