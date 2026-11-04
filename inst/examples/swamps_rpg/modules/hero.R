hero <- game$add_sprite(
  "hero", asset("sprites/hero/orc/hero_orc_idle.png"),
  x = 150, y = 150, frame_width = 100, frame_height = 100,
  frame_count = 29, frame_rate = 4
)
hero$set_body_size(32, 18, offset_x = 34, offset_y = 72)
hero$set_depth_by_y(offset = 40)
hero$follow_camera()
for (direction in c("down", "up", "left", "right")) {
  hero$add_animation(
    paste0("move_", direction),
    asset(sprintf("sprites/hero/orc/hero_orc_move_%s.png", direction)),
    frame_width = 100, frame_height = 100, frame_count = 6, frame_rate = 8
  )
}
hero$add_player_controls(speed = 220)
game$enable_terrain_collision("hero")
