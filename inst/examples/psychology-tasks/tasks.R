# Small, inspectable task plans. No clinical norms or patient identifiers.
task_instructions <- c(
  go_no_go = "Click the square when it says GO. Do not click when it says WAIT.",
  visual_search = "Find the letter T among the Ls and click its box.",
  sequence_memory = "Watch the highlighted boxes, then click them in the same order."
)

make_task_plan <- function(task, trials, span) {
  switch(task,
    go_no_go = as.list(sample(rep(c("GO", "GO", "GO", "WAIT"), length.out = trials))),
    visual_search = as.list(sample.int(9, trials, replace = TRUE)),
    sequence_memory = lapply(seq_len(trials), function(i) sample.int(9, span)),
    stop("Unknown task")
  )
}

empty_task_results <- function() {
  data.frame(
    task = character(), trial = integer(), stimulus = character(),
    expected = character(), response = character(), correct = logical(),
    server_latency_ms = numeric(), outcome = character(), recorded_at_utc = character()
  )
}
