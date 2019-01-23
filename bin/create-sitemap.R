suppressPackageStartupMessages({
  library("xml2")
  library("optparse")
  library("glue")
})

sitemap_url_info <- function(path, base_url, priority = 0.5,
                        changefreq = "daily") {
  lastmod <- format(file.info(path)$mtime, format = "%Y-%m-%d",
                    tz = "UTC")
  loc <- paste0(stringr::str_replace(base_url, "/$", ""), "/", basename(path))
  list(lastmod = lastmod, loc = loc, priority = priority,
       changefreq = changefreq)
}

create_sitemap <- function(output_dir, base_url,
                           pattern = "^.*\\.html$",
                           excludes = character(),
                           changfreq = "daily", priority = 0.5) {
  SITEMAP_XMLNS <- "http://www.sitemaps.org/schemas/sitemap/0.9"
  filenames <- dir(output_dir, pattern = pattern)
  filenames <- base::setdiff(filenames, excludes)
  filenames <- file.path(output_dir, filenames)
  sitemap <- xml_new_root("urlset", xmlns = SITEMAP_XMLNS)
  for (file in filenames) {
    info <- sitemap_url_info(file, base_url = base_url)
    url <- xml_add_child(sitemap, "url")
    xml_add_child(url, "loc", info$loc)
    xml_add_child(url, "lastmod", info$lastmod)
    xml_add_child(url, "priority", info$priority)
    xml_add_child(url, "changefreq", info$changefreq)
  }
  sitemap_loc <- file.path(output_dir, "sitemap.xml")
  cat(glue("Writing to {sitemap_loc}\n"))
  write_xml(sitemap, sitemap_loc)
}

main <- function() {
  output_dir <- bookdown:::load_config()$output_dir
  config <- yaml::read_yaml(here::here("_config.yml"))
  create_sitemap(output_dir, config$deploy_url)
}

main()
