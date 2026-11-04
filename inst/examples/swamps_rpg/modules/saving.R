# One named slot per Shiny session. Saves disappear when the session closes.
shiny::observeEvent(input$save, {
  game$save_game("progress", state = list(
    realm = realm, has_key = has_key, completed = completed
  ), objects = c("hero", "mushroom"), directory = save_directory)
  notice("Save requested. Load restores this session's latest completed save.")
})
shiny::observeEvent(input$load, {
  saves <- game$list_saved_games(directory = save_directory)
  if (!any(vapply(saves, function(save) identical(save$name, "progress"), logical(1)))) {
    notice("No saved progress yet. Press Save first.")
    return()
  }
  mushroom$stop_motion()
  state <- game$load_game("progress", directory = save_directory)
  has_key <<- isTRUE(state$has_key)
  completed <<- isTRUE(state$completed)
  position <- state$phaser$objects$hero
  show_realm(state$realm, position$x, position$y)
  notice(if (completed) "Loaded: hut reached; explore or start a new game." else
    if (has_key) "Loaded: key collected. Head to the blue doorway." else
      "Loaded: find the gold key in the south-west.")
})
