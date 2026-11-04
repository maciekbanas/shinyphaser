# Deliberate placements make the depth and collision effects easy to find.
# x is the image center; base_y is the bottom of the artwork on the ground.
swamp_scenery <- function() {
  data.frame(
    name = c("tree_1", "tree_2", "bush_1", "bush_2", "bush_3"),
    asset = c("tree_1", "tree_2", "bush_1", "bush_2", "bush_3"),
    x = c(300, 850, 150, 550, 1050),
    base_y = c(450, 430, 690, 590, 450),
    width = c(200, 300, 100, 100, 100),
    height = c(400, 300, 100, 100, 100),
    footprint_width = c(64, 100, 64, 70, 60),
    footprint_height = c(24, 24, 20, 20, 20)
  )
}
