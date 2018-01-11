#!/bin/env Rscript
# Spell check
library("spelling")
wordlist_file <- "WORDLIST"

wordlist <- stringr::str_trim(readLines(wordlist_file))

files <- list.files(".", pattern = "\\.(Rnw|Rmd)$", full.names = TRUE)
misspelled_words <- spell_check_files(files, ignore = wordlist)
print(misspelled_words)

# wordlist <- misspelled_words$word
# cat(str_c(wordlist, collapse = "\n"), "\n", file = "WORDLIST")
