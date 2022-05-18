
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tarflow.iquizoo

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![R-CMD-check](https://github.com/psychelzh/tarflow.iquizoo/workflows/R-CMD-check/badge.svg)](https://github.com/psychelzh/tarflow.iquizoo/actions)
[![Codecov test
coverage](https://codecov.io/gh/psychelzh/tarflow.iquizoo/branch/main/graph/badge.svg)](https://app.codecov.io/gh/psychelzh/tarflow.iquizoo?branch=main)
<!-- badges: end -->

The goal of tarflow.iquizoo is to provide workflow auto-generation for
IQUIZOO data powered by [targets](https://github.com/wlandau/targets)
package.

## Background

The preprocessing of IQUIZOO data used to be very harduous because the
datasets were very disorganized. Newer version of database and games
make things much better. Now there is a package called
[preproc.iquizoo](https://github.com/psychelzh/preproc.iquizoo),
containing all the required functions used in preprocessing. It
facilitates analysis significantly. For now, with the advent of
[targets](https://github.com/wlandau/targets), we can easily setup
workflows to automate all the preprocessing! This is what this package
does. Hopefully, it will make the analysis of IQUIZOO data a favorable
thing.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("psychelzh/tarflow.iquizoo")
```

## Usage

This package is essentially providing several rmarkdown templates for
use. See [this
article](https://rstudio.github.io/rstudio-extensions/rmarkdown_templates.html)
to understand how to open a new template.

Currently two templates are provided:

-   `"fetch-iquizoo"` (“Fetch Iquizoo Data”): Fetch all the data as a
    whole, not appropriate for raw data preprocessing.
-   `"fetch-iquizoo-branches"` (“Fetch Iquizoo Data Separately”): Fetch
    all the data separately by games, appropriate for raw data
    preprocessing.
