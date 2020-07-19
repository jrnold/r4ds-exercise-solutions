---
output: html_document
editor_options: 
  chunk_output_type: console
---
# Strings {#strings .r4ds-section}

## Introduction {#introduction-8 .r4ds-section}


```r
library("tidyverse")
```

## String basics {#string-basics .r4ds-section}

### Exercise 14.2.1 {.unnumbered .exercise data-number="14.2.1"}

<div class="question">

In code that doesn’t use stringr, you’ll often see `paste()` and `paste0()`. 
What’s the difference between the two functions? What stringr function are they equivalent to? 
How do the functions differ in their handling of `NA`?

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

### Exercise 14.2.2 {.unnumbered .exercise data-number="14.2.2"}

<div class="question">
In your own words, describe the difference between the `sep` and `collapse` arguments to `str_c()`.
</div>

<div class="answer">

The `sep` argument is the string inserted between arguments to `str_c()`, while `collapse` is the string used to separate any elements of the character vector into a character vector of length one.

</div>

### Exercise 14.2.3 {.unnumbered .exercise data-number="14.2.3"}

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

### Exercise 14.2.4 {.unnumbered .exercise data-number="14.2.4"}

<div class="question">
What does `str_wrap()` do? When might you want to use it?
</div>

<div class="answer">

The function `str_wrap()` wraps text so that it fits within a certain width.
This is useful for wrapping long strings of text to be typeset.

</div>

### Exercise 14.2.5 {.unnumbered .exercise data-number="14.2.5"}

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

### Exercise 14.2.6 {.unnumbered .exercise data-number="14.2.6"}

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

## Matching patterns with regular expressions {#matching-patterns-with-regular-expressions .r4ds-section}

### Basic matches {#basic-matches .r4ds-section}

#### Exercise 14.3.1.1 {.unnumbered .exercise data-number="14.3.1.1"}

<div class="question">
Explain why each of these strings don’t match a `\`: `"\"`, `"\\"`, `"\\\"`.
</div>

<div class="answer">

-   `"\"`: This will escape the next character in the R string.
-   `"\\"`: This will resolve to `\` in the regular expression, which will escape the next character in the regular expression.
-   `"\\\"`: The first two backslashes will resolve to a literal backslash in the regular expression, the third will escape the next character. So in the regular expression, this will escape some escaped character.

</div>

#### Exercise 14.3.1.2 {.unnumbered .exercise data-number="14.3.1.2"}

<div class="question">
How would you match the sequence `"'\` ?
</div>

<div class="answer">


```r
str_view("\"'\\", "\"'\\\\", match = TRUE)
```

<!--html_preserve--><div id="htmlwidget-ac96cb3ee4656e2e9ec3" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-ac96cb3ee4656e2e9ec3">{"x":{"html":"<ul>\n  <li><span class='match'>\"'\\<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

#### Exercise 14.3.1.3 {.unnumbered .exercise data-number="14.3.1.3"}

<div class="question">
What patterns will the regular expression `\..\..\..` match? How would you represent it as a string?
</div>

<div class="answer">

It will match any patterns that are a dot followed by any character, repeated three times.


```r
str_view(c(".a.b.c", ".a.b", "....."), c("\\..\\..\\.."), match = TRUE)
```

<!--html_preserve--><div id="htmlwidget-e5c8c404fe174e4c81bd" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-e5c8c404fe174e4c81bd">{"x":{"html":"<ul>\n  <li><span class='match'>.a.b.c<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

### Anchors {#anchors .r4ds-section}

#### Exercise 14.3.2.1 {.unnumbered .exercise data-number="14.3.2.1"}

<div class="question">
How would you match the literal string `"$^$"`?
</div>

<div class="answer">

To check that the pattern works, I'll include both the string `"$^$"`, and an example where that pattern occurs in the middle of the string which should not be matched.

```r
str_view(c("$^$", "ab$^$sfas"), "^\\$\\^\\$$", match = TRUE)
```

<!--html_preserve--><div id="htmlwidget-36aa3d2a04d42bbc2145" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-36aa3d2a04d42bbc2145">{"x":{"html":"<ul>\n  <li><span class='match'>$^$<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

#### Exercise 14.3.2.2 {.unnumbered .exercise data-number="14.3.2.2"}

<div class="question">
Given the corpus of common words in `stringr::words`, create regular expressions that find all words that:

1.  Start with “y”.
1.  End with “x”
1.  Are exactly three letters long. (Don’t cheat by using `str_length()`!)
1.  Have seven letters or more.

Since this list is long, you might want to use the `match` argument to `str_view()` to show only the matching or non-matching words.

</div>

<div class="answer">

The answer to each part follows.

1.  The words that start with  “y” are:

    
    ```r
    str_view(stringr::words, "^y", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-febe03efa1a2d8d52a86" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-febe03efa1a2d8d52a86">{"x":{"html":"<ul>\n  <li><span class='match'>y<\/span>ear<\/li>\n  <li><span class='match'>y<\/span>es<\/li>\n  <li><span class='match'>y<\/span>esterday<\/li>\n  <li><span class='match'>y<\/span>et<\/li>\n  <li><span class='match'>y<\/span>ou<\/li>\n  <li><span class='match'>y<\/span>oung<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

1.  End with “x”

    
    ```r
    str_view(stringr::words, "x$", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-1fb4450895fe099f74a1" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-1fb4450895fe099f74a1">{"x":{"html":"<ul>\n  <li>bo<span class='match'>x<\/span><\/li>\n  <li>se<span class='match'>x<\/span><\/li>\n  <li>si<span class='match'>x<\/span><\/li>\n  <li>ta<span class='match'>x<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

1.  Are exactly three letters long are

    
    ```r
    str_view(stringr::words, "^...$", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-10b3b7155e8045a1b2ad" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-10b3b7155e8045a1b2ad">{"x":{"html":"<ul>\n  <li><span class='match'>act<\/span><\/li>\n  <li><span class='match'>add<\/span><\/li>\n  <li><span class='match'>age<\/span><\/li>\n  <li><span class='match'>ago<\/span><\/li>\n  <li><span class='match'>air<\/span><\/li>\n  <li><span class='match'>all<\/span><\/li>\n  <li><span class='match'>and<\/span><\/li>\n  <li><span class='match'>any<\/span><\/li>\n  <li><span class='match'>arm<\/span><\/li>\n  <li><span class='match'>art<\/span><\/li>\n  <li><span class='match'>ask<\/span><\/li>\n  <li><span class='match'>bad<\/span><\/li>\n  <li><span class='match'>bag<\/span><\/li>\n  <li><span class='match'>bar<\/span><\/li>\n  <li><span class='match'>bed<\/span><\/li>\n  <li><span class='match'>bet<\/span><\/li>\n  <li><span class='match'>big<\/span><\/li>\n  <li><span class='match'>bit<\/span><\/li>\n  <li><span class='match'>box<\/span><\/li>\n  <li><span class='match'>boy<\/span><\/li>\n  <li><span class='match'>bus<\/span><\/li>\n  <li><span class='match'>but<\/span><\/li>\n  <li><span class='match'>buy<\/span><\/li>\n  <li><span class='match'>can<\/span><\/li>\n  <li><span class='match'>car<\/span><\/li>\n  <li><span class='match'>cat<\/span><\/li>\n  <li><span class='match'>cup<\/span><\/li>\n  <li><span class='match'>cut<\/span><\/li>\n  <li><span class='match'>dad<\/span><\/li>\n  <li><span class='match'>day<\/span><\/li>\n  <li><span class='match'>die<\/span><\/li>\n  <li><span class='match'>dog<\/span><\/li>\n  <li><span class='match'>dry<\/span><\/li>\n  <li><span class='match'>due<\/span><\/li>\n  <li><span class='match'>eat<\/span><\/li>\n  <li><span class='match'>egg<\/span><\/li>\n  <li><span class='match'>end<\/span><\/li>\n  <li><span class='match'>eye<\/span><\/li>\n  <li><span class='match'>far<\/span><\/li>\n  <li><span class='match'>few<\/span><\/li>\n  <li><span class='match'>fit<\/span><\/li>\n  <li><span class='match'>fly<\/span><\/li>\n  <li><span class='match'>for<\/span><\/li>\n  <li><span class='match'>fun<\/span><\/li>\n  <li><span class='match'>gas<\/span><\/li>\n  <li><span class='match'>get<\/span><\/li>\n  <li><span class='match'>god<\/span><\/li>\n  <li><span class='match'>guy<\/span><\/li>\n  <li><span class='match'>hit<\/span><\/li>\n  <li><span class='match'>hot<\/span><\/li>\n  <li><span class='match'>how<\/span><\/li>\n  <li><span class='match'>job<\/span><\/li>\n  <li><span class='match'>key<\/span><\/li>\n  <li><span class='match'>kid<\/span><\/li>\n  <li><span class='match'>lad<\/span><\/li>\n  <li><span class='match'>law<\/span><\/li>\n  <li><span class='match'>lay<\/span><\/li>\n  <li><span class='match'>leg<\/span><\/li>\n  <li><span class='match'>let<\/span><\/li>\n  <li><span class='match'>lie<\/span><\/li>\n  <li><span class='match'>lot<\/span><\/li>\n  <li><span class='match'>low<\/span><\/li>\n  <li><span class='match'>man<\/span><\/li>\n  <li><span class='match'>may<\/span><\/li>\n  <li><span class='match'>mrs<\/span><\/li>\n  <li><span class='match'>new<\/span><\/li>\n  <li><span class='match'>non<\/span><\/li>\n  <li><span class='match'>not<\/span><\/li>\n  <li><span class='match'>now<\/span><\/li>\n  <li><span class='match'>odd<\/span><\/li>\n  <li><span class='match'>off<\/span><\/li>\n  <li><span class='match'>old<\/span><\/li>\n  <li><span class='match'>one<\/span><\/li>\n  <li><span class='match'>out<\/span><\/li>\n  <li><span class='match'>own<\/span><\/li>\n  <li><span class='match'>pay<\/span><\/li>\n  <li><span class='match'>per<\/span><\/li>\n  <li><span class='match'>put<\/span><\/li>\n  <li><span class='match'>red<\/span><\/li>\n  <li><span class='match'>rid<\/span><\/li>\n  <li><span class='match'>run<\/span><\/li>\n  <li><span class='match'>say<\/span><\/li>\n  <li><span class='match'>see<\/span><\/li>\n  <li><span class='match'>set<\/span><\/li>\n  <li><span class='match'>sex<\/span><\/li>\n  <li><span class='match'>she<\/span><\/li>\n  <li><span class='match'>sir<\/span><\/li>\n  <li><span class='match'>sit<\/span><\/li>\n  <li><span class='match'>six<\/span><\/li>\n  <li><span class='match'>son<\/span><\/li>\n  <li><span class='match'>sun<\/span><\/li>\n  <li><span class='match'>tax<\/span><\/li>\n  <li><span class='match'>tea<\/span><\/li>\n  <li><span class='match'>ten<\/span><\/li>\n  <li><span class='match'>the<\/span><\/li>\n  <li><span class='match'>tie<\/span><\/li>\n  <li><span class='match'>too<\/span><\/li>\n  <li><span class='match'>top<\/span><\/li>\n  <li><span class='match'>try<\/span><\/li>\n  <li><span class='match'>two<\/span><\/li>\n  <li><span class='match'>use<\/span><\/li>\n  <li><span class='match'>war<\/span><\/li>\n  <li><span class='match'>way<\/span><\/li>\n  <li><span class='match'>wee<\/span><\/li>\n  <li><span class='match'>who<\/span><\/li>\n  <li><span class='match'>why<\/span><\/li>\n  <li><span class='match'>win<\/span><\/li>\n  <li><span class='match'>yes<\/span><\/li>\n  <li><span class='match'>yet<\/span><\/li>\n  <li><span class='match'>you<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

1.  The words that have seven letters or more:

    
    ```r
    str_view(stringr::words, ".......", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-4018eef1a407a0df6b52" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-4018eef1a407a0df6b52">{"x":{"html":"<ul>\n  <li><span class='match'>absolut<\/span>e<\/li>\n  <li><span class='match'>account<\/span><\/li>\n  <li><span class='match'>achieve<\/span><\/li>\n  <li><span class='match'>address<\/span><\/li>\n  <li><span class='match'>adverti<\/span>se<\/li>\n  <li><span class='match'>afterno<\/span>on<\/li>\n  <li><span class='match'>against<\/span><\/li>\n  <li><span class='match'>already<\/span><\/li>\n  <li><span class='match'>alright<\/span><\/li>\n  <li><span class='match'>althoug<\/span>h<\/li>\n  <li><span class='match'>america<\/span><\/li>\n  <li><span class='match'>another<\/span><\/li>\n  <li><span class='match'>apparen<\/span>t<\/li>\n  <li><span class='match'>appoint<\/span><\/li>\n  <li><span class='match'>approac<\/span>h<\/li>\n  <li><span class='match'>appropr<\/span>iate<\/li>\n  <li><span class='match'>arrange<\/span><\/li>\n  <li><span class='match'>associa<\/span>te<\/li>\n  <li><span class='match'>authori<\/span>ty<\/li>\n  <li><span class='match'>availab<\/span>le<\/li>\n  <li><span class='match'>balance<\/span><\/li>\n  <li><span class='match'>because<\/span><\/li>\n  <li><span class='match'>believe<\/span><\/li>\n  <li><span class='match'>benefit<\/span><\/li>\n  <li><span class='match'>between<\/span><\/li>\n  <li><span class='match'>brillia<\/span>nt<\/li>\n  <li><span class='match'>britain<\/span><\/li>\n  <li><span class='match'>brother<\/span><\/li>\n  <li><span class='match'>busines<\/span>s<\/li>\n  <li><span class='match'>certain<\/span><\/li>\n  <li><span class='match'>chairma<\/span>n<\/li>\n  <li><span class='match'>charact<\/span>er<\/li>\n  <li><span class='match'>Christm<\/span>as<\/li>\n  <li><span class='match'>colleag<\/span>ue<\/li>\n  <li><span class='match'>collect<\/span><\/li>\n  <li><span class='match'>college<\/span><\/li>\n  <li><span class='match'>comment<\/span><\/li>\n  <li><span class='match'>committ<\/span>ee<\/li>\n  <li><span class='match'>communi<\/span>ty<\/li>\n  <li><span class='match'>company<\/span><\/li>\n  <li><span class='match'>compare<\/span><\/li>\n  <li><span class='match'>complet<\/span>e<\/li>\n  <li><span class='match'>compute<\/span><\/li>\n  <li><span class='match'>concern<\/span><\/li>\n  <li><span class='match'>conditi<\/span>on<\/li>\n  <li><span class='match'>conside<\/span>r<\/li>\n  <li><span class='match'>consult<\/span><\/li>\n  <li><span class='match'>contact<\/span><\/li>\n  <li><span class='match'>continu<\/span>e<\/li>\n  <li><span class='match'>contrac<\/span>t<\/li>\n  <li><span class='match'>control<\/span><\/li>\n  <li><span class='match'>convers<\/span>e<\/li>\n  <li><span class='match'>correct<\/span><\/li>\n  <li><span class='match'>council<\/span><\/li>\n  <li><span class='match'>country<\/span><\/li>\n  <li><span class='match'>current<\/span><\/li>\n  <li><span class='match'>decisio<\/span>n<\/li>\n  <li><span class='match'>definit<\/span>e<\/li>\n  <li><span class='match'>departm<\/span>ent<\/li>\n  <li><span class='match'>describ<\/span>e<\/li>\n  <li><span class='match'>develop<\/span><\/li>\n  <li><span class='match'>differe<\/span>nce<\/li>\n  <li><span class='match'>difficu<\/span>lt<\/li>\n  <li><span class='match'>discuss<\/span><\/li>\n  <li><span class='match'>distric<\/span>t<\/li>\n  <li><span class='match'>documen<\/span>t<\/li>\n  <li><span class='match'>economy<\/span><\/li>\n  <li><span class='match'>educate<\/span><\/li>\n  <li><span class='match'>electri<\/span>c<\/li>\n  <li><span class='match'>encoura<\/span>ge<\/li>\n  <li><span class='match'>english<\/span><\/li>\n  <li><span class='match'>environ<\/span>ment<\/li>\n  <li><span class='match'>especia<\/span>l<\/li>\n  <li><span class='match'>evening<\/span><\/li>\n  <li><span class='match'>evidenc<\/span>e<\/li>\n  <li><span class='match'>example<\/span><\/li>\n  <li><span class='match'>exercis<\/span>e<\/li>\n  <li><span class='match'>expense<\/span><\/li>\n  <li><span class='match'>experie<\/span>nce<\/li>\n  <li><span class='match'>explain<\/span><\/li>\n  <li><span class='match'>express<\/span><\/li>\n  <li><span class='match'>finance<\/span><\/li>\n  <li><span class='match'>fortune<\/span><\/li>\n  <li><span class='match'>forward<\/span><\/li>\n  <li><span class='match'>functio<\/span>n<\/li>\n  <li><span class='match'>further<\/span><\/li>\n  <li><span class='match'>general<\/span><\/li>\n  <li><span class='match'>germany<\/span><\/li>\n  <li><span class='match'>goodbye<\/span><\/li>\n  <li><span class='match'>history<\/span><\/li>\n  <li><span class='match'>holiday<\/span><\/li>\n  <li><span class='match'>hospita<\/span>l<\/li>\n  <li><span class='match'>however<\/span><\/li>\n  <li><span class='match'>hundred<\/span><\/li>\n  <li><span class='match'>husband<\/span><\/li>\n  <li><span class='match'>identif<\/span>y<\/li>\n  <li><span class='match'>imagine<\/span><\/li>\n  <li><span class='match'>importa<\/span>nt<\/li>\n  <li><span class='match'>improve<\/span><\/li>\n  <li><span class='match'>include<\/span><\/li>\n  <li><span class='match'>increas<\/span>e<\/li>\n  <li><span class='match'>individ<\/span>ual<\/li>\n  <li><span class='match'>industr<\/span>y<\/li>\n  <li><span class='match'>instead<\/span><\/li>\n  <li><span class='match'>interes<\/span>t<\/li>\n  <li><span class='match'>introdu<\/span>ce<\/li>\n  <li><span class='match'>involve<\/span><\/li>\n  <li><span class='match'>kitchen<\/span><\/li>\n  <li><span class='match'>languag<\/span>e<\/li>\n  <li><span class='match'>machine<\/span><\/li>\n  <li><span class='match'>meaning<\/span><\/li>\n  <li><span class='match'>measure<\/span><\/li>\n  <li><span class='match'>mention<\/span><\/li>\n  <li><span class='match'>million<\/span><\/li>\n  <li><span class='match'>ministe<\/span>r<\/li>\n  <li><span class='match'>morning<\/span><\/li>\n  <li><span class='match'>necessa<\/span>ry<\/li>\n  <li><span class='match'>obvious<\/span><\/li>\n  <li><span class='match'>occasio<\/span>n<\/li>\n  <li><span class='match'>operate<\/span><\/li>\n  <li><span class='match'>opportu<\/span>nity<\/li>\n  <li><span class='match'>organiz<\/span>e<\/li>\n  <li><span class='match'>origina<\/span>l<\/li>\n  <li><span class='match'>otherwi<\/span>se<\/li>\n  <li><span class='match'>paragra<\/span>ph<\/li>\n  <li><span class='match'>particu<\/span>lar<\/li>\n  <li><span class='match'>pension<\/span><\/li>\n  <li><span class='match'>percent<\/span><\/li>\n  <li><span class='match'>perfect<\/span><\/li>\n  <li><span class='match'>perhaps<\/span><\/li>\n  <li><span class='match'>photogr<\/span>aph<\/li>\n  <li><span class='match'>picture<\/span><\/li>\n  <li><span class='match'>politic<\/span><\/li>\n  <li><span class='match'>positio<\/span>n<\/li>\n  <li><span class='match'>positiv<\/span>e<\/li>\n  <li><span class='match'>possibl<\/span>e<\/li>\n  <li><span class='match'>practis<\/span>e<\/li>\n  <li><span class='match'>prepare<\/span><\/li>\n  <li><span class='match'>present<\/span><\/li>\n  <li><span class='match'>pressur<\/span>e<\/li>\n  <li><span class='match'>presume<\/span><\/li>\n  <li><span class='match'>previou<\/span>s<\/li>\n  <li><span class='match'>private<\/span><\/li>\n  <li><span class='match'>probabl<\/span>e<\/li>\n  <li><span class='match'>problem<\/span><\/li>\n  <li><span class='match'>proceed<\/span><\/li>\n  <li><span class='match'>process<\/span><\/li>\n  <li><span class='match'>produce<\/span><\/li>\n  <li><span class='match'>product<\/span><\/li>\n  <li><span class='match'>program<\/span>me<\/li>\n  <li><span class='match'>project<\/span><\/li>\n  <li><span class='match'>propose<\/span><\/li>\n  <li><span class='match'>protect<\/span><\/li>\n  <li><span class='match'>provide<\/span><\/li>\n  <li><span class='match'>purpose<\/span><\/li>\n  <li><span class='match'>quality<\/span><\/li>\n  <li><span class='match'>quarter<\/span><\/li>\n  <li><span class='match'>questio<\/span>n<\/li>\n  <li><span class='match'>realise<\/span><\/li>\n  <li><span class='match'>receive<\/span><\/li>\n  <li><span class='match'>recogni<\/span>ze<\/li>\n  <li><span class='match'>recomme<\/span>nd<\/li>\n  <li><span class='match'>relatio<\/span>n<\/li>\n  <li><span class='match'>remembe<\/span>r<\/li>\n  <li><span class='match'>represe<\/span>nt<\/li>\n  <li><span class='match'>require<\/span><\/li>\n  <li><span class='match'>researc<\/span>h<\/li>\n  <li><span class='match'>resourc<\/span>e<\/li>\n  <li><span class='match'>respect<\/span><\/li>\n  <li><span class='match'>respons<\/span>ible<\/li>\n  <li><span class='match'>saturda<\/span>y<\/li>\n  <li><span class='match'>science<\/span><\/li>\n  <li><span class='match'>scotlan<\/span>d<\/li>\n  <li><span class='match'>secreta<\/span>ry<\/li>\n  <li><span class='match'>section<\/span><\/li>\n  <li><span class='match'>separat<\/span>e<\/li>\n  <li><span class='match'>serious<\/span><\/li>\n  <li><span class='match'>service<\/span><\/li>\n  <li><span class='match'>similar<\/span><\/li>\n  <li><span class='match'>situate<\/span><\/li>\n  <li><span class='match'>society<\/span><\/li>\n  <li><span class='match'>special<\/span><\/li>\n  <li><span class='match'>specifi<\/span>c<\/li>\n  <li><span class='match'>standar<\/span>d<\/li>\n  <li><span class='match'>station<\/span><\/li>\n  <li><span class='match'>straigh<\/span>t<\/li>\n  <li><span class='match'>strateg<\/span>y<\/li>\n  <li><span class='match'>structu<\/span>re<\/li>\n  <li><span class='match'>student<\/span><\/li>\n  <li><span class='match'>subject<\/span><\/li>\n  <li><span class='match'>succeed<\/span><\/li>\n  <li><span class='match'>suggest<\/span><\/li>\n  <li><span class='match'>support<\/span><\/li>\n  <li><span class='match'>suppose<\/span><\/li>\n  <li><span class='match'>surpris<\/span>e<\/li>\n  <li><span class='match'>telepho<\/span>ne<\/li>\n  <li><span class='match'>televis<\/span>ion<\/li>\n  <li><span class='match'>terribl<\/span>e<\/li>\n  <li><span class='match'>therefo<\/span>re<\/li>\n  <li><span class='match'>thirtee<\/span>n<\/li>\n  <li><span class='match'>thousan<\/span>d<\/li>\n  <li><span class='match'>through<\/span><\/li>\n  <li><span class='match'>thursda<\/span>y<\/li>\n  <li><span class='match'>togethe<\/span>r<\/li>\n  <li><span class='match'>tomorro<\/span>w<\/li>\n  <li><span class='match'>tonight<\/span><\/li>\n  <li><span class='match'>traffic<\/span><\/li>\n  <li><span class='match'>transpo<\/span>rt<\/li>\n  <li><span class='match'>trouble<\/span><\/li>\n  <li><span class='match'>tuesday<\/span><\/li>\n  <li><span class='match'>underst<\/span>and<\/li>\n  <li><span class='match'>univers<\/span>ity<\/li>\n  <li><span class='match'>various<\/span><\/li>\n  <li><span class='match'>village<\/span><\/li>\n  <li><span class='match'>wednesd<\/span>ay<\/li>\n  <li><span class='match'>welcome<\/span><\/li>\n  <li><span class='match'>whether<\/span><\/li>\n  <li><span class='match'>without<\/span><\/li>\n  <li><span class='match'>yesterd<\/span>ay<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
    
    Since the pattern `.......` is not anchored with either `.` or `$`
    this will match any word with at last seven letters.
    The pattern, `^.......$`, matches words with exactly seven characters.

</div>

### Character classes and alternatives {#character-classes-and-alternatives .r4ds-section}

#### Exercise 14.3.3.1 {.unnumbered .exercise data-number="14.3.3.1"}

<div class="question">

Create regular expressions to find all words that:

1.  Start with a vowel.
1.  That only contain consonants. (Hint: thinking about matching “not”-vowels.)
1.  End with `ed`, but not with `eed`.
1.  End with `ing` or `ise`.

</div>

<xdiv class="answer">

The answer to each part follows.

1.  Words starting with vowels

    
    ```r
    str_subset(stringr::words, "^[aeiou]")
    #>   [1] "a"           "able"        "about"       "absolute"    "accept"     
    #>   [6] "account"     "achieve"     "across"      "act"         "active"     
    #>  [11] "actual"      "add"         "address"     "admit"       "advertise"  
    #>  [16] "affect"      "afford"      "after"       "afternoon"   "again"      
    #>  [21] "against"     "age"         "agent"       "ago"         "agree"      
    #>  [26] "air"         "all"         "allow"       "almost"      "along"      
    #>  [31] "already"     "alright"     "also"        "although"    "always"     
    #>  [36] "america"     "amount"      "and"         "another"     "answer"     
    #>  [41] "any"         "apart"       "apparent"    "appear"      "apply"      
    #>  [46] "appoint"     "approach"    "appropriate" "area"        "argue"      
    #>  [51] "arm"         "around"      "arrange"     "art"         "as"         
    #>  [56] "ask"         "associate"   "assume"      "at"          "attend"     
    #>  [61] "authority"   "available"   "aware"       "away"        "awful"      
    #>  [66] "each"        "early"       "east"        "easy"        "eat"        
    #>  [71] "economy"     "educate"     "effect"      "egg"         "eight"      
    #>  [76] "either"      "elect"       "electric"    "eleven"      "else"       
    #>  [81] "employ"      "encourage"   "end"         "engine"      "english"    
    #>  [86] "enjoy"       "enough"      "enter"       "environment" "equal"      
    #>  [91] "especial"    "europe"      "even"        "evening"     "ever"       
    #>  [96] "every"       "evidence"    "exact"       "example"     "except"     
    #> [101] "excuse"      "exercise"    "exist"       "expect"      "expense"    
    #> [106] "experience"  "explain"     "express"     "extra"       "eye"        
    #> [111] "idea"        "identify"    "if"          "imagine"     "important"  
    #> [116] "improve"     "in"          "include"     "income"      "increase"   
    #> [121] "indeed"      "individual"  "industry"    "inform"      "inside"     
    #> [126] "instead"     "insure"      "interest"    "into"        "introduce"  
    #> [131] "invest"      "involve"     "issue"       "it"          "item"       
    #> [136] "obvious"     "occasion"    "odd"         "of"          "off"        
    #> [141] "offer"       "office"      "often"       "okay"        "old"        
    #> [146] "on"          "once"        "one"         "only"        "open"       
    #> [151] "operate"     "opportunity" "oppose"      "or"          "order"      
    #> [156] "organize"    "original"    "other"       "otherwise"   "ought"      
    #> [161] "out"         "over"        "own"         "under"       "understand" 
    #> [166] "union"       "unit"        "unite"       "university"  "unless"     
    #> [171] "until"       "up"          "upon"        "use"         "usual"
    ```

1.  Words that contain only consonants: Use the `negate`
    argument of `str_subset`.
    
    ```r
    str_subset(stringr::words, "[aeiou]", negate=TRUE)
    #> [1] "by"  "dry" "fly" "mrs" "try" "why"
    ```
    Alternatively, using `str_view()` the consonant-only
    words are:
    
    ```r
    str_view(stringr::words, "[aeiou]", match=FALSE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-5b1b2f4ad92281566982" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-5b1b2f4ad92281566982">{"x":{"html":"<ul>\n  <li>by<\/li>\n  <li>dry<\/li>\n  <li>fly<\/li>\n  <li>mrs<\/li>\n  <li>try<\/li>\n  <li>why<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

1.  Words that end with "-ed" but not ending in "-eed".

    
    ```r
    str_subset(stringr::words, "[^e]ed$")
    #> [1] "bed"     "hundred" "red"
    ```
    
    The pattern above will not match the word `"ed"`. If we wanted to include that, we could include it as a special case.
    
    
    ```r
    str_subset(c("ed", stringr::words), "(^|[^e])ed$")
    #> [1] "ed"      "bed"     "hundred" "red"
    ```

1.  Words ending in `ing` or `ise`:

    
    ```r
    str_subset(stringr::words, "i(ng|se)$")
    #>  [1] "advertise" "bring"     "during"    "evening"   "exercise"  "king"     
    #>  [7] "meaning"   "morning"   "otherwise" "practise"  "raise"     "realise"  
    #> [13] "ring"      "rise"      "sing"      "surprise"  "thing"
    ```

</div>

#### Exercise 14.3.3.2 {.unnumbered .exercise data-number="14.3.3.2"}

<div class="question">

Empirically verify the rule “i” before e except after “c”.

</div>

<div class="answer">


```r
length(str_subset(stringr::words, "(cei|[^c]ie)"))
#> [1] 14
```


```r
length(str_subset(stringr::words, "(cie|[^c]ei)"))
#> [1] 3
```

</div>

#### Exercise 14.3.3.3 {.unnumbered .exercise data-number="14.3.3.3"}

<div class="question">
Is “q” always followed by a “u”?
</div>

<div class="answer">

In the `stringr::words` dataset, yes.

```r
str_view(stringr::words, "q[^u]", match = TRUE)
```

<!--html_preserve--><div id="htmlwidget-5b1b2f4ad92281566982" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-5b1b2f4ad92281566982">{"x":{"html":"<ul>\n  <li><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

In the English language--- [no](https://en.wiktionary.org/wiki/Appendix:English_words_containing_Q_not_followed_by_U).
However, the examples are few, and mostly loanwords, such as "burqa" and "cinq".
Also, "qwerty".
That I had to add all of those examples to the list of words that spellchecking should ignore is indicative of their rarity.

</div>

#### Exercise 14.3.3.4 {.unnumbered .exercise data-number="14.3.3.4"}

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

There are other [spelling differences between American and British English](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences) but they are not patterns amenable to regular expressions.
It would require a dictionary with differences in spellings for different words.

</div>

#### Exercise 14.3.3.5 {.unnumbered .exercise data-number="14.3.3.5"}

<div class="question">
Create a regular expression that will match telephone numbers as commonly written in your country.
</div>

<div class="answer">

<div class="alert alert-primary hints-alert>
This answer can be improved and expanded.
</div>

The answer to this will vary by country.

<!-- grouping is not covered until 14.3.5 -->

For the United States, phone numbers have a format like `123-456-7890` or `(123)456-7890`).
These regular expressions will parse the first form

```r
x <- c("123-456-7890", "(123)456-7890", "(123) 456-7890", "1235-2351")
str_view(x, "\\d\\d\\d-\\d\\d\\d-\\d\\d\\d\\d")
```

<!--html_preserve--><div id="htmlwidget-25c3e940e6859592f801" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-25c3e940e6859592f801">{"x":{"html":"<ul>\n  <li><span class='match'>123-456-7890<\/span><\/li>\n  <li>(123)456-7890<\/li>\n  <li>(123) 456-7890<\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view(x, "[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]")
```

<!--html_preserve--><div id="htmlwidget-3f27c09be0c60bb52829" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-3f27c09be0c60bb52829">{"x":{"html":"<ul>\n  <li><span class='match'>123-456-7890<\/span><\/li>\n  <li>(123)456-7890<\/li>\n  <li>(123) 456-7890<\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
The regular expressions will parse the second form:

```r
str_view(x, "\\(\\d\\d\\d\\)\\s*\\d\\d\\d-\\d\\d\\d\\d")
```

<!--html_preserve--><div id="htmlwidget-416566eb193bf50d04e6" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-416566eb193bf50d04e6">{"x":{"html":"<ul>\n  <li>123-456-7890<\/li>\n  <li><span class='match'>(123)456-7890<\/span><\/li>\n  <li><span class='match'>(123) 456-7890<\/span><\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view(x, "\\([0-9][0-9][0-9]\\)[ ]*[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]")
```

<!--html_preserve--><div id="htmlwidget-72cbf064100ce560a04c" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-72cbf064100ce560a04c">{"x":{"html":"<ul>\n  <li>123-456-7890<\/li>\n  <li><span class='match'>(123)456-7890<\/span><\/li>\n  <li><span class='match'>(123) 456-7890<\/span><\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

This regular expression can be simplified with the `{m,n}` regular expression modifier introduced in the next section,

```r
str_view(x, "\\d{3}-\\d{3}-\\d{4}")
```

<!--html_preserve--><div id="htmlwidget-d11fc4360aa0230696d7" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-d11fc4360aa0230696d7">{"x":{"html":"<ul>\n  <li><span class='match'>123-456-7890<\/span><\/li>\n  <li>(123)456-7890<\/li>\n  <li>(123) 456-7890<\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view(x, "\\(\\d{3}\\)\\s*\\d{3}-\\d{4}")
```

<!--html_preserve--><div id="htmlwidget-21c7483268bafca56cec" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-21c7483268bafca56cec">{"x":{"html":"<ul>\n  <li>123-456-7890<\/li>\n  <li><span class='match'>(123)456-7890<\/span><\/li>\n  <li><span class='match'>(123) 456-7890<\/span><\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Note that this pattern doesn't account for phone numbers that are invalid
due to an invalid area code.
Nor does this pattern account for special numbers like 911.
It also doesn't  parse a leading country code or an extensions.
See the Wikipedia page for the [North American Numbering
Plan](https://en.wikipedia.org/wiki/North_American_Numbering_Plan) for more information on the complexities of US phone numbers, and [this Stack Overflow
question](https://stackoverflow.com/questions/123559/a-comprehensive-regex-for-phone-number-validation) for a discussion of using a regex for phone number validation.
The R package [dialr](https://cran.r-project.org/web/packages/dialr/index.html) implements robust phone number parsing.
Generally, for patterns like phone numbers or URLs it is better to use a dedicated package.
It is easy to match the pattern for the most common cases and useful for learning regular expressions, but in real applications there often edge cases that are handled by dedicated packages.

</div>

### Repetition {#repetition .r4ds-section}

#### Exercise 14.3.4.1 {.unnumbered .exercise data-number="14.3.4.1"}

<div class="question">
Describe the equivalents of `?`, `+`, `*` in `{m,n}` form.
</div>

<div class="answer">

| Pattern | `{m,n}` | Meaning           |
|---------|---------|-------------------|
| `?`     | `{0,1}` | Match at most 1   |
| `+`     | `{1,}`  | Match 1 or more   |
| `*`     | `{0,}`  | Match 0 or more   |

For example, let's repeat the examples in the chapter, replacing `?` with `{0,1}`, 
`+` with `{1,}`, and `*` with `{*,}`.

```r
x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
```

```r
str_view(x, "CC?")
```

<!--html_preserve--><div id="htmlwidget-1834a22cd196f3aa03a1" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-1834a22cd196f3aa03a1">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MD<span class='match'>CC<\/span>CLXXXVIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view(x, "CC{0,1}")
```

<!--html_preserve--><div id="htmlwidget-28515d92cb327f90c9eb" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-28515d92cb327f90c9eb">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MD<span class='match'>CC<\/span>CLXXXVIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


```r
str_view(x, "CC+")
```

<!--html_preserve--><div id="htmlwidget-0caf26d4e3c00206b0c5" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-0caf26d4e3c00206b0c5">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MD<span class='match'>CCC<\/span>LXXXVIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view(x, "CC{1,}")
```

<!--html_preserve--><div id="htmlwidget-da0b268a2927f570ebf3" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-da0b268a2927f570ebf3">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MD<span class='match'>CCC<\/span>LXXXVIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->


```r
str_view_all(x, "C[LX]+")
```

<!--html_preserve--><div id="htmlwidget-0ed12bb554391c49c2e3" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-0ed12bb554391c49c2e3">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MDCC<span class='match'>CLXXX<\/span>VIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view_all(x, "C[LX]{1,}")
```

<!--html_preserve--><div id="htmlwidget-ec658d41f8c4f2d124e9" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-ec658d41f8c4f2d124e9">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MDCC<span class='match'>CLXXX<\/span>VIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

The chapter does not contain an example of `*`.
This pattern looks for a "C" optionally followed by
any number of "L" or "X" characters.

```r
str_view_all(x, "C[LX]*")
```

<!--html_preserve--><div id="htmlwidget-6b83523733b890d61edc" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-6b83523733b890d61edc">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MD<span class='match'>C<\/span><span class='match'>C<\/span><span class='match'>CLXXX<\/span>VIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

```r
str_view_all(x, "C[LX]{0,}")
```

<!--html_preserve--><div id="htmlwidget-b3f7c917b6c8ff580948" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-b3f7c917b6c8ff580948">{"x":{"html":"<ul>\n  <li>1888 is the longest year in Roman numerals: MD<span class='match'>C<\/span><span class='match'>C<\/span><span class='match'>CLXXX<\/span>VIII<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

#### Exercise 14.3.4.2 {.unnumbered .exercise data-number="14.3.4.2"}

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

#### Exercise 14.3.4.3 {.unnumbered .exercise data-number="14.3.4.3"}

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
    str_view(words, "^[^aeiou]{3}", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-d258b2ee1c304ebe1664" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-d258b2ee1c304ebe1664">{"x":{"html":"<ul>\n  <li><span class='match'>Chr<\/span>ist<\/li>\n  <li><span class='match'>Chr<\/span>istmas<\/li>\n  <li><span class='match'>dry<\/span><\/li>\n  <li><span class='match'>fly<\/span><\/li>\n  <li><span class='match'>mrs<\/span><\/li>\n  <li><span class='match'>sch<\/span>eme<\/li>\n  <li><span class='match'>sch<\/span>ool<\/li>\n  <li><span class='match'>str<\/span>aight<\/li>\n  <li><span class='match'>str<\/span>ategy<\/li>\n  <li><span class='match'>str<\/span>eet<\/li>\n  <li><span class='match'>str<\/span>ike<\/li>\n  <li><span class='match'>str<\/span>ong<\/li>\n  <li><span class='match'>str<\/span>ucture<\/li>\n  <li><span class='match'>sys<\/span>tem<\/li>\n  <li><span class='match'>thr<\/span>ee<\/li>\n  <li><span class='match'>thr<\/span>ough<\/li>\n  <li><span class='match'>thr<\/span>ow<\/li>\n  <li><span class='match'>try<\/span><\/li>\n  <li><span class='match'>typ<\/span>e<\/li>\n  <li><span class='match'>why<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

1.  This regex finds three or more vowels in a row:

    
    ```r
    str_view(words, "[aeiou]{3,}", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-b8f31ebacaee3527bb86" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-b8f31ebacaee3527bb86">{"x":{"html":"<ul>\n  <li>b<span class='match'>eau<\/span>ty<\/li>\n  <li>obv<span class='match'>iou<\/span>s<\/li>\n  <li>prev<span class='match'>iou<\/span>s<\/li>\n  <li>q<span class='match'>uie<\/span>t<\/li>\n  <li>ser<span class='match'>iou<\/span>s<\/li>\n  <li>var<span class='match'>iou<\/span>s<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

1.  This regex finds two or more vowel-consonant pairs in a row.

    
    ```r
    str_view(words, "([aeiou][^aeiou]){2,}", match = TRUE)
    ```
    
    <!--html_preserve--><div id="htmlwidget-b25b670b028f478bf741" style="width:960px;height:100%;" class="str_view html-widget"></div>
    <script type="application/json" data-for="htmlwidget-b25b670b028f478bf741">{"x":{"html":"<ul>\n  <li>abs<span class='match'>olut<\/span>e<\/li>\n  <li><span class='match'>agen<\/span>t<\/li>\n  <li><span class='match'>alon<\/span>g<\/li>\n  <li><span class='match'>americ<\/span>a<\/li>\n  <li><span class='match'>anot<\/span>her<\/li>\n  <li><span class='match'>apar<\/span>t<\/li>\n  <li>app<span class='match'>aren<\/span>t<\/li>\n  <li>auth<span class='match'>orit<\/span>y<\/li>\n  <li>ava<span class='match'>ilab<\/span>le<\/li>\n  <li><span class='match'>awar<\/span>e<\/li>\n  <li><span class='match'>away<\/span><\/li>\n  <li>b<span class='match'>alan<\/span>ce<\/li>\n  <li>b<span class='match'>asis<\/span><\/li>\n  <li>b<span class='match'>ecom<\/span>e<\/li>\n  <li>b<span class='match'>efor<\/span>e<\/li>\n  <li>b<span class='match'>egin<\/span><\/li>\n  <li>b<span class='match'>ehin<\/span>d<\/li>\n  <li>b<span class='match'>enefit<\/span><\/li>\n  <li>b<span class='match'>usines<\/span>s<\/li>\n  <li>ch<span class='match'>arac<\/span>ter<\/li>\n  <li>cl<span class='match'>oses<\/span><\/li>\n  <li>comm<span class='match'>unit<\/span>y<\/li>\n  <li>cons<span class='match'>ider<\/span><\/li>\n  <li>c<span class='match'>over<\/span><\/li>\n  <li>d<span class='match'>ebat<\/span>e<\/li>\n  <li>d<span class='match'>ecid<\/span>e<\/li>\n  <li>d<span class='match'>ecis<\/span>ion<\/li>\n  <li>d<span class='match'>efinit<\/span>e<\/li>\n  <li>d<span class='match'>epar<\/span>tment<\/li>\n  <li>d<span class='match'>epen<\/span>d<\/li>\n  <li>d<span class='match'>esig<\/span>n<\/li>\n  <li>d<span class='match'>evelop<\/span><\/li>\n  <li>diff<span class='match'>eren<\/span>ce<\/li>\n  <li>diff<span class='match'>icul<\/span>t<\/li>\n  <li>d<span class='match'>irec<\/span>t<\/li>\n  <li>d<span class='match'>ivid<\/span>e<\/li>\n  <li>d<span class='match'>ocumen<\/span>t<\/li>\n  <li>d<span class='match'>urin<\/span>g<\/li>\n  <li><span class='match'>econom<\/span>y<\/li>\n  <li><span class='match'>educat<\/span>e<\/li>\n  <li><span class='match'>elec<\/span>t<\/li>\n  <li><span class='match'>elec<\/span>tric<\/li>\n  <li><span class='match'>eleven<\/span><\/li>\n  <li>enco<span class='match'>urag<\/span>e<\/li>\n  <li>env<span class='match'>iron<\/span>ment<\/li>\n  <li>e<span class='match'>urop<\/span>e<\/li>\n  <li><span class='match'>even<\/span><\/li>\n  <li><span class='match'>evenin<\/span>g<\/li>\n  <li><span class='match'>ever<\/span><\/li>\n  <li><span class='match'>ever<\/span>y<\/li>\n  <li><span class='match'>eviden<\/span>ce<\/li>\n  <li><span class='match'>exac<\/span>t<\/li>\n  <li><span class='match'>exam<\/span>ple<\/li>\n  <li><span class='match'>exer<\/span>cise<\/li>\n  <li><span class='match'>exis<\/span>t<\/li>\n  <li>f<span class='match'>amil<\/span>y<\/li>\n  <li>f<span class='match'>igur<\/span>e<\/li>\n  <li>f<span class='match'>inal<\/span><\/li>\n  <li>f<span class='match'>inan<\/span>ce<\/li>\n  <li>f<span class='match'>inis<\/span>h<\/li>\n  <li>fr<span class='match'>iday<\/span><\/li>\n  <li>f<span class='match'>utur<\/span>e<\/li>\n  <li>g<span class='match'>eneral<\/span><\/li>\n  <li>g<span class='match'>over<\/span>n<\/li>\n  <li>h<span class='match'>oliday<\/span><\/li>\n  <li>h<span class='match'>ones<\/span>t<\/li>\n  <li>hosp<span class='match'>ital<\/span><\/li>\n  <li>h<span class='match'>owever<\/span><\/li>\n  <li><span class='match'>iden<\/span>tify<\/li>\n  <li><span class='match'>imagin<\/span>e<\/li>\n  <li>ind<span class='match'>ivid<\/span>ual<\/li>\n  <li>int<span class='match'>eres<\/span>t<\/li>\n  <li>intr<span class='match'>oduc<\/span>e<\/li>\n  <li><span class='match'>item<\/span><\/li>\n  <li>j<span class='match'>esus<\/span><\/li>\n  <li>l<span class='match'>evel<\/span><\/li>\n  <li>l<span class='match'>ikel<\/span>y<\/li>\n  <li>l<span class='match'>imit<\/span><\/li>\n  <li>l<span class='match'>ocal<\/span><\/li>\n  <li>m<span class='match'>ajor<\/span><\/li>\n  <li>m<span class='match'>anag<\/span>e<\/li>\n  <li>me<span class='match'>anin<\/span>g<\/li>\n  <li>me<span class='match'>asur<\/span>e<\/li>\n  <li>m<span class='match'>inis<\/span>ter<\/li>\n  <li>m<span class='match'>inus<\/span><\/li>\n  <li>m<span class='match'>inut<\/span>e<\/li>\n  <li>m<span class='match'>omen<\/span>t<\/li>\n  <li>m<span class='match'>oney<\/span><\/li>\n  <li>m<span class='match'>usic<\/span><\/li>\n  <li>n<span class='match'>atur<\/span>e<\/li>\n  <li>n<span class='match'>eces<\/span>sary<\/li>\n  <li>n<span class='match'>ever<\/span><\/li>\n  <li>n<span class='match'>otic<\/span>e<\/li>\n  <li><span class='match'>okay<\/span><\/li>\n  <li><span class='match'>open<\/span><\/li>\n  <li><span class='match'>operat<\/span>e<\/li>\n  <li>opport<span class='match'>unit<\/span>y<\/li>\n  <li>org<span class='match'>aniz<\/span>e<\/li>\n  <li><span class='match'>original<\/span><\/li>\n  <li><span class='match'>over<\/span><\/li>\n  <li>p<span class='match'>aper<\/span><\/li>\n  <li>p<span class='match'>arag<\/span>raph<\/li>\n  <li>p<span class='match'>aren<\/span>t<\/li>\n  <li>part<span class='match'>icular<\/span><\/li>\n  <li>ph<span class='match'>otog<\/span>raph<\/li>\n  <li>p<span class='match'>olic<\/span>e<\/li>\n  <li>p<span class='match'>olic<\/span>y<\/li>\n  <li>p<span class='match'>olitic<\/span><\/li>\n  <li>p<span class='match'>osit<\/span>ion<\/li>\n  <li>p<span class='match'>ositiv<\/span>e<\/li>\n  <li>p<span class='match'>ower<\/span><\/li>\n  <li>pr<span class='match'>epar<\/span>e<\/li>\n  <li>pr<span class='match'>esen<\/span>t<\/li>\n  <li>pr<span class='match'>esum<\/span>e<\/li>\n  <li>pr<span class='match'>ivat<\/span>e<\/li>\n  <li>pr<span class='match'>obab<\/span>le<\/li>\n  <li>pr<span class='match'>oces<\/span>s<\/li>\n  <li>pr<span class='match'>oduc<\/span>e<\/li>\n  <li>pr<span class='match'>oduc<\/span>t<\/li>\n  <li>pr<span class='match'>ojec<\/span>t<\/li>\n  <li>pr<span class='match'>oper<\/span><\/li>\n  <li>pr<span class='match'>opos<\/span>e<\/li>\n  <li>pr<span class='match'>otec<\/span>t<\/li>\n  <li>pr<span class='match'>ovid<\/span>e<\/li>\n  <li>qu<span class='match'>alit<\/span>y<\/li>\n  <li>re<span class='match'>alis<\/span>e<\/li>\n  <li>re<span class='match'>ason<\/span><\/li>\n  <li>r<span class='match'>ecen<\/span>t<\/li>\n  <li>r<span class='match'>ecog<\/span>nize<\/li>\n  <li>r<span class='match'>ecom<\/span>mend<\/li>\n  <li>r<span class='match'>ecor<\/span>d<\/li>\n  <li>r<span class='match'>educ<\/span>e<\/li>\n  <li>r<span class='match'>efer<\/span><\/li>\n  <li>r<span class='match'>egar<\/span>d<\/li>\n  <li>r<span class='match'>elat<\/span>ion<\/li>\n  <li>r<span class='match'>emem<\/span>ber<\/li>\n  <li>r<span class='match'>epor<\/span>t<\/li>\n  <li>repr<span class='match'>esen<\/span>t<\/li>\n  <li>r<span class='match'>esul<\/span>t<\/li>\n  <li>r<span class='match'>etur<\/span>n<\/li>\n  <li>s<span class='match'>atur<\/span>day<\/li>\n  <li>s<span class='match'>econ<\/span>d<\/li>\n  <li>secr<span class='match'>etar<\/span>y<\/li>\n  <li>s<span class='match'>ecur<\/span>e<\/li>\n  <li>s<span class='match'>eparat<\/span>e<\/li>\n  <li>s<span class='match'>even<\/span><\/li>\n  <li>s<span class='match'>imilar<\/span><\/li>\n  <li>sp<span class='match'>ecific<\/span><\/li>\n  <li>str<span class='match'>ateg<\/span>y<\/li>\n  <li>st<span class='match'>uden<\/span>t<\/li>\n  <li>st<span class='match'>upid<\/span><\/li>\n  <li>t<span class='match'>elep<\/span>hone<\/li>\n  <li>t<span class='match'>elevis<\/span>ion<\/li>\n  <li>th<span class='match'>erefor<\/span>e<\/li>\n  <li>tho<span class='match'>usan<\/span>d<\/li>\n  <li>t<span class='match'>oday<\/span><\/li>\n  <li>t<span class='match'>oget<\/span>her<\/li>\n  <li>t<span class='match'>omor<\/span>row<\/li>\n  <li>t<span class='match'>onig<\/span>ht<\/li>\n  <li>t<span class='match'>otal<\/span><\/li>\n  <li>t<span class='match'>owar<\/span>d<\/li>\n  <li>tr<span class='match'>avel<\/span><\/li>\n  <li><span class='match'>unit<\/span><\/li>\n  <li><span class='match'>unit<\/span>e<\/li>\n  <li><span class='match'>univer<\/span>sity<\/li>\n  <li><span class='match'>upon<\/span><\/li>\n  <li>v<span class='match'>isit<\/span><\/li>\n  <li>w<span class='match'>ater<\/span><\/li>\n  <li>w<span class='match'>oman<\/span><\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

#### Exercise 14.3.4.4 {.unnumbered .exercise data-number="14.3.4.4"}

<div class="question">

Solve the beginner regexp crosswords at <https://regexcrossword.com/challenges/>

</div>

<div class="answer">

Exercise left to reader. That site validates its solutions, so they aren't repeated here.

</div>

### Grouping and backreferences {#grouping-and-backreferences .r4ds-section}

#### Exercise 14.3.5.1 {.unnumbered .exercise data-number="14.3.5.1"}

<div class="question">
Describe, in words, what these expressions will match:

1.  `(.)\1\1` :
1.  `"(.)(.)\\2\\1"`:
1.  `(..)\1`: 
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

#### Exercise 14.3.5.2 {.unnumbered .exercise data-number="14.3.5.2"}

<div class="question">
Construct regular expressions to match words that:

1.  Start and end with the same character.
1.  Contain a repeated pair of letters (e.g. ``church'' contains ``ch'' repeated twice.)
1.  Contain one letter repeated in at least three places (e.g. ``eleven'' contains three ``e''s.)

</div>

<div class="answer">

The answer to each part follows.

<!-- Use str_subset because I just want to pull words out -->

1.  This regular expression matches words that start and end with the same character.

    
    ```r
    str_subset(words, "^(.)((.*\\1$)|\\1?$)")
    #>  [1] "a"          "america"    "area"       "dad"        "dead"      
    #>  [6] "depend"     "educate"    "else"       "encourage"  "engine"    
    #> [11] "europe"     "evidence"   "example"    "excuse"     "exercise"  
    #> [16] "expense"    "experience" "eye"        "health"     "high"      
    #> [21] "knock"      "level"      "local"      "nation"     "non"       
    #> [26] "rather"     "refer"      "remember"   "serious"    "stairs"    
    #> [31] "test"       "tonight"    "transport"  "treat"      "trust"     
    #> [36] "window"     "yesterday"
    ```

1.  This regular expression will match any pair of repeated letters, where *letters* is defined to be the ASCII letters A-Z.
    First, check that it works with the example in the problem.
    
    ```r
    str_subset("church", "([A-Za-z][A-Za-z]).*\\1")
    #> [1] "church"
    ```
    Now, find all matching words in `words`.
    
    ```r
    str_subset(words, "([A-Za-z][A-Za-z]).*\\1")
    #>  [1] "appropriate" "church"      "condition"   "decide"      "environment"
    #>  [6] "london"      "paragraph"   "particular"  "photograph"  "prepare"    
    #> [11] "pressure"    "remember"    "represent"   "require"     "sense"      
    #> [16] "therefore"   "understand"  "whether"
    ```

    The `\\1` pattern is called a backreference. It matches whatever the first group
    matched. This allows the pattern to match a repeating pair of letters without having
    to specify exactly what pair letters is being repeated.

    Note that these patterns are case sensitive. Use the
    case insensitive flag if you want to check for repeated pairs
    of letters with different capitalization.

1.  This regex matches words that contain one letter repeated in at least three places.
    First, check that it works with th example given in the question.
    
    ```r
    str_subset("eleven", "([a-z]).*\\1.*\\1")
    #> [1] "eleven"
    ```
    Now, retrieve the matching words in `words`.
    
    ```r
    str_subset(words, "([a-z]).*\\1.*\\1")
    #>  [1] "appropriate" "available"   "believe"     "between"     "business"   
    #>  [6] "degree"      "difference"  "discuss"     "eleven"      "environment"
    #> [11] "evidence"    "exercise"    "expense"     "experience"  "individual" 
    #> [16] "paragraph"   "receive"     "remember"    "represent"   "telephone"  
    #> [21] "therefore"   "tomorrow"
    ```

</div>

## Tools {#tools .r4ds-section}

### Detect matches {#detect-matches .r4ds-section}

#### Exercise 14.4.1.1 {.unnumbered .exercise data-number="14.4.1.1"}

<div class="question">

For each of the following challenges, try solving it by using both a single regular expression, and a combination of multiple `str_detect()` calls.

1.  Find all words that start or end with x.
1.  Find all words that start with a vowel and end with a consonant.
1.  Are there any words that contain at least one of each different vowel?

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
      cross(rerun(5, c("a", "e", "i", "o", "u")),
        .filter = function(...) {
          x <- as.character(unlist(list(...)))
          length(x) != length(unique(x))
        }
      ) %>%
      map_chr(~str_c(unlist(.x), collapse = ".*")) %>%
      str_c(collapse = "|")
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

</div>

#### Exercise 14.4.1.2 {.unnumbered .exercise data-number="14.4.1.2"}

<div class="question">
  
What word has the higher number of vowels? What word has the highest proportion of vowels? (Hint: what is the denominator?)

</div>

<div class="answer">
  
The word with the highest number of vowels is
    

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

### Extract matches {#extract-matches .r4ds-section}

#### Exercise 14.4.2.1 {.unnumbered .exercise data-number="14.4.2.1"}

<div class="question">

In the previous example, you might have noticed that the regular expression matched “flickered”, which is not a color. 
Modify the regex to fix the problem.

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

<!--html_preserve--><div id="htmlwidget-46d1193f7ba074d981c8" style="width:960px;height:100%;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-46d1193f7ba074d981c8">{"x":{"html":"<ul>\n  <li>It is hard to erase <span class='match'>blue<\/span> or <span class='match'>red<\/span> ink.<\/li>\n  <li>The <span class='match'>green<\/span> light in the brown box flickered.<\/li>\n  <li>The sky in the west is tinged with <span class='match'>orange<\/span> <span class='match'>red<\/span>.<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

</div>

#### Exercise 14.4.2.2 {.unnumbered .exercise data-number="14.4.2.2"}

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
    Since `str_extract()` will extract the first match, if it is provided a 
    regular expression for words, it will return the first word.

    
    ```r
    str_extract(sentences, "[A-ZAa-z]+") %>% head()
    #> [1] "The"   "Glue"  "It"    "These" "Rice"  "The"
    ```
    
    However, the third sentence begins with "It's". To catch this, I'll 
    change the regular expression to require the string to begin with a letter,
    but allow for a subsequent apostrophe.
    
    
    ```r
    str_extract(sentences, "[A-Za-z][A-Za-z']*") %>% head()
    #> [1] "The"   "Glue"  "It's"  "These" "Rice"  "The"
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

### Grouped matches {#grouped-matches .r4ds-section}

#### Exercise 14.4.3.1 {.unnumbered .exercise data-number="14.4.3.1"}

<div class="question">

Find all words that come after a “number” like “one”, “two”, “three” etc. 
Pull out both the number and the word.

</div>

<div class="answer">


```r
numword <- "\\b(one|two|three|four|five|six|seven|eight|nine|ten) +(\\w+)"
sentences[str_detect(sentences, numword)] %>%
  str_extract(numword)
#>  [1] "seven books"   "two met"       "two factors"   "three lists"  
#>  [5] "seven is"      "two when"      "ten inches"    "one war"      
#>  [9] "one button"    "six minutes"   "ten years"     "two shares"   
#> [13] "two distinct"  "five cents"    "two pins"      "five robins"  
#> [17] "four kinds"    "three story"   "three inches"  "six comes"    
#> [21] "three batches" "two leaves"
```

</div>

#### Exercise 14.4.3.2 {.unnumbered .exercise data-number="14.4.3.2"}

<div class="question">

Find all contractions.
Separate out the pieces before and after the apostrophe.

</div>

<div class="answer">

This is done in two steps. First, identify the contractions. Second, split the string on the contraction.


```r
contraction <- "([A-Za-z]+)'([A-Za-z]+)"
sentences[str_detect(sentences, contraction)] %>%
  str_extract(contraction) %>%
  str_split("'")
#> [[1]]
#> [1] "It" "s" 
#> 
#> [[2]]
#> [1] "man" "s"  
#> 
#> [[3]]
#> [1] "don" "t"  
#> 
#> [[4]]
#> [1] "store" "s"    
#> 
#> [[5]]
#> [1] "workmen" "s"      
#> 
#> [[6]]
#> [1] "Let" "s"  
#> 
#> [[7]]
#> [1] "sun" "s"  
#> 
#> [[8]]
#> [1] "child" "s"    
#> 
#> [[9]]
#> [1] "king" "s"   
#> 
#> [[10]]
#> [1] "It" "s" 
#> 
#> [[11]]
#> [1] "don" "t"  
#> 
#> [[12]]
#> [1] "queen" "s"    
#> 
#> [[13]]
#> [1] "don" "t"  
#> 
#> [[14]]
#> [1] "pirate" "s"     
#> 
#> [[15]]
#> [1] "neighbor" "s"
```

</div>

### Replacing matches {#replacing-matches .r4ds-section}

#### Exercise 14.4.4.1 {.unnumbered .exercise data-number="14.4.4.1"}

<div class="question">
Replace all forward slashes in a string with backslashes.
</div>

<div class="answer">


```r
str_replace_all("past/present/future", "/", "\\\\")
#> [1] "past\\present\\future"
```

</div>

#### Exercise 14.4.4.2 {.unnumbered .exercise data-number="14.4.4.2"}

<div class="question">
Implement a simple version of `str_to_lower()` using `replace_all()`.
</div>

<div class="answer">

```r
replacements <- c("A" = "a", "B" = "b", "C" = "c", "D" = "d", "E" = "e",
                  "F" = "f", "G" = "g", "H" = "h", "I" = "i", "J" = "j", 
                  "K" = "k", "L" = "l", "M" = "m", "N" = "n", "O" = "o", 
                  "P" = "p", "Q" = "q", "R" = "r", "S" = "s", "T" = "t", 
                  "U" = "u", "V" = "v", "W" = "w", "X" = "x", "Y" = "y", 
                  "Z" = "z")
lower_words <- str_replace_all(words, pattern = replacements)
head(lower_words)
#> [1] "a"        "able"     "about"    "absolute" "accept"   "account"
```

</div>

#### Exercise 14.4.4.3 {.unnumbered .exercise data-number="14.4.4.3"}

<div class="question">
Switch the first and last letters in `words`. Which of those strings are still words?
</div>

<div class="answer">

First, make a vector of all the words with first and last letters swapped,

```r
swapped <- str_replace_all(words, "^([A-Za-z])(.*)([A-Za-z])$", "\\3\\2\\1")
```
Next, find what of "swapped" is also in the original list using the function `intersect()`,

```r
intersect(swapped, words)
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

Alternatively, the regex can be written using the POSIX character class for letter (`[[:alpha:]]`):

```r
swapped2 <- str_replace_all(words, "^([[:alpha:]])(.*)([[:alpha:]])$", "\\3\\2\\1")
intersect(swapped2, words)
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

### Splitting {#splitting .r4ds-section}

#### Exercise 14.4.5.1 {.unnumbered .exercise data-number="14.4.5.1"}

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

#### Exercise 14.4.5.2 {.unnumbered .exercise data-number="14.4.5.2"}

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

#### Exercise 14.4.5.3 {.unnumbered .exercise data-number="14.4.5.3"}

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

### Find matches {#find-matches .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

## Other types of pattern {#other-types-of-pattern .r4ds-section}

### Exercise 14.5.1 {.unnumbered .exercise data-number="14.5.1"}

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

### Exercise 14.5.2 {.unnumbered .exercise data-number="14.5.2"}

<div class="question">

What are the five most common words in `sentences`?

</div>

<div class="answer">

Using `str_extract_all()` with the argument `boundary("word")` will extract all words.
The rest of the code uses dplyr functions to count words and find the most
common words.

```r
tibble(word = unlist(str_extract_all(sentences, boundary("word")))) %>%
  mutate(word = str_to_lower(word)) %>%
  count(word, sort = TRUE) %>%
  head(5)
#> # A tibble: 5 x 2
#>   word      n
#>   <chr> <int>
#> 1 the     751
#> 2 a       202
#> 3 of      132
#> 4 to      123
#> 5 and     118
```

</div>

## Other uses of regular expressions {#other-uses-of-regular-expressions .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

## stringi {#stringi .r4ds-section}


```r
library("stringi")
```

### Exercise 14.7.1 {.unnumbered .exercise data-number="14.7.1"}

<div class="question">

Find the stringi functions that:

1.  Count the number of words.
1.  Find duplicated strings.
1.  Generate random text.

</div>

<div class="answer">

The answer to each part follows.

1.  To count the number of words use `stringi::stri_count_words()`.
    This code counts the words in the first five sentences of `sentences`.
    
    ```r
    stri_count_words(head(sentences))
    #> [1] 8 8 9 9 7 7
    ```

1.  The `stringi::stri_duplicated()` function finds duplicate strings.
    
    ```r
    stri_duplicated(c("the", "brown", "cow", "jumped", "over",
                               "the", "lazy", "fox"))
    #> [1] FALSE FALSE FALSE FALSE FALSE  TRUE FALSE FALSE
    ```

1.  The *stringi* package contains several functions beginning with `stri_rand_*` that generate random text.
    The function `stringi::stri_rand_strings()` generates random strings.
    The following code generates four random strings each of length five.
    
    ```r
    stri_rand_strings(4, 5)
    #> [1] "5pb90" "SUHjl" "sA2JO" "CP3Oy"
    ```
    
    The function `stringi::stri_rand_shuffle()` randomly shuffles the characters in the text.
    
    ```r
    stri_rand_shuffle("The brown fox jumped over the lazy cow.")
    #> [1] "ot f.lween p   jzwoom xyucobhv daheerrT"
    ```
    
    The function `stringi::stri_rand_lipsum()` generates [lorem ipsum](https://en.wikipedia.org/wiki/Lorem_ipsum) text.
    Lorem ipsum text is nonsense text often used as placeholder text in publishing.
    The following code generates one paragraph of placeholder text.
    
    ```r
    stri_rand_lipsum(1)
    #> [1] "Lorem ipsum dolor sit amet, hac non metus cras nam vitae tempus proin, sed. Diam gravida viverra eros mauris, magna lacinia dui nullam. Arcu proin aenean fringilla sed sollicitudin hac neque, egestas condimentum massa, elementum vivamus. Odio eget litora molestie eget eros pulvinar ac. Vel nec nullam vivamus, sociosqu lectus varius eleifend. Vitae in. Conubia ut hac maximus amet, conubia sed. Volutpat vitae class cursus, elit mauris porta. Mauris lacus donec odio eget quam inceptos, ridiculus cursus, ad massa. Rhoncus hac aenean at id consectetur molestie vitae! Sed, primis mi dictum lacinia eros. Ligula, feugiat consequat ut vivamus ut morbi et. Dolor, eget eleifend nec magnis aliquam egestas. Sollicitudin venenatis et aptent rhoncus nisl platea ligula cum."
    ```

</div>

### Exercise 14.7.2 {.unnumbered .exercise data-number="14.7.2"}

<div class="question">

How do you control the language that `stri_sort()` uses for sorting?

</div>

<div class="answer">

You can set a locale to use when sorting with either `stri_sort(..., opts_collator=stri_opts_collator(locale = ...))` or `stri_sort(..., locale = ...)`.
In this example from the `stri_sort()` documentation, the sorted order of the character vector depends on the locale.

```r
string1 <- c("hladny", "chladny")
stri_sort(string1, locale = "pl_PL")
#> [1] "chladny" "hladny"
stri_sort(string1, locale = "sk_SK")
#> [1] "hladny"  "chladny"
```

The output of `stri_opts_collator()` can also be used for the `locale` argument of `str_sort`.

```r
stri_sort(string1, opts_collator = stri_opts_collator(locale = "pl_PL"))
#> [1] "chladny" "hladny"
stri_sort(string1, opts_collator = stri_opts_collator(locale = "sk_SK"))
#> [1] "hladny"  "chladny"
```
The `stri_opts_collator()` provides finer grained control over how strings are sorted.
In addition to setting the locale, it has options to customize how cases, unicode, accents, and numeric values are handled when comparing strings.

```r
string2 <- c("number100", "number2")
stri_sort(string2)
#> [1] "number100" "number2"
stri_sort(string2, opts_collator = stri_opts_collator(numeric = TRUE))
#> [1] "number2"   "number100"
```

</div>
