#' Parse Rmd files to get what happened in them.
library("drake")
library("CodeDepends")
library("globals")


code <- str_c(readLines('visualize.R'), collapse = "\n")
globals <- globalsOf(rlang::parse_expr(str_c("{", code, "}")), substitute = FALSE,
                     mustExist = FALSE)

sc <- CodeDepends::readScript("visualize.R")
getInputs(sc)
getVariables(sc)


list.functions.in.file <- function(filename,alphabetic=TRUE) {
  # from hrbrmstr, StackExchange 3/1/2015
  if(!file.exists(filename)) { stop("couldn't find file ",filename) }
  if(!get.ext(filename)=="R") { warning("expecting *.R file, will try to proceed") }
  # requireNameSpace("dplyr")
  tmp <- getParseData(parse(filename, keep.source=TRUE))
  # next line does what dplyr used to do!
  nms <- tmp$text[which(tmp$token=="SYMBOL_FUNCTION_CALL")]
  funs <- unique(if(alphabetic) { sort(nms) } else { nms })
  #crit <- quote(token == "SYMBOL_FUNCTION_CALL")
  #tmp <- dplyr::filter(tmp, .dots = crit)
  #tmp <- dplyr::filter(tmp,token=="SYMBOL_FUNCTION_CALL")
  #tmp <- unique(if(alphabetic) { sort(tmp$text) } else { tmp$text })
  src <- paste(as.vector(sapply(funs, find)))
  outlist <- tapply(funs, factor(src), c)
  return(outlist)
}

## packrat::expressionDependencies
##
