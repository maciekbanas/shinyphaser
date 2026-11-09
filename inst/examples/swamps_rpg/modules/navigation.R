show_realm <- function(map_key, x, y) {
  combat_generation <<- combat_generation + 1L
  enemy_hurt_until[] <<- -Inf
  lapply(enemies, function(actor) actor$stop_motion())
  enemy_in_range[] <<- FALSE
  realm <<- map_key
  outside <- identical(map_key, "mushroom_swamps")
  visible <- if (outside) clearing_objects else "exit"
  hidden <- if (outside) "exit" else clearing_objects
  if (life_points <= 0) hidden <- union(hidden, "hero") else visible <- union(visible, "hero")
  defeated <- names(enemy_hit_points)[enemy_hit_points <= 0]
  visible <- setdiff(visible, defeated)
  hidden <- union(hidden, defeated)
  if (has_key) {
    visible <- setdiff(visible, "key")
    hidden <- union(hidden, "key")
  }
  game$activate_map(map_key, player_name = "hero", x = x, y = y,
                    visible_objects = visible, hidden_objects = hidden)
}
play_chime <- function() {
  if (isTRUE(input$sound)) chime$play()
}

# Context limits point triggers to their own map. Only entries cause actions.
for (spec in list(
  list(id = "key", x = 650, y = 1090, context = "mushroom_swamps"),
  list(id = "door", x = 1450, y = 150, context = "mushroom_swamps"),
  list(id = "exit", x = 150, y = 500, context = "hut")
)) {
  game$add_proximity_trigger(spec$id, "hero", spec$x, spec$y, radius = 45,
                            context = spec$context, input_id = paste0("near_", spec$id))
}
shiny::observeEvent(input$near_key, {
  if (isTRUE(input$near_key$active) && realm == "mushroom_swamps" && !has_key && life_points > 0) {
    has_key <<- TRUE
    key$hide()
    play_chime()
    notice("Key collected! Enter the blue doorway in the north-east.")
  }
})
shiny::observeEvent(input$near_door, {
  if (isTRUE(input$near_door$active) && realm == "mushroom_swamps") {
    if (has_key && life_points > 0) {
      completed <<- TRUE
      show_realm("hut", 150, 350)
      play_chime()
      notice("You reached the hut! Walk to the blue exit to revisit the clearing, or start a new game.")
    } else notice("The hut is locked. Find the gold key in the south first.")
  }
})
shiny::observeEvent(input$near_exit, {
  if (isTRUE(input$near_exit$active) && realm == "hut") {
    show_realm("mushroom_swamps", 1450, 250)
    notice("Back in the clearing. The key stays with you; the hut remains unlocked.")
  }
})
shiny::observeEvent(input$restart, {
  has_key <<- FALSE
  completed <<- FALSE
  life_points <<- 100
  enemy_hit_points <<- enemy_max_hit_points
  last_attack <<- -Inf
  last_damage <<- -Inf
  update_hud()
  # Restore the wandering enemy as well as the hero and objective.
  game$load_game("initial", directory = save_directory)
  show_realm("mushroom_swamps", 150, 150)
  notice("New game. Find the gold key in the south of the clearing.")
})
# Explicit snapshot avoids depending on asynchronous asset loading at startup.
game$save_game("initial", snapshot = list(
  mushroom = list(x = 650, y = 350, visible = TRUE, active = TRUE),
  skeleton = list(x = 1450, y = 750, visible = TRUE, active = TRUE)
), directory = save_directory)
show_realm("mushroom_swamps", 150, 150)
