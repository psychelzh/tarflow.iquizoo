# tarflow.iquizoo (development version)

* Separate `tar_prep_proj()` into `tar_prep_hash()` and `tar_fetch_users()`.

# tarflow.iquizoo 3.11.0

## Breaking Changes

* Added `parse_data()`, previously named as `wrangle_data()`. See <https://github.com/psychelzh/preproc.iquizoo/issues/86>.

# tarflow.iquizoo 3.10.2

* Fixed compatibility issue with 'data.iquizoo' 2024.03.31-2.
* Bumped minimum version of 'data.iquizoo' to 2024.03.31-2.

# tarflow.iquizoo 3.10.1

## New Features

* Added `"preproc"` option in `action_raw_data` argument of `tar_prep_raw()`.

# tarflow.iquizoo 3.10.0

## Breaking Changes

* Now `query` argument of `fetch_data()` is optional. If not specified, the default query stored in the package will be used.

## Enhancements

* Added `suffix_format` argument to `fetch_data()` to specify the format of suffix in the query file. This is useful when you want to use a different format of suffix in the query file.
* Enhanced the documentation of `fetch_data()`.
* Let package not depend on dplyr, tidyr and purrr packages (#84).
* Exported more targets factory functions: `tar_prep_proj()`, `tar_fetch_data()`, `tar_prep_raw()`.
* Do not add `progress_hash` objects when `check_progress` is set to `FALSE` in `tar_prep_iquizoo()`.

# tarflow.iquizoo 3.9.3

## Breaking Changes

* Make the default cache location more intuitive as `~/.cache/tarflow.iquizoo`. This will unavoidably invalidate existing caches for old pipelines, but the pipeline targets will not be affected.

# tarflow.iquizoo 3.9.2

## Breaking Changes

* Convert `fetch_iquizoo_mem()` as a function factory to avoid cache location error.

# tarflow.iquizoo 3.9.1

## New Features

* Exported `fetch_iquizoo_mem()`, which is a cached version of `fetch_iquizoo()`, i.e., the results of `fetch_iquizoo()` will be cached.

# tarflow.iquizoo 3.9.0

## Breaking Changes

* Ensure all internal SQL query templates end with semicolon. This will unavoidably invalidate existing targets for old pipelines.
* Removed `preproc_data()` and `wrangle_data()` functions. Now all data preprocessing are done in `preproc.iquizoo` package.

# tarflow.iquizoo 3.8.2

## Enhancements

* Added workaround using tidytable package when the type compatibility triggers an error in `preproc_data()`.
* Added a warning when no non-empty raw data found in `preproc_data()`.
* Added support for triggering a warning for `wrangle_data()` parsing error and `preproc_data()` data binding error.

# tarflow.iquizoo 3.8.1

## Bug Fixes

* Fixed an issue of fetching data when games were distributed on different projects. A regression issue introduced by 3.8.0.

# tarflow.iquizoo 3.8.0

## New Features

* Added `combine` argument in `tar_prep_iquizoo()`. This will enable users to specify freely how to combine the data from branches. See `?tar_prep_iquizoo` for details.

## Enhancements

* Let data from single games be fetched into one targets so that the total targets number could be reduced.

# tarflow.iquizoo 3.7.4

## Bug fixes

* Fix a bug in `fetch_data()` because the data table name in the database is actually based on the project creation time.

# tarflow.iquizoo 3.7.3

## Improvements

* Remove `"all"` option from `what` argument. Specify multiple values if you want to fetch multiple types of data.

# tarflow.iquizoo 3.7.2

## Breaking Changes

* Renamed `use_targets_template()` as `use_targets_pipeline()`. Although arbitary, `"pipeline"` is a little more accurate than `"template"`.

## Misc

* Used Apache License 2.0 instead of MIT License now.

# tarflow.iquizoo 3.7.1

* Fix a compatibility issue with R 4.2.0 which was introduced since 3.6.0.

# tarflow.iquizoo 3.7.0

## Breaking Changes

* Renamed `use_targets()` as `use_targets_template()` to avoid name masking with `targets::use_targets()`.
* Renamed `prepare_fetch_data()` as `tar_prep_iquizoo()` to obey the name convention of targets factory.

# tarflow.iquizoo 3.6.2

* Enhance the organization of pkgdown reference.

# tarflow.iquizoo 3.6.1

* Enhanced documentations for `prepare_fetch_data()`.

# tarflow.iquizoo 3.6.0

## Breaking Changes

* Let `fetch_data()` extract `course_date` automatically. In this way, the `contents` (regardless based on template or feeding directly) does not require the `course_date` column from now on.

# tarflow.iquizoo 3.5.1

* Use `data.iquizoo::match_preproc()`.
* Added `quietly` argument to `setup_option_file()`, so now messages are suppressed when loading package.
* Added more test cases against database settings. Note test cases do not cover odbc driver for now.

# tarflow.iquizoo 3.5.0

## Breaking Changes

* Let pipeline perform raw data parsing and indices calculation on combined raw data from single tasks ([#73](https://github.com/psychelzh/tarflow.iquizoo/issues/73)).
* Let `prepare_fetch_data()` signal error when `contents` contains no data.
* Rename the target `contents` as `contents_origin` to avoid possible name conflict with `contents` input argument. This is a limitation of {targets} package.

## New Features

* Added `contents` argument in `prepare_fetch_data()` to support pre-fetched `contents` as contents configuration. This is useful if you have already fetched the contents data and want to use it directly.

# tarflow.iquizoo 3.4.0

## New Features

* Support `action_raw_data` argument in `prepare_fetch_data()` to specify the action of raw data. This is useful when you want only the parsed raw data and not the indices, e.g., `action_raw_data = "parse"` will not perform indices calculation.
* Added `raw_data_parsed` targets combination and removed `raw_data` targets combination, which should be a potential bug for the unparsed `raw_data` targets combination is not really the intent.

# tarflow.iquizoo 3.3.4

* Fix a roundtrip issue, see [this issue](https://github.com/truecluster/bit64/issues/27) from {bit64} package.

# tarflow.iquizoo 3.3.3

* Ensure `tarchetypes::tar_map()` only rely on columns of `project_id`, `game_id` and `course_date` from template SQL output.

# tarflow.iquizoo 3.3.2

## New Features

* Added two functions `setup_option_file()` and `check_source()` to help setup the database connection option file and check if the database is ready ([#71](https://github.com/psychelzh/tarflow.iquizoo/issues/71)).
  * To ensure option file is correctly set up, you should specify these three environment variables: `MYSQL_HOST`, `MYSQL_USER`, `MYSQL_PASSWORD`. See [option file template](inst/database/my.cnf.tmpl) for details.
  * Note if `check_source()` returns `FALSE`, this package will call `setup_option_file()` once to setup the option file in loading phase. You should check if the option file is correctly set up.

# tarflow.iquizoo 3.3.1

* Let `users` template be independent of input parameters. This means advanced users could minimally specify the `contents` template only.

# tarflow.iquizoo 3.3.0

## Breaking Changes

* The `RMariaDB::MariaDB()` database driver is detected with higher priority, and `odbc::odbc()` is technically deprecated, although still supported (not sure for working) for now ([#68](https://github.com/psychelzh/tarflow.iquizoo/issues/68)).
* Renamed `fetch_parameterized()` as `fetch_iquizoo()`. The latter is shorter and echoes with the package name.
* Removed `fetch_batch()` as vector parameters are supported by `DBI::dbGetQuery()`. `fetch_iquizoo()` handles both vector and scalar parameters.

# tarflow.iquizoo 3.2.1

* Supported to remove duplicates in users. Useful when different projects from the same organization share the same users.
* Enhance some internal logic.

# tarflow.iquizoo 3.2.0

## New Features

* Added `setup_source()` to specify the data source. Arguments `driver`, `dsn` and `groups` of `fetch_parameterized()` now live in this function.
* Let `params` argument of `fetch_parameterized()` be optional (but not after `...`) when no parameters in `query`. Note this is not checked beforehand, so you should take care of whether there are parameters.
* Supported custom SQL templates. When users want to use different parameter names other than the default one, they could support their own paired with SQL templates. See `setup_templates()` for details ([#66](https://github.com/psychelzh/tarflow.iquizoo/issues/66)).

## Improvements

* Enhanced progress hash.
  * The name is changed from `project_hash` to `progress_hash`, which is more informative. So the argument `always_check_hash` of `prepare_fetch_data()` is changed to `check_progress` accordingly.
  * Now if there are multiple projects, the hash will be separated for each project.
  * The SQL now is independent of the user's parameters ([#67](https://github.com/psychelzh/tarflow.iquizoo/issues/67)).

# tarflow.iquizoo 3.1.2

* Fixed a bug of named parameters when `RMariaDB::MariaDB()` is used.

# tarflow.iquizoo 3.1.1

* Fixed a bug that `fetch_preset()` does not pass `...` to `fetch_parameterized()` correctly.

# tarflow.iquizoo 3.1.0

## Breaking Changes

* Changed parameters to organization name and project name. Former course specification is removed.

## New Features

* Support specify `dsn` and `groups` in options by `tarflow.dsn` and `tarflow.groups` respectively. This is useful when default values are not suitable for you.
* Added project users to pipeline.
* Added support for auto-check whether the projects data are up-to-date. This turned on by default, and you can turn it off by setting `always_check_hash` to `FALSE` in `use_targets()`.

## Bug Fixes

* Fix a bug that targets flow will fail with meaningless message when `odbc` does not configure correctly.

# tarflow.iquizoo 3.0.3

* Remove unicode characters from document.

# tarflow.iquizoo 3.0.2

* Fix encoding issue in Rd.

# tarflow.iquizoo 3.0.1

* Fix internal issues. No user-level updates.

# tarflow.iquizoo 3.0.0

## Breaking Changes

* Supported the new database design of IQUIZOO. Now the Rmarkdown templates were removed, and users should call `tarflow.iquizoo::use_targets()` to generate the pipeline.
* Limited the parameters settings to only `course_name` and `course_period` for now. Other parameters will be added in future.
* Added `game_stage` and `game_star` to scores data ([#29](https://github.com/psychelzh/tarflow.iquizoo/issues/29)).

# tarflow.iquizoo 2.5.5

## New Features

* Supported `I()` to input literal query in `query_file` argument for `pickup()`.
* Added project names and game version names into data query template.

## Bug Fixes

* Fix some typos in documentation.

# tarflow.iquizoo 2.5.4

* Enhanced templates: now `content_orginal_data_detail` and `content_score_detail` tables lived in `iqizoo_content_db` database.

# tarflow.iquizoo 2.5.3

* Added more tests. No user-level updates.

# tarflow.iquizoo 2.5.2

## Bug Fixes

* Fixed a bug in `.onAttach()` that will display incorrect message when loading the package.

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

* Implemented new updates of data.iquizoo package, and now `input` and `extra` should be configured in `game_info` data from that package.
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

* Fix a bug of `preproc_data()` occurred when using complex dplyr verbs (see #43).

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
