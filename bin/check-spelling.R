#!/bin/env Rscript
# Spell check
library("spelling")
library("magrittr")
wordlist_file <- "WORDLIST"

wordlist <- stringr::str_trim(readLines(wordlist_file))

files <- c(list.files(here::here("."), pattern = "\\.(Rnw|Rmd)$", full.names = TRUE),
           list.files(here::here("rmarkdown"),
                      pattern = "\\.(Rmd)$", full.names = TRUE),
           here::here("NEWS.md"),
           here::here("README.md")) %>%
  normalizePath() %>%
  unique()

misspelled_words <- spell_check_files(sort(files), ignore = wordlist)
any_mispelled <- as.logical(nrow(misspelled_words))

if (any_mispelled) {
  sink(file = stderr())
  print(misspelled_words)
  sink()
  quit(1)
}
