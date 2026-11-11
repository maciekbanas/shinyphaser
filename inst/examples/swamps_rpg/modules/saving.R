# One named slot per Shiny session. Saves disappear when the session closes.
shiny::observeEvent(input$save, {
  game$save_game("progress", state = list(
    realm = realm, spirit_rescued = spirit_rescued, completed = completed,
    life_points = life_points, enemy_hit_points = as.list(enemy_hit_points)
  ), objects = c("hero", names(enemies)), directory = save_directory)
  notice("Save requested. Load restores this session's latest completed save.")
})
shiny::observeEvent(input$load, {
  saves <- game$list_saved_games(directory = save_directory)
  if (!any(vapply(saves, function(save) identical(save$name, "progress"), logical(1)))) {
    notice("No saved progress yet. Press Save first.")
    return()
  }
  lapply(enemies, function(actor) actor$stop_motion())
  state <- game$load_game("progress", directory = save_directory)
  spirit_rescued <<- isTRUE(state$spirit_rescued)
  completed <<- isTRUE(state$completed)
  life_points <<- state$life_points
  saved_health <- unlist(state$enemy_hit_points)
  # Earlier single-enemy checkpoints stored a scalar mushroom health value.
  enemy_hit_points <<- enemy_max_hit_points
  if (is.null(names(saved_health)) && length(saved_health) == 1L) {
    enemy_hit_points[["mushroom"]] <<- saved_health[[1]]
  } else {
    common <- intersect(names(saved_health), names(enemy_hit_points))
    enemy_hit_points[common] <<- saved_health[common]
  }
  last_attack <<- -Inf
  last_damage <<- -Inf
  update_hud()
  position <- state$phaser$objects$hero
  show_realm(state$realm, position$x, position$y)
  notice(if (life_points <= 0) "Loaded: game over. Start a new game or load another checkpoint." else
    if (completed) "Loaded: crypt reached; explore or start a new game." else
    if (spirit_rescued) "Loaded: spirit rescued. Head to the crypt doorway." else
      "Loaded: rescue the good spirit in the south.")
  if (life_points > 0 && !completed) show_objective()
})
