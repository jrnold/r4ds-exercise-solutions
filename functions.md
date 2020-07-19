# Functions {#functions .r4ds-section}

## Introduction {#introduction-12 .r4ds-section}


```r
library("tidyverse")
library("lubridate")
```

## When should you write a function? {#when-should-you-write-a-function .r4ds-section}

### Exercise 19.2.1 {.unnumbered .exercise data-number="19.2.1"}

<div class="question">

Why is `TRUE` not a parameter to `rescale01()`?
What would happen if `x` contained a single missing value, and `na.rm` was `FALSE`?

</div>

<div class="answer">

The code for `rescale01()` is reproduced below.

```r
rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
```

If `x` contains a single missing value and `na.rm = FALSE`, then this function stills return a non-missing value.

```r
rescale01_alt <- function(x, na.rm = FALSE) {
  rng <- range(x, na.rm = na.rm, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01_alt(c(NA, 1:5), na.rm = FALSE)
#> [1]   NA 0.00 0.25 0.50 0.75 1.00
rescale01_alt(c(NA, 1:5), na.rm = TRUE)
#> [1]   NA 0.00 0.25 0.50 0.75 1.00
```
The option `finite = TRUE` to `range()` will drop all non-finite elements, and `NA` is a non-finite element.

However, if both `finite = FALSE` and `na.rm = FALSE`, then this function will return a vector of `NA` values.
Recall, arithmetic operations involving `NA` values return `NA`.

```r
rescale01_alt2 <- function(x, na.rm = FALSE, finite = FALSE) {
  rng <- range(x, na.rm = na.rm, finite = finite)
  (x - rng[1]) / (rng[2] - rng[1])
}
rescale01_alt2(c(NA, 1:5), na.rm = FALSE, finite = FALSE)
#> [1] NA NA NA NA NA NA
```

</div>

### Exercise 19.2.2 {.unnumbered .exercise data-number="19.2.2"}

<div class="question">

In the second variant of `rescale01()`, infinite values are left unchanged.
Rewrite `rescale01()` so that `-Inf` is mapped to `0`, and `Inf` is mapped to `1`.

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

### Exercise 19.2.3 {.unnumbered .exercise data-number="19.2.3"}

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

This code standardizes a vector so that it sums to one.

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
# drop missing values when standardizing
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

### Exercise 19.2.4 {.unnumbered .exercise data-number="19.2.4"}

<div class="question">

Follow <https://nicercode.github.io/intro/writing-functions.html> to write your own functions to compute the variance and skew of a numeric vector.

</div>

<div class="answer">

**Note** The math in <https://nicercode.github.io/intro/writing-functions.html> seems not to be rendering.

The sample variance is defined as,
$$
\mathrm{Var}(x) = \frac{1}{n - 1} \sum_{i=1}^n (x_i - \bar{x}) ^2 \text{,}
$$
where $\bar{x} = (\sum_i^n x_i) / n$ is the sample mean.
The corresponding function is:

```r
variance <- function(x, na.rm = TRUE) {
  n <- length(x)
  m <- mean(x, na.rm = TRUE)
  sq_err <- (x - m)^2
  sum(sq_err) / (n - 1)
}
```

```r
var(1:10)
#> [1] 9.17
variance(1:10)
#> [1] 9.17
```

There are multiple definitions for [skewness](https://en.wikipedia.org/wiki/Skewness), but we will use the following one,
$$
\mathrm{Skew}(x) = \frac{\frac{1}{n - 2}\left(\sum_{i=1}^{n}(x_{i} - \bar x)^3\right)}{\mathrm{Var}(x)^{3 / 2}} \text{.}
$$

The corresponding function is:

```r
skewness <- function(x, na.rm = FALSE) {
  n <- length(x)
  m <- mean(x, na.rm = na.rm)
  v <- var(x, na.rm = na.rm)
  (sum((x - m) ^ 3) / (n - 2)) / v ^ (3 / 2)
}
```

```r
skewness(c(1, 2, 5, 100))
#> [1] 1.49
```

</div>

### Exercise 19.2.5 {.unnumbered .exercise data-number="19.2.5"}

<div class="question">

Write `both_na()`, a function that takes two vectors of the same length and returns the number of positions that have an `NA` in both vectors.

</div>

<div class="answer">


```r
both_na <- function(x, y) {
  sum(is.na(x) & is.na(y))
}
both_na(
  c(NA, NA, 1, 2),
  c(NA, 1, NA, 2)
)
#> [1] 1
both_na(
  c(NA, NA, 1, 2, NA, NA, 1),
  c(NA, 1, NA, 2, NA, NA, 1)
)
#> [1] 3
```

</div>

### Exercise 19.2.6 {.unnumbered .exercise data-number="19.2.6"}

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

### Exercise 19.2.7 {.unnumbered .exercise data-number="19.2.7"}

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
  give_chances(
    from = Good_Fairy,
    to = foo_foo,
    number = chances,
    condition = "Don't behave",
    consequence = turn_into_goon
  )
}

lyric <- function() {
  foo_foo %>%
    hop(through = forest) %>%
    scoop(up = field_mouse) %>%
    bop(on = head)

  down_came(Good_Fairy)
  said(
    Good_Fairy,
    c(
      "Little bunny Foo Foo",
      "I don't want to see you",
      "Scooping up the field mice",
      "And bopping them on the head."
    )
  )
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

## Functions are for humans and computers {#functions-are-for-humans-and-computers .r4ds-section}

### Exercise 19.3.1 {.unnumbered .exercise data-number="19.3.1"}

<div class="question">
Read the source code for each of the following three functions, puzzle out what they do, and then brainstorm better names.


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

</div>

<div class="answer">

The function `f1` tests whether each element of the character vector `nchar`
starts with the string `prefix`. For example,

```r
f1(c("abc", "abcde", "ad"), "ab")
#> [1]  TRUE  TRUE FALSE
```
A better name for `f1` is `has_prefix()`

The function `f2` drops the last element of the vector `x`.

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
Good names would include `recycle()` (R's name for this behavior) or `expand()`.

</div>

### Exercise 19.3.2 {.unnumbered .exercise data-number="19.3.2"}

<div class="question">
Take a function that you’ve written recently and spend 5 minutes brainstorming a better name for it and its arguments.
</div>

<div class="answer">

Answer left to the reader.

</div>

### Exercise 19.3.3 {.unnumbered .exercise data-number="19.3.3"}

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

### Exercise 19.3.4 {.unnumbered .exercise data-number="19.3.4"}

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

## Conditional execution {#conditional-execution .r4ds-section}

### Exercise 19.4.1 {.unnumbered .exercise data-number="19.4.1"}

<div class="question">
What’s the difference between `if` and `ifelse()`? > Carefully read the help and construct three examples that illustrate the key differences.
</div>

<div class="answer">

The keyword `if` tests a single condition, while `ifelse()` tests each element.

</div>

### Exercise 19.4.2 {.unnumbered .exercise data-number="19.4.2"}

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
#> [1] "good morning"
greet(ymd_h("2017-01-08:05"))
#> [1] "good morning"
greet(ymd_h("2017-01-08:13"))
#> [1] "good afternoon"
greet(ymd_h("2017-01-08:20"))
#> [1] "good evening"
```

</div>

### Exercise 19.4.3 {.unnumbered .exercise data-number="19.4.3"}

<div class="question">

Implement a `fizzbuzz()` function. It takes a single number as input. If the
number is divisible by three, it returns “fizz”. If it’s divisible by five it
returns “buzz”. If it’s divisible by three and five, it returns “fizzbuzz”.
Otherwise, it returns the number. Make sure you first write working code before
you create the function.

</div>

<div class="answer">

We can use modulo operator, `%%`, to check divisibility.
The expression `x %% y` returns 0 if `y` divides `x`.

```r
1:10 %% 3 == 0
#>  [1] FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE
```
A more concise way of checking for divisibility is to note that the not operator will return `TRUE` for 0, and `FALSE` for all non-zero numbers.
Thus, `!(x %% y)`, will check whether `y` divides `x`.

```r
!(1:10 %% 3)
#>  [1] FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE FALSE  TRUE FALSE
```

There are four cases to consider:

1.  If `x` is divisible by 3 and 5, then return "fizzbuzz".
1.  If `x` is divisible by 3 and not 5, then return "fizz".
1.  If `x` is divisible by 5 and not 3, then return "buzz".
1.  Otherwise, which is the case in which `x` is not divisible by either 3 or 5, return `x`.

The key to answering this question correctly, is to first check whether `x`
is divisible by both 3 and 5. 
If the function checks whether `x` is divisible by 3 or 5 before considering the case that the number is divisible by both, then the function will never return `"fizzbuzz"`.


```r
fizzbuzz <- function(x) {
  # these two lines check that x is a valid input
  stopifnot(length(x) == 1)
  stopifnot(is.numeric(x))
  if (!(x %% 3) && !(x %% 5)) {
    "fizzbuzz"
  } else if (!(x %% 3)) {
    "fizz"
  } else if (!(x %% 5)) {
    "buzz"
  } else {
    # ensure that the function returns a character vector
    as.character(x)
  }
}
fizzbuzz(6)
#> [1] "fizz"
fizzbuzz(10)
#> [1] "buzz"
fizzbuzz(15)
#> [1] "fizzbuzz"
fizzbuzz(2)
#> [1] "2"
```

This function can be slightly improved by combining the first two lines conditions so
we only check whether `x` is divisible by 3 once.

```r
fizzbuzz2 <- function(x) {
  # these two lines check that x is a valid input
  stopifnot(length(x) == 1)
  stopifnot(is.numeric(x))
  if (!(x %% 3)) {
    if (!(x %% 5)) {
      "fizzbuzz"
    } else {
      "fizz"
    }
  } else if (!(x %% 5)) {
    "buzz"
  } else {
    # ensure that the function returns a character vector
    as.character(x)
  }
}
fizzbuzz2(6)
#> [1] "fizz"
fizzbuzz2(10)
#> [1] "buzz"
fizzbuzz2(15)
#> [1] "fizzbuzz"
fizzbuzz2(2)
#> [1] "2"
```

Instead of only accepting one number as an input, we could a FizzBuzz function that works on a vector. 
The `case_when()` function vectorizes multiple if-else conditions, so is perfect for this task.
In fact, fizz-buzz is used in the examples in the documentation of `case_when()`.

```r
fizzbuzz_vec <- function(x) {
  case_when(!(x %% 3) & !(x %% 5) ~ "fizzbuzz",
            !(x %% 3) ~ "fizz",
            !(x %% 5) ~ "buzz",
            TRUE ~ as.character(x)
            )
}
fizzbuzz_vec(c(0, 1, 2, 3, 5, 9, 10, 12, 15))
#> [1] "fizzbuzz" "1"        "2"        "fizz"     "buzz"     "fizz"     "buzz"    
#> [8] "fizz"     "fizzbuzz"
```

The following function is an example of a vectorized FizzBuzz function that
only uses bracket assignment.

```r
fizzbuzz_vec2 <- function(x) {
  y <- as.character(x)
  # put the individual cases first - any elements divisible by both 3 and 5
  # will be overwritten with fizzbuzz later
  y[!(x %% 3)] <- "fizz"
  y[!(x %% 3)] <- "buzz"
  y[!(x %% 3) & !(x %% 5)] <- "fizzbuzz"
  y
}
fizzbuzz_vec2(c(0, 1, 2, 3, 5, 9, 10, 12, 15))
#> [1] "fizzbuzz" "1"        "2"        "buzz"     "5"        "buzz"     "10"      
#> [8] "buzz"     "fizzbuzz"
```

This question, called the ["Fizz Buzz"](https://en.wikipedia.org/wiki/Fizz_buzz) question, is a common programming interview question used for screening out programmers who can't program.[^fizzbuzz]

</div>

### Exercise 19.4.4 {.unnumbered .exercise data-number="19.4.4"}

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
cut(temp, c(-Inf, 0, 10, 20, 30, Inf),
  right = TRUE,
  labels = c("freezing", "cold", "cool", "warm", "hot")
)
#>  [1] freezing freezing freezing cold     cold     cool     cool     warm    
#>  [9] warm     hot      hot      hot      hot     
#> Levels: freezing cold cool warm hot
```

To have intervals open on the left (using `<`), I change the argument to `right = FALSE`,

```r
temp <- seq(-10, 50, by = 5)
cut(temp, c(-Inf, 0, 10, 20, 30, Inf),
  right = FALSE,
  labels = c("freezing", "cold", "cool", "warm", "hot")
)
#>  [1] freezing freezing cold     cold     cool     cool     warm     warm    
#>  [9] hot      hot      hot      hot      hot     
#> Levels: freezing cold cool warm hot
```

Two advantages of using `cut` is that it works on vectors, whereas `if` only works on a single value (I already demonstrated this above),
and that to change comparisons I only needed to change the argument to `right`, but I would have had to change four operators in the `if` expression.

</div>

### Exercise 19.4.5 {.unnumbered .exercise data-number="19.4.5"}

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

### Exercise 19.4.6 {.unnumbered .exercise data-number="19.4.6"}

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
  NULL # value to return if x not matched
)
```

</div>

## Function arguments {#function-arguments .r4ds-section}

### Exercise 19.5.1 {.unnumbered .exercise data-number="19.5.1"}

<div class="question">
What does `commas(letters, collapse = "-")` do? Why?
</div>

<div class="answer">

The `commas()` function in the chapter is defined as

```r
commas <- function(...) {
  str_c(..., collapse = ", ")
}
```

When `commas()` is given a collapse argument, it throws an error.

```r
commas(letters, collapse = "-")
#> Error in str_c(..., collapse = ", "): formal argument "collapse" matched by multiple actual arguments
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
  str_c(..., collapse = collapse)
}
```

</div>

### Exercise 19.5.2 {.unnumbered .exercise data-number="19.5.2"}

<div class="question">

It’d be nice if you could supply multiple characters to the `pad` argument, e.g. `rule("Title", pad = "-+")`.
Why doesn’t this currently work? How could you fix it?

</div>

<div class="answer">

This is the definition of the rule function from the [chapter](https://r4ds.had.co.nz/functions.html).

```r
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", str_dup(pad, width), "\n", sep = "")
}
```

```r
rule("Important output")
#> Important output -----------------------------------------------------------
```

You can currently supply multiple characters to the `pad` argument, but the output will not be the desired width. 
The `rule()` function duplicates `pad` a number of times
equal to the desired width minus the length of the title and five extra characters.
This implicitly assumes that `pad` is only one character. If `pad` were two character,
the output will be almost twice as long.

```r
rule("Valuable output", pad = "-+")
#> Valuable output -+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

One way to handle this is to use `str_trunc()` to truncate the string,
and `str_length()` to calculate the number of characters in the `pad` argument.

```r
rule <- function(..., pad = "-") {
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  padding <- str_dup(
    pad,
    ceiling(width / str_length(title))
  ) %>%
    str_trunc(width)
  cat(title, " ", padding, "\n", sep = "")
}
rule("Important output")
#> Important output ----
rule("Valuable output", pad = "-+")
#> Valuable output -+-+-+-+
rule("Vital output", pad = "-+-")
#> Vital output -+--+--+--+--+--+-
```

Note that in the second output, there is only a single `-` at the end.

</div>

### Exercise 19.5.3 {.unnumbered .exercise data-number="19.5.3"}

<div class="question">
What does the `trim` argument to `mean()` do? When might you use it?
</div>

<div class="answer">

The `trim` arguments trims a fraction of observations from each end of the vector (meaning the range) before calculating the mean.
This is useful for calculating a measure of central tendency that is robust to outliers.

</div>

### Exercise 19.5.4 {.unnumbered .exercise data-number="19.5.4"}

<div class="question">
The default value for the `method` argument to `cor()` is `c("pearson", "kendall", "spearman")`.
What does that mean? What value is used by default?
</div>

<div class="answer">

It means that the `method` argument can take one of those three values.
The first value, `"pearson"`, is used by default.

</div>

## Return values {#return-values .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

## Environment {#environment .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

[fizzbuzz]: Read [Why I’m still using “Fizz Buzz” to hire Software-Developers](https://hackernoon.com/why-im-still-using-fizz-buzz-to-hire-software-developers-7e31a89a4bbf) for more discussion on the use of the Fizz-Buzz question in programming interviews.
