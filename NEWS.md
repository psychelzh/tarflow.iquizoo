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
