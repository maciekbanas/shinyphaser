#' @title Sprite
#' @description Create and manage animated sprites in the Phaser scene. Created
#'   with PhaserGame$add_sprite() method.
#' @export
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
    #' @param session Shiny session object.
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

    #' @description Play a loaded animation for the sprite.
    #' @param anim_name Character. Identifier for the animation to play (e.g. "
    #'   move_left").
    #' @param duration Numeric. Optional duration in milliseconds to play the animation
    #'  before reverting to idle (defaults to Inf, which loops indefinitely until another animation is played).
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

    #' @description Stop this sprite's current scripted movement.
    #' @return Invisible; sends a custom message to the client.
    stop_motion = function() {
      send_js(private, sprintf("stopSpriteMotion('%s');", private$name))
    },

    #' @description Show this sprite.
    #' @return Invisible; sends a custom message to the client.
    show = function() {
      send_js(private, sprintf("showObject('%s');", private$name))
    },

    #' @description Hide this sprite.
    #' @return Invisible; sends a custom message to the client.
    hide = function() {
      send_js(private, sprintf("hideObject('%s');", private$name))
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

    #' @description Choose the animation prefix used by player controls.
    #' @param prefix Character. Prefix for idle and directional movement animation keys.
    #' @return Invisible; sends a custom message to the client.
    set_player_animation_prefix = function(prefix) {
      js <- sprintf(
        "setPlayerAnimationPrefix(%s, %s);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE),
        jsonlite::toJSON(prefix, auto_unbox = TRUE)
      )
      send_js(private, js)
    },

    #' @description Make the camera follow this sprite as it moves through the world.
    #' @param lerp_x Numeric. Horizontal interpolation factor from 0 to 1 (default: 1).
    #' @param lerp_y Numeric. Vertical interpolation factor from 0 to 1 (default: 1).
    #' @param round_pixels Logical. Whether to round camera pixels to avoid sub-pixel rendering (default: TRUE).
    follow_camera = function(lerp_x = 1,
                             lerp_y = 1,
                             round_pixels = TRUE) {
      js <- sprintf(
        "followSpriteWithCamera('%s', %f, %f, %s);",
        private$name, lerp_x, lerp_y, tolower(round_pixels)
      )
      send_js(private, js)
    },

    #' @description Stop the camera from following this sprite.
    stop_camera_follow = function() {
      js <- sprintf("stopCameraFollow('%s');", private$name)
      send_js(private, js)
    },

    #' @description Set how much this sprite scrolls with the camera.
    #' @param x Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls with world).
    #' @param y Numeric. Vertical scroll factor. Defaults to `x`.
    set_scroll_factor = function(x, y = x) {
      js <- sprintf("setScrollFactor('%s', %f, %f);", private$name, x, y)
      send_js(private, js)
    },

    #' @description Set the sprite's rendering depth. Objects with a larger
    #'   depth are rendered in front of objects with a smaller depth.
    #' @param depth Numeric. Phaser rendering depth.
    #' @return This sprite object, invisibly, to support method chaining.
    set_depth = function(depth) {
      js <- sprintf("setSpriteDepth('%s', %f);", private$name, depth)
      send_js(private, js)
      invisible(self)
    },

    #' @description Set a collision body size and its offset within the unscaled
    #'   sprite frame. Calls made before the sprite loads are queued.
    #' @param width,height Positive numeric. Body size in frame pixels.
    #' @param offset_x,offset_y Numeric. Offset from the frame's top-left corner.
    #' @return This sprite, invisibly.
    set_body_size = function(width, height, offset_x = 0, offset_y = 0) {
      values <- list(width = width, height = height, offset_x = offset_x, offset_y = offset_y)
      for (key in names(values)) {
        value <- values[[key]]
        if (!is.numeric(value) || length(value) != 1L || !is.finite(value)) {
          stop(key, " must be a finite number.", call. = FALSE)
        }
      }
      if (width <= 0 || height <= 0) stop("width and height must be positive.", call. = FALSE)
      send_js(private, sprintf("setSpriteBodySize(%s, %s, %s, %s, %s);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE), width, height, offset_x, offset_y))
      invisible(self)
    },

    #' @description Continuously set drawing depth to the sprite's y-coordinate
    #'   plus an offset, in the browser. Disable to retain the current depth;
    #'   set_depth() also disables automatic depth sorting.
    #' @param offset Numeric. Vertical distance from the sprite origin to its
    #'   ground point, in world pixels (40 for the example's centered Orc).
    #' @param enabled Logical. Whether to update depth each frame.
    #' @return This sprite, invisibly.
    set_depth_by_y = function(offset = 0, enabled = TRUE) {
      if (!is.numeric(offset) || length(offset) != 1L || !is.finite(offset)) {
        stop("offset must be a finite number.", call. = FALSE)
      }
      if (!is.logical(enabled) || length(enabled) != 1L || is.na(enabled)) {
        stop("enabled must be TRUE or FALSE.", call. = FALSE)
      }
      send_js(private, sprintf("setSpriteDepthByY(%s, %s, %s);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE), offset, tolower(enabled)))
      invisible(self)
    },

    #' @description Set the sprite's velocity in the x direction.
    #' @param x Numeric. Velocity in pixels/second (positive = right, negative =
    #' left).
    set_velocity_x = function(x = 100) {
      js <- sprintf("setVelocityX('%s', %d);",
                    private$name, x)
      send_js(private, js)
    },

    #' @description Set the sprite's velocity in the y direction.
    #' @param x Numeric. Velocity in pixels/second (positive = down, negative =
    #' up).
    set_velocity_y = function(x = 100) {
      js <- sprintf("setVelocityY('%s', %d);",
                    private$name, x)
      send_js(private, js)
    },

    #' @description Set the sprite's velocity in both x and y directions.
    #' @param x Numeric. Velocity in pixels/second (positive = right, negative =
    #'  left).
    #' @param y Numeric. Velocity in pixels/second (positive = down, negative =
    #'  up).
    set_gravity = function(x = 100, y = 100) {
      Sys.sleep(0.1)
      js <- sprintf("setGravity('%s', %d, %d);",
                    private$name, x, y)
      send_js(private, js)
    },

    #' @description Set the sprite's bounce factor.
    #' @param x Numeric. Bounce factor.
    set_bounce = function(x) {
      Sys.sleep(0.1)
      js <- sprintf("setBounce('%s', %f);",
                    private$name, x)
      send_js(private, js)
    },

    #' @description Remove sprite from the scene.
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
      js <- sprintf(
        "window.setTimeout(function() { setSpriteInMotion('%s', %d, %d, %d, %d); }, %f);",
        private$name, dir_x, dir_y, speed, distance, lag * 1000
      )
      send_js(private, js)
    },

    #' @description Start client-side sight checks that make this sprite alert,
    #'   wander while the target is out of range, and approach the target when
    #'   it is in range. This is a reusable browser-side behaviour rather than
    #'   an RPG-specific rule.
    #' @param target_name Character. Name of the target sprite to approach.
    #' @param sight_range Numeric. Maximum distance in pixels at which the target is noticed.
    #' @param speed Numeric. Approach speed in pixels/second.
    #' @param distance Numeric. Distance in pixels to travel for each approach step.
    #' @param check_interval Numeric. Milliseconds between sight checks.
    #' @param alert_duration Numeric. Milliseconds to show the alert while approaching.
    #' @param wander_interval Numeric. Milliseconds between random movements while the target is out of sight.
    start_approach_on_sight = function(target_name,
                                       sight_range,
                                       speed,
                                       distance,
                                       check_interval = 250,
                                       alert_duration = 1200,
                                       wander_interval = 1500) {
      js <- sprintf(
        "startSpriteApproachOnSight(%s, %s, %f, %f, %f, %f, %f, %f);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE),
        jsonlite::toJSON(target_name, auto_unbox = TRUE),
        sight_range, speed, distance, check_interval, alert_duration, wander_interval
      )
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)

#' @title Static Sprite
#' @description Create and manage non-animated sprites in the Phaser scene. Created
#'   with PhaserGame$add_static_sprite() method.
#' @export
StaticSprite <- R6::R6Class(
  classname = "StaticSprite",
  public = list(
    #' @description Add a non-animated static sprite to the scene.
    #' @param name Character. Unique name of the sprite.
    #' @param url Character. URL or path to image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param session Shiny session object.
    initialize = function(name, url, x, y, session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addStaticSprite('%s','%s', %s, %s);",
                    name, url, x, y)
      send_js(private, js)
    },

    #' @description Remove static sprite from the scene.
    destroy = function() {
      js <- sprintf("destroySprite('%s');",
                    private$name)
      send_js(private, js)
    },
    #' @description Show this static sprite.
    #' @return Invisible; sends a custom message to the client.
    show = function() {
      send_js(private, sprintf("showObject('%s');", private$name))
    },
    #' @description Hide this static sprite.
    #' @return Invisible; sends a custom message to the client.
    hide = function() {
      send_js(private, sprintf("hideObject('%s');", private$name))
    },
    #' @description Make the camera follow this static sprite as it moves through the world.
    #' @param lerp_x Numeric. Horizontal interpolation factor from 0 to 1 (default: 1).
    #' @param lerp_y Numeric. Vertical interpolation factor from 0 to 1 (default: 1).
    #' @param round_pixels Logical. Whether to round camera pixels to avoid sub-pixel rendering (default: TRUE).
    follow_camera = function(lerp_x = 1,
                             lerp_y = 1,
                             round_pixels = TRUE) {
      js <- sprintf(
        "followSpriteWithCamera('%s', %f, %f, %s);",
        private$name, lerp_x, lerp_y, tolower(round_pixels)
      )
      send_js(private, js)
    },
    #' @description Stop the camera from following this static sprite.
    stop_camera_follow = function() {
      js <- sprintf("stopCameraFollow('%s');", private$name)
      send_js(private, js)
    },
    #' @description Set how much this static sprite scrolls with the camera.
    #' @param x Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls with world).
    #' @param y Numeric. Vertical scroll factor. Defaults to `x`.
    set_scroll_factor = function(x, y = x) {
      js <- sprintf("setScrollFactor('%s', %f, %f);", private$name, x, y)
      send_js(private, js)
    },
    #' @description Set the static sprite's rendering depth. Objects with a
    #'   larger depth are rendered in front of objects with a smaller depth.
    #' @param depth Numeric. Phaser rendering depth.
    #' @return This static sprite object, invisibly, to support method chaining.
    set_depth = function(depth) {
      js <- sprintf("setSpriteDepth('%s', %f);", private$name, depth)
      send_js(private, js)
      invisible(self)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)
