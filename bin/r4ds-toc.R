#' extract the table of contents from "R for Data Science" and save to a csv file
library("rvest")
library("purrr")
library("stringr")
library("jsonlite")
library("tibble")
library("dplyr")
library("readr")

R4DS_INDEX <- "https://r4ds.had.co.nz/"

r4ds_chapters <- function() {
  index <- read_html(R4DS_INDEX)
  book_summary <- html_nodes(index, "div.book-summary")
  chapters <- html_nodes(book_summary, "li.chapter") %>%
    keep(~ str_detect(html_attr(.x, "data-level"), "^\\d+$")) %>%
    map_dfr(~tibble(path = html_attr(.x, "data-path"),
                    chapter = html_attr(.x, "data-level")))
  chapters
}

process_section <- function(section) {
  header <- html_children(section)[[1]]
  lvl <- str_split(html_attr(section, "class"), " ")[[1]] %>%
    str_subset("^level(\\d+)$") %>%
    str_extract("\\d+")
  tibble(
    section_level = lvl,
    section_id = html_attr(section, "id"),
    section_number = html_text(html_node(header, "span.header-section-number")),
    section_name = str_replace(html_text(header), "^[\\d.]+\\s+", "")
  )
}

process_path <- function(path) {
  doc <- read_html(str_c(R4DS_INDEX, path))
  map_dfr(html_nodes(doc, "div.section"), process_section) %>%
    mutate(path = path)
}

create_toc <- function() {
  chapters <- r4ds_chapters()
  map_dfr(chapters$path, process_path) %>%
    mutate(url = str_c(R4DS_INDEX, path, "#", section_id))
}

main <- function() {
  toc <- create_toc()
  write_csv(toc, "r4ds-toc.csv")
}

main()
