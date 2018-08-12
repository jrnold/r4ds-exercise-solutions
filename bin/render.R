#!/usr/bin/env Rscript
# Script to render book

# From devtools:::git_uncommitted
git_uncommitted <- function (path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

# Adapted from devtools:::git_uncommitted
check_uncommitted <- function(path = ".") {
  if (!git_uncommitted(path)) {
    stop("Uncommitted files.",
         "All files should be committed before release.",
         "Please add and commit.")
  }
}

render <- function(path = here::here(), output_format = "all") {
  if (rmarkdown::pandoc_version() < 2) {
    stop("This book requires pandoc > 2")
  }
  check_uncommitted(path)
  bookdown::render_book(path, output_format = output_format)
}

main <- function(args = NULL) {
  if (is.null(args)) {
    args <- commandArgs(TRUE)
  }
  output_format <- if (!length(args)) {
    "all"
  } else {
    args[[1]]
  }
  render(output_format = output_format)
}

main()
