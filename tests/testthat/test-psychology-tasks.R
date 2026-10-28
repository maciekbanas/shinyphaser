test_that("cognitive task plans have bounded, inspectable stimuli", {
  env <- new.env(parent = globalenv())
  example_dir <- system.file("examples", "psychology-tasks", package = "shinyphaser")
  sys.source(file.path(example_dir, "tasks.R"), env)
  go <- unlist(env$make_task_plan("go_no_go", 8, 3))
  expect_equal(sum(go == "GO"), 6)
  expect_equal(sum(go == "WAIT"), 2)
  search <- unlist(env$make_task_plan("visual_search", 8, 3))
  expect_length(search, 8)
  expect_true(all(search %in% seq_len(9)))
  memory <- env$make_task_plan("sequence_memory", 8, 3)
  expect_length(memory, 8)
  expect_true(all(vapply(memory, function(x) length(x) == 3 &&
                          !anyDuplicated(x) && all(x %in% seq_len(9)), logical(1))))
  expect_error(env$make_task_plan("unknown", 8, 3), "Unknown task")
})

test_that("task responses are phase-gated and cancelled timers cannot restart a run", {
  app_file <- system.file("examples", "psychology-tasks", "app.R", package = "shinyphaser")
  app <- source(app_file, local = new.env(parent = globalenv()))$value
  shiny::testServer(app$serverFuncSource(), {
    session$setInputs(task = "go_no_go", trials = 4, window_ms = 1000, span = 2, start = 1)
    expect_identical(state$phase, "response")
    expected_correct <- state$stimulus == "GO"
    session$setInputs(go_click = list(nonce = 1))
    expect_equal(nrow(records()), 1)
    expect_identical(records()$correct, expected_correct)
    expect_true(records()$server_latency_ms >= 0)
    # A repeated click during feedback must not add a second result.
    session$setInputs(go_click = list(nonce = 2))
    expect_equal(nrow(records()), 1)
    session$setInputs(stop = 1)
    later::run_now(0.55)
    expect_identical(state$phase, "idle")
    expect_false(state$running)
    expect_equal(state$trial, 1)

    session$setInputs(task = "sequence_memory", start = 2)
    expect_identical(state$phase, "watch")
    session$setInputs(cell_1_click = list(nonce = 3))
    expect_equal(nrow(records()), 0)
    session$setInputs(stop = 2)
    expect_identical(records()$outcome, "cancelled")
    expect_true(is.na(records()$correct))
    later::run_now(0.55)
    expect_identical(state$phase, "idle")

    session$setInputs(task = "visual_search", start = 3)
    target <- state$stimulus
    wrong <- target %% 9 + 1L
    do.call(session$setInputs, setNames(list(list(nonce = 4)), paste0("cell_", wrong, "_click")))
    expect_false(records()$correct)
    expect_identical(records()$outcome, "incorrect")
    session$setInputs(start = 4)
    target <- state$stimulus
    do.call(session$setInputs, setNames(list(list(nonce = 5)), paste0("cell_", target, "_click")))
    expect_true(records()$correct)
    expect_identical(records()$outcome, "correct")
    session$setInputs(stop = 3)
  })
})
