# Hedgehog

Collect apples, avoid enemies, and finish three levels. Move with the arrow
keys; press Space for a short speed boost. Requires `shinyalert` in addition
to shinyphaser's dependencies.

From the repository root, after installing shinyphaser:

```r
shiny::runApp("inst/examples/hedgehog")
```

All game artwork lives in this example's `www/` directory. The app registers
it as `hedgehog-assets` explicitly. Keep the entire
example directory together. The package's simpler sample app shares this artwork.
