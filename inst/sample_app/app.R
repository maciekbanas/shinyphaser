library(shiny)
library(phaserR)

game <- PhaserGame$new(id = "sample_game", width = 320, height = 240)

ui <- fluidPage(
  game$ui()
)

server <- function(input, output, session) {
  game$set_shiny_session(session)

  game$add_image(
    name = "ground",
    url = "assets/hero_game/terrain/ground.png",
    x = 160,
    y = 120
  )
}

shinyApp(ui, server)
