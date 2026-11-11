# Swamp clearing (Swamps RPG example)

A short exploration demo: rescue the good spirit in the south, face a mushroom
and four skeleton warriors, and reach the crypt entrance in the north-east.
Walk through the opening in its south wall to return. Arrow keys move the hero;
press Space at close range to attack. The hero starts with 100 life points;
the mushroom has 6 and each skeleton has 8. Three hits defeat the mushroom and
four defeat each skeleton. Contact costs 10 (mushroom) or 12 (skeleton) life
points, with one shared one-second damage cooldown. At zero life, use the menu
to restart or load a save.

From the repository root, with the current shinyphaser version and its suggested
`shinyalert` package installed:

```r
shiny::runApp("inst/examples/swamps_rpg")
```

Objective instructions appear in `shinyalert` popups: first rescue the spirit,
then enter the crypt. The game pauses while you read and resumes on Continue.
New game and loading unfinished progress show the appropriate objective again.
Only the hero's life points and bar remain in the top-right HUD. Hit and defeat
animations provide combat feedback; game-over and missing-save messages use popups.

## Features to try

- Walk behind a tree or a bush. Its artwork can hide the hero, while a
  separate invisible footprint blocks only its base. All seven scenery objects
  have fixed placements on grass.
- Approach either enemy to see its alert and pursuit; move away to let it wander.
- Press Space to attack, with a 0.6-second cooldown. Only the hero's life
  points and bar appear over the map; enemies show hit reactions rather than
  health labels. The Menu opens over the map.
- Hits push enemies away by up to 52 pixels and show a damage reaction; the
  final hit plays the destruction animation
  before the mushroom disappears. The skeleton has no destruction sheet and
  disappears after its damage reaction. Defeated enemies cannot deal damage.
- Approach the spirit to rescue it, enter the crypt, and return. The entrance
  artwork sits at `(1450, 350)`, with depth set to its base at `y = 450`.
  An invisible 160 by 24 pixel footprint blocks that base, like the tree and
  bush footprints. The hero can walk behind the upper art, but stays visible
  when approaching the solid base from the front. The entry trigger is in front
  at `(1450, 450)`. The doorway stays sealed until the spirit is safe;
  approaching it beforehand opens a reminder popup. Map activation changes terrain,
  collisions, camera bounds, and the visibility and physics of scene objects.
- Toggle Sound to enable or mute the short spirit/doorway chime.
- Save, move somewhere else, then Load. One save slot stores the current map,
  objective progress, life points, enemy health, and hero and all enemy positions for
  this browser session.
  Saves are deleted when the Shiny session ends; they are not shared with visitors.
- New game resets the objective and the hero and all five enemies, leaving the save slot available.

The encounter stays small: five enemies, one spirit rescue, and one crypt. The clearing
is 16 by 12 tiles (1600 by 1200 pixels); the crypt is 10 by 6 tiles (1000 by 600 pixels).

A swing hits one living enemy in contact. If both are touching the hero, the
mushroom is targeted first. The four skeletons start on grass at `(1450, 750)`,
`(450, 750)`, `(1150, 150)`, and `(850, 1050)`; they use left/right movement and attack sheets, with a
generic fallback for vertical movement.

The spirit sheet uses 14 frames of 32 by 32 pixels; the two empty cells are
excluded. Rescuing it changes the objective state and hides the spirit. Saving
and loading preserves that state; New game brings the spirit back.

## Code layout

`ui.R` defines the menu and HUD overlays. `app.R` loads the UI and creates a
separate game for each Shiny session.
Its server sources these focused modules in order:

- `navigation_setup.R`: load the two maps and their embedded tilesets.
- `hero.R`: movement animations, controls, foot-sized body, and depth sorting.
- `scenery_layout.R`: the small, deliberate scenery layout (loaded by `app.R`).
- `scenery.R`: scenery art and footprints, five enemies, the animated spirit, markers, and sound.
- `combat.R`: attacks, contact damage, cooldowns, health display, and defeat.
- `navigation.R`: proximity triggers, spirit/crypt objective, and restart.
- `saving.R`: save/load using the package's R interface.

All assets live in `www/`. The example registers `swamps-rpg-assets` explicitly.
The maps are generated JSON in Tiled format; use of the Tiled editor is optional.
The game uses the shinyphaser R interface and standard Shiny callbacks without
custom JavaScript.
