#' extract the table of contents from R for Data Science and Save
library("rvest")
library("purrr")
library("stringr")
library("jsonlite")

URL <- "https://r4ds.had.co.nz/"

process_chapter <- function(x) {
  list(number = html_attr(x, "data-level"),
       path =  html_attr(html_node(x, "a"), "href"),
       name = str_replace(html_text(html_node(x, "a"),
                                    trim = TRUE), "^\\d+(\\.\\d+)*\\s+", ""))
}

r4ds_toc <- function() {
  index <- read_html(URL)
  book_summary <- html_nodes(index, "div.book-summary")
  chapters <- html_nodes(book_summary, "li.chapter")
  map(chapters, process_chapter)
}

toc <- r4ds_toc()

write_json(toc, "r4ds-toc.json")
