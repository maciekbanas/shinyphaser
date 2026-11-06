# Swamp clearing (Swamps RPG example)

A short exploration demo: collect the gold key in the south, fight one
mushroom enemy, and reach the blue doorway in the north-east. The doorway leads
to a small hut. Walk to its blue exit to return. Arrow keys move the hero;
press Space at close range to attack. The hero starts with 100 life points;
the mushroom has 6. Three hits defeat it. Contact costs 10 life points at most
once per second. At zero life, use the menu to restart or load a save.

From the repository root, after installing the current shinyphaser version:

```r
shiny::runApp("inst/examples/swamps_rpg")
```

## Features to try

- Walk behind a tree or a bush. Its artwork can hide the hero, while a
  separate invisible footprint blocks only its base. All seven scenery objects
  have fixed placements on grass.
- Approach the mushroom to see its alert and pursuit; move away to let it wander.
- Press Space to attack, with a 0.6-second cooldown. Life points and the
  enemy's remaining health stay visible over the map; the Menu opens over it.
- Hits push the mushroom away by up to 52 pixels and show a damage reaction; the final hit plays the destruction animation
  before the mushroom disappears. Defeated enemies cannot deal damage.
- Collect the key, enter the hut, and return. Map activation changes terrain,
  collisions, camera bounds, and the visibility and physics of scene objects.
- Toggle Sound to enable or mute the short key/doorway chime.
- Save, move somewhere else, then Load. One save slot stores the current map,
  objective progress, life points, enemy health, and hero/enemy positions for
  this browser session.
  Saves are deleted when the Shiny session ends; they are not shared with visitors.
- New game resets the objective and both actors, leaving the save slot available.

The encounter stays small: one enemy, one key, and one hut. The clearing
is 16 by 12 tiles (1600 by 1200 pixels); the hut is 10 by 6 tiles (1000 by 600 pixels).

## Code layout

`ui.R` defines the menu and HUD overlays. `app.R` loads the UI and creates a
separate game for each Shiny session.
Its server sources these focused modules in order:

- `navigation_setup.R`: load the two maps and their embedded tilesets.
- `hero.R`: movement animations, controls, foot-sized body, and depth sorting.
- `scenery_layout.R`: the small, deliberate scenery layout (loaded by `app.R`).
- `scenery.R`: scenery art and footprints, one enemy, markers, and sound.
  Proximity entry/leave events independently select follow/wander movement and
  show/hide an alert.
- `combat.R`: attacks, contact damage, cooldowns, health display, and defeat.
- `navigation.R`: proximity triggers, key/door objective, and restart.
- `saving.R`: save/load using the package's R interface.

All assets live in `www/`. The example registers `swamps-rpg-assets` explicitly.
The maps are generated JSON in Tiled format; use of the Tiled editor is optional.
The game uses the shinyphaser R interface and standard Shiny callbacks without
custom JavaScript.
