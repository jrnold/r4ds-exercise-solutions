#' extract the table of contents from "R for Data Science" and save to a csv file
library("rvest")
library("purrr")
library("stringr")
library("jsonlite")

get_chapters <- function(output_dir) {
  index <- read_html(file.path(output_dir, "index.html"))
  book_summary <- html_nodes(index, "div.book-summary")
  chapters <- html_nodes(book_summary, "li.chapter") %>%
    keep(~ str_detect(html_attr(.x, "data-level"), "^\\d+$")) %>%
    map_dfr(~tibble(path = html_attr(.x, "data-path"),
                    chapter = html_attr(.x, "data-level")))
  chapters
}

# Extract code comments from a section
get_code <- function(x) {
  code <-  xml_nodes(x, "pre.sourceCode.r") %>%
    map_chr(xml_text) %>%
    str_c(collapse = "\n")
  if (length(code)) {
    str_split(code, coll("\n")) %>%
      flatten_chr() %>%
      # remove comments
      remove_comments() %>%
      remove_empty_strings()
  } else {
    ""
  }
}

remove_comments <- function(x) {
  str_replace(x, "#.*$", "")
}

remove_output <- function(x) {
  x[!str_detect(x, "^#> ")]
}

remove_empty_strings <- function(x) {
  x[str_length(str_trim(x)) > 0]
}

get_text <- function(x) {
  html_text(x) %>%
    str_split("\n") %>%
    purrr::pluck(1) %>%
    remove_output() %>%
    str_c(collapse = "\n") %>%
    str_trim()
}

count_images <- function(x) {
  length(html_nodes(x, "img"))
}

process_exercise <- function(x) {
  answer <- html_node(x, "div.answer")
  tibble(number = html_attr(x, "data-number"),
       id = html_attr(x, "id"),
       answer_images = count_images(answer),
       answer_text = get_text(answer),
       answer_code = list(get_code(answer)),
       question = str_trim(html_text(html_node(x, "div.question"))))
}

process_path <- function(path, output_dir) {
  doc <- read_html(file.path(output_dir, path))
  exercises <- html_nodes(doc, "div.exercise")
  map(exercises, process_exercise) %>%
    map(function(x) {x$path <- path; x})
}

output_dir <- bookdown:::load_config()$output_dir
exercises <- get_chapters(output_dir)$path %>%
  map(process_path, output_dir = output_dir) %>%
  purrr::flatten() %>%
  bind_rows() %>%
  mutate(
    loc = map_int(answer_code, length),
    words = stringi::stri_count_words(answer_text),
    chars = str_length(answer_text),
    chapter = map_chr(str_split(number, fixed(".")), 1L)
  )
