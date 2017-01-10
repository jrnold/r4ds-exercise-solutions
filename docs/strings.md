
# Strings

## Introduction

Functions and packages coverered

- **stringr** package
- `str_length`
- `str_c`
- `str_replace_na`
- `str_sub`
- `str_to_uppser`, `str_sort`, `str_to_lower`, `str_order`
- `str_length`, `str_pad`, `str_trim`, `str_sub`
- For regex = `str_view`, `str_view_all`
- regex syntax
- `str_detect`
- `str_subset`
- `str_count`
- `str_extract`
- `str_match`
- `tidyr::extract`
- `str_split`
- `str_locate`
- `str_sub`
- the **stringi** package

Ideas

- mention [`rex`](https://github.com/kevinushey/rex). A package with friendly regular expressions.
- Use it to match country names? Extract numbers from text?
- Discuss fuzzy joining and string distance, approximate matching.



```r
library(tidyverse)
library(stringr)
```


## String Basics

### Exercises

1. In code that doesn’t use stringr, you’ll often see `paste()` and `paste0()`. What’s the difference between the two functions? What stringr function are they equivalent to? How do the functions differ in their handling of NA?

The function `paste` seperates strings by spaces by default, while `paste0` does not seperate strings with spaces by default.


```r
paste("foo", "bar")
#> [1] "foo bar"
paste0("foo", "bar")
#> [1] "foobar"
```

Since `str_c` does not seperate strings with spaces by default it is closer in behabior to `paste0`.


```r
str_c("foo", "bar")
#> [1] "foobar"
```

However, `str_c` and the paste ufnction handle NA differently.
The function `str_c` propogates `NA`, if any argument is a missing value, it returns a missing value.
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

2. In your own words, describe the difference between the `sep` and `collapse` arguments to `str_c()`.

The `sep` argument is the string inserted between argugments to `str_c`, while `collapse` is the string used to separate any elements of the character vector into a character vector of length one.

3. Use `str_length()` and `str_sub()` to extract the middle character from a string. What will you do if the string has an even number of characters?

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

4. What does `str_wrap()` do? When might you want to use it?

The function `str_wrap` wraps text so that it fits within a certain width.
This is useful for wrapping long strings of text to be typeset.

5. What does `str_trim()` do? What’s the opposite of `str_trim()`?

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

6. Write a function that turns (e.g.) a vector c("a", "b", "c") into the string a, b, and c. Think carefully about what it should do if given a vector of length 0, 1, or 2.

*Note:* See Ch 19 for writing functions.


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



### Exercises

1. Explain why each of these strings don’t match a `\`: `"\"`, `"\\"`, `"\\\"`.

- `"\"`: This will escape the next character in the R string.
- `"\\"`: This will resolve to `\` in the regular expression, which will escape the next character in the regular expression.
- `"\\\"`: The first two backslashes will resolve to a literal backslash in the regular expression, the third will escape the next character. So in the regular expresion, this will escape some escaped character.

2. How would you match the sequence `"'\` ?



3. What patterns will the regular expression `\..\..\..` match? How would you represent it as a string?

It will match any patterns that are a dot followed by any character, repeated three times.











#### Exercises

1. How would you match the literal string "$^$"?


```r
str_view(c("$^$", "ab$^$sfas"), "^\\$\\^\\$$")
```

<!--html_preserve--><div id="htmlwidget-d34691559831f28a8b47" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-d34691559831f28a8b47">{"x":{"html":"<ul>\n  <li><span class='match'>$^$\u003c/span>\u003c/li>\n  <li>ab$^$sfas\u003c/li>\n\u003c/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

2. Given the corpus of common words in `stringr::words`, create regular expressions that find all words that:

  1. Start with “y”.
  2. End with “x”
  3. Are exactly three letters long. (Don’t cheat by using `str_length()`!)
  4. Have seven letters or more.
  
Since this list is long, you might want to use the match argument to `str_view()` to show only the matching or non-matching words.


```r
head(stringr::words)
#> [1] "a"        "able"     "about"    "absolute" "accept"   "account"
```







A simpler way, shown later is 




#### Character classes and alternatives



##### Exercises


1. Create regular expressions to find all words that:

   1. Start with a vowel.
   2. That only contain consonants. (Hint: thinking about matching “not”-vowels.)
   3. End with `ed`, but not with `eed`.
   4. End with `ing` or `ise`.

Words starting with vowels

```r
str_view(stringr::words, "^[aeiou]")
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

Words ending in ing or ise:

```r
str_view(stringr::words, "i(ng|se)$", match = TRUE)
```

2. Empirically verify the rule “i before e except after c”.

Using only what has been introduced thus far: 

```r
str_view(stringr::words, "(cei|[^c]ie)", match = TRUE)
```

```r
str_view(stringr::words, "(cie|[^c]ei)", match = TRUE)
```

Using `str_detect`:

```r
sum(str_detect(stringr::words, "(cei|[^c]ie)"))
#> [1] 14
sum(str_detect(stringr::words, "(cie|[^c]ei)"))
#> [1] 3
```

3. Is “q” always followed by a “u”?

In the `stringr::words` dataset, yes. In the full English language, no.

```r
str_view(stringr::words, "q[^u]", match = TRUE)
```

4. Write a regular expression that matches a word if it’s probably written in British English, not American English.

Ummm. In the general case, this is hard. But, there are a few heuristics to consider that can get part of the way there: British English uses 

- "ou" instead of "o"
- use of "ae" and "oe" instead of "a" and "o"
- ends in `ise` instead of `ize`
- ending `yse`

`ou|ise^|ae|oe|yse^`

There are others, but https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences but this is not handled best by a regular expression.
It would require a dictionary with differences in spellings for different words.
And even then, a good algorithm would be statistical, inferring the probability that a text or word is using the British spelling rather than some deterministic algorithm.

5. Create a regular expression that will match telephone numbers as commonly written in your country.

Using what has been covered in *R4DS* thus far,

```r
x <- c("123-456-7890", "1235-2351")
str_view(x, "\\d\\d\\d-\\d\\d\\d-\\d\\d\\d\\d")
```
Using stuff covered in the next section,

```r
str_view(x, "\\d{3}-\\d{3}-\\d{4}")
```
Note that this pattern doesn't account for phone numbers that are invalid because of unassigned area code, or special numbers like 911, or for extensions. See https://en.wikipedia.org/wiki/North_American_Numbering_Plan for the complexities of US phone numbers, and http://stackoverflow.com/questions/123559/a-comprehensive-regex-for-phone-number-validation for one discussion of using a regex for phone number validation.

### Repitition

#### Exercises

1. Describe the equivalents of `?`, `+`, `*` in `{m,n}` form.

The equivalent of `?` is `{,1}`, matching at most 1.
The equivalent of `+` is `{1,}`, matching 1 or more.
There is no direct equivalent of `*` in `{m,n}` form since there are no bounds on the matches: it can be 0 up to infinity matches.


2. Describe in words what these regular expressions match: (read carefully to see if I’m using a regular expression or a string that defines a regular expression.)

  1. `^.*$`: Any string
  2. `"\\{.+\\}"`: Any string with curly braces surrounding at least one character.
  3. `\d{4}-\d{2}-\d{2}`: A date in "%Y-%m-%d" format: four digits followed by a dash, followed by two digits followed by a dash, followed by another two digits followed by a dash.
  4. `"\\\\{4}"`: This resolves to the regex `\\{4}`, which is four backslashes.

3. Create regular expressions to find all words that:

  1. Start with three consonants. 
  2. Have three or more vowels in a row.
  3. Have two or more vowel-consonant pairs in a row.
  
A regex to find all words starting with three consonants

```r
str_view(words, "^[^aeiou]{3}", match = TRUE)
```

A regex to find three or more vowels in a row:

```r
str_view(words, "[aeiou]{3,}", match = TRUE)
```

Two or more vowel-consonant pairs in a row.

```r
str_view(words, "([aeiou][^aeiou]){2,}", match = TRUE)
```

  
4. Solve the beginner regexp crosswords at https://regexcrossword.com/challenges/beginner

*Nope*

### Grouping and backreferences


```r
str_view(fruit, "(..)\\1", match = TRUE)
```

#### Exercises

1. Describe, in words, what these expressions will match:

  1. `(.)\1\1` : The same character apearing three times in a row. E.g. "aaa"
  2. `"(.)(.)\\2\\1"`: A pair of characters followed by the same pair of characters in reversed order. E.g. "abba".
  3. `(..)\1`: Any two characters repeated. E.g. "a1a1".
  4. `"(.).\\1.\\1"`: A character followed by any character, the original character, any other character, the original character again. E.g. "abaca", "b8b.b".
  5. `"(.)(.)(.).*\\3\\2\\1"` Three characters followed by zero or more characters of any kind followed by the same three characters but in reverse order. E.g. "abcsgasgddsadgsdgcba" or "abccba" or "abc1cba".
  
2. Construct regular expressions to match words that:

  1. Start and end with the same character. Assuming the word is more than one character and all strings are considered words, `^(.).*\1$`
  

```r
str_view(words, "^(.).*\\1$", match = TRUE)
```

  2 Contain a repeated pair of letters (e.g. “church” contains “ch” repeated twice.). 
  

```r
# any two characters repeated
str_view(words, "(..).*\\1", match = TRUE)
```

```r
# more stringent, letters only, but also allowing for differences in capitalization
str_view(str_to_lower(words), "([a-z][a-z]).*\\1", match = TRUE)
```


  3. Contain one letter repeated in at least three places (e.g. “eleven” contains three “e”s.)
  
  

```r
str_view(words, "(.).*\\1.*\\1", match = TRUE)
```

<!--html_preserve--><div id="htmlwidget-6f8d3407f82dc7e2d69a" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-6f8d3407f82dc7e2d69a">{"x":{"html":"<ul>\n  <li>a<span class='match'>pprop\u003c/span>riate\u003c/li>\n  <li><span class='match'>availa\u003c/span>ble\u003c/li>\n  <li>b<span class='match'>elieve\u003c/span>\u003c/li>\n  <li>b<span class='match'>etwee\u003c/span>n\u003c/li>\n  <li>bu<span class='match'>siness\u003c/span>\u003c/li>\n  <li>d<span class='match'>egree\u003c/span>\u003c/li>\n  <li>diff<span class='match'>erence\u003c/span>\u003c/li>\n  <li>di<span class='match'>scuss\u003c/span>\u003c/li>\n  <li><span class='match'>eleve\u003c/span>n\u003c/li>\n  <li>e<span class='match'>nvironmen\u003c/span>t\u003c/li>\n  <li><span class='match'>evidence\u003c/span>\u003c/li>\n  <li><span class='match'>exercise\u003c/span>\u003c/li>\n  <li><span class='match'>expense\u003c/span>\u003c/li>\n  <li><span class='match'>experience\u003c/span>\u003c/li>\n  <li><span class='match'>indivi\u003c/span>dual\u003c/li>\n  <li>p<span class='match'>aragra\u003c/span>ph\u003c/li>\n  <li>r<span class='match'>eceive\u003c/span>\u003c/li>\n  <li>r<span class='match'>emembe\u003c/span>r\u003c/li>\n  <li>r<span class='match'>eprese\u003c/span>nt\u003c/li>\n  <li>t<span class='match'>elephone\u003c/span>\u003c/li>\n  <li>th<span class='match'>erefore\u003c/span>\u003c/li>\n  <li>t<span class='match'>omorro\u003c/span>w\u003c/li>\n\u003c/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

## Tools

### Detect matches


```r
x <- c("apple", "banana", "pear")
str_detect(x, "e")
#> [1]  TRUE FALSE  TRUE
```

Number of words starting with t?

```r
sum(str_detect(words, "^t"))
#> [1] 65
```
Proportion of words ending with a vowel?

```r
mean(str_detect(words, "[aeiou]$"))
#> [1] 0.277
```

To find all words with no vowels

```r
no_vowels_1 <- !str_detect(words, "[aeiou]")
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")
identical(no_vowels_1, no_vowels_2)
#> [1] TRUE
```


```r
words[str_detect(words, "x$")]
#> [1] "box" "sex" "six" "tax"
str_subset(words, "x$")
#> [1] "box" "sex" "six" "tax"
```


```r
df <- tibble(
  word = words,
  i = seq_along(word)
)
df %>%
  filter(str_detect(words, "x$"))
#> # A tibble: 4 × 2
#>    word     i
#>   <chr> <int>
#> 1   box   108
#> 2   sex   747
#> 3   six   772
#> 4   tax   841
```

Number of matches in each string

```r
x <- c("apple", "banana", "pear")
str_count(x, "a")
#> [1] 1 3 1
```
Average vowels per word

```r
mean(str_count(words, "[aeiou]"))
#> [1] 1.99
```


```r
df %>%
  mutate(
    vowels = str_count(word, "[aeiou]"),
    consonants = str_count(word, "[^aeiou]")
  )
#> # A tibble: 980 × 4
#>       word     i vowels consonants
#>      <chr> <int>  <int>      <int>
#> 1        a     1      1          0
#> 2     able     2      2          2
#> 3    about     3      3          2
#> 4 absolute     4      4          4
#> 5   accept     5      2          4
#> 6  account     6      3          4
#> # ... with 974 more rows
```

- matches do not overlap - they are usually greedy, except when otherwise noted.
- matches only match the first one. `_all()` functions will get all matches.

### Exercises

1. For each of the following challenges, try solving it by using both a single regular expression, and a combination of multiple `str_detect()` calls.

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


2. What word has the highest number of vowels? What word has the highest proportion of vowels? (Hint: what is the denominator?)


```r
prop_vowels <- str_count(words, "[aeiou]") / str_length(words)
words[which(prop_vowels == max(prop_vowels))]
#> [1] "a"
```

### Extract Matches

The Harvard sentences:

```r
length(sentences)
#> [1] 720
head(sentences)
#> [1] "The birch canoe slid on the smooth planks." 
#> [2] "Glue the sheet to the dark blue background."
#> [3] "It's easy to tell the depth of a well."     
#> [4] "These days a chicken leg is a rare dish."   
#> [5] "Rice is often served in round bowls."       
#> [6] "The juice of lemons makes fine punch."
```


```r
colours <- c("red", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|")
colour_match
#> [1] "red|orange|yellow|green|blue|purple"
```


```r
has_colour <- str_subset(sentences, colour_match)
matches <- str_extract(has_colour, colour_match)
head(matches)
#> [1] "blue" "blue" "red"  "red"  "red"  "blue"
```


```r
more <- sentences[str_count(sentences, colour_match) > 1]
str_view_all(more, colour_match)
```

<!--html_preserve--><div id="htmlwidget-e8092118b2671020ef37" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-e8092118b2671020ef37">{"x":{"html":"<ul>\n  <li>It is hard to erase <span class='match'>blue\u003c/span> or <span class='match'>red\u003c/span> ink.\u003c/li>\n  <li>The <span class='match'>green\u003c/span> light in the brown box flicke<span class='match'>red\u003c/span>.\u003c/li>\n  <li>The sky in the west is tinged with <span class='match'>orange\u003c/span> <span class='match'>red\u003c/span>.\u003c/li>\n\u003c/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


```r
str_extract(more, colour_match)
#> [1] "blue"   "green"  "orange"
```

The `_all` versions of functions return lists.

```r
str_extract_all(more, colour_match)
#> [[1]]
#> [1] "blue" "red" 
#> 
#> [[2]]
#> [1] "green" "red"  
#> 
#> [[3]]
#> [1] "orange" "red"
```


```r
str_extract_all(more, colour_match, simplify = TRUE)
#>      [,1]     [,2] 
#> [1,] "blue"   "red"
#> [2,] "green"  "red"
#> [3,] "orange" "red"
```


```r
x <- c("a", "a b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)
#>      [,1] [,2] [,3]
#> [1,] "a"  ""   ""  
#> [2,] "a"  "b"  ""  
#> [3,] "a"  "b"  "c"
```

#### Exercises

1. In the previous example, you might have noticed that the regular expression matched “flickered”, which is not a colour. Modify the regex to fix the problem.

Add the `\b` before and after the pattern

```r
colour_match2 <- str_c("\\b(", str_c(colours, collapse = "|"), ")\\b")
colour_match2
#> [1] "\\b(red|orange|yellow|green|blue|purple)\\b"
```


```r
more2 <- sentences[str_count(sentences, colour_match) > 1]
str_view_all(more2, colour_match2, match = TRUE)
```


2. From the Harvard sentences data, extract:

  1. The first word from each sentence.
  2. All words ending in `ing`.
  3. All plurals.

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


```r
noun <- "(a|the) ([^ ]+)"
has_noun <- sentences %>%
  str_subset(noun) %>%
  head(10)
has_noun %>%
  str_extract(noun)
#>  [1] "the smooth" "the sheet"  "the depth"  "a chicken"  "the parked"
#>  [6] "the sun"    "the huge"   "the ball"   "the woman"  "a helps"
```



```r
has_noun %>%
  str_match(noun)
#>       [,1]         [,2]  [,3]     
#>  [1,] "the smooth" "the" "smooth" 
#>  [2,] "the sheet"  "the" "sheet"  
#>  [3,] "the depth"  "the" "depth"  
#>  [4,] "a chicken"  "a"   "chicken"
#>  [5,] "the parked" "the" "parked" 
#>  [6,] "the sun"    "the" "sun"    
#>  [7,] "the huge"   "the" "huge"   
#>  [8,] "the ball"   "the" "ball"   
#>  [9,] "the woman"  "the" "woman"  
#> [10,] "a helps"    "a"   "helps"
```


```r
tibble(sentence = sentences) %>%
  tidyr::extract(
    sentence, c("article", "noun"), "(a|the) ([^ ]+)",
    remove = FALSE
  )
#> # A tibble: 720 × 3
#>                                      sentence article    noun
#> *                                       <chr>   <chr>   <chr>
#> 1  The birch canoe slid on the smooth planks.     the  smooth
#> 2 Glue the sheet to the dark blue background.     the   sheet
#> 3      It's easy to tell the depth of a well.     the   depth
#> 4    These days a chicken leg is a rare dish.       a chicken
#> 5        Rice is often served in round bowls.    <NA>    <NA>
#> 6       The juice of lemons makes fine punch.    <NA>    <NA>
#> # ... with 714 more rows
```

#### Exercises

1. Find all words that come after a “number” like “one”, “two”, “three” etc. Pull out both the number and the word.

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


2. Find all contractions. Separate out the pieces before and after the apostrophe.


```r
contraction <- "([A-Za-z]+)'([A-Za-z]+)"
sentences %>%
  `[`(str_detect(sentences, contraction)) %>%
  str_extract(contraction)
#>  [1] "It's"       "man's"      "don't"      "store's"    "workmen's" 
#>  [6] "Let's"      "sun's"      "child's"    "king's"     "It's"      
#> [11] "don't"      "queen's"    "don't"      "pirate's"   "neighbor's"
```

### Splitting


#### Exercises

1. Split up a string like `"apples, pears, and bananas"` into individual components.


```r
x <- c("apples, pears, and bananas")
str_split(x, ", +(and +)?")[[1]]
#> [1] "apples"  "pears"   "bananas"
```


2. Why is it better to split up by `boundary("word")` than `" "`?

Splitting by `boundary("word")` splits on punctuation and not just whitespace.

3. What does splitting with an empty string `("")` do? Experiment, and then read the documentation.


```r
str_split("ab. cd|agt", "")[[1]]
#>  [1] "a" "b" "." " " "c" "d" "|" "a" "g" "t"
```

It splits the string into individual characters.


## Other types of patterns

### Exercises

1. How would you find all strings containing `\` with `regex()` vs. with `fixed()`?


```r
str_subset(c("a\\b", "ab"), "\\\\")
#> [1] "a\\b"
str_subset(c("a\\b", "ab"), fixed("\\"))
#> [1] "a\\b"
```

2. What are the five most common words in sentences?


```r
str_extract_all(sentences, boundary("word")) %>%
  unlist() %>%
  str_to_lower() %>%
  tibble() %>%
  set_names("word") %>%
  group_by(word) %>%
  count(sort = TRUE) %>%
  head(5)
#> # A tibble: 5 × 2
#>    word     n
#>   <chr> <int>
#> 1   the   751
#> 2     a   202
#> 3    of   132
#> 4    to   123
#> 5   and   118
```

## stringi

### Exercises

1. Find the stringi functions that:

    1. Count the number of words. `stri_count_words`
    2. Find duplicated strings. `stri_duplicated`
    2. Generate random text. There are several functions beginning with `stri_rand_`. `stri_rand_lipsum` generates lorem ipsum text, `stri_rand_strings` generates random strings, `stri_rand_shuffle` randomly shuffles the code points in the text.

2. How do you control the language that `stri_sort()` uses for sorting?

Use the `locale` argument to the `opts_collator` argument.
