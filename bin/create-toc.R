#!/usr/bin/env Rscript
#' Write a table of contents
#'
#' This writes out a table of contents for R4DS Solutions to a JSON file.
#' This is useful for quickly navigating or looking up exercises.
#'
#'
suppressPackageStartupMessages({
  library("rvest")
  library("purrr")
  library("stringr")
  library("jsonlite")
  library("tibble")
  library("fs")
  library("dplyr")
  library("glue")
  library("optparse")
})

get_section_title <- function(x) {
  is_section_number <- function(x) {
    (xml_type(x) == "element") &&
      xml_name(x) == "span" &&
      html_has_class(x, "header-section-number")
  }
  header <- html_children(x)[[1]]
  title <- discard(xml_contents(header), is_section_number) %>%
    map_chr(html_text) %>%
    str_c(collapse = "") %>%
    str_trim()
  number <- html_text(html_node(header, "span.header-section-number"))
  list(title = title, number = number)
}

#' Return the classes of a HTML element
html_classes <- function(x) {
  klass <- html_attr(x, "class")
  if (!length(klass) || is.na(klass)) {
    character()
  } else {
    # Space separated - includes space, tab, and newlines
    # https://www.w3.org/TR/2011/WD-html5-20110525/elements.html#classes
    unique(str_split(str_trim(klass), "\\s")[[1]])
  }
}

#' Check whether a HTML element has a class
html_has_class <- function(x, kls) kls %in% html_classes(x)

# Get section level number
get_level <- function(x) {
  lvl <- str_extract(str_subset(html_classes(x), "^level\\d+$"),
                                 "\\d+")
  as.integer(lvl)
}

#' parse each section
process_section <- function(x, path = "/") {
  lvl <- get_level(x)
  current <- rlang::list2(id = html_attr(x, "id"),
                          !!!get_section_title(x),
                          path = path)
  # find next level of nodes
  sections <- map(html_nodes(x, glue("div.section.level{lvl + 1}")),
                             process_section, path = path)
  names(sections) <- map_chr(sections, "id")
  current[["sections"]] <- sections
  current
}

process_page <- function(path, output_dir) {
  doc <- read_html(fs::path(output_dir, path))
  # find top level heading
  process_section(html_node(doc, "div.section.level1"), path = path)
}

process_chapter <- function(x, output_dir) {
  a <- html_node(x, "a")
  data_level <- html_attr(x, "data-level")
  out <- list(chapter = if_else(data_level == "", NA_integer_,
                         as.integer(data_level)),
               path = html_attr(x, "data-path"),
               href = html_attr(a, "href"),
               name = str_replace(html_text(a), "^[\\d.]+ ", ""))
  out$sections <- process_page(out[["path"]], output_dir)
  out
}

#' create and write the table of contents
write_toc <- function(output_dir, path) {
  index <- read_html(file.path(output_dir, "index.html"))
  book_summary <- html_nodes(index, "div.book-summary>nav>ul")
  chapters <- map(html_nodes(book_summary, xpath = "./li[@class='chapter']"),
                  process_chapter, output_dir)
  outfile <- fs::path(output_dir, path)
  cat(glue("Writing to {outfile}\n"))
  write_json(chapters, outfile)
}

main <- function() {
  description <- str_c(
    "Create a JSON table of contents for R4DS containing the sections ",
    "for all HTML files"
  )
  parser <- OptionParser(description = description)
  opts <- parse_args(parser, positional_arguments = TRUE)
  path <- if (length(opts$args) < 1) {
    "toc.json"
  } else {
    opts$args[[1]]
  }
  output_dir <- bookdown:::load_config()$output_dir
  write_toc(output_dir, path)
}

main()
