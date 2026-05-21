Sprite <- R6::R6Class(
  classname = "Sprite",
  public = list(
    #' @param name Character. Unique key for the sprite and its idle animation.
    #' @param url Character. URL or path to the spritesheet image.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param frame_width Numeric. Width of each frame.
    #' @param frame_height Numeric. Height of each frame.
    #' @param frame_count Numeric. Number of frames in the spritesheet. If NULL, auto-detect from spritesheet dimensions.
    #' @param frame_rate Numeric. Frames per second for the idle animation.
    initialize = function(name, url, x, y,
                          frame_width, frame_height, frame_count = NULL, frame_rate,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf(
        "addSprite(%s, %s, %d, %d, %d, %d, %s, %d);",
        jsonlite::toJSON(name, auto_unbox = TRUE),
        jsonlite::toJSON(url, auto_unbox = TRUE),
        x, y, frame_width, frame_height,
        if (is.null(frame_count)) "null" else as.character(as.integer(frame_count)),
        frame_rate
      )
      send_js(private, js)
    },
    #' @description Load a custom animation for any sprite previously added.
    #' @param suffix Character. Identifier for this animation (e.g. "move_left").
    #' @param url Character. URL or path to the spritesheet.
    #' @param frame_width Numeric. Width of each frame.
    #' @param frame_height Numeric. Height of each frame.
    #' @param frame_count Numeric. Number of frames in the spritesheet. If NULL, auto-detect from spritesheet dimensions.
    #' @param frame_rate Numeric. Frames per second for playback.
    #' @return Invisible; sends a custom message to the client.
    add_animation = function(suffix, url,
                             frame_width, frame_height,
                             frame_count = NULL, frame_rate) {
      js <- sprintf(
        "addSpriteAnimation(%s,%s,%s,%d,%d,%s,%d);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE),
        jsonlite::toJSON(suffix, auto_unbox = TRUE),
        jsonlite::toJSON(url, auto_unbox = TRUE),
        frame_width, frame_height,
        if (is.null(frame_count)) "null" else as.character(as.integer(frame_count)),
        frame_rate
      )
      send_js(private, js)
    },

    play_animation = function(anim_name, duration = Inf) {
      Sys.sleep(0.1)
      js <- if (is.infinite(duration)) {
        sprintf(
          "playAnimation('%s','%s');",
          private$name, anim_name
        )
      } else {
        sprintf(
          "playAnimationForDuration('%s','%s', %d);",
          private$name, anim_name, duration
        )
      }
      send_js(private, js)
    },

    #' @description Enable movement controls (arrow keys) for a player sprite.
    #' @param directions Character vector. Directions to enable (defaults to c("left","right","down","up")).
    #' @param speed Numeric. Movement speed in pixels/second (default: 200).
    add_player_controls = function(directions = c("left", "right", "down", "up"),
                                   speed = 200) {
      js_dirs <- jsonlite::toJSON(directions, auto_unbox = TRUE)
      js <- sprintf("addPlayerControls('%s', %s, %d);", private$name, js_dirs, speed)
      send_js(private, js)
    },

    set_velocity_x = function(x = 100) {
      js <- sprintf("setVelocityX('%s', %d);",
                    private$name, x)
      send_js(private, js)
    },

    set_velocity_y = function(x = 100) {
      js <- sprintf("setVelocityY('%s', %d);",
                    private$name, x)
      send_js(private, js)
    },

    set_gravity = function(x = 100, y = 100) {
      Sys.sleep(0.1)
      js <- sprintf("setGravity('%s', %d, %d);",
                    private$name, x, y)
      send_js(private, js)
    },

    set_bounce = function(x) {
      Sys.sleep(0.1)
      js <- sprintf("setBounce('%s', %f);",
                    private$name, x)
      send_js(private, js)
    },

    destroy = function() {
      js <- sprintf("destroySprite('%s');",
                    private$name)
      send_js(private, js)
    },

    #' @description Move sprite along a vector for a set distance.
    #' @param dir_x Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).
    #' @param dir_y Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).
    #' @param speed Numeric. Speed in pixels/second.
    #' @param distance Numeric. Distance in pixels to travel before stopping.
    #' @param lag Numeric. Optional delay before sending the command (defaults to distance/speed).
    set_in_motion = function(dir_x,
                             dir_y,
                             speed,
                             distance,
                             lag = distance/speed) {
      Sys.sleep(lag)
      js <- sprintf(
        "setSpriteInMotion('%s', %d, %d, %d, %d);",
        private$name, dir_x, dir_y, speed, distance
      )
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)

StaticSprite <- R6::R6Class(
  classname = "StaticSprite",
  public = list(
    initialize = function(name, url, x, y, session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addStaticSprite('%s','%s', %s, %s);",
                    name, url, x, y)
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)
