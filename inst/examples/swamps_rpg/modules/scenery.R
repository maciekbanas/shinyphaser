  scenery_map <- jsonlite::fromJSON(
    file.path(example_dir, "www", "maps", "mushroom_swamps.json"),
    simplifyVector = FALSE
  )
  reserved_positions <- rbind(
    c(100, 140), c(1600, 840), c(2850, 5890),
    do.call(rbind, lapply(enemy_specs, function(spec) c(spec$x, spec$y))),
    do.call(rbind, berry_specs)
  )
  scenery_layout <- make_swamp_scenery(scenery_map, reserved_positions)
  for (i in seq_len(nrow(scenery_layout))) {
    item <- scenery_layout[i, ]
    art <- game$add_image(
      item$name,
      paste0("swamps-rpg-assets/terrain/mushroom_swamps/", item$asset, ".png"),
      item$x, item$y
    )
    art$set_depth(item$base_y)
    footprint <- paste0(item$name, "_footprint")
    game$add_collision_rectangle(
      footprint, item$x, item$base_y - item$footprint_height / 2,
      item$footprint_width, item$footprint_height
    )
    game$add_collider("hero", footprint)
  }
  mushroom_swamps_objects <- c(
    mushroom_swamps_objects, scenery_layout$name,
    paste0(scenery_layout$name, "_footprint")
  )
  # Ground-space depth keeps actors behind objects above them and in front below.
  session$sendCustomMessage("phaser", list(js = sprintf(
    "configureSwampsScenery(%s);",
    jsonlite::toJSON(c("hero", enemy_names, "wizard", "mushroom_spirit"))
  )))
