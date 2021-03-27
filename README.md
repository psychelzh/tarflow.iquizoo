# tarflow-iquizoo

[![tic](https://github.com/psychelzh/tarflow.iquizoo/workflows/tic/badge.svg?branch=master)](https://github.com/psychelzh/tarflow.iquizoo/actions)
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

Workflow generation for IQUIZOO data powered by [`targets`](https://github.com/wlandau/targets).

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Background

The preprocessing of IQUIZOO data used to be very harduous because the datasets were very disorganized. Newer version of database and games make things much better. Now there is a package called [`dataproc.iquizoo`](https://github.com/psychelzh/dataproc.iquizoo), containing all the required functions used in preprocessing. It facilitates analysis significantly. For now, with the advent of [`targets`](https://github.com/wlandau/targets), we can easily setup workflows to automate all the preprocessing! This is what this package does. Hopefully, it will make the analysis of IQUIZOO data a favorable thing.

## Install

This work will have little chance to be on CRAN. Install it using the following scripts.

```r
remotes::install_github("psychelzh/tarflow.iquizoo")
```

## Usage

We use `schema` as our job descriptor. Currently, three schemas are supported:

- `"original"`: Fetch original data only.
- `"indices"`: Fetch original data and do preprocessing on it based on `dataproc.iquizoo` package.
- `"scores"`: Fetch the calculated scores in IQUIZOO database.

For example, you can generate jobs using `"indices"` schema as follows:

```r
# use 'indices' targets
tarflow.iquizoo::use_targets(schema = "indices")
```

This will generate a `_targets.R` file describing all the jobs to be done. You can do some changes on it and then run the following line of code:

```r
targets::tar_make()
```

## Maintainers

[@psychelzh](https://github.com/psychelzh)

## Contributing

PRs accepted.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

MIT © 2021 Liang Zhang
