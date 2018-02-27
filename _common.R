set.seed(1014)
options(digits = 3)

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  autodep = TRUE,
  out.width = "70%",
  fig.align = 'center',
  fig.width = 6,
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold"
)

options(dplyr.print_min = 6, dplyr.print_max = 6)

is_html <- knitr::opts_knit$get("rmarkdown.pandoc.to") == "html"

BeginQuestion <- function() {
  if (is_html) {
    "<div class='question'>"
  } else {
    "\\begin{question}"
  }
}
EndQuestion <- function() {
  if (is_html) {
    "</div>"
  } else {
    "\\end{question}"
  }
}

