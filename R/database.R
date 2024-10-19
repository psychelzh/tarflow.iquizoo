#' Fetch result of query from iQuizoo database
#'
#' @param query A character string containing SQL.
#' @param ... Further arguments passed to [DBI::dbConnect()].
#' @param params The parameters to be bound to the query. Default to `NULL`, see
#'   [DBI::dbGetQuery()] for more details.
#' @param group Section identifier in the `default.file`. See
#'   [RMariaDB::MariaDB()] for more information.
#' @return A [data.frame] contains the fetched data.
#' @seealso [fetch_iquizoo_mem()] for a memoised version of this function.
#' @export
fetch_iquizoo <- function(query, ...,
                          params = NULL,
                          group = getOption("tarflow.group")) {
  check_dots_used()
  con <- DBI::dbConnect(RMariaDB::MariaDB(), group = group, ...)
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
#'   `~/.cache/tarflow.iquizoo` with a maximal age of 7 days. If set
#'   `TARFLOW_CACHE` to `"memory"`, the cache will be stored in memory. You can
#'   also set `cache` to a custom cache, see [memoise::memoise()] for more
#'   details.
#' @return A memoised version of [fetch_iquizoo()].
#' @seealso [fetch_iquizoo()] for the original function.
#' @export
fetch_iquizoo_mem <- function(cache = NULL) {
  requireNamespace("digest", quietly = TRUE)
  if (is.null(cache)) {
    cache <- switch(Sys.getenv("TARFLOW_CACHE", "disk"),
      disk = cachem::cache_disk(
        "~/.cache/tarflow.iquizoo",
        max_age = 3600 * 24 * 7 # 7 days
      ),
      memory = cachem::cache_mem()
    )
  }
  memoise::memoise(fetch_iquizoo, cache = cache)
}

# nocov end

#' Fetch data from iQuizoo database
#'
#' This function is a wrapper of [fetch_iquizoo()], which is used as a helper
#' function to fetch data from the iQuizoo database.
#'
#' The data essentially means one of the two types of data: raw data or scores.
#' The raw data is the original data collected from the game, while the scores
#' are the scores calculated by the iQuizoo system. While scores can also be
#' calculated from the raw data, the pre-calculated scores are used to for some
#' quick analysis.
#'
#' The data is separated by project date, so the table name is suffixed by the
#' project date, which is automatically fetched from the database by this
#' function. You could set the format of the date suffix by `suffix_format`,
#' although currently you should not need to change it because it probably will
#' not change in the future. Finally, this suffix should be substituted into the
#' query, which should contain an expression to inject the table name, i.e.,
#' `"{table_name}"`.
#'
#' @param project_id The project id to be bound to the query.
#' @param game_id The game id to be bound to the query.
#' @param ... Further arguments passed to [fetch_iquizoo()].
#' @param what What to fetch. Can be either "raw_data" or "scores".
#' @param query A parameterized SQL query. A default query file is stored in the
#'   package, which is often enough for most cases. You can also specify your
#'   own query file by this argument. See details for more information.
#' @param suffix_format The format of the date suffix. See details for more
#'   information.
#' @return A [data.frame] contains the fetched data.
#' @export
fetch_data <- function(project_id, game_id, ...,
                       what = c("raw_data", "scores"),
                       query = NULL,
                       suffix_format = "%Y0101") {
  check_dots_used()
  what <- match.arg(what)
  # data separated by project date, so we need to get the project date first
  suffix <- package_file("sql", "project_date.sql") |>
    read_file() |>
    fetch_iquizoo(params = project_id) |>
    .subset2("project_date") |>
    format(suffix_format)
  table_name <- paste0(
    switch(what,
      raw_data = "content_orginal_data_",
      scores = "content_ability_score_"
    ),
    suffix
  )
  query <- query %||% read_file(package_file("sql", paste0(what, ".sql")))
  fetch_iquizoo(
    glue::glue(
      query,
      .envir = env(table_name = table_name)
    ),
    ...,
    params = list(project_id, game_id)
  )
}

#' Parse Raw Data
#'
#' Raw data fetched from iQuizoo database is stored in json string format. This
#' function is used to parse raw json string data as [data.frame()] and store
#' them in a list column.
#'
#' @param data The raw data.
#' @param col_raw_json The column name storing raw json string data.
#' @param name_raw_parsed The name used to store parsed data.
#' @return A [data.frame] contains the parsed data.
#' @export
parse_data <- function(data,
                       col_raw_json = "game_data",
                       name_raw_parsed = "raw_parsed") {
  data[[name_raw_parsed]] <- lapply(
    data[[col_raw_json]],
    parse_raw_json
  )
  data[, names(data) != col_raw_json, drop = FALSE]
}

# helper functions
parse_raw_json <- function(jstr) {
  tryCatch(
    jsonlite::fromJSON(jstr),
    error = function(cnd) {
      warn(
        c(
          "Failed to parse json string:",
          conditionMessage(cnd),
          i = "Will parse it as `NULL` instead."
        )
      )
      return()
    }
  )
}
