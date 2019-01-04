library("stringr")
library("readr")
library("fs")

filenames <- dir(".", pattern = "^.*\\.Rmd$")

fix_exercise_title <- function(line) {
  pattern <- "(<span class=\"exercise-number\">)((?:[0-9]+\\.)*)([0-9]+\\.)([0-9]+)(</span>)"
  replacement <- "\\1\\2\\4\\5"
  str_replace(line, pattern, replacement)
}

for (filename in filenames) {
  file_copy(filename, str_c(filename, ".bak"))
  newlines <- fix_exercise_title(read_lines(filename))
  write_lines(newlines, filename)
}
