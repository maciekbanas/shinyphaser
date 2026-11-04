# Swamp clearing (Swamps RPG example)

A short exploration demo: collect the gold key in the south-west, avoid one
mushroom enemy, and reach the blue doorway in the north-east. The doorway leads
to a small hut. Walk to its blue exit to return. Arrow keys move the hero;
contact with the mushroom resets your position while keeping the key.

From the repository root, after installing the current shinyphaser version:

```r
shiny::runApp("inst/examples/swamps_rpg")
```

## Features to try

- Walk behind either tree or a bush. Its artwork can hide the hero, while a
  separate invisible footprint blocks only its base. All five scenery objects
  have fixed placements on grass.
- Approach the mushroom to see its alert and pursuit; move away to let it wander.
- Collect the key, enter the hut, and return. Map activation changes terrain,
  collisions, camera bounds, and the visibility and physics of scene objects.
- Toggle Sound to enable or mute the short key/doorway chime.
- Save, move somewhere else, then Load. One save slot stores the current map,
  objective progress, and hero/enemy positions for this browser session.
  Saves are deleted when the Shiny session ends; they are not shared with visitors.
- New game resets the objective and both actors, leaving the save slot available.

There is no combat, health system, dialogue, or multi-stage quest. The clearing
is 12 by 8 tiles (1200 by 800 pixels); the hut is 10 by 6 tiles (1000 by 600 pixels).

## Code layout

`app.R` defines the UI and creates a separate game for each Shiny session.
Its server sources these focused modules in order:

- `navigation_setup.R`: load the two maps and their embedded tilesets.
- `hero.R`: movement animations, controls, foot-sized body, and depth sorting.
- `scenery_layout.R`: the small, deliberate scenery layout (loaded by `app.R`).
- `scenery.R`: scenery art and footprints, one enemy, markers, and sound.
- `navigation.R`: proximity triggers, key/door objective, contact, and restart.
- `saving.R`: save/load using the package's R interface.

All assets live in `www/`. The example registers `swamps-rpg-assets` explicitly.
The maps are generated JSON in Tiled format; use of the Tiled editor is optional.
The game uses the shinyphaser R interface and standard Shiny callbacks without
custom JavaScript.
