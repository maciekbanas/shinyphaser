# Swamps RPG example

From the repository root, after installing shinyphaser:

```r
shiny::runApp("inst/examples/swamps_rpg")
```

The entry point only establishes shared game state and loads focused modules:

- `ui.R` contains menus, styles, and browser-side save controls.
- `modules/game_state.R` contains combat state and status helpers.
- `modules/hero.R` configures the Orc hero sprite and animations.
- `modules/navigation_setup.R` loads the Mushroom Swamps map, while `modules/navigation.R` starts the game directly in that realm.
- `modules/saving.R` owns save/load observers.
- `modules/realms/mushroom_swamps_world.R` contains the swamp enemies, perks, and NPCs.

Modules are sourced into the active Shiny server invocation in the order listed
in `app.R`; this lets callbacks share session state without turning the example
back into one large file.

## Local assets

All maps, terrain, sprites, perks, and sounds live in this example's `www/`
directory. The app explicitly registers `swamps-rpg-assets` and resolves its UI
and modules relative to `app.R`. Keep the entire example directory together.
