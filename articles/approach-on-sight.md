# Make enemies approach the hero on sight

An enemy can wander until the hero gets close, show an alert, and then
move toward the hero. `Sprite$start_approach_on_sight()` handles these
reactions in the browser, so you do not need an R timer or custom
JavaScript.

![](assets/approaching.gif)

Swamps RPG uses this behavior for its mushroom enemies. With the current
development version of shinyphaser installed, run the game from the
repository root:

``` r

shiny::runApp("inst/examples/swamps_rpg")
```

## Create the hero and an enemy

Here is a complete small app using the artwork bundled with Swamps RPG.
Save it as `app.R` in a Shiny app directory. Move with the arrow keys
and approach the mushroom enemy. It shows a yellow `!` when it notices
the hero.

``` r

library(shiny)
library(shinyphaser)

addResourcePath("approach-assets", system.file(
  "examples", "swamps_rpg", "www", package = "shinyphaser"
))

game <- PhaserGame$new(width = 960, height = 600)
ui <- tagList(
  tags$p("Move with the arrow keys. Get close to the mushroom, then move away."),
  game$use_phaser()
)

server <- function(input, output, session) {
  game <- PhaserGame$new(width = 960, height = 600)
  game$set_shiny_session(session)
  game$set_world_bounds(960, 600)

  hero <- game$add_sprite(
    "hero", "approach-assets/sprites/hero/orc/hero_orc_idle.png",
    x = 120, y = 300, frame_width = 100, frame_height = 100,
    frame_count = 29, frame_rate = 4
  )
  enemy <- game$add_sprite(
    "mushroom", "approach-assets/sprites/enemies/mushroom_man/mushroom_man_idle.png",
    x = 700, y = 300, frame_width = 100, frame_height = 100,
    frame_count = 8, frame_rate = 8
  )

  for (direction in c("left", "right", "up", "down")) {
    hero$add_animation(
      paste0("move_", direction),
      sprintf("approach-assets/sprites/hero/orc/hero_orc_move_%s.png", direction),
      frame_width = 100, frame_height = 100, frame_count = 6, frame_rate = 8
    )
    enemy$add_animation(
      paste0("move_", direction),
      sprintf("approach-assets/sprites/enemies/mushroom_man/mushroom_man_walk_%s.png", direction),
      frame_width = 100, frame_height = 100, frame_count = 2, frame_rate = 8
    )
  }
  hero$add_player_controls(speed = 220)

  status <- game$add_text("Approach the mushroom", "status", 24, 24)
  status$set_scroll_factor(0)
  status$set_depth(10000)
  game$add_overlap("hero", "mushroom", browser_action = browser_actions({
    status$set("Contact! Move away to escape.")
  }))

  enemy$start_approach_on_sight(
    target_name = "hero", sight_range = 300, speed = 100, distance = 60,
    check_interval = 250, alert_duration = 1200, wander_interval = 1500
  )
}

shinyApp(ui, server)
```

The target is identified by the **sprite name**, `"hero"`, rather than
the R variable holding it. Give each enemy a unique name if you create
several. Directional animations use the suffixes `move_left`,
`move_right`, `move_up`, and `move_down`. The runtime selects an
available movement animation, falling back to `move` or `idle` when
directional animations are absent.

## Configure the approach

Call the method once during enemy setup, after binding the game to its
Shiny session. Its sight checks wait until both sprites exist and are
active.

| Argument | Meaning |
|----|----|
| `target_name` | Name passed to `add_sprite()` for the target |
| `sight_range` | Detection radius in pixels, measured between sprite positions |
| `speed` | Movement speed in pixels per second, for approach and wandering |
| `distance` | Maximum length of each movement step in pixels |
| `check_interval` | Milliseconds between detection checks |
| `alert_duration` | Milliseconds over which the yellow `!` fades |
| `wander_interval` | Minimum milliseconds between attempts to wander while out of range |

Use positive values for distances, speed, and timing. A smaller
`distance` produces shorter steps, allowing the enemy to adjust
direction more often. A lower `check_interval` makes detection more
responsive, but does not restart an approach step that is already
running. Calling the method again for the same enemy replaces its
sight-check timer with the new settings.

## Understand the behavior

- **Outside the radius:** the enemy periodically chooses a random
  horizontal or vertical direction and wanders using the configured
  speed and step size.
- **Entering the radius:** the enemy interrupts its wandering movement
  and displays a yellow `!` above its head.
- **While approaching:** the enemy moves toward the hero in steps,
  choosing a new direction between steps. A step is capped at the
  current distance to the hero. Forced animations, such as an attack or
  damage reaction, postpone new approach steps until they finish.
- **Leaving the radius:** the enemy returns to wandering. Re-entering
  the radius can trigger another alert.

Here, “sight” means a distance check. It does not check the enemy’s
facing direction or test whether a wall or tree hides the hero. Movement
is a direct approach, not pathfinding around obstacles. Configure
terrain and collision separately, and do not assume that this method
will find a route through a maze.

## Keep contact and combat separate

Approaching does not automatically damage the hero or end the game. The
small app above uses `add_overlap()` to show a contact message. In a
combat game, a separate server action can update health, with a
throttled sustained overlap:

``` r

# Inside your server, after creating the sprites:
life <- reactiveVal(100)
game$add_overlap(
  "hero", "mushroom", input = input,
  mode = "stay", interval = 1000,
  server_action = function(event) {
    life(max(0, life() - 5))
  }
)
```

This subtracts five health at most once per second while the sprites
overlap. Connect `life()` to your own health display. See [Choose
between browser and server actions](browser-server-actions.md) for more
on splitting immediate feedback from R-side game rules.

To combine enemies with trees and bushes, see [Walk behind scenery and
block its footprint](scenery-and-collision.md). `set_depth_by_y()`
controls their drawing order; it does not change detection range or add
pathfinding.
