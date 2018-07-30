set.seed(1014)
options(digits = 3)

.nojekyll <- here::here("docs", ".nojekyll")
if (!file.exists(.nojekyll)) {
  close(open(file(.nojekyll, "w")))
}

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE,
  cache = TRUE,
  autodep = TRUE,
  # need to save cache
  cache.extra = knitr::rand_seed,
  out.width = "70%",
  fig.align = 'center',
  fig.width = 6,
  fig.asp = 0.618,  # 1 / phi
  fig.show = "hold"
)

options(dplyr.print_min = 6, dplyr.print_max = 6)

is_html <- knitr::opts_knit$get("rmarkdown.pandoc.to") == "html"

# keep track of the current state
STATE <- NULL

BeginQuestion <- function() {
  if (!is.null(STATE)) {
    message(glue::glue("Starting Question block when STATE = {STATE}"))
    stop()
  }
  STATE <<- "Question"
  "<div class='question'>"
}
EndQuestion <- function() {
  if (is.null(STATE) || !STATE %in% "Question") {
    message(glue::glue("Ending Question block when STATE = {STATE}"))
    stop()
  }
  STATE <<- NULL
  "</div>"
}

BeginAnswer <- function() {
  if (!is.null(STATE)) {
    message(glue::glue("Starting Answer block when STATE = {STATE}"))
    stop()
  }
  STATE <<- "Answer"
  "<div class='answer'>"
}
EndAnswer <- function() {
  if (is.null(STATE) || !STATE %in% "Answer") {
    message(glue::glue("Ending Answer block when STATE = {STATE}"))
    stop()
  }
  STATE <<- NULL
  "</div>"
}
