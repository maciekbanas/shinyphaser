scenery_layout <- swamp_scenery()
for (i in seq_len(nrow(scenery_layout))) {
  item <- scenery_layout[i, ]
  art <- game$add_image(
    item$name, asset(paste0("terrain/mushroom_swamps/", item$asset, ".png")),
    item$x, item$base_y - item$height / 2
  )
  art$set_depth(item$base_y)
  footprint <- paste0(item$name, "_footprint")
  game$add_collision_rectangle(
    footprint, item$x, item$base_y - item$footprint_height / 2,
    item$footprint_width, item$footprint_height
  )
  game$add_collider("hero", footprint)
}

mushroom <- game$add_sprite(
  "mushroom", asset("sprites/enemies/mushroom_man/mushroom_man_idle.png"),
  x = 650, y = 350, frame_width = 100, frame_height = 100,
  frame_count = 8, frame_rate = 8
)
mushroom$set_body_size(32, 18, offset_x = 34, offset_y = 72)
mushroom$set_depth_by_y(offset = 40)
for (direction in c("down", "up", "left", "right")) {
  mushroom$add_animation(
    paste0("move_", direction),
    asset(sprintf("sprites/enemies/mushroom_man/mushroom_man_walk_%s.png", direction)),
    frame_width = 100, frame_height = 100, frame_count = 2, frame_rate = 8
  )
}
game$enable_terrain_collision("mushroom")
for (name in scenery_layout$name) game$add_collider("mushroom", paste0(name, "_footprint"))
mushroom$start_approach_on_sight(
  "hero", sight_range = 240, speed = 85, distance = 45,
  check_interval = 100, wander_interval = 1500
)

# Simple colored markers keep the objective visible without extra artwork.
key <- game$add_rectangle("key", 650, 1090, 24, 32, "0xffd34e")
key$set_depth(1100)
door <- game$add_rectangle("door", 1450, 150, 70, 70, "0x397bb5")
door$set_depth(100)
exit <- game$add_rectangle("exit", 150, 550, 80, 70, "0x397bb5", visible = FALSE)
exit$set_depth(100)
clearing_objects <- c(scenery_layout$name, paste0(scenery_layout$name, "_footprint"),
                      "mushroom", "key", "door")
chime <- game$add_sound("chime", asset("sounds/chime.wav"), volume = 0.3)

for (suffix in c("attack", paste0("attack_", c("left", "right")))) {
  mushroom$add_animation(suffix,
    asset(paste0("sprites/enemies/mushroom_man/mushroom_man_", suffix, ".png")),
    frame_width = 100, frame_height = 100, frame_count = 4, frame_rate = 6)
}
attack_sound <- game$add_sound("attack", asset("sounds/attack.wav"), volume = 0.3)
