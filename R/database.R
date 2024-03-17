#' Fetch result of query from iQuizoo database
#'
#' @param query A character string containing SQL.
#' @param ... Further arguments passed to [DBI::dbConnect()].
#' @param params The parameters to be bound to the query. Default to `NULL`, see
#'   [DBI::dbGetQuery()] for more details.
#' @param source The data source from which data is fetched. See
#'   [setup_source()] for details.
#' @return A [data.frame] contains the fetched data.
#' @seealso [fetch_iquizoo_mem()] for a memoised version of this function.
#' @export
fetch_iquizoo <- function(query, ...,
                          params = NULL,
                          source = setup_source()) {
  check_dots_used()
  if (!inherits(source, "tarflow.source")) {
    cli::cli_abort(
      "{.arg source} must be created by {.fun setup_source}.",
      class = "tarflow_bad_source"
    )
  }
  # connect to given database which is pre-configured
  if (!inherits_any(source$driver, c("OdbcDriver", "MariaDBDriver"))) {
    cli::cli_abort(
      "Driver must be either OdbcDriver or MariaDBDriver.",
      class = "tarflow_bad_driver"
    )
  }
  # nocov start
  if (inherits(source$driver, "OdbcDriver")) {
    con <- DBI::dbConnect(source$driver, dsn = source$dsn, ...)
  }
  # nocov end
  if (inherits(source$driver, "MariaDBDriver")) {
    con <- DBI::dbConnect(source$driver, groups = source$groups, ...)
  }
  on.exit(DBI::dbDisconnect(con))
  DBI::dbGetQuery(con, query, params = params)
}

# nocov start

#' Memoised version of [fetch_iquizoo()]
#'
#' This function is a memoised version of [fetch_iquizoo()]. It is useful when
#' the same query is called multiple times or you want to cache the result. See
#' [memoise::memoise()] and [fetch_iquizoo()] for more details.
#'
#' @param cache The cache to be used. Default cache could be configured by
#'   setting the environment variable `TARFLOW_CACHE` to `"disk"` or `"memory"`.
#'   If set `TARFLOW_CACHE` to `"disk"`, the cache will be stored in disk at
#'   `~/.cache/tarflow.iquizoo`. If set `TARFLOW_CACHE` to `"memory"`, the cache
#'   will be stored in memory. You can also set `cache` to a custom cache, see
#'   [memoise::memoise()] for more details.
#' @return A memoised version of [fetch_iquizoo()].
#' @seealso [fetch_iquizoo()] for the original function.
#' @export
fetch_iquizoo_mem <- function(cache = NULL) {
  requireNamespace("digest", quietly = TRUE)
  if (is.null(cache)) {
    cache <- switch(Sys.getenv("TARFLOW_CACHE", "disk"),
      disk = cachem::cache_disk("~/.cache/tarflow.iquizoo"),
      memory = cachem::cache_mem()
    )
  }
  memoise::memoise(fetch_iquizoo, cache = cache)
}

# nocov end

#' Fetch data from iQuizoo database
#'
#' @param query A parameterized SQL query. Note the query should also contain
#'   a `glue` expression to inject the table name, i.e., `"{ table_name }"`.
#' @param project_id The project id to be bound to the query.
#' @param game_id The game id to be bound to the query.
#' @param ... Further arguments passed to [fetch_iquizoo()].
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_data <- function(query, project_id, game_id, ...,
                       what = c("raw_data", "scores")) {
  check_dots_used()
  what <- match.arg(what)
  # the database stores data from each year into a separate table with the
  # suffix of course date with the format "<year>0101"
  suffix <- package_file("sql", "project_date.sql") |>
    read_file() |>
    fetch_iquizoo(params = project_id) |>
    .subset2("project_date") |>
    format("%Y0101")
  table_name <- paste0(
    switch(what,
      raw_data = "content_orginal_data_",
      scores = "content_ability_score_"
    ),
    suffix
  )
  fetch_iquizoo(
    stringr::str_glue(
      query,
      .envir = env(table_name = table_name)
    ),
    ...,
    params = list(project_id, game_id)
  )
}
