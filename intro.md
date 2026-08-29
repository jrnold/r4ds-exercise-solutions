# Introduction {#introduction .r4ds-section}


```{=html}
<div class="alert alert-warning">
<p>
<strong>This book is superseded.</strong>
</p>
<p>
These are solutions to the 
<strong>1st edition</strong>
 of 
<em>R for Data Science</em>
. A 
<a href="https://r4ds.hadley.nz/">2nd edition</a>
 has since been published, with its own 
<a href="https://mine-cetinkaya-rundel.github.io/r4ds-solutions/">solutions to the exercises</a>
.
</p>
<p>This site is no longer maintained. It is kept online for reference.</p>
</div>
```




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

These solutions cover the 1st edition and are no longer maintained, so errors
in them will not be fixed. The repository is archived: issues and pull requests
are closed.

If you want to help with solutions to the current edition, contribute to
[R for Data Science (2e) --- Solutions to Exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/)
instead, at <https://github.com/mine-cetinkaya-rundel/r4ds-solutions>.

## Colophon {-}



HTML and PDF versions of this book are available at <https://jrnold.github.io/r4ds-exercise-solutions>.
The book is powered by [bookdown](https://bookdown.org/home) which makes it easy to turn R markdown files into HTML, PDF, and EPUB.

The source of this book is available on GitHub at <https://github.com/jrnold/r4ds-exercise-solutions>.
This book was built from commit [675bc75](https://github.com/jrnold/r4ds-exercise-solutions/tree/675bc752abc8ff68e54ed010cfc66b7f23a309bc).

This book was built with these R packages.

```r
devtools::session_info("r4ds.exercise.solutions")
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 4.0.3 (2020-10-10)
#>  os       Ubuntu 20.04.5 LTS          
#>  system   x86_64, linux-gnu           
#>  ui       X11                         
#>  language (EN)                        
#>  collate  en_US.UTF-8                 
#>  ctype    en_US.UTF-8                 
#>  tz       Etc/UTC                     
#>  date     2026-08-29                  
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  ! package                 * version date lib source
#>  R r4ds.exercise.solutions   <NA>    <NA> [?] <NA>  
#> 
#> [1] /usr/local/lib/R/site-library
#> [2] /usr/local/lib/R/library
#> 
#>  R ── Package was removed from disk.
```
