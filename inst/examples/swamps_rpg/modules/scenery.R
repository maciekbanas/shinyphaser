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

# Rescue the animated spirit by approaching it.
good_spirit <- game$add_sprite("good_spirit", asset("sprites/npc/good_spirit/good_spirit.png"),
  x = 650, y = 1090, frame_width = 32, frame_height = 32,
  frame_count = 14, frame_rate = 6)
good_spirit$set_depth(1100)
door <- game$add_image("door",
  asset("terrain/mushroom_swamps/crypt_entrance.png"), 1450, 350)
door$set_depth(400) # Sort the arch by its base, like other scenery.
exit <- game$add_rectangle("exit", 150, 550, 80, 70, "0x397bb5", visible = FALSE)
exit$set_depth(100)
clearing_objects <- c(scenery_layout$name, paste0(scenery_layout$name, "_footprint"),
                      "mushroom", "good_spirit", "door")
chime <- game$add_sound("chime", asset("sounds/chime.wav"), volume = 0.3)

for (suffix in c("attack", paste0("attack_", c("left", "right")))) {
  mushroom$add_animation(suffix,
    asset(paste0("sprites/enemies/mushroom_man/mushroom_man_", suffix, ".png")),
    frame_width = 100, frame_height = 100, frame_count = 4, frame_rate = 6)
}
attack_sound <- game$add_sound("attack", asset("sounds/attack.wav"), volume = 0.3)

for (direction in c("down", "up", "left", "right")) {
  mushroom$add_animation(paste0("damage_", direction),
    asset(sprintf("sprites/enemies/mushroom_man/mushroom_man_damage_%s.png", direction)),
    frame_width = 100, frame_height = 100, frame_count = 3, frame_rate = 8)
}
mushroom$add_animation("destroy",
  asset("sprites/enemies/mushroom_man/mushroom_man_destroy.png"),
  frame_width = 100, frame_height = 100, frame_count = 4, frame_rate = 8)
mushroom$add_animation("damage",
  asset("sprites/enemies/mushroom_man/mushroom_man_damage_down.png"),
  frame_width = 100, frame_height = 100, frame_count = 3, frame_rate = 8)

# All four warriors share their artwork but have unique names and combat state.
enemies <- list(mushroom = mushroom)
for (i in seq_len(nrow(skeleton_spawns))) {
  spawn <- skeleton_spawns[i, ]
  id <- spawn$id
  actor <- game$add_sprite(id, asset("sprites/enemies/skeleton/skeleton_idle.png"),
    x = spawn$x, y = spawn$y, frame_width = 100, frame_height = 100,
    frame_count = 10, frame_rate = 6)
  actor$set_body_size(32, 18, offset_x = 34, offset_y = 72)
  actor$set_depth_by_y(offset = 40)
  for (direction in c("left", "right")) {
    for (kind in c("move", "attack")) {
      actor$add_animation(paste0(kind, "_", direction),
        asset(sprintf("sprites/enemies/skeleton/skeleton_%s_%s.png", kind, direction)),
        frame_width = 100, frame_height = 100, frame_count = 2, frame_rate = 6)
    }
  }
  # Generic right-facing animations are the fallback for vertical movement.
  for (kind in c("move", "attack")) {
    actor$add_animation(kind,
      asset(sprintf("sprites/enemies/skeleton/skeleton_%s_right.png", kind)),
      frame_width = 100, frame_height = 100, frame_count = 2, frame_rate = 6)
  }
  actor$add_animation("damage", asset("sprites/enemies/skeleton/skeleton_damage.png"),
    frame_width = 100, frame_height = 100, frame_count = 2, frame_rate = 6)
  game$enable_terrain_collision(id)
  for (name in scenery_layout$name) game$add_collider(id, paste0(name, "_footprint"))
  actor$start_approach_on_sight("hero", sight_range = 240, speed = 75, distance = 45,
    check_interval = 100, wander_interval = 1700)
  enemies[[id]] <- actor
}
clearing_objects <- union(clearing_objects, names(enemies))
