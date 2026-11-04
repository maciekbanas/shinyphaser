test_that("Swamps RPG app and focused modules are packaged", {
  example_dir <- system.file("examples", "swamps_rpg", package = "shinyphaser")
  expect_true(file.exists(file.path(example_dir, "app.R")))
  expect_false(dir.exists(file.path(example_dir, "R")))
  for (module in c("hero", "navigation_setup", "navigation", "scenery", "scenery_layout", "saving")) {
    expect_true(file.exists(file.path(example_dir, "modules", paste0(module, ".R"))))
  }
})
