#!/usr/bin/env Rscript
# Script to render book
if (rmarkdown::pandoc_version() < 2) {
  stop("This book requires pandoc > 2")
}
args <- commandArgs(TRUE)
output_format <- if (!length(args)) {
  "all"
} else {
  args[[1]]
}
bookdown::render_book(".", output_format = output_format)
