# Image

Create and manage images in the Phaser scene. Created with
PhaserGame\$add_image() method.

## Methods

### Public methods

- [`Image$new()`](#method-Image-new)

- [`Image$show()`](#method-Image-show)

- [`Image$hide()`](#method-Image-hide)

- [`Image$click()`](#method-Image-click)

- [`Image$clone()`](#method-Image-clone)

------------------------------------------------------------------------

### Method `new()`

Add an image object to the Phaser scene.

#### Usage

    Image$new(
      name,
      url,
      x,
      y,
      visible,
      clickable,
      session = getDefaultReactiveDomain()
    )

#### Arguments

- `name`:

  Character. Unique name of the image.

- `url`:

  Character. URL or path to image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `visible`:

  Logical. Whether image is initially visible.

- `clickable`:

  Logical. Whether image emits click events.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `show()`

Show a previously added image.

#### Usage

    Image$show()

------------------------------------------------------------------------

### Method `hide()`

Hide a previously added image.

#### Usage

    Image$hide()

------------------------------------------------------------------------

### Method `click()`

Add a click event listener to the image that triggers an R function when
clicked.

#### Usage

    Image$click(event_fun, input)

#### Arguments

- `event_fun`:

  A function.

- `input`:

  Shiny input object.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Image$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
