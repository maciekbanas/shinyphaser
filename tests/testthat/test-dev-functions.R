test_that("phaser_create_assets requires an explicit path", {
  expect_error(phaser_create_assets(), "`path` must be supplied", fixed = TRUE)
})

test_that("phaser_create_assets rejects paths that are not directories", {
  not_a_dir <- tempfile("phaser-assets-file-", tmpdir = tempdir())
  expect_true(file.create(not_a_dir))
  on.exit(unlink(not_a_dir), add = TRUE)

  expect_error(
    phaser_create_assets(not_a_dir),
    "`path` exists but is not a directory",
    fixed = TRUE
  )
})

test_that("phaser_create_assets creates assets directory in tempdir", {
  assets_dir <- tempfile("phaser-assets-", tmpdir = tempdir())
  on.exit(unlink(assets_dir, recursive = TRUE), add = TRUE)

  expect_false(dir.exists(assets_dir))

  result <- phaser_create_assets(assets_dir)

  expect_true(dir.exists(assets_dir))
  expect_identical(
    result,
    normalizePath(assets_dir, winslash = "/", mustWork = TRUE)
  )
})

test_that("phaser_create_assets is idempotent in tempdir", {
  assets_dir <- tempfile("phaser-assets-existing-", tmpdir = tempdir())
  dir.create(assets_dir, recursive = TRUE)
  on.exit(unlink(assets_dir, recursive = TRUE), add = TRUE)

  expect_message(
    phaser_create_assets(assets_dir),
    paste0("Directory already exists: ", assets_dir),
    fixed = TRUE
  )
  expect_true(dir.exists(assets_dir))
})

test_that("run_sample_app is available", {
  expect_true(is.function(run_sample_app))
})
