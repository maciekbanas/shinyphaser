# Hedgehog

Collect apples, avoid enemies, and finish three levels. Move with the arrow
keys; press Space for a short speed boost. Requires `shinyalert` in addition
to shinyphaser's dependencies.

From the repository root, after installing shinyphaser:

```r
shiny::runApp("inst/examples/hedgehog")
```

Or source the app from any working directory:

```r
app <- source("/path/to/shinyphaser/inst/examples/hedgehog/app.R")$value
shiny::runApp(app)
```

For an installed package:

```r
shiny::runApp(system.file("examples", "hedgehog", package = "shinyphaser"))
```

All game artwork lives in this example's `www/` directory. The app registers
it as `hedgehog-assets` explicitly, including when sourced. Keep the entire
example directory together. The package's simpler sample app shares this artwork.
