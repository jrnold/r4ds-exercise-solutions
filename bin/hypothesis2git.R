#!/usr/bin/env Rscript
suppressPackageStartupMessages({
  library("hypothesisr")
  library("stringr")
  library("urltools")
  library("glue")
  library("gh")
  library("optparse")
})

GITHUB_OWNER <- "jrnold"
GITHUB_REPO <- "r4ds-exercise-solutions"

annotation_to_github <- function(url) {
  id <- str_split(url_parse(url)$path, "/")[[1]][[1]]
  annotation <- hs_read(id)

  title <- glue("Address hypothes.is comment {id}")
  text <- str_c("> ", str_split(annotation$text, "\n")[[1]], collapse = "\n")
  body <- glue(
    "Hypothesis annotation {annotation$links$incontext} ({annotation$user})\n",
    "{text}",
    .sep = "\n"
  )
  labels <- list("hypothes.is")

  ret <- gh("POST /repos/:owner/:repo/issues", owner = GITHUB_OWNER, repo = GITHUB_REPO,
            title = title, body = body, labels = labels)
  cat(as.character(ret))
  ret
}

main <- function() {
  parser <- OptionParser()
  args <- parse_args(parser, args = commandArgs(TRUE),
                     positional_arguments = TRUE)
  annotation_to_github(args$args[[1]])
}

main()
