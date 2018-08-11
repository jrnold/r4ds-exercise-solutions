
# Introduction

## Acknowledgments {-}

All the credit should go to Garrett Grolemund and Hadley Wickham for writing the truly fantastic *R for Data Science* book,
without which these solutions would not exist---literally.

This book was written in the open, with some people contributed pull requests to fix problems.
Thank you to all who contributed via [GitHub](https://github.com/jrnold/r4ds-exercise-solutions/graphs/contributors).

Thanks go to all contributers in alphabetical order: \@jmclawson, <benherbertson@gmail.com>, <dongzhuoer@mail.nankai.edu.cn>, <dongzhuoer@mail.nankai.edu.cn>, <kleinmarkgeard@gmail.com>, <mjones01@BattelleEcology.org>, <ndecoursin@gmail.com>, <nickywang100@gmail.com>, <theadamattack@gmail.com>, <theadamattack@gmail.com>, <tinhb92@gmail.com>.

## Organization {-}

The solutions are organized in the same order, and with the 
same numbers as in *R for Data Science*. Sections without
exercises are given a placeholder.

Like *R for Data Science*, packages used in each chapter are loaded in a code chunk at the start of the chapter in a section titled "Prerequisites".
If a package is used infrequently in solutions it may not 
be loaded, and functions using it will be called using the 
package name followed by two colons, as in `dplyr::mutate()` (see the *R for Data Science* [Introduction](http://r4ds.had.co.nz/introduction.html#running-r-code)).
We will also use `::` to be explicit about the package of a
function.

## Dependencies {-}

You can install all packages used in the solutions with the 
following line of code.

```r
devtools::install_github("jrnold/r4ds-exercise-solutions")
```

## Bugs/Contributing {-}

If you find any typos, errors in the solutions, have an alternative solution,
or think the solution could be improved, I would love your contributions.
Please open an issue at <https://github.com/jrnold/r4ds-exercise-solutions/issues> or a pull request at
<https://github.com/jrnold/r4ds-exercise-solutions/pulls>.

## Updates {-}

### 2018-08-06 {-}

-   Add sections on how to install dependencies, how the book is organized (#61, thanks dongzhuoer), contributing, and a colonophon.
-   Add answer 20.3.3 (#66, thanks dongzhuoer)
-   Correct chapter numbering, again. (dongzhuoer #93)
-   Fix Typos (dongzhuoer #92)

### 2018-08-05 {-}

-   Edit 20.4.4 so that `even_numbers()` handles special values correctly.
    Expand discussion and add testing of special cases for `not_last()`.
    (#74,#75 dongzhuoer)

-   Edit 20.4.5 to expand the discussion of the answer. (#75, thanks dongzhuoer)

-   Fix section and exercise numbers. (dongzhuoer #91)

### 2018-08-04 {-}

-   Fix section and exercise numbers in Chapter 27.

-   Rewrite Ex 20.4.3. Previous answer depended on printing the code in each function.
    This does not work for the current version of `set_names()`. Rewrote answer
    to describe the differences in features in each function. (#71)

-   Edit Ex 20.3.4. Fix function, expand and clarify function. (#70)

-   Correct 19.4.3. Return values instead of printing them. (dongzhuoer #72)

-   Edit Ex. 21.2.4. Incorrect exercise number. Pre-allocated vector is only 10 times faster. (dongzhuoer #80)

-   Edit Ex. 20.5.1. Keep order of elements in the the graphics the same as in the code. (dongzhuoer #79)

-   Edit Ex. 20.3.1 for clarity.

-   Fix Ex. 14.2.6. It was incorrect for a list of length two. (dongzhuoer #90)

-   Fix typos. (dongzhuoer #76, #77, #81, #82, #87, #88, #89)

### 2018-08-03 {-}

-   Updated 11.2.4. `read_csv()` now supports a `quote` argument. (dongzhuoer #53)
-   Edited 21.2.3. Added lyrics for all songs.
-   Edited 19.2.6
-   Edited 19.2.4. Used different definition of sample skewness. (#55)
-   Edited 19.5.2 (dongzhuoer #62)
-   Edited 19.4.6 (dongzhuoer #59)
-   Edited 19.4.5 (dongzhuoer #60)
-   Fix typos (dongzhuoer #51, #52, #54, #64, #63)

### 2018-08-01 {-}

-   Edit answer to 20.4.6 (nzxwang, #50)

### 2018-07-31 {-}

-   Add widget to view rstudiotips Twitter timeline
-   Fix answer to 5.7.4 (#44), and 5.7.5
-   Edit answers of 4.4.1

### 2018-07-30 {-}

-   Update answer to Ex 7.5.3.1 (#49)

### 2018-07-29 {-}

-   Add answer to Ex 3.5.4 (#32)
-   Move exercise 6 of 5.6 to exercise 8 of 5.7 (#43)
-   Update code for Ex 5.7.7 to be cleaner (#41)
-   Fix various typos (dongzhuoer #39, #40, #43, #45, #46, #47, #48)

### 2018-07-28 {-}

-   Fix miscellaneous typos (dongzhuoer, #31, #33, #34, #35, #36, #37)

### 2018-07-24 {-}

-   Fix bugs and typos in Ex. 5.2.4. Change a `>=` to `>` in part 1. Remove `!is.na()` conditions from `filter()` statements. (Thanks to JamesCuster, #28, #29)
-   Typo fixes (JamesCuster, #30)

### 2018-07-23 {-}

-   Fix bug and edit solution to Ex. 3.9.4 (Thanks to JamesCuster, #27)
-   Fix typo in Ex. 3.9.1 (Thanks to JamesCuster, #26)

### 2018-07-22 {-}

-   Edit plot in Ex. 12.2.3 (KleinGeard, #25)
-   Add examples to Ex. 12.4.2 (KleinGeard, #25)
-   Fix typo in Ex. 13.2.2 (KleinGeard, #25)
-   Correct exercise number in Ex. 13.2.3 (KleinGeard, #25)
-   Extended discussion of Ex. 13.3.2 (KleinGeard, #25)
-   New answer to Ex. 14.3.5.1.2 (KleinGeard)
-   Added answer to Ex. 14.4.2.1.d (KleinGeard, #25)
-   Miscellaneous minor typo fixes.

### 2018-07-21 {-}

-   Added answer to Ex. 11.3.4 (KleinGeard, #25)
-   Correct and edit Ex. 12.2.2. (KleinGeard, #25): Missing multiplication by 10,000, typo in code, and did not store results in the appropriate format.

### 2018-07-15 {-}

-   Added answer to Ex. 25.2.3
-   Edited Sec. 27.2. Corrected formatting of R markdown files.
-   Changed format of contributors list

### 2018-07-14 {-}

-   Added answer to Ex. 20.5.1
-   Added answer to Ex. 3.8.3 (KleinGeard, #23)
-   Edited answer to Ex. 5.2.1 to use modulo operator (KleinGeard, #23)
-   Corrected answer to Ex 3.3.5 (Ronald Gould, #24)
-   Corrected typos, URLs, HTML, markdown issues.

### 2018-05-08 {-}

-   Corrected answer to Ex. 3.6.6 (#21)
-   Added NEWS.md to track changes

## Colophon {-}

HTML and PDF versions of this book are available at <https://jrnold.github.io/r4ds-exercise-solutions>.
The book is powered by [bookdown](https://bookdown.org) which makes it easy to turn R markdown files into HTML, PDF, and EPUB.

This book was built with:

```r
devtools::session_info()
#> Session info -------------------------------------------------------------
#>  setting  value                       
#>  version  R version 3.5.1 (2018-07-02)
#>  system   x86_64, linux-gnu           
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  tz       Etc/UTC                     
#>  date     2018-08-11
#> Packages -----------------------------------------------------------------
#>  package    * version date       source        
#>  assertthat   0.2.0   2017-04-11 CRAN (R 3.5.1)
#>  backports    1.1.2   2017-12-13 CRAN (R 3.5.1)
#>  base       * 3.5.1   2018-08-08 local         
#>  bindr        0.1.1   2018-03-13 CRAN (R 3.5.1)
#>  bindrcpp   * 0.2.2   2018-03-29 CRAN (R 3.5.1)
#>  bookdown     0.7     2018-02-18 CRAN (R 3.5.1)
#>  codetools    0.2-15  2016-10-05 CRAN (R 3.5.1)
#>  compiler     3.5.1   2018-08-08 local         
#>  crayon       1.3.4   2017-09-16 CRAN (R 3.5.1)
#>  datasets   * 3.5.1   2018-08-08 local         
#>  devtools     1.13.6  2018-06-27 CRAN (R 3.5.1)
#>  digest       0.6.15  2018-01-28 CRAN (R 3.5.1)
#>  dplyr      * 0.7.6   2018-06-29 CRAN (R 3.5.1)
#>  evaluate     0.11    2018-07-17 CRAN (R 3.5.1)
#>  git2r        0.23.0  2018-07-17 CRAN (R 3.5.1)
#>  glue         1.3.0   2018-07-17 CRAN (R 3.5.1)
#>  graphics   * 3.5.1   2018-08-08 local         
#>  grDevices  * 3.5.1   2018-08-08 local         
#>  here         0.1     2017-05-28 cran (@0.1)   
#>  hms          0.4.2   2018-03-10 CRAN (R 3.5.1)
#>  htmltools    0.3.6   2017-04-28 CRAN (R 3.5.1)
#>  knitr        1.20    2018-02-20 CRAN (R 3.5.1)
#>  magrittr     1.5     2014-11-22 CRAN (R 3.5.1)
#>  memoise      1.1.0   2017-04-21 CRAN (R 3.5.1)
#>  methods    * 3.5.1   2018-08-08 local         
#>  pillar       1.3.0   2018-07-14 CRAN (R 3.5.1)
#>  pkgconfig    2.0.1   2017-03-21 CRAN (R 3.5.1)
#>  purrr        0.2.5   2018-05-29 CRAN (R 3.5.1)
#>  R6           2.2.2   2017-06-17 CRAN (R 3.5.1)
#>  Rcpp         0.12.18 2018-07-23 CRAN (R 3.5.1)
#>  readr        1.1.1   2017-05-16 CRAN (R 3.5.1)
#>  rlang        0.2.1   2018-05-30 CRAN (R 3.5.1)
#>  rmarkdown    1.10    2018-06-11 CRAN (R 3.5.1)
#>  rprojroot    1.3-2   2018-01-03 CRAN (R 3.5.1)
#>  stats      * 3.5.1   2018-08-08 local         
#>  stringi      1.2.4   2018-07-20 CRAN (R 3.5.1)
#>  stringr      1.3.1   2018-05-10 CRAN (R 3.5.1)
#>  tibble       1.4.2   2018-01-22 CRAN (R 3.5.1)
#>  tidyselect   0.2.4   2018-02-26 CRAN (R 3.5.1)
#>  tools        3.5.1   2018-08-08 local         
#>  utils      * 3.5.1   2018-08-08 local         
#>  withr        2.1.2   2018-03-15 CRAN (R 3.5.1)
#>  xfun         0.3     2018-07-06 CRAN (R 3.5.1)
#>  yaml         2.2.0   2018-07-25 CRAN (R 3.5.1)
```

<!-- match unopened div --><div>
