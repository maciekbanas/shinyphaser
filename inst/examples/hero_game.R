devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- shiny::tagList(
  game$ui()
)


server <- function(input, output, session) {

  life_points <- 100

  game$set_shiny_session()

  game$add_image(
    name = "ground",
    url = "assets/hero_game/terrain/ground.png",
    x = 800,
    y = 300
  )
  hero <- game$add_sprite(
    name = "hero",
    url = "assets/hero_game/sprites/hero_idle.png",
    x = 100,
    y = 100,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 7,
    frameRate = 4
  )
  hero$add_player_controls(
    speed = 200
  )
  hero$add_animation(
    suffix = "move_down",
    url = "assets/hero_game/sprites/hero_move_down.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "move_up",
    url = "assets/hero_game/sprites/hero_move_up.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "move_left",
    url = "assets/hero_game/sprites/hero_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "move_right",
    url = "assets/hero_game/sprites/hero_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "attack",
    url = "assets/hero_game/sprites/hero_attack.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 4
  )
  Sys.sleep(0.1)

  game$add_control(
    "Space",
    action = function() {
      hero$play_animation("hero_attack", duration = 1e3)
      are_overlap_skeleton <- game$are_overlap(
        object_one = "hero",
        object_two = "skeleton",
        input = input
      )
      Sys.sleep(0.1)
      are_overlap_wizard <- game$are_overlap(
        object_one = "hero",
        object_two = "wizard",
        input = input
      )
      if (are_overlap_skeleton()) {
        skeleton$destroy()
      }
      if (are_overlap_wizard()) {
        show_wizard_window(game, input)
      }
    },
    input
  )

  life_points_text <- game$add_text(
    text = "life: 100/100",
    id = "life_points",
    x = 1200,
    y = 50
  )

  wizard <- game$add_sprite(
    name = "wizard",
    url = "assets/hero_game/sprites/wizard_idle.png",
    x = 500,
    y = 300,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 17,
    frameRate = 4
  )
  wizard$add_animation(
    suffix = "talk",
    url = "assets/hero_game/sprites/wizard_talk.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 4
  )

  skeleton <- game$add_sprite(
    name = "skeleton",
    url = "assets/hero_game/sprites/skeleton_idle.png",
    x = 700,
    y = 500,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 8,
    frameRate = 4
  )

  skeleton$add_animation(
    suffix = "attack",
    url = "assets/hero_game/sprites/skeleton_attack.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 4
  )

  Sys.sleep(0.1)
  talk_btn <- game$add_rectangle(
    name = "talk_btn",
    y = 600,
    x = 600,
    width = 100,
    height = 40,
    color = '0xffffff',
    visible = FALSE,
    clickable = TRUE
  )
  game$add_overlap(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_btn$show()
      wizard$play_animation("wizard_talk", 2e3)
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_btn$hide()
      wizard$play_animation("wizard_idle")
    },
    input = input
  )

  game$add_overlap(
    object_one = "hero",
    object_two = "skeleton",
    callback_fun = function(evt) {
      print("Skeleton attacks you!")
      skeleton$play_animation("skeleton_attack")
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "skeleton",
    callback_fun = function(evt) {
      print("Skeleton stops.")
      skeleton$play_animation("skeleton_idle")
    },
    input = input
  )

  talk_btn$click(
    event_fun = function(evt) {
      show_wizard_window(game, input)
    },
    input = input
  )
}

show_wizard_window <- function(game, input) {
  redbox <- game$add_rectangle(
    name = "redbox",
    x = 700,
    y = 200,
    width = 400,
    height = 400,
    color = '0xff0000'
  )
}

shiny::shinyApp(ui, server)
