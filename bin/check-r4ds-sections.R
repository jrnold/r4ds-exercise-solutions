#!/usr/bin/env Rscript
#' Check that sections in Soluions match those in R4DS
#'
#' For all sections in the solutions, check that
#'
#' -   It appears in R4DS
#' -   It has the same title as in R4DS
#' -   It has the same heading level as R4DS
#'
#' It does not check whether all sections in R4DS appear in the Solutions
#'
suppressPackageStartupMessages({
  library("xml2")
  library("rvest")
  library("purrr")
  library("tibble")
  library("dplyr")
  library("glue")
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

main <- function() {
  # Find any sections in solutions not in R4DS
  output_dir <- bookdown:::load_config()$output_dir
  filenames <- map(jsonlite::read_json(fs::path(output_dir, "toc.json")),
                   "path") %>%
    map_chr(1) %>%
    keep(~ !.x %in% c("references.html"))

  config <- yaml::read_yaml("_config.yml")

  sections <- map_dfr(filenames, handle_html_file, output_dir = output_dir,
                      r4ds_url = config$r4ds$url)

  missing_ids <- filter(sections, is.na(title_r4ds)) %>%
    select(path, id)

  different_headings <- filter(sections, tag_solutions != tag_r4ds) %>%
    select(path, id, tag_solutions, tag_r4ds)

  different_titles <- filter(sections, title_solutions != title_r4ds) %>%
    select(path, id, title_solutions, title_r4ds)

  if (any(c(nrow(missing_ids) > 0, nrow(different_headings) > 0,
            nrow(different_titles) > 0))) {
    if (nrow(missing_ids) > 0) {
      cat("There sections have IDs not in R4DS", file = stderr())
      cat(glue_data(missing_ids, "{path}#{id}"), file = stderr())
    }
    if (nrow(different_titles) > 0) {
      cat("These sections have different titles than R4DS:")
      cat(glue_data(missing_ids, "{path}#{id}: '{title_solutions}' (solutions) '{title_r4ds}' (R4DS)"),
          file = stderr())
    }
    if (nrow(different_headings) > 0) {
      cat("These sections have different heading levels than R4DS:")
      cat(glue_data(missing_ids, "{path}#{id}: '{tag_solutions}' (solutions) '{tag_r4ds}' (R4DS)"),
          file = stderr())
    }
    quit(save = "no", status = 1)
  }
}

main()
