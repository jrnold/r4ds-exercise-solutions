library("knitr")
library("stringr")
library("tibble")
library("purrr")

path <- "functions.Rmd"
fmt <- "md"
if (is.null(fmt)) {
  stop("Invalid format found")
}
pat <- yaml::yaml.load_file("patterns.yml")[[fmt]]

# copy of knitr:::parse_only
parse_only <- function(code) {
  if (length(code) == 0) {
    expression()
  } else {
    parse(text = code, keep.source = FALSE)
  }
}

# copy of knitr:::quote_label
quote_label <- function(x) {
  x = str_replace(x, "^\\s*,?", "")
  if (str_detect(x, "^\\s*[^'\"](,|\\s*$)")) {
    x <- str_replace(x, "^\\s*([^'\"])(,|\\s*$)", "'\\1'\\2")
  }
  else if (str_detect(x, "^\\s*[^'\"](,|[^=]*(,|\\s*$))")) {
    x <- str_replace(x, "^\\s*([^'\"][^=]*)(,|\\s*$)", "'\\1'\\2")
  }
  x
}

# alternative to using knitr:::output_format() == "markdown"
is_markdown <- function(fmt) {
  fmt %in% c("md")
}

knitr_chunk_params <- function(x, filename = NULL) {
  structure(x, class = "knitr_chunk_params", "knitr_parsed")
}


# slightly adapted from knitr:::parse_params
# changed to avoid dependcies on the state
parse_params <- function(header, fmt, pat) {
  params <- str_match(header, pat$chunk.begin)[1L, 2L]
  engine = "r"
  if (is_markdown(fmt)) {
    engine = str_replace(params, "^([a-zA-Z0-9_]+).*$", "\\1")
    params = str_replace(params, "^([a-zA-Z0-9_]+)", "")
  }
  params = str_replace(params, "^\\s*,*|,*\\s*$", "")
  if (str_to_lower(engine) != "r") {
    params = sprintf("%s, engine=\"%s\"", params, engine)
    params = str_replace(params, "^\\s*,\\s*", "")
  }
  if (params == "") {
    return(list())
  }
  res <- eval(parse_only(paste("alist(", quote_label(params), ")")))
  idx <- which(names(res) == "")
  for (i in idx) {
    if (identical(res[[i]], alist(, )[[1]])) {
      res[[i]] = NULL
    }
  }
  # apply header
  spaces <- str_replace(params, "^([\t >]*).*", "\\1")
  res$indent <- spaces
  res
}

lines <- tibble(
  text = readLines(path),
  header = FALSE,
  chunk_begin = str_detect(text, pat$chunk.begin),
  chunk_end = str_detect(text, pat$chunk.end),
  ref_chunk = str_detect(text, pat$ref.chunk),
  line_number = seq_along(text),
  id = NA_integer_
)

in_code <- FALSE
first_non_blank <- FALSE
in_header <- FALSE
id <- 1L
for (i in seq_len(nrow(lines))) {
  if (!first_non_blank && str_detect(lines$text[[i]], "^[\\s\\n]$")) {
    next
  }
  if (!first_non_blank && str_detect(lines$text[[i]], "^-{3}\\s*$")) {
    in_header <- TRUE
    lines[i, "header"] <- TRUE
    lines[i, "id"] <- 0L
  } else if (in_header) {
    lines$header <- TRUE
    lines[i, "header"] <- TRUE
    lines[i, "id"] <- 0L
    if (str_detect(lines$text[[i]], "^-{3}\\s*$")) {
      in_header <- FALSE
    }
  } else if (!in_code) {
    if (lines$chunk_begin[[i]]) {
      if (i > 1L) {
        id <- id + 1L
      }
      in_code <- TRUE
    }
    lines[i, "id"] <- id
  } else {
    lines[i, "id"] <- id
    if (lines$chunk_end[[i]]) {
      id <- id + 1L
      in_code <- FALSE
    }
  }
}

parse_code <- function(x) {
  if (x$ref_chunk[[1L]]) {
    list(ref = str_match(x$text, pat$ref.chunk)[1L, 2L],
         text = x$text,
         line_start = min(x$line_number),
         line_end = max(x$line_number))
  } else {
    if (!is.null(pat$chunk.code)) {
      x$text <- str_replace(x$text, pat$chunk.code, "")
    }
    list(text = str_c(x$text, collapse = "\n"),
         line_start = min(x$line_number),
         line_end = max(x$line_number))
  }
}

parse_chunk <- function(x) {
  if (nrow(x) == 0L) {
    return(NULL)
  }
  # code chunk
  if (x$chunk_begin[[1]]) {
    # extract parameters
    params <- x$text[[1]]
    line_start <- min(x$line_number)
    line_end <- max(x$line_number)
    # remove chunk start and end
    x <- x[2L:(nrow(x) - 1L), ]
    # split into code and references
    # reuse id column because its already there
    id <- 1L
    for (i in seq_len(nrow(x))) {
      if (x$ref_chunk[[i]]) {
        id <- (id == 1L) | (id + 1L)
        x[i, "id"] <- id
        id <- id + 1L
      } else {
        x[i, "id"] <- id
      }
    }
    x <- split(x, x$id)
    list(params = parse_params(params, fmt, pat),
         code = map(x, parse_code),
         line_start = line_start,
         line_end = line_end)
  } else {
    list(text = str_c(x$text, collapse = "\n"),
         line_start = min(x$line_number),
         line_end = max(x$line_number))
  }
}

split(lines, lines$id) %>%
  map(parse_chunk) %>%
  print()
