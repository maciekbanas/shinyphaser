#' @title Image
#' @description Create and manage images in the Phaser scene. Created with
#'   PhaserGame$add_image() method.
#' @export
Image <- R6::R6Class(
  classname = "Image",
  public = list(
    #' @description Add an image object to the Phaser scene.
    #' @param name Character. Unique name of the image.
    #' @param url Character. URL or path to image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param visible Logical. Whether image is initially visible.
    #' @param clickable Logical. Whether image emits click events.
    #' @param session Shiny session object.
    initialize = function(name, url, x, y, visible, clickable,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addImage('%s', '%s', %d, %d, %s, %s);",
                    name, url, x, y, tolower(visible), tolower(clickable))
      send_js(private, js)
    },
    #' @description Show a previously added image.
    show = function() {
      js <- sprintf("showImage('%s');", private$name)
      send_js(private, js)
    },
    #' @description Hide a previously added image.
    hide = function() {
      js <- sprintf("hideImage('%s');", private$name)
      send_js(private, js)
    },
    #' @description Add a click event listener to the image that triggers an R
    #'   function when clicked.
    #' @param event_fun A function.
    #' @param input Shiny input object.
    click = function(event_fun, input) {
      js <- sprintf("clickImage('%s');", private$name)
      send_js(private, js)
      observe_id <- paste0(private$name, "_click")
      shiny::observeEvent(input[[observe_id]], {
        evt <- input[[observe_id]]
        event_fun(evt)
      }, ignoreNULL = TRUE)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)
