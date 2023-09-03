library(testthat)
Sys.setenv(TARFLOW.CACHE = "memory")
library(tarflow.iquizoo)

test_check("tarflow.iquizoo")
