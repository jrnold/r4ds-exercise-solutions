#!/usr/bin/env Rscript
if (rmarkdown::pandoc_version() < 2) {
  stop("This book requires pandoc > 2")
}
bookdown::render_book(".", output_format = "all")
