# Swamp clearing (Swamps RPG example)

Explore a compact clearing, enter the crypt at its southern edge, and rescue
its mushroom spirit to win. Four mushrooms roam the clearing, two skeleton
warriors guard the crypt entrance, and two more wait inside. Arrow keys move
the hero; press Space at close range to attack.

From the repository root, with the current shinyphaser version and its suggested
`shinyalert` package installed:

```r
shiny::runApp("inst/examples/swamps_rpg")
```

Objective instructions appear in `shinyalert` popups. The game pauses while you
read and resumes on Continue. Entering the crypt does not finish the game:
approach the spirit inside to display the victory alert. You can return to the
clearing through the opening in the crypt's south wall.

## Features to try

- Walk behind trees and bushes. Their artwork can hide the hero, while separate
  invisible footprints block their bases. All seven scenery objects sit on grass.
- Approach enemies to see their alert and pursuit; move away to let them wander.
  Only actors belonging to the current map are visible and active.
- Press Space to attack, with a 0.6-second cooldown. A swing hits one living
  enemy in contact, in stable list order. Each mushroom has 6 life points and each
  skeleton has 8; each hit deals 2 damage. Hits push enemies back up to 52 pixels.
  Mushrooms play destruction artwork on defeat; skeletons disappear after their
  damage reaction. Defeated enemies cannot hurt the hero.
- Contact costs 10 (mushroom) or 12 (skeleton) hero life points, with a shared
  one-second damage cooldown. Only the hero's life and bar appear in the HUD.
  At zero life, open Menu to restart or load a save.
- Find the crypt artwork at `(1450, 950)`, sorted by its ground-level base at
  `y = 1050`. An invisible 160 by 24 pixel footprint blocks its base; approach
  the entry trigger in front at `(1450, 1050)`. The entrance is open from the start.
  Map activation switches terrain, collisions, camera bounds, and actor visibility.
- Find the spirit at `(850, 150)` inside the crypt. Collecting it hides the spirit
  and displays a victory popup once. Leaving and returning keeps it collected.
- Toggle Sound to enable the spirit/doorway chime and attack sound.
- Save, move elsewhere, then Load. One session-local save slot stores the map,
  objective progress, life points, enemy health, and hero and enemy positions.
  Saves disappear when the Shiny session ends.
- New game restores all eight enemies, the spirit, health, and the starting map,
  while keeping the save slot available.

The clearing is 16 by 12 tiles (1600 by 1200 pixels); the crypt is 10 by 6 tiles
(1000 by 600 pixels). Two skeletons start near the entrance at `(1350, 1100)` and
`(1450, 750)`; two start inside at `(450, 250)` and `(750, 350)`. Skeletons use
left/right movement and attack sheets, with a fallback for vertical movement.
The spirit sheet uses 14 frames of 32 by 32 pixels, excluding two empty cells.

## Code layout

`ui.R` defines the menu and HUD overlays. `app.R` creates a separate game for each
Shiny session and declares enemy spawns and map membership. Its server sources:

- `navigation_setup.R`: load both maps and their embedded tilesets.
- `hero.R`: controls, animation, foot-sized body, and depth sorting.
- `scenery.R`: scenery, footprints, eight enemies, spirit, doorway, and sound.
- `combat.R`: attacks, map-aware contact damage, cooldowns, health, and defeat.
- `navigation.R`: visibility, proximity triggers, victory, and restart.
- `saving.R`: session-local save/load through the package's R interface.

`scenery_layout.R`, loaded by `app.R`, defines the fixed scenery placements.
All assets live in `www/`, registered under `swamps-rpg-assets`. Maps are generated
Tiled JSON; using the Tiled editor is optional.
