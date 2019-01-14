library("readr")
library("stringr")

rmd_files <-

clean_exercise <- function(path) {
  lines <- read_lines(path)
  PAT <- "^(#+\\s*Exercise)\\s+(<span .*>)(.*)(</span>)\\s*(\\{.*)(\\})\\s*$"
  newlines <- str_replace(lines, PAT,  "\\1 \\3 \\5 data-number=\"\\3\"}")
  write_lines(newlines, path)
}
fs::dir_ls(path = ".", regexp = ".*\\.[rR]md$") %>%
  walk(clean_exercise)
