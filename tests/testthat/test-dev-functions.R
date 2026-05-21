test_that("phaser_create_assets creates assets directory", {
  old_wd <- getwd()
  tmp <- tempfile("phaser-assets-")
  dir.create(tmp)
  setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  expect_false(dir.exists(file.path("inst", "examples", "assets")))

  phaser_create_assets()

  expect_true(dir.exists(file.path("inst", "examples", "assets")))
})

test_that("phaser_create_assets is idempotent", {
  old_wd <- getwd()
  tmp <- tempfile("phaser-assets-")
  dir.create(tmp)
  setwd(tmp)
  on.exit(setwd(old_wd), add = TRUE)

  dir.create(file.path("inst", "examples", "assets"), recursive = TRUE)

  expect_message(
    phaser_create_assets(),
    "Directory already exists: inst/examples/assets"
  )
  expect_true(dir.exists(file.path("inst", "examples", "assets")))
})



test_that("run_sample_app is available", {
  expect_true(is.function(run_sample_app))
})
