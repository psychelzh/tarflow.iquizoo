# tarflow-iquizoo

[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-green.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

Workflow generation for IQUIZOO data powered by [`targets`](https://github.com/wlandau/targets).

## Table of Contents

- [Background](#background)
- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Background

The preprocessing of IQUIZOO data used to be very harduous because of the datasets are very disorganized. Newer version of database and games make things much better. Now there is a package called [`dataproc.iquizoo`](https://github.com/psychelzh/dataproc.iquizoo), containing all the required functions used in preprocessing. It facilitates analysis significantly. For now, with the advent of [`targets`](https://github.com/wlandau/targets), we can easily setup workflows to automate all the preprocessing! This is what this package does. Hopefully, it will make the analysis of IQUIZOO data a preferable thing.

## Install

This work will have little chance to be on CRAN. Install it using the following scripts.

```r
remotes::install_github("psychelzh/tarflow.iquizoo")
```

## Usage

We use `schema` as our job descriptor. Two `schema`s are planned to be supported, i.e., `'indices'` and `'scores'`. Pass one of the `schema` name as input of `use_targets` function.

```r
# use 'indices' targets
tarflow.iquizoo::use_targets(schema = "indices")
```

## Maintainers

[@psychelzh](https://github.com/psychelzh)

## Contributing

PRs accepted.

Small note: If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

MIT © 2020 Liang Zhang
