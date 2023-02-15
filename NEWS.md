# tarflow.iquizoo 2.5.1

## Bug Fixes

* Fixed option `"tarflow.driver"` not working.
* Removed `...` argument from `connect_to_db()` for it is just an internal function.

# tarflow.iquizoo 2.5.0

## Breaking Changes

* Now `pickup()` support `drv` argument to specify the database driver. This is useful when you want to specify which database driver to use. For example, you can use `drv = RMariaDB::MariaDB()`.
  * The default is from the value of option `"tarflow.driver"`, which will find the first available driver from `odbc` and `RMariaDB`. If neither of them is available, a message will be prompted to inform user to install one.

# tarflow.iquizoo 2.4.1

## Breaking Changes

* Added a new argument `add_keyword` to `compose_where()` to allow adding keyword `WHERE` to the where clause. This is useful when you want to compose a where clause for a subquery.

# tarflow.iquizoo 2.4.0

## Breaking Changes

* Removed `search_games_mem()` for it will not behave as expected. Especially, `memoise::forget()` will not work. A working version is added in rmarkdown template.

## Misc

* Enhanced code quality.

# tarflow.iquizoo 2.3.2

## Bug Fixes

* Fixed errors caused by `<integer64>` class. Now `data.iquizoo::game_info` and data returned by `pickup()` stores `game_id` as `<integer64>` class from bit64 package, but `tarchetypes::tar_map()` does not support such class, and here we convert it to `<character>` class as a workaround.

# tarflow.iquizoo 2.3.1

## Bug fixes

* Fixed recoverable error message pattern to match more cases.

# tarflow.iquizoo 2.3.0

## Breaking Changes

* Implemented new udpations of data.iquizoo package, and now `input` and `extra` should be configured in `game_info` data from that package.
* Suggests {preproc.iquizoo} 2.4.0 or higher now, because we require the preprocessing functions support `.by` again.

## New Features

* Supported setting custom variable name for parsed raw data.

## Bug Fixes

* Fixed bug of `integer64` type.

# tarflow.iquizoo 2.2.0

## Breaking Changes

* Now `preproc_data()` do not use `purrr::possibly()` to suppress errors.

# tarflow.iquizoo 2.1.0

## Breaking Changes

* Now parsed data are nested into the `data.frame()` of data, which will be more efficient (#50).
* Now `pickup()` support input literal sql query string through argument `query_file`. To be recognized as literal sql query, the string must contains at least one new line.
* Now raw data will also fetch `"game_version"` column.

# tarflow.iquizoo 2.0.0

## Breaking Changes

* Now `preproc_data()` returns `indices` after `tidyr::pivot_longer()`, so the column names are now `"index_name"` and `"score"`, consistent among all games.
* Now `wrangle_data()` also changes character values to lower case.
* A better logic dealing with data preprocessing after preproc.iquizoo functions accept `.input` and `.extra` inputs.

# tarflow.iquizoo 1.0.1

## Internal

* Remove old content from github README.

# tarflow.iquizoo 1.0.0

## Breaking Changes

* `init()` and its related functions were totally removed, which were deprecated in `"0.2.0"` and later.
* `fetch()` and `fetch_single_game()` were renamed as `pickup()` and `pickup_single_game()` to avoid name masking of `DBI::fetch()` (see #45).

## Bug Fixes

* Fix a bug of `preproc_data()` occured when using complex dplyr verbs (see #43).

## Internal

* Added more tests for many core functions except `pickup()` (see #41).

# tarflow.iquizoo 0.2.1

## Breaking Changes

* Adapt to new preproc.iquizoo and data.iquizoo packages.

## Bug Fixes

* Fix a target name problem.

# tarflow.iquizoo 0.2.0

## Breaking Changes

* Now `init()` is deprecated, and rmarkdown template is recommended instead.

## New Features

* Support setting up pipeline in rmarkdown using template (#35).

# tarflow.iquizoo 0.1.10

## Bug Fixes

* Unified user identifier to `'OrganizationUserId'`.

# tarflow.iquizoo 0.1.9

## Bug Fixes

* Fixed an exception when fetching `users` from new version of database. Now `base_grade_class` was obsolete and removed from query.

# tarflow.iquizoo 0.1.8

## Bug Fixes

* Fix exception of encoding issue of SQL query by removing the recoding of user sex.

# tarflow.iquizoo 0.1.7

## Bug Fixes

* Fix an exception caused by new database design of IQUIZOO.

# tarflow.iquizoo 0.1.6

## New Features

* Set `known_only` to `FALSE` when downloading pre-calculated scores (#32).

## Bug Fixes

* Fix an exception when using key as one target (#33).
* Fix an issue of `TarScript()` when there are only one `codes` (thus `unique()` is not necessary to be called) to update.

# tarflow.iquizoo 0.1.5

## New Features

* Add `known_only` argument (default to `TRUE`) to `search_games()`, which uses the games in `dataproc.iquizoo::game_info` only. You cannot set it as `FALSE` when fetching original data.

# tarflow.iquizoo 0.1.4

## New Features

* Add `encoding` argument (default to `"UTF-8"`) to `fetch()`, which is used to set the encoding of SQL query files. This will also fix some encoding issues on Windows OS.

# tarflow.iquizoo 0.1.3

## Bug Fixes

* Correct logic of `step_query()`. The query named `games` are not to be included in targets. And queries named `users` and `abilities` should be always fetched. Other queries depend on whether it is separated or not.

# tarflow.iquizoo 0.1.2

## New Features

* Supported games abilities.

# tarflow.iquizoo 0.1.1

* Adapt to new database design in IQUIZOO.

# tarflow.iquizoo 0.1.0

## Breaking changes

* Moved `wrangle_data()` (#24) to dataproc.iquizoo package now. That is, the data preprocessing parts are all moved to dataproc.iquizoo package now. This better fits our mental models about these packages.

# tarflow.iquizoo 0.0.7

## Breaking changes

* Removed `calc_indices` (#24) and added `wrangle_data()` to fit the jobs for this package. This new function will parse input `json` string and stack them into long format, but keep other meta info in the attribute `"info"` of output. With all these, the output added a subclass `"tbl_meta"` and a `print()` method.

## Enhancements

* Added `fetch_single_game()` to treat special case of fetching dataset from a single game. This is used especially when using branches.
* Unexported `compose_where()` and `insert_where()`, because they are just for usage in current package.

# tarflow.iquizoo 0.0.6

## Bug Fixes

* Use `stringr::str_detect()` to remove empty json string. Now `"[]"` and `"{}"` are both removed.

# tarflow.iquizoo 0.0.5

## Bug Fixes

* Fix issue of empty json string by removing empty (i.e., `"[]"`) json string data in validation step of `calc_indices()`.

# tarflow.iquizoo 0.0.4

## Bug Fixes

* Fix issue of invalid json string by introducing a data validation step in `calc_indices()`.

# tarflow.iquizoo 0.0.3

## Bug Fixes

* Fix an issue of data name case, and now all the names are translated to lower-case ones before preprocessing.

# tarflow.iquizoo 0.0.2

## New Features

* New feature is introduced with a huge change that `use_targets()` has been removed. And `init()` is used to replace it. With this function, we can define many other schemas. Maybe in future, the logic should be modified to better handle schemas.

# tarflow.iquizoo 0.0.1

* Fix the encoding issue on Windows system.
* Add new schema "original" to download original data only.
* Use a new yaml configurations api.
* Support more types of `config_where` in `fetch_from_v3()`. Besides the `list` type, now you can specify a `data.frame` type and even a `character` type of `config_where`. This is most helpful when `config_where` is generated not by `yaml` config, but by R code directly.
* Rename `fetch_from_v3()` as `fetch()`, and the API is now `fetch(query_file, config_where, dsn)`. That is to say, you can now pass the data source name of your database to it.
* Export S3 method `compose_where()`, which originally was named as `compose_where_clause()`.
* Support new argument `separate` in `use_targets()` to optionally separate fetching into branches by games.
* Support new argument `ignore_tar` in `use_targets()` to optionally ignore internal data from targets package in version control system (i.e., ".gitignore").
* Now `use_targets()` will skip "config.yml" file silently if there already exists one.
* Moved internal data named `game_info` to "dataproc.iquizoo (>= 0.2.6)" package.

# tarflow.iquizoo 0.0.0.9001

* Added a `NEWS.md` file to track changes to the package.
