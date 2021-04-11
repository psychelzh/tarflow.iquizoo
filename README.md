# tarflow-iquizoo

<!-- badges: start -->
[![R-CMD-check](https://github.com/psychelzh/tarflow.iquizoo/workflows/R-CMD-check/badge.svg)](https://github.com/psychelzh/tarflow.iquizoo/actions)
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

Workflow generation for IQUIZOO data powered by [targets](https://github.com/wlandau/targets) package.

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Background

The preprocessing of IQUIZOO data used to be very harduous because the datasets were very disorganized. Newer version of database and games make things much better. Now there is a package called [dataproc.iquizoo](https://github.com/psychelzh/dataproc.iquizoo), containing all the required functions used in preprocessing. It facilitates analysis significantly. For now, with the advent of [targets](https://github.com/wlandau/targets), we can easily setup workflows to automate all the preprocessing! This is what this package does. Hopefully, it will make the analysis of IQUIZOO data a favorable thing.

## Install

Install the development version from github.

```r
# install.package("remotes")
remotes::install_github("psychelzh/tarflow.iquizoo")
```

## Usage

If you are using R in interactive mode (typically when using *RStudio*), there will be a simple wizard to guide your setup. It will prompt you to choose the correct actions.

```r
# invoke setup wizard
tarflow.iquizoo::init()
```

Essentially, file `_targets.R` will be created in which lists a pipeline that can be used by targets package. You can run the pipeline with the following line of code:

```r
targets::tar_make()
```

Or if you prefer to run on multicores, use this:

```r
# set the number of works in the `workers` argument
targets::tar_make_future(workers = <numeric>)
```

## Maintainers

[@psychelzh](https://github.com/psychelzh)

## Contributing

PRs accepted.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

MIT © 2021 Liang Zhang
