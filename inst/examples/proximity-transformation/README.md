# Proximity transformation

From the repository root, with the current shinyphaser version installed:

```r
shiny::runApp("inst/examples/proximity-transformation")
```

Move towards the tree with the arrow keys. Entering a 180-pixel radius hides
its image and shows a prepared monster. `once = TRUE` prevents repeat reactions;
reload the app to reset. Distances use object centers, not artwork boundaries.

The example uses `add_proximity_trigger()` and `browser_actions()`, with no
custom JavaScript or R callback. The monster remains in place: detection and
transformation are separate from pursuit or combat. All assets are local to
this example's `www/` directory.
