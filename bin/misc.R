any_missing <- function(x) any(is.na(x))

is_key <- function(tbl, ...) {
  variables <- quos(...)
  has_nulls <- summarise_at(tbl, vars(UQS(variables)), any_missing)
  if (any(as.logical(has_nulls))) {
    return(FALSE)
  }
  nrow(distinct(tbl, !!!variables)) == nrow(tbl)
}

# check that columns in y are are foreign key of x
is_foreign_key <- function(x, y, by = NULL) {
  # check that y is a primary key
  if (!rlang::eval_tidy(quo(is_key(y, !!!by)))) {
    return(FALSE)
  }
  # check that all x are found in y
  !nrow(anti_join(x, y, by = by))
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

