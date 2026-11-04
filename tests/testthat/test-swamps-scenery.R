test_that("compact swamp scenery stays on grass without covering objectives", {
  example_dir <- system.file("examples", "swamps_rpg", package = "shinyphaser")
  env <- new.env(parent = globalenv())
  sys.source(file.path(example_dir, "modules", "scenery_layout.R"), env)
  layout <- env$swamp_scenery()
  map <- jsonlite::fromJSON(file.path(example_dir, "www", "maps", "mushroom_swamps.json"),
                            simplifyVector = FALSE)
  expect_equal(c(map$width, map$height), c(12, 8))
  expect_equal(nrow(layout), 5)
  terrain <- Filter(function(layer) layer$name == "terrain", map$layers)[[1]]
  tiles <- matrix(unlist(terrain$data), nrow = map$height, byrow = TRUE)
  grass <- vapply(Filter(function(tile) grepl("^mushroom_swamps_grass_", tile$name),
                         map$tilesets), function(tile) tile$firstgid, numeric(1))
  reserved <- rbind(c(150, 150), c(650, 350), c(550, 690), c(1050, 150))
  for (i in seq_len(nrow(layout))) {
    item <- layout[i, ]
    left <- item$x - item$width / 2
    right <- item$x + item$width / 2
    top <- item$base_y - item$height
    bottom <- item$base_y
    columns <- seq(floor(left / 100) + 1, floor((right - 1) / 100) + 1)
    rows <- seq(floor(top / 100) + 1, floor((bottom - 1) / 100) + 1)
    expect_true(all(tiles[rows, columns] %in% grass), info = item$name)
    expect_false(any(reserved[, 1] > left & reserved[, 1] < right &
                     reserved[, 2] > top & reserved[, 2] < bottom), info = item$name)
    expect_true(file.exists(file.path(example_dir, "www", "terrain", "mushroom_swamps",
                                     paste0(item$asset, ".png"))))
  }
})

test_that("clearing objectives, map transitions, restart and saves remain consistent", {
  example_dir <- system.file("examples", "swamps_rpg", package = "shinyphaser")
  app <- source(file.path(example_dir, "app.R"), local = new.env())$value
  shiny::testServer(app$serverFuncSource(), {
    # Read live closure state, rather than testServer's initial variable copies.
    state <- environment(show_realm)
    session$flushReact()
    session$setInputs(near_door = list(active = TRUE))
    expect_identical(state$realm, "mushroom_swamps")
    expect_false(state$completed)
    session$setInputs(near_key = list(active = TRUE))
    expect_true(state$has_key)
    session$setInputs(near_door = list(active = TRUE, nonce = 2))
    expect_identical(state$realm, "hut")
    expect_true(state$completed)
    session$setInputs(near_exit = list(active = FALSE))
    expect_identical(state$realm, "hut")
    session$setInputs(near_exit = list(active = TRUE))
    expect_identical(state$realm, "mushroom_swamps")
    # A late event for the hut cannot move the player from the clearing.
    session$setInputs(near_exit = list(active = TRUE, nonce = 2))
    expect_identical(state$realm, "mushroom_swamps")
    session$setInputs(load = 1)
    expect_match(notice(), "No saved progress")
    game$save_game("progress", state = list(realm = "hut", has_key = TRUE, completed = TRUE),
      snapshot = list(hero = list(x = 96, y = 210)), directory = save_directory)
    session$setInputs(restart = 1)
    expect_false(state$has_key)
    expect_false(state$completed)
    session$setInputs(load = 2)
    expect_identical(state$realm, "hut")
    expect_true(state$has_key)
    expect_true(state$completed)
  })
})
