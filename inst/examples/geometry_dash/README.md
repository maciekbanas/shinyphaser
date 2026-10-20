# Geometry Dash-style runner

A small, original one-button obstacle course built with **shinyphaser**.
The cube runs automatically after the first jump. Clear eight spikes and
reach the green finish line. Space, Up, or tapping the canvas jumps; jumping
again requires landing. Use **Restart** after a crash or to replay.

From the repository root, install the package and run:

```r
# In a terminal first: R CMD INSTALL .
shiny::runApp("inst/examples/geometry_dash")
```

Sourcing the file from the repository root also works:

```r
app <- source("inst/examples/geometry_dash/app.R")$value
shiny::runApp(app)
```

Or, after installing the package:

```r
shiny::runApp(system.file("examples", "geometry_dash", package = "shinyphaser"))
```

`app.R` creates the scene, world gravity, player, floor, spike hitboxes, and
finish through the R API. `browser_actions()` handles jumping, grounded state,
crashes, and completion locally without a Shiny round trip. The small inline
JavaScript only maps taps to the keyboard control and prevents page scrolling.
The original PNG artwork is embedded in `app.R`, decoded into a temporary
directory, and served with `shiny::addResourcePath()`. Copying or sourcing the
app does not depend on Shiny automatically serving a `www/` directory. Copies
of the artwork are included in `www/` for reference. No external game assets
are needed.
Phaser itself loads from the package's standard jsDelivr dependency, so the
browser needs Internet access. No additional R packages beyond shinyphaser's
dependencies are required.

Change the spike positions, horizontal velocity, jump velocity, or world gravity
in `app.R` to tune the course. Keep the hitboxes inside the visible spikes and
leave enough room between obstacles to land.
