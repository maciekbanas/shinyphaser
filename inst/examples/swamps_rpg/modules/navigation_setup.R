# Names and image URLs come from the same JSON entries.
for (map_key in c("mushroom_swamps", "hut")) {
  map <- jsonlite::fromJSON(file.path(example_dir, "www", "maps", paste0(map_key, ".json")),
                            simplifyVector = FALSE)
  game$add_map(
    map_key, asset(paste0("maps/", map_key, ".json")),
    tileset_urls = vapply(map$tilesets, function(tile) {
      asset(sub("^../", "", tile$image))
    }, character(1)),
    tileset_names = vapply(map$tilesets, function(tile) tile$name, character(1)),
    layer_name = "terrain"
  )
}
