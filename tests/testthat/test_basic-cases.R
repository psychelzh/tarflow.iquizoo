skip_if_not(check_source())
test_that("Works when single game on different projects", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_prep_iquizoo(
        contents = tibble::tibble(
          project_id = bit64::as.integer64(c(519355469824389, 519355011072389)),
          game_id = bit64::as.integer64(238239294447813)
        ),
        what = "scores"
      )
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_equal(
      unique(targets::tar_read(scores_238239294447813)$project_id),
      bit64::as.integer64(c(519355469824389, 519355011072389))
    )
  })
})

test_that("`combine` work properly", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "北京师范大学测试用账号", "难度测试"
      )
      tar_prep_iquizoo(
        params,
        combine = objects()
      )
    })
    expect_contains(
      targets::tar_manifest(callr_function = NULL)$name,
      objects()
    )
  })
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学测试用账号", "难度测试"
  )
  tar_prep_iquizoo(params, combine = "bad") |>
    expect_error(class = "tarflow_bad_combine")
})

test_that("Serialize check (no roundtrip error)", {
  withr::local_envvar(c(TARFLOW_CACHE = "memory"))
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      params <- tibble::tribble(
        ~organization_name, ~project_name,
        "四川省双流棠湖中学高中部", "棠湖中学英才计划测训体验账号"
      )
      tar_prep_iquizoo(params)[1]
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    expect_identical(
      targets::tar_read(contents_origin),
      fetch_iquizoo(
        read_file(setup_templates()$contents),
        params = unname(as.list(
          tibble::tribble(
            ~organization_name, ~project_name,
            "四川省双流棠湖中学高中部", "棠湖中学英才计划测训体验账号"
          )
        ))
      )
    )
  })
})

test_that("Ensure project date is used", {
  targets::tar_dir({
    targets::tar_script({
      library(targets)
      tar_prep_iquizoo(
        contents = data.frame(
          project_id = bit64::as.integer64(132121231360389),
          game_id = bit64::as.integer64(268008982646879)
        ),
        what = "scores",
        combine = "scores"
      )
    })
    targets::tar_make(reporter = "silent", callr_function = NULL)
    nrow(targets::tar_read(scores)) |> expect_gt(0)
  })
})
