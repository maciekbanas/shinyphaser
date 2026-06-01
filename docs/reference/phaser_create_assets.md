# Create an assets folder

Creates an assets directory at the user-supplied `path` if it doesn't
exist. Useful for storing your game's graphic assets.

## Usage

``` r
phaser_create_assets(path)
```

## Arguments

- path:

  Character. Directory path to create. No default is provided so the
  function does not write to the user's working directory unless a path
  is explicitly supplied.

## Examples

``` r
assets_dir <- file.path(tempdir(), "shinyphaser-assets")
phaser_create_assets(assets_dir)
#> Error in phaser_create_assets(assets_dir): unused argument (assets_dir)
```
