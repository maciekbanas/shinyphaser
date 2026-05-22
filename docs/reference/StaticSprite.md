# Static Sprite

Create and manage non-animated sprites in the Phaser scene. Created with
PhaserGame\$add_static_sprite() method.

## Methods

### Public methods

- [`StaticSprite$new()`](#method-StaticSprite-new)

- [`StaticSprite$clone()`](#method-StaticSprite-clone)

------------------------------------------------------------------------

### Method `new()`

Add a non-animated static sprite to the scene.

#### Usage

    StaticSprite$new(name, url, x, y, session = getDefaultReactiveDomain())

#### Arguments

- `name`:

  Character. Unique name of the sprite.

- `url`:

  Character. URL or path to image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    StaticSprite$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
