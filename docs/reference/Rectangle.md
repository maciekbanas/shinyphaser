# Rectangle

Create and manage rectangles in the Phaser scene. Created with
PhaserGame\$add_rectangle() method.

## Methods

### Public methods

- [`Rectangle$new()`](#method-Rectangle-new)

- [`Rectangle$show()`](#method-Rectangle-show)

- [`Rectangle$hide()`](#method-Rectangle-hide)

- [`Rectangle$click()`](#method-Rectangle-click)

- [`Rectangle$clone()`](#method-Rectangle-clone)

------------------------------------------------------------------------

### Method `new()`

Add a rectangle object to the Phaser scene.

#### Usage

    Rectangle$new(
      name,
      x,
      y,
      width,
      height,
      color,
      visible,
      clickable,
      session = getDefaultReactiveDomain()
    )

#### Arguments

- `name`:

  Character. Unique name of the rectangle.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `width`:

  Numeric. Rectangle width in pixels.

- `height`:

  Numeric. Rectangle height in pixels.

- `color`:

  Character. Fill color in Phaser-compatible format.

- `visible`:

  Logical. Whether rectangle is initially visible.

- `clickable`:

  Logical. Whether rectangle emits click events.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `show()`

Show a previously added rectangle.

#### Usage

    Rectangle$show()

------------------------------------------------------------------------

### Method `hide()`

Hide a previously added rectangle.

#### Usage

    Rectangle$hide()

------------------------------------------------------------------------

### Method `click()`

Add a click event listener to the rectangle that triggers an R function
when clicked.

#### Usage

    Rectangle$click(event_fun, input)

#### Arguments

- `event_fun`:

  A function.

- `input`:

  Shiny input object.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Rectangle$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
