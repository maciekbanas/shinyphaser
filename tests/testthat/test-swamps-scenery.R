test_that("compact swamp scenery stays on grass without covering objectives", {
  example_dir <- system.file("examples", "swamps_rpg", package = "shinyphaser")
  env <- new.env(parent = globalenv())
  sys.source(file.path(example_dir, "modules", "scenery_layout.R"), env)
  layout <- env$swamp_scenery()
  map <- jsonlite::fromJSON(file.path(example_dir, "www", "maps", "mushroom_swamps.json"),
                            simplifyVector = FALSE)
  expect_equal(c(map$width, map$height), c(16, 12))
  expect_equal(nrow(layout), 7)
  terrain <- Filter(function(layer) layer$name == "terrain", map$layers)[[1]]
  tiles <- matrix(unlist(terrain$data), nrow = map$height, byrow = TRUE)
  grass <- vapply(Filter(function(tile) grepl("^mushroom_swamps_grass_", tile$name),
                         map$tilesets), function(tile) tile$firstgid, numeric(1))
  reserved <- rbind(c(150, 150), c(650, 350), c(650, 1090), c(1450, 150), c(1450, 750), c(450, 750), c(1150, 150), c(850, 1050))
  for (i in seq_len(nrow(reserved))) {
    column <- floor(reserved[i, 1] / map$tilewidth) + 1
    row <- floor(reserved[i, 2] / map$tileheight) + 1
    expect_true(tiles[row, column] %in% grass)
  }
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
    session$setInputs(near_good_spirit = list(active = TRUE))
    expect_true(state$spirit_rescued)
    session$setInputs(near_door = list(active = TRUE, nonce = 2))
    expect_identical(state$realm, "crypt")
    expect_true(state$completed)
    session$setInputs(near_exit = list(active = FALSE))
    expect_identical(state$realm, "crypt")
    session$setInputs(near_exit = list(active = TRUE))
    expect_identical(state$realm, "mushroom_swamps")
    # A late event for the hut cannot move the player from the clearing.
    session$setInputs(near_exit = list(active = TRUE, nonce = 2))
    expect_identical(state$realm, "mushroom_swamps")
    session$setInputs(load = 1)
    expect_match(notice(), "No saved progress")
    game$save_game("progress", state = list(realm = "crypt", spirit_rescued = TRUE, completed = TRUE,
      life_points = 70, enemy_hit_points = 0),
      snapshot = list(hero = list(x = 96, y = 210)), directory = save_directory)
    session$setInputs(restart = 1)
    expect_false(state$spirit_rescued)
    expect_false(state$completed)
    session$setInputs(load = 2)
    expect_identical(state$realm, "crypt")
    expect_true(state$spirit_rescued)
    expect_true(state$completed)
    expect_equal(state$life_points, 70)
    expect_equal(state$enemy_hit_points[["mushroom"]], 0)
  })
})

test_that("combat enforces range, cooldowns, defeat and restart", {
  app <- source(system.file("examples", "swamps_rpg", "app.R", package = "shinyphaser"),
                local = new.env())$value
  shiny::testServer(app$serverFuncSource(), {
    state <- environment(attack)
    expect_equal(knockback_from_contact(list(x1 = 0, y1 = 0, x2 = 10, y2 = 2)), c(x = 1, y = 0))
    expect_equal(knockback_from_contact(list(x1 = 10, y1 = 0, x2 = 0, y2 = 2)), c(x = -1, y = 0))
    expect_equal(knockback_from_contact(list(x1 = 0, y1 = 10, x2 = 2, y2 = 0)), c(x = 0, y = -1))
    expect_equal(knockback_from_contact(list()), c(x = 0, y = 1))
    session$flushReact()
    attack()
    expect_equal(state$enemy_hit_points[["mushroom"]], 6)
    state$last_attack <- -Inf
    session$setInputs(overlap_hero_mushroom = list(nonce = 1))
    expect_equal(state$life_points, 90)
    session$setInputs(overlap_hero_mushroom = list(nonce = 2))
    expect_equal(state$life_points, 90)
    attack()
    expect_equal(state$enemy_hit_points[["mushroom"]], 4)
    attack()
    expect_equal(state$enemy_hit_points[["mushroom"]], 4)
    session$setInputs(overlap_end_hero_mushroom = list(nonce = 1))
    state$last_attack <- -Inf
    attack()
    expect_equal(state$enemy_hit_points[["mushroom"]], 4)
    state$enemy_in_range[["mushroom"]] <- TRUE
    for (i in 1:2) {
      state$last_attack <- -Inf
      attack()
    }
    expect_equal(state$enemy_hit_points[["mushroom"]], 0)
    state$last_damage <- -Inf
    session$setInputs(overlap_hero_mushroom = list(nonce = 3))
    expect_equal(state$life_points, 90)
    session$setInputs(restart = 1)
    expect_equal(state$life_points, 100)
    expect_equal(state$enemy_hit_points[["mushroom"]], 6)
    state$life_points <- 10
    state$last_damage <- -Inf
    session$setInputs(overlap_hero_mushroom = list(nonce = 4))
    expect_equal(state$life_points, 0)
    expect_match(notice(), "Game over")
    state$last_attack <- -Inf
    attack()
    expect_equal(state$enemy_hit_points[["mushroom"]], 6)
    session$setInputs(restart = 2)
    expect_equal(state$life_points, 100)
    expect_false(any(state$enemy_in_range))
  })
})

test_that("skeleton combat is independent and both enemies survive save/load correctly", {
  app <- source(system.file("examples", "swamps_rpg", "app.R", package = "shinyphaser"),
                local = new.env())$value
  shiny::testServer(app$serverFuncSource(), {
    state <- environment(attack)
    session$flushReact()
    session$setInputs(overlap_hero_skeleton = list(nonce = 1))
    expect_equal(state$life_points, 88)
    session$setInputs(overlap_hero_mushroom = list(nonce = 1))
    expect_equal(state$life_points, 88) # Shared hero invulnerability window.
    state$enemy_in_range[["mushroom"]] <- FALSE
    attack()
    expect_equal(state$enemy_hit_points[c("mushroom", "skeleton")], c(mushroom = 6, skeleton = 6))
    session$setInputs(overlap_end_hero_skeleton = list(nonce = 1))
    state$last_attack <- -Inf
    attack()
    expect_equal(state$enemy_hit_points[["skeleton"]], 6)
    state$enemy_in_range[["skeleton"]] <- TRUE
    for (i in 1:3) {
      state$last_attack <- -Inf
      attack()
    }
    expect_equal(state$enemy_hit_points[c("mushroom", "skeleton")], c(mushroom = 6, skeleton = 0))
    state$last_damage <- -Inf
    session$setInputs(overlap_hero_skeleton = list(nonce = 2))
    expect_equal(state$life_points, 88) # Defeated skeleton cannot hurt the hero.
    game$save_game("progress", state = list(realm = "mushroom_swamps", spirit_rescued = FALSE,
      completed = FALSE, life_points = 88, enemy_hit_points = list(mushroom = 4, skeleton = 0)),
      snapshot = list(hero = list(x = 150, y = 150), skeleton = list(x = 1400, y = 800)),
      directory = save_directory)
    session$setInputs(restart = 1)
    expect_equal(state$enemy_hit_points[c("mushroom", "skeleton")], c(mushroom = 6, skeleton = 8))
    session$setInputs(load = 1)
    expect_equal(state$enemy_hit_points[c("mushroom", "skeleton")], c(mushroom = 4, skeleton = 0))
    expect_equal(state$life_points, 88)
    expect_false(any(state$enemy_in_range))
    # One swing must not damage both enemies when contacts overlap.
    session$setInputs(restart = 2)
    state$enemy_in_range[] <- TRUE
    state$last_attack <- -Inf
    attack()
    expect_equal(state$enemy_hit_points[c("mushroom", "skeleton")], c(mushroom = 4, skeleton = 8))
  })
})

test_that("all four skeletons have independent combat state and rescue progress persists", {
  app <- source(system.file("examples", "swamps_rpg", "app.R", package = "shinyphaser"),
                local = new.env())$value
  shiny::testServer(app$serverFuncSource(), {
    state <- environment(attack)
    session$flushReact()
    expect_length(enemies, 5)
    expect_equal(nrow(skeleton_spawns), 4)
    expect_equal(state$enemy_hit_points[skeleton_spawns$id],
      stats::setNames(rep(8, 4), skeleton_spawns$id))
    for (i in 2:4) {
      id <- paste0("skeleton_", i)
      state$last_damage <- -Inf
      event <- stats::setNames(list(list(nonce = i)), paste0("overlap_hero_", id))
      do.call(session$setInputs, event)
      expect_equal(state$life_points, 100 - 12 * (i - 1))
      state$enemy_in_range[] <- FALSE
      state$enemy_in_range[[id]] <- TRUE
      state$last_attack <- -Inf
      attack()
      expect_equal(state$enemy_hit_points[[id]], 6)
    }
    expect_equal(state$enemy_hit_points[["skeleton"]], 8)
    session$setInputs(near_door = list(active = TRUE))
    expect_identical(state$realm, "mushroom_swamps")
    expect_match(notice(), "Rescue the good spirit")
    session$setInputs(near_good_spirit = list(active = TRUE))
    expect_true(state$spirit_rescued)
    session$setInputs(near_door = list(active = TRUE, nonce = 2))
    expect_identical(state$realm, "crypt")
    game$save_game("progress", state = list(realm = "crypt", spirit_rescued = TRUE,
      completed = TRUE, life_points = state$life_points,
      enemy_hit_points = as.list(state$enemy_hit_points)),
      snapshot = list(hero = list(x = 150, y = 350)), directory = save_directory)
    session$setInputs(restart = 1)
    expect_false(state$spirit_rescued)
    expect_equal(state$enemy_hit_points, enemy_max_hit_points)
    session$setInputs(load = 1)
    expect_true(state$spirit_rescued)
    expect_identical(state$realm, "crypt")
    expect_equal(unname(state$enemy_hit_points[paste0("skeleton_", 2:4)]), rep(6, 3))
  })
})
