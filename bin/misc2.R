# Get number of words and lines of code for all R4DS sections

## Library r4ds information
library("readr")
library("httr")
library("dplyr")
library("xml2")
library("purrr")
library("rvest")
library("stringr")

process_chapter <- function(text) {
  doc <- read_html(text)
  main_section <- html_node(doc, "div.section.level1")
  sections <- html_nodes(main_section, "div.section.level2")
  # TODO: This is missing non-section introductions
  if (length(sections)) {
    map(sections, process_section)
  } else {
    list(process_section(main_section))
  }
}

process_section <- function(x) {
  list(id = xml_attr(x, "id"),
       number = xml_text(xml_node(x, "span.header-section-number")),
       text = get_text(x),
       code = get_code(x))
}

# Extract text from a section
extract_text <- function(.x) {
  out <- switch(xml_type(.x),
                element = {
                  if (xml_name(.x) %in% c("pre")) {
                    "\n"
                  } else {
                    str_c(map_chr(xml_contents(.x), get_text), collapse = "")
                  }
                },
                text = {
                  xml_text(.x)
                },
                "")
  if (length(out) == 0) {
    out <- ""
  }
  out
}

# Extract code comments from a section
get_code <- function(.x) {
  code <-  map_chr(xml_nodes(.x, "pre.sourceCode.r"), xml_text) %>%
    str_c(collapse = "\n")
  if (length(code)) {
    str_split(code, coll("\n")) %>%
      flatten_chr() %>%
      str_replace("#.*$", "") %>%
      discard(~ str_detect(.x, "^\\s*$"))
  } else {
    character()
  }
}

r4ds_toc <- read_csv("r4ds-toc.csv", col_types = cols(
  section_level = col_double(),
  section_id = col_character(),
  section_number = col_character(),
  section_name = col_character(),
  path = col_character(),
  url = col_character()
))

chapters <- filter(r4ds_toc, section_level == 1L) %>%
  mutate(html = map(url, ~ content(httr::GET(.x), as = "text")))

chapter_summaries <- map(chapters$html, process_chapter) %>%
  flatten() %>%
  map_dfr(~ tibble(id = .$id,
                   number = .$number,
                   text = stringi::stri_count_words(.$text),
                   lines_of_code = length(.$code)))
