#!/usr/bin/env Rscript
#' Check that sections match R4DS
suppressPackageStartupMessages({
  library("xml2")
  library("rvest")
  library("purrr")
  library("tibble")
  library("dplyr")
})

handle_section <- function(x) {
  header <- html_node(x, "h1,h2,h3,h4,h5")
  tibble(id = as.character(html_attr(x, "id")),
         title = stringr::str_replace(html_text(header),
                                      "^\\d+(\\.\\d+)*\\s+", ""),
         tag = xml_name(header))
}

handle_html_file <- function(path, output_dir, r4ds_url) {
  doc <- read_html(fs::path(output_dir, path))
  solution_sections <- map_dfr(html_nodes(doc, "div.section.r4ds-section"),
                               handle_section)
  if (nrow(solution_sections)) {
    solution_sections$path <- path

    r4ds_url <- httr::modify_url(r4ds_url, path = path)
    r4ds_doc <- read_html(r4ds_url)
    r4ds_sections <- map_dfr(html_nodes(r4ds_doc, "div.section"),
                             handle_section)

    left_join(solution_sections, r4ds_sections,
              by = "id", suffix = c("_solutions", "_r4ds"))
  }
}

# Find any sections in solutions not in R4DS
output_dir <- bookdown:::load_config()$output_dir
filenames <- map(jsonlite::read_json(fs::path(output_dir, "toc.json")),
                 "path") %>%
  map_chr(1) %>%
  keep(~ !.x %in% c("references.html"))

config <- yaml::read_yaml("_config.yml")

sections <- map_dfr(filenames, handle_html_file, output_dir = output_dir,
                    r4ds_url = config$r4ds$url)
