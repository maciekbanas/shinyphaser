test_that("swamp scenery uses clear grass and stable non-overlapping placements", {
  example_dir <- system.file("examples", "swamps_rpg", package = "shinyphaser")
  env <- new.env(parent = globalenv())
  sys.source(file.path(example_dir, "modules", "scenery_layout.R"), env)
  map <- jsonlite::fromJSON(file.path(example_dir, "www", "maps", "mushroom_swamps.json"),
                            simplifyVector = FALSE)
  # Use the same reserved locations as the app, including its actor spawn points.
  app <- source(file.path(example_dir, "app.R"), local = new.env())$value
  layout <- NULL
  reserved <- NULL
  shiny::testServer(app$serverFuncSource(), {
    layout <<- scenery_layout
    reserved <<- reserved_positions
  })
  expect_equal(as.integer(table(layout$asset)), c(15L, 15L, 15L, 5L, 5L, 5L))
  expect_equal(nrow(layout), 60)
  seed_before <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  expect_identical(env$make_swamp_scenery(map, reserved), layout)
  expect_identical(get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE), seed_before)

  terrain <- Filter(function(layer) layer$name == "terrain", map$layers)[[1]]
  tiles <- matrix(unlist(terrain$data), nrow = map$height, byrow = TRUE)
  grass <- vapply(Filter(function(tile) grepl("^mushroom_swamps_grass_", tile$name),
                         map$tilesets), function(tile) tile$firstgid, numeric(1))
  for (i in seq_len(nrow(layout))) {
    item <- layout[i, ]
    columns <- seq(floor(item$left / 100) + 1, floor((item$right - 1) / 100) + 1)
    rows <- seq(floor(item$top / 100) + 1, floor((item$bottom - 1) / 100) + 1)
    expect_true(all(tiles[rows, columns] %in% grass), info = item$name)
    expect_true(file.exists(file.path(example_dir, "www", "terrain", "mushroom_swamps",
                                     paste0(item$asset, ".png"))))
    if (i > 1) {
      others <- layout[seq_len(i - 1), ]
      expect_false(any(item$left < others$right + 24 & item$right > others$left - 24 &
                         item$top < others$bottom + 24 & item$bottom > others$top - 24))
    }
  }
})
