set.seed(1014)
options(digits = 3)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  autodep = TRUE,
  # need to save cache
  cache.extra = knitr::rand_seed,
  out.width = "70%",
  fig.align = "center",
  fig.width = 6,
  fig.asp = 0.618, # 1 / phi
  fig.show = "hold",
  # styler
  tidy = 'styler'
)

options(dplyr.print_min = 6, dplyr.print_max = 6)

is_html <- knitr::opts_knit$get("rmarkdown.pandoc.to") == "html"

# Info and useful links
SOURCE_URL <- stringr::str_c("https:/", "github.com", "jrnold",
  "r4ds-exercise-solutions",
  sep = "/"
)
PUB_URL <- stringr::str_c("https:/", "jrnold.github.io",
  "r4ds-exercise-solutions",
  sep = "/"
)

R4DS_URL <- "https://r4ds.had.co.nz"

r4ds_url <- function(...) {
  stringr::str_c(R4DS_URL, ..., sep = "/")
}

comma_int <- function(x) {
  prettyNum(x, big.interval = 3, big.mark = ",")
}

no_exercises <- function() {
  tags <- htmltools::tags
  tags$div(
    class = 'alert alert-warning hints-alert',
    tags$div(
      class = "hints-icon",
      tags$i(
        class = "fa fa-exclamation-circle"
      )
    ),
    tags$div(
      class = "hints-container",
      "No exercises"
    )
  )
}
