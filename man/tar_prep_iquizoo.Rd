% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/targets.R
\name{tar_prep_iquizoo}
\alias{tar_prep_iquizoo}
\title{Generate a set of targets for pre-processing of iQuizoo data}
\usage{
tar_prep_iquizoo(
  params,
  contents,
  ...,
  what = c("raw_data", "scores"),
  action_raw_data = c("all", "parse", "none"),
  combine = NULL,
  templates = setup_templates(),
  check_progress = TRUE
)
}
\arguments{
\item{params, contents}{Used as the configuration of data fetching. These two
arguments are mutually exclusive. If \code{params} is specified, it will be used
as parameters to be bound to the query, see \code{\link[DBI:dbBind]{DBI::dbBind()}} for more
details. The default template requires specifying \code{organization_name} and
\code{project_name}, in that order. If \code{contents} is specified, it should be a
\link{data.frame} and will be used directly as the configuration of data
fetching. Note \code{contents} should at least contain \code{project_id} and
\code{game_id} names.}

\item{...}{For future usage. Should be empty.}

\item{what}{What to fetch. There are basically two types of data, i.e., raw
data and scores. The former is the logged raw data for each trial of the
tasks/games, while the latter is the scores calculated by iQuizoo server.
If set as "all", both raw data and scores will be fetched. Further actions
on the fetched raw data can be specified by \code{action_raw_data}.}

\item{action_raw_data}{The action to be taken on the fetched raw data. There
are two consecutive actions, i.e., wrangling and pre-processing. The former
will parse the raw data into a tidy format, while the latter will calculate
indices based on the parsed data. If set as "all", both wrangling and
pre-processing will be done. If set as "parse", only wrangling will be
done. If set as "none", neither will be done. If \code{what} is "scores", this
argument will be ignored.}

\item{combine}{Specify which targets to be combined. Note you should only
specify names from \code{c("scores", "raw_data", "raw_data_parsed", "indices")}.
If \code{NULL}, none will be combined.}

\item{templates}{The SQL template files used to fetch data. See
\code{\link[=setup_templates]{setup_templates()}} for details.}

\item{check_progress}{Whether to check the progress hash. Set it as \code{FALSE}
if the project is finalized.}
}
\value{
A list of target objects.
}
\description{
This target factory prepares a set of target objects used to fetch data from
iQuizoo database, separated into static branches so that each is for a
specific project and task/game combination. Further pre-processing on the
fetched data can also be added if requested.
}
