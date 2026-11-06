library(shinyphaser)

game <- PhaserGame$new(width = 800, height = 600)
ui <- shiny::tagList(
  shiny::tags$p("Move with the arrow keys. Approach the tree: it turns into a monster.
                 Move away and return: the transformation happens only once. Reload to reset."),
  game$use_phaser()
)
server <- function(input, output, session) {
  game <- PhaserGame$new(width = 800, height = 600)
  game$set_shiny_session(session)
  game$set_world_bounds(800, 600)
  game$add_rectangle("grass", 400, 300, 800, 600, "0x387c3c")$set_depth(-1)
  hero <- game$add_sprite("hero", "player.png", 100, 300,
    frame_width = 32, frame_height = 32, frame_count = 1, frame_rate = 1)
  hero$add_player_controls(speed = 180)
  tree <- game$add_image("tree", "tree.png", 550, 300)
  monster <- game$add_sprite("monster", "monster.png", 550, 300,
    frame_width = 100, frame_height = 100, frame_count = 8, frame_rate = 6)
  monster$hide()
  hint <- game$add_text("Approach the tree", "hint", 20, 20)
  hint$set_depth(1000)
  game$add_proximity_trigger(
    "awaken_tree", "hero", target_name = "tree", radius = 180,
    event = "enter", once = TRUE,
    browser_action = browser_actions({
      tree$hide()
      monster$show()
      hint$set("The tree became a monster!")
    })
  )
}
shiny::shinyApp(ui, server)
