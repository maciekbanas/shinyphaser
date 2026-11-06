proximity_session <- function() {
  messages <- list()
  session <- new.env(parent = emptyenv())
  session$sendCustomMessage <- function(type, message) {
    messages[[length(messages) + 1L]] <<- list(type = type, message = message)
  }
  session$get_messages <- function() messages
  session
}

test_that("object proximity compiles browser actions and validates target choices", {
  session <- proximity_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  hint <- game$add_text("Hello", "hint", 0, 0, visible = FALSE)
  game$add_proximity_trigger("reveal", "hero", target_name = "tree", radius = 100,
    event = "enter", once = TRUE, browser_action = browser_actions({hint$show()}))
  js <- tail(session$get_messages(), 1)[[1]]$message$js
  expect_match(js, '"tree", "enter", true', fixed = TRUE)
  expect_match(js, '"show_text":"hint"', fixed = TRUE)
  expect_match(js, 'null, null, 100', fixed = TRUE)
  expect_error(game$add_proximity_trigger("a", "hero"), "finite x and y")
  expect_error(game$add_proximity_trigger("a", "hero", x = 1, target_name = "tree"), "not both")
  expect_error(game$add_proximity_trigger("a", "hero", 1, NA_real_), "finite x and y")
  expect_error(game$add_proximity_trigger("a", "hero", 1, 2, radius = -1), "radius")
  expect_error(game$add_proximity_trigger("a", "hero", 1, 2, once = NA), "once")
  expect_error(game$add_proximity_trigger("a", "hero", 1, 2, target_name = ""), "target_name")
  expect_error(game$add_proximity_trigger("a", "hero", 1, 2, event = "stay"), "arg")
  expect_error(game$add_proximity_trigger("a", "hero", 1, 2, browser_action = list()), "browser_actions")
  expect_error(game$add_proximity_trigger("a", "hero", 1, 2, server_action = function(e) NULL), "input is required")
})

test_that("proximity server callbacks receive default and explicit input events", {
  shiny::testServer(function(input, output, session) {
    game <- PhaserGame$new()
    game$set_shiny_session(session)
    received <- shiny::reactiveVal(NULL)
    game$add_proximity_trigger("gate", "hero", target_name = "gate",
      input = input, server_action = function(event) received(event))
    game$add_proximity_trigger("exit", "hero", 10, 20, input_id = "legacy_input",
      input = input, server_action = function(event) received(event))
  }, {
    session$flushReact()
    session$setInputs(proximity_gate = list(active = TRUE, event = "enter"))
    expect_identical(received()$event, "enter")
    session$setInputs(legacy_input = list(active = FALSE, event = "leave"))
    expect_false(received()$active)
  })
})

test_that("replacing a trigger replaces its R observer", {
  shiny::testServer(function(input, output, session) {
    game <- PhaserGame$new()
    game$set_shiny_session(session)
    calls <- shiny::reactiveVal(character())
    register <- function(label) {
      game$add_proximity_trigger("gate", "hero", 0, 0, input = input,
        server_action = function(event) calls(c(shiny::isolate(calls()), label)))
    }
    register("old")
  }, {
    session$flushReact()
    register("new")
    session$flushReact()
    session$setInputs(proximity_gate = list(active = TRUE))
    expect_identical(calls(), "new")
  })
})
