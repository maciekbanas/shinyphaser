test_that("generic sprite movement supports R and compiled browser actions", {
  session <- new.env(parent = emptyenv())
  messages <- list()
  session$sendCustomMessage <- function(type, message) messages[[length(messages) + 1L]] <<- message
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  actor <- game$add_sprite("actor", "actor.png", 0, 0, 10, 10, 1, 1)
  actor$set_movement("follow", "hero", speed = 85)
  expect_match(tail(messages, 1)[[1]]$js, '"mode":"follow","target_name":"hero"', fixed = TRUE)
  game$add_proximity_trigger("follow", "actor", target_name = "hero", event = "enter",
    browser_action = browser_actions({actor$set_movement("follow", "hero", speed = 85)}))
  expect_match(tail(messages, 1)[[1]]$js, '"sprite_movement"', fixed = TRUE)
  game$add_proximity_trigger("wander", "actor", target_name = "hero", event = "leave",
    browser_action = browser_actions({actor$set_movement("wander", speed = 85, distance = 60)}))
  expect_match(tail(messages, 1)[[1]]$js, '"target_name":null,"speed":85,"distance":60', fixed = TRUE)
  expect_error(actor$set_movement("follow"), "target_name")
  expect_error(actor$set_movement("wander", "hero"), "only used")
  expect_error(actor$set_movement("other"), "mode")
  expect_error(actor$set_movement("wander", speed = 0), "speed")
  expect_error(actor$set_movement("wander", distance = Inf), "distance")
  expect_error(actor$set_movement("wander", interval = NA_real_), "interval")
  expect_false("start_approach_on_sight" %in% names(actor))
})
