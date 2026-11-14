show_realm <- function(map_key, x, y) {
  combat_generation <<- combat_generation + 1L
  enemy_hurt_until[] <<- -Inf
  lapply(enemies, function(actor) actor$stop_motion())
  enemy_in_range[] <<- FALSE
  realm <<- map_key
  outside <- identical(map_key, "mushroom_swamps")
  visible <- if (outside) clearing_objects else crypt_objects
  hidden <- if (outside) crypt_objects else clearing_objects
  if (life_points <= 0) hidden <- union(hidden, "hero") else visible <- union(visible, "hero")
  defeated <- names(enemy_hit_points)[enemy_hit_points <= 0]
  visible <- setdiff(visible, defeated)
  hidden <- union(hidden, defeated)
  if (spirit_rescued) {
    visible <- setdiff(visible, "good_spirit")
    hidden <- union(hidden, "good_spirit")
  }
  game$activate_map(map_key, player_name = "hero", x = x, y = y,
                    visible_objects = visible, hidden_objects = hidden)
}
play_chime <- function() {
  if (isTRUE(input$sound)) chime$play()
}

# Context limits point triggers to their own map. Only entries cause actions.
for (spec in list(
  list(id = "good_spirit", x = 850, y = 150, context = "crypt"),
  list(id = "door", x = 1450, y = 1050, radius = 35, context = "mushroom_swamps"),
  list(id = "exit", x = 150, y = 500, context = "crypt")
)) {
  game$add_proximity_trigger(spec$id, "hero", spec$x, spec$y, radius = if (is.null(spec$radius)) 45 else spec$radius,
                            context = spec$context, input_id = paste0("near_", spec$id))
}
shiny::observeEvent(input$near_good_spirit, {
  if (isTRUE(input$near_good_spirit$active) && realm == "crypt" && !spirit_rescued && life_points > 0) {
    spirit_rescued <<- TRUE
    completed <<- TRUE
    good_spirit$hide()
    update_hud()
    play_chime()
    notice("The mushroom spirit is safe. You won the game!")
    show_objective()
  }
})
shiny::observeEvent(input$near_door, {
  if (isTRUE(input$near_door$active) && realm == "mushroom_swamps" && life_points > 0) {
    show_realm("crypt", 150, 350)
    play_chime()
    notice("Find the mushroom spirit inside the crypt. Watch out for skeletons!")
  }
})
shiny::observeEvent(input$near_exit, {
  if (isTRUE(input$near_exit$active) && realm == "crypt") {
    show_realm("mushroom_swamps", 1450, 1120)
    notice(if (completed) "Back in the clearing. The mushroom spirit is safe; you won!" else
      "Back in the clearing. Enter the crypt to rescue the mushroom spirit.")
  }
})
shiny::observeEvent(input$restart, {
  spirit_rescued <<- FALSE
  completed <<- FALSE
  life_points <<- 100
  enemy_hit_points <<- enemy_max_hit_points
  last_attack <<- -Inf
  last_damage <<- -Inf
  update_hud()
  # Restore the wandering enemy as well as the hero and objective.
  game$load_game("initial", directory = save_directory)
  show_realm("mushroom_swamps", 150, 150)
  notice("New game. Enter the crypt in the south and rescue the mushroom spirit.")
  show_objective()
})
# Explicit snapshot avoids depending on asynchronous asset loading at startup.
initial_positions <- list()
for (i in seq_len(nrow(mushroom_spawns))) {
  spawn <- mushroom_spawns[i, ]
  initial_positions[[spawn$id]] <- list(x = spawn$x, y = spawn$y, visible = TRUE, active = TRUE)
}
for (i in seq_len(nrow(skeleton_spawns))) {
  spawn <- skeleton_spawns[i, ]
  initial_positions[[spawn$id]] <- list(x = spawn$x, y = spawn$y, visible = TRUE, active = TRUE)
}
game$save_game("initial", snapshot = initial_positions, directory = save_directory)
show_realm("mushroom_swamps", 150, 150)
