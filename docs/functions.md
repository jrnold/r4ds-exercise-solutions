
# Functions

## Introduction


```r
library("tidyverse")
library("lubridate")
```

## When should you write a function?

### Exercise <span class="exercise-number">19.2.1</span> {.unnumbered .exercise}

<div class="question">

Why is TRUE not a parameter to `rescale01()`?
What would happen if `x` contained a single missing value, and `na.rm` was `FALSE`?

</div>

<div class="answer">

First, note that by a a single missing value, this means that the vector `x` has at least one element equal to `NA`.

If there were any `NA` values, and `na.rm = FALSE`, then the function would
return `NA`.

I can confirm this by testing a function that allows for `na.rm` as an argument,

```r
rescale01_alt <- function(x, finite = TRUE) {
  rng <- range(x, na.rm = finite, finite = finite)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01_alt(c(NA, 1:5), finite = FALSE)
#> [1] NA NA NA NA NA NA
rescale01_alt(c(NA, 1:5), finite = TRUE)
#> [1]   NA 0.00 0.25 0.50 0.75 1.00
```

</div>

### Exercise <span class="exercise-number">19.2.2</span> {.unnumbered .exercise}

<div class="question">

In the second variant of `rescale01()`, infinite values are left unchanged.
Rewrite `rescale01()` so that `-Inf` is mapped to 0, and `Inf` is mapped to 1.

</div>

<div class="answer">


```r
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  y <- (x - rng[1]) / (rng[2] - rng[1])
  y[y == -Inf] <- 0
  y[y == Inf] <- 1
  y
}

rescale01(c(Inf, -Inf, 0:5, NA))
#> [1] 1.0 0.0 0.0 0.2 0.4 0.6 0.8 1.0  NA
```

</div>

### Exercise <span class="exercise-number">19.2.3</span> {.unnumbered .exercise}

<div class="question">

Practice turning the following code snippets into functions. Think about what each function does. What would you call it? How many arguments does it need? Can you rewrite it to be more expressive or less duplicative?


```r
mean(is.na(x))

x / sum(x, na.rm = TRUE)

sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
```

</div>

<div class="answer">

This code calculates the proportion of `NA` values in a vector.

```r
mean(is.na(x))
```
I will write it as a function named `prop_na()` that takes a single argument `x`,
and returns a single numeric value between 0 and 1.

```r
prop_na <- function(x) {
  mean(is.na(x))
}
prop_na(c(0, 1, 2, NA, 4, NA))
#> [1] 0.333
```

This code standardizes a vector so that it sums to 1.

```r
x / sum(x, na.rm = TRUE)
```
I'll write a function named `sum_to_one()`, which is a function of a single argument, `x`, the vector to standardize, and an optional argument `na.rm`.
The optional argument, `na.rm`, makes the function more expressive, since it can
handle `NA` values in two ways (returning `NA` or dropping them).
Additionally, this makes `sum_to_one()` consistent with `sum()`, `mean()`, and many
other R functions which have a `na.rm` argument.
While the example code had `na.rm = TRUE`, I set `na.rm = FALSE` by default
in order to make the function behave the same as the built-in functions like `sum()` and `mean()` in its handling of missing values.

```r
sum_to_one <- function(x, na.rm = FALSE) {
  x / sum(x, na.rm = na.rm)
}
```


```r
# no missing values
sum_to_one(1:5)
#> [1] 0.0667 0.1333 0.2000 0.2667 0.3333
# if any missing, return all missing
sum_to_one(c(1:5, NA))
#> [1] NA NA NA NA NA NA
# drop missing values when standarizing
sum_to_one(c(1:5, NA), na.rm = TRUE)
#> [1] 0.0667 0.1333 0.2000 0.2667 0.3333     NA
```

This code calculates the [coefficient of variation](https://en.wikipedia.org/wiki/Coefficient_of_variation) (assuming that `x` can only take non-negative values), which is the standard deviation divided by the mean.

```r
sd(x, na.rm = TRUE) / mean(x, na.rm = TRUE)
```
I'll write a function named `coef_variation()`, which takes a single argument `x`,
and an optional `na.rm` argument.

```r
coef_variation <- function(x, na.rm = FALSE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}
coef_variation(1:5)
#> [1] 0.527
coef_variation(c(1:5, NA))
#> [1] NA
coef_variation(c(1:5, NA), na.rm = TRUE)
#> [1] 0.527
```

</div>

### Exercise <span class="exercise-number">19.2.4</span> {.unnumbered .exercise}

<div class="question">

Follow <http://nicercode.github.io/intro/writing-functions.html> to write your own functions to compute the variance and skew of a numeric vector.

</div>

<div class="answer">

**Note** The math in <https://nicercode.github.io/intro/writing-functions.html> seems not to be rendering, but I'll write functions for the variance and skewness.

The sample variance is defined as
$$
Var(x) = \frac{1}{n - 1} \sum_{i=1}^n (x_i - \bar{x}) ^2
$$
where the sample mean is $\bar{x} = (\sum x_i) / n$.

```r
variance <- function(x, na.rm = TRUE) {
  n <- length(x)
  m <- mean(x, na.rm = TRUE)
  sq_err <- (x - m) ^ 2
  sum(sq_err) / (n - 1)
}
var(1:10)
#> [1] 9.17
variance(1:10)
#> [1] 9.17
```

There are multiple definitions of [skewness](https://en.wikipedia.org/wiki/Skewness),
but one of the most commonly used is the following:[@DoaneSeward2011]
$$
\mathsf{skewness}(x) = \frac{n}{(n - 1)(n - 2)} \sum_{i = 1}^{n} {\left( \frac{x_i - \bar{x}}{s} \right)}^{3} .
$$
where $\bar{x}$ is the sample mean and
$$
s = \sqrt{\frac{1}{n - 1} \sum_{i = 1}^{n} (x_i - \bar{x})^2}
$$
is the sample standard deviation.
The corresponding function is:

```r
skewness <- function(x, na.rm = FALSE) {
  n <- length(x)
  m <- mean(x, na.rm = na.rm)
  s <- sd(x, na.rm = na.rm)
  n * sum(((x - m) / s) ^ 3) / (n - 1) / (n - 2)
}
skewness(c(1, 2, 5, 100))
#> [1] 1.99
```

</div>

### Exercise <span class="exercise-number">19.2.5</span> {.unnumbered .exercise}

<div class="question">

Write `both_na()`, a function that takes two vectors of the same length and returns the number of positions that have an `NA` in both vectors.

</div>

<div class="answer">


```r
both_na <- function(x, y) {
  sum(is.na(x) & is.na(y))
}
both_na(c(NA, NA,  1, 2),
        c(NA,  1, NA, 2))
#> [1] 1
both_na(c(NA, NA,  1, 2, NA, NA, 1),
        c(NA,  1, NA, 2, NA, NA, 1))
#> [1] 3
```

</div>

### Exercise <span class="exercise-number">19.2.6</span> {.unnumbered .exercise}

<div class="question">
What do the following functions do? Why are they useful even though they are so short?
</div>

<div class="answer">


```r
is_directory <- function(x) file.info(x)$isdir
is_readable <- function(x) file.access(x, 4) == 0
```

The function `is_directory()` checks whether the path in `x` is a directory.
The function `is_readable()` checks whether the path in `x` is readable, meaning that the file exists and the user has permission to open it.
These functions are useful even though they are short because their names make it much clearer what the code is doing.

</div>

### Exercise <span class="exercise-number">19.2.7</span> {.unnumbered .exercise}

<div class="question">

Read the complete lyrics to ``Little Bunny Foo Foo''. There’s a lot of duplication in this song. Extend the initial piping example to recreate the complete song, and use functions to reduce the duplication.

</div>

<div class="answer">
The lyrics of one of the [most common versions](https://en.wikipedia.org/wiki/Little_Bunny_Foo_Foo) of this song are

> Little bunny Foo Foo \
> Hopping through the forest \
> Scooping up the field mice \
> And bopping them on the head
>
> Down came the Good Fairy, and she said \
> "Little bunny Foo Foo \
> I don't want to see you \  
> Scooping up the field mice
>
> And bopping them on the head. \
> I'll give you three chances, \
> And if you don't stop, I'll turn you into a GOON!" \
> And the next day...

The verses repeat with one chance fewer each time.
When there are no chances left, the Good Fairy says

> "I gave you three chances, and you didn't stop; so...." \
> POOF. She turned him into a GOON! \
> And the moral of this story is: *hare today, goon tomorrow.*

Here's one way of writing this
```r
threat <- function(chances) {
  give_chances(from = Good_Fairy,
               to = foo_foo,
               number = chances,
               condition = "Don't behave",
               consequence = turn_into_goon)  
}

lyric <- function() {
  foo_foo %>%
    hop(through = forest) %>%
    scoop(up = field_mouse) %>%
    bop(on = head)

  down_came(Good_Fairy)
  said(Good_Fairy,
      c("Little bunny Foo Foo",
        "I don't want to see you",
        "Scooping up the field mice",
        "And bopping them on the head.")
}

lyric()
threat(3)
lyric()
threat(2)
lyric()
threat(1)
lyric()
turn_into_goon(Good_Fairy, foo_foo)

```

</div>

## Functions are for humans and computers

### Exercise <span class="exercise-number">19.3.1</span> {.unnumbered .exercise}

<div class="question">
Read the source code for each of the following three functions, puzzle out what they do, and then brainstorm better names.
</div>

<div class="answer">


```r
f1 <- function(string, prefix) {
  substr(string, 1, nchar(prefix)) == prefix
}

f2 <- function(x) {
  if (length(x) <= 1) return(NULL)
  x[-length(x)]
}

f3 <- function(x, y) {
  rep(y, length.out = length(x))
}
```

The function `f1` returns whether a function has a common prefix.

```r
f1(c("str_c", "str_foo", "abc"), "str_")
#> [1]  TRUE  TRUE FALSE
```
A better name for `f1` is `has_prefix()`

The function `f2` drops the last element

```r
f2(1:3)
#> [1] 1 2
f2(1:2)
#> [1] 1
f2(1)
#> NULL
```
A better name for `f2` is `drop_last()`.

The function `f3` repeats `y` once for each element of `x`.

```r
f3(1:3, 4)
#> [1] 4 4 4
```
Good names would include `recycle()` (R's name for this behavior), or `expand()`.

</div>

### Exercise <span class="exercise-number">19.3.2</span> {.unnumbered .exercise}

<div class="question">
Take a function that you’ve written recently and spend 5 minutes brainstorming a better name for it and its arguments.
</div>

<div class="answer">

Answer left to the reader.

</div>

### Exercise <span class="exercise-number">19.3.3</span> {.unnumbered .exercise}

<div class="question">
Compare and contrast `rnorm()` and `MASS::mvrnorm()`. How could you make them more consistent?
</div>

<div class="answer">

`rnorm()` samples from the univariate normal distribution, while `MASS::mvrnorm`
samples from the multivariate normal distribution. The main arguments in
`rnorm()` are `n`, `mean`, `sd`. The main arguments is `MASS::mvrnorm` are `n`,
`mu`, `Sigma`. To be consistent they should have the same names. However, this
is difficult. In general, it is better to be consistent with more widely used
functions, e.g. `rmvnorm()` should follow the conventions of `rnorm()`. However,
while `mean` is correct in the multivariate case, `sd` does not make sense in
the multivariate case. However, both functions are internally consistent.
It would not be good practice to have `mu` and `sd` as arguments or `mean` and `Sigma` as arguments.

</div>

### Exercise <span class="exercise-number">19.3.4</span> {.unnumbered .exercise}

<div class="question">
Make a case for why `norm_r()`, `norm_d()` etc would be better than `rnorm()`, `dnorm()`. Make a case for the opposite.
</div>

<div class="answer">

If named `norm_r()` and `norm_d()`, the naming convention groups functions by their
distribution.

If named `rnorm()`, and `dnorm()`, the naming convention groups functions
by the action they perform.

-   `r*` functions always sample from distributions: for example,
    `rnorm()`, `rbinom()`, `runif()`, and `rexp()`.

-   `d*` functions calculate the probability density or mass of a distribution: 
    For example, `dnorm()`, `dbinom()`, `dunif()`, and `dexp()`.
    
R distributions use this latter naming convention.

</div>

## Conditional execution

### Exercise <span class="exercise-number">19.4.1</span> {.unnumbered .exercise}

<div class="question">
What’s the difference between `if` and `ifelse()`? > Carefully read the help and construct three examples that illustrate the key differences.
</div>

<div class="answer">

The keyword `if` tests a single condition, while `ifelse()` tests each element.

</div>

### Exercise <span class="exercise-number">19.4.2</span> {.unnumbered .exercise}

<div class="question">
Write a greeting function that says “good morning”, “good afternoon”, or “good evening”, depending on the time of day. (Hint: use a time argument that defaults to `lubridate::now()`. That will make it easier to test your function.)
</div>

<div class="answer">


```r
greet <- function(time = lubridate::now()) {
  hr <- lubridate::hour(time)
  # I don't know what to do about times after midnight,
  # are they evening or morning?
  if (hr < 12) {
    print("good morning")
  } else if (hr < 17) {
    print("good afternoon")
  } else {
    print("good evening")
  }
}
greet()
#> [1] "good afternoon"
greet(ymd_h("2017-01-08:05"))
#> [1] "good morning"
greet(ymd_h("2017-01-08:13"))
#> [1] "good afternoon"
greet(ymd_h("2017-01-08:20"))
#> [1] "good evening"
```

</div>

### Exercise <span class="exercise-number">19.4.3</span> {.unnumbered .exercise}

<div class="question">

Implement a `fizzbuzz()` function. It takes a single number as input. If the
number is divisible by three, it returns “fizz”. If it’s divisible by five it
returns “buzz”. If it’s divisible by three and five, it returns “fizzbuzz”.
Otherwise, it returns the number. Make sure you first write working code before
you create the function.

</div>

<div class="answer">


```r
fizzbuzz <- function(x) {
  stopifnot(length(x) == 1)
  stopifnot(is.numeric(x))
  # this could be made more efficient by minimizing the
  # number of tests
  if (!(x %% 3) && !(x %% 5)) {
    "fizzbuzz"
  } else if (!(x %% 3)) {
    "fizz"
  } else if (!(x %% 5)) {
    "buzz"
  } else {
    x
  }
}
fizzbuzz(6)
#> [1] "fizz"
fizzbuzz(10)
#> [1] "buzz"
fizzbuzz(15)
#> [1] "fizzbuzz"
fizzbuzz(2)
#> [1] 2
```

</div>

### Exercise <span class="exercise-number">19.4.4</span> {.unnumbered .exercise}

<div class="question">
How could you use `cut()` to simplify this set of nested if-else statements?
</div>

<div class="answer">


```r
if (temp <= 0) {
  "freezing"
} else if (temp <= 10) {
  "cold"
} else if (temp <= 20) {
  "cool"
} else if (temp <= 30) {
  "warm"
} else {
  "hot"
}
```
How would you change the call to `cut()` if I’d used `<` instead of `<=`? What is the other chief advantage of cut() for this problem? (Hint: what happens if you have many values in temp?)


```r
temp <- seq(-10, 50, by = 5)
cut(temp, c(-Inf, 0, 10, 20, 30, Inf), right = TRUE,
    labels = c("freezing", "cold", "cool", "warm", "hot"))
#>  [1] freezing freezing freezing cold     cold     cool     cool    
#>  [8] warm     warm     hot      hot      hot      hot     
#> Levels: freezing cold cool warm hot
```

To have intervals open on the left (using `<`), I change the argument to `right = FALSE`,

```r
temp <- seq(-10, 50, by = 5)
cut(temp, c(-Inf, 0, 10, 20, 30, Inf), right = FALSE,
    labels = c("freezing", "cold", "cool", "warm", "hot"))
#>  [1] freezing freezing cold     cold     cool     cool     warm    
#>  [8] warm     hot      hot      hot      hot      hot     
#> Levels: freezing cold cool warm hot
```

Two advantages of using `cut` is that it works on vectors, whereas `if` only works on a single value (I already demonstrated this above),
and that to change comparisons I only needed to change the argument to `right`, but I would have had to change four operators in the `if` expression.

</div>

### Exercise <span class="exercise-number">19.4.5</span> {.unnumbered .exercise}

<div class="question">

What happens if you use `switch()` with numeric values?

</div>

<div class="answer">

In `switch(n, ...)`, if `n` is numeric, it will return the `n`th argument from `...`.
This means that if `n = 1`, `switch()` will return the first argument in `...`,
if `n = 2`, the second, and so on.
For example,

```r
switch(1, "apple", "banana", "cantaloupe")
#> [1] "apple"
switch(2, "apple", "banana", "cantaloupe")
#> [1] "banana"
```

If you use a non-integer number for the first argument of `switch()`, it will
ignore the non-integer part.

```r
switch(1.2, "apple", "banana", "cantaloupe")
#> [1] "apple"
switch(2.8, "apple", "banana", "cantaloupe")
#> [1] "banana"
```
Note that `switch()` truncates the numeric value, it does not round to the nearest integer.
While it is possible to use non-integer numbers with `switch()`, you should avoid it

</div>

### Exercise <span class="exercise-number">19.4.6</span> {.unnumbered .exercise}

<div class="question">
What does this `switch()` call do? What happens if `x` is `"e"`?

```r
x <- "e"
switch(x,
  a = ,
  b = "ab",
  c = ,
  d = "cd"
)
```

Experiment, then carefully read the documentation.

</div>

<div class="answer">

First, let's write a function `switcheroo()`, and see what it returns for different values of `x`.

```r
switcheroo <- function(x) {
  switch(x,
    a = ,
    b = "ab",
    c = ,
    d = "cd"
  )
}
switcheroo("a")
#> [1] "ab"
switcheroo("b")
#> [1] "ab"
switcheroo("c")
#> [1] "cd"
switcheroo("d")
#> [1] "cd"
switcheroo("e")
switcheroo("f")
```

The `switcheroo()` function returns `"ab"` for `x = "a"` or `x = "b"`,
`"cd"` for `x = "c"` or `x = "d"`, and
`NULL` for `x = "e"` or any other value of `x` not in `c("a", "b", "c", "d")`.

How does this work?
The `switch()` function returns the first non-missing argument value for the first name it matches.
Thus, when `switch()` encounters an argument with a missing value, like `a = ,`,
it will return the value of the next argument with a non missing value, which in this case is `b = "ab"`.
If `object` in `switch(object=)` is not equal to the names of any of its arguments,
`switch()` will return either the last (unnamed) argument if one is present or `NULL`.
Since `"e"` is not one of the named arguments in `switch()` (`a`, `b`, `c`, `d`),
and no other unnamed default value is present, this code will return `NULL`.

The code in the question is shorter way of writing the following.
```r
switch(x,
  a = "ab",
  b = "ab",
  c = "cd",
  d = "cd",
  NULL  # value to return if x not matched
)
```

</div>

## Function arguments

### Exercise <span class="exercise-number">19.5.1</span> {.unnumbered .exercise}

<div class="question">
What does `commas(letters, collapse = "-")` do? Why?
</div>

<div class="answer">

The `commas()` function in the chapter is defined as

```r
commas <- function(...) {
  stringr::str_c(..., collapse = ", ")
}
```

When `commas()` is given a collapse argument, it throws an error.

```r
commas(letters, collapse = "-")
#> Error in stringr::str_c(..., collapse = ", "): formal argument "collapse" matched by multiple actual arguments
```
This is because when the argument `collapse` is given to `commas()`, it
is passed to `str_c()` as part of `...`.
In other words, the previous code is equivalent to

```r
str_c(letters, collapse = "-", collapse = ", ")
```
However, it is an error to give the same named argument to a function twice.

One way to allow the user to override the separator in `commas()` is to add a `collapse`
argument to the function.

```r
commas <- function(..., collapse = ", ") {
  stringr::str_c(..., collapse = collapse)
}
```

</div>

### Exercise <span class="exercise-number">19.5.2</span> {.unnumbered .exercise}

<div class="question">

It’d be nice if you could supply multiple characters to the `pad` argument, e.g. `rule("Title", pad = "-+")`.
Why doesn’t this currently work? How could you fix it?

</div>

<div class="answer">

This is the definition of the rule function from the [chapter](http://r4ds.had.co.nz/functions.html).

```r
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}
```

```r
rule("Important output")
#> Important output ------------------------------------------------------
```

You can currently supply multiple characters to the `pad` argument, but the output is
will not be the desired width. The `rule()` function duplicates `pad` a number of times
equal to the desired width minus the length of the title and five extra characters.
This implicitly assumes that `pad` is only one character. If `pad` were two character,
the output will be almost twice as long.

```r
rule("Valuable output", pad = "-+")
#> Valuable output -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

One way to handle this is to use `stringr::str_trunc()` to truncate the string,
and `stringr::str_length()` to calculate the number of characters in the `pad` argument.

```r
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  padding <- stringr::str_dup(pad,
                              ceiling(width / stringr::str_length(title))) %>%
    stringr::str_trunc(width)
  cat(title, " ", padding, "\n", sep = "")
}
rule("Important output")
#> Important output ----
rule("Valuable output", pad = "-+")
#> Valuable output -+-+-+-+
rule("Vital output", pad = "-+-")
#> Vital output -+--+--+--+--+-
```

Note that in the second output, there is only a single `-` at the end.

</div>

### Exercise <span class="exercise-number">19.5.3</span> {.unnumbered .exercise}

<div class="question">
What does the `trim` argument to `mean()` do? When might you use it?
</div>

<div class="answer">

The `trim` arguments trims a fraction of observations from each end of the vector (meaning the range) before calculating the mean.
This is useful for calculating a measure of central tendency that is robust to outliers.

</div>

### Exercise <span class="exercise-number">19.5.4</span> {.unnumbered .exercise}

<div class="question">
The default value for the `method` argument to `cor()` is `c("pearson", "kendall", "spearman")`.
What does that mean? What value is used by default?
</div>

<div class="answer">

It means that the `method` argument can take one of those three values.
The first value, `"pearson"`, is used by default.

</div>

## Return values

No Exercises

## Environment

No Exercises
