#' TarScript class
#'
#' @description
#'
#' `r lifecycle::badge("experimental")` Stores all the required commands used
#' for pipeline building.
#'
#' @export
TarScript <- R6::R6Class(
  "TarScript",
  cloneable = FALSE,
  private = list(
    package = c("targets", "tarchetypes"),
    global = NULL,
    option = NULL,
    targets = NULL,
    pipeline = NULL,
    path_script = "_targets.R"
  ),
  public = list(
    #' @description
    #'
    #' Create a new [TarScript] object.
    #'
    #' @param package Character vector. The package need to be included in the
    #'   script. Usually only "targets" and "tarchetypes" only. Set it `NULL` if
    #'   not needed.
    #' @param global A `list` of expressions. Global variables or functions used
    #'   in the script. For example, there might be a `source()` call to prepare
    #'   functions.
    #' @param option A `list`. Will be arguments of `tar_option_set()`. Set it
    #'   `NULL` if not needed.
    #' @param targets A `list` of expressions. Defined targets out of the
    #'   pipeline `list`.
    #' @param pipeline A `list` of expressions, each of which is a `call` to
    #'   `tar_target()` or its related. This cannot be `NULL` when build.
    initialize = function(package = c("targets", "tarchetypes"),
                          global = NULL,
                          option = NULL,
                          targets = NULL,
                          pipeline = NULL) {
      private$package <- package
      private$global <- global
      private$option <- option
      private$targets <- targets
      private$pipeline <- pipeline
    },
    #' @description
    #'
    #' Build the targets script. This will update the file "_targets.R" from
    #' current project.
    #'
    #' @param ... For future expansion use and must be empty.
    #' @param styler A logical indicating if styler should be called to make the
    #'   generated file nicer to read. Default is `TRUE`.
    build = function(..., styler = TRUE) {
      if (!missing(...)) {
        ellipsis::check_dots_empty()
      }
      stopifnot(!is.null(private$pipeline))
      c(
        purrr::map(
          private$package,
          ~ rlang::call2("library", !!!rlang::syms(.x))
        ),
        private$global,
        purrr::map(
          private$option,
          ~ rlang::call2("tar_option_set", !!!.x)
        ),
        private$targets,
        rlang::call2("list", !!!private$pipeline)
      ) %>%
        purrr::map_chr(rlang::expr_deparse) %>%
        writeLines(private$path_script)
      if (styler) {
        styler::style_file(private$path_script)
      }
      invisible(self)
    },
    #' @description
    #'
    #' Update a part of the script.
    #'
    #' @param step A character of the updating step name.
    #' @param codes The codes to be added. See details at [TarScript$initialize]
    #'   for the supported format.
    update = function(step, codes) {
      private[[step]] <- codes
      self
    },
    #' @description
    #'
    #' Print object more informative.
    #'
    #' @param ... For future expansion use and must be empty.
    print = function(...) {
      if (!missing(...)) {
        ellipsis::check_dots_empty()
      }
      cat(
        "<TarScript>",
        ifelse(
          is.null(private$pipeline),
          "Note: pipeline is not set yet. Please set it before building.",
          "Awesome! Pipeline has been set. Call build method to build now."
        ),
        sep = "\n"
      )
      invisible(self)
    }
  )
)
