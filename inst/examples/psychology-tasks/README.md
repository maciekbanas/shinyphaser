# Cognitive task prototypes

Three small test-game examples for exploring cognitive practice and task design:

| Task | What the participant does | What is recorded |
|---|---|---|
| GO / WAIT | Click GO, withhold a click on WAIT | Correct clicks, withholding, commission errors, omissions |
| Find T | Click T among eight L distractors | Target position, selected position, correctness, omissions |
| Repeat a sequence | Watch numbered boxes flash, then click them in order | Presented and entered sequences, correctness, omissions |

From the repository root, with the current shinyphaser installed:

```r
shiny::runApp("inst/examples/psychology-tasks")
```

Choose a task, number of trials, and response window, then click **Start new
run**. The memory task also has an adjustable sequence length. All responses
use clicks or taps on the Phaser canvas. Instructions use words, letters,
and numbers as well as colors. No external game artwork is required.

The tasks are illustrative prototypes, **not validated clinical assessments
or established treatments**. They have no diagnostic cutoffs, normative scores,
or claims about therapeutic outcomes. In particular, the Find T example is a
simple visual-search task, not a validated sustained-attention instrument.

## Behavior and results

- GO / WAIT shuffles a roughly 3:1 mix of GO and WAIT trials. Clicking WAIT is
  a commission error; missing GO is an omission. Successful withholding has no
  response latency.
- Find T randomizes the target position on each trial. The first click ends
  the trial, including an incorrect click.
- Sequence memory presents distinct positions, highlighted for 450 ms with
  200 ms gaps. Input is ignored during presentation. The response window starts
  after presentation and covers the **entire** sequence entry. The first
  incorrect click ends the trial.
- A trial without a completed response times out. Brief feedback precedes the
  next trial. Stimuli and inputs are gated by the current phase.
- **Stop** and changing the task cancel an active trial and invalidate pending
  callbacks. Cancelled trials are marked separately and excluded from accuracy.
  Restarting clears the previous results, so download them first if needed.
- Settings are captured at the start of a run; parameter edits apply to the
  next run. Each browser session has its own task state and results.

The table and CSV contain the task, trial, stimulus, expected response, actual
response, correctness, outcome, UTC recording timestamp, and
`server_latency_ms`. For sequence memory, latency is measured from the end of
presentation to the terminal click, rather than separately for each click.

**Timing is approximate.** The R server starts its clock when it sends the
stimulus, or opens the memory-response phase, and stops when it receives a
response. Network latency, browser rendering, scheduling, and Shiny processing
affect these values. These examples do not measure stimulus-onset timing in
the browser, and are unsuitable for precise reaction-time conclusions.

No participant identifiers are requested. Results are held in memory and are
not automatically saved to disk or uploaded elsewhere. The CSV is generated
only when the user downloads it. Phaser itself loads from jsDelivr.

## How shinyphaser is used

`app.R` creates the canvas with `PhaserGame`, displays cues with
`add_rectangle()` and `add_text()`, sets their drawing order with `set_depth()`,
and handles responses with `Rectangle$click()`. The `show()`, `hide()`, and
`Text$set()` methods reuse existing scene objects between trials. R manages
trial plans, feedback, results, and CSV downloads; `later` schedules presentation
and response deadlines without blocking the Shiny session.

`tasks.R` contains the instructions, randomized task plans, and results schema.
Keep both R files together. No additional R dependencies beyond those listed
by shinyphaser and its suggested `later` package are needed.
