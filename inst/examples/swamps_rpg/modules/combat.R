# Health and scoring belong to R; Phaser handles animation and movement.
hud <- shiny::reactiveVal(list(life = life_points, enemy = enemy_hit_points))
update_hud <- function() hud(list(life = life_points, enemy = enemy_hit_points))
output$hud <- shiny::renderUI({
  state <- hud()
  shiny::tagList(
    shiny::tags$span(sprintf("Life: %d / 100", state$life)),
    shiny::tags$progress(value = state$life, max = 100),
    shiny::tags$small(if (state$enemy > 0) sprintf("Mushroom: %d / 6", state$enemy) else
      "Mushroom defeated")
  )
})

# Browser throttling reduces traffic; the R clock also guards damage and attacks.
game$add_overlap("hero", "mushroom", input = input, mode = "stay", interval = 1000,
  server_action = function(event) {
    if (realm != "mushroom_swamps" || life_points <= 0 || enemy_hit_points <= 0) return()
    enemy_in_range <<- TRUE
    now <- as.numeric(Sys.time())
    if (now - last_damage < 1) return()
    last_damage <<- now
    life_points <<- max(0, life_points - 10)
    mushroom$play_animation("mushroom_attack", duration = 700)
    update_hud()
    if (life_points == 0) {
      show_realm("mushroom_swamps", 150, 150)
      notice("Game over. Open Menu to start a new game or load your save.")
    } else notice("The mushroom hits for 10. Press Space at close range to fight back!")
  }
)
game$add_overlap_end("hero", "mushroom", input = input,
  server_action = function(event) enemy_in_range <<- FALSE)

attack <- function(event = NULL) {
  if (life_points <= 0 || realm != "mushroom_swamps") return()
  now <- as.numeric(Sys.time())
  if (now - last_attack < 0.6) return()
  last_attack <<- now
  hero$play_animation("hero_attack", duration = 500)
  if (isTRUE(input$sound)) attack_sound$play()
  if (!enemy_in_range || enemy_hit_points <= 0) {
    notice("Move closer to the mushroom to land a hit.")
    return()
  }
  enemy_hit_points <<- max(0, enemy_hit_points - 2)
  mushroom$stop_motion()
  update_hud()
  if (enemy_hit_points == 0) {
    enemy_in_range <<- FALSE
    # Map visibility also disables the defeated enemy's physics body.
    game$activate_map(realm, hidden_objects = "mushroom")
    notice("Mushroom defeated! Find the gold key and reach the hut.")
  } else notice("Hit! The mushroom loses 2 life points.")
}
game$add_control("Space", input = input, server_action = attack)
