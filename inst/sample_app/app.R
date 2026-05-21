library(shiny)
library(shinyphaser)

game <- PhaserGame$new(id = "sample_game", width = 320, height = 240)

ui <- shiny::tagList(
  game$ui()
)

server <- function(input, output, session) {
  game$set_shiny_session(session)

  game$add_image(
    name = "grass",
    url = "assets/hedgehog/terrain/grass.png",
    x = 800,
    y = 300
  )
}

shinyApp(ui, server)
