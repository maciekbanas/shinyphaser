test_that("swamp bank tiles have shores on every side adjacent to grass", {
  map <- jsonlite::fromJSON(system.file(
    "examples", "swamps_rpg", "www", "maps", "mushroom_swamps.json",
    package = "shinyphaser"
  ), simplifyVector = FALSE)
  terrain <- Filter(function(layer) layer$name == "terrain", map$layers)[[1]]
  tiles <- matrix(unlist(terrain$data), nrow = map$height, byrow = TRUE)
  ids <- vapply(map$tilesets, function(tile) tile$firstgid, numeric(1))
  tile_names <- vapply(map$tilesets, function(tile) tile$name, character(1))
  grass_ids <- ids[grepl("^mushroom_swamps_grass_", tile_names)]
  steps <- list(top = c(-1, 0), bottom = c(1, 0), left = c(0, -1), right = c(0, 1))

  for (row in seq_len(map$height)) {
    for (column in seq_len(map$width)) {
      gid <- tiles[row, column]
      if (gid %in% grass_ids) next
      expected <- names(Filter(function(step) {
        r <- row + step[1]
        c <- column + step[2]
        # A shore also closes off swamp at the outer boundary of this map.
        r < 1 || r > map$height || c < 1 || c > map$width || tiles[r, c] %in% grass_ids
      }, steps))
      name <- tile_names[match(gid, ids)]
      actual <- if (grepl("_bank_", name)) {
        strsplit(sub(".*_bank_", "", name), "_", fixed = TRUE)[[1]]
      } else {
        character()
      }
      expect_identical(sort(actual), sort(as.character(expected)),
                      info = sprintf("%s at column %d, row %d", name, column, row))
    }
  }
})
