skip_if_not(check_source())
targets::tar_test("Ensure `check_progress = FALSE` work", {
  targets::tar_script(
    tar_prep_iquizoo(
      contents = data.frame(
        project_id = bit64::as.integer64(132121231360389),
        game_id = bit64::as.integer64(268008982646879)
      ),
      what = "scores",
      check_progress = FALSE
    )
  )
  targets::tar_make(reporter = "silent", callr_function = NULL)
  expect_true(all(!startsWith(targets::tar_objects(), "progress_hash")))
})
