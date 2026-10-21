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
- `modules/scenery_layout.R` generates repeatable grass-only tree and bush placements.
- `modules/scenery.R` creates scenery images, their solid footprints, and hero colliders.
- `www/scenery.js` sorts actor depth by foot position and configures the hero's foot-sized body.
- `modules/realms/mushroom_swamps_world.R` contains the swamp enemies, perks, and NPCs.

Modules are sourced into the active Shiny server invocation in the order listed
in `app.R`; this lets callbacks share session state without turning the example
back into one large file.

## Local assets

All maps, terrain, sprites, perks, and sounds live in this example's `www/`
directory. The app explicitly registers `swamps-rpg-assets` and resolves its UI
and modules relative to `app.R`. Keep the entire example directory together.

The map contains five copies of each tree and fifteen of each bush. Their full
image areas stay on grass, with space around existing actors and collectables.
The hero can walk behind the foliage, while invisible footprints block trunks
and bush bases. A fixed random seed keeps the layout consistent across saves.
