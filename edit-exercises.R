library("tidyverse")
library("yaml")

bookdown <- yaml.load_file("_bookdown.yml")

chapters <- bookdown$rmd_files[!str_detect(bookdown$rmd_files, "^(index|explore|wrangle|program|model|communicate)\\.Rmd$")]

edit_rmd <- function(chapter, filenames) {
  filename <- filenames[[chapter]]
  lines <- read_lines(filename)
  counters <- rep(0L, 5L)
  for (j in seq_along(lines)) {
    line <- lines[[j]]
    if (str_detect(line, "^#+ ")[[1L]]) {
       i <- str_length(str_extract(line, "^#+"))
       if (i == 1L) {
         counters[[1L]] <- chapter
       } else {
         counters[i] <- counters[i] + 1L
         if (i < length(counters)) {
           counters[(i + 1L):length(counters)] <- 0L
         }
       }
       if (str_detect(line, "^#+ Exercise \\d+")) {
         lines[[j]] <- str_replace(line,
                     "Exercise (\\d+)",
                     str_c("Exercise ",
                           "<span class=\"exercise-number\">",
                           str_c(counters[seq_len(i)], collapse = "."),
                           "</span>",
                           sep = ""))
       }
    }
  }
  write_lines(lines, path = str_c(filename))
}

walk(seq_along(chapters), edit_rmd, filenames = chapters)
