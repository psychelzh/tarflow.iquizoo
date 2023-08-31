# Created by tarflow.iquizoo::use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
# library(tarchetypes) # Load other packages as needed.

# Set target options:
tar_option_set(
  packages = c("tarflow.iquizoo", "preproc.iquizoo") # packages that your targets need to run
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # For distributed computing in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller with 2 workers which will run as local R processes:
  #
  #   controller = crew::crew_controller_local(workers = 2)
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# source("other_functions.R") # Source other scripts as needed.

tbl_params <- tibble::tribble(
  ~course_name, ~course_period,
  # replace course name and course period with your own
  "# COURSE NAME", "# COURSE PERIOD"
)

targets <- tarflow.iquizoo::prepare_fetch_data(tbl_params, what = "all")

# Replace the target list below with your own:
list(
  # change what to scores or raw_data if you want to
  targets,
  tar_target(
    course_contents,
    attr(targets, "params")
  )
  # more targets goes here
)
