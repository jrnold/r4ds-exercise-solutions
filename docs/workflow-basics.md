
---
output: html_document
editor_options:
  chunk_output_type: console
---
# Workflow: basics

## Prerequisites {-}


```r
library("tidyverse")
```

## Coding basics

No exercises

## What's in a name?

No exercises

## Calling functions

No exercises

## Practice

### Exercise <span class="exercise-number">4.4.1</span> {.unnumbered .exercise}

<div class="question">
Why does this code not work?

```r
my_variable <- 10
my_varıable
#> Error in eval(expr, envir, enclos): object 'my_varıable' not found
```
</div>

<div class="answer">

The variable being printed is `my_varıable`, not `my_variable`:
the seventh character is "ı" ("[LATIN SMALL LETTER DOTLESS I](https://en.wikipedia.org/wiki/Dotted_and_dotless_I)"), not "i".

While it wouldn't have helped much in this case, the importance of
distinguishing characters in code is reasons why fonts which clearly
distinguish similar characters are preferred in programming.
It is especially important to distinguish between two sets of similar looking characters:

-   the numeral zero (0), the Latin small letter O (o), and the Latin capital letter O (O),
-   the numeral one (1), the Latin small letter I (i), the Latin capital letter I (I), and Latin small letter L (l).

In these fonts, zero and the Latin letter O are often distinguished by using a glyph for zero that uses either a dot in the interior or a slash through it.
Some examples of fonts with dotted or slashed zero glyphs  are Consolas, Deja Vu Sans Mono, Monaco, Menlo, [Source Sans Pro](https://adobe-fonts.github.io/source-sans-pro/), and FiraCode.

Error messages of the form `"object '...' not found"` mean exactly what they say.
R cannot find an object with that name.
Unfortunately, the error does not tell you why that object cannot be found, because R does not know the reason that the object does not exist.
The most common scenarios in which I encounter this error message are

1.  I forgot to create the object, or an error prevented the object from being created.

1.  I made a typo in the object's name, either when using it or when I created it (as in the example above), or I forgot what I had originally named it.
    If you find yourself often writing the wrong name for an object,
    it is a good indication that the original name was not a good one.

1.  I forgot to load the package that contains the object using `library()`.

</div>

### Exercise <span class="exercise-number">4.4.2</span> {.unnumbered .exercise}

<div class="question">

Tweak each of the following R commands so that they run correctly:

</div>

<div class="answer">


```r
ggplot(dota = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))
#> Error in FUN(X[[i]], ...): object 'displ' not found
```



\begin{center}\includegraphics[width=0.7\linewidth]{workflow-basics_files/figure-latex/unnamed-chunk-4-1} \end{center}
The error message is `argument "data" is missing, with no default`.

It looks like a typo, `dota` instead of `data`.

```r
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))
```



\begin{center}\includegraphics[width=0.7\linewidth]{workflow-basics_files/figure-latex/unnamed-chunk-5-1} \end{center}


```r
fliter(mpg, cyl = 8)
#> Error in fliter(mpg, cyl = 8): could not find function "fliter"
```

R could not find the function `fliter()` because we made a typo: `fliter` instead of `filter`.


```r
filter(mpg, cyl = 8)
#> Error: `cyl` (`cyl = 8`) must not be named, do you need `==`?
```

We aren't done yet. But the error message gives a suggestion. Let's follow it.


```r
filter(mpg, cyl == 8)
#> # A tibble: 70 x 11
#>   manufacturer model displ  year   cyl trans drv     cty   hwy fl    class
#>   <chr>        <chr> <dbl> <int> <int> <chr> <chr> <int> <int> <chr> <chr>
#> 1 audi         a6 q~   4.2  2008     8 auto~ 4        16    23 p     mids~
#> 2 chevrolet    c150~   5.3  2008     8 auto~ r        14    20 r     suv  
#> 3 chevrolet    c150~   5.3  2008     8 auto~ r        11    15 e     suv  
#> 4 chevrolet    c150~   5.3  2008     8 auto~ r        14    20 r     suv  
#> 5 chevrolet    c150~   5.7  1999     8 auto~ r        13    17 r     suv  
#> 6 chevrolet    c150~   6    2008     8 auto~ r        12    17 r     suv  
#> # ... with 64 more rows
```


```r
filter(diamond, carat > 3)
#> Error in filter(diamond, carat > 3): object 'diamond' not found
```

R says it can't find the object `diamond`.
This is a typo; the data frame is named `diamonds`.

```r
filter(diamonds, carat > 3)
#> # A tibble: 32 x 10
#>   carat cut     color clarity depth table price     x     y     z
#>   <dbl> <ord>   <ord> <ord>   <dbl> <dbl> <int> <dbl> <dbl> <dbl>
#> 1  3.01 Premium I     I1       62.7    58  8040  9.1   8.97  5.67
#> 2  3.11 Fair    J     I1       65.9    57  9823  9.15  9.02  5.98
#> 3  3.01 Premium F     I1       62.2    56  9925  9.24  9.13  5.73
#> 4  3.05 Premium E     I1       60.9    58 10453  9.26  9.25  5.66
#> 5  3.02 Fair    I     I1       65.2    56 10577  9.11  9.02  5.91
#> 6  3.01 Fair    H     I1       56.1    62 10761  9.54  9.38  5.31
#> # ... with 26 more rows
```

How did I know? I started typing in `diamond` and RStudio completed it to `diamonds`.
Since `diamonds` includes the variable `carat` and the code works, that appears to have been the problem.

</div>

### Exercise <span class="exercise-number">4.4.3</span> {.unnumbered .exercise}

<div class="question">
Press *Alt + Shift + K*. What happens? How can you get to the same place using the menus?
</div>

<div class="answer">

This gives a menu with keyboard shortcuts. This can be found in the menu under `Tools -> Keyboard Shortcuts Help`.

</div>
