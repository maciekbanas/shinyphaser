# Simple map

A minimal 8-by-6 tile map with walkable floor, solid walls, and a controllable
orange square. From the repository root, with shinyphaser installed:

```r
shiny::runApp("inst/examples/simple-map")
```

Move with the arrow keys. The complete map and original PNG images are in
`www/`; no file-generation step is needed. In `room.json`, tile ID 1 is floor
and ID 2 is wall. Edit the map in Tiled or change its tile-data array, then
restart the app. The wall tile has the Boolean property `collides = true`.

Keep the entire example directory together. The browser needs Internet access
to load Phaser from the package's standard jsDelivr dependency.
