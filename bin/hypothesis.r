# Create GitHub issuses from hypothes.is annotations
suppressPackageStartupMessages({
  library("rapiclient")
  library("httr")
  library("ghql")
  library('purrr')
  library("stringr")
  library("glue")
  library("ghql")
})



HYPOTHESIS_USER <- "acct:jrnold@hypothes.is"
GITHUB_LABEL_INFO <- list(id="MDU6TGFiZWwxMzE5MTEyNTM4", name="hypothes.is")
GITHUB_REPO_ID  <- "MDEwOlJlcG9zaXRvcnk3NjgzMTMxMQ=="


get_annotations <- function(search_after, limit=200) {
  hypothesis_api <- suppressWarnings(get_api(url = "https://h.readthedocs.io/en/latest/api-reference/hypothesis-v1.yaml"))
  hypothesis_api$host <- "hypothes.is"
  hypothesis_api$basePath <- "/api"
  operations <- get_operations(hypothesis_api)
  res <- operations$Search_for_annotations(search_after=search_after, sort="created", order="asc",
                                           limit=limit,
                                           wildcard_uri = "https://jrnold.github.io/r4ds-exercise-solutions/*")
  content(res) %>%
    pluck("rows") %>%
    keep(function(x) {
      x$user != HYPOTHESIS_USER
    })
}

annotation_to_issue <- function(annotation, con) {
  x <- annotation[c("user", "id", "created", "updated", "uri", "text")]
  x[["link_incontext"]] <- annotation$links$incontext
  x[["link_html"]] <- annotation$links$html
  x[["text"]] <- str_c("> ", str_split(x$text, "\n")[[1]], collapse = "\n")
  title <- glue("Respond to {link_html}", .envir = x)
  body <- glue("Respond to hypothes.is annotation [{id}]({link_html}) on {uri} (user: {user}, created: {created}, updated: {updated})\n", "{text}",
                "\n", "Link: {link_incontext}",
                .envir = x, .sep = "\n")

  qry <- Query$new()
  qry$query('createNewIssue', "
  mutation createNewIssue($repositoryId: String!, $title: String!, $body: String!) {
    createIssue(input: {repositoryId: $repositoryId, title: $title, body: $body}) {
      issue{
        id
        title
      }
  }
}")

  qry$query('addLabelsToIssue', "
  mutation addLabelsToIssue($issueId: String!, $labels: [String!]!) {
    addLabelsToLabelable(input: {labelableId: $issueId, labelIds: $labels}) {
      labelable {
        ... on Issue {
          id
        }
      }
    }
}")

  res <- con$exec(qry$queries$createNewIssue, list(title = title, body = body, repositoryId = GITHUB_REPO_ID))
  data <- jsonlite::parse_json(res)$data
  issue_id <- data$createIssue$issue$id
  cat("Created issue ", data$createIssue$issue$title, "\n")
  res2 <- con$exec(qry$queries$addLabelsToIssue, list(issueId = issue_id, labels = list(GITHUB_LABEL_INFO$id)))
  cat("Added label to issue ", data$createIssue$issue$title, "\n")
  issue_id
}

connect_github <- function() {
  token <- Sys.getenv("GITHUB_PAT")
  con <- GraphqlClient$new(
    url = "https://api.github.com/graphql",
    headers = list(Authorization = paste0("Bearer ", token))
  )
  con$load_schema()
  con
}

main <- function() {
  search_after <- "2019-09-01T00:00:00"
  annotations <- get_annotations(search_after = search_after)
  con <- connect_github()
  map(annotations, annotation_to_issue, con)
}

annotations <- main()

# con$load_schema()
# qry <- Query$new()
# qry$query("getRepoId", "{
#   repository(owner: \"jrnold\", name: \"r4ds-exercise-solutions\") {
#     id
#     name
#     labels {
#       edges {
#         node {
#           id
#           name
#         }
#       }
#     }
#   }
# }")
# (x <- con$exec(qry$queries$getRepoId))

