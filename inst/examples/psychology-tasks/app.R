library(shiny)
library(shinyphaser)

example_dir <- local({
  paths <- vapply(sys.frames(), function(frame) {
    if (is.null(frame$ofile)) "" else as.character(frame$ofile)[1]
  }, character(1))
  paths <- paths[nzchar(paths)]
  if (length(paths)) dirname(normalizePath(tail(paths, 1), mustWork = TRUE)) else getwd()
})
source(file.path(example_dir, "tasks.R"), local = TRUE)

game <- PhaserGame$new(width = 640, height = 360)
ui <- fluidPage(
  tags$head(tags$style(HTML("
    .task-demo { max-width: 960px; margin: 20px auto; }
    #phaser_game { width: 640px !important; height: 360px !important; max-width: 100%; }
    #phaser_game canvas { max-width: 100%; height: auto !important; }
  "))),
  div(class = "task-demo",
    h2("Cognitive task prototypes"),
    p("Three small examples for exploring cognitive practice and task design.",
      "These are not validated clinical assessments or established treatments."),
    selectInput("task", "Task", c(
      "Response inhibition: GO / WAIT" = "go_no_go",
      "Visual attention: find T" = "visual_search",
      "Working memory: repeat a sequence" = "sequence_memory"
    ), selectize = FALSE),
    fluidRow(
      column(4, numericInput("trials", "Trials per run", 8, min = 4, max = 20, step = 1)),
      column(4, numericInput("window_ms", "Response window (ms)", 2500, min = 500, max = 10000, step = 500)),
      column(4, numericInput("span", "Memory sequence length", 3, min = 2, max = 6, step = 1))
    ),
    div(style = "min-height: 60px", textOutput("instructions")),
    p(actionButton("start", "Start new run"), " ", actionButton("stop", "Stop")),
    div(style = "height: 24px", textOutput("progress")),
    div(style = "height: 44px", textOutput("notice")),
    game$use_phaser(),
    h3("This session's results"),
    textOutput("summary"),
    p("Latency is measured at the Shiny server and includes rendering/network delays.",
      "It is not a precise browser reaction-time measure. No normative scores are calculated."),
    tableOutput("results"),
    downloadButton("download", "Download trial CSV"),
    p("Results stay in this session unless you download them. Starting a new run clears the table.")
  )
)

server <- function(input, output, session) {
  game <- PhaserGame$new(width = 640, height = 360)
  game$set_shiny_session(session)
  state <- new.env(parent = emptyenv())
  state$generation <- 0L
  state$running <- FALSE
  state$phase <- "idle"
  state$trial <- 0L
  records <- reactiveVal(empty_task_results())
  notice <- reactiveVal("Choose a task, then start a run.")
  progress <- reactiveVal("Ready")

  go <- game$add_rectangle("go", 320, 180, 150, 150, "0x25824b", visible = FALSE, clickable = TRUE)
  wait <- game$add_rectangle("wait", 320, 180, 150, 150, "0xa43b46", visible = FALSE, clickable = TRUE)
  cue <- game$add_text("", "cue", 245, 160,
                      style = list(fontSize = "36px", color = "#ffffff", fixedWidth = 150, align = "center"), visible = FALSE)
  cue$set_depth(10)
  cells <- lapply(seq_len(9), function(i) {
    x <- 200 + ((i - 1) %% 3) * 120
    y <- 70 + ((i - 1) %/% 3) * 110
    box <- game$add_rectangle(paste0("cell_", i), x, y, 90, 80,
                              "0x36435b", visible = FALSE, clickable = TRUE)
    highlight <- game$add_rectangle(paste0("highlight_", i), x, y, 90, 80,
                                    "0xe3ad39", visible = FALSE)
    highlight$set_depth(5)
    label <- game$add_text("", paste0("label_", i), x - 10, y - 20,
                          style = list(fontSize = "32px", color = "#ffffff"), visible = FALSE)
    label$set_depth(10)
    list(box = box, highlight = highlight, label = label)
  })
  clear_board <- function() {
    go$hide()
    wait$hide()
    cue$hide()
    lapply(cells, function(cell) {
      cell$box$hide()
      cell$highlight$hide()
      cell$label$hide()
    })
  }
  # Every trial, stop or restart invalidates callbacks from the previous phase.
  schedule <- function(callback, delay) {
    generation <- state$generation
    later::later(function() {
      if (session$isClosed() || generation != state$generation) return()
      withReactiveDomain(session, isolate(callback()))
    }, delay)
  }
  record <- function(response, correct, outcome, latency = NA_real_) {
    row <- data.frame(
      task = state$task, trial = state$trial,
      stimulus = paste(state$stimulus, collapse = "-"),
      expected = if (state$task == "go_no_go") {
        if (state$stimulus == "GO") "click" else "withhold"
      } else paste(state$stimulus, collapse = "-"),
      response = response, correct = correct, server_latency_ms = latency,
      outcome = outcome,
      recorded_at_utc = format(Sys.time(), "%Y-%m-%dT%H:%M:%OS3Z", tz = "UTC")
    )
    records(rbind(isolate(records()), row))
  }
  latency <- function() round(1000 * (proc.time()[["elapsed"]] - state$onset))
  finish_trial <- function(response, correct, outcome, elapsed = NA_real_) {
    if (!state$running || state$phase != "response") return()
    record(response, correct, outcome, elapsed)
    state$generation <- state$generation + 1L
    state$phase <- "feedback"
    clear_board()
    notice(if (isTRUE(correct)) "Correct." else "Response recorded. Try the next trial.")
    schedule(next_trial, 0.45)
  }
  response_phase <- function() {
    state$phase <- "response"
    state$onset <- proc.time()[["elapsed"]]
    schedule(function() {
      withheld <- state$task == "go_no_go" && state$stimulus == "WAIT"
      response <- if (withheld) "withhold" else paste(state$response, collapse = "-")
      finish_trial(response, withheld, if (withheld) "withheld" else "omission")
    }, state$window_ms / 1000)
  }
  flash_sequence <- function(i = 1L) {
    if (i > length(state$stimulus)) {
      notice("Your turn: click the boxes in the same order.")
      response_phase()
      return()
    }
    cell <- cells[[state$stimulus[i]]]
    cell$highlight$show()
    schedule(function() {
      cell$highlight$hide()
      schedule(function() flash_sequence(i + 1L), 0.2)
    }, 0.45)
  }
  next_trial <- function() {
    if (state$trial >= length(state$plan)) {
      state$running <- FALSE
      state$phase <- "complete"
      notice("Run complete. You can download the trial table or start again.")
      return()
    }
    state$generation <- state$generation + 1L
    state$trial <- state$trial + 1L
    state$stimulus <- state$plan[[state$trial]]
    state$response <- integer()
    clear_board()
    progress(sprintf("Trial %d / %d", state$trial, length(state$plan)))
    if (state$task == "go_no_go") {
      if (state$stimulus == "GO") go$show() else wait$show()
      cue$set(state$stimulus)
      cue$show()
      notice("GO: click. WAIT: do not click.")
      response_phase()
    } else {
      lapply(seq_len(9), function(i) {
        cell <- cells[[i]]
        cell$box$show()
        cell$label$set(if (state$task == "visual_search") {
          if (i == state$stimulus) "T" else "L"
        } else as.character(i))
        cell$label$show()
      })
      if (state$task == "visual_search") {
        notice("Find T and click its box.")
        response_phase()
      } else {
        state$phase <- "watch"
        notice("Watch the highlighted boxes. Wait for your turn.")
        flash_sequence()
      }
    }
  }
  respond_go <- function(event) {
    if (!state$running || state$phase != "response" || state$task != "go_no_go") return()
    correct <- state$stimulus == "GO"
    finish_trial("click", correct, if (correct) "correct" else "commission", latency())
  }
  go$click(respond_go, input)
  wait$click(respond_go, input)
  lapply(seq_len(9), function(i) {
    force(i)
    cells[[i]]$box$click(function(event) {
      if (!state$running || state$phase != "response" || state$task == "go_no_go") return()
      if (state$task == "visual_search") {
        correct <- i == state$stimulus
        finish_trial(as.character(i), correct, if (correct) "correct" else "incorrect", latency())
      } else {
        state$response <- c(state$response, i)
        correct <- i == state$stimulus[length(state$response)]
        if (!correct || length(state$response) == length(state$stimulus)) {
          finish_trial(paste(state$response, collapse = "-"), correct,
                       if (correct) "correct" else "incorrect", latency())
        }
      }
    }, input)
  })
  stop_run <- function(message = "Run stopped. Completed trials are retained.") {
    if (state$running && state$phase %in% c("watch", "response")) {
      record(paste(state$response, collapse = "-"), NA, "cancelled")
    }
    state$generation <- state$generation + 1L
    state$running <- FALSE
    state$phase <- "idle"
    clear_board()
    notice(message)
  }
  observeEvent(input$start, {
    req(input$task %in% names(task_instructions))
    req(is.finite(input$trials), is.finite(input$window_ms), is.finite(input$span))
    stop_run()
    records(empty_task_results())
    state$task <- input$task
    state$window_ms <- max(500, min(10000, input$window_ms))
    state$plan <- make_task_plan(state$task, max(4, min(20, as.integer(input$trials))),
                                 max(2, min(6, as.integer(input$span))))
    state$trial <- 0L
    state$running <- TRUE
    next_trial()
  })
  observeEvent(input$stop, stop_run())
  observeEvent(input$task, {
    if (state$running && !identical(state$task, input$task)) {
      stop_run("Task changed. Start a new run when ready.")
    }
  }, ignoreInit = TRUE)
  session$onSessionEnded(function() state$generation <- state$generation + 1L)

  output$instructions <- renderText(task_instructions[[input$task]])
  output$notice <- renderText(notice())
  output$progress <- renderText(progress())
  output$results <- renderTable(records(), na = "", striped = TRUE)
  output$summary <- renderText({
    completed <- records()[records()$outcome != "cancelled", ]
    sprintf("Correct trials: %d / %d completed. Cancelled trials are excluded.",
            sum(completed$correct), nrow(completed))
  })
  output$download <- downloadHandler(
    filename = function() paste0("task-trials-", format(Sys.time(), "%Y%m%d-%H%M%S"), ".csv"),
    content = function(file) write.csv(isolate(records()), file, row.names = FALSE, na = "")
  )
}

shinyApp(ui, server)
