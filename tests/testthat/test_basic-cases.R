skip_if_not(check_source())
targets::tar_test("Works when single game on different projects", {
  targets::tar_script({
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

targets::tar_test("`combine` work properly", {
  targets::tar_script({
    params <- tibble::tribble(
      ~organization_name, ~project_name,
      "北京师范大学（测试）", "元认知测试"
    )
    tar_prep_iquizoo(
      params,
      combine = objects(),
      cache = cachem::cache_mem()
    )
  })
  expect_contains(
    targets::tar_manifest(callr_function = NULL)$name,
    objects()
  )
  params <- tibble::tribble(
    ~organization_name, ~project_name,
    "北京师范大学（测试）", "元认知测试"
  )
  tar_prep_iquizoo(params, combine = "bad") |>
    expect_error(class = "tarflow_bad_combine")
})

targets::tar_test("Serialize check (no roundtrip error)", {
  withr::local_envvar(c(TARFLOW_CACHE = "memory"))
  targets::tar_script({
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

targets::tar_test("Ensure project date is used", {
  targets::tar_script(
    tar_prep_iquizoo(
      contents = data.frame(
        project_id = bit64::as.integer64(132121231360389),
        game_id = bit64::as.integer64(268008982646879)
      ),
      what = "scores",
      combine = "scores"
    )
  )
  targets::tar_make(reporter = "silent", callr_function = NULL)
  nrow(targets::tar_read(scores)) |> expect_gt(0)
})
