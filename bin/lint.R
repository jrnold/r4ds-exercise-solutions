#!/bin/env RScript
suppressPackageStartupMessages({
  library("lintr")
  library("glue")
})

linters <- with_defaults(
  camel_case_linter = NULL,
  multiple_dots_linter = NULL
)

files <- list.files(".", pattern = "\\.(Rnw|Rmd)$", full.names = TRUE)
for (f in files) {
  cat(f, "\n")
  ret <- try(lint(f, linters = linters))
  if (inherits(ret, "Lint")) {
    print(ret)
  }
}
