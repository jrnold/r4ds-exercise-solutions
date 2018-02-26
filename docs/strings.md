
# Strings

## Introduction


```r
library(tidyverse)
library(stringr)
```

## String Basics


### Exercise 1 {.exercise}

> In code that doesn’t use **stringr**, you’ll often see `paste()` and `paste0()`. What’s the difference between the two functions? What **stringr** function are they equivalent to? How do the functions differ in their handling of NA?

The function `paste` separates strings by spaces by default, while `paste0` does not separate strings with spaces by default.


```r
paste("foo", "bar")
#> [1] "foo bar"
paste0("foo", "bar")
#> [1] "foobar"
```

Since `str_c` does not separate strings with spaces by default it is closer in behavior to `paste0`.


```r
str_c("foo", "bar")
#> [1] "foobar"
```

However, `str_c` and the paste function handle NA differently.
The function `str_c` propagates `NA`, if any argument is a missing value, it returns a missing value.
This is in line with how the numeric R functions, e.g. `sum`, `mean`, handle missing values.
However, the paste functions, convert `NA` to the string `"NA"` and then treat it as any other character vector.

```r
str_c("foo", NA)
#> [1] NA
paste("foo", NA)
#> [1] "foo NA"
paste0("foo", NA)
#> [1] "fooNA"
```

### Exercise 2 {.exercise}

> In your own words, describe the difference between the `sep` and `collapse` arguments to `str_c()`.

The `sep` argument is the string inserted between arguments to `str_c`, while `collapse` is the string used to separate any elements of the character vector into a character vector of length one.

### Exercise 3 {.exercise}

> Use `str_length()` and `str_sub()` to extract the middle character from a string. What will you do if the string has an even number of characters?

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

### Exercise 4 {.exercise}

> What does `str_wrap()` do? When might you want to use it?

The function `str_wrap` wraps text so that it fits within a certain width.
This is useful for wrapping long strings of text to be typeset.

### Exercise 5 {.exercise}

> What does `str_trim()` do? What’s the opposite of `str_trim()`?

The function `str_trim` trims the whitespace from a string.

```r
str_trim(" abc ")
#> [1] "abc"
str_trim(" abc ", side = "left")
#> [1] "abc "
str_trim(" abc ", side = "right")
#> [1] " abc"
```

The opposite of `str_trim` is `str_pad` which adds characters to each side.


```r
str_pad("abc", 5, side = "both")
#> [1] " abc "
str_pad("abc", 4, side = "right")
#> [1] "abc "
str_pad("abc", 4, side = "left")
#> [1] " abc"
```

### Exercise 6 {.exercise}

> Write a function that turns (e.g.) a vector c("a", "b", "c") into the string a, b, and c. Think carefully about what it should do if given a vector of length 0, 1, or 2.

See the Chapter [Functions] for more details on writing R functions.


```r
str_commasep <- function(x, sep = ", ", last = ", and ") {
  if (length(x) > 1) {
    str_c(str_c(x[-length(x)], collapse = sep),
                x[length(x)],
                sep = last)
  } else {
    x
  }
}
str_commasep("")
#> [1] ""
str_commasep("a")
#> [1] "a"
str_commasep(c("a", "b"))
#> [1] "a, and b"
str_commasep(c("a", "b", "c"))
#> [1] "a, b, and c"
```

## Matching Patterns and Regular Expressions

### Basic Matches

#### Exercise 1 {.exercise}

> Explain why each of these strings don’t match a `\`: `"\"`, `"\\"`, `"\\\"`.

- `"\"`: This will escape the next character in the R string.
- `"\\"`: This will resolve to `\` in the regular expression, which will escape the next character in the regular expression.
- `"\\\"`: The first two backslashes will resolve to a literal backslash in the regular expression, the third will escape the next character. So in the regular expression, this will escape some escaped character.

#### Exercise 2 {.exercise}

> How would you match the sequence `"'\` ?


```r
str_view("\"'\\", "\"'\\\\")
```

#### Exercise 3 {.exercise}

> What patterns will the regular expression `\..\..\..` match? How would you represent it as a string?

It will match any patterns that are a dot followed by any character, repeated three times.


```r
str_view(c(".a.b.c", ".a.b", "....."), c("\\..\\..\\.."))
```


```r
x < c("apple", "banana", "pear")
#> Warning in x < c("apple", "banana", "pear"): longer object length is not a
#> multiple of shorter object length
str_view(x, "^a")
```


```r
str_view(x, "a$")
```


```r
x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple")
```


```r
str_view(x, "^apple$")
```

### Anchors

#### Exercise 1 {.exercise}

> How would you match the literal string `"$^$"`?


```r
str_view(c("$^$", "ab$^$sfas"), "^\\$\\^\\$$")
```

#### Exercise 2 {.exercise}

> Given the corpus of common words in `stringr::words`, create regular expressions that find all words that:

>  1. Start with “y”.
>  2. End with “x”
>  3. Are exactly three letters long. (Don’t cheat by using `str_length()`!)
>  4. Have seven letters or more.
>  
> Since this list is long, you might want to use the match argument to `str_view()` to show only the matching or non-matching words.



```r
str_view(stringr::words, "^y", match =TRUE)
```


```r
str_view(stringr::words, "x$", match = TRUE)
```


```r
str_view(stringr::words, "^...$", match = TRUE)
```

A simpler way, shown later is 

```r
str_view(stringr::words, "^.{3}$", match = TRUE)
```


```r
str_view(stringr::words, ".......", match = TRUE)
```

### Character classes and alternatives

#### Exercise 1 {.exercise}

> Create regular expressions to find all words that:
>
> 1.  Start with a vowel.
> 2.  That only contain consonants. (Hint: thinking about matching “not”-vowels.)
> 3.  End with `ed`, but not with `eed`.
> 4.  End with `ing` or `ise`.

Words starting with vowels

```r
str_view(stringr::words, "^[aeiou]", match = TRUE)
```

Words that contain only consonants

```r
str_view(stringr::words, "^[^aeiou]+$", match=TRUE)
```
This seems to require using the `+` pattern introduced later, unless one wants to be very verbose and specify words of certain lengths.

Words that end with `ed` but not with `eed`. This handles the special case of "ed", as well as words with length > 2.

```r
str_view(stringr::words, "^ed$|[^e]ed$", match = TRUE)
```

Words ending in `ing` or `ise`:

```r
str_view(stringr::words, "i(ng|se)$", match = TRUE)
```

#### Exercise 2 {.exercise}

> Empirically verify the rule ``i before e except after c''.

Using only what has been introduced thus far: 

```r
str_view(stringr::words, "(cei|[^c]ie)", match = TRUE)
```

```r
str_view(stringr::words, "(cie|[^c]ei)", match = TRUE)
```

Using `str_detect` we can count the number of words that follow these rules:

```r
sum(str_detect(stringr::words, "(cei|[^c]ie)"))
sum(str_detect(stringr::words, "(cie|[^c]ei)"))
```

#### Exercise 3 {.exercise}

> Is ``q'' always followed by a ``u''?

In the `stringr::words` dataset, yes. In the full English language, no.

```r
str_view(stringr::words, "q[^u]", match = TRUE)
```

#### Exercise 4 {.exercise}

> Write a regular expression that matches a word if it’s probably written in British English, not American English.

In the general case, this is hard, and could require a dictionary.
But, there are a few heuristics to consider that would account for some common cases: British English tends to use the following:

- "ou" instead of "o"
- use of "ae" and "oe" instead of "a" and "o"
- ends in `ise` instead of `ize`
- ends in `yse`

The regex `ou|ise^|ae|oe|yse^` would match these.

There are other [spelling differences between American and British English] (https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences) but they are not patterns amenable to regular expressions.
It would require a dictionary with differences in spellings for different words.

#### Exercise 5 {.exercise}

> Create a regular expression that will match telephone numbers as commonly written in your country.

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

Note that this pattern doesn't account for phone numbers that are invalid because of unassigned area code, or special numbers like 911, or extensions. See the Wikipedia page for the [North American Numbering Plan](https://en.wikipedia.org/wiki/North_American_Numbering_Plan) for more information on the complexities of US phone numbers, and [this Stack Overflow question](http://stackoverflow.com/questions/123559/a-comprehensive-regex-for-phone-number-validation) for a discussion of using a regex for phone number validation.


### Repetition

#### Exercise 1 {.exercise}

> Describe the equivalents of `?`, `+`, `*` in `{m,n}` form.

----- ---------  ----------------------------------
`-`   `{,1}`     Match at most 1
`+`   `{1,}`     Match one or more
`*`   None       No equivalent
----- ---------  ----------------------------------

The `*` pattern has no `{m,n}` equivalent since there is no upper bound on the number of matches. The expected pattern `{,}` is not valid.

```r
str_view("abcd", ".{,}")
#> Error in stri_locate_first_regex(string, pattern, opts_regex = opts(pattern)): Error in {min,max} interval. (U_REGEX_BAD_INTERVAL)
```


#### Exercise 2 {.exercise}

> Describe in words what these regular expressions match: (read carefully to see if I’m using a regular expression or a string that defines a regular expression.)
>
> 1.  `^.*$`
> 2.  `"\\{.+\\}"`
> 3.  `\d{4}-\d{2}-\d{2}`
> 4.  `"\\\\{4}"`


-------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------- 
`^.*$`               Any string
`"\\{.+\\}"`         Any string with curly braces surrounding at least one character.
`\d{4}-\d{2}-\d{2}`  Four digits followed by a hyphen, followed by two digits followed by a hyphen, followed by another two digits. This is a regular expression that can match dates formatted like "YYYY-MM-DD" ("%Y-%m-%d").
 `"\\\\{4}"`         This resolves to the regular expression `\\{4}`, which is four backslashes.
 
Examples:

- `^.*$`: `c("dog", "$1.23", "lorem ipsum")`
- `"\\{.+\\}"`: `c("{a}", "{abc}")`
- `\d{4}-\d{2}-\d{2}`: `2018-01-11`
- `"\\\\{4}"`: `"\\\\\\\\"` (Backslashes in an R character vector need to be escaped.)

#### Exercise 3 {.exercise}

> Create regular expressions to find all words that:
>
> 1. Start with three consonants. 
> 2. Have three or more vowels in a row.
> 3. Have two or more vowel-consonant pairs in a row.
  
A regex to find all words starting with three consonants

```r
str_view(words, "^[^aeiou]{3}")
```

A regex to find three or more vowels in a row:

```r
str_view(words, "[aeiou]{3,}")
```

Two or more vowel-consonant pairs in a row.

```r
str_view(words, "([aeiou][^aeiou]){2,}")
```

  
#### Exercise 4 {.exercise}

> Solve the beginner regexp crosswords at https://regexcrossword.com/challenges/

Exercise left to reader. That site validates its solutions, so they aren't repeated here.

### Grouping and backreferences

#### Exercise 1 {.exercise}

> Describe, in words, what these expressions will match:
>
> 1.  `(.)\1\1` :
> 2.  `"(.)(.)\\2\\1"`:
> 3.  `(..)\1`: Any two characters repeated. E.g. `"a1a1"`.
> 4.  `"(.).\\1.\\1"`:
> 5.  `"(.)(.)(.).*\\3\\2\\1"`
  
  
1.  `(.)\1\1` : The same character appearing three times in a row. E.g. `"aaa"`
2.  `"(.)(.)\\2\\1"`: A pair of characters followed by the same pair of characters in reversed order. E.g. `"abba"`.
3.  `(..)\1`: Any two characters repeated. E.g. `"a1a1"`.
4.  `"(.).\\1.\\1"`: A character followed by any character, the original character, any other character, the original character again. E.g. `"abaca"`, `"b8b.b"`.
5.  `"(.)(.)(.).*\\3\\2\\1"` Three characters followed by zero or more characters of any kind followed by the same three characters but in reverse order. E.g. `"abcsgasgddsadgsdgcba"` or `"abccba"` or `"abc1cba"`.
  
#### Exercise 2 {.exercise}

> Construct regular expressions to match words that:
>
> 1. Start and end with the same character. Assuming the word is more than one character and all strings are considered words, `^(.).*\1$`
> 2. Contain a repeated pair of letters (e.g. ``church'' contains ``ch'' repeated twice.)
> 3. Contain one letter repeated in at least three places (e.g. ``eleven'' contains three ``e''s.)


Start and end with the same character. Assuming the word is more than one character and all strings are considered words, `^(.).*\1$`:

```r
str_view(words, "^(.).*\\1$")
```

Contain a repeated pair of letters (e.g. “church” contains “ch” repeated twice.):

I'll consider several patterns with varying levels of generality.
This pattern checks for any pair of repeated characters:

```r
str_view(words, "(..).*\\1")
```
This pattern is checks for any pair of repeated "letters":

```r
str_view(words, "([A-Za-z][A-Za-z]).*\\1")
```


Contain one letter repeated in at least three places (e.g. ``eleven'' contains three ``e''s.)
  

```r
str_subset(str_to_lower(words), "([a-z]).*\\1.*\\1")
#>  [1] "appropriate" "available"   "believe"     "between"     "business"   
#>  [6] "degree"      "difference"  "discuss"     "eleven"      "environment"
#> [11] "evidence"    "exercise"    "expense"     "experience"  "individual" 
#> [16] "paragraph"   "receive"     "remember"    "represent"   "telephone"  
#> [21] "therefore"   "tomorrow"
```
The `\\1` is used to refer back to the first group (`(.)`) so that whatever letter is matched by `[A-Za-z]` is again matched.


## Tools

### Detect matches

No exercises 

### Exercises

#### Exercise 1 {.exercise}

> For each of the following challenges, try solving it by using both a single regular expression, and a combination of multiple `str_detect()` calls.

  1. Find all words that start or end with x.
  2. Find all words that start with a vowel and end with a consonant.
  3. Are there any words that contain at least one of each different vowel?
  
Words that start or end with `x`?

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

Find all words starting with vowel and ending with consonant.


```r
str_subset(words, "^[aeiou].*[^aeiou]$") %>% head()
#> [1] "about"   "accept"  "account" "across"  "act"     "actual"
start_with_vowel <- str_detect(words, "^[aeiou]")
end_with_consonant <- str_detect(words, "[^aeiou]$")
words[start_with_vowel & end_with_consonant] %>% head()
#> [1] "about"   "accept"  "account" "across"  "act"     "actual"
```

Words that contain at least one of each vowel.
I can't think of a good way of doing this without doing a regex of the permutations: 

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
To check that it works,

```r
str_subset("aseiouds", pattern)
#> [1] "aseiouds"
```


#### Exercise 2 {.exercise}

> What word has the highest number of vowels? What word has the highest proportion of vowels? (Hint: what is the denominator?)


```r
prop_vowels <- str_count(words, "[aeiou]") / str_length(words)
words[which(prop_vowels == max(prop_vowels))]
#> [1] "a"
```

### Extract Matches


#### Exercise 1 {.exercise}

> In the previous example, you might have noticed that the regular expression matched “flickered”, which is not a color. Modify the regex to fix the problem.

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
str_view_all(more2, colour_match2, match = TRUE)
```


#### Exercise 2 {.exercise}

> From the Harvard sentences data, extract:
>
> 1. The first word from each sentence.
> 2. All words ending in `ing`.
> 3. All plurals.

The first word in each sentence requires defining what a word is. I'll consider a word any contiguous 

```r
str_extract(sentences, "[a-zA-X]+") %>% head()
#> [1] "The"   "Glue"  "It"    "These" "Rice"  "The"
```

All words ending in `ing`:

```r
pattern <- "\\b[A-Za-z]+ing\\b"
sentences_with_ing <- str_detect(sentences, pattern)
unique(unlist(str_extract_all(sentences[sentences_with_ing], pattern))) %>%
  head()
#> [1] "spring"  "evening" "morning" "winding" "living"  "king"
```

All plurals. To do this correct requires linguistic information. But if we just want to say any word ending in an "s" is plural (and with more than 3 characters to remove as, is, gas, etc.)

```r
unique(unlist(str_extract_all(sentences, "\\b[A-Za-z]{3,}s\\b"))) %>%
  head()
#> [1] "planks" "days"   "bowls"  "lemons" "makes"  "hogs"
```

### Grouped Matches


#### Exercise 1 {.exercise}

> Find all words that come after a “number” like “one”, “two”, “three” etc. Pull out both the number and the word.

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


#### Exercise 2 {.exercise}

> Find all contractions. Separate out the pieces before and after the apostrophe.


```r
contraction <- "([A-Za-z]+)'([A-Za-z]+)"
sentences %>%
  `[`(str_detect(sentences, contraction)) %>%
  str_extract(contraction)
#>  [1] "It's"       "man's"      "don't"      "store's"    "workmen's" 
#>  [6] "Let's"      "sun's"      "child's"    "king's"     "It's"      
#> [11] "don't"      "queen's"    "don't"      "pirate's"   "neighbor's"
```

### Replacing Matches


#### Exercise 1 {.exercise}

> Replace all forward slashes in a string with backslashes.

```r
backslashed <- str_replace_all("past/present/future", "\\/", "\\\\")
writeLines(backslashed)
#> past\present\future
```

#### Exercise 2 {.exercise}

> Implement a simple version of `str_to_lower()` using `replace_all()`.

```r
lower <- str_replace_all(words, c("A"="a", "B"="b", "C"="c", "D"="d", "E"="e", "F"="f", "G"="g", "H"="h", "I"="i", "J"="j", "K"="k", "L"="l", "M"="m", "N"="n", "O"="o", "P"="p", "Q"="q", "R"="r", "S"="s", "T"="t", "U"="u", "V"="v", "W"="w", "X"="x", "Y"="y", "Z"="z"))
```

#### Exercise 3 {.exercise}

> Switch the first and last letters in `words`. Which of those strings are still words?

First, make a vector of all the words with first and last letters swapped,

```r
swapped <- str_replace_all(words, "^([A-Za-z])(.*)([a-z])$", "\\3\\2\\1")
```
Next, find what of "swapped" is also in the original list using the function `intersect`,

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

### Splitting

#### Exercise 1 {.exercise}

> Split up a string like `"apples, pears, and bananas"` into individual components.


```r
x <- c("apples, pears, and bananas")
str_split(x, ", +(and +)?")[[1]]
#> [1] "apples"  "pears"   "bananas"
```


#### Exercise 2 {.exercise}

> Why is it better to split up by `boundary("word")` than `" "`?

Splitting by `boundary("word")` splits on punctuation and not just whitespace.

#### Exercise 3 {.exercise}

> What does splitting with an empty string `("")` do? Experiment, and then read the documentation.


```r
str_split("ab. cd|agt", "")[[1]]
#>  [1] "a" "b" "." " " "c" "d" "|" "a" "g" "t"
```

It splits the string into individual characters.

### Find matches

No exercises

## Other types of patterns


### Exercise 1 {.exercise}

> How would you find all strings containing `\` with `regex()` vs. with `fixed()`?


```r
str_subset(c("a\\b", "ab"), "\\\\")
#> [1] "a\\b"
str_subset(c("a\\b", "ab"), fixed("\\"))
#> [1] "a\\b"
```

### Exercise 2 {.exercise}

> What are the five most common words in sentences?


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

## Other uses of regular expressions

No exercises

## stringi


### Exercise 1 {.exercise}

> Find the **stringi** functions that:

> 1. Count the number of words. `stri_count_words`
> 2. Find duplicated strings. `stri_duplicated`
> 3. Generate random text. There are several functions beginning with `stri_rand_`. `stri_rand_lipsum` generates lorem ipsum text, `stri_rand_strings` generates random strings, `stri_rand_shuffle` randomly shuffles the code points in the text.

1. Count the number of words. `stri_count_words`
2. Find duplicated strings. `stri_duplicated`
3. Generate random text. There are several functions beginning with `stri_rand_`. `stri_rand_lipsum` generates lorem ipsum text, `stri_rand_strings` generates random strings, `stri_rand_shuffle` randomly shuffles the code points in the text.


### Exercise 2 {.exercise}

> How do you control the language that `stri_sort()` uses for sorting?

Use the `locale` argument to the `opts_collator` argument.
