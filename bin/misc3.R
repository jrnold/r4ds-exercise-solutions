source("_common.R")

knitr::knit_hooks$set(
  track_objects = function(before, options, envir) {
    if (before) {
    } else {
      CodeDepends::
    }
  }
)

knitr::opts_chunk$set(track_objects = TRUE)
text <- read_file("visualize.Rmd")
output <- knitr::knit(text = text)

