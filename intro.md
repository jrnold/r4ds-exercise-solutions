# Introduction {#introduction .r4ds-section}



## How this book is organized {-}

The book is divided into sections in with the same numbers and titles as those in *R for Data Science*. 
Not all sections have exercises.
Those sections without exercises have placeholder text indicating that there are no exercises.
The text for each exercise is followed by the solution. 

Like *R for Data Science*, packages used in each chapter are loaded in a code chunk at the start of the chapter in a section titled "Prerequisites".
If exercises depend on code in a section of *R for Data Science* it is either provided before the exercises or within the exercise solution.

If a package is used infrequently in solutions it may not be loaded, and functions using it will be called using the package name followed by two colons, as in `dplyr::mutate()` (see the *R for Data Science* [Introduction](https://r4ds.had.co.nz/introduction.html#running-r-code)).
The double colon may also be used to be explicit about the package from which a function comes.

## Prerequisites {-}

This book is a complement to, not a substitute of, [R for Data Science]().
It only provides the exercise solutions for it. 
See the [R for Data Science](https://r4ds.had.co.nz/introduction.html#prerequisites) prerequisites.

Additional, the solutions use several packages that are not used in *R4DS*.
You can install all packages required to run the code in this book with the following line of code.

```r
devtools::install_github("jrnold/r4ds-exercise-solutions")
```

## Bugs/Contributing {-}

If you find any typos, errors in the solutions, have an alternative solution,
or think the solution could be improved, I would love your contributions.
The best way to contribute is through GitHub.
Please open an issue at <https://github.com/jrnold/r4ds-exercise-solutions/issues> or a pull request at
<https://github.com/jrnold/r4ds-exercise-solutions/pulls>.

## Colophon {-}



HTML and PDF versions of this book are available at <https://jrnold.github.io/r4ds-exercise-solutions>.
The book is powered by [bookdown](https://bookdown.org/home) which makes it easy to turn R markdown files into HTML, PDF, and EPUB.

The source of this book is available on GitHub at <https://github.com/jrnold/r4ds-exercise-solutions>.
This book was built from commit [f0d0f0d](https://github.com/jrnold/r4ds-exercise-solutions/tree/f0d0f0de3c4e3c14bcb01ea700d45838200b95ad).

This book was built with these R packages.

```r
devtools::session_info("r4ds.exercise.solutions")
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 4.0.0 (2020-04-24)
#>  os       Ubuntu 16.04.6 LTS          
#>  system   x86_64, linux-gnu           
#>  ui       X11                         
#>  language en_US.UTF-8                 
#>  collate  en_US.UTF-8                 
#>  ctype    en_US.UTF-8                 
#>  tz       UTC                         
#>  date     2020-07-19                  
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  ! package                 * version date lib source
#>  R r4ds.exercise.solutions   <NA>    <NA> [?] <NA>  
#> 
#> [1] /home/travis/R/Library
#> [2] /usr/local/lib/R/site-library
#> [3] /home/travis/R-bin/lib/R/library
#> 
#>  R ── Package was removed from disk.
```
