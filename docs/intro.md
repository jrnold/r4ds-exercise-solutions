
# Introduction

## Acknowledgment

All the credit should go to Garrett Grolemond and Hadley Wickham for writing the truly fantastic *R for Data Science* book, 
without which these solutions would not exist---literally.

This book was written in the open, with some people contributed pull requests to fix problems.
Thank you to all who contributed via GitHub:

```r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
# git --no-pager shortlog -ns > contribs.txt
contribs <- readr::read_tsv("contribs.txt", col_names = c("n", "name"))
#> Parsed with column specification:
#> cols(
#>   n = col_integer(),
#>   name = col_character()
#> )

contribs <- contribs %>% 
  filter(!name %in% c("jrnold", "Jeffrey Arnold")) %>%
  arrange(name) %>% 
  mutate(uname = ifelse(!grepl(" ", name), paste0("@", name), name))

cat("Thanks go to all contributers in alphabetical order: ")
#> Thanks go to all contributers in alphabetical order:
cat(paste0(contribs$uname, collapse = ", "))
#> @A, Adam Blake, @Ben, James Clawson, Nick DeCoursin
cat(".\n")
#> .
```

