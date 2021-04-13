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
    #' @param global A `character` vector. Global variables or functions used in
    #'   the script. For example, there might be a `source()` call to prepare
    #'   functions. `character` used for better formatting. No `unique()` is
    #'   applied.
    #' @param option A `list`. Will be arguments of `tar_option_set()`. Set it
    #'   `NULL` if not needed.
    #' @param targets A `character` vector. Defined targets out of the pipeline
    #'   `list`. `character` used for better formatting. No `unique()` is
    #'   applied.
    #' @param pipeline A `list` of expressions, each of which is a `call` to
    #'   `tar_target()` or its related. This cannot be `NULL` when build.
    initialize = function(package = c("targets", "tarchetypes"),
                          global = NULL,
                          option = NULL,
                          targets = NULL,
                          pipeline = NULL) {
      private$package <- unique(package)
      private$global <- unique(global)
      # option is a `list` with names, making sure its names are unique
      stopifnot(!anyDuplicated(names(option)))
      private$option <- option
      private$targets <- targets
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
      # different when updating option and targets
      stopifnot(!(step == "option" && anyDuplicated(names(codes))))
      if (!step %in% c("option", "targets")) {
        codes <- unique(codes)
      }
      if (append) {
        if (step == "option") {
          # delete old options with repetitive names
          old_option <- private$option
          old_option[names(old_option) %in% names(codes)] <- NULL
          private$option <- c(old_option, codes)
        } else {
          private[[step]] <- unique(c(private[[step]], codes))
        }
      } else {
        private[[step]] <- codes
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
      deparse_call2 <- function(.fn, ...) {
        deparse1(rlang::call2(.fn, ...))
      }
      # global and targets should be strings
      c(
        purrr::map_chr(
          private$package,
          ~ deparse_call2("library", !!!rlang::syms(.x))
        ),
        private$global,
        deparse_call2("tar_option_set", !!!private$option),
        private$targets,
        "list(",
        private$pipeline %>%
          purrr::map_chr(deparse1) %>%
          stringr::str_c(collapse = ",\n"),
        ")"
      )
    }
  )
)
