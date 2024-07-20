skip_if_not(check_source())
targets::tar_test("Ensure subset users props work", {
  targets::tar_script({
    library(targets)
    tar_prep_iquizoo(
      contents = data.frame(
        project_id = bit64::as.integer64(132121231360389),
        game_id = bit64::as.integer64(268008982646879)
      ),
      what = "scores",
      subset_users_props = "user_name"
    )
  })
  targets::tar_make(reporter = "silent", callr_function = NULL)
  targets::tar_read(users) |> expect_named(c("user_id", "user_name"))
})
