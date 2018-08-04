#!/bin/env Rscript
#' Check that all question and answer divs are matched.
library("stringr")
library("purrr")
library("stringr")
library("glue")

is_question <- function(x) {
  str_detect(x, "<div\\s*class=\"question\">")
}

is_answer <- function(x) {
  str_detect(x, "<div\\s*class=\"answer\">")
}

missing_divs <- function(path) {
  lines <- read_lines(path)
  last_seen <- NULL
  for (i in seq_along(lines)) {
    line <- lines[[i]]
    if (is_question(line)) {
      if (!is.null(last_seen) && last_seen != "answer") {
        warning(glue("Missing answer in {path}:{i}"))
      }
      last_seen <- "question"
    }
    if (is_answer(line)) {
      if (is.null(last_seen) || last_seen != "question") {
        warning(glue("Missing question in {path}:{i}"))
      }
      last_seen <- "answer"
    }
  }
  if (!is.null(last_seen) && last_seen == "question") {
    warning(glue("Missing answer in {path}:{i}"))
  }
}

main <- function() {
  files <- list.files(here::here(), pattern = "\\.Rmd")
  walk(files, missing_divs)
}

main()
