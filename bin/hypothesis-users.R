library("httr")
library("jsonlite")
library("rapiclient")
library("purrr")

user_url <- function(x) {
  username <- str_match(x, "acct:(.*)@")[1, 2]
  url <- str_c("https://hypothes.is/users/", username)
  str_c("[\\@", username, "](", url, ")")
}

annotations <- GET("https://hypothes.is/api/search",
                  query = list(wildcard_uri = "https://jrnold.github.io/r4ds-exercise-solutions/*")) %>%
  content()

hypothesis_users <- annotations %>%
  pluck("rows") %>%
  keep(~ !.x$flagged) %>%
  map_chr("user") %>%
  unique() %>%
  discard(~ .x == "acct:jrnold@hypothes.is") %>%
  map_chr(user_url) %>%
  sort()
