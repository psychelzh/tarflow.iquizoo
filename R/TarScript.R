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
    #'   not needed. And repetitive packages are removed.
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
      private$package <- unique(package)
      private$global <- unique(global)
      private$option <- unique(option)
      private$targets <- unique(targets)
      private$pipeline <- unique(pipeline)
    },
    #' @description
    #'
    #' Build the targets script. This will update the file "_targets.R" from
    #' current project by default.
    #'
    #' @param path A [connection][base::connection], or a character string
    #'   naming the file to print the script. Set to "" to print to the standard
    #'   output. The default is "_targets.R".
    #' @param ... For future expansion use and must be empty.
    #' @param styler A logical indicating if styler should be called to make the
    #'   generated file nicer to read. Default is `TRUE`.
    build = function(path = NULL, ..., styler = TRUE) {
      if (!missing(...)) {
        ellipsis::check_dots_empty()
      }
      stopifnot(!is.null(private$pipeline))
      # prepare commands before pipeline
      script_text <- self$deparse_script()
      if (styler) {
        script_text <- styler::style_text(script_text)
      }
      if (is.null(path)) {
        path = fs::path(usethis::proj_path(), private$path_script)
      }
      cat(script_text, file = path, sep = "\n")
      invisible(self)
    },
    #' @description
    #'
    #' Update a part of the script.
    #'
    #' @param step A character of the updating step name.
    #' @param codes The codes to update. See details at [TarScript$initialize]
    #'   for the supported format.
    #' @param append A logical value indicating if the `codes` are appended to
    #'   the old `step` (`TRUE`) or replaced (`FALSE`).
    update = function(step, codes, append = TRUE) {
      if (append) {
        private[[step]] <- unique(c(private[[step]], codes))
      } else {
        private[[step]] <- unique(codes)
      }
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
    },
    #' @description
    #'
    #' Deparse the whole script to a character vector. Each element of it is a
    #' code line. Note this method does not return the object itself, so it
    #' cannot be chained.
    deparse_script = function() {
      # deparse command before pipeline
      cmds_pre <- c(
        purrr::map(
          private$package,
          ~ rlang::call2("library", !!!rlang::syms(.x))
        ),
        private$global,
        purrr::map(
          private$option,
          ~ rlang::call2("tar_option_set", !!!.x)
        ),
        private$targets
      ) %>%
        purrr::map_chr(rlang::expr_deparse)
      # deparse pipeline, note it is wrapped around a call to `list()`
      cmds_pipeline <- c(
        "list(",
        private$pipeline %>%
          purrr::map_chr(rlang::expr_deparse) %>%
          stringr::str_c(collapse = ",\n"),
        ")"
      )
      c(cmds_pre, cmds_pipeline)
    }
  )
)
