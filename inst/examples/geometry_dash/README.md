# Geometry Dash-style runner

A small, original one-button obstacle course built with **shinyphaser**.
The cube runs automatically after the first jump. Clear eight spikes and
reach the green finish line. Space, Up, or tapping the canvas jumps; jumping
again requires landing. Use **Restart** after a crash or to replay.

From the repository root, with shinyphaser installed:

```r
shiny::runApp("inst/examples/geometry_dash")
```

`app.R` creates the scene, world gravity, player, floor, spike hitboxes, and
finish through the R API. `browser_actions()` handles jumping, grounded state,
crashes, and completion locally without a Shiny round trip. The small inline
JavaScript only maps taps to the keyboard control and prevents page scrolling.
The original PNG artwork lives in this example's `www/` directory and is
served explicitly by the app. Keep the entire example directory together.
Phaser itself loads from the package's standard jsDelivr dependency, so the
browser needs Internet access. No additional R packages beyond shinyphaser's
dependencies are required.

Change the spike positions, horizontal velocity, jump velocity, or world gravity
in `app.R` to tune the course. Keep the hitboxes inside the visible spikes and
leave enough room between obstacles to land.
