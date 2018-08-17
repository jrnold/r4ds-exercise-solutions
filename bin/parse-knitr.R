library("knitr")
library("stringr")
library("tibble")
library("purrr")

path <- "functions.Rmd"
fmt <- "md"
if (is.null(fmt)) {
  stop("Invalid format found")
}
pat <- knitr::all_patterns[[fmt]]

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
  x = gsub("^\\s*,?", "", x)
  if (grepl("^\\s*[^'\"](,|\\s*$)", x)) {
    x = gsub("^\\s*([^'\"])(,|\\s*$)", "'\\1'\\2", x)
  }
  else if (grepl("^\\s*[^'\"](,|[^=]*(,|\\s*$))", x)) {
    x = gsub("^\\s*([^'\"][^=]*)(,|\\s*$)", "'\\1'\\2", x)
  }
  x
}

# alternative to using knitr:::output_format() == "markdown"
is_markdown <- function(fmt) {
  fmt %in% c("md")
}

# slightly adapted from knitr:::parse_params
# changed to avoid dependcies on the state
parse_params <- function(header, fmt, pat) {
  params <- str_match(header, pat$chunk.begin)[1L, 2L]
  engine = "r"
  if (is_markdown(fmt)) {
    engine = sub("^([a-zA-Z0-9_]+).*$", "\\1", params)
    params = sub("^([a-zA-Z0-9_]+)", "", params)
  }
  params = gsub("^\\s*,*|,*\\s*$", "", params)
  if (tolower(engine) != "r") {
    params = sprintf("%s, engine=\"%s\"", params, engine)
    params = gsub("^\\s*,\\s*", "", params)
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
  browser()
  # apply header
  spaces <- gsub("^([\t >]*).*", "\\1", header)
  res$indent <- spaces
  res
}

lines <- tibble(
  text = readLines(path),
  chunk_begin = str_detect(text, pat$chunk.begin),
  chunk_end = str_detect(text, pat$chunk.end),
  ref_chunk = str_detect(text, pat$ref.chunk),
  line_number = seq_along(text),
  id = NA_integer_
)

in_code <- FALSE
id <- 1L
for (i in seq_len(nrow(lines))) {
  if (!in_code) {
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
