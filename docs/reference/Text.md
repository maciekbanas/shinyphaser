# Text

R6 class to represent a text object in the Phaser scene, allowing
dynamic updates to its content. Created with PhaserGame\$add_text()
method.

## Methods

### Public methods

- [`Text$new()`](#method-Text-new)

- [`Text$set()`](#method-Text-set)

- [`Text$clone()`](#method-Text-clone)

------------------------------------------------------------------------

### Method `new()`

Create a text object in the Phaser scene.

#### Usage

    Text$new(text, id, x, y, style, session = shiny::getDefaultReactiveDomain())

#### Arguments

- `text`:

  Character. Text value to display.

- `id`:

  Character. Unique ID for the text object.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `style`:

  Named list. Styling options passed to Phaser text rendering.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `set()`

Update the text content of this object.

#### Usage

    Text$set(text)

#### Arguments

- `text`:

  Character. New text value to display.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Text$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
