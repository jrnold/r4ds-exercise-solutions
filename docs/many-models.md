
# Many models

## Introduction


```r
library("modelr")
library("tidyverse")
#> -- Attaching packages ---------------------------------- tidyverse 1.2.1 --
#> √ ggplot2 3.0.0     √ purrr   0.2.5
#> √ tibble  1.4.2     √ dplyr   0.7.6
#> √ tidyr   0.8.1     √ stringr 1.3.1
#> √ readr   1.1.1     √ forcats 0.3.0
#> -- Conflicts ------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library("gapminder")
```

## Gapminder

### Exercise <span class="exercise-number">25.2.1</span> {.unnumbered .exercise}

A linear trend seems to be slightly too simple for the overall trend. Can you do better with a quadratic polynomial? How can you interpret the coefficients of the quadratic? (Hint you might want to transform year so that it has mean zero.)

The following code replicates the analysis in the chapter but the function `country_model()` is replaced with a regression that includes the year squared.

```r
lifeExp ~ poly(year, 2)
```


```r
country_model <- function(df) {
  lm(lifeExp ~ poly(year - median(year), 2), data = df)
}

by_country <- gapminder %>%
  group_by(country, continent) %>%
  nest()

by_country <- by_country %>%
  mutate(model = map(data, country_model))
```


```r
by_country <- by_country %>%
  mutate(
    resids = map2(data, model, add_residuals)
  )
by_country
#> # A tibble: 142 x 5
#>   country     continent data              model    resids           
#>   <fct>       <fct>     <list>            <list>   <list>           
#> 1 Afghanistan Asia      <tibble [12 x 4]> <S3: lm> <tibble [12 x 5]>
#> 2 Albania     Europe    <tibble [12 x 4]> <S3: lm> <tibble [12 x 5]>
#> 3 Algeria     Africa    <tibble [12 x 4]> <S3: lm> <tibble [12 x 5]>
#> 4 Angola      Africa    <tibble [12 x 4]> <S3: lm> <tibble [12 x 5]>
#> 5 Argentina   Americas  <tibble [12 x 4]> <S3: lm> <tibble [12 x 5]>
#> 6 Australia   Oceania   <tibble [12 x 4]> <S3: lm> <tibble [12 x 5]>
#> # ... with 136 more rows
```


```r
unnest(by_country, resids) %>%
ggplot(aes(year, resid)) +
  geom_line(aes(group = country), alpha = 1 / 3) +
  geom_smooth(se = FALSE)
#> `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")'
```



\begin{center}\includegraphics[width=0.7\linewidth]{many-models_files/figure-latex/unnamed-chunk-6-1} \end{center}


```r
by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance, .drop = TRUE) %>%
  ggplot(aes(continent, r.squared)) +
  geom_jitter(width = 0.5)
```



\begin{center}\includegraphics[width=0.7\linewidth]{many-models_files/figure-latex/unnamed-chunk-7-1} \end{center}

### Exercise <span class="exercise-number">25.2.2</span> {.unnumbered .exercise}

<div class="question">
Explore other methods for visualizing the distribution of $R^2$ per continent. You might want to try the **ggbeeswarm** package, which provides similar methods for avoiding overlaps as jitter, but uses deterministic methods.
</div>

<div class="answer">

See exercise 7.5.1.1.6 for more on **ggbeeswarm**


```r
library("ggbeeswarm")
by_country %>%
  mutate(glance = map(model, broom::glance)) %>%
  unnest(glance, .drop = TRUE) %>%
  ggplot(aes(continent, r.squared)) +
  geom_beeswarm()
```



\begin{center}\includegraphics[width=0.7\linewidth]{many-models_files/figure-latex/unnamed-chunk-8-1} \end{center}

</div>

## List-columns

No exercises

## Creating list-columns

### Exercise <span class="exercise-number">25.4.1</span> {.unnumbered .exercise}

<div class="question">
List all the functions that you can think of that take a atomic vector and return a list.
</div>

<div class="answer">

E.g. Many of the **stringr** functions.

</div>

### Exercise <span class="exercise-number">25.4.2</span> {.unnumbered .exercise}

<div class="question">
Brainstorm useful summary functions that, like `quantile()`, return multiple values.
</div>

<div class="answer">

Some examples of summary functions that return multiple values are `range()` and `fivenum()`.


```r
range(mtcars$mpg)
#> [1] 10.4 33.9
fivenum(mtcars$mpg)
#> [1] 10.4 15.3 19.2 22.8 33.9
```

</div>

### Exercise <span class="exercise-number">25.4.3</span> {.unnumbered .exercise}

<div class="question">
What’s missing in the following data frame? How does `quantile()` return that missing piece? Why isn’t that helpful here?
</div>

<div class="answer">


```r
mtcars %>%
  group_by(cyl) %>%
  summarise(q = list(quantile(mpg))) %>%
  unnest()
#> # A tibble: 15 x 2
#>     cyl     q
#>   <dbl> <dbl>
#> 1     4  21.4
#> 2     4  22.8
#> 3     4  26  
#> 4     4  30.4
#> 5     4  33.9
#> 6     6  17.8
#> # ... with 9 more rows
```

The particular quantiles of the values are missing, e.g. `0%`, `25%`, `50%`, `75%`, `100%`. `quantile()` returns these in the names of the vector.

```r
quantile(mtcars$mpg)
#>   0%  25%  50%  75% 100% 
#> 10.4 15.4 19.2 22.8 33.9
```

Since the `unnest` function drops the names of the vector, they aren't useful here.

</div>

### Exercise <span class="exercise-number">25.4.4</span> {.unnumbered .exercise}

<div class="question">
What does this code do?
Why might might it be useful?
</div>

<div class="answer">


```r
mtcars %>%
  group_by(cyl) %>%
  summarise_each(funs(list))
#> `summarise_each()` is deprecated.
#> Use `summarise_all()`, `summarise_at()` or `summarise_if()` instead.
#> To map `funs` over all variables, use `summarise_all()`
#> # A tibble: 3 x 11
#>     cyl mpg    disp   hp     drat   wt     qsec   vs     am    gear  carb 
#>   <dbl> <list> <list> <list> <list> <list> <list> <list> <lis> <lis> <lis>
#> 1     4 <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl~ <dbl~ <dbl~
#> 2     6 <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl~ <dbl~ <dbl~
#> 3     8 <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl ~ <dbl~ <dbl~ <dbl~
```

It creates a data frame in which each row corresponds to a value of `cyl`,
and each observation for each column (other than `cyl`) is a vector of all the values of that column for that value of `cyl`.
It seems like it should be useful to have all the observations of each variable for each group, but off the top of my head, I can't think of a specific use for this.
But, it seems that it may do many things that `dplyr::do` does.

</div>

## Simplifying list-columns

### Exercise <span class="exercise-number">25.5.1</span> {.unnumbered .exercise}

<div class="question">
Why might the `lengths()` function be useful for creating atomic vector columns from list-columns?
</div>

<div class="answer">

The `lengths()` function gets the lengths of each element in a list.
It could be useful for testing whether all elements in a list-column are the same length.
You could get the maximum length to determine how many atomic vector columns to create.
It is also a replacement for something like `map_int(x, length)` or `sapply(x, length)`.

</div>

### Exercise <span class="exercise-number">25.5.2</span> {.unnumbered .exercise}

<div class="question">
List the most common types of vector found in a data frame.
What makes lists different?
</div>

<div class="answer">

The common types of vectors in data frames are:

-   `logical`
-   `numeric`
-   `integer`
-   `character`
-   `factor`

All of the common types of vectors in data frames are atomic. Lists are not atomic (they can contain other lists and other vectors).

</div>

<!-- match unopened div --><div>
