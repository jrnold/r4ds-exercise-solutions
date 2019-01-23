any_missing <- function(x) any(is.na(x))

#' Check whether variables are a primary key
#'
#' Check whether a set of variables is a primary key for a data frame.
#' Unlike SQL databases, R data frames do not enforce a primary key
#' constraint. This function checks whether a set of variables uniquely
#' identify a row.
#'
#' @param tbl A tbl.
#' @param ... One or more unquoted expressions separated by commas.
#'   You can treat variable names like they are positions. This uses
#'   The same semantics as [dplyr::select()].
#' @return A logical vector of length one that is `TRUE` if the
#'   variables are primary key, and `FALSE` otherwise.
is_primary_key <- function(tbl, ...) {
  variables <- quos(...)
  # no elements can be missing
  has_nulls <- summarise_at(tbl, vars(UQS(variables)), any_missing)
  if (any(as.logical(has_nulls))) {
    return(FALSE)
  }
  nrow(distinct(tbl, !!!variables)) == nrow(tbl)
}

foo <- tribble(
  ~a, ~b, ~c,
  1, NA, 1,
  2, 2, 1,
  3, 3, 3
)

is_key(foo, a)
is_key(foo, b)
is_key(foo, c)

is_key(foo, 1:3)

# check that columns in y are are foreign key of x
is_foreign_key <- function(x, y, by = NULL) {
  # check that by is a primary key for y
  if (!rlang::eval_tidy(quo(is_primary_key(y, !!!by)))) {
    return(FALSE)
  }
  # check that all x are found in y
  !nrow(anti_join(x, y, by = by))
}

