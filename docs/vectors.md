
# Vectors

## Introduction

Functions mentioned

- `typeof`
- `dplyr::near`
- `is.finite`, `is.nan`, `is.na`
- `attributes`



```r
library("tidyverse")
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

## Important types of Atomic Vector

Why does this matter? 99% of the time in the work you do, it won't.
Someone else has written the numerical methods and (hopefully) accounted for these issues.
And the types of problems you encounter in social science generally are not dealing with these issues.
However, if you aren't even aware that "floating point numbers" are a "thing", if something goes wrong, it will seem like magic.
Also, at least being aware of these problems will help you understand error messages from optimization routines that complaing of "numerical precision".

Computerphile has a good video on [Floating Point Numbers](https://youtu.be/PZRI1IfStY0).

### Exercises

1. Describe the difference between `is.finite(x)` and `!is.infinite(x)`.

To find out, try the functions on a numeric vector that includes a number and the five special values (`NA`, `NaN`, `Inf`, `-Inf`).


```r
x <- c(0, NA, NaN, Inf, -Inf)
is.finite(x)
#> [1]  TRUE FALSE FALSE FALSE FALSE
!is.infinite(x)
#> [1]  TRUE  TRUE  TRUE FALSE FALSE
```

`is.finite` considers only a number to be finite, and considers missing (`NA`), not a number (`NaN`), and positive and negative infinity to be not finite.
However, since `is.infinite` only considers `Inf` and `-Inf` to be inifinite, `!is.infinite` considers `0` as well as missing and not-a-number to be not infinite.

So `NA` and `NaN` are neither finite or infinite. Mind blown.

2. Read the source code for `dplyr::near()` (Hint: to see the source code, drop the ()). How does it work?

The source for `dplyr::near` is:

```r
dplyr::near
#> function (x, y, tol = .Machine$double.eps^0.5) 
#> {
#>     abs(x - y) < tol
#> }
#> <environment: namespace:dplyr>
```

Instead of checking for exact equality, it checks that two numbers are within a certain tolerance, `tol`. 
By default the tolerance is set to the square root of `.Machine$double.eps`, which is the smallest floating point number that the computer can represent.

3. A logical vector can take 3 possible values. How many possible values can an integer vector take? How many possible values can a double take? Use google to do some research.

The help for `.Machine` describes some of this:

  As all current implementations of R use 32-bit integers and usne IEC 60559 floating-point (double precision) arithmetic,

The [IEC 60559](https://en.wikipedia.org/wiki/Double-precision_floating-point_format) or IEEE 754 format uses a 64 bit vector, but 



4. Brainstorm at least four functions that allow you to convert a double to an integer. How do they differ? Be precise.

Broadly, could convert a double to an integer by truncating or rounding to the nearest integer.
For truncating or for handling ties (doubles ending in 0.5), there are multiple methods for determing which integer value to go to.

methods                        0.5  -0.5  1.5  -1.5 
============================== ==== ===== ==== ==== 
towards zero:                  0    0     1    1 
away from zero                 1    -1    2    -2
largest towards $+\infty$)     1    0     2    -1
smallest (towards $-\infty$)   0    -1    1    -2
even                           0    0     2    -2
odd                            1    -1    1    -1
=====================================================

See the Wikipedia article [IEEE floating point](https://en.wikipedia.org/wiki/IEEE_floating_point) for rounding rules.

For rounding, R and many programming languages use the IEEE standard. This is "round to nearest, ties to even".
This is not the same as what you 
See the value of looking at the value of `.Machine$double.rounding` and its documentation.


```r
x <- seq(-10, 10, by = 0.5)

round2 <- function(x, to_even = TRUE) {
  q <- x %/% 1
  r <- x %% 1
  q + (r >= 0.5)
}
x <- c(-12.5, -11.5, 11.5, 12.5)
round(x)
#> [1] -12 -12  12  12
round2(x, to_even = FALSE)
#> [1] -12 -11  12  13
```

The problem with the always rounding 0.5 up rule is that it is biased upwards. Rounding to nearest with ties towards even is
not.
Consider the sequence $-100.5, -99.5, \dots, 0, \dots, 99.5, 100.5$. 
Its sum is 0. 
It would be nice if rounding preserved that sum. 
Using the "ties towards even", the sum is still zero. 
Hoever, the "ties towards $+\infty$" produces a non-zero number.

```r
x <- seq(-100.5, 100.5, by = 1)
sum(x)
#> [1] 0
sum(round(x))
#> [1] 0
sum(round2(x))
#> [1] 101
```

Here's a real-world non-engineering example of rounding going terribly wrong.
In 1983, the Vancouver stock exchange adjusted its index from 524.811 to 1098.892 to correct for accumulated error due to rounding to three decimal points (see [Vancouver Stock Exchange](https://en.wikipedia.org/wiki/Vancouver_Stock_Exchange])).

Here's a [list](https://www.ma.utexas.edu/users/arbogast/misc/disasters.html) of a few more.



5. What functions from the **readr** package allow you to turn a string into logical, integer, and double vector?

The functions `parse_logical`, `parse_integer`, and `parse_number`.


```r
parse_logical(c("TRUE", "FALSE", "1", "0", "true", "t", "NA"))
#> [1]  TRUE FALSE  TRUE FALSE  TRUE  TRUE    NA
```


```r
parse_integer(c("1235", "0134", "NA"))
#> [1] 1235  134   NA
```


```r
parse_number(c("1.0", "3.5", "1,000", "NA"))
#> [1]    1.0    3.5 1000.0     NA
```

Read the documentation of `read_number`. In order to ignore things like currency symbols and comma seperators in number strings it ignores them using a heuristic.


## Using atomic vectors

1. What does `mean(is.na(x))` tell you about a vector `x`? What about `sum(!is.finite(x))`?

The expression `mean(is.na(x))` calculates the proportion of missing values in a vector

```r
x <- c(1:10, NA, NaN, Inf, -Inf)
mean(is.na(x))
#> [1] 0.143
```

The expression `mean(!is.finite(x))` calcualtes the proportion of values that are `NA`, `NaN`, or infinite.

```r
mean(!is.finite(x))
#> [1] 0.286
```


2. Carefully read the documentation of `is.vector()`. What does it actually test for? Why does `is.atomic()` not agree with the definition of atomic vectors above?

The function `is.vector` only checks whether the object has no attributes other than names. Thus a `list` is a vector:

```r
is.vector(list(a = 1, b = 2))
#> [1] TRUE
```
But any object that has an attribute (other than names) is not:

```r
x <- 1:10
attr(x, "something") <- TRUE
is.vector(x)
#> [1] FALSE
```

The idea behind this is that object oriented classes will include attributes, including, but not limited to `"class"`.

The function `is.atomic` explicitly checks whether an object is one of the atomic types ("logical", "integer", "numeric", "complex", "character", and "raw") or NULL.


```r
is.atomic(1:10)
#> [1] TRUE
is.atomic(list(a = 1))
#> [1] FALSE
```

The function `is.atomic` will consider objects to be atomic even if they have extra attributes.

```r
is.atomic(x)
#> [1] TRUE
```


3. Compare and contrast `setNames()` with `purrr::set_names()`.

These are simple functions, so we can simply print out their source code:

```r
setNames
#> function (object = nm, nm) 
#> {
#>     names(object) <- nm
#>     object
#> }
#> <bytecode: 0x7fca28a92038>
#> <environment: namespace:stats>
```

```r
purrr::set_names
#> function (x, nm = x) 
#> {
#>     if (!is_vector(x)) {
#>         stop("`x` must be a vector", call. = FALSE)
#>     }
#>     if (length(x) != length(nm)) {
#>         stop("`x` and `nm` must be the same length", call. = FALSE)
#>     }
#>     names(x) <- nm
#>     x
#> }
#> <environment: namespace:purrr>
```

From the code we can see that `set_names` adds a few sanity checks: `x` has to be a vector, and the lengths of the object and the names have to be the same.


4. Create functions that take a vector as input and returns:

  1. The last value. Should you use [ or [[?
  2 The elements at even numbered positions.
  3. Every element except the last value.
  4. Only even numbers (and no missing values).


```r
last_value <- function(x) {
  # check for case with no length
  if (length(x)) {
    # Use [[ as suggested because it returns one element
    x[[length(x)]]  
  } else {
    x
  }
}
last_value(numeric())
#> numeric(0)
last_value(1)
#> [1] 1
last_value(1:10)
#> [1] 10
```


```r
even_indices <- function(x) {
  if (length(x)) {
    x[seq_along(x) %% 2 == 0]
  } else {
    x
  }  
}
even_indices(numeric())
#> numeric(0)
even_indices(1)
#> numeric(0)
even_indices(1:10)
#> [1]  2  4  6  8 10
# test using case to ensure that values not indices
# are being returned
even_indices(letters)
#>  [1] "b" "d" "f" "h" "j" "l" "n" "p" "r" "t" "v" "x" "z"
```


```r
not_last <- function(x) {
  if (length(x)) {
    x[-length(x)]
  } else {
    x
  }
}
not_last(1:5)
#> [1] 1 2 3 4
```


```r
even_numbers <- function(x) {
  x[!is.na(x) & (x %% 2 == 0)]
}
even_numbers(-10:10)
#>  [1] -10  -8  -6  -4  -2   0   2   4   6   8  10
```


5. Why is `x[-which(x > 0)]` not the same as `x[x <= 0]`?

They will treat missing values differently.

```r
x <- c(-5:5, Inf, -Inf, NaN, NA)
x[-which(x > 0)]
#> [1]   -5   -4   -3   -2   -1    0 -Inf  NaN   NA
-which(x > 0)
#> [1]  -7  -8  -9 -10 -11 -12
x[x <= 0]
#> [1]   -5   -4   -3   -2   -1    0 -Inf   NA   NA
x <= 0
#>  [1]  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE FALSE FALSE FALSE FALSE
#> [12] FALSE  TRUE    NA    NA
```

`-which(x > 0)` which calculates the indexes for any value that is `TRUE` and ignores `NA`. Thus is keeps `NA` and `NaN` because the comparison is not `TRUE`.
`x <= 0` works slightly differently. If `x <= 0` returns `TRUE` or `FALSE` it works the same way. Hoewver, if the comparison generates a `NA`, then it will always keep that entry, but set it to `NA`. This is why the last two values of `x[x <= 0]` are `NA` rather than `c(NaN, NA)`.


6. What happens when you subset with a positive integer that’s bigger than the length of the vector? What happens when you subset with a name that doesn’t exist?

When you subset with positive integers that are larger than the length of the vector, `NA` values are returned for those integers larger than the length of the vector.

```r
(1:10)[11:12]
#> [1] NA NA
```

When a vector is subset with a name that doesn't exist, an error is generated.


```r
c(a = 1, 2)[["b"]]
#> Error in c(a = 1, 2)[["b"]]: subscript out of bounds
```

## Recursive Vectors (lists)

### Exercises

1. Draw the following lists as nested sets:

  1. `list(a, b, list(c, d), list(e, f))`
  2. `list(list(list(list(list(list(a))))))`
  
2. What happens if you subset a `tibble` as if you’re subsetting a list? What are the key differences between a list and a `tibble`?

Subsetting a `tibble` works the same way as a list; a data frame can be thought of as a list of columns.
The key different between a list and a `tibble` is that a tibble (data frame) has the restriction that all its elements (columns) must have the same length.

```r
x <- tibble(a = 1:2, b = 3:4)
x[["a"]]
#> [1] 1 2
x["a"]
#> # A tibble: 2 × 1
#>       a
#>   <int>
#> 1     1
#> 2     2
x[1]
#> # A tibble: 2 × 1
#>       a
#>   <int>
#> 1     1
#> 2     2
x[1, ]
#> # A tibble: 1 × 2
#>       a     b
#>   <int> <int>
#> 1     1     3
```

## Augmented Vectors


### Exercises

1. What does `hms::hms(3600)` return? How does it print? What primitive type is the augmented vector built on top of? What attributes does it use?



```r
x <- hms::hms(3600)
class(x)
#> [1] "hms"      "difftime"
x
#> 01:00:00
```

`hms::hms` returns an object of class, and prints the time in "%H:%M:%S" format.

The primitive type is a double

```r
typeof(x)
#> [1] "double"
```

The atttributes is uses are `"units"` and `"class"`.

```r
attributes(x)
#> $units
#> [1] "secs"
#> 
#> $class
#> [1] "hms"      "difftime"
```

2. Try and make a tibble that has columns with different lengths. What happens?

If I try to create at tibble with a scalar and column of a different length there are no issues, and the scalar is repeated to the length of the longer vector.

```r
tibble(x = 1, y = 1:5)
#> # A tibble: 5 × 2
#>       x     y
#>   <dbl> <int>
#> 1     1     1
#> 2     1     2
#> 3     1     3
#> 4     1     4
#> 5     1     5
```

However, if I try to create a tibble with two vectors of different lengths (other than one), the `tibble` function throws an error.

```r
tibble(x = 1:3, y = 1:4)
#> Error: Variables must be length 1 or 4.
#> Problem variables: 'x'
```


3. Based on the definition above, is it ok to have a list as a column of a tibble?

If I didn't already know the answer, what I would do is try it out. 
From the above, the error message was about vectors having different lengths.
But there is nothing that prevents a tibble from having vectors of different types: doubles, character, integers, logical, factor, date. 
The later are still atomic, but they have additional attributes.
So, maybe there won't be an issue with a list vector as long as it is the same length.


```r
tibble(x = 1:3, y = list("a", 1, list(1:3)))
#> # A tibble: 3 × 2
#>       x          y
#>   <int>     <list>
#> 1     1  <chr [1]>
#> 2     2  <dbl [1]>
#> 3     3 <list [1]>
```

It works! I even used a list with heterogenous types and there wasn't an issue.
In following chapters we'll see that list vectors can be very useful: for example, when processing many different models.

