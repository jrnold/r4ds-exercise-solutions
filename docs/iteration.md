
# Iteration

## Prerequisites
 

```r
library(tidyverse)
#> Loading tidyverse: ggplot2
#> Loading tidyverse: tibble
#> Loading tidyverse: tidyr
#> Loading tidyverse: readr
#> Loading tidyverse: purrr
#> Loading tidyverse: dplyr
#> Conflicts with tidy packages ----------------------------------------------
#> filter(): dplyr, stats
#> lag():    dplyr, stats
```

## For Loops

### Exercises


Write for loops to:

1. Compute the mean of every column in `mtcars`.
2. Determine the type of each column in `nycflights13::flights`.
3. Compute the number of unique values in each column of `iris`.
4. Generate 10 random normals for each of $\mu = -10$, 0, 10, and 100.

Think about the output, sequence, and body before you start writing the loop.

To compute the mean of every column in `mtcars`.

```r
output <- vector("double", ncol(mtcars))
names(output) <- names(mtcars)
for (i in names(mtcars)) {
  output[i] <- mean(mtcars[[i]])
}
output
#>     mpg     cyl    disp      hp    drat      wt    qsec      vs      am 
#>  20.091   6.188 230.722 146.688   3.597   3.217  17.849   0.438   0.406 
#>    gear    carb 
#>   3.688   2.812
```

Determine the type of each column in `nycflights13::flights`.
Note that we need to use a `list`, not a character vector, since the class can have multiple values.

```r
data("flights", package = "nycflights13")
output <- vector("list", ncol(flights))
names(output) <- names(flights)
for (i in names(flights)) {
  output[[i]] <- class(flights[[i]])
}
output
#> $year
#> [1] "integer"
#> 
#> $month
#> [1] "integer"
#> 
#> $day
#> [1] "integer"
#> 
#> $dep_time
#> [1] "integer"
#> 
#> $sched_dep_time
#> [1] "integer"
#> 
#> $dep_delay
#> [1] "numeric"
#> 
#> $arr_time
#> [1] "integer"
#> 
#> $sched_arr_time
#> [1] "integer"
#> 
#> $arr_delay
#> [1] "numeric"
#> 
#> $carrier
#> [1] "character"
#> 
#> $flight
#> [1] "integer"
#> 
#> $tailnum
#> [1] "character"
#> 
#> $origin
#> [1] "character"
#> 
#> $dest
#> [1] "character"
#> 
#> $air_time
#> [1] "numeric"
#> 
#> $distance
#> [1] "numeric"
#> 
#> $hour
#> [1] "numeric"
#> 
#> $minute
#> [1] "numeric"
#> 
#> $time_hour
#> [1] "POSIXct" "POSIXt"
```



```r
data(iris)
iris_uniq <- vector("double", ncol(iris))
names(iris_uniq) <- names(iris)
for (i in names(iris)) {
  iris_uniq[i] <- length(unique(iris[[i]]))
}
iris_uniq
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width      Species 
#>           35           23           43           22            3
```


```r
# number to draw
n <- 10
# values of the mean
mu <- c(-10, 0, 10, 100)
normals <- vector("list", length(mu))
for (i in seq_along(normals)) {
  normals[[i]] <- rnorm(n, mean = mu[i])
}
normals
#> [[1]]
#>  [1] -11.40  -9.74 -12.44 -10.01  -9.38  -8.85 -11.82 -10.25 -10.24 -10.28
#> 
#> [[2]]
#>  [1] -0.5537  0.6290  2.0650 -1.6310  0.5124 -1.8630 -0.5220 -0.0526
#>  [9]  0.5430 -0.9141
#> 
#> [[3]]
#>  [1] 10.47 10.36  8.70 10.74 11.89  9.90  9.06  9.98  9.17  8.49
#> 
#> [[4]]
#>  [1] 100.9 100.2 100.2 101.6 100.1  99.9  98.1  99.7  99.7 101.1
```

However, we don't need a `for` loop for this since `rnorm` recycles means.

```r
matrix(rnorm(n * length(mu), mean = mu), ncol = n)
#>        [,1]   [,2]  [,3]     [,4]   [,5]   [,6]    [,7]   [,8]    [,9]
#> [1,] -9.930  -9.56 -9.88 -10.2061 -12.27 -8.926 -11.178  -9.51  -8.663
#> [2,] -0.639   2.76 -1.91   0.0192   2.68 -0.665  -0.976  -1.70   0.237
#> [3,]  9.950  10.05 10.86  10.0296   9.64 11.114  11.065   8.53  11.318
#> [4,] 99.749 100.58 99.76 100.5498 100.21 99.754 100.132 100.28 100.524
#>      [,10]
#> [1,] -9.39
#> [2,] -0.11
#> [3,] 10.17
#> [4,] 99.91
```

2. Eliminate the for loop in each of the following examples by taking advantage of an existing function that works with vectors:


```r
out <- ""
for (x in letters) {
  out <- stringr::str_c(out, x)
}
out
#> [1] "abcdefghijklmnopqrstuvwxyz"
```

`str_c` already works with vectors, so simply use `str_c` with the `collapse` argument to return a single string.

```r
stringr::str_c(letters, collapse = "")
#> [1] "abcdefghijklmnopqrstuvwxyz"
```

For this I'm going to rename the variable `sd` to something different because `sd` is the name of the function we want to use.

```r
x <- sample(100)
sd. <- 0
for (i in seq_along(x)) {
  sd. <- sd. + (x[i] - mean(x)) ^ 2
}
sd. <- sqrt(sd. / (length(x) - 1))
sd.
#> [1] 29
```

We could simply use the `sd` function.

```r
sd(x)
#> [1] 29
```
Or if there was a need to use the equation (e.g. for pedagogical reasons), then
the functions `mean` and `sum` already work with vectors:

```r
sqrt(sum((x - mean(x)) ^ 2) / (length(x) - 1))
#> [1] 29
```



```r
x <- runif(100)
out <- vector("numeric", length(x))
out[1] <- x[1]
for (i in 2:length(x)) {
  out[i] <- out[i - 1] + x[i]
}
out
#>   [1]  0.126  1.064  1.865  2.623  3.156  3.703  3.799  4.187  4.359  5.050
#>  [11]  5.725  6.672  6.868  7.836  8.224  8.874  9.688  9.759 10.286 11.050
#>  [21] 11.485 12.038 12.242 12.273 13.242 13.421 14.199 15.085 15.921 16.527
#>  [31] 17.434 17.470 17.601 17.695 18.392 18.797 18.863 18.989 19.927 20.143
#>  [41] 20.809 21.013 21.562 22.389 22.517 22.778 23.066 23.081 23.935 24.349
#>  [51] 25.100 25.819 26.334 27.309 27.670 27.840 28.623 28.654 29.444 29.610
#>  [61] 29.639 30.425 31.250 32.216 32.594 32.769 33.372 34.178 34.215 34.947
#>  [71] 35.163 35.179 35.307 35.993 36.635 36.963 37.350 38.058 38.755 39.681
#>  [81] 40.140 40.736 40.901 41.468 42.366 42.960 43.792 44.386 45.165 45.562
#>  [91] 46.412 47.154 47.472 47.583 47.685 48.485 48.865 48.917 49.904 50.508
```
The code above is calculating a cumulative sum. Use the function `cumsum`

```r
all.equal(cumsum(x),out)
#> [1] TRUE
```
