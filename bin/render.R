#!/usr/bin/env Rscript
# Script to render book
suppressPackageStartupMessages({
  library("optparse")
  library("xml2")
})

# From devtools:::git_uncommitted
git_uncommitted <- function(path = ".") {
  r <- git2r::repository(path, discover = TRUE)
  st <- vapply(git2r::status(r), length, integer(1))
  any(st != 0)
}

# Adapted from devtools:::git_uncommitted
check_uncommitted <- function(path = ".") {
  if (git_uncommitted(path)) {
    stop(paste("Uncommitted files.",
      "All files should be committed before release.",
      "Please add and commit.",
      sep = " "
    ))
  }
}

create_url_info <- function(path, base_url, priority = 0.5,
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
  print(output_dir)
  filenames <- dir(output_dir, pattern = pattern)
  filenames <- base::setdiff(filenames, excludes)
  filenames <- file.path(output_dir, filenames)
  sitemap <- xml_new_root("urlset", xmlns = SITEMAP_XMLNS)
  for (file in filenames) {
    info <- create_url_info(file, base_url = base_url)
    url <- xml_add_child(sitemap, "url")
    xml_add_child(url, "loc", info$loc)
    xml_add_child(url, "lastmod", info$lastmod)
    xml_add_child(url, "priority", info$priority)
    xml_add_child(url, "changefreq", info$changefreq)
  }
  sitemap_loc <- file.path(output_dir, "sitemap.xml")
  write_xml(sitemap, sitemap_loc)
}

create_outdir <- function(output_dir) {
  # create nojekyll if it doesn't exist
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  nojekyll <- file.path(output_dir, ".nojekyll")
  if (!file.exists(nojekyll)) {
    cat("Creating ", nojekyll, "\n")
    con <- file(nojekyll, "w")
    close(con)
  }
}

render <- function(input, output_format = "all", force = FALSE,
                   config = "_config.yml", ...) {
  if (rmarkdown::pandoc_version() < 2) {
    stop("This book requires pandoc > 2")
  }
  if (!force) {
    check_uncommitted(dirname(input[[1]]))
  }
  config <- yaml::read_yaml(config)
  output_dir <- bookdown:::load_config()$output_dir
  create_outdir(output_dir)
  bookdown::render_book(input = "index.Rmd", ...)
  create_sitemap(output_dir, config$url)
}

main <- function(args = NULL) {
  option_list <- list(
    make_option(c("-f", "--force"),
      action = "store_true", default = FALSE,
      help = "Render even if there are uncomitted changes."
    ),
    make_option(c("-q", "--quiet"),
      action = "store_true", default = FALSE,
      help = "Do not use verbose output"
    ),
    make_option("--to", default = "all",
                help = "Bookdown output format to use"),
    make_option("--config", default = "_config.yml",
                help = "Path to project config file. Needed for output URL.")
  )
  if (is.null(args)) {
    args <- commandArgs(TRUE)
  }
  opts <- parse_args(OptionParser(
      usage = "%prog [options] [output_format|all|html|pdf]",
      option_list = option_list
    ),
    args = args,
    positional_arguments = TRUE,
    convert_hyphens_to_underscores = TRUE
  )
  output_format <- opts$options$to
  if (output_format == "html") {
    output_format <- "bookdown::gitbook"
  } else if (output_format == "pdf") {
    output_format <- "bookdown::pdf_book"
  }
  input <- if (!length(opts$args)) {
    "index.Rmd"
  } else {
    opts$args
  }
  render(
    input,
    output_format = output_format,
    force = opts$options$force,
    quiet = opts$options$quiet,
    config = opts$options$config,
  )
}

main()
