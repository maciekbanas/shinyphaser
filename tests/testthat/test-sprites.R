make_mock_session <- function() {
  msgs <- list()
  env <- new.env(parent = emptyenv())
  env$sendCustomMessage <- function(type, message) {
    msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
  }
  env$get_messages <- function() msgs
  env
}

test_that("Sprite initialize sends null frameCount when omitted", {
  session <- make_mock_session()

  Sprite$new(
    name = "hero",
    url = "hero.png",
    x = 10,
    y = 20,
    frameWidth = 16,
    frameHeight = 16,
    frameRate = 12,
    session = session
  )

  msgs <- session$get_messages()
  expect_length(msgs, 1)
  expect_identical(msgs[[1]]$type, "phaser")
  expect_match(msgs[[1]]$message$js, "addSprite\\(\"hero\", \"hero.png\", 10, 20, 16, 16, null, 12\\);")
})

test_that("Sprite add_animation sends explicit frameCount when provided", {
  session <- make_mock_session()
  sprite <- Sprite$new(
    name = "hero",
    url = "hero.png",
    x = 0,
    y = 0,
    frameWidth = 16,
    frameHeight = 16,
    frameRate = 8,
    session = session
  )

  sprite$add_animation(
    suffix = "run",
    url = "run.png",
    frameWidth = 32,
    frameHeight = 32,
    frameCount = 6,
    frameRate = 24
  )

  msgs <- session$get_messages()
  expect_length(msgs, 2)
  expect_match(msgs[[2]]$message$js, "addSpriteAnimation\\(\"hero\",\"run\",\"run.png\",32,32,6,24\\);")
})
