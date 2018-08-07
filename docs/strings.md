
# Strings

## Introduction


```r
library(tidyverse)
library(stringr)
```

## String Basics

### Exercise <span class="exercise-number">14.2.1</span> {.unnumbered .exercise}

<div class="question">
In code that doesn’t **stringr**, you’ll often see `paste()` and `paste0()`. What’s the difference between the two functions? What **stringr** function are they equivalent to? How do the functions differ in their handling of NA?
</div>

<div class="answer">

The function `paste()` separates strings by spaces by default, while `paste0()` does not separate strings with spaces by default.


```r
paste("foo", "bar")
#> [1] "foo bar"
paste0("foo", "bar")
#> [1] "foobar"
```

Since `str_c()` does not separate strings with spaces by default it is closer in behavior to `paste0()`.


```r
str_c("foo", "bar")
#> [1] "foobar"
```

However, `str_c()` and the paste function handle NA differently.
The function `str_c()` propagates `NA`, if any argument is a missing value, it returns a missing value.
This is in line with how the numeric R functions, e.g. `sum()`, `mean()`, handle missing values.
However, the paste functions, convert `NA` to the string `"NA"` and then treat it as any other character vector.

```r
str_c("foo", NA)
#> [1] NA
paste("foo", NA)
#> [1] "foo NA"
paste0("foo", NA)
#> [1] "fooNA"
```

</div>

### Exercise <span class="exercise-number">14.2.2</span> {.unnumbered .exercise}

<div class="question">
In your own words, describe the difference between the `sep` and `collapse` arguments to `str_c()`.
</div>

<div class="answer">

The `sep` argument is the string inserted between arguments to `str_c()`, while `collapse` is the string used to separate any elements of the character vector into a character vector of length one.

</div>

### Exercise <span class="exercise-number">14.2.3</span> {.unnumbered .exercise}

<div class="question">
Use `str_length()` and `str_sub()` to extract the middle character from a string. What will you do if the string has an even number of characters?
</div>

<div class="answer">

The following function extracts the middle character. If the string has an even number of characters the choice is arbitrary.
We choose to select $\lceil n / 2 \rceil$, because that case works even if the string is only of length one.
A more general method would allow the user to select either the floor or ceiling for the middle character of an even string.

```r
x <- c("a", "abc", "abcd", "abcde", "abcdef")
L <- str_length(x)
m <- ceiling(L / 2)
str_sub(x, m, m)
#> [1] "a" "b" "b" "c" "c"
```

</div>

### Exercise <span class="exercise-number">14.2.4</span> {.unnumbered .exercise}

<div class="question">
What does `str_wrap()` do? When might you want to use it?
</div>

<div class="answer">

The function `str_wrap()` wraps text so that it fits within a certain width.
This is useful for wrapping long strings of text to be typeset.

</div>

### Exercise <span class="exercise-number">14.2.5</span> {.unnumbered .exercise}

<div class="question">
What does `str_trim()` do? What’s the opposite of `str_trim()`?
</div>

<div class="answer">

The function `str_trim()` trims the whitespace from a string.

```r
str_trim(" abc ")
#> [1] "abc"
str_trim(" abc ", side = "left")
#> [1] "abc "
str_trim(" abc ", side = "right")
#> [1] " abc"
```

The opposite of `str_trim()` is `str_pad()` which adds characters to each side.


```r
str_pad("abc", 5, side = "both")
#> [1] " abc "
str_pad("abc", 4, side = "right")
#> [1] "abc "
str_pad("abc", 4, side = "left")
#> [1] " abc"
```

</div>

### Exercise <span class="exercise-number">14.2.6</span> {.unnumbered .exercise}

<div class="question">
Write a function that turns (e.g.) a vector `c("a", "b", "c")` into the string `"a, b, and c"`. Think carefully about what it should do if given a vector of length 0, 1, or 2.
</div>

<div class="answer">

See the Chapter [Functions] for more details on writing R functions.

This function needs to handle four cases.

1.  `n == 0`: an empty string, e.g. `""`.
1.  `n == 1`: the original vector, e.g. `"a"`.
1.  `n == 2`: return the two elements separated by "and", e.g. `"a and b"`.
1.  `n > 2`: return the first `n - 1` elements separated by commas, and the last element separated by a comma and "and", e.g. `"a, b, and c"`.


```r
str_commasep <- function(x, delim = ",") {
  n <- length(x)
  if (n == 0) {
    ""
  } else if (n == 1) {
    x
  } else if (n == 2) {
    # no comma before and when n == 2
    str_c(x[[1]], "and", x[[2]], sep = " ")
  } else {
    # commas after all n - 1 elements
    not_last <- str_c(x[seq_len(n - 1)], delim)
    # prepend "and" to the last element
    last <- str_c("and", x[[n]], sep = " ")
    # combine parts with spaces
    str_c(c(not_last, last), collapse = " ")
  }
}
str_commasep("")
#> [1] ""
str_commasep("a")
#> [1] "a"
str_commasep(c("a", "b"))
#> [1] "a and b"
str_commasep(c("a", "b", "c"))
#> [1] "a, b, and c"
str_commasep(c("a", "b", "c", "d"))
#> [1] "a, b, c, and d"
```

</div>

## Matching Patterns and Regular Expressions

### Basic Matches

#### Exercise <span class="exercise-number">14.3.1.1</span> {.unnumbered .exercise}

<div class="question">
Explain why each of these strings don’t match a `\`: `"\"`, `"\\"`, `"\\\"`.
</div>

<div class="answer">

-   `"\"`: This will escape the next character in the R string.
-   `"\\"`: This will resolve to `\` in the regular expression, which will escape the next character in the regular expression.
-   `"\\\"`: The first two backslashes will resolve to a literal backslash in the regular expression, the third will escape the next character. So in the regular expression, this will escape some escaped character.

</div>

#### Exercise <span class="exercise-number">14.3.1.2</span> {.unnumbered .exercise}

<div class="question">
How would you match the sequence `"'\` ?
</div>

<div class="answer">


```r
str_view("\"'\\", "\"'\\\\")
```

</div>

#### Exercise <span class="exercise-number">14.3.1.3</span> {.unnumbered .exercise}

<div class="question">
What patterns will the regular expression `\..\..\..` match? How would you represent it as a string?
</div>

<div class="answer">

It will match any patterns that are a dot followed by any character, repeated three times.


```r
str_view(c(".a.b.c", ".a.b", "....."), c("\\..\\..\\.."))
```

</div>

### Anchors

#### Exercise <span class="exercise-number">14.3.2.1</span> {.unnumbered .exercise}

<div class="question">
How would you match the literal string `"$^$"`?
</div>

<div class="answer">


```r
str_view(c("$^$", "ab$^$sfas"), "^\\$\\^\\$$")
```

</div>

#### Exercise <span class="exercise-number">14.3.2.2</span> {.unnumbered .exercise}

<div class="question">
Given the corpus of common words in `stringr::words`, create regular expressions that find all words that:

1.  Start with “y”.
1.  End with “x”
1.  Are exactly three letters long. (Don’t cheat by using `str_length()`!)
1.  Have seven letters or more.

Since this list is long, you might want to use the match argument to `str_view()` to show only the matching or non-matching words.

</div>

<div class="answer">

The answer to each part follows.

1.  The words that start with  “y” are:

    
    ```r
    str_view(stringr::words, "^y", match =TRUE)
    ```

1.  End with “x”

    
    ```r
    str_view(stringr::words, "x$", match = TRUE)
    ```

1.  Are exactly three letters long are

    
    ```r
    str_view(stringr::words, "^...$", match = TRUE)
    ```

1.  The words that have seven letters or more are

    
    ```r
    str_view(stringr::words, ".......", match = TRUE)
    ```

</div>

### Character classes and alternatives

#### Exercise <span class="exercise-number">14.3.3.1</span> {.unnumbered .exercise}

<div class="question">

Create regular expressions to find all words that:

1.  Start with a vowel.
1.  That only contain consonants. (Hint: thinking about matching “not”-vowels.)
1.  End with `ed`, but not with `eed`.
1.  End with `ing` or `ise`.

</div>

<div class="answer">

The answer to each part follows.

1.  Words starting with vowels

    
    ```r
    str_view(stringr::words, "^[aeiou]", match = TRUE)
    ```

1.  Words that contain only consonants

    
    ```r
    str_view(stringr::words, "^[^aeiou]+$", match=TRUE)
    ```

    This seems to require using the `+` pattern introduced later, unless one wants to be very verbose and specify words of certain lengths.

1.  Words that end with "-ed" but not ending in "-eed". This handles the special case of "-ed", as well as words with a length great than two.

    
    ```r
    str_view(stringr::words, "^ed$|[^e]ed$", match = TRUE)
    ```

1.  Words ending in `ing` or `ise`:

    
    ```r
    str_view(stringr::words, "i(ng|se)$", match = TRUE)
    ```

</div>

#### Exercise <span class="exercise-number">14.3.3.2</span> {.unnumbered .exercise}

<div class="question">

Empirically verify the rule ``i before e except after c''.

</div>

<div class="answer">

Using only what has been introduced thus far:


```r
str_view(stringr::words, "(cei|[^c]ie)", match = TRUE)
```


```r
str_view(stringr::words, "(cie|[^c]ei)", match = TRUE)
```

Using `str_detect()` count the number of words that follow these rules:

```r
sum(str_detect(stringr::words, "(cei|[^c]ie)"))
sum(str_detect(stringr::words, "(cie|[^c]ei)"))
```

</div>

#### Exercise <span class="exercise-number">14.3.3.3</span> {.unnumbered .exercise}

<div class="question">
Is ``q'' always followed by a ``u''?
</div>

<div class="answer">

In the `stringr::words` dataset, yes. In the full English language, no.

```r
str_view(stringr::words, "q[^u]", match = TRUE)
```

</div>

#### Exercise <span class="exercise-number">14.3.3.4</span> {.unnumbered .exercise}

<div class="question">
Write a regular expression that matches a word if it’s probably written in British English, not American English.
</div>

<div class="answer">

In the general case, this is hard, and could require a dictionary.
But, there are a few heuristics to consider that would account for some common cases: British English tends to use the following:

-   "ou" instead of "o"
-   use of "ae" and "oe" instead of "a" and "o"
-   ends in `ise` instead of `ize`
-   ends in `yse`

The regex `ou|ise$|ae|oe|yse$` would match these.

There are other [spelling differences between American and British English] (https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences) but they are not patterns amenable to regular expressions.
It would require a dictionary with differences in spellings for different words.

</div>

#### Exercise <span class="exercise-number">14.3.3.5</span> {.unnumbered .exercise}

<div class="question">
Create a regular expression that will match telephone numbers as commonly written in your country.
</div>

<div class="answer">

The answer to this will vary by country.

For the United States, phone numbers have a format like `123-456-7890`.

```r
x <- c("123-456-7890", "1235-2351")
str_view(x, "\\d\\d\\d-\\d\\d\\d-\\d\\d\\d\\d")
```
or

```r
str_view(x, "[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]")
```

This regular expression can be simplified with the `{m,n}` regular expression modifier introduced in the next section,

```r
str_view(x, "\\d{3}-\\d{3}-\\d{4}")
```

Note that this pattern doesn't account for phone numbers that are invalid
because of unassigned area code, or special numbers like 911, or extensions.
See the Wikipedia page for the [North American Numbering
Plan](https://en.wikipedia.org/wiki/North_American_Numbering_Plan) for more
information on the complexities of US phone numbers, and [this Stack Overflow
question](http://stackoverflow.com/questions/123559/a-comprehensive-regex-for-phone-number-validation)
for a discussion of using a regex for phone number validation.

</div>

### Repetition

#### Exercise <span class="exercise-number">14.3.4.1</span> {.unnumbered .exercise}

<div class="question">
Describe the equivalents of `?`, `+`, `*` in `{m,n}` form.
</div>

<div class="answer">

| Pattern | `{m,n}` | Meaning           |
|---------|---------|-------------------|
| `?`     | `{0,1}` | Match at most 1   |
| `+`     | `{1,}`  | Match 1 or more   |
| `*`     | `{0,}`  | Match 0 or more   |

For example, let's repeat the let's rewrite the `?`, `+`, and `*` examples using `{,}`.

```r
x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
```

```r
str_view(x, "CC{0,1}")
```

```r
str_view(x, "CC+")
```

```r
str_view(x, "CC{1,}")
```

</div>

#### Exercise <span class="exercise-number">14.3.4.2</span> {.unnumbered .exercise}

<div class="question">
Describe in words what these regular expressions match: (read carefully to see if I’m using a regular expression or a string that defines a regular expression.)

1.  `^.*$`
1.  `"\\{.+\\}"`
1.  `\d{4}-\d{2}-\d{2}`
1.  `"\\\\{4}"`

</div>

<div class="answer">

The answer to each part follows.

1.  `^.*$` will match any string. For example: `^.*$`: `c("dog", "$1.23", "lorem ipsum")`.

1.  `"\\{.+\\}"` will match any string with curly braces surrounding at least one character.
    For example: `"\\{.+\\}"`: `c("{a}", "{abc}")`.

1.  `\d{4}-\d{2}-\d{2}` will match four digits followed by a hyphen, followed by
     two digits followed by a hyphen, followed by another two digits.
     This is a regular expression that can match dates formatted like "YYYY-MM-DD" ("%Y-%m-%d").
     For example: `\d{4}-\d{2}-\d{2}`: `2018-01-11`

1.  `"\\\\{4}"` is `\\{4}`, which will match four backslashes.
    For example: `"\\\\{4}"`: `"\\\\\\\\"`.

</div>

#### Exercise <span class="exercise-number">14.3.4.3</span> {.unnumbered .exercise}

<div class="question">
Create regular expressions to find all words that:

1.  Start with three consonants.
1.  Have three or more vowels in a row.
1.  Have two or more vowel-consonant pairs in a row.

</div>

<div class="answer">

The answer to each part follows.

1.  This regex finds all words starting with three consonants.

    
    ```r
    str_view(words, "^[^aeiou]{3}")
    ```

1.  This regex finds three or more vowels in a row:

    
    ```r
    str_view(words, "[aeiou]{3,}")
    ```

1.  This regex finds two or more vowel-consonant pairs in a row.

    
    ```r
    str_view(words, "([aeiou][^aeiou]){2,}")
    ```

</div>

#### Exercise <span class="exercise-number">14.3.4.4</span> {.unnumbered .exercise}

<div class="question">

Solve the beginner regexp crosswords at <https://regexcrossword.com/challenges/>

</div>

<div class="answer">

Exercise left to reader. That site validates its solutions, so they aren't repeated here.

</div>

### Grouping and backreferences

#### Exercise <span class="exercise-number">14.3.5.1</span> {.unnumbered .exercise}

<div class="question">
Describe, in words, what these expressions will match:

1.  `(.)\1\1` :
1.  `"(.)(.)\\2\\1"`:
1.  `(..)\1`: Any two characters repeated. E.g. `"a1a1"`.
1.  `"(.).\\1.\\1"`:
1.  `"(.)(.)(.).*\\3\\2\\1"`

</div>

<div class="answer">

The answer to each part follows.

1.  `(.)\1\1`: The same character appearing three times in a row. E.g. `"aaa"`
1.  `"(.)(.)\\2\\1"`: A pair of characters followed by the same pair of characters in reversed order. E.g. `"abba"`.
1.  `(..)\1`: Any two characters repeated. E.g. `"a1a1"`.
1.  `"(.).\\1.\\1"`: A character followed by any character, the original character, any other character, the original character again. E.g. `"abaca"`, `"b8b.b"`.
1.  `"(.)(.)(.).*\\3\\2\\1"` Three characters followed by zero or more characters of any kind followed by the same three characters but in reverse order. E.g. `"abcsgasgddsadgsdgcba"` or `"abccba"` or `"abc1cba"`.

</div>

#### Exercise <span class="exercise-number">14.3.5.2</span> {.unnumbered .exercise}

<div class="question">
Construct regular expressions to match words that:

1.  Start and end with the same character.
1.  Contain a repeated pair of letters (e.g. ``church'' contains ``ch'' repeated twice.)
1.  Contain one letter repeated in at least three places (e.g. ``eleven'' contains three ``e''s.)

</div>

<div class="answer">

The answer to each part follows.

1.  This regular expression matches words that and end with the same character.

    
    ```r
    str_view(stringr::words, "^(.)((.*\\1$)|\\1?$)", match = TRUE)
    ```

1.  This regex matches words that contain a repeated pair of letters.

    
    ```r
    str_view(words, "(..).*\\1")
    ```

    These patterns checks for any pair of repeated "letters".

    
    ```r
    str_view(words, "([A-Za-z][A-Za-z]).*\\1")
    ```

    
    ```r
    str_view(words, "([[:letter:]]).*\\1")
    ```

    Note that these patterns are case sensitive. Use the
    case insensitive flag if you want to check for repeated pairs
    of letters with different capitalization.

    The `\\1` is used to refer back to the first group (`(.)`) so that whatever letter is matched by `[A-Za-z]` is again matched.

1.  This regex matches words that contain one letter repeated in at least three places.

    
    ```r
    str_subset(str_to_lower(words), "([a-z]).*\\1.*\\1")
    #>  [1] "appropriate" "available"   "believe"     "between"     "business"   
    #>  [6] "degree"      "difference"  "discuss"     "eleven"      "environment"
    #> [11] "evidence"    "exercise"    "expense"     "experience"  "individual" 
    #> [16] "paragraph"   "receive"     "remember"    "represent"   "telephone"  
    #> [21] "therefore"   "tomorrow"
    ```

</div>

## Tools

### Detect matches

No exercises

### Exercises

#### Exercise <span class="exercise-number">14.4.2.1</span> {.unnumbered .exercise}

<div class="question">
For each of the following challenges, try solving it by using both a single regular expression, and a combination of multiple `str_detect()` calls.

1.  Find all words that start or end with x.
1.  Find all words that start with a vowel and end with a consonant.
1.  Are there any words that contain at least one of each different vowel?
1.  What word has the higher number of vowels? What word has the highest proportion of vowels? (Hint: what is the denominator?)

</div>

<div class="answer">

The answer to each part follows.

1.  Words that start or end with `x`?

    
    ```r
    # one regex
    words[str_detect(words, "^x|x$")]
    #> [1] "box" "sex" "six" "tax"
    # split regex into parts
    start_with_x <- str_detect(words, "^x")
    end_with_x <- str_detect(words, "x$")
    words[start_with_x | end_with_x]
    #> [1] "box" "sex" "six" "tax"
    ```

1.  Words starting with vowel and ending with consonant.

    
    ```r
    str_subset(words, "^[aeiou].*[^aeiou]$") %>% head()
    #> [1] "about"   "accept"  "account" "across"  "act"     "actual"
    start_with_vowel <- str_detect(words, "^[aeiou]")
    end_with_consonant <- str_detect(words, "[^aeiou]$")
    words[start_with_vowel & end_with_consonant] %>% head()
    #> [1] "about"   "accept"  "account" "across"  "act"     "actual"
    ```

1.  There is not a simple regular expression to match words that
    that contain at least one of each vowel. The regular expression
    would need to consider all possible orders in which the vowels
    could occur.

    
    ```r
    pattern <-
      cross_n(rerun(5, c("a", "e", "i", "o", "u")),
            .filter = function(...) {
              x <- as.character(unlist(list(...)))
              length(x) != length(unique(x))
            }) %>%
      map_chr(~ str_c(unlist(.x), collapse = ".*")) %>%
      str_c(collapse = "|")
    #> Warning: `cross_n()` is deprecated; please use `cross()` instead.
    ```

    To check that this pattern works, test it on a pattern that
    should match
    
    ```r
    str_subset("aseiouds", pattern)
    #> [1] "aseiouds"
    ```

    Using multiple `str_detect()` calls, one pattern for each vowel,
    produces a much simpler and readable answer.

    
    ```r
    str_subset(words, pattern)
    #> character(0)
    
    words[str_detect(words, "a") &
          str_detect(words, "e") &
          str_detect(words, "i") &
          str_detect(words, "o") &
          str_detect(words, "u")]
    #> character(0)
    ```

    There appear to be none.

1.  The word with the highest number of vowels is
    
    ```r
    vowels <- str_count(words, "[aeiou]")
    words[which(vowels == max(vowels))]
    #> [1] "appropriate" "associate"   "available"   "colleague"   "encourage"  
    #> [6] "experience"  "individual"  "television"
    ```

    The word with the highest proportion of vowels is
    
    ```r
    prop_vowels <- str_count(words, "[aeiou]") / str_length(words)
    words[which(prop_vowels == max(prop_vowels))]
    #> [1] "a"
    ```

</div>

### Extract Matches

#### Exercise <span class="exercise-number">14.4.3.1</span> {.unnumbered .exercise}

<div class="question">
In the previous example, you might have noticed that the regular expression matched “flickered”, which is not a color. Modify the regex to fix the problem.
</div>

<div class="answer">

This was the original color match pattern:

```r
colours <- c("red", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|")
```
It matches "flickered" because it matches "red".
The problem is that the previous pattern will match any word with the name of a color inside it. We want to only match colors in which the entire word is the name of the color.
We can do this by adding a `\b` (to indicate a word boundary) before and after the pattern:

```r
colour_match2 <- str_c("\\b(", str_c(colours, collapse = "|"), ")\\b")
colour_match2
#> [1] "\\b(red|orange|yellow|green|blue|purple)\\b"
```


```r
more2 <- sentences[str_count(sentences, colour_match) > 1]
```

```r
str_view_all(more2, colour_match2, match = TRUE)
```

</div>

#### Exercise <span class="exercise-number">14.4.3.2</span> {.unnumbered .exercise}

<div class="question">

From the Harvard sentences data, extract:

1.  The first word from each sentence.
1.  All words ending in `ing`.
1.  All plurals.

</div>

<div class="answer">

The answer to each part follows.

1.  Finding the first word in each sentence requires defining what a pattern constitutes a word. For the purposes of this question,
    I'll consider a word any contiguous set of letters.

    
    ```r
    str_extract(sentences, "[a-zA-Z]+") %>% head()
    #> [1] "The"   "Glue"  "It"    "These" "Rice"  "The"
    ```

1.  This pattern finds all words ending in `ing`.

    
    ```r
    pattern <- "\\b[A-Za-z]+ing\\b"
    sentences_with_ing <- str_detect(sentences, pattern)
    unique(unlist(str_extract_all(sentences[sentences_with_ing], pattern))) %>%
      head()
    #> [1] "spring"  "evening" "morning" "winding" "living"  "king"
    ```

1.  Finding all plurals cannot be correctly accomplished with regular expressions alone.
    Finding plural words would at least require morphological information about words in the language.
    See [WordNet](https://cran.r-project.org/web/packages/wordnet/index.html) for a resource that would do that.
    However, identifying words that end in an "s" and with more than three characters, in order to remove "as", "is", "gas", etc., is
    a reasonable heuristic.

    
    ```r
    unique(unlist(str_extract_all(sentences, "\\b[A-Za-z]{3,}s\\b"))) %>%
      head()
    #> [1] "planks" "days"   "bowls"  "lemons" "makes"  "hogs"
    ```

</div>

### Grouped Matches

#### Exercise <span class="exercise-number">14.4.4.1</span> {.unnumbered .exercise}

<div class="question">
Find all words that come after a “number” like “one”, “two”, “three” etc. Pull out both the number and the word.
</div>

<div class="answer">

I'll use the same following "word" pattern as used above

```r
numword <- "(one|two|three|four|five|six|seven|eight|nine|ten) +(\\S+)"
sentences[str_detect(sentences, numword)] %>%
  str_extract(numword)
#>  [1] "ten served"    "one over"      "seven books"   "two met"      
#>  [5] "two factors"   "one and"       "three lists"   "seven is"     
#>  [9] "two when"      "one floor."    "ten inches."   "one with"     
#> [13] "one war"       "one button"    "six minutes."  "ten years"    
#> [17] "one in"        "ten chased"    "one like"      "two shares"   
#> [21] "two distinct"  "one costs"     "ten two"       "five robins." 
#> [25] "four kinds"    "one rang"      "ten him."      "three story"  
#> [29] "ten by"        "one wall."     "three inches"  "ten your"     
#> [33] "six comes"     "one before"    "three batches" "two leaves."
```

</div>

#### Exercise <span class="exercise-number">14.4.4.2</span> {.unnumbered .exercise}

<div class="question">
Find all contractions. Separate out the pieces before and after the apostrophe.
</div>

<div class="answer">


```r
contraction <- "([A-Za-z]+)'([A-Za-z]+)"
sentences %>%
  `[`(str_detect(sentences, contraction)) %>%
  str_extract(contraction)
#>  [1] "It's"       "man's"      "don't"      "store's"    "workmen's" 
#>  [6] "Let's"      "sun's"      "child's"    "king's"     "It's"      
#> [11] "don't"      "queen's"    "don't"      "pirate's"   "neighbor's"
```

</div>

### Replacing Matches

#### Exercise <span class="exercise-number">14.4.5.1</span> {.unnumbered .exercise}

<div class="question">
Replace all forward slashes in a string with backslashes.
</div>

<div class="answer">


```r
backslashed <- str_replace_all("past/present/future", "\\/", "\\\\")
writeLines(backslashed)
#> past\present\future
```

</div>

#### Exercise <span class="exercise-number">14.4.5.2</span> {.unnumbered .exercise}

<div class="question">
Implement a simple version of `str_to_lower()` using `replace_all()`.
</div>

<div class="answer">

```r
lower <- str_replace_all(words, c("A"="a", "B"="b", "C"="c", "D"="d", "E"="e", "F"="f", "G"="g", "H"="h", "I"="i", "J"="j", "K"="k", "L"="l", "M"="m", "N"="n", "O"="o", "P"="p", "Q"="q", "R"="r", "S"="s", "T"="t", "U"="u", "V"="v", "W"="w", "X"="x", "Y"="y", "Z"="z"))
```

</div>

#### Exercise <span class="exercise-number">14.4.5.3</span> {.unnumbered .exercise}

<div class="question">
Switch the first and last letters in `words`. Which of those strings are still words?
</div>

<div class="answer">

First, make a vector of all the words with first and last letters swapped,

```r
swapped <- str_replace_all(words, "^([A-Za-z])(.*)([a-z])$", "\\3\\2\\1")
```
Next, find what of "swapped" is also in the original list using the function `intersect()`,

```r
intersect(swapped,words)
#>  [1] "a"          "america"    "area"       "dad"        "dead"      
#>  [6] "lead"       "read"       "depend"     "god"        "educate"   
#> [11] "else"       "encourage"  "engine"     "europe"     "evidence"  
#> [16] "example"    "excuse"     "exercise"   "expense"    "experience"
#> [21] "eye"        "dog"        "health"     "high"       "knock"     
#> [26] "deal"       "level"      "local"      "nation"     "on"        
#> [31] "non"        "no"         "rather"     "dear"       "refer"     
#> [36] "remember"   "serious"    "stairs"     "test"       "tonight"   
#> [41] "transport"  "treat"      "trust"      "window"     "yesterday"
```

</div>

### Splitting

#### Exercise <span class="exercise-number">14.4.6.1</span> {.unnumbered .exercise}

<div class="question">
Split up a string like `"apples, pears, and bananas"` into individual components.
</div>

<div class="answer">


```r
x <- c("apples, pears, and bananas")
str_split(x, ", +(and +)?")[[1]]
#> [1] "apples"  "pears"   "bananas"
```

</div>

#### Exercise <span class="exercise-number">14.4.6.2</span> {.unnumbered .exercise}

<div class="question">
Why is it better to split up by `boundary("word")` than `" "`?
</div>

<div class="answer">

Splitting by `boundary("word")` is a more sophisticated method to split a string into words.
It recognizes non-space punctuation that splits words, and also removes punctuation while retaining internal non-letter characters that are parts of the word, e.g., "can't"
See the [ICU website](http://userguide.icu-project.org/boundaryanalysis) for a description of the set of rules that are used to determine word boundaries.

Consider this sentence from the official [Unicode Report on word boundaries](http://www.unicode.org/reports/tr29/#Word_Boundaries),

```r
sentence <- "The quick (“brown”) fox can’t jump 32.3 feet, right?"
```
Splitting the string on spaces considers will group the punctuation with the words,

```r
str_split(sentence, " ")
#> [[1]]
#> [1] "The"       "quick"     "(“brown”)" "fox"       "can’t"     "jump"     
#> [7] "32.3"      "feet,"     "right?"
```
However, splitting the string using `boundary("word")` correctly removes punctuation, while not
separating "32.2" and "can't",

```r
str_split(sentence, boundary("word"))
#> [[1]]
#> [1] "The"   "quick" "brown" "fox"   "can’t" "jump"  "32.3"  "feet"  "right"
```

</div>

#### Exercise <span class="exercise-number">14.4.6.3</span> {.unnumbered .exercise}

<div class="question">
What does splitting with an empty string `("")` do? Experiment, and then read the documentation.
</div>

<div class="answer">


```r
str_split("ab. cd|agt", "")[[1]]
#>  [1] "a" "b" "." " " "c" "d" "|" "a" "g" "t"
```

It splits the string into individual characters.

</div>

### Find matches

No exercises

## Other types of patterns

### Exercise <span class="exercise-number">14.5.1</span> {.unnumbered .exercise}

<div class="question">
How would you find all strings containing `\` with `regex()` vs. with `fixed()`?
</div>

<div class="answer">


```r
str_subset(c("a\\b", "ab"), "\\\\")
#> [1] "a\\b"
str_subset(c("a\\b", "ab"), fixed("\\"))
#> [1] "a\\b"
```

</div>

### Exercise <span class="exercise-number">14.5.2</span> {.unnumbered .exercise}

<div class="question">
What are the five most common words in sentences?
</div>

<div class="answer">


```r
str_extract_all(sentences, boundary("word")) %>%
  unlist() %>%
  str_to_lower() %>%
  tibble() %>%
  set_names("word") %>%
  group_by(word) %>%
  count(sort = TRUE) %>%
  head(5)
#> # A tibble: 5 x 2
#> # Groups:   word [5]
#>   word      n
#>   <chr> <int>
#> 1 the     751
#> 2 a       202
#> 3 of      132
#> 4 to      123
#> 5 and     118
```

</div>

## Other uses of regular expressions

No exercises

## stringi

### Exercise <span class="exercise-number">14.7.1</span> {.unnumbered .exercise}

<div class="question">

Find the **stringi** functions that:

1.  Count the number of words.
1.  Find duplicated strings.
1.  Generate random text.

</div>

<div class="answer">

The answer to each part follows.

1.  To count the number of words use `stri_count_words()`.

1.  To find duplicated strings use `stri_duplicated()`.

1.  To generate random text the *stringi* package contains several functions beginning with `stri_rand_*`:

    -   `stri_rand_lipsum()` generates lorem ipsum text
    -   `stri_rand_strings()` generates random strings
    -   `stri_rand_shuffle()` randomly shuffles the code points (characters) in the text.

</div>

### Exercise <span class="exercise-number">14.7.2</span> {.unnumbered .exercise}

<div class="question">
How do you control the language that `stri_sort()` uses for sorting?
</div>

<div class="answer">

You can set a locale to use when sorting with either `stri_sort(..., opts_collator=stri_opts_collator(locale = ...))` or `stri_sort(..., locale = ...)`.

</div>
