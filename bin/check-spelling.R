#!/bin/env Rscript
# Spell check
library("spelling")
wordlist_file <- "WORDLIST"

wordlist <- stringr::str_trim(readLines(wordlist_file))

files <- c(list.files(here::here("."), pattern = "\\.(Rnw|Rmd)$", full.names = TRUE),
           list.files(here::here("rmarkdown"),
                      pattern = "\\.(Rmd)$", full.names = TRUE),
           here::here("NEWS.md"),
           here::here("README.md")) %>%
  normalizePath() %>%
  unique()

misspelled_words <- spell_check_files(files, ignore = wordlist)
print(misspelled_words)

# wordlist <- misspelled_words$word
# cat(str_c(wordlist, collapse = "\n"), "\n", file = "WORDLIST")
