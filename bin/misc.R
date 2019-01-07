any_missing <- function(x) any(is.na(x))

is_key <- function(tbl, ...) {
  variables <- quos(...)
  has_nulls <- summarise_at(tbl, vars(!!!variables), any_missing)
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

