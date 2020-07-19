# Vectors {#vectors .r4ds-section}

## Introduction {#introduction-13 .r4ds-section}


```r
library("tidyverse")
```

## Vector basics {#vector-basics .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

## Important types of atomic vector {#important-types-of-atomic-vector .r4ds-section}

### Exercise 20.3.1 {.unnumbered .exercise data-number="20.3.1"}

<div class="question">
Describe the difference between `is.finite(x)` and `!is.infinite(x)`.
</div>

<div class="answer">

To find out, try the functions on a numeric vector that includes at least one number and the four special values (`NA`, `NaN`, `Inf`, `-Inf`).


```r
x <- c(0, NA, NaN, Inf, -Inf)
is.finite(x)
#> [1]  TRUE FALSE FALSE FALSE FALSE
!is.infinite(x)
#> [1]  TRUE  TRUE  TRUE FALSE FALSE
```

The `is.finite()` function considers non-missing numeric values to be finite,
and missing (`NA`), not a number (`NaN`), and positive (`Inf`) and negative infinity (`-Inf`) to not be finite. The `is.infinite()` behaves slightly differently.
It considers `Inf` and `-Inf` to be infinite, and everything else, including non-missing numbers, `NA`, and `NaN` to not be infinite. See Table \@ref(tab:finite-infinite).

Table: (\#tab:finite-infinite) Results of `is.finite()` and `is.infinite()` for
       numeric and special values.

|        | `is.finite()` | `is.infinite()` |
|--------|---------------|-----------------|
| `1`    | `TRUE`        | `FALSE`         |
| `NA`   | `FALSE`       | `FALSE`         |
| `NaN`  | `FALSE`       | `FALSE`         |
| `Inf`  | `FALSE`       | `TRUE`          |

</div>

### Exercise 20.3.2 {.unnumbered .exercise data-number="20.3.2"}

<div class="question">
Read the source code for `dplyr::near()` (Hint: to see the source code, drop the `()`). How does it work?
</div>

<div class="answer">

The source for `dplyr::near` is:

```r
dplyr::near
#> function (x, y, tol = .Machine$double.eps^0.5) 
#> {
#>     abs(x - y) < tol
#> }
#> <bytecode: 0x5d8e8a8>
#> <environment: namespace:dplyr>
```

Instead of checking for exact equality, it checks that two numbers are within a certain tolerance, `tol`.
By default the tolerance is set to the square root of `.Machine$double.eps`, which is the smallest floating point number that the computer can represent.

</div>

### Exercise 20.3.3 {.unnumbered .exercise data-number="20.3.3"}

<div class="question">
A logical vector can take 3 possible values. How many possible values can an integer vector take? How many possible values can a double take? Use Google to do some research.
</div>

<div class="answer">

For integers vectors, R uses a 32-bit representation. This means that it can represent up to $2^{32}$ different values with integers. One of these values is set aside for `NA_integer_`.
From the help for `integer`.

> Note that current implementations of R use 32-bit integers for integer vectors,
> so the range of representable integers is restricted to about +/-2*10^9: doubles
> can hold much larger integers exactly.

The range of integers values that R can represent in an integer vector is $\pm 2^{31} - 1$,

```r
.Machine$integer.max
#> [1] 2147483647
```
The maximum integer is $2^{31} - 1$ rather than $2^{32}$ because 1 bit is used to
represent the sign ($+$, $-$) and one value is used to represent `NA_integer_`.

If you try to represent an integer greater than that value, R will return `NA` values.

```r
.Machine$integer.max + 1L
#> Warning in .Machine$integer.max + 1L: NAs produced by integer overflow
#> [1] NA
```
However, you can represent that value (exactly) with a numeric vector at the cost of
about two times the memory.

```r
as.numeric(.Machine$integer.max) + 1
#> [1] 2.15e+09
```
The same is true for the negative of the integer max.

```r
-.Machine$integer.max - 1L
#> Warning in -.Machine$integer.max - 1L: NAs produced by integer overflow
#> [1] NA
```

For double vectors, R uses a 64-bit representation. This means that they can hold up
to $2^{64}$ values exactly. However, some of those values are allocated to special values
such as `-Inf`, `Inf`, `NA_real_`, and `NaN`. From the help for `double`:

> All R platforms are required to work with values conforming to the IEC 60559
> (also known as IEEE 754) standard. This basically works with a precision of
> 53 bits, and represents to that precision a range of absolute values from
> about 2e-308 to 2e+308. It also has special values `NaN` (many of them),
> plus and minus infinity
> and plus and minus zero (although R acts as if these are the same). There are
> also denormal(ized) (or subnormal) numbers with absolute values above or below
> the range given above but represented to less precision.

The details of floating point representation and arithmetic are complicated, beyond
the scope of this question, and better discussed in the references provided below.
The double can represent numbers in the range of about $\pm 2 \times 10^{308}$, which is
provided in

```r
.Machine$double.xmax
#> [1] 1.8e+308
```

Many  other details for the implementation of the double vectors are given in the `.Machine` variable (and its documentation).
These include the base (radix) of doubles,

```r
.Machine$double.base
#> [1] 2
```
the number of bits used for the significand (mantissa),

```r
.Machine$double.digits
#> [1] 53
```
the number of bits used in the exponent,

```r
.Machine$double.exponent
#> [1] 11
```
and the smallest positive and negative numbers not equal to zero,

```r
.Machine$double.eps
#> [1] 2.22e-16
.Machine$double.neg.eps
#> [1] 1.11e-16
```

-   Computerphile, "[Floating Point Numbers](https://www.youtube.com/watch?v=PZRI1IfStY0)"
-   <https://en.wikipedia.org/wiki/IEEE_754>
-   <https://en.wikipedia.org/wiki/Double-precision_floating-point_format>
-   "[Floating Point Numbers: Why floating-point numbers are needed](https://floating-point-gui.de/formats/fp/)"
-   Fabien Sanglard, "[Floating Point Numbers: Visually Explained](http://fabiensanglard.net/floating_point_visually_explained/)"
-   James Howard, "[How Many Floating Point Numbers are There?](https://jameshoward.us/2015/09/09/how-many-floating-point-numbers-are-there/)"
-   GeeksforGeeks, "[Floating Point Representation Basics](https://www.geeksforgeeks.org/floating-point-representation-basics/)"
-   Chris Hecker, "[Lets Go to the (Floating) Point](http://chrishecker.com/images/f/fb/Gdmfp.pdf)", *Game Developer*
-   Chua Hock-Chuan, [A Tutorial on Data Representation Integers, Floating-point Numbers, and Characters](http://www.ntu.edu.sg/home/ehchua/programming/java/datarepresentation.html)
-   John D. Cook, "[Anatomy of a floating point number](https://www.johndcook.com/blog/2009/04/06/anatomy-of-a-floating-point-number/)"
-   John D. Cook, "[Five Tips for Floating Point Programming](https://www.codeproject.com/Articles/29637/Five-Tips-for-Floating-Point-Programming)"

</div>

### Exercise 20.3.4 {.unnumbered .exercise data-number="20.3.4"}

<div class="question">
Brainstorm at least four functions that allow you to convert a double to an integer. How do they differ? Be precise.
</div>

<div class="answer">

The difference between to convert a double to an integer differ in how they deal with the fractional part of the double.
There are are a variety of rules that could be used to do this.

-   Round down, towards $-\infty$. This is also called taking the `floor` of a number. This is the method the `floor()` function uses.

-   Round up, towards $+\infty$. This is also called taking the `ceiling`. This is the method the `ceiling()` function uses.

-   Round towards zero. This is the method that the `trunc()` and `as.integer()` functions use.

-   Round away from zero. 

-   Round to the nearest integer. There several different methods for handling ties, defined as numbers with a fractional part of 0.5.

    -   Round half down, towards $-\infty$.
    -   Round half up, towards $+\infty$.
    -   Round half towards zero
    -   Round half away from zero
    -   Round half towards the even integer. This is the method that the  `round()` function uses.
    -   Round half towards the odd integer.


```r
function(x, method) {
  if (method == "round down") {
    floor(x)
  } else if (method == "round up") {
    ceiling(x)
  } else if (method == "round towards zero") {
    trunc(x)
  } else if (method == "round away from zero") {
    sign(x) * ceiling(abs(x))
  } else if (method == "nearest, round half up") {
    floor(x + 0.5)
  } else if (method == "nearest, round half down") {
    ceiling(x - 0.5)
  } else if (method == "nearest, round half towards zero") {
    sign(x) * ceiling(abs(x) - 0.5)
  } else if (method == "nearest, round half away from zero") {
    sign(x) * floor(abs(x) + 0.5)
  } else if (method == "nearest, round half to even") {
    round(x, digits = 0)
  } else if (method == "nearest, round half to odd") {
    case_when(
      # smaller integer is odd - round half down
      floor(x) %% 2 ~ ceiling(x - 0.5),
      # otherwise, round half up 
      TRUE ~ floor(x + 0.5)
    )
  } else if (method == "nearest, round half randomly") {
    round_half_up <- sample(c(TRUE, FALSE), length(x), replace = TRUE)
    y <- x
    y[round_half_up] <- ceiling(x[round_half_up] - 0.5)
    y[!round_half_up] <- floor(x[!round_half_up] + 0.5)
    y
  }
}
#> function(x, method) {
#>   if (method == "round down") {
#>     floor(x)
#>   } else if (method == "round up") {
#>     ceiling(x)
#>   } else if (method == "round towards zero") {
#>     trunc(x)
#>   } else if (method == "round away from zero") {
#>     sign(x) * ceiling(abs(x))
#>   } else if (method == "nearest, round half up") {
#>     floor(x + 0.5)
#>   } else if (method == "nearest, round half down") {
#>     ceiling(x - 0.5)
#>   } else if (method == "nearest, round half towards zero") {
#>     sign(x) * ceiling(abs(x) - 0.5)
#>   } else if (method == "nearest, round half away from zero") {
#>     sign(x) * floor(abs(x) + 0.5)
#>   } else if (method == "nearest, round half to even") {
#>     round(x, digits = 0)
#>   } else if (method == "nearest, round half to odd") {
#>     case_when(
#>       # smaller integer is odd - round half down
#>       floor(x) %% 2 ~ ceiling(x - 0.5),
#>       # otherwise, round half up 
#>       TRUE ~ floor(x + 0.5)
#>     )
#>   } else if (method == "nearest, round half randomly") {
#>     round_half_up <- sample(c(TRUE, FALSE), length(x), replace = TRUE)
#>     y <- x
#>     y[round_half_up] <- ceiling(x[round_half_up] - 0.5)
#>     y[!round_half_up] <- floor(x[!round_half_up] + 0.5)
#>     y
#>   }
#> }
#> <environment: 0x2b114b8>
```


```r
tibble(
  x = c(1.8, 1.5, 1.2, 0.8, 0.5, 0.2, 
        -0.2, -0.5, -0.8, -1.2, -1.5, -1.8),
  `Round down` = floor(x),
  `Round up` = ceiling(x),
  `Round towards zero` = trunc(x),
  `Nearest, round half to even` = round(x)
) 
#> # A tibble: 12 x 5
#>       x `Round down` `Round up` `Round towards zero` `Nearest, round half to ev…
#>   <dbl>        <dbl>      <dbl>                <dbl>                       <dbl>
#> 1   1.8            1          2                    1                           2
#> 2   1.5            1          2                    1                           2
#> 3   1.2            1          2                    1                           1
#> 4   0.8            0          1                    0                           1
#> 5   0.5            0          1                    0                           0
#> 6   0.2            0          1                    0                           0
#> # … with 6 more rows
```

See the Wikipedia articles, [Rounding](https://en.wikipedia.org/wiki/Rounding) and [IEEE floating point](https://en.wikipedia.org/wiki/IEEE_floating_point) for more discussion of these rounding rules.

For rounding, R and many programming languages use the IEEE standard. This method is called "round to nearest, ties to even".[^rounding]
This rule rounds ties, numbers with a remainder of  0.5, to the nearest even number.
In this rule, half the ties are rounded up, and half are rounded down.
The following function, `round2()`, manually implements the "round to nearest, ties to even" method.

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

This rounding method  may be different than the one you learned in grade school, which is, at least for me, was to always round ties upwards, or, alternatively away from zero.
This rule is called the "round half up" rule.
The problem with the "round half up" rule is that it is biased upwards for positive numbers. 
Rounding to nearest with ties towards even is not.
Consider this sequence which sums to zero.

```r
x <- seq(-100.5, 100.5, by = 1)
x
#>   [1] -100.5  -99.5  -98.5  -97.5  -96.5  -95.5  -94.5  -93.5  -92.5  -91.5
#>  [11]  -90.5  -89.5  -88.5  -87.5  -86.5  -85.5  -84.5  -83.5  -82.5  -81.5
#>  [21]  -80.5  -79.5  -78.5  -77.5  -76.5  -75.5  -74.5  -73.5  -72.5  -71.5
#>  [31]  -70.5  -69.5  -68.5  -67.5  -66.5  -65.5  -64.5  -63.5  -62.5  -61.5
#>  [41]  -60.5  -59.5  -58.5  -57.5  -56.5  -55.5  -54.5  -53.5  -52.5  -51.5
#>  [51]  -50.5  -49.5  -48.5  -47.5  -46.5  -45.5  -44.5  -43.5  -42.5  -41.5
#>  [61]  -40.5  -39.5  -38.5  -37.5  -36.5  -35.5  -34.5  -33.5  -32.5  -31.5
#>  [71]  -30.5  -29.5  -28.5  -27.5  -26.5  -25.5  -24.5  -23.5  -22.5  -21.5
#>  [81]  -20.5  -19.5  -18.5  -17.5  -16.5  -15.5  -14.5  -13.5  -12.5  -11.5
#>  [91]  -10.5   -9.5   -8.5   -7.5   -6.5   -5.5   -4.5   -3.5   -2.5   -1.5
#> [101]   -0.5    0.5    1.5    2.5    3.5    4.5    5.5    6.5    7.5    8.5
#> [111]    9.5   10.5   11.5   12.5   13.5   14.5   15.5   16.5   17.5   18.5
#> [121]   19.5   20.5   21.5   22.5   23.5   24.5   25.5   26.5   27.5   28.5
#> [131]   29.5   30.5   31.5   32.5   33.5   34.5   35.5   36.5   37.5   38.5
#> [141]   39.5   40.5   41.5   42.5   43.5   44.5   45.5   46.5   47.5   48.5
#> [151]   49.5   50.5   51.5   52.5   53.5   54.5   55.5   56.5   57.5   58.5
#> [161]   59.5   60.5   61.5   62.5   63.5   64.5   65.5   66.5   67.5   68.5
#> [171]   69.5   70.5   71.5   72.5   73.5   74.5   75.5   76.5   77.5   78.5
#> [181]   79.5   80.5   81.5   82.5   83.5   84.5   85.5   86.5   87.5   88.5
#> [191]   89.5   90.5   91.5   92.5   93.5   94.5   95.5   96.5   97.5   98.5
#> [201]   99.5  100.5
sum(x)
#> [1] 0
```

A nice property of  rounding preserved that sum.
Using the "ties towards even", the sum is still zero.
However, the "ties towards $+\infty$" produces a non-zero number.

```r
sum(x)
#> [1] 0
sum(round(x))
#> [1] 0
sum(round2(x))
#> [1] 101
```

Rounding rules can have real world impacts.
One notable example was that in 1983, the Vancouver stock exchange adjusted its index from 524.811 to 1098.892 to correct for accumulated error due to rounding to three decimal points (see [Vancouver Stock Exchange](https://en.wikipedia.org/wiki/Vancouver_Stock_Exchange)).
This [site](https://web.ma.utexas.edu/users/arbogast/misc/disasters.html) lists several more examples of the dangers of rounding rules.

</div>

### Exercise 20.3.5 {.unnumbered .exercise data-number="20.3.5"}

<div class="question">
What functions from the readr package allow you to turn a string into logical, integer, and double vector?
</div>

<div class="answer">

The function `parse_logical()` parses logical values, which can appear
as variations of TRUE/FALSE or 1/0.

```r
parse_logical(c("TRUE", "FALSE", "1", "0", "true", "t", "NA"))
#> [1]  TRUE FALSE  TRUE FALSE  TRUE  TRUE    NA
```

The function `parse_integer()` parses integer values.

```r
parse_integer(c("1235", "0134", "NA"))
#> [1] 1235  134   NA
```
However, if there are any non-numeric characters in the string, including
currency symbols, commas, and decimals, `parse_integer()` will raise an error.

```r
parse_integer(c("1000", "$1,000", "10.00"))
#> Warning: 2 parsing failures.
#> row col               expected actual
#>   2  -- an integer             $1,000
#>   3  -- no trailing characters .00
#> [1] 1000   NA   NA
#> attr(,"problems")
#> # A tibble: 2 x 4
#>     row   col expected               actual
#>   <int> <int> <chr>                  <chr> 
#> 1     2    NA an integer             $1,000
#> 2     3    NA no trailing characters .00
```

The function `parse_number()` parses numeric values.
Unlike `parse_integer()`, the function `parse_number()` is more forgiving about the format of the numbers.
It ignores all non-numeric characters before or after the first number, as with `"$1,000.00"` in the example.
Within the number, `parse_number()` will only ignore grouping marks such as `","`.
This allows it to easily parse numeric fields that include currency symbols and comma separators in number strings without any intervention by the user.

```r
parse_number(c("1.0", "3.5", "$1,000.00", "NA", "ABCD12234.90", "1234ABC", "A123B", "A1B2C"))
#> [1]     1.0     3.5  1000.0      NA 12234.9  1234.0   123.0     1.0
```

</div>

## Using atomic vectors {#using-atomic-vectors .r4ds-section}

### Exercise 20.4.1 {.unnumbered .exercise data-number="20.4.1"}

<div class="question">
What does `mean(is.na(x))` tell you about a vector `x`? What about `sum(!is.finite(x))`?
</div>

<div class="answer">

I'll use the numeric vector `x` to compare the behaviors of `is.na()`
and `is.finite()`. It contains numbers (`-1`, `0`, `1`) as 
well as all the special numeric values: infinity (`Inf`), 
missing (`NA`), and not-a-number (`NaN`). 

```r
x <- c(-Inf, -1, 0, 1, Inf, NA, NaN)
```

The expression `mean(is.na(x))` calculates the proportion of missing (`NA`) and not-a-number `NaN` values in a vector:

```r
mean(is.na(x))
#> [1] 0.286
```
The result of 0.286 is equal to `2 / 7` as expected.
There are seven elements in the vector `x`, and two elements that are either `NA` or `NaN`.

The expression `sum(!is.finite(x))` calculates the number of elements in the vector that are equal to missing (`NA`), not-a-number (`NaN`), or infinity (`Inf`). 

```r
sum(!is.finite(x))
#> [1] 4
```

Review the [Numeric](https://r4ds.had.co.nz/vectors.html#numeric) section for the differences between `is.na()` and `is.finite()`.

</div>

### Exercise 20.4.2 {.unnumbered .exercise data-number="20.4.2"}

<div class="question">
Carefully read the documentation of `is.vector()`. What does it actually test for? Why does `is.atomic()` not agree with the definition of atomic vectors above?
</div>

<div class="answer">

The function `is.vector()` only checks whether the object has no attributes other than names. Thus a `list` is a vector:

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

The function `is.atomic()` explicitly checks whether an object is one of the atomic types ("logical", "integer", "numeric", "complex", "character", and "raw") or NULL.


```r
is.atomic(1:10)
#> [1] TRUE
is.atomic(list(a = 1))
#> [1] FALSE
```

The function `is.atomic()` will consider objects to be atomic even if they have extra attributes.

```r
is.atomic(x)
#> [1] TRUE
```

</div>

### Exercise 20.4.3 {.unnumbered .exercise data-number="20.4.3"}

<div class="question">
Compare and contrast `setNames()` with `purrr::set_names()`.
</div>

<div class="answer">

The function `setNames()` takes two arguments, a vector to be named and a vector
of names to apply to its elements.

```r
setNames(1:4, c("a", "b", "c", "d"))
#> a b c d 
#> 1 2 3 4
```
You can use the values of the vector as its names if the `nm` argument is used.

```r
setNames(nm = c("a", "b", "c", "d"))
#>   a   b   c   d 
#> "a" "b" "c" "d"
```

The function `set_names()` has more ways to set the names than `setNames()`.
The names can be specified in the same manner as `setNames()`.

```r
purrr::set_names(1:4, c("a", "b", "c", "d"))
#> a b c d 
#> 1 2 3 4
```
The names can also be specified as unnamed arguments,

```r
purrr::set_names(1:4, "a", "b", "c", "d")
#> a b c d 
#> 1 2 3 4
```
The function `set_names()` will name an object with itself if no `nm` argument is
provided (the opposite of `setNames()` behavior).

```r
purrr::set_names(c("a", "b", "c", "d"))
#>   a   b   c   d 
#> "a" "b" "c" "d"
```

The biggest difference between `set_names()` and `setNames()` is that `set_names()` allows for using a function or formula to transform the existing names.

```r
purrr::set_names(c(a = 1, b = 2, c = 3), toupper)
#> A B C 
#> 1 2 3
purrr::set_names(c(a = 1, b = 2, c = 3), ~toupper(.))
#> A B C 
#> 1 2 3
```

The `set_names()` function also checks that the length of the names argument is the
same length as the vector that is being named, and will raise an error if it is not.

```r
purrr::set_names(1:4, c("a", "b"))
#> Error: `nm` must be `NULL` or a character vector the same length as `x`
```
The `setNames()` function will allow the names to be shorter than the vector being
named, and will set the missing names to `NA`.

```r
setNames(1:4, c("a", "b"))
#>    a    b <NA> <NA> 
#>    1    2    3    4
```

</div>

### Exercise 20.4.4 {.unnumbered .exercise data-number="20.4.4"}

<div class="question">
Create functions that take a vector as input and returns:

1.  The last value. Should you use `[` or `[[`?
1.  The elements at even numbered positions.
1.  Every element except the last value.
1.  Only even numbers (and no missing values).

</div>

<div class="answer">

The answers to the parts follow.

1.  This function find the last value in a vector.

    
    ```r
    last_value <- function(x) {
      # check for case with no length
      if (length(x)) {
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

    The function uses `[[` in order to extract a single element.

1.  This function returns the elements at even number positions.

    
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

1.  This function returns a vector with every element except the last.

    
    ```r
    not_last <- function(x) {
      n <- length(x)
      if (n) {
        x[-n]
      } else {
        # n == 0
        x
      }
    }
    not_last(1:3)
    #> [1] 1 2
    ```

    We should also confirm that the function works with some edge cases, like
    a vector with one element, and a vector with zero elements.
    
    ```r
    not_last(1)
    #> numeric(0)
    not_last(numeric())
    #> numeric(0)
    ```
    In both these cases, `not_last()` correctly returns an empty vector.

1.  This function returns the elements of a vector that are even numbers.

    
    ```r
    even_numbers <- function(x) {
      x[x %% 2 == 0]
    }
    even_numbers(-4:4)
    #> [1] -4 -2  0  2  4
    ```

    We could improve this function by handling the special numeric values:
    `NA`, `NaN`, `Inf`. However, first we need to decide how to handle them.
    Neither `NaN` nor `Inf` are numbers, and so they are neither even nor odd.
    In other words, since `NaN` nor `Inf` aren't *even* numbers, they aren't *even numbers*.
    What about `NA`? Well, we don't know. `NA` is a number, but we don't know its
    value. The missing number could be even or odd, but we don't know.
    Another reason to return `NA` is that it is consistent with the behavior of other R functions, 
    which generally return `NA` values instead of dropping them.

    
    ```r
    even_numbers2 <- function(x) {
      x[!is.infinite(x) & !is.nan(x) & (x %% 2 == 0)]
    }
    even_numbers2(c(0:4, NA, NaN, Inf, -Inf))
    #> [1]  0  2  4 NA
    ```

</div>

### Exercise 20.4.5 {.unnumbered .exercise data-number="20.4.5"}

<div class="question">
Why is `x[-which(x > 0)]` not the same as `x[x <= 0]`?
</div>

<div class="answer">

These expressions differ in the way that they treat missing values.
Let's test how they work by creating a vector with positive and negative integers,
and special values (`NA`, `NaN`, and `Inf`). These values should encompass
all relevant types of values that these expressions would encounter.

```r
x <- c(-1:1, Inf, -Inf, NaN, NA)
x[-which(x > 0)]
#> [1]   -1    0 -Inf  NaN   NA
x[x <= 0]
#> [1]   -1    0 -Inf   NA   NA
```
The expressions  `x[-which(x > 0)]` and `x[x <= 0]` return the same values except
for a `NaN` instead of an `NA` in the expression using which.

So what is going on here? Let's work through each part of these expressions and
see where the different occurs.
Let's start with the expression `x[x <= 0]`.

```r
x <= 0
#> [1]  TRUE  TRUE FALSE FALSE  TRUE    NA    NA
```
Recall how the logical relational operators (`<`, `<=`, `==`, `!=`, `>`, `>=`) treat `NA` values.
Any relational operation that includes a `NA` returns an `NA`.
Is `NA <= 0`? We don't know because it depends on the unknown value of `NA`, so the answer is `NA`.
This same argument applies to `NaN`. Asking whether `NaN <= 0` does not make sense because you can't compare a number to "Not a Number".

Now recall how indexing treats `NA` values.
Indexing can take a logical vector as an input. 
When the indexing vector is logical, the output vector includes those elements where the logical vector is `TRUE`, and excludes those elements where the logical vector is `FALSE`.
Logical vectors can also include `NA` values, and it is not clear how they should be treated.
Well, since the value is `NA`, it could be `TRUE` or `FALSE`, we don't know.
Keeping elements with `NA` would treat the `NA` as `TRUE`, and dropping them would treat the `NA` as `FALSE`.  
The way R decides to handle the `NA` values so that they are treated differently than `TRUE` or `FALSE` values is to include elements where the indexing vector is `NA`, but set their values to `NA`.

Now consider the expression `x[-which(x > 0)]`.
As before, to understand this expression we'll work from the inside out.
Consider `x > 0`.

```r
x > 0
#> [1] FALSE FALSE  TRUE  TRUE FALSE    NA    NA
```
As with `x <= 0`, it returns `NA` for comparisons involving `NA` and `NaN`.

What does `which()` do?

```r
which(x > 0)
#> [1] 3 4
```
The `which()` function returns the indexes for which the argument is `TRUE`.
This means that it is not including the indexes for which the argument is `FALSE` or `NA`.

Now consider the full expression `x[-which(x > 0)]`?
The `which()` function returned a vector of integers.
How does indexing treat negative integers?

```r
x[1:2]
#> [1] -1  0
x[-(1:2)]
#> [1]    1  Inf -Inf  NaN   NA
```
If indexing gets a vector of positive integers, it will select those indexes;
if it receives a vector of negative integers, it will drop those indexes.
Thus, `x[-which(x > 0)]` ends up dropping the elements for which `x > 0` is true,
and keeps all the other elements and their original values, including `NA` and `NaN`.

There's one other special case that we should consider. How do these two expressions work with
an empty vector?

```r
x <- numeric()
x[x <= 0]
#> numeric(0)
x[-which(x > 0)]
#> numeric(0)
```
Thankfully, they both handle empty vectors the same.

This exercise is a reminder to always test your code. Even though these two expressions looked
equivalent, they are not in practice. And when you do test code, consider both
how it works on typical values as well as special values and edge cases, like a
vector with `NA` or `NaN` or `Inf` values, or an empty vector. These are where
unexpected behavior is most likely to occur.

</div>

### Exercise 20.4.6 {.unnumbered .exercise data-number="20.4.6"}

<div class="question">
What happens when you subset with a positive integer that’s bigger than the length of the vector? What happens when you subset with a name that doesn’t exist?
</div>

<div class="answer">

Let's consider the named vector,

```r
x <- c(a = 10, b = 20)
```
If we subset it by an integer larger than its length, it returns a vector of missing values.

```r
x[3]
#> <NA> 
#>   NA
```
This also applies to ranges.

```r
x[3:5]
#> <NA> <NA> <NA> 
#>   NA   NA   NA
```
If some indexes are larger than the length of the vector, those elements are `NA`.

```r
x[1:5]
#>    a    b <NA> <NA> <NA> 
#>   10   20   NA   NA   NA
```

Likewise, when `[` is provided names not in the vector's names, it will return
`NA` for those elements.

```r
x["c"]
#> <NA> 
#>   NA
x[c("c", "d", "e")]
#> <NA> <NA> <NA> 
#>   NA   NA   NA
x[c("a", "b", "c")]
#>    a    b <NA> 
#>   10   20   NA
```

Though not yet discussed much in this chapter, the `[[` behaves differently.
With an atomic vector, if `[[` is given an index outside the range of the vector or an invalid name, it raises an error.

```r
x[["c"]]
#> Error in x[["c"]]: subscript out of bounds
```

```r
x[[5]]
#> Error in x[[5]]: subscript out of bounds
```

</div>

## Recursive vectors (lists) {#lists .r4ds-section}

### Exercise 20.5.1 {.unnumbered .exercise data-number="20.5.1"}

<div class="question">
Draw the following lists as nested sets:

1.  `list(a, b, list(c, d), list(e, f))`
1.  `list(list(list(list(list(list(a))))))`

</div>

<div class="answer">

There are a variety of ways to draw these graphs.
The original diagrams in *R for Data Science* were produced with [Graffle](https://www.omnigroup.com/omnigraffle).
You could also use various diagramming, drawing, or presentation software, including Adobe Illustrator, Inkscape, PowerPoint, Keynote, and Google Slides.

For these examples, I generated these diagrams programmatically using the
[DiagrammeR](http://rich-iannone.github.io/DiagrammeR/graphviz_and_mermaid.html) R package to render [Graphviz](https://www.graphviz.org/) diagrams.

1.  The nested set diagram for
    `list(a, b, list(c, d), list(e, f))`
    is:[^DiagrammeR]



1.  The nested set diagram for
    `list(list(list(list(list(list(a))))))`
    is:

    <!--html_preserve--><div id="htmlwidget-ac96cb3ee4656e2e9ec3" style="width:70%;height:415.296px;" class="grViz html-widget"></div>
    <script type="application/json" data-for="htmlwidget-ac96cb3ee4656e2e9ec3">{"x":{"diagram":"digraph nested_set_2 {\n  node[shape=box]\n  graph[style=rounded]\n  # subgraph for R information\n  subgraph cluster_1 {\n    subgraph cluster_2 {\n      graph[fillcolor=gray90,style=\"rounded,filled\"]\n      subgraph cluster_3 {\n        graph[fillcolor=gray80]\n        subgraph cluster_4 {\n          graph[fillcolor=gray70]\n          subgraph cluster_5 {\n            graph[fillcolor=gray60]\n            subgraph cluster_6 {\n              graph[fillcolor=gray50]\n              node[style=filled,fillcolor=gray40]\n              \"a\"\n            }\n          }\n        }\n      }\n    }\n  }\n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

### Exercise 20.5.2 {.unnumbered .exercise data-number="20.5.2"}

<div class="question">

What happens if you subset a `tibble` as if you’re subsetting a list? What are the key differences between a list and a `tibble`?

</div>

<div class="answer">

Subsetting a `tibble` works the same way as a list; a data frame can be thought of as a list of columns.
The key difference between a list and a `tibble` is that all the elements (columns) of a tibble must have the same length (number of rows).
Lists can have vectors with different lengths as elements.

```r
x <- tibble(a = 1:2, b = 3:4)
x[["a"]]
#> [1] 1 2
x["a"]
#> # A tibble: 2 x 1
#>       a
#>   <int>
#> 1     1
#> 2     2
x[1]
#> # A tibble: 2 x 1
#>       a
#>   <int>
#> 1     1
#> 2     2
x[1, ]
#> # A tibble: 1 x 2
#>       a     b
#>   <int> <int>
#> 1     1     3
```

</div>

## Attributes {#attributes .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

## Augmented vectors {#augmented-vectors .r4ds-section}

### Exercise 20.7.1 {.unnumbered .exercise data-number="20.7.1"}

<div class="question">

What does `hms::hms(3600)` return? How does it print? What primitive type is the augmented vector built on top of? What attributes does it use?

</div>

<div class="answer">


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

The attributes is uses are `"units"` and `"class"`.

```r
attributes(x)
#> $units
#> [1] "secs"
#> 
#> $class
#> [1] "hms"      "difftime"
```

</div>

### Exercise 20.7.2 {.unnumbered .exercise data-number="20.7.2"}

<div class="question">
Try and make a tibble that has columns with different lengths. What happens?
</div>

<div class="answer">

If I try to create a tibble with a scalar and column of a different length there are no issues, and the scalar is repeated to the length of the longer vector.

```r
tibble(x = 1, y = 1:5)
#> # A tibble: 5 x 2
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
#> Error: Tibble columns must have compatible sizes.
#> * Size 3: Existing data.
#> * Size 4: Column `y`.
#> ℹ Only values of size one are recycled.
```

</div>

### Exercise 20.7.3 {.unnumbered .exercise data-number="20.7.3"}

<div class="question">
Based on the definition above, is it OK to have a list as a column of a tibble?
</div>

<div class="answer">

If I didn't already know the answer, what I would do is try it out.
From the above, the error message was about vectors having different lengths.
But there is nothing that prevents a tibble from having vectors of different types: doubles, character, integers, logical, factor, date.
The later are still atomic, but they have additional attributes.
So, maybe there won't be an issue with a list vector as long as it is the same length.


```r
tibble(x = 1:3, y = list("a", 1, list(1:3)))
#> # A tibble: 3 x 2
#>       x y         
#>   <int> <list>    
#> 1     1 <chr [1]> 
#> 2     2 <dbl [1]> 
#> 3     3 <list [1]>
```

It works! I even used a list with heterogeneous types and there wasn't an issue.
In following chapters we'll see that list vectors can be very useful: for example, when processing many different models.

</div>

[^DiagrammeR]: These diagrams were created with the [DiagrammeR](https://rich-iannone.github.io/DiagrammeR/) package.
[^rounding]: See the documentation for `.Machine$double.rounding`.
