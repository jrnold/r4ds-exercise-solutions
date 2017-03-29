
# Iteration

## Introduction

- **purrr** package
- `for` loop
- `while`
- `seq_len`, `seq_along`
- `unlist`
- `bind_rows`, `bind_cols`, `purrr::flatten_dbl`
- Map functions in **purrr**: `map` and type-specific variants `map_lgl`, `map_chr`, `map_int`, `map_dbl`.
- `col_summary`
- apply function in base R: `lapply`, `sapply`, `vapply`
- `safely`, `quietly`, `possibly`
- `walk` and variants
- `keep`, `discard`, 
- `some`, `every`, 
- `head_while`, `tail_while`, 
- `detect`, `detect_index`
- `reduce`
 

```r
library("tidyverse")
library("stringr")
```
The package **microbenchmark** is used for timing code

```r
library("microbenchmark")
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
#>  [1]  -9.03 -11.01 -10.08 -10.55  -9.25 -10.93 -10.47 -10.86 -11.52  -8.03
#> 
#> [[2]]
#>  [1]  0.4632 -0.8562  0.6480  0.0758  0.4918 -0.7535  0.3490 -0.1708
#>  [9]  1.6312 -0.7827
#> 
#> [[3]]
#>  [1] 10.00 10.41 10.72 12.35  9.72  9.52 10.08 10.77 10.56  9.63
#> 
#> [[4]]
#>  [1]  99.4  99.6  99.1 100.1  99.4  99.7  99.9  97.9 100.2  99.7
```

However, we don't need a `for` loop for this since `rnorm` recycles means.

```r
matrix(rnorm(n * length(mu), mean = mu), ncol = n)
#>        [,1]   [,2]    [,3]    [,4]      [,5]   [,6]    [,7]   [,8]    [,9]
#> [1,] -9.745 -11.57 -9.0267  -9.563  -8.78273  -9.83 -10.861 -10.69 -11.781
#> [2,] -0.553  -1.04 -0.0768   0.413   0.00048   1.40   0.421   1.34  -0.716
#> [3,] 11.405  11.02 10.8929  10.976  10.75513   9.32  11.451  12.74  10.911
#> [4,] 99.205  99.30 99.2225 101.147 100.34240 100.74 100.194  99.06  99.228
#>        [,10]
#> [1,] -10.782
#> [2,]  -0.432
#> [3,]   9.332
#> [4,] 101.390
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
#>   [1]  0.938  1.739  2.497  3.030  3.577  3.673  4.061  4.233  4.924  5.599
#>  [11]  6.546  6.742  7.711  8.098  8.748  9.563  9.634 10.160 10.924 11.359
#>  [21] 11.912 12.116 12.147 13.116 13.295 14.073 14.959 15.796 16.401 17.308
#>  [31] 17.344 17.475 17.569 18.266 18.671 18.737 18.864 19.801 20.017 20.683
#>  [41] 20.887 21.436 22.263 22.391 22.652 22.941 22.955 23.809 24.223 24.974
#>  [51] 25.693 26.208 27.183 27.544 27.714 28.498 28.529 29.318 29.485 29.513
#>  [61] 30.299 31.125 32.090 32.468 32.643 33.247 34.052 34.089 34.822 35.037
#>  [71] 35.053 35.182 35.868 36.510 36.837 37.224 37.932 38.629 39.555 40.014
#>  [81] 40.610 40.775 41.342 42.240 42.835 43.666 44.260 45.039 45.436 46.286
#>  [91] 47.028 47.346 47.458 47.559 48.359 48.739 48.791 49.778 50.382 50.531
```
The code above is calculating a cumulative sum. Use the function `cumsum`

```r
all.equal(cumsum(x),out)
#> [1] TRUE
```

**Ex. 21.2.1.3**  Combine your function writing and for loop skills:

    1. Write a for loop that `prints()` the lyrics to the children's song 
       "Alice the camel".

    1. Convert the nursery rhyme "ten in the bed" to a function. Generalise 
       it to any number of people in any sleeping structure.

    1. Convert the song "99 bottles of beer on the wall" to a function.
       Generalise to any number of any vessel containing any liquid on 
       any surface.
    
I don't know what the deal is with Hadley and nursery rhymes.
Here's the lyrics for [Alice the Camel](http://www.kididdles.com/lyrics/a012.html)

We'll look from five to no humps, and print out a different last line if there are no humps. This uses `cat` instead of `print`, so it looks nicer.

```r
humps <- c("five", "four", "three", "two", "one", "no")
for (i in humps) {
  cat(str_c("Alice the camel has ", rep(i, 3), " humps.",
             collapse = "\n"), "\n")
  if (i == "no") {
    cat("Now Alice is a horse.\n")
  } else {
    cat("So go, Alice, go.\n")
  }
  cat("\n")
}
#> Alice the camel has five humps.
#> Alice the camel has five humps.
#> Alice the camel has five humps. 
#> So go, Alice, go.
#> 
#> Alice the camel has four humps.
#> Alice the camel has four humps.
#> Alice the camel has four humps. 
#> So go, Alice, go.
#> 
#> Alice the camel has three humps.
#> Alice the camel has three humps.
#> Alice the camel has three humps. 
#> So go, Alice, go.
#> 
#> Alice the camel has two humps.
#> Alice the camel has two humps.
#> Alice the camel has two humps. 
#> So go, Alice, go.
#> 
#> Alice the camel has one humps.
#> Alice the camel has one humps.
#> Alice the camel has one humps. 
#> So go, Alice, go.
#> 
#> Alice the camel has no humps.
#> Alice the camel has no humps.
#> Alice the camel has no humps. 
#> Now Alice is a horse.
```

The lyrics for [Ten in the Bed](http://supersimplelearning.com/songs/original-series/one/ten-in-the-bed/):

```r
numbers <- c("ten", "nine", "eight", "seven", "six", "five",
             "four", "three", "two", "one")
for (i in numbers) {
  cat(str_c("There were ", i, " in the bed\n"))
  cat("and the little one said\n")
  if (i == "one") {
    cat("I'm lonely...")
  } else {
    cat("Roll over, roll over\n")
    cat("So they all rolled over and one fell out.\n")
  }
  cat("\n")
}
#> There were ten in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were nine in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were eight in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were seven in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were six in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were five in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were four in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were three in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were two in the bed
#> and the little one said
#> Roll over, roll over
#> So they all rolled over and one fell out.
#> 
#> There were one in the bed
#> and the little one said
#> I'm lonely...
```

For the bottles of beer, I define a helper function to correctly print the number of bottles.

```r
bottles <- function(i) {
  if (i > 2) {
   bottles <- str_c(i - 1, " bottles")
  } else if (i == 2) {
   bottles <- "1 bottle"
  } else {
   bottles <- "no more bottles"
  }
  bottles
}

beer_bottles <- function(n) {
  # should test whether n >= 1.
  for (i in seq(n, 1)) {
     cat(str_c(bottles(i), " of beer on the wall, ", bottles(i), " of beer.\n"))
     cat(str_c("Take one down and pass it around, ", bottles(i - 1),
                " of beer on the wall.\n\n"))
  }
  cat("No more bottles of beer on the wall, no more bottles of beer.\n")
  cat(str_c("Go to the store and buy some more, ", bottles(n), " of beer on the wall.\n"))
}
beer_bottles(3)
#> 2 bottles of beer on the wall, 2 bottles of beer.
#> Take one down and pass it around, 1 bottle of beer on the wall.
#> 
#> 1 bottle of beer on the wall, 1 bottle of beer.
#> Take one down and pass it around, no more bottles of beer on the wall.
#> 
#> no more bottles of beer on the wall, no more bottles of beer.
#> Take one down and pass it around, no more bottles of beer on the wall.
#> 
#> No more bottles of beer on the wall, no more bottles of beer.
#> Go to the store and buy some more, 2 bottles of beer on the wall.
```


**Ex 21.2.1.4**  It's common to see for loops that don't preallocate the output and instead increase the length of a vector at each step:
    

```r
output <- vector("integer", 0)
for (i in seq_along(x)) {
  output <- c(output, lengths(x[[i]]))
}
output
```

I'll use the package **microbenchmark** to time this.
Microbenchmark will run an R expression a number of times and time it.

Define a function that appends to an integer vector.

```r
add_to_vector <- function(n) {
  output <- vector("integer", 0)
  for (i in seq_len(n)) {
    output <- c(output, i)
  }
  output  
}
microbenchmark(add_to_vector(10000), times = 3)
#> Unit: milliseconds
#>                  expr min  lq mean median  uq max neval
#>  add_to_vector(10000) 183 187  189    191 191 192     3
```

And one that pre-allocates it.

```r
add_to_vector_2 <- function(n) {
  output <- vector("integer", n)
  for (i in seq_len(n)) {
    output[[i]] <- i
  }
  output
}
microbenchmark(add_to_vector_2(10000), times = 3)
#> Unit: milliseconds
#>                    expr  min lq mean median   uq  max neval
#>  add_to_vector_2(10000) 7.54 11 13.5   14.4 16.5 18.7     3
```

The pre-allocated vector is about **100** times faster!
YMMV, but the longer the vector and the bigger the objects, the more that pre-allocation will outperform appending.


## For loop variations


### 

**Ex** Imagine you have a directory full of CSV files that you want to read in.
You have their paths in a vector, 
`files <- dir("data/", pattern = "\\.csv$", full.names = TRUE)`, and now
want to read each one with `read_csv()`. Write the for loop that will 
load them into a single data frame. 

I pre-allocate a list, read each file as data frame into an element in that list.
This creates a list of data frames.
I then use `bind_rows` to create a single data frame from the list of data frames.

```r
df <- vector("list", length(files))
for (fname in seq_along(files)) {
  df[[i]] <- read_csv(files[[i]])
}
df <- bind_rows(df)
```


**Ex** What happens if you use `for (nm in names(x))` and `x` has no names?
What if only some of the elements are named? What if the names are
not unique?

Let's try it out and see what happens.

When there are no names for the vector, it does not run the code in the loop (it runs zero iterations of the loop):

```r
x <- 1:3
print(names(x))
#> NULL
for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}
```
Note that the length of `NULL` is zero:

```r
length(NULL)
#> [1] 0
```

If there only some names, then we get an error if we try to access an element without a name. 
However, oddly, `nm == ""` when there is no name.

```r
x <- c(a = 1, 2, c = 3)
names(x)
#> [1] "a" ""  "c"
```

```r
for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}
#> [1] "a"
#> [1] 1
#> [1] ""
#> Error in x[[nm]]: subscript out of bounds
```

Finally, if there are duplicate names, then `x[[nm]]` will give the *first* element with that name.
There is no way to access duplicately named elements by name.

```r
x <- c(a = 1, a = 2, c = 3)
names(x)
#> [1] "a" "a" "c"
```

```r
for (nm in names(x)) {
  print(nm)
  print(x[[nm]])
}
#> [1] "a"
#> [1] 1
#> [1] "a"
#> [1] 1
#> [1] "c"
#> [1] 3
```


**Ex**  Write a function that prints the mean of each numeric column in a data 
frame, along with its name. For example, `show_mean(iris)` would print:
    

```r
show_mean(iris)
#> Sepal.Length: 5.84
#> Sepal.Width:  3.06
#> Petal.Length: 3.76
#> Petal.Width:  1.20
```
    
(Extra challenge: what function did I use to make sure that the numbers
lined up nicely, even though the variable names had different lengths?)

There may be other functions to do this, but I'll use `str_pad`, and `str_length` to ensure that the space given to the variable names is the same.
I messed around with the options to `format` until I got two digits .

```r
show_mean <- function(df, digits = 2) {
  # Get max length of any variable in the dataset
  maxstr <- max(str_length(names(df)))
  for (nm in names(df)) {
    if (is.numeric(df[[nm]])) {
      cat(str_c(str_pad(str_c(nm, ":"), maxstr + 1L, side = "right"),
                format(mean(df[[nm]]), digits = digits, nsmall = digits),
                sep = " "),
          "\n")
    }
  }
}
show_mean(iris)
#> Sepal.Length: 5.84 
#> Sepal.Width:  3.06 
#> Petal.Length: 3.76 
#> Petal.Width:  1.20
```

**Ex** What does this code do? How does it work?


```r
trans <- list( 
  disp = function(x) x * 0.0163871,
  am = function(x) {
    factor(x, labels = c("auto", "manual"))
  }
)
```

```r
for (var in names(trans)) {
  mtcars[[var]] <- trans[[var]](mtcars[[var]])
}
```

This code mutates the `disp` and `am` columns:

- `disp` is  multiplied by 0.0163871
- `am` is replaced by a factor variable.

The code works by looping over a named list of functions.
It calls the named function in the list on the column of `mtcars` with the same name, and replaces the values of that column.

E.g. this is a function:

```r
trans[["disp"]]
```
This applies the function to the column of `mtcars` with the same name

```r
trans[["disp"]](mtcars[["disp"]])
```



## For loops vs. functionals


```r
col_summary <- function(df, fun) {
  out <- vector("double", length(df))
  for (i in seq_along(df)) {
    out[i] <- fun(df[[i]])
  }
  out
}
```

### Exercises

**Ex. 21.4.1.1** Read the documentation for `apply()`. In the 2d case, what two for loops does it generalise.

It generalises looping over the rows or columns of a matrix or data-frame. 

**Ex. 21.4.1.2** Adapt `col_summary()` so that it only applies to numeric columns You might want to start with an `is_numeric()` function that returns a logical vector that has a `TRUE` corresponding to each numeric column.


```r
col_summary2 <- function(df, fun) {
  # test whether each colum is numeric
  numeric_cols <- vector("logical", length(df))
  for (i in seq_along(df)) {
    numeric_cols[[i]] <- is.numeric(df[[i]])
  }
  # indexes of numeric columns
  idxs <- seq_along(df)[numeric_cols]
  # number of numeric columns
  n <- sum(numeric_cols)
  out <- vector("double", n)
  for (i in idxs) {
    out[i] <- fun(df[[i]])
  }
  out
}
```

Let's test that it works,

```r
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = letters[1:10],
  d = rnorm(10)
)
col_summary2(df, mean)
#> [1]  0.0262 -0.3145  0.0000 -0.1516
```


## The map functions

### Shortcuts

**Notes** The `lm()` function runs a linear regression. It is covered in the [Model Basics](http://r4ds.had.co.nz/model-basics.html) chapter.


### Exercises

**Ex** Write code that uses one of the map functions to:

    1. Compute the mean of every column in `mtcars`.
    1. Determine the type of each column in `nycflights13::flights`.
    1. Compute the number of unique values in each column of `iris`.
    1. Generate 10 random normals for each of $\mu = -10$, $0$, $10$, and $100$.
    
The mean of every column in `mtcars`:

```r
map_dbl(mtcars, mean)
#>     mpg     cyl    disp      hp    drat      wt    qsec      vs      am 
#>  20.091   6.188 230.722 146.688   3.597   3.217  17.849   0.438   0.406 
#>    gear    carb 
#>   3.688   2.812
```

The type of every column in `nycflights13::flights`. 

```r
map(nycflights13::flights, class)
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
I had to use `map` rather than `map_chr` since the class
Though if by type, `typeof` is meant:

```r
map_chr(nycflights13::flights, typeof)
#>           year          month            day       dep_time sched_dep_time 
#>      "integer"      "integer"      "integer"      "integer"      "integer" 
#>      dep_delay       arr_time sched_arr_time      arr_delay        carrier 
#>       "double"      "integer"      "integer"       "double"    "character" 
#>         flight        tailnum         origin           dest       air_time 
#>      "integer"    "character"    "character"    "character"       "double" 
#>       distance           hour         minute      time_hour 
#>       "double"       "double"       "double"       "double"
```

The number of unique values in each column of `iris`:

```r
map_int(iris, ~ length(unique(.)))
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width      Species 
#>           35           23           43           22            3
```

Generate 10 random normals for each of $\mu = -10$, $0$, $10$, and $100$:

```r
map(c(-10, 0, 10, 100), rnorm, n = 10)
#> [[1]]
#>  [1]  -8.42  -9.99 -10.65  -8.14  -9.17  -8.80  -9.40  -9.94 -11.29 -10.13
#> 
#> [[2]]
#>  [1]  0.384 -0.542  0.223 -0.645 -0.415 -2.295 -0.632 -0.531  0.710 -0.248
#> 
#> [[3]]
#>  [1] 10.68  9.40 10.11 10.37  9.39 11.04  9.70 11.42  9.13  7.78
#> 
#> [[4]]
#>  [1]  99.7 100.4 101.0 100.3 101.2  99.7  99.3  98.5 102.5 100.6
```



**Ex**  How can you create a single vector that for each column in a data frame
indicates whether or not it's a factor?

Use `map_lgl` with the function `is.factor`,

```r
map_lgl(mtcars, is.factor)
#>   mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb 
#> FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE FALSE
```


**Ex** What happens when you use the map functions on vectors that aren't lists? What does `map(1:5, runif)` do? Why?

The function `map` applies the function to each element of the vector.

```r
map(1:5, runif)
#> [[1]]
#> [1] 0.133
#> 
#> [[2]]
#> [1] 0.927 0.894
#> 
#> [[3]]
#> [1] 0.204 0.257 0.614
#> 
#> [[4]]
#> [1] 0.441 0.316 0.101 0.273
#> 
#> [[5]]
#> [1] 0.6537 0.9279 0.0266 0.5595 0.8542
```

    
**Ex** What does `map(-2:2, rnorm, n = 5)` do? Why? What does `map_dbl(-2:2, rnorm, n = 5)` do? Why?

This takes samples of `n = 5` from normal distributions of means -2, -1, 0, 1, and 2, and returns a list with each element a numeric vectors of length 5.

```r
map(-2:2, rnorm, n = 5)
#> [[1]]
#> [1] -3.43 -2.01 -2.21 -2.91 -4.10
#> 
#> [[2]]
#> [1]  0.893 -1.968 -1.103 -0.760 -0.939
#> 
#> [[3]]
#> [1] -2.17758 -0.11786  0.11229  0.00789  1.87774
#> 
#> [[4]]
#> [1] 3.159 1.710 1.767 0.692 2.012
#> 
#> [[5]]
#> [1] 1.08 2.56 2.32 2.37 3.13
```

However, if we use `map_dbl` it throws an error. `map_dbl` expects the function 
to return a numeric vector of length one.

```r
map_dbl(-2:2, rnorm, n = 5)
#> Error: Result 1 is not a length 1 atomic vector
```

If we wanted a numeric vector, we could use `map` followed by `flatten_dbl`,

```r
flatten_dbl(map(-2:2, rnorm, n = 5))
#>  [1] -2.222 -3.010 -1.519 -0.396 -3.515 -2.416 -0.123 -0.376  1.112 -1.356
#> [11] -1.064  1.077  1.182  0.198 -0.400  1.616  2.974  2.885 -0.589  0.460
#> [21]  0.831  2.559  0.181  2.393  2.042
```


**Ex** Rewrite `map(x, function(df) lm(mpg ~ wt, data = df))` to eliminate the anonymous function. 


```r
map(list(mtcars), ~ lm(mpg ~ wt, data = .))
#> [[1]]
#> 
#> Call:
#> lm(formula = mpg ~ wt, data = .)
#> 
#> Coefficients:
#> (Intercept)           wt  
#>       37.29        -5.34
```



## Dealing with Failure

## Mapping over multiple arguments

## Walk

## Other patterns of for loops

### Exercises

**Ex** Implement your own version of `every()` using a for loop. Compare it with
`purrr::every()`. What does purrr's version do that your version doesn't?



```r
# Use ... to pass arguments to the function
every2 <- function(.x, .p, ...) {
  for (i in .x) {
    if (!.p(i, ...)) {
      # If any is FALSE we know not all of then were TRUE
      return(FALSE)
    }
  }
  # if nothing was FALSE, then it is TRUE
  TRUE  
}

every2(1:3, function(x) {x > 1})
#> [1] FALSE
every2(1:3, function(x) {x > 0})
#> [1] TRUE
```

The function `purrr::every` does fancy things with `.p`, like taking a logical vector instead of a function, or being able to test part of a string if the elements of `.x` are lists.

**Ex** Create an enhanced `col_sum()` that applies a summary function to every
numeric column in a data frame.

**Note** this question has a typo. It is referring to `col_summary`. 

I will use `map` to apply the function to all the columns, and `keep` to only select numeric columns.

```r
col_sum2 <- function(df, f, ...) {
  map(keep(df, is.numeric), f, ...)
}
```


```r
col_sum2(iris, mean)
#> $Sepal.Length
#> [1] 5.84
#> 
#> $Sepal.Width
#> [1] 3.06
#> 
#> $Petal.Length
#> [1] 3.76
#> 
#> $Petal.Width
#> [1] 1.2
```



**Ex**  A possible base R equivalent of `col_sum()` is:


```r
col_sum3 <- function(df, f) {
  is_num <- sapply(df, is.numeric)
  df_num <- df[, is_num]
  sapply(df_num, f)
}
```

But it has a number of bugs as illustrated with the following inputs:


```r
df <- tibble(
  x = 1:3, 
  y = 3:1,
  z = c("a", "b", "c")
)
# OK
col_sum3(df, mean)
# Has problems: don't always return numeric vector
col_sum3(df[1:2], mean)
col_sum3(df[1], mean)
col_sum3(df[0], mean)
```

What causes the bugs?

The problem is that `sapply` doesn't always return numeric vectors.
If no columns are selected, instead of gracefully exiting, it returns an empty list. 
This causes an error since we can't use a list with `[`.

```r
sapply(df[0], is.numeric)
#> named list()
```

```r
sapply(df[1], is.numeric)
#>    a 
#> TRUE
```

```r
sapply(df[1:2], is.numeric)
#>    a    b 
#> TRUE TRUE
```

