library("knitr")
library("readr")
library("rlang")
library("stringr")
library("CodeDepends")
library("fs")

CORE_PKGS = c("base", "methods", "stats", "graphics", "grDevices",
              "utils", "datasets")

colonshandler <- function(e, collector, basedir, input,
                           formulaInputs, update,
                           pipe = FALSE, nseval = FALSE, ..., iscall = FALSE)
{
  nameToUse = asVarName(deparse(e))
  if (iscall)
    collector$calls(nameToUse)
  else collector$vars(nameToUse, input = input)
}

libreqhandler <- function(e, collector, ...) {
  libname <- as.character(e[[2]])
  collector$library(libname)
  if (libname == "tidyverse") {
    for (lib in c("ggplot2", "tibble", "tidyr", "readr", "purrr", "dplyr",
                  "stringr", "forcats")) {
      collector$library(lib)
    }
  }
}

librarySymbols = function(nm, ..., verbose=FALSE, attach=FALSE) {
  deps = getDeps(nm, found = corePkgs , verbose = verbose)
  libs = c(nm, deps)
  libs = gsub("([[:space:]]|\\n)+", "", libs)
  #we load but DON'T attach the library and all its dependencies to resolve its symbols
  allsyms = unlist(lapply(libs, function(x)
  {

  }))
  allsyms
}

lookup_functions <- function(packages) {
  for (pkg in packages) {
    loadNamespace()
  }
}

collector <- inputCollector('::' = colonshandler,
                            ':::' = colonshandler,
                            library = libreqhandler,
                            requires = libreqhandler,
                            requireNamespace = libreqhandler,
                            checkLibrarySymbols = TRUE)

get_package <- function(func, e) {
  parsed_name <- str_match(func, "^([A-Za-z][A-Za-z0-9_.]*):::?(.*)$")
  if (!is.na(parsed_name[1, 2])) {
    list(nm = parsed_name[1, 2], pkg = parsed_name[1, 3])
  } else {
    list(nm = func, pkg = e[[func]] %||% NA_character_)
  }
}

resolveFunctions <- function(x, packages = character()) {
  libsymbols <- rlang::new_environment()
  libs <- c(CORE_PKGS, x@libraries, packages)
  for (ns in libs) {
    exports <- getNamespaceExports(ns)
    for (nm in exports) {
      libsymbols[[nm]] <- ns
    }
  }
  nonlocalfuncs <- setdiff(names(x@functions), x@outputs)
  map(nonlocalfuncs, get_package, e = libsymbols)
}

get_function_uses <- function(path) {
  print(path)
  old_opts <- options(knitr.purl.inline = FALSE)
  on.exit(options(old_opts))
  text <- read_file(path)
  out <- knitr::knit(text = text, tangle = TRUE, quiet = TRUE)
  expres <- parse_expr(str_c("{", out, "}"))
  funcs <- getInputs(expres, collector = collector)
  resolveFunctions(funcs) %>%
    map_dfr(as_tibble) %>%
    mutate(path = path)
}

funcuses <- dir_ls(regexp = "\\.Rmd$") %>%
  base::setdiff("contributions.Rmd") %>%
  map_dfr(get_function_uses)


