#!/usr/bin/env Rscript
# Script to render book
suppressPackageStartupMessages({
  library("optparse")
})
# From devtools:::git_uncommitted
git_uncommitted <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

# Adapted from devtools:::git_uncommitted
check_uncommitted <- function(path = ".") {
  if (git_uncommitted(path)) {
    stop(paste("Uncommitted files.",
               "All files should be committed before release.",
               "Please add and commit.", sep = " "))
  }
}

render <- function(path = NULL,
                   output_format = "all", force = FALSE) {
  if (rmarkdown::pandoc_version() < 2) {
    stop("This book requires pandoc > 2")
  }
  if (is.null(path)) {
    path <- here::here("index.Rmd")
  }
  if (!force) {
    check_uncommitted(path)
  }
  bookdown::render_book(input = "index.Rmd", output_format = output_format)
}

main <- function(args = NULL) {
  option_list <- list(
    make_option(c("-f", "--force"), action = "store_true", default = FALSE,
                help = "Render even if there are uncomitted changes.")
  )
  # option_list <- list()

  if (is.null(args)) {
    args <- commandArgs(TRUE)
  }
  opts <- parse_args(OptionParser(usage = "%prog [options] [output_format|all]",
                                  option_list = option_list),
                     args = args,
                     positional_arguments = TRUE,
                     convert_hyphens_to_underscores = TRUE)
  output_format <- if (!length(opts$args)) {
    "all"
  } else {
    opts$args[[1]]
  }
  print(output_format)
  render(output_format = output_format, force = opts$options$force)
}

main()
