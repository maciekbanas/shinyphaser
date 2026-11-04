# Keep scenery generation separate from rendering so placements can be checked.
make_swamp_scenery <- function(map, reserved, seed = 168) {
  old_seed <- get0(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
  on.exit({
    if (is.null(old_seed)) {
      rm(".Random.seed", envir = .GlobalEnv)
    } else {
      assign(".Random.seed", old_seed, envir = .GlobalEnv)
    }
  })
  set.seed(seed)

  terrain <- Filter(function(layer) identical(layer$name, "terrain"), map$layers)[[1]]
  grass_ids <- vapply(Filter(function(tileset) {
    grepl("^mushroom_swamps_grass_", tileset$name)
  }, map$tilesets), function(tileset) tileset$firstgid, numeric(1))
  tiles <- matrix(unlist(terrain$data), nrow = map$height, byrow = TRUE)
  specs <- data.frame(
    asset = c("tree_1", "tree_2", "tree_3", "bush_1", "bush_2", "bush_3"),
    width = c(200, 300, 300, 100, 100, 100),
    height = c(400, 300, 300, 100, 100, 100),
    footprint_width = c(64, 100, 100, 64, 70, 60),
    footprint_height = c(24, 24, 24, 20, 20, 20),
    count = c(5, 5, 5, 15, 15, 15)
  )
  candidates <- expand.grid(
    x = (seq_len(map$width) - 0.5) * map$tilewidth,
    base_y = (seq_len(map$height) - 1) * map$tileheight + 90
  )
  placed <- list()
  for (i in seq_len(nrow(specs))) {
    spec <- specs[i, ]
    choices <- candidates[sample.int(nrow(candidates)), ]
    count <- 0L
    for (j in seq_len(nrow(choices))) {
      x <- choices$x[j]
      base_y <- choices$base_y[j]
      bounds <- c(left = x - spec$width / 2, right = x + spec$width / 2,
                  top = base_y - spec$height, bottom = base_y)
      if (bounds["left"] < 0 || bounds["right"] > map$width * map$tilewidth ||
          bounds["top"] < 0 || bounds["bottom"] > map$height * map$tileheight) next
      columns <- seq(floor(bounds["left"] / map$tilewidth) + 1,
                     floor((bounds["right"] - 1) / map$tilewidth) + 1)
      rows <- seq(floor(bounds["top"] / map$tileheight) + 1,
                  floor((bounds["bottom"] - 1) / map$tileheight) + 1)
      if (!all(tiles[rows, columns] %in% grass_ids)) next
      # Leave room around spawn points, NPCs, enemies and collectables.
      if (any(reserved[, 1] > bounds["left"] - 80 &
              reserved[, 1] < bounds["right"] + 80 &
              reserved[, 2] > bounds["top"] - 80 &
              reserved[, 2] < bounds["bottom"] + 80)) next
      if (any(vapply(placed, function(other) {
        bounds["left"] < other$right + 24 && bounds["right"] > other$left - 24 &&
          bounds["top"] < other$bottom + 24 && bounds["bottom"] > other$top - 24
      }, logical(1)))) next
      count <- count + 1L
      placed[[length(placed) + 1L]] <- data.frame(
        name = paste0(spec$asset, "_", count), asset = spec$asset,
        x = x, y = base_y - spec$height / 2, base_y = base_y,
        width = spec$width, height = spec$height,
        footprint_width = spec$footprint_width,
        footprint_height = spec$footprint_height,
        left = unname(bounds["left"]), right = unname(bounds["right"]),
        top = unname(bounds["top"]), bottom = unname(bounds["bottom"])
      )
      if (count == spec$count) break
    }
    if (count != spec$count) stop("Not enough clear grass for ", spec$asset)
  }
  do.call(rbind, placed)
}
