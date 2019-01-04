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
      "Please add and commit.",
      sep = " "
    ))
  }
}

create_outdir <- function() {
  # create nojekyll if it doesn't exist
  output_dir <- yaml::read_yaml(here::here("_bookdown.yml"))[["output_dir"]]
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  nojekyll <- file.path(output_dir, ".nojekyll")
  if (!file.exists(nojekyll)) {
    cat("Creating ", nojeykll, "\n")
    con <- file(nojekyll, "w")
    close(con)
  }
}

render <- function(path = NULL, output_format = "all", force = FALSE, ...) {
  if (rmarkdown::pandoc_version() < 2) {
    stop("This book requires pandoc > 2")
  }

  if (is.null(path)) {
    path <- here::here("index.Rmd")
  }
  if (!force) {
    check_uncommitted(dirname(path))
  }
  create_outdir()
  bookdown::render_book(input = "index.Rmd", ...)
}

main <- function(args = NULL) {
  option_list <- list(
    make_option(c("-f", "--force"),
      action = "store_true", default = FALSE,
      help = "Render even if there are uncomitted changes."
    ),
    make_option(c("-q", "--quiet"),
      action = "store_true", default = FALSE,
      help = "Do not use verbose output"
    )
  )
  # option_list <- list()

  if (is.null(args)) {
    args <- commandArgs(TRUE)
  }
  opts <- parse_args(OptionParser(
    usage = "%prog [options] [output_format|all|html|pdf]",
    option_list = option_list
  ),
  args = args,
  positional_arguments = TRUE,
  convert_hyphens_to_underscores = TRUE
  )
  output_format <- if (!length(opts$args)) {
    "all"
  } else {
    opts$args[[1]]
  }
  if (output_format == "html") {
    output_format <- "bookdown::gitbook"
  } else if (output_format == "pdf") {
    output_format <- "bookdown::pdf_book"
  }
  render(
    output_format = output_format,
    force = opts$options$force,
    quiet = opts$options$quiet
  )
}

main()
