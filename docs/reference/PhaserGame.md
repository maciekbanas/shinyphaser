# PhaserGame

R6 class to create and manage a Phaser game within a Shiny application.
Provides methods for adding sprites, animations, images, backgrounds,
controls, and collision handling.

## Public fields

- `id`:

  Character. ID of the Game container. Used as the HTML element ID where
  the game canvas will be rendered.

## Methods

### Public methods

- [`PhaserGame$new()`](#method-PhaserGame-new)

- [`PhaserGame$set_shiny_session()`](#method-PhaserGame-set_shiny_session)

- [`PhaserGame$ui()`](#method-PhaserGame-ui)

- [`PhaserGame$add_text()`](#method-PhaserGame-add_text)

- [`PhaserGame$add_player_sprite()`](#method-PhaserGame-add_player_sprite)

- [`PhaserGame$add_sprite_animation()`](#method-PhaserGame-add_sprite_animation)

- [`PhaserGame$add_image()`](#method-PhaserGame-add_image)

- [`PhaserGame$add_map()`](#method-PhaserGame-add_map)

- [`PhaserGame$add_player_controls()`](#method-PhaserGame-add_player_controls)

- [`PhaserGame$enable_terrain_collision()`](#method-PhaserGame-enable_terrain_collision)

- [`PhaserGame$add_static_sprite()`](#method-PhaserGame-add_static_sprite)

- [`PhaserGame$add_static_group()`](#method-PhaserGame-add_static_group)

- [`PhaserGame$add_collider()`](#method-PhaserGame-add_collider)

- [`PhaserGame$add_overlap()`](#method-PhaserGame-add_overlap)

- [`PhaserGame$add_sprite()`](#method-PhaserGame-add_sprite)

- [`PhaserGame$set_sprite_in_motion()`](#method-PhaserGame-set_sprite_in_motion)

- [`PhaserGame$clone()`](#method-PhaserGame-clone)

------------------------------------------------------------------------

### Method `new()`

Create a PhaserGame object with the given configuration.

#### Usage

    PhaserGame$new(id = "phaser_game", width = 800, height = 600)

#### Arguments

- `id`:

  Character. ID of the Game container (defaults to "phaser_game").

- `width`:

  Numeric. Width of the Phaser canvas in pixels (defaults to 800).

- `height`:

  Numeric. Height of the Phaser canvas in pixels (defaults to 600).

#### Returns

A new PhaserGame object.

#### Examples

    game <- PhaserGame$new(id = "my_game", width = 1024, height = 768)

------------------------------------------------------------------------

### Method `set_shiny_session()`

#### Usage

    PhaserGame$set_shiny_session(session = shiny::getDefaultReactiveDomain())

#### Arguments

- `session`:

  Shiny session object (default: shiny::getDefaultReactiveDomain()).

------------------------------------------------------------------------

### Method `ui()`

Load dependencies and initialize the Phaser game in the UI.

#### Usage

    PhaserGame$ui()

#### Returns

HTML tag list containing dependencies and initialization script.

#### Examples

     game$ui()

------------------------------------------------------------------------

### Method `add_text()`

#### Usage

    PhaserGame$add_text(text, id, x, y, style = list(fontSize = "22px"))

------------------------------------------------------------------------

### Method `add_player_sprite()`

Add a player sprite to the scene as an animated spritesheet.

#### Usage

    PhaserGame$add_player_sprite(
      name,
      url,
      x,
      y,
      frameWidth,
      frameHeight,
      frameCount,
      frameRate
    )

#### Arguments

- `name`:

  Character. Unique key for the sprite.

- `url`:

  Character. URL or relative path to the spritesheet image.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `frameWidth`:

  Numeric. Width of each frame in the spritesheet.

- `frameHeight`:

  Numeric. Height of each frame in the spritesheet.

- `frameCount`:

  Numeric. Total number of frames.

- `frameRate`:

  Numeric. Frames per second for the animation.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `add_sprite_animation()`

Load a custom animation for any sprite previously added.

#### Usage

    PhaserGame$add_sprite_animation(
      name,
      suffix,
      url,
      frameWidth,
      frameHeight,
      frameCount,
      frameRate
    )

#### Arguments

- `name`:

  Character. Base key used in add_player_sprite or add_enemy_sprite.

- `suffix`:

  Character. Identifier for this animation (e.g. "move_left").

- `url`:

  Character. URL or path to the spritesheet.

- `frameWidth`:

  Numeric. Width of each frame.

- `frameHeight`:

  Numeric. Height of each frame.

- `frameCount`:

  Numeric. Number of frames in the spritesheet.

- `frameRate`:

  Numeric. Frames per second for playback.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `add_image()`

Adds a static image to the Phaser scene.

#### Usage

    PhaserGame$add_image(imageName, imageUrl, x, y)

#### Arguments

- `imageName`:

  Character. Unique key to reference this image.

- `imageUrl`:

  Character. URL or path to the image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `add_map()`

Add a background (tilemap) layer from Tiled JSON + tileset image(s).

#### Usage

    PhaserGame$add_map(mapKey, mapUrl, tilesetUrls, tilesetNames, layerName)

#### Arguments

- `mapKey`:

  Character. Key for the tilemap JSON.

- `mapUrl`:

  Character. URL of the Tiled JSON file (relative to www/assets/).

- `tilesetUrls`:

  Character vector. URLs of tileset image files.

- `tilesetNames`:

  Character vector. Names of tilesets as defined in Tiled.

- `layerName`:

  Character. Name of the layer to render from Tiled.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `add_player_controls()`

Enable movement controls (arrow keys) for a player sprite.

#### Usage

    PhaserGame$add_player_controls(
      name,
      directions = c("left", "right", "down", "up"),
      speed = 200
    )

#### Arguments

- `name`:

  Character. Name of the player sprite (as added via add_player_sprite).

- `directions`:

  Character vector. Directions to enable (defaults to
  c("left","right","down","up")).

- `speed`:

  Numeric. Movement speed in pixels/second (default: 200).

------------------------------------------------------------------------

### Method `enable_terrain_collision()`

Enable terrain collision for a player sprite.

#### Usage

    PhaserGame$enable_terrain_collision(name)

#### Arguments

- `name`:

  Character. Name of the player sprite (as added via add_player_sprite).

------------------------------------------------------------------------

### Method `add_static_sprite()`

Adds a static sprite to the scene (non-animated).

#### Usage

    PhaserGame$add_static_sprite(name, url, x, y)

#### Arguments

- `name`:

  Character. Unique name of the sprite.

- `url`:

  Character. URL or path to the image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

------------------------------------------------------------------------

### Method `add_static_group()`

Adds a static group to the scene (non-animated).

#### Usage

    PhaserGame$add_static_group(input, name, url)

#### Arguments

- `name`:

  Character. Unique name of the group.

- `url`:

  Character. URL or path to the image file.

------------------------------------------------------------------------

### Method `add_collider()`

Adds a collider between two game objects.

#### Usage

    PhaserGame$add_collider(object_one_name, object_two_name)

#### Arguments

- `object_one_name`:

  Character. Name of the first object.

- `object_two_name`:

  Character. Name of the second object.

------------------------------------------------------------------------

### Method `add_overlap()`

Adds a collider between two game objects.

#### Usage

    PhaserGame$add_overlap(
      object_one_name,
      object_two_name = NULL,
      group_name = NULL,
      callback_fun,
      input
    )

#### Arguments

- `object_one_name`:

  Character. Name of the first object.

- `object_two_name`:

  Character. Name of the second object.

- `group_name`:

  Character. Name of the group.

------------------------------------------------------------------------

### Method `add_sprite()`

Load a base spritesheet and create an "idle" animation.

#### Usage

    PhaserGame$add_sprite(
      name,
      url,
      x,
      y,
      frameWidth,
      frameHeight,
      frameCount,
      frameRate
    )

#### Arguments

- `name`:

  Character. Unique key for the sprite and its idle animation.

- `url`:

  Character. URL or path to the spritesheet image.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `frameWidth`:

  Numeric. Width of each frame.

- `frameHeight`:

  Numeric. Height of each frame.

- `frameCount`:

  Numeric. Number of frames in the spritesheet.

- `frameRate`:

  Numeric. Frames per second for the idle animation.

------------------------------------------------------------------------

### Method `set_sprite_in_motion()`

Move all sprites of a given type along a vector for a set distance.

#### Usage

    PhaserGame$set_sprite_in_motion(
      type,
      dirX,
      dirY,
      speed,
      distance,
      lag = distance/speed
    )

#### Arguments

- `type`:

  Character. Key used in add_sprite().

- `dirX`:

  Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).

- `dirY`:

  Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).

- `speed`:

  Numeric. Speed in pixels/second.

- `distance`:

  Numeric. Distance in pixels to travel before stopping.

- `lag`:

  Numeric. Optional delay before sending the command (defaults to
  distance/speed).

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PhaserGame$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
## ------------------------------------------------
## Method `PhaserGame$new`
## ------------------------------------------------

game <- PhaserGame$new(id = "my_game", width = 1024, height = 768)

## ------------------------------------------------
## Method `PhaserGame$ui`
## ------------------------------------------------

 game$ui()
#> <div id="my_game" style="width:100vw; height:100vh;"></div>
#> <script>initPhaserGame('my_game', {"width":1024,"height":768});</script>
```
