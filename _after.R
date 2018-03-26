if (!is.null(STATE)) {
  message(glue::glue("Unclosed Question or Answer block. STATE = {}"))
  stop()
}
