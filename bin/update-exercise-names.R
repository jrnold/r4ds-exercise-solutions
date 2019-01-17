library("readr")
library("stringr")
library("purrr")

clean_exercise <- function(path) {
  lines <- read_lines(path)
  lines <- str_replace(lines, "^(#.*\\{#.*)\\}\\s*$", "\\1 .r4ds-section}")
  write_lines(lines, path)
}
fs::dir_ls(path = ".", regexp = ".*\\.[rR]md$") %>%
  walk(clean_exercise)
