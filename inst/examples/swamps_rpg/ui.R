# Menus and status stay over the map, independently of the following camera.
ui <- shiny::fluidPage(
  shiny::tags$style("
    body {margin:0;background:#080d0b;color:#f6e7bd;font-family:Georgia,serif;}
    .container-fluid {padding:0;}
    #game_shell {position:relative;width:min(960px,100vw);margin:24px auto;}
    #phaser_game {width:100% !important;height:auto !important;}
    canvas {display:block;max-width:100%;}
    #game_menu {position:absolute;left:16px;top:16px;z-index:20;}
    #game_menu summary,.menu_panel {padding:12px;border:2px solid #8f7140;
      border-radius:6px;background:rgba(15,22,18,.95);}
    #game_menu summary {cursor:pointer;font:bold 16px sans-serif;}
    .menu_panel {width:210px;margin-top:6px;}
    .menu_panel .btn {display:block;width:100%;margin-bottom:8px;
      background:#202d26;color:#f6e7bd;border-color:#8f7140;}
    #hud {position:absolute;right:16px;top:16px;z-index:10;padding:12px;
      background:rgba(15,22,18,.88);border:2px solid #8f7140;border-radius:6px;}
    #hud progress {display:block;width:180px;height:18px;accent-color:#79b74a;}
    #status {position:absolute;bottom:12px;left:12px;right:12px;z-index:10;
      padding:12px;background:rgba(15,22,18,.88);pointer-events:none;}
    .controls {max-width:960px;margin:auto;padding:0 12px;color:#bcb59e;}
  "),
  shiny::tags$div(id = "game_shell",
    ui_game$use_phaser(),
    shiny::tags$details(id = "game_menu",
      shiny::tags$summary("Menu"),
      shiny::tags$div(class = "menu_panel",
        shiny::strong("SWAMPS RPG"),
        shiny::actionButton("restart", "New game"),
        shiny::actionButton("save", "Save game"),
        shiny::actionButton("load", "Load game"),
        shiny::checkboxInput("sound", "Sound", TRUE)
      )
    ),
    shiny::uiOutput("hud"),
    shiny::textOutput("status")
  ),
  shiny::p(class = "controls", "Arrow keys: move · Space: attack at close range.
    Find the gold key in the south, then enter the blue doorway in the north-east.
    Walk behind trees; their trunks block movement. Menu: restart, save, load, sound.")
)
