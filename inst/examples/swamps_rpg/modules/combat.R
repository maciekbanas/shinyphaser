# Health and scoring belong to R; Phaser handles animation and movement.
hud <- shiny::reactiveVal(life_points)
update_hud <- function() hud(life_points)
output$hud <- shiny::renderUI({
  life <- hud()
  shiny::tagList(
    shiny::tags$span(sprintf("Life: %d / 100", life)),
    shiny::tags$progress(value = life, max = 100)
  )
})

# Push along the dominant axis, away from the hero's latest contact position.
knockback_from_contact <- function(event) {
  delta <- c(event$x2 - event$x1, event$y2 - event$y1)
  if (length(delta) != 2L || any(!is.finite(delta)) || all(delta == 0)) {
    return(c(x = 0, y = 1))
  }
  if (abs(delta[1]) >= abs(delta[2])) c(x = sign(delta[1]), y = 0) else
    c(x = 0, y = sign(delta[2]))
}
knockback_direction <- lapply(enemies, function(actor) c(x = 0, y = 1))

# Each enemy has independent range, health, hurt state, and knockback direction.
for (enemy_name in names(enemies)) local({
  id <- enemy_name
  actor <- enemies[[id]]
  game$add_overlap("hero", id, input = input, mode = "stay", interval = 1000,
    server_action = function(event) {
      if (realm != "mushroom_swamps" || life_points <= 0 || enemy_hit_points[[id]] <= 0) return()
      enemy_in_range[[id]] <<- TRUE
      knockback_direction[[id]] <<- knockback_from_contact(event)
      now <- as.numeric(Sys.time())
      # One shared hero cooldown prevents simultaneous enemies stacking damage.
      if (now < enemy_hurt_until[[id]] || now - last_damage < 1) return()
      last_damage <<- now
      damage <- if (startsWith(id, "skeleton")) 12 else 10
      life_points <<- max(0, life_points - damage)
      actor$play_animation(paste0(id, "_attack"), duration = if (startsWith(id, "skeleton")) 400 else 700)
      update_hud()
      if (life_points == 0) {
        show_realm("mushroom_swamps", 150, 150)
        notice("Game over. Open Menu to start a new game or load your save.")
        show_dialog("Game over", "Open Menu to start a new game or load your save.", "error")
      } else notice(sprintf("%s hits for %d. Press Space at close range to fight back!",
                            enemy_labels[[id]], damage))
    }
  )
  game$add_overlap_end("hero", id, input = input,
    server_action = function(event) enemy_in_range[[id]] <<- FALSE)
})

attack <- function(event = NULL) {
  if (life_points <= 0 || realm != "mushroom_swamps") return()
  now <- as.numeric(Sys.time())
  if (now - last_attack < 0.6) return()
  last_attack <<- now
  hero$play_animation("hero_attack", duration = 500)
  if (isTRUE(input$sound)) attack_sound$play()
  targets <- names(enemy_in_range)[enemy_in_range & enemy_hit_points > 0]
  if (!length(targets)) {
    notice("Move closer to an enemy to land a hit.")
    return()
  }
  # A swing hits one enemy, in stable list order if both are touching the hero.
  id <- targets[[1]]
  actor <- enemies[[id]]
  enemy_hit_points[[id]] <<- max(0, enemy_hit_points[[id]] - 2)
  actor$stop_motion()
  enemy_hurt_until[[id]] <<- now + 0.5
  actor$set_in_motion(
    dir_x = knockback_direction[[id]][["x"]], dir_y = knockback_direction[[id]][["y"]],
    speed = 130, distance = 52, lag = 0
  )
  actor$play_animation(paste0(id, "_damage"),
    duration = if (enemy_hit_points[[id]] == 0) 1000 else 500)
  update_hud()
  if (enemy_hit_points[[id]] == 0) {
    enemy_in_range[[id]] <<- FALSE
    generation <- combat_generation
    # Only the mushroom has destruction artwork. Skeleton uses its hit reaction.
    if (id == "mushroom") later::later(function() {
      if (session$isClosed() || generation != combat_generation || enemy_hit_points[[id]] > 0) return()
      actor$play_animation("mushroom_destroy", duration = 500)
    }, delay = 0.3)
    later::later(function() {
      if (session$isClosed() || generation != combat_generation || enemy_hit_points[[id]] > 0) return()
      game$activate_map(realm, hidden_objects = id)
    }, delay = if (id == "mushroom") 0.95 else 0.65)
    notice(paste(enemy_labels[[id]], "defeated! Rescue the good spirit and reach the crypt."))
  } else notice(sprintf("Hit! %s loses 2 life points.", enemy_labels[[id]]))
}
game$add_control("Space", input = input, server_action = attack)
