#!/usr/bin/env Rscript
#' For all sections anchor links and links to the relevant R4DS section
suppressPackageStartupMessages({
  library("rvest")
  library("fs")
  library("rlang")
  library("jsonlite")
  library("purrr")
  library("glue")
})

# Add link to r4ds after each section
add_r4ds_link_section <- function(x, r4ds_url) {
  # first child should be the heading
  header <- html_node(x, "h1,h2,h3,h4")
  href <- httr::modify_url(r4ds_url, frag = xml_attr(x, "id"))
  a <- xml_add_child(header, "a", href = href,
                     class = "r4ds-section-link section-link",
                     `aria-hidden` = "true")
  icon <- xml_add_child(a, "i",
                        class = "fa fa-external-link",
                        `aria-hidden` = "true")
}

add_r4ds_links <- function(doc, path, r4ds_url) {
  # r4ds-section used to indicate R4DS
  r4ds_sections <- html_nodes(doc, ".r4ds-section")
  r4ds_path_url <- httr::modify_url(r4ds_url,
                                    path = as.character(path))
  walk(r4ds_sections, add_r4ds_link_section, r4ds_url = r4ds_path_url)
}

# Add link to r4ds after each section
add_anchor_section <- function(x) {
  # first child should be the heading
  header <- html_node(x, "h1,h2,h3,h4")
  href <- paste0("#", xml_attr(x, "id"))
  a <- xml_add_child(header, "a", href = href, class = "anchor section-link",
                     `aria-hidden` = "true", .where = 0)
  icon <- xml_add_child(a, "i",
                        class = "fa fa-link",
                        `aria-hidden` = "true")
}

# Add link to r4ds after each section
add_anchors <- function(doc) {
  walk(html_nodes(doc, "div.section"), add_anchor_section)
}

handle_page <- function(path, r4ds_url, output_dir) {
  # read HTML for a file
  filename <- fs::path(output_dir, path)
  doc <- read_html(filename)
  add_r4ds_links(doc, path = path, r4ds_url = r4ds_url)
  add_anchors(doc)
  cat(glue("Adding links to {filename}"), "\n\n")
  write_html(doc, filename, options = c("as_html", "format"))
}

main <- function() {
  # read table of contents to get list of HTML files
  toc_filename <- "toc.json"
  output_dir <- bookdown:::load_config()[["output_dir"]]
  toc <- read_json(fs::path(output_dir, toc_filename))

  # Get URL of r4ds
  config <- yaml::read_yaml(fs::path("_config.yml"))
  r4ds_url <- config$r4ds$url
  walk(unlist(map(toc, "path")), handle_page, r4ds_url, output_dir)
}

main()
