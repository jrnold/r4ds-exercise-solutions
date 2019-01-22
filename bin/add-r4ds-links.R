suppressPackageStartupMessages({
  library("rvest")
  library("rjson")
  library("fs")
  library("rlang")
  library("jsonlite")
})

eval_tags <- function(expr) {
  eval_tidy(enquo(expr), data = htmltools::tags)
}

handle_section <- function(x, r4ds_url) {
  # first child should be the heading
  header <- html_node(x, "h1,h2,h3,h4")
  href <- httr::modify_url(r4ds_url, frag = xml_attr(x, "id"))
  a <- xml_add_child(header, "a", href = href)
  icon <- xml_add_child(a, "i", class = "fa fa-external-link r4ds-section-link",
                        `aria-hidden` = "true")
}

handle_page <- function(path, r4ds_url, output_dir) {
  # read HTML for a file
  filename <- fs::path(output_dir, path)
  doc <- read_html(filename)
  # r4ds-section used to indicate R4DS
  r4ds_sections <- html_nodes(doc, ".r4ds-section")
  r4ds_path_url <- httr::modify_url(r4ds_url,
                                    path = as.character(path))
  map(r4ds_sections, handle_section, r4ds_url = r4ds_path_url)
  write_html(doc, filename)
}

# read table of contents to get list of HTML files
toc_filename <- "toc.json"
toc <- read_json(fs::path(output_dir, toc_filename))
output_dir <- bookdown:::load_config()[["output_dir"]]

# Get URL of r4ds
config <- yaml::read_yaml(fs::path("_config.yml"))
r4ds_url <- config$r4ds$url
doc <- handle_page("data-visualisation.html", r4ds_url, output_dir)

