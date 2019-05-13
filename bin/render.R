#!/usr/bin/env Rscript
# Script to render book
suppressPackageStartupMessages({
  library("optparse")
  library("xml2")
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

create_outdir <- function(output_dir) {
  # create nojekyll if it doesn't exist
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  nojekyll <- file.path(output_dir, ".nojekyll")
  if (!file.exists(nojekyll)) {
    cat("Creating ", nojekyll, "\n")
    con <- file(nojekyll, "w")
    close(con)
  }
}

render <- function(input, output_format = "all", force = FALSE,
                   config = "_config.yml", ...) {
  if (rmarkdown::pandoc_version() < 2) {
    stop("This book requires pandoc > 2")
  }
  if (!force) {
    check_uncommitted(dirname(input[[1]]))
  }
  output_dir <- yaml::read_yaml("_bookdown.yml")$output_dir
  create_outdir(output_dir)
  bookdown::render_book(input = "index.Rmd", output_format = output_format, ...,
                        envir = new.env(), clean_envir = FALSE)
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
    ),
    make_option("--to", default = "all",
                help = "Bookdown output format to use"),
    make_option("--config", default = "_config.yml",
                help = "Path to project config file. Needed for output URL.")
  )
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
  output_format <- opts$options$to
  if (output_format == "html") {
    output_format <- "bookdown::gitbook"
  } else if (output_format == "pdf") {
    output_format <- "bookdown::pdf_book"
  }
  input <- if (!length(opts$args)) {
    "index.Rmd"
  } else {
    opts$args
  }
  render(
    input,
    output_format = output_format,
    force = opts$options$force,
    quiet = opts$options$quiet
  )
}

main()
