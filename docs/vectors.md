
# Vectors

## Introduction


```r
library("tidyverse")
```

## Vector Basics

No exercises

## Important Types of Atomic Vector

### Exercise <span class="exercise-number">20.3.1</span> {.unnumbered .exercise}

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

### Exercise <span class="exercise-number">20.3.2</span> {.unnumbered .exercise}

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
#> <bytecode: 0x564e2380e908>
#> <environment: namespace:dplyr>
```

Instead of checking for exact equality, it checks that two numbers are within a certain tolerance, `tol`.
By default the tolerance is set to the square root of `.Machine$double.eps`, which is the smallest floating point number that the computer can represent.

</div>

### Exercise <span class="exercise-number">20.3.3</span> {.unnumbered .exercise}

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

### Exercise <span class="exercise-number">20.3.4</span> {.unnumbered .exercise}

<div class="question">
Brainstorm at least four functions that allow you to convert a double to an integer. How do they differ? Be precise.
</div>

<div class="answer">

Broadly, could convert a double to an integer by truncating or rounding to the nearest integer.
For truncating or for handling ties (doubles ending in 0.5), there are multiple methods for determining which integer value to go to.

| methods                        | 0.5  | -0.5  | 1.5  | -1.5  |
| ------------------------------ | ---- | ----- | ---- | ----- |
| towards zero:                  | 0    | 0     | 1    | 1     |
| away from zero                 | 1    | -1    | 2    | -2    |
| largest towards $+\infty$)     | 1    | 0     | 2    | -1    |
| smallest (towards $-\infty$)   | 0    | -1    | 1    | -2    |
| even                           | 0    | 0     | 2    | -2    |
| odd                            | 1    | -1    | 1    | -1    |

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
However, the "ties towards $+\infty$" produces a non-zero number.

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
In 1983, the Vancouver stock exchange adjusted its index from 524.811 to 1098.892 to correct for accumulated error due to rounding to three decimal points (see [Vancouver Stock Exchange](https://en.wikipedia.org/wiki/Vancouver_Stock_Exchange)).

Here's a [list](https://www.ma.utexas.edu/users/arbogast/misc/disasters.html) of a few more.

</div>

### Exercise <span class="exercise-number">20.3.5</span> {.unnumbered .exercise}

<div class="question">
What functions from the **readr** package allow you to turn a string into logical, integer, and double vector?
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
#> Warning in rbind(names(probs), probs_f): number of columns of result is not
#> a multiple of vector length (arg 1)
#> Warning: 2 parsing failures.
#> row # A tibble: 2 x 4 col     row   col expected               actual expected   <int> <int> <chr>                  <chr>  actual 1     2    NA an integer             $1,000 row 2     3    NA no trailing characters .00
#> [1] 1000   NA   NA
#> attr(,"problems")
#> # A tibble: 2 x 4
#>     row   col expected               actual
#>   <int> <int> <chr>                  <chr> 
#> 1     2    NA an integer             $1,000
#> 2     3    NA no trailing characters .00
```

The function `parse_number()` parses integer values.

```r
parse_number(c("1.0", "3.5", "$1,000.00", "NA"))
#> [1]    1.0    3.5 1000.0     NA
```

Unlike `parse_integer()`, the function `parse_number()` is very forgiving about the format of the numbers.
It ignores all non-numeric characters, as with `"$1,000.00"` in the example.
This allows it to easily parse numeric fields that include currency symbols and comma separators in number strings without any intervention by the user.

</div>

## Using atomic vectors

### Exercise <span class="exercise-number">20.4.1</span> {.unnumbered .exercise}

<div class="question">
What does `mean(is.na(x))` tell you about a vector `x`? What about `sum(!is.finite(x))`?
</div>

<div class="answer">

The expression `mean(is.na(x))` calculates the proportion of missing values in a vector

```r
x <- c(1:10, NA, NaN, Inf, -Inf)
mean(is.na(x))
#> [1] 0.143
```

The expression `mean(!is.finite(x))` calculates the proportion of values that are `NA`, `NaN`, or infinite.

```r
mean(!is.finite(x))
#> [1] 0.286
```

</div>

### Exercise <span class="exercise-number">20.4.2</span> {.unnumbered .exercise}

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

### Exercise <span class="exercise-number">20.4.3</span> {.unnumbered .exercise}

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
You can name an vector with itself if the `nm` argument is used.

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
purrr::set_names(c(a = 1, b = 2, c = 3), ~ toupper(.))
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

### Exercise <span class="exercise-number">20.4.4</span> {.unnumbered .exercise}

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

1.  This function returns a the elements of a vector that are even numbers.

    
    ```r
    even_numbers <- function(x) {
      x[x %% 2 == 0]
    }
    even_numbers(-10:10)
    #>  [1] -10  -8  -6  -4  -2   0   2   4   6   8  10
    ```

    We could improve this function by handling the cases of the special values:
    `NA`, `NaN`, `Inf`. However, first we need to decide how to handle them.
    Neither `NaN` nor `Inf` are considered even numbers. What about `NA`?
    Well, we don't know. The value of `NA` could be even or odd, but it is missing.
    So we will follow the convention of many R functions and keep the `NA` values.
    The revised function now handles these cases.
    
    ```r
    even_numbers <- function(x) {
      x[!is.infinite(x) & !is.nan(x) & (x %% 2 == 0)]
    }
    even_numbers(c(0:4, NA, NaN, Inf))
    #> [1]  0  2  4 NA
    ```

</div>

### Exercise <span class="exercise-number">20.4.5</span> {.unnumbered .exercise}

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
for a `NaN` instead of a `NA` in the `which()` based expression.

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
Indexing can use a logical vector, and will include those elements where the logical vector is `TRUE`,
and will not not return those elements where the logical vector is `FALSE`.
Since a logical vector can include `NA` values, what should it do for them?
Well, since the value is `NA` it could be `TRUE` or `FALSE`, we don't know.
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

### Exercise <span class="exercise-number">20.4.6</span> {.unnumbered .exercise}

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

## Recursive Vectors (lists)

### Exercise <span class="exercise-number">20.5.1</span> {.unnumbered .exercise}

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
    is



    

1.  The nested set diagram for
    `list(list(list(list(list(list(a))))))1`
    is as follows.



    

</div>

### Exercise <span class="exercise-number">20.5.2</span> {.unnumbered .exercise}

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

## Attributes

No exercises

## Augmented Vectors

### Exercise <span class="exercise-number">20.7.1</span> {.unnumbered .exercise}

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
#> $class
#> [1] "hms"      "difftime"
#> 
#> $units
#> [1] "secs"
```

</div>

### Exercise <span class="exercise-number">20.7.2</span> {.unnumbered .exercise}

<div class="question">
Try and make a tibble that has columns with different lengths. What happens?
</div>

<div class="answer">

If I try to create at tibble with a scalar and column of a different length there are no issues, and the scalar is repeated to the length of the longer vector.

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
#> Error: Column `x` must be length 1 or 4, not 3
```

</div>

### Exercise <span class="exercise-number">20.7.3</span> {.unnumbered .exercise}

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

[^double-rounding: The built-in variable `.Machine$double.rounding` indicates
                   the rounding method used by R. It states that the round half to even
                   method is expected to be used, but this may differ by operating system.
