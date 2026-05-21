test_that("sample app loads", {
  skip_if_not_installed("shinytest2")

  app <- shinytest2::AppDriver$new(
    app_dir = system.file("sample_app", package = "shinyphaser"),
    name = "sample_app"
  )

  app$wait_for_idle(timeout = 10000)
  app$expect_js("document.getElementById('phaser_game') !== null")
})
