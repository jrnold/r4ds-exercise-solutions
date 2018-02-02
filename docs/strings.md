
# Strings

## Introduction


```r
library(tidyverse)
library(stringr)
```

## String Basics


1. In code that doesn’t use **stringr**, you’ll often see `paste()` and `paste0()`. What’s the difference between the two functions? What **stringr** function are they equivalent to? How do the functions differ in their handling of NA?

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

2. In your own words, describe the difference between the `sep` and `collapse` arguments to `str_c()`.

The `sep` argument is the string inserted between arguments to `str_c`, while `collapse` is the string used to separate any elements of the character vector into a character vector of length one.

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

1. Explain why each of these strings don’t match a `\`: `"\"`, `"\\"`, `"\\\"`.

- `"\"`: This will escape the next character in the R string.
- `"\\"`: This will resolve to `\` in the regular expression, which will escape the next character in the regular expression.
- `"\\\"`: The first two backslashes will resolve to a literal backslash in the regular expression, the third will escape the next character. So in the regular expression, this will escape some escaped character.

2. How would you match the sequence `"'\` ?



3. What patterns will the regular expression `\..\..\..` match? How would you represent it as a string?

It will match any patterns that are a dot followed by any character, repeated three times.











### Anchors

1. How would you match the literal string "$^$"?


```r
str_view(c("$^$", "ab$^$sfas"), "^\\$\\^\\$$")
```

<!--html_preserve--><div id="htmlwidget-d34691559831f28a8b47" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-d34691559831f28a8b47">{"x":{"html":"<ul>\n  <li><span class='match'>$^$<\/span><\/li>\n  <li>ab$^$sfas<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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




### Character classes and alternatives

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

Words ending in `ing` or `ise`:

```r
str_view(stringr::words, "i(ng|se)$", match = TRUE)
```

2. Empirically verify the rule ``i before e except after c''.

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
#> [1] 14
sum(str_detect(stringr::words, "(cie|[^c]ei)"))
#> [1] 3
```

3. Is ``q'' always followed by a ``u''?

In the `stringr::words` dataset, yes. In the full English language, no.

```r
str_view(stringr::words, "q[^u]", match = TRUE)
```

4. Write a regular expression that matches a word if it’s probably written in British English, not American English.

In the general case, this is hard, and could require a dictionary.
But, there are a few heuristics to consider that would account for some common cases: British English tends to use the following:

- "ou" instead of "o"
- use of "ae" and "oe" instead of "a" and "o"
- ends in `ise` instead of `ize`
- ends in `yse`

The regex `ou|ise^|ae|oe|yse^` would match these.

There are other [spelling differences between American and British English] (https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences) but they are not patterns amenable to regular expressions.
It would require a dictionary with differences in spellings for different words.

5. Create a regular expression that will match telephone numbers as commonly written in your country.

The answer to this will vary by country.

For the United States, phone numbers have a format like `123-456-7890`.

```r
x <- c("123-456-7890", "1235-2351")
str_view(x, "\\d\\d\\d-\\d\\d\\d-\\d\\d\\d\\d")
```

<!--html_preserve--><div id="htmlwidget-f3525ce3d319e7c562ff" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-f3525ce3d319e7c562ff">{"x":{"html":"<ul>\n  <li><span class='match'>123-456-7890<\/span><\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->
or 

```r
str_view(x, "[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]")
```

<!--html_preserve--><div id="htmlwidget-59f2370825da36350af1" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-59f2370825da36350af1">{"x":{"html":"<ul>\n  <li>123-456-7890<\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

This regular expression can be simplified with the `{m,n}` regular expression modifier introduced in the next section,

```r
str_view(x, "\\d{3}-\\d{3}-\\d{4}")
```

<!--html_preserve--><div id="htmlwidget-3ec749e04bfb96c2d6c3" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-3ec749e04bfb96c2d6c3">{"x":{"html":"<ul>\n  <li><span class='match'>123-456-7890<\/span><\/li>\n  <li>1235-2351<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Note that this pattern doesn't account for phone numbers that are invalid because of unassigned area code, or special numbers like 911, or extensions. See the Wikipedia page for the [North American Numbering Plan](https://en.wikipedia.org/wiki/North_American_Numbering_Plan) for more information on the complexities of US phone numbers, and [this Stack Overflow question](http://stackoverflow.com/questions/123559/a-comprehensive-regex-for-phone-number-validation) for a discussion of using a regex for phone number validation.


### Repetition

1. Describe the equivalents of `?`, `+`, `*` in `{m,n}` form.

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


2. Describe in words what these regular expressions match: (read carefully to see if I’m using a regular expression or a string that defines a regular expression.)

    1. `^.*$`
    2. `"\\{.+\\}"`: Any string with curly braces surrounding at least one   character.
    3. `\d{4}-\d{2}-\d{2}`: A date in "%Y-%m-%d" format: four digits followed by a dash, followed by two digits followed by a dash, followed by another two digits followed by a dash.
    4. `"\\\\{4}"`: This resolves to the regular expression `\\{4}`, which is four backslashes.


-------------------- ---------------------------------------------------------------------------------------------------------------------------------------------------- 
`^.*$`               Any string
`"\\{.+\\}"`         Any string with curly braces surrounding at least one character.
`\d{4}-\d{2}-\d{2}`  Four digits followed by a hyphen, followed by two digits followed by a hypen, followed by another two digits. This is a regular expression that can match dates formatted a YYYY-MM-DD ("%Y-%m-%d").
 `"\\\\{4}"`         This resolves to the regular expression `\\{4}`, which is four backslashes.
 
Examples:

- `^.*$`: `c("dog", "$1.23", "lorem ipsum")`
- `"\\{.+\\}"`: `c("{a}", "{abc}")`
- `\d{4}-\d{2}-\d{2}`: `2018-01-11`
- `"\\\\{4}"`: `"\\\\\\\\"` (Backslashes in an R character vector need to be escaped.)

3. Create regular expressions to find all words that:

  1. Start with three consonants. 
  2. Have three or more vowels in a row.
  3. Have two or more vowel-consonant pairs in a row.
  
A regex to find all words starting with three consonants

```r
str_view(words, "^[^aeiou]{3}")
```

<!--html_preserve--><div id="htmlwidget-6a2314a79aa854fab7df" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-6a2314a79aa854fab7df">{"x":{"html":"<ul>\n  <li>a<\/li>\n  <li>able<\/li>\n  <li>about<\/li>\n  <li>absolute<\/li>\n  <li>accept<\/li>\n  <li>account<\/li>\n  <li>achieve<\/li>\n  <li>across<\/li>\n  <li>act<\/li>\n  <li>active<\/li>\n  <li>actual<\/li>\n  <li>add<\/li>\n  <li>address<\/li>\n  <li>admit<\/li>\n  <li>advertise<\/li>\n  <li>affect<\/li>\n  <li>afford<\/li>\n  <li>after<\/li>\n  <li>afternoon<\/li>\n  <li>again<\/li>\n  <li>against<\/li>\n  <li>age<\/li>\n  <li>agent<\/li>\n  <li>ago<\/li>\n  <li>agree<\/li>\n  <li>air<\/li>\n  <li>all<\/li>\n  <li>allow<\/li>\n  <li>almost<\/li>\n  <li>along<\/li>\n  <li>already<\/li>\n  <li>alright<\/li>\n  <li>also<\/li>\n  <li>although<\/li>\n  <li>always<\/li>\n  <li>america<\/li>\n  <li>amount<\/li>\n  <li>and<\/li>\n  <li>another<\/li>\n  <li>answer<\/li>\n  <li>any<\/li>\n  <li>apart<\/li>\n  <li>apparent<\/li>\n  <li>appear<\/li>\n  <li>apply<\/li>\n  <li>appoint<\/li>\n  <li>approach<\/li>\n  <li>appropriate<\/li>\n  <li>area<\/li>\n  <li>argue<\/li>\n  <li>arm<\/li>\n  <li>around<\/li>\n  <li>arrange<\/li>\n  <li>art<\/li>\n  <li>as<\/li>\n  <li>ask<\/li>\n  <li>associate<\/li>\n  <li>assume<\/li>\n  <li>at<\/li>\n  <li>attend<\/li>\n  <li>authority<\/li>\n  <li>available<\/li>\n  <li>aware<\/li>\n  <li>away<\/li>\n  <li>awful<\/li>\n  <li>baby<\/li>\n  <li>back<\/li>\n  <li>bad<\/li>\n  <li>bag<\/li>\n  <li>balance<\/li>\n  <li>ball<\/li>\n  <li>bank<\/li>\n  <li>bar<\/li>\n  <li>base<\/li>\n  <li>basis<\/li>\n  <li>be<\/li>\n  <li>bear<\/li>\n  <li>beat<\/li>\n  <li>beauty<\/li>\n  <li>because<\/li>\n  <li>become<\/li>\n  <li>bed<\/li>\n  <li>before<\/li>\n  <li>begin<\/li>\n  <li>behind<\/li>\n  <li>believe<\/li>\n  <li>benefit<\/li>\n  <li>best<\/li>\n  <li>bet<\/li>\n  <li>between<\/li>\n  <li>big<\/li>\n  <li>bill<\/li>\n  <li>birth<\/li>\n  <li>bit<\/li>\n  <li>black<\/li>\n  <li>bloke<\/li>\n  <li>blood<\/li>\n  <li>blow<\/li>\n  <li>blue<\/li>\n  <li>board<\/li>\n  <li>boat<\/li>\n  <li>body<\/li>\n  <li>book<\/li>\n  <li>both<\/li>\n  <li>bother<\/li>\n  <li>bottle<\/li>\n  <li>bottom<\/li>\n  <li>box<\/li>\n  <li>boy<\/li>\n  <li>break<\/li>\n  <li>brief<\/li>\n  <li>brilliant<\/li>\n  <li>bring<\/li>\n  <li>britain<\/li>\n  <li>brother<\/li>\n  <li>budget<\/li>\n  <li>build<\/li>\n  <li>bus<\/li>\n  <li>business<\/li>\n  <li>busy<\/li>\n  <li>but<\/li>\n  <li>buy<\/li>\n  <li>by<\/li>\n  <li>cake<\/li>\n  <li>call<\/li>\n  <li>can<\/li>\n  <li>car<\/li>\n  <li>card<\/li>\n  <li>care<\/li>\n  <li>carry<\/li>\n  <li>case<\/li>\n  <li>cat<\/li>\n  <li>catch<\/li>\n  <li>cause<\/li>\n  <li>cent<\/li>\n  <li>centre<\/li>\n  <li>certain<\/li>\n  <li>chair<\/li>\n  <li>chairman<\/li>\n  <li>chance<\/li>\n  <li>change<\/li>\n  <li>chap<\/li>\n  <li>character<\/li>\n  <li>charge<\/li>\n  <li>cheap<\/li>\n  <li>check<\/li>\n  <li>child<\/li>\n  <li>choice<\/li>\n  <li>choose<\/li>\n  <li><span class='match'>Chr<\/span>ist<\/li>\n  <li><span class='match'>Chr<\/span>istmas<\/li>\n  <li>church<\/li>\n  <li>city<\/li>\n  <li>claim<\/li>\n  <li>class<\/li>\n  <li>clean<\/li>\n  <li>clear<\/li>\n  <li>client<\/li>\n  <li>clock<\/li>\n  <li>close<\/li>\n  <li>closes<\/li>\n  <li>clothe<\/li>\n  <li>club<\/li>\n  <li>coffee<\/li>\n  <li>cold<\/li>\n  <li>colleague<\/li>\n  <li>collect<\/li>\n  <li>college<\/li>\n  <li>colour<\/li>\n  <li>come<\/li>\n  <li>comment<\/li>\n  <li>commit<\/li>\n  <li>committee<\/li>\n  <li>common<\/li>\n  <li>community<\/li>\n  <li>company<\/li>\n  <li>compare<\/li>\n  <li>complete<\/li>\n  <li>compute<\/li>\n  <li>concern<\/li>\n  <li>condition<\/li>\n  <li>confer<\/li>\n  <li>consider<\/li>\n  <li>consult<\/li>\n  <li>contact<\/li>\n  <li>continue<\/li>\n  <li>contract<\/li>\n  <li>control<\/li>\n  <li>converse<\/li>\n  <li>cook<\/li>\n  <li>copy<\/li>\n  <li>corner<\/li>\n  <li>correct<\/li>\n  <li>cost<\/li>\n  <li>could<\/li>\n  <li>council<\/li>\n  <li>count<\/li>\n  <li>country<\/li>\n  <li>county<\/li>\n  <li>couple<\/li>\n  <li>course<\/li>\n  <li>court<\/li>\n  <li>cover<\/li>\n  <li>create<\/li>\n  <li>cross<\/li>\n  <li>cup<\/li>\n  <li>current<\/li>\n  <li>cut<\/li>\n  <li>dad<\/li>\n  <li>danger<\/li>\n  <li>date<\/li>\n  <li>day<\/li>\n  <li>dead<\/li>\n  <li>deal<\/li>\n  <li>dear<\/li>\n  <li>debate<\/li>\n  <li>decide<\/li>\n  <li>decision<\/li>\n  <li>deep<\/li>\n  <li>definite<\/li>\n  <li>degree<\/li>\n  <li>department<\/li>\n  <li>depend<\/li>\n  <li>describe<\/li>\n  <li>design<\/li>\n  <li>detail<\/li>\n  <li>develop<\/li>\n  <li>die<\/li>\n  <li>difference<\/li>\n  <li>difficult<\/li>\n  <li>dinner<\/li>\n  <li>direct<\/li>\n  <li>discuss<\/li>\n  <li>district<\/li>\n  <li>divide<\/li>\n  <li>do<\/li>\n  <li>doctor<\/li>\n  <li>document<\/li>\n  <li>dog<\/li>\n  <li>door<\/li>\n  <li>double<\/li>\n  <li>doubt<\/li>\n  <li>down<\/li>\n  <li>draw<\/li>\n  <li>dress<\/li>\n  <li>drink<\/li>\n  <li>drive<\/li>\n  <li>drop<\/li>\n  <li><span class='match'>dry<\/span><\/li>\n  <li>due<\/li>\n  <li>during<\/li>\n  <li>each<\/li>\n  <li>early<\/li>\n  <li>east<\/li>\n  <li>easy<\/li>\n  <li>eat<\/li>\n  <li>economy<\/li>\n  <li>educate<\/li>\n  <li>effect<\/li>\n  <li>egg<\/li>\n  <li>eight<\/li>\n  <li>either<\/li>\n  <li>elect<\/li>\n  <li>electric<\/li>\n  <li>eleven<\/li>\n  <li>else<\/li>\n  <li>employ<\/li>\n  <li>encourage<\/li>\n  <li>end<\/li>\n  <li>engine<\/li>\n  <li>english<\/li>\n  <li>enjoy<\/li>\n  <li>enough<\/li>\n  <li>enter<\/li>\n  <li>environment<\/li>\n  <li>equal<\/li>\n  <li>especial<\/li>\n  <li>europe<\/li>\n  <li>even<\/li>\n  <li>evening<\/li>\n  <li>ever<\/li>\n  <li>every<\/li>\n  <li>evidence<\/li>\n  <li>exact<\/li>\n  <li>example<\/li>\n  <li>except<\/li>\n  <li>excuse<\/li>\n  <li>exercise<\/li>\n  <li>exist<\/li>\n  <li>expect<\/li>\n  <li>expense<\/li>\n  <li>experience<\/li>\n  <li>explain<\/li>\n  <li>express<\/li>\n  <li>extra<\/li>\n  <li>eye<\/li>\n  <li>face<\/li>\n  <li>fact<\/li>\n  <li>fair<\/li>\n  <li>fall<\/li>\n  <li>family<\/li>\n  <li>far<\/li>\n  <li>farm<\/li>\n  <li>fast<\/li>\n  <li>father<\/li>\n  <li>favour<\/li>\n  <li>feed<\/li>\n  <li>feel<\/li>\n  <li>few<\/li>\n  <li>field<\/li>\n  <li>fight<\/li>\n  <li>figure<\/li>\n  <li>file<\/li>\n  <li>fill<\/li>\n  <li>film<\/li>\n  <li>final<\/li>\n  <li>finance<\/li>\n  <li>find<\/li>\n  <li>fine<\/li>\n  <li>finish<\/li>\n  <li>fire<\/li>\n  <li>first<\/li>\n  <li>fish<\/li>\n  <li>fit<\/li>\n  <li>five<\/li>\n  <li>flat<\/li>\n  <li>floor<\/li>\n  <li><span class='match'>fly<\/span><\/li>\n  <li>follow<\/li>\n  <li>food<\/li>\n  <li>foot<\/li>\n  <li>for<\/li>\n  <li>force<\/li>\n  <li>forget<\/li>\n  <li>form<\/li>\n  <li>fortune<\/li>\n  <li>forward<\/li>\n  <li>four<\/li>\n  <li>france<\/li>\n  <li>free<\/li>\n  <li>friday<\/li>\n  <li>friend<\/li>\n  <li>from<\/li>\n  <li>front<\/li>\n  <li>full<\/li>\n  <li>fun<\/li>\n  <li>function<\/li>\n  <li>fund<\/li>\n  <li>further<\/li>\n  <li>future<\/li>\n  <li>game<\/li>\n  <li>garden<\/li>\n  <li>gas<\/li>\n  <li>general<\/li>\n  <li>germany<\/li>\n  <li>get<\/li>\n  <li>girl<\/li>\n  <li>give<\/li>\n  <li>glass<\/li>\n  <li>go<\/li>\n  <li>god<\/li>\n  <li>good<\/li>\n  <li>goodbye<\/li>\n  <li>govern<\/li>\n  <li>grand<\/li>\n  <li>grant<\/li>\n  <li>great<\/li>\n  <li>green<\/li>\n  <li>ground<\/li>\n  <li>group<\/li>\n  <li>grow<\/li>\n  <li>guess<\/li>\n  <li>guy<\/li>\n  <li>hair<\/li>\n  <li>half<\/li>\n  <li>hall<\/li>\n  <li>hand<\/li>\n  <li>hang<\/li>\n  <li>happen<\/li>\n  <li>happy<\/li>\n  <li>hard<\/li>\n  <li>hate<\/li>\n  <li>have<\/li>\n  <li>he<\/li>\n  <li>head<\/li>\n  <li>health<\/li>\n  <li>hear<\/li>\n  <li>heart<\/li>\n  <li>heat<\/li>\n  <li>heavy<\/li>\n  <li>hell<\/li>\n  <li>help<\/li>\n  <li>here<\/li>\n  <li>high<\/li>\n  <li>history<\/li>\n  <li>hit<\/li>\n  <li>hold<\/li>\n  <li>holiday<\/li>\n  <li>home<\/li>\n  <li>honest<\/li>\n  <li>hope<\/li>\n  <li>horse<\/li>\n  <li>hospital<\/li>\n  <li>hot<\/li>\n  <li>hour<\/li>\n  <li>house<\/li>\n  <li>how<\/li>\n  <li>however<\/li>\n  <li>hullo<\/li>\n  <li>hundred<\/li>\n  <li>husband<\/li>\n  <li>idea<\/li>\n  <li>identify<\/li>\n  <li>if<\/li>\n  <li>imagine<\/li>\n  <li>important<\/li>\n  <li>improve<\/li>\n  <li>in<\/li>\n  <li>include<\/li>\n  <li>income<\/li>\n  <li>increase<\/li>\n  <li>indeed<\/li>\n  <li>individual<\/li>\n  <li>industry<\/li>\n  <li>inform<\/li>\n  <li>inside<\/li>\n  <li>instead<\/li>\n  <li>insure<\/li>\n  <li>interest<\/li>\n  <li>into<\/li>\n  <li>introduce<\/li>\n  <li>invest<\/li>\n  <li>involve<\/li>\n  <li>issue<\/li>\n  <li>it<\/li>\n  <li>item<\/li>\n  <li>jesus<\/li>\n  <li>job<\/li>\n  <li>join<\/li>\n  <li>judge<\/li>\n  <li>jump<\/li>\n  <li>just<\/li>\n  <li>keep<\/li>\n  <li>key<\/li>\n  <li>kid<\/li>\n  <li>kill<\/li>\n  <li>kind<\/li>\n  <li>king<\/li>\n  <li>kitchen<\/li>\n  <li>knock<\/li>\n  <li>know<\/li>\n  <li>labour<\/li>\n  <li>lad<\/li>\n  <li>lady<\/li>\n  <li>land<\/li>\n  <li>language<\/li>\n  <li>large<\/li>\n  <li>last<\/li>\n  <li>late<\/li>\n  <li>laugh<\/li>\n  <li>law<\/li>\n  <li>lay<\/li>\n  <li>lead<\/li>\n  <li>learn<\/li>\n  <li>leave<\/li>\n  <li>left<\/li>\n  <li>leg<\/li>\n  <li>less<\/li>\n  <li>let<\/li>\n  <li>letter<\/li>\n  <li>level<\/li>\n  <li>lie<\/li>\n  <li>life<\/li>\n  <li>light<\/li>\n  <li>like<\/li>\n  <li>likely<\/li>\n  <li>limit<\/li>\n  <li>line<\/li>\n  <li>link<\/li>\n  <li>list<\/li>\n  <li>listen<\/li>\n  <li>little<\/li>\n  <li>live<\/li>\n  <li>load<\/li>\n  <li>local<\/li>\n  <li>lock<\/li>\n  <li>london<\/li>\n  <li>long<\/li>\n  <li>look<\/li>\n  <li>lord<\/li>\n  <li>lose<\/li>\n  <li>lot<\/li>\n  <li>love<\/li>\n  <li>low<\/li>\n  <li>luck<\/li>\n  <li>lunch<\/li>\n  <li>machine<\/li>\n  <li>main<\/li>\n  <li>major<\/li>\n  <li>make<\/li>\n  <li>man<\/li>\n  <li>manage<\/li>\n  <li>many<\/li>\n  <li>mark<\/li>\n  <li>market<\/li>\n  <li>marry<\/li>\n  <li>match<\/li>\n  <li>matter<\/li>\n  <li>may<\/li>\n  <li>maybe<\/li>\n  <li>mean<\/li>\n  <li>meaning<\/li>\n  <li>measure<\/li>\n  <li>meet<\/li>\n  <li>member<\/li>\n  <li>mention<\/li>\n  <li>middle<\/li>\n  <li>might<\/li>\n  <li>mile<\/li>\n  <li>milk<\/li>\n  <li>million<\/li>\n  <li>mind<\/li>\n  <li>minister<\/li>\n  <li>minus<\/li>\n  <li>minute<\/li>\n  <li>miss<\/li>\n  <li>mister<\/li>\n  <li>moment<\/li>\n  <li>monday<\/li>\n  <li>money<\/li>\n  <li>month<\/li>\n  <li>more<\/li>\n  <li>morning<\/li>\n  <li>most<\/li>\n  <li>mother<\/li>\n  <li>motion<\/li>\n  <li>move<\/li>\n  <li><span class='match'>mrs<\/span><\/li>\n  <li>much<\/li>\n  <li>music<\/li>\n  <li>must<\/li>\n  <li>name<\/li>\n  <li>nation<\/li>\n  <li>nature<\/li>\n  <li>near<\/li>\n  <li>necessary<\/li>\n  <li>need<\/li>\n  <li>never<\/li>\n  <li>new<\/li>\n  <li>news<\/li>\n  <li>next<\/li>\n  <li>nice<\/li>\n  <li>night<\/li>\n  <li>nine<\/li>\n  <li>no<\/li>\n  <li>non<\/li>\n  <li>none<\/li>\n  <li>normal<\/li>\n  <li>north<\/li>\n  <li>not<\/li>\n  <li>note<\/li>\n  <li>notice<\/li>\n  <li>now<\/li>\n  <li>number<\/li>\n  <li>obvious<\/li>\n  <li>occasion<\/li>\n  <li>odd<\/li>\n  <li>of<\/li>\n  <li>off<\/li>\n  <li>offer<\/li>\n  <li>office<\/li>\n  <li>often<\/li>\n  <li>okay<\/li>\n  <li>old<\/li>\n  <li>on<\/li>\n  <li>once<\/li>\n  <li>one<\/li>\n  <li>only<\/li>\n  <li>open<\/li>\n  <li>operate<\/li>\n  <li>opportunity<\/li>\n  <li>oppose<\/li>\n  <li>or<\/li>\n  <li>order<\/li>\n  <li>organize<\/li>\n  <li>original<\/li>\n  <li>other<\/li>\n  <li>otherwise<\/li>\n  <li>ought<\/li>\n  <li>out<\/li>\n  <li>over<\/li>\n  <li>own<\/li>\n  <li>pack<\/li>\n  <li>page<\/li>\n  <li>paint<\/li>\n  <li>pair<\/li>\n  <li>paper<\/li>\n  <li>paragraph<\/li>\n  <li>pardon<\/li>\n  <li>parent<\/li>\n  <li>park<\/li>\n  <li>part<\/li>\n  <li>particular<\/li>\n  <li>party<\/li>\n  <li>pass<\/li>\n  <li>past<\/li>\n  <li>pay<\/li>\n  <li>pence<\/li>\n  <li>pension<\/li>\n  <li>people<\/li>\n  <li>per<\/li>\n  <li>percent<\/li>\n  <li>perfect<\/li>\n  <li>perhaps<\/li>\n  <li>period<\/li>\n  <li>person<\/li>\n  <li>photograph<\/li>\n  <li>pick<\/li>\n  <li>picture<\/li>\n  <li>piece<\/li>\n  <li>place<\/li>\n  <li>plan<\/li>\n  <li>play<\/li>\n  <li>please<\/li>\n  <li>plus<\/li>\n  <li>point<\/li>\n  <li>police<\/li>\n  <li>policy<\/li>\n  <li>politic<\/li>\n  <li>poor<\/li>\n  <li>position<\/li>\n  <li>positive<\/li>\n  <li>possible<\/li>\n  <li>post<\/li>\n  <li>pound<\/li>\n  <li>power<\/li>\n  <li>practise<\/li>\n  <li>prepare<\/li>\n  <li>present<\/li>\n  <li>press<\/li>\n  <li>pressure<\/li>\n  <li>presume<\/li>\n  <li>pretty<\/li>\n  <li>previous<\/li>\n  <li>price<\/li>\n  <li>print<\/li>\n  <li>private<\/li>\n  <li>probable<\/li>\n  <li>problem<\/li>\n  <li>proceed<\/li>\n  <li>process<\/li>\n  <li>produce<\/li>\n  <li>product<\/li>\n  <li>programme<\/li>\n  <li>project<\/li>\n  <li>proper<\/li>\n  <li>propose<\/li>\n  <li>protect<\/li>\n  <li>provide<\/li>\n  <li>public<\/li>\n  <li>pull<\/li>\n  <li>purpose<\/li>\n  <li>push<\/li>\n  <li>put<\/li>\n  <li>quality<\/li>\n  <li>quarter<\/li>\n  <li>question<\/li>\n  <li>quick<\/li>\n  <li>quid<\/li>\n  <li>quiet<\/li>\n  <li>quite<\/li>\n  <li>radio<\/li>\n  <li>rail<\/li>\n  <li>raise<\/li>\n  <li>range<\/li>\n  <li>rate<\/li>\n  <li>rather<\/li>\n  <li>read<\/li>\n  <li>ready<\/li>\n  <li>real<\/li>\n  <li>realise<\/li>\n  <li>really<\/li>\n  <li>reason<\/li>\n  <li>receive<\/li>\n  <li>recent<\/li>\n  <li>reckon<\/li>\n  <li>recognize<\/li>\n  <li>recommend<\/li>\n  <li>record<\/li>\n  <li>red<\/li>\n  <li>reduce<\/li>\n  <li>refer<\/li>\n  <li>regard<\/li>\n  <li>region<\/li>\n  <li>relation<\/li>\n  <li>remember<\/li>\n  <li>report<\/li>\n  <li>represent<\/li>\n  <li>require<\/li>\n  <li>research<\/li>\n  <li>resource<\/li>\n  <li>respect<\/li>\n  <li>responsible<\/li>\n  <li>rest<\/li>\n  <li>result<\/li>\n  <li>return<\/li>\n  <li>rid<\/li>\n  <li>right<\/li>\n  <li>ring<\/li>\n  <li>rise<\/li>\n  <li>road<\/li>\n  <li>role<\/li>\n  <li>roll<\/li>\n  <li>room<\/li>\n  <li>round<\/li>\n  <li>rule<\/li>\n  <li>run<\/li>\n  <li>safe<\/li>\n  <li>sale<\/li>\n  <li>same<\/li>\n  <li>saturday<\/li>\n  <li>save<\/li>\n  <li>say<\/li>\n  <li><span class='match'>sch<\/span>eme<\/li>\n  <li><span class='match'>sch<\/span>ool<\/li>\n  <li>science<\/li>\n  <li>score<\/li>\n  <li>scotland<\/li>\n  <li>seat<\/li>\n  <li>second<\/li>\n  <li>secretary<\/li>\n  <li>section<\/li>\n  <li>secure<\/li>\n  <li>see<\/li>\n  <li>seem<\/li>\n  <li>self<\/li>\n  <li>sell<\/li>\n  <li>send<\/li>\n  <li>sense<\/li>\n  <li>separate<\/li>\n  <li>serious<\/li>\n  <li>serve<\/li>\n  <li>service<\/li>\n  <li>set<\/li>\n  <li>settle<\/li>\n  <li>seven<\/li>\n  <li>sex<\/li>\n  <li>shall<\/li>\n  <li>share<\/li>\n  <li>she<\/li>\n  <li>sheet<\/li>\n  <li>shoe<\/li>\n  <li>shoot<\/li>\n  <li>shop<\/li>\n  <li>short<\/li>\n  <li>should<\/li>\n  <li>show<\/li>\n  <li>shut<\/li>\n  <li>sick<\/li>\n  <li>side<\/li>\n  <li>sign<\/li>\n  <li>similar<\/li>\n  <li>simple<\/li>\n  <li>since<\/li>\n  <li>sing<\/li>\n  <li>single<\/li>\n  <li>sir<\/li>\n  <li>sister<\/li>\n  <li>sit<\/li>\n  <li>site<\/li>\n  <li>situate<\/li>\n  <li>six<\/li>\n  <li>size<\/li>\n  <li>sleep<\/li>\n  <li>slight<\/li>\n  <li>slow<\/li>\n  <li>small<\/li>\n  <li>smoke<\/li>\n  <li>so<\/li>\n  <li>social<\/li>\n  <li>society<\/li>\n  <li>some<\/li>\n  <li>son<\/li>\n  <li>soon<\/li>\n  <li>sorry<\/li>\n  <li>sort<\/li>\n  <li>sound<\/li>\n  <li>south<\/li>\n  <li>space<\/li>\n  <li>speak<\/li>\n  <li>special<\/li>\n  <li>specific<\/li>\n  <li>speed<\/li>\n  <li>spell<\/li>\n  <li>spend<\/li>\n  <li>square<\/li>\n  <li>staff<\/li>\n  <li>stage<\/li>\n  <li>stairs<\/li>\n  <li>stand<\/li>\n  <li>standard<\/li>\n  <li>start<\/li>\n  <li>state<\/li>\n  <li>station<\/li>\n  <li>stay<\/li>\n  <li>step<\/li>\n  <li>stick<\/li>\n  <li>still<\/li>\n  <li>stop<\/li>\n  <li>story<\/li>\n  <li><span class='match'>str<\/span>aight<\/li>\n  <li><span class='match'>str<\/span>ategy<\/li>\n  <li><span class='match'>str<\/span>eet<\/li>\n  <li><span class='match'>str<\/span>ike<\/li>\n  <li><span class='match'>str<\/span>ong<\/li>\n  <li><span class='match'>str<\/span>ucture<\/li>\n  <li>student<\/li>\n  <li>study<\/li>\n  <li>stuff<\/li>\n  <li>stupid<\/li>\n  <li>subject<\/li>\n  <li>succeed<\/li>\n  <li>such<\/li>\n  <li>sudden<\/li>\n  <li>suggest<\/li>\n  <li>suit<\/li>\n  <li>summer<\/li>\n  <li>sun<\/li>\n  <li>sunday<\/li>\n  <li>supply<\/li>\n  <li>support<\/li>\n  <li>suppose<\/li>\n  <li>sure<\/li>\n  <li>surprise<\/li>\n  <li>switch<\/li>\n  <li><span class='match'>sys<\/span>tem<\/li>\n  <li>table<\/li>\n  <li>take<\/li>\n  <li>talk<\/li>\n  <li>tape<\/li>\n  <li>tax<\/li>\n  <li>tea<\/li>\n  <li>teach<\/li>\n  <li>team<\/li>\n  <li>telephone<\/li>\n  <li>television<\/li>\n  <li>tell<\/li>\n  <li>ten<\/li>\n  <li>tend<\/li>\n  <li>term<\/li>\n  <li>terrible<\/li>\n  <li>test<\/li>\n  <li>than<\/li>\n  <li>thank<\/li>\n  <li>the<\/li>\n  <li>then<\/li>\n  <li>there<\/li>\n  <li>therefore<\/li>\n  <li>they<\/li>\n  <li>thing<\/li>\n  <li>think<\/li>\n  <li>thirteen<\/li>\n  <li>thirty<\/li>\n  <li>this<\/li>\n  <li>thou<\/li>\n  <li>though<\/li>\n  <li>thousand<\/li>\n  <li><span class='match'>thr<\/span>ee<\/li>\n  <li><span class='match'>thr<\/span>ough<\/li>\n  <li><span class='match'>thr<\/span>ow<\/li>\n  <li>thursday<\/li>\n  <li>tie<\/li>\n  <li>time<\/li>\n  <li>to<\/li>\n  <li>today<\/li>\n  <li>together<\/li>\n  <li>tomorrow<\/li>\n  <li>tonight<\/li>\n  <li>too<\/li>\n  <li>top<\/li>\n  <li>total<\/li>\n  <li>touch<\/li>\n  <li>toward<\/li>\n  <li>town<\/li>\n  <li>trade<\/li>\n  <li>traffic<\/li>\n  <li>train<\/li>\n  <li>transport<\/li>\n  <li>travel<\/li>\n  <li>treat<\/li>\n  <li>tree<\/li>\n  <li>trouble<\/li>\n  <li>true<\/li>\n  <li>trust<\/li>\n  <li><span class='match'>try<\/span><\/li>\n  <li>tuesday<\/li>\n  <li>turn<\/li>\n  <li>twelve<\/li>\n  <li>twenty<\/li>\n  <li>two<\/li>\n  <li><span class='match'>typ<\/span>e<\/li>\n  <li>under<\/li>\n  <li>understand<\/li>\n  <li>union<\/li>\n  <li>unit<\/li>\n  <li>unite<\/li>\n  <li>university<\/li>\n  <li>unless<\/li>\n  <li>until<\/li>\n  <li>up<\/li>\n  <li>upon<\/li>\n  <li>use<\/li>\n  <li>usual<\/li>\n  <li>value<\/li>\n  <li>various<\/li>\n  <li>very<\/li>\n  <li>video<\/li>\n  <li>view<\/li>\n  <li>village<\/li>\n  <li>visit<\/li>\n  <li>vote<\/li>\n  <li>wage<\/li>\n  <li>wait<\/li>\n  <li>walk<\/li>\n  <li>wall<\/li>\n  <li>want<\/li>\n  <li>war<\/li>\n  <li>warm<\/li>\n  <li>wash<\/li>\n  <li>waste<\/li>\n  <li>watch<\/li>\n  <li>water<\/li>\n  <li>way<\/li>\n  <li>we<\/li>\n  <li>wear<\/li>\n  <li>wednesday<\/li>\n  <li>wee<\/li>\n  <li>week<\/li>\n  <li>weigh<\/li>\n  <li>welcome<\/li>\n  <li>well<\/li>\n  <li>west<\/li>\n  <li>what<\/li>\n  <li>when<\/li>\n  <li>where<\/li>\n  <li>whether<\/li>\n  <li>which<\/li>\n  <li>while<\/li>\n  <li>white<\/li>\n  <li>who<\/li>\n  <li>whole<\/li>\n  <li><span class='match'>why<\/span><\/li>\n  <li>wide<\/li>\n  <li>wife<\/li>\n  <li>will<\/li>\n  <li>win<\/li>\n  <li>wind<\/li>\n  <li>window<\/li>\n  <li>wish<\/li>\n  <li>with<\/li>\n  <li>within<\/li>\n  <li>without<\/li>\n  <li>woman<\/li>\n  <li>wonder<\/li>\n  <li>wood<\/li>\n  <li>word<\/li>\n  <li>work<\/li>\n  <li>world<\/li>\n  <li>worry<\/li>\n  <li>worse<\/li>\n  <li>worth<\/li>\n  <li>would<\/li>\n  <li>write<\/li>\n  <li>wrong<\/li>\n  <li>year<\/li>\n  <li>yes<\/li>\n  <li>yesterday<\/li>\n  <li>yet<\/li>\n  <li>you<\/li>\n  <li>young<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

A regex to find three or more vowels in a row:

```r
str_view(words, "[aeiou]{3,}")
```

<!--html_preserve--><div id="htmlwidget-fb37aa630b9d9968db84" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-fb37aa630b9d9968db84">{"x":{"html":"<ul>\n  <li>a<\/li>\n  <li>able<\/li>\n  <li>about<\/li>\n  <li>absolute<\/li>\n  <li>accept<\/li>\n  <li>account<\/li>\n  <li>achieve<\/li>\n  <li>across<\/li>\n  <li>act<\/li>\n  <li>active<\/li>\n  <li>actual<\/li>\n  <li>add<\/li>\n  <li>address<\/li>\n  <li>admit<\/li>\n  <li>advertise<\/li>\n  <li>affect<\/li>\n  <li>afford<\/li>\n  <li>after<\/li>\n  <li>afternoon<\/li>\n  <li>again<\/li>\n  <li>against<\/li>\n  <li>age<\/li>\n  <li>agent<\/li>\n  <li>ago<\/li>\n  <li>agree<\/li>\n  <li>air<\/li>\n  <li>all<\/li>\n  <li>allow<\/li>\n  <li>almost<\/li>\n  <li>along<\/li>\n  <li>already<\/li>\n  <li>alright<\/li>\n  <li>also<\/li>\n  <li>although<\/li>\n  <li>always<\/li>\n  <li>america<\/li>\n  <li>amount<\/li>\n  <li>and<\/li>\n  <li>another<\/li>\n  <li>answer<\/li>\n  <li>any<\/li>\n  <li>apart<\/li>\n  <li>apparent<\/li>\n  <li>appear<\/li>\n  <li>apply<\/li>\n  <li>appoint<\/li>\n  <li>approach<\/li>\n  <li>appropriate<\/li>\n  <li>area<\/li>\n  <li>argue<\/li>\n  <li>arm<\/li>\n  <li>around<\/li>\n  <li>arrange<\/li>\n  <li>art<\/li>\n  <li>as<\/li>\n  <li>ask<\/li>\n  <li>associate<\/li>\n  <li>assume<\/li>\n  <li>at<\/li>\n  <li>attend<\/li>\n  <li>authority<\/li>\n  <li>available<\/li>\n  <li>aware<\/li>\n  <li>away<\/li>\n  <li>awful<\/li>\n  <li>baby<\/li>\n  <li>back<\/li>\n  <li>bad<\/li>\n  <li>bag<\/li>\n  <li>balance<\/li>\n  <li>ball<\/li>\n  <li>bank<\/li>\n  <li>bar<\/li>\n  <li>base<\/li>\n  <li>basis<\/li>\n  <li>be<\/li>\n  <li>bear<\/li>\n  <li>beat<\/li>\n  <li>b<span class='match'>eau<\/span>ty<\/li>\n  <li>because<\/li>\n  <li>become<\/li>\n  <li>bed<\/li>\n  <li>before<\/li>\n  <li>begin<\/li>\n  <li>behind<\/li>\n  <li>believe<\/li>\n  <li>benefit<\/li>\n  <li>best<\/li>\n  <li>bet<\/li>\n  <li>between<\/li>\n  <li>big<\/li>\n  <li>bill<\/li>\n  <li>birth<\/li>\n  <li>bit<\/li>\n  <li>black<\/li>\n  <li>bloke<\/li>\n  <li>blood<\/li>\n  <li>blow<\/li>\n  <li>blue<\/li>\n  <li>board<\/li>\n  <li>boat<\/li>\n  <li>body<\/li>\n  <li>book<\/li>\n  <li>both<\/li>\n  <li>bother<\/li>\n  <li>bottle<\/li>\n  <li>bottom<\/li>\n  <li>box<\/li>\n  <li>boy<\/li>\n  <li>break<\/li>\n  <li>brief<\/li>\n  <li>brilliant<\/li>\n  <li>bring<\/li>\n  <li>britain<\/li>\n  <li>brother<\/li>\n  <li>budget<\/li>\n  <li>build<\/li>\n  <li>bus<\/li>\n  <li>business<\/li>\n  <li>busy<\/li>\n  <li>but<\/li>\n  <li>buy<\/li>\n  <li>by<\/li>\n  <li>cake<\/li>\n  <li>call<\/li>\n  <li>can<\/li>\n  <li>car<\/li>\n  <li>card<\/li>\n  <li>care<\/li>\n  <li>carry<\/li>\n  <li>case<\/li>\n  <li>cat<\/li>\n  <li>catch<\/li>\n  <li>cause<\/li>\n  <li>cent<\/li>\n  <li>centre<\/li>\n  <li>certain<\/li>\n  <li>chair<\/li>\n  <li>chairman<\/li>\n  <li>chance<\/li>\n  <li>change<\/li>\n  <li>chap<\/li>\n  <li>character<\/li>\n  <li>charge<\/li>\n  <li>cheap<\/li>\n  <li>check<\/li>\n  <li>child<\/li>\n  <li>choice<\/li>\n  <li>choose<\/li>\n  <li>Christ<\/li>\n  <li>Christmas<\/li>\n  <li>church<\/li>\n  <li>city<\/li>\n  <li>claim<\/li>\n  <li>class<\/li>\n  <li>clean<\/li>\n  <li>clear<\/li>\n  <li>client<\/li>\n  <li>clock<\/li>\n  <li>close<\/li>\n  <li>closes<\/li>\n  <li>clothe<\/li>\n  <li>club<\/li>\n  <li>coffee<\/li>\n  <li>cold<\/li>\n  <li>colleague<\/li>\n  <li>collect<\/li>\n  <li>college<\/li>\n  <li>colour<\/li>\n  <li>come<\/li>\n  <li>comment<\/li>\n  <li>commit<\/li>\n  <li>committee<\/li>\n  <li>common<\/li>\n  <li>community<\/li>\n  <li>company<\/li>\n  <li>compare<\/li>\n  <li>complete<\/li>\n  <li>compute<\/li>\n  <li>concern<\/li>\n  <li>condition<\/li>\n  <li>confer<\/li>\n  <li>consider<\/li>\n  <li>consult<\/li>\n  <li>contact<\/li>\n  <li>continue<\/li>\n  <li>contract<\/li>\n  <li>control<\/li>\n  <li>converse<\/li>\n  <li>cook<\/li>\n  <li>copy<\/li>\n  <li>corner<\/li>\n  <li>correct<\/li>\n  <li>cost<\/li>\n  <li>could<\/li>\n  <li>council<\/li>\n  <li>count<\/li>\n  <li>country<\/li>\n  <li>county<\/li>\n  <li>couple<\/li>\n  <li>course<\/li>\n  <li>court<\/li>\n  <li>cover<\/li>\n  <li>create<\/li>\n  <li>cross<\/li>\n  <li>cup<\/li>\n  <li>current<\/li>\n  <li>cut<\/li>\n  <li>dad<\/li>\n  <li>danger<\/li>\n  <li>date<\/li>\n  <li>day<\/li>\n  <li>dead<\/li>\n  <li>deal<\/li>\n  <li>dear<\/li>\n  <li>debate<\/li>\n  <li>decide<\/li>\n  <li>decision<\/li>\n  <li>deep<\/li>\n  <li>definite<\/li>\n  <li>degree<\/li>\n  <li>department<\/li>\n  <li>depend<\/li>\n  <li>describe<\/li>\n  <li>design<\/li>\n  <li>detail<\/li>\n  <li>develop<\/li>\n  <li>die<\/li>\n  <li>difference<\/li>\n  <li>difficult<\/li>\n  <li>dinner<\/li>\n  <li>direct<\/li>\n  <li>discuss<\/li>\n  <li>district<\/li>\n  <li>divide<\/li>\n  <li>do<\/li>\n  <li>doctor<\/li>\n  <li>document<\/li>\n  <li>dog<\/li>\n  <li>door<\/li>\n  <li>double<\/li>\n  <li>doubt<\/li>\n  <li>down<\/li>\n  <li>draw<\/li>\n  <li>dress<\/li>\n  <li>drink<\/li>\n  <li>drive<\/li>\n  <li>drop<\/li>\n  <li>dry<\/li>\n  <li>due<\/li>\n  <li>during<\/li>\n  <li>each<\/li>\n  <li>early<\/li>\n  <li>east<\/li>\n  <li>easy<\/li>\n  <li>eat<\/li>\n  <li>economy<\/li>\n  <li>educate<\/li>\n  <li>effect<\/li>\n  <li>egg<\/li>\n  <li>eight<\/li>\n  <li>either<\/li>\n  <li>elect<\/li>\n  <li>electric<\/li>\n  <li>eleven<\/li>\n  <li>else<\/li>\n  <li>employ<\/li>\n  <li>encourage<\/li>\n  <li>end<\/li>\n  <li>engine<\/li>\n  <li>english<\/li>\n  <li>enjoy<\/li>\n  <li>enough<\/li>\n  <li>enter<\/li>\n  <li>environment<\/li>\n  <li>equal<\/li>\n  <li>especial<\/li>\n  <li>europe<\/li>\n  <li>even<\/li>\n  <li>evening<\/li>\n  <li>ever<\/li>\n  <li>every<\/li>\n  <li>evidence<\/li>\n  <li>exact<\/li>\n  <li>example<\/li>\n  <li>except<\/li>\n  <li>excuse<\/li>\n  <li>exercise<\/li>\n  <li>exist<\/li>\n  <li>expect<\/li>\n  <li>expense<\/li>\n  <li>experience<\/li>\n  <li>explain<\/li>\n  <li>express<\/li>\n  <li>extra<\/li>\n  <li>eye<\/li>\n  <li>face<\/li>\n  <li>fact<\/li>\n  <li>fair<\/li>\n  <li>fall<\/li>\n  <li>family<\/li>\n  <li>far<\/li>\n  <li>farm<\/li>\n  <li>fast<\/li>\n  <li>father<\/li>\n  <li>favour<\/li>\n  <li>feed<\/li>\n  <li>feel<\/li>\n  <li>few<\/li>\n  <li>field<\/li>\n  <li>fight<\/li>\n  <li>figure<\/li>\n  <li>file<\/li>\n  <li>fill<\/li>\n  <li>film<\/li>\n  <li>final<\/li>\n  <li>finance<\/li>\n  <li>find<\/li>\n  <li>fine<\/li>\n  <li>finish<\/li>\n  <li>fire<\/li>\n  <li>first<\/li>\n  <li>fish<\/li>\n  <li>fit<\/li>\n  <li>five<\/li>\n  <li>flat<\/li>\n  <li>floor<\/li>\n  <li>fly<\/li>\n  <li>follow<\/li>\n  <li>food<\/li>\n  <li>foot<\/li>\n  <li>for<\/li>\n  <li>force<\/li>\n  <li>forget<\/li>\n  <li>form<\/li>\n  <li>fortune<\/li>\n  <li>forward<\/li>\n  <li>four<\/li>\n  <li>france<\/li>\n  <li>free<\/li>\n  <li>friday<\/li>\n  <li>friend<\/li>\n  <li>from<\/li>\n  <li>front<\/li>\n  <li>full<\/li>\n  <li>fun<\/li>\n  <li>function<\/li>\n  <li>fund<\/li>\n  <li>further<\/li>\n  <li>future<\/li>\n  <li>game<\/li>\n  <li>garden<\/li>\n  <li>gas<\/li>\n  <li>general<\/li>\n  <li>germany<\/li>\n  <li>get<\/li>\n  <li>girl<\/li>\n  <li>give<\/li>\n  <li>glass<\/li>\n  <li>go<\/li>\n  <li>god<\/li>\n  <li>good<\/li>\n  <li>goodbye<\/li>\n  <li>govern<\/li>\n  <li>grand<\/li>\n  <li>grant<\/li>\n  <li>great<\/li>\n  <li>green<\/li>\n  <li>ground<\/li>\n  <li>group<\/li>\n  <li>grow<\/li>\n  <li>guess<\/li>\n  <li>guy<\/li>\n  <li>hair<\/li>\n  <li>half<\/li>\n  <li>hall<\/li>\n  <li>hand<\/li>\n  <li>hang<\/li>\n  <li>happen<\/li>\n  <li>happy<\/li>\n  <li>hard<\/li>\n  <li>hate<\/li>\n  <li>have<\/li>\n  <li>he<\/li>\n  <li>head<\/li>\n  <li>health<\/li>\n  <li>hear<\/li>\n  <li>heart<\/li>\n  <li>heat<\/li>\n  <li>heavy<\/li>\n  <li>hell<\/li>\n  <li>help<\/li>\n  <li>here<\/li>\n  <li>high<\/li>\n  <li>history<\/li>\n  <li>hit<\/li>\n  <li>hold<\/li>\n  <li>holiday<\/li>\n  <li>home<\/li>\n  <li>honest<\/li>\n  <li>hope<\/li>\n  <li>horse<\/li>\n  <li>hospital<\/li>\n  <li>hot<\/li>\n  <li>hour<\/li>\n  <li>house<\/li>\n  <li>how<\/li>\n  <li>however<\/li>\n  <li>hullo<\/li>\n  <li>hundred<\/li>\n  <li>husband<\/li>\n  <li>idea<\/li>\n  <li>identify<\/li>\n  <li>if<\/li>\n  <li>imagine<\/li>\n  <li>important<\/li>\n  <li>improve<\/li>\n  <li>in<\/li>\n  <li>include<\/li>\n  <li>income<\/li>\n  <li>increase<\/li>\n  <li>indeed<\/li>\n  <li>individual<\/li>\n  <li>industry<\/li>\n  <li>inform<\/li>\n  <li>inside<\/li>\n  <li>instead<\/li>\n  <li>insure<\/li>\n  <li>interest<\/li>\n  <li>into<\/li>\n  <li>introduce<\/li>\n  <li>invest<\/li>\n  <li>involve<\/li>\n  <li>issue<\/li>\n  <li>it<\/li>\n  <li>item<\/li>\n  <li>jesus<\/li>\n  <li>job<\/li>\n  <li>join<\/li>\n  <li>judge<\/li>\n  <li>jump<\/li>\n  <li>just<\/li>\n  <li>keep<\/li>\n  <li>key<\/li>\n  <li>kid<\/li>\n  <li>kill<\/li>\n  <li>kind<\/li>\n  <li>king<\/li>\n  <li>kitchen<\/li>\n  <li>knock<\/li>\n  <li>know<\/li>\n  <li>labour<\/li>\n  <li>lad<\/li>\n  <li>lady<\/li>\n  <li>land<\/li>\n  <li>language<\/li>\n  <li>large<\/li>\n  <li>last<\/li>\n  <li>late<\/li>\n  <li>laugh<\/li>\n  <li>law<\/li>\n  <li>lay<\/li>\n  <li>lead<\/li>\n  <li>learn<\/li>\n  <li>leave<\/li>\n  <li>left<\/li>\n  <li>leg<\/li>\n  <li>less<\/li>\n  <li>let<\/li>\n  <li>letter<\/li>\n  <li>level<\/li>\n  <li>lie<\/li>\n  <li>life<\/li>\n  <li>light<\/li>\n  <li>like<\/li>\n  <li>likely<\/li>\n  <li>limit<\/li>\n  <li>line<\/li>\n  <li>link<\/li>\n  <li>list<\/li>\n  <li>listen<\/li>\n  <li>little<\/li>\n  <li>live<\/li>\n  <li>load<\/li>\n  <li>local<\/li>\n  <li>lock<\/li>\n  <li>london<\/li>\n  <li>long<\/li>\n  <li>look<\/li>\n  <li>lord<\/li>\n  <li>lose<\/li>\n  <li>lot<\/li>\n  <li>love<\/li>\n  <li>low<\/li>\n  <li>luck<\/li>\n  <li>lunch<\/li>\n  <li>machine<\/li>\n  <li>main<\/li>\n  <li>major<\/li>\n  <li>make<\/li>\n  <li>man<\/li>\n  <li>manage<\/li>\n  <li>many<\/li>\n  <li>mark<\/li>\n  <li>market<\/li>\n  <li>marry<\/li>\n  <li>match<\/li>\n  <li>matter<\/li>\n  <li>may<\/li>\n  <li>maybe<\/li>\n  <li>mean<\/li>\n  <li>meaning<\/li>\n  <li>measure<\/li>\n  <li>meet<\/li>\n  <li>member<\/li>\n  <li>mention<\/li>\n  <li>middle<\/li>\n  <li>might<\/li>\n  <li>mile<\/li>\n  <li>milk<\/li>\n  <li>million<\/li>\n  <li>mind<\/li>\n  <li>minister<\/li>\n  <li>minus<\/li>\n  <li>minute<\/li>\n  <li>miss<\/li>\n  <li>mister<\/li>\n  <li>moment<\/li>\n  <li>monday<\/li>\n  <li>money<\/li>\n  <li>month<\/li>\n  <li>more<\/li>\n  <li>morning<\/li>\n  <li>most<\/li>\n  <li>mother<\/li>\n  <li>motion<\/li>\n  <li>move<\/li>\n  <li>mrs<\/li>\n  <li>much<\/li>\n  <li>music<\/li>\n  <li>must<\/li>\n  <li>name<\/li>\n  <li>nation<\/li>\n  <li>nature<\/li>\n  <li>near<\/li>\n  <li>necessary<\/li>\n  <li>need<\/li>\n  <li>never<\/li>\n  <li>new<\/li>\n  <li>news<\/li>\n  <li>next<\/li>\n  <li>nice<\/li>\n  <li>night<\/li>\n  <li>nine<\/li>\n  <li>no<\/li>\n  <li>non<\/li>\n  <li>none<\/li>\n  <li>normal<\/li>\n  <li>north<\/li>\n  <li>not<\/li>\n  <li>note<\/li>\n  <li>notice<\/li>\n  <li>now<\/li>\n  <li>number<\/li>\n  <li>obv<span class='match'>iou<\/span>s<\/li>\n  <li>occasion<\/li>\n  <li>odd<\/li>\n  <li>of<\/li>\n  <li>off<\/li>\n  <li>offer<\/li>\n  <li>office<\/li>\n  <li>often<\/li>\n  <li>okay<\/li>\n  <li>old<\/li>\n  <li>on<\/li>\n  <li>once<\/li>\n  <li>one<\/li>\n  <li>only<\/li>\n  <li>open<\/li>\n  <li>operate<\/li>\n  <li>opportunity<\/li>\n  <li>oppose<\/li>\n  <li>or<\/li>\n  <li>order<\/li>\n  <li>organize<\/li>\n  <li>original<\/li>\n  <li>other<\/li>\n  <li>otherwise<\/li>\n  <li>ought<\/li>\n  <li>out<\/li>\n  <li>over<\/li>\n  <li>own<\/li>\n  <li>pack<\/li>\n  <li>page<\/li>\n  <li>paint<\/li>\n  <li>pair<\/li>\n  <li>paper<\/li>\n  <li>paragraph<\/li>\n  <li>pardon<\/li>\n  <li>parent<\/li>\n  <li>park<\/li>\n  <li>part<\/li>\n  <li>particular<\/li>\n  <li>party<\/li>\n  <li>pass<\/li>\n  <li>past<\/li>\n  <li>pay<\/li>\n  <li>pence<\/li>\n  <li>pension<\/li>\n  <li>people<\/li>\n  <li>per<\/li>\n  <li>percent<\/li>\n  <li>perfect<\/li>\n  <li>perhaps<\/li>\n  <li>period<\/li>\n  <li>person<\/li>\n  <li>photograph<\/li>\n  <li>pick<\/li>\n  <li>picture<\/li>\n  <li>piece<\/li>\n  <li>place<\/li>\n  <li>plan<\/li>\n  <li>play<\/li>\n  <li>please<\/li>\n  <li>plus<\/li>\n  <li>point<\/li>\n  <li>police<\/li>\n  <li>policy<\/li>\n  <li>politic<\/li>\n  <li>poor<\/li>\n  <li>position<\/li>\n  <li>positive<\/li>\n  <li>possible<\/li>\n  <li>post<\/li>\n  <li>pound<\/li>\n  <li>power<\/li>\n  <li>practise<\/li>\n  <li>prepare<\/li>\n  <li>present<\/li>\n  <li>press<\/li>\n  <li>pressure<\/li>\n  <li>presume<\/li>\n  <li>pretty<\/li>\n  <li>prev<span class='match'>iou<\/span>s<\/li>\n  <li>price<\/li>\n  <li>print<\/li>\n  <li>private<\/li>\n  <li>probable<\/li>\n  <li>problem<\/li>\n  <li>proceed<\/li>\n  <li>process<\/li>\n  <li>produce<\/li>\n  <li>product<\/li>\n  <li>programme<\/li>\n  <li>project<\/li>\n  <li>proper<\/li>\n  <li>propose<\/li>\n  <li>protect<\/li>\n  <li>provide<\/li>\n  <li>public<\/li>\n  <li>pull<\/li>\n  <li>purpose<\/li>\n  <li>push<\/li>\n  <li>put<\/li>\n  <li>quality<\/li>\n  <li>quarter<\/li>\n  <li>question<\/li>\n  <li>quick<\/li>\n  <li>quid<\/li>\n  <li>q<span class='match'>uie<\/span>t<\/li>\n  <li>quite<\/li>\n  <li>radio<\/li>\n  <li>rail<\/li>\n  <li>raise<\/li>\n  <li>range<\/li>\n  <li>rate<\/li>\n  <li>rather<\/li>\n  <li>read<\/li>\n  <li>ready<\/li>\n  <li>real<\/li>\n  <li>realise<\/li>\n  <li>really<\/li>\n  <li>reason<\/li>\n  <li>receive<\/li>\n  <li>recent<\/li>\n  <li>reckon<\/li>\n  <li>recognize<\/li>\n  <li>recommend<\/li>\n  <li>record<\/li>\n  <li>red<\/li>\n  <li>reduce<\/li>\n  <li>refer<\/li>\n  <li>regard<\/li>\n  <li>region<\/li>\n  <li>relation<\/li>\n  <li>remember<\/li>\n  <li>report<\/li>\n  <li>represent<\/li>\n  <li>require<\/li>\n  <li>research<\/li>\n  <li>resource<\/li>\n  <li>respect<\/li>\n  <li>responsible<\/li>\n  <li>rest<\/li>\n  <li>result<\/li>\n  <li>return<\/li>\n  <li>rid<\/li>\n  <li>right<\/li>\n  <li>ring<\/li>\n  <li>rise<\/li>\n  <li>road<\/li>\n  <li>role<\/li>\n  <li>roll<\/li>\n  <li>room<\/li>\n  <li>round<\/li>\n  <li>rule<\/li>\n  <li>run<\/li>\n  <li>safe<\/li>\n  <li>sale<\/li>\n  <li>same<\/li>\n  <li>saturday<\/li>\n  <li>save<\/li>\n  <li>say<\/li>\n  <li>scheme<\/li>\n  <li>school<\/li>\n  <li>science<\/li>\n  <li>score<\/li>\n  <li>scotland<\/li>\n  <li>seat<\/li>\n  <li>second<\/li>\n  <li>secretary<\/li>\n  <li>section<\/li>\n  <li>secure<\/li>\n  <li>see<\/li>\n  <li>seem<\/li>\n  <li>self<\/li>\n  <li>sell<\/li>\n  <li>send<\/li>\n  <li>sense<\/li>\n  <li>separate<\/li>\n  <li>ser<span class='match'>iou<\/span>s<\/li>\n  <li>serve<\/li>\n  <li>service<\/li>\n  <li>set<\/li>\n  <li>settle<\/li>\n  <li>seven<\/li>\n  <li>sex<\/li>\n  <li>shall<\/li>\n  <li>share<\/li>\n  <li>she<\/li>\n  <li>sheet<\/li>\n  <li>shoe<\/li>\n  <li>shoot<\/li>\n  <li>shop<\/li>\n  <li>short<\/li>\n  <li>should<\/li>\n  <li>show<\/li>\n  <li>shut<\/li>\n  <li>sick<\/li>\n  <li>side<\/li>\n  <li>sign<\/li>\n  <li>similar<\/li>\n  <li>simple<\/li>\n  <li>since<\/li>\n  <li>sing<\/li>\n  <li>single<\/li>\n  <li>sir<\/li>\n  <li>sister<\/li>\n  <li>sit<\/li>\n  <li>site<\/li>\n  <li>situate<\/li>\n  <li>six<\/li>\n  <li>size<\/li>\n  <li>sleep<\/li>\n  <li>slight<\/li>\n  <li>slow<\/li>\n  <li>small<\/li>\n  <li>smoke<\/li>\n  <li>so<\/li>\n  <li>social<\/li>\n  <li>society<\/li>\n  <li>some<\/li>\n  <li>son<\/li>\n  <li>soon<\/li>\n  <li>sorry<\/li>\n  <li>sort<\/li>\n  <li>sound<\/li>\n  <li>south<\/li>\n  <li>space<\/li>\n  <li>speak<\/li>\n  <li>special<\/li>\n  <li>specific<\/li>\n  <li>speed<\/li>\n  <li>spell<\/li>\n  <li>spend<\/li>\n  <li>square<\/li>\n  <li>staff<\/li>\n  <li>stage<\/li>\n  <li>stairs<\/li>\n  <li>stand<\/li>\n  <li>standard<\/li>\n  <li>start<\/li>\n  <li>state<\/li>\n  <li>station<\/li>\n  <li>stay<\/li>\n  <li>step<\/li>\n  <li>stick<\/li>\n  <li>still<\/li>\n  <li>stop<\/li>\n  <li>story<\/li>\n  <li>straight<\/li>\n  <li>strategy<\/li>\n  <li>street<\/li>\n  <li>strike<\/li>\n  <li>strong<\/li>\n  <li>structure<\/li>\n  <li>student<\/li>\n  <li>study<\/li>\n  <li>stuff<\/li>\n  <li>stupid<\/li>\n  <li>subject<\/li>\n  <li>succeed<\/li>\n  <li>such<\/li>\n  <li>sudden<\/li>\n  <li>suggest<\/li>\n  <li>suit<\/li>\n  <li>summer<\/li>\n  <li>sun<\/li>\n  <li>sunday<\/li>\n  <li>supply<\/li>\n  <li>support<\/li>\n  <li>suppose<\/li>\n  <li>sure<\/li>\n  <li>surprise<\/li>\n  <li>switch<\/li>\n  <li>system<\/li>\n  <li>table<\/li>\n  <li>take<\/li>\n  <li>talk<\/li>\n  <li>tape<\/li>\n  <li>tax<\/li>\n  <li>tea<\/li>\n  <li>teach<\/li>\n  <li>team<\/li>\n  <li>telephone<\/li>\n  <li>television<\/li>\n  <li>tell<\/li>\n  <li>ten<\/li>\n  <li>tend<\/li>\n  <li>term<\/li>\n  <li>terrible<\/li>\n  <li>test<\/li>\n  <li>than<\/li>\n  <li>thank<\/li>\n  <li>the<\/li>\n  <li>then<\/li>\n  <li>there<\/li>\n  <li>therefore<\/li>\n  <li>they<\/li>\n  <li>thing<\/li>\n  <li>think<\/li>\n  <li>thirteen<\/li>\n  <li>thirty<\/li>\n  <li>this<\/li>\n  <li>thou<\/li>\n  <li>though<\/li>\n  <li>thousand<\/li>\n  <li>three<\/li>\n  <li>through<\/li>\n  <li>throw<\/li>\n  <li>thursday<\/li>\n  <li>tie<\/li>\n  <li>time<\/li>\n  <li>to<\/li>\n  <li>today<\/li>\n  <li>together<\/li>\n  <li>tomorrow<\/li>\n  <li>tonight<\/li>\n  <li>too<\/li>\n  <li>top<\/li>\n  <li>total<\/li>\n  <li>touch<\/li>\n  <li>toward<\/li>\n  <li>town<\/li>\n  <li>trade<\/li>\n  <li>traffic<\/li>\n  <li>train<\/li>\n  <li>transport<\/li>\n  <li>travel<\/li>\n  <li>treat<\/li>\n  <li>tree<\/li>\n  <li>trouble<\/li>\n  <li>true<\/li>\n  <li>trust<\/li>\n  <li>try<\/li>\n  <li>tuesday<\/li>\n  <li>turn<\/li>\n  <li>twelve<\/li>\n  <li>twenty<\/li>\n  <li>two<\/li>\n  <li>type<\/li>\n  <li>under<\/li>\n  <li>understand<\/li>\n  <li>union<\/li>\n  <li>unit<\/li>\n  <li>unite<\/li>\n  <li>university<\/li>\n  <li>unless<\/li>\n  <li>until<\/li>\n  <li>up<\/li>\n  <li>upon<\/li>\n  <li>use<\/li>\n  <li>usual<\/li>\n  <li>value<\/li>\n  <li>var<span class='match'>iou<\/span>s<\/li>\n  <li>very<\/li>\n  <li>video<\/li>\n  <li>view<\/li>\n  <li>village<\/li>\n  <li>visit<\/li>\n  <li>vote<\/li>\n  <li>wage<\/li>\n  <li>wait<\/li>\n  <li>walk<\/li>\n  <li>wall<\/li>\n  <li>want<\/li>\n  <li>war<\/li>\n  <li>warm<\/li>\n  <li>wash<\/li>\n  <li>waste<\/li>\n  <li>watch<\/li>\n  <li>water<\/li>\n  <li>way<\/li>\n  <li>we<\/li>\n  <li>wear<\/li>\n  <li>wednesday<\/li>\n  <li>wee<\/li>\n  <li>week<\/li>\n  <li>weigh<\/li>\n  <li>welcome<\/li>\n  <li>well<\/li>\n  <li>west<\/li>\n  <li>what<\/li>\n  <li>when<\/li>\n  <li>where<\/li>\n  <li>whether<\/li>\n  <li>which<\/li>\n  <li>while<\/li>\n  <li>white<\/li>\n  <li>who<\/li>\n  <li>whole<\/li>\n  <li>why<\/li>\n  <li>wide<\/li>\n  <li>wife<\/li>\n  <li>will<\/li>\n  <li>win<\/li>\n  <li>wind<\/li>\n  <li>window<\/li>\n  <li>wish<\/li>\n  <li>with<\/li>\n  <li>within<\/li>\n  <li>without<\/li>\n  <li>woman<\/li>\n  <li>wonder<\/li>\n  <li>wood<\/li>\n  <li>word<\/li>\n  <li>work<\/li>\n  <li>world<\/li>\n  <li>worry<\/li>\n  <li>worse<\/li>\n  <li>worth<\/li>\n  <li>would<\/li>\n  <li>write<\/li>\n  <li>wrong<\/li>\n  <li>year<\/li>\n  <li>yes<\/li>\n  <li>yesterday<\/li>\n  <li>yet<\/li>\n  <li>you<\/li>\n  <li>young<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

Two or more vowel-consonant pairs in a row.

```r
str_view(words, "([aeiou][^aeiou]){2,}")
```

<!--html_preserve--><div id="htmlwidget-fa04ac5febadaac18a3d" style="width:960px;height:auto;" class="str_view html-widget"></div>
<script type="application/json" data-for="htmlwidget-fa04ac5febadaac18a3d">{"x":{"html":"<ul>\n  <li>a<\/li>\n  <li>able<\/li>\n  <li>about<\/li>\n  <li>abs<span class='match'>olut<\/span>e<\/li>\n  <li>accept<\/li>\n  <li>account<\/li>\n  <li>achieve<\/li>\n  <li>across<\/li>\n  <li>act<\/li>\n  <li>active<\/li>\n  <li>actual<\/li>\n  <li>add<\/li>\n  <li>address<\/li>\n  <li>admit<\/li>\n  <li>advertise<\/li>\n  <li>affect<\/li>\n  <li>afford<\/li>\n  <li>after<\/li>\n  <li>afternoon<\/li>\n  <li>again<\/li>\n  <li>against<\/li>\n  <li>age<\/li>\n  <li><span class='match'>agen<\/span>t<\/li>\n  <li>ago<\/li>\n  <li>agree<\/li>\n  <li>air<\/li>\n  <li>all<\/li>\n  <li>allow<\/li>\n  <li>almost<\/li>\n  <li><span class='match'>alon<\/span>g<\/li>\n  <li>already<\/li>\n  <li>alright<\/li>\n  <li>also<\/li>\n  <li>although<\/li>\n  <li>always<\/li>\n  <li><span class='match'>americ<\/span>a<\/li>\n  <li>amount<\/li>\n  <li>and<\/li>\n  <li><span class='match'>anot<\/span>her<\/li>\n  <li>answer<\/li>\n  <li>any<\/li>\n  <li><span class='match'>apar<\/span>t<\/li>\n  <li>app<span class='match'>aren<\/span>t<\/li>\n  <li>appear<\/li>\n  <li>apply<\/li>\n  <li>appoint<\/li>\n  <li>approach<\/li>\n  <li>appropriate<\/li>\n  <li>area<\/li>\n  <li>argue<\/li>\n  <li>arm<\/li>\n  <li>around<\/li>\n  <li>arrange<\/li>\n  <li>art<\/li>\n  <li>as<\/li>\n  <li>ask<\/li>\n  <li>associate<\/li>\n  <li>assume<\/li>\n  <li>at<\/li>\n  <li>attend<\/li>\n  <li>auth<span class='match'>orit<\/span>y<\/li>\n  <li>ava<span class='match'>ilab<\/span>le<\/li>\n  <li><span class='match'>awar<\/span>e<\/li>\n  <li><span class='match'>away<\/span><\/li>\n  <li>awful<\/li>\n  <li>baby<\/li>\n  <li>back<\/li>\n  <li>bad<\/li>\n  <li>bag<\/li>\n  <li>b<span class='match'>alan<\/span>ce<\/li>\n  <li>ball<\/li>\n  <li>bank<\/li>\n  <li>bar<\/li>\n  <li>base<\/li>\n  <li>b<span class='match'>asis<\/span><\/li>\n  <li>be<\/li>\n  <li>bear<\/li>\n  <li>beat<\/li>\n  <li>beauty<\/li>\n  <li>because<\/li>\n  <li>b<span class='match'>ecom<\/span>e<\/li>\n  <li>bed<\/li>\n  <li>b<span class='match'>efor<\/span>e<\/li>\n  <li>b<span class='match'>egin<\/span><\/li>\n  <li>b<span class='match'>ehin<\/span>d<\/li>\n  <li>believe<\/li>\n  <li>b<span class='match'>enefit<\/span><\/li>\n  <li>best<\/li>\n  <li>bet<\/li>\n  <li>between<\/li>\n  <li>big<\/li>\n  <li>bill<\/li>\n  <li>birth<\/li>\n  <li>bit<\/li>\n  <li>black<\/li>\n  <li>bloke<\/li>\n  <li>blood<\/li>\n  <li>blow<\/li>\n  <li>blue<\/li>\n  <li>board<\/li>\n  <li>boat<\/li>\n  <li>body<\/li>\n  <li>book<\/li>\n  <li>both<\/li>\n  <li>bother<\/li>\n  <li>bottle<\/li>\n  <li>bottom<\/li>\n  <li>box<\/li>\n  <li>boy<\/li>\n  <li>break<\/li>\n  <li>brief<\/li>\n  <li>brilliant<\/li>\n  <li>bring<\/li>\n  <li>britain<\/li>\n  <li>brother<\/li>\n  <li>budget<\/li>\n  <li>build<\/li>\n  <li>bus<\/li>\n  <li>b<span class='match'>usines<\/span>s<\/li>\n  <li>busy<\/li>\n  <li>but<\/li>\n  <li>buy<\/li>\n  <li>by<\/li>\n  <li>cake<\/li>\n  <li>call<\/li>\n  <li>can<\/li>\n  <li>car<\/li>\n  <li>card<\/li>\n  <li>care<\/li>\n  <li>carry<\/li>\n  <li>case<\/li>\n  <li>cat<\/li>\n  <li>catch<\/li>\n  <li>cause<\/li>\n  <li>cent<\/li>\n  <li>centre<\/li>\n  <li>certain<\/li>\n  <li>chair<\/li>\n  <li>chairman<\/li>\n  <li>chance<\/li>\n  <li>change<\/li>\n  <li>chap<\/li>\n  <li>ch<span class='match'>arac<\/span>ter<\/li>\n  <li>charge<\/li>\n  <li>cheap<\/li>\n  <li>check<\/li>\n  <li>child<\/li>\n  <li>choice<\/li>\n  <li>choose<\/li>\n  <li>Christ<\/li>\n  <li>Christmas<\/li>\n  <li>church<\/li>\n  <li>city<\/li>\n  <li>claim<\/li>\n  <li>class<\/li>\n  <li>clean<\/li>\n  <li>clear<\/li>\n  <li>client<\/li>\n  <li>clock<\/li>\n  <li>close<\/li>\n  <li>cl<span class='match'>oses<\/span><\/li>\n  <li>clothe<\/li>\n  <li>club<\/li>\n  <li>coffee<\/li>\n  <li>cold<\/li>\n  <li>colleague<\/li>\n  <li>collect<\/li>\n  <li>college<\/li>\n  <li>colour<\/li>\n  <li>come<\/li>\n  <li>comment<\/li>\n  <li>commit<\/li>\n  <li>committee<\/li>\n  <li>common<\/li>\n  <li>comm<span class='match'>unit<\/span>y<\/li>\n  <li>company<\/li>\n  <li>compare<\/li>\n  <li>complete<\/li>\n  <li>compute<\/li>\n  <li>concern<\/li>\n  <li>condition<\/li>\n  <li>confer<\/li>\n  <li>cons<span class='match'>ider<\/span><\/li>\n  <li>consult<\/li>\n  <li>contact<\/li>\n  <li>continue<\/li>\n  <li>contract<\/li>\n  <li>control<\/li>\n  <li>converse<\/li>\n  <li>cook<\/li>\n  <li>copy<\/li>\n  <li>corner<\/li>\n  <li>correct<\/li>\n  <li>cost<\/li>\n  <li>could<\/li>\n  <li>council<\/li>\n  <li>count<\/li>\n  <li>country<\/li>\n  <li>county<\/li>\n  <li>couple<\/li>\n  <li>course<\/li>\n  <li>court<\/li>\n  <li>c<span class='match'>over<\/span><\/li>\n  <li>create<\/li>\n  <li>cross<\/li>\n  <li>cup<\/li>\n  <li>current<\/li>\n  <li>cut<\/li>\n  <li>dad<\/li>\n  <li>danger<\/li>\n  <li>date<\/li>\n  <li>day<\/li>\n  <li>dead<\/li>\n  <li>deal<\/li>\n  <li>dear<\/li>\n  <li>d<span class='match'>ebat<\/span>e<\/li>\n  <li>d<span class='match'>ecid<\/span>e<\/li>\n  <li>d<span class='match'>ecis<\/span>ion<\/li>\n  <li>deep<\/li>\n  <li>d<span class='match'>efinit<\/span>e<\/li>\n  <li>degree<\/li>\n  <li>d<span class='match'>epar<\/span>tment<\/li>\n  <li>d<span class='match'>epen<\/span>d<\/li>\n  <li>describe<\/li>\n  <li>d<span class='match'>esig<\/span>n<\/li>\n  <li>detail<\/li>\n  <li>d<span class='match'>evelop<\/span><\/li>\n  <li>die<\/li>\n  <li>diff<span class='match'>eren<\/span>ce<\/li>\n  <li>diff<span class='match'>icul<\/span>t<\/li>\n  <li>dinner<\/li>\n  <li>d<span class='match'>irec<\/span>t<\/li>\n  <li>discuss<\/li>\n  <li>district<\/li>\n  <li>d<span class='match'>ivid<\/span>e<\/li>\n  <li>do<\/li>\n  <li>doctor<\/li>\n  <li>d<span class='match'>ocumen<\/span>t<\/li>\n  <li>dog<\/li>\n  <li>door<\/li>\n  <li>double<\/li>\n  <li>doubt<\/li>\n  <li>down<\/li>\n  <li>draw<\/li>\n  <li>dress<\/li>\n  <li>drink<\/li>\n  <li>drive<\/li>\n  <li>drop<\/li>\n  <li>dry<\/li>\n  <li>due<\/li>\n  <li>d<span class='match'>urin<\/span>g<\/li>\n  <li>each<\/li>\n  <li>early<\/li>\n  <li>east<\/li>\n  <li>easy<\/li>\n  <li>eat<\/li>\n  <li><span class='match'>econom<\/span>y<\/li>\n  <li><span class='match'>educat<\/span>e<\/li>\n  <li>effect<\/li>\n  <li>egg<\/li>\n  <li>eight<\/li>\n  <li>either<\/li>\n  <li><span class='match'>elec<\/span>t<\/li>\n  <li><span class='match'>elec<\/span>tric<\/li>\n  <li><span class='match'>eleven<\/span><\/li>\n  <li>else<\/li>\n  <li>employ<\/li>\n  <li>enco<span class='match'>urag<\/span>e<\/li>\n  <li>end<\/li>\n  <li>engine<\/li>\n  <li>english<\/li>\n  <li>enjoy<\/li>\n  <li>enough<\/li>\n  <li>enter<\/li>\n  <li>env<span class='match'>iron<\/span>ment<\/li>\n  <li>equal<\/li>\n  <li>especial<\/li>\n  <li>e<span class='match'>urop<\/span>e<\/li>\n  <li><span class='match'>even<\/span><\/li>\n  <li><span class='match'>evenin<\/span>g<\/li>\n  <li><span class='match'>ever<\/span><\/li>\n  <li><span class='match'>ever<\/span>y<\/li>\n  <li><span class='match'>eviden<\/span>ce<\/li>\n  <li><span class='match'>exac<\/span>t<\/li>\n  <li><span class='match'>exam<\/span>ple<\/li>\n  <li>except<\/li>\n  <li>excuse<\/li>\n  <li><span class='match'>exer<\/span>cise<\/li>\n  <li><span class='match'>exis<\/span>t<\/li>\n  <li>expect<\/li>\n  <li>expense<\/li>\n  <li>experience<\/li>\n  <li>explain<\/li>\n  <li>express<\/li>\n  <li>extra<\/li>\n  <li>eye<\/li>\n  <li>face<\/li>\n  <li>fact<\/li>\n  <li>fair<\/li>\n  <li>fall<\/li>\n  <li>f<span class='match'>amil<\/span>y<\/li>\n  <li>far<\/li>\n  <li>farm<\/li>\n  <li>fast<\/li>\n  <li>father<\/li>\n  <li>favour<\/li>\n  <li>feed<\/li>\n  <li>feel<\/li>\n  <li>few<\/li>\n  <li>field<\/li>\n  <li>fight<\/li>\n  <li>f<span class='match'>igur<\/span>e<\/li>\n  <li>file<\/li>\n  <li>fill<\/li>\n  <li>film<\/li>\n  <li>f<span class='match'>inal<\/span><\/li>\n  <li>f<span class='match'>inan<\/span>ce<\/li>\n  <li>find<\/li>\n  <li>fine<\/li>\n  <li>f<span class='match'>inis<\/span>h<\/li>\n  <li>fire<\/li>\n  <li>first<\/li>\n  <li>fish<\/li>\n  <li>fit<\/li>\n  <li>five<\/li>\n  <li>flat<\/li>\n  <li>floor<\/li>\n  <li>fly<\/li>\n  <li>follow<\/li>\n  <li>food<\/li>\n  <li>foot<\/li>\n  <li>for<\/li>\n  <li>force<\/li>\n  <li>forget<\/li>\n  <li>form<\/li>\n  <li>fortune<\/li>\n  <li>forward<\/li>\n  <li>four<\/li>\n  <li>france<\/li>\n  <li>free<\/li>\n  <li>fr<span class='match'>iday<\/span><\/li>\n  <li>friend<\/li>\n  <li>from<\/li>\n  <li>front<\/li>\n  <li>full<\/li>\n  <li>fun<\/li>\n  <li>function<\/li>\n  <li>fund<\/li>\n  <li>further<\/li>\n  <li>f<span class='match'>utur<\/span>e<\/li>\n  <li>game<\/li>\n  <li>garden<\/li>\n  <li>gas<\/li>\n  <li>g<span class='match'>eneral<\/span><\/li>\n  <li>germany<\/li>\n  <li>get<\/li>\n  <li>girl<\/li>\n  <li>give<\/li>\n  <li>glass<\/li>\n  <li>go<\/li>\n  <li>god<\/li>\n  <li>good<\/li>\n  <li>goodbye<\/li>\n  <li>g<span class='match'>over<\/span>n<\/li>\n  <li>grand<\/li>\n  <li>grant<\/li>\n  <li>great<\/li>\n  <li>green<\/li>\n  <li>ground<\/li>\n  <li>group<\/li>\n  <li>grow<\/li>\n  <li>guess<\/li>\n  <li>guy<\/li>\n  <li>hair<\/li>\n  <li>half<\/li>\n  <li>hall<\/li>\n  <li>hand<\/li>\n  <li>hang<\/li>\n  <li>happen<\/li>\n  <li>happy<\/li>\n  <li>hard<\/li>\n  <li>hate<\/li>\n  <li>have<\/li>\n  <li>he<\/li>\n  <li>head<\/li>\n  <li>health<\/li>\n  <li>hear<\/li>\n  <li>heart<\/li>\n  <li>heat<\/li>\n  <li>heavy<\/li>\n  <li>hell<\/li>\n  <li>help<\/li>\n  <li>here<\/li>\n  <li>high<\/li>\n  <li>history<\/li>\n  <li>hit<\/li>\n  <li>hold<\/li>\n  <li>h<span class='match'>oliday<\/span><\/li>\n  <li>home<\/li>\n  <li>h<span class='match'>ones<\/span>t<\/li>\n  <li>hope<\/li>\n  <li>horse<\/li>\n  <li>hosp<span class='match'>ital<\/span><\/li>\n  <li>hot<\/li>\n  <li>hour<\/li>\n  <li>house<\/li>\n  <li>how<\/li>\n  <li>h<span class='match'>owever<\/span><\/li>\n  <li>hullo<\/li>\n  <li>hundred<\/li>\n  <li>husband<\/li>\n  <li>idea<\/li>\n  <li><span class='match'>iden<\/span>tify<\/li>\n  <li>if<\/li>\n  <li><span class='match'>imagin<\/span>e<\/li>\n  <li>important<\/li>\n  <li>improve<\/li>\n  <li>in<\/li>\n  <li>include<\/li>\n  <li>income<\/li>\n  <li>increase<\/li>\n  <li>indeed<\/li>\n  <li>ind<span class='match'>ivid<\/span>ual<\/li>\n  <li>industry<\/li>\n  <li>inform<\/li>\n  <li>inside<\/li>\n  <li>instead<\/li>\n  <li>insure<\/li>\n  <li>int<span class='match'>eres<\/span>t<\/li>\n  <li>into<\/li>\n  <li>intr<span class='match'>oduc<\/span>e<\/li>\n  <li>invest<\/li>\n  <li>involve<\/li>\n  <li>issue<\/li>\n  <li>it<\/li>\n  <li><span class='match'>item<\/span><\/li>\n  <li>j<span class='match'>esus<\/span><\/li>\n  <li>job<\/li>\n  <li>join<\/li>\n  <li>judge<\/li>\n  <li>jump<\/li>\n  <li>just<\/li>\n  <li>keep<\/li>\n  <li>key<\/li>\n  <li>kid<\/li>\n  <li>kill<\/li>\n  <li>kind<\/li>\n  <li>king<\/li>\n  <li>kitchen<\/li>\n  <li>knock<\/li>\n  <li>know<\/li>\n  <li>labour<\/li>\n  <li>lad<\/li>\n  <li>lady<\/li>\n  <li>land<\/li>\n  <li>language<\/li>\n  <li>large<\/li>\n  <li>last<\/li>\n  <li>late<\/li>\n  <li>laugh<\/li>\n  <li>law<\/li>\n  <li>lay<\/li>\n  <li>lead<\/li>\n  <li>learn<\/li>\n  <li>leave<\/li>\n  <li>left<\/li>\n  <li>leg<\/li>\n  <li>less<\/li>\n  <li>let<\/li>\n  <li>letter<\/li>\n  <li>l<span class='match'>evel<\/span><\/li>\n  <li>lie<\/li>\n  <li>life<\/li>\n  <li>light<\/li>\n  <li>like<\/li>\n  <li>l<span class='match'>ikel<\/span>y<\/li>\n  <li>l<span class='match'>imit<\/span><\/li>\n  <li>line<\/li>\n  <li>link<\/li>\n  <li>list<\/li>\n  <li>listen<\/li>\n  <li>little<\/li>\n  <li>live<\/li>\n  <li>load<\/li>\n  <li>l<span class='match'>ocal<\/span><\/li>\n  <li>lock<\/li>\n  <li>london<\/li>\n  <li>long<\/li>\n  <li>look<\/li>\n  <li>lord<\/li>\n  <li>lose<\/li>\n  <li>lot<\/li>\n  <li>love<\/li>\n  <li>low<\/li>\n  <li>luck<\/li>\n  <li>lunch<\/li>\n  <li>machine<\/li>\n  <li>main<\/li>\n  <li>m<span class='match'>ajor<\/span><\/li>\n  <li>make<\/li>\n  <li>man<\/li>\n  <li>m<span class='match'>anag<\/span>e<\/li>\n  <li>many<\/li>\n  <li>mark<\/li>\n  <li>market<\/li>\n  <li>marry<\/li>\n  <li>match<\/li>\n  <li>matter<\/li>\n  <li>may<\/li>\n  <li>maybe<\/li>\n  <li>mean<\/li>\n  <li>me<span class='match'>anin<\/span>g<\/li>\n  <li>me<span class='match'>asur<\/span>e<\/li>\n  <li>meet<\/li>\n  <li>member<\/li>\n  <li>mention<\/li>\n  <li>middle<\/li>\n  <li>might<\/li>\n  <li>mile<\/li>\n  <li>milk<\/li>\n  <li>million<\/li>\n  <li>mind<\/li>\n  <li>m<span class='match'>inis<\/span>ter<\/li>\n  <li>m<span class='match'>inus<\/span><\/li>\n  <li>m<span class='match'>inut<\/span>e<\/li>\n  <li>miss<\/li>\n  <li>mister<\/li>\n  <li>m<span class='match'>omen<\/span>t<\/li>\n  <li>monday<\/li>\n  <li>m<span class='match'>oney<\/span><\/li>\n  <li>month<\/li>\n  <li>more<\/li>\n  <li>morning<\/li>\n  <li>most<\/li>\n  <li>mother<\/li>\n  <li>motion<\/li>\n  <li>move<\/li>\n  <li>mrs<\/li>\n  <li>much<\/li>\n  <li>m<span class='match'>usic<\/span><\/li>\n  <li>must<\/li>\n  <li>name<\/li>\n  <li>nation<\/li>\n  <li>n<span class='match'>atur<\/span>e<\/li>\n  <li>near<\/li>\n  <li>n<span class='match'>eces<\/span>sary<\/li>\n  <li>need<\/li>\n  <li>n<span class='match'>ever<\/span><\/li>\n  <li>new<\/li>\n  <li>news<\/li>\n  <li>next<\/li>\n  <li>nice<\/li>\n  <li>night<\/li>\n  <li>nine<\/li>\n  <li>no<\/li>\n  <li>non<\/li>\n  <li>none<\/li>\n  <li>normal<\/li>\n  <li>north<\/li>\n  <li>not<\/li>\n  <li>note<\/li>\n  <li>n<span class='match'>otic<\/span>e<\/li>\n  <li>now<\/li>\n  <li>number<\/li>\n  <li>obvious<\/li>\n  <li>occasion<\/li>\n  <li>odd<\/li>\n  <li>of<\/li>\n  <li>off<\/li>\n  <li>offer<\/li>\n  <li>office<\/li>\n  <li>often<\/li>\n  <li><span class='match'>okay<\/span><\/li>\n  <li>old<\/li>\n  <li>on<\/li>\n  <li>once<\/li>\n  <li>one<\/li>\n  <li>only<\/li>\n  <li><span class='match'>open<\/span><\/li>\n  <li><span class='match'>operat<\/span>e<\/li>\n  <li>opport<span class='match'>unit<\/span>y<\/li>\n  <li>oppose<\/li>\n  <li>or<\/li>\n  <li>order<\/li>\n  <li>org<span class='match'>aniz<\/span>e<\/li>\n  <li><span class='match'>original<\/span><\/li>\n  <li>other<\/li>\n  <li>otherwise<\/li>\n  <li>ought<\/li>\n  <li>out<\/li>\n  <li><span class='match'>over<\/span><\/li>\n  <li>own<\/li>\n  <li>pack<\/li>\n  <li>page<\/li>\n  <li>paint<\/li>\n  <li>pair<\/li>\n  <li>p<span class='match'>aper<\/span><\/li>\n  <li>p<span class='match'>arag<\/span>raph<\/li>\n  <li>pardon<\/li>\n  <li>p<span class='match'>aren<\/span>t<\/li>\n  <li>park<\/li>\n  <li>part<\/li>\n  <li>part<span class='match'>icular<\/span><\/li>\n  <li>party<\/li>\n  <li>pass<\/li>\n  <li>past<\/li>\n  <li>pay<\/li>\n  <li>pence<\/li>\n  <li>pension<\/li>\n  <li>people<\/li>\n  <li>per<\/li>\n  <li>percent<\/li>\n  <li>perfect<\/li>\n  <li>perhaps<\/li>\n  <li>period<\/li>\n  <li>person<\/li>\n  <li>ph<span class='match'>otog<\/span>raph<\/li>\n  <li>pick<\/li>\n  <li>picture<\/li>\n  <li>piece<\/li>\n  <li>place<\/li>\n  <li>plan<\/li>\n  <li>play<\/li>\n  <li>please<\/li>\n  <li>plus<\/li>\n  <li>point<\/li>\n  <li>p<span class='match'>olic<\/span>e<\/li>\n  <li>p<span class='match'>olic<\/span>y<\/li>\n  <li>p<span class='match'>olitic<\/span><\/li>\n  <li>poor<\/li>\n  <li>p<span class='match'>osit<\/span>ion<\/li>\n  <li>p<span class='match'>ositiv<\/span>e<\/li>\n  <li>possible<\/li>\n  <li>post<\/li>\n  <li>pound<\/li>\n  <li>p<span class='match'>ower<\/span><\/li>\n  <li>practise<\/li>\n  <li>pr<span class='match'>epar<\/span>e<\/li>\n  <li>pr<span class='match'>esen<\/span>t<\/li>\n  <li>press<\/li>\n  <li>pressure<\/li>\n  <li>pr<span class='match'>esum<\/span>e<\/li>\n  <li>pretty<\/li>\n  <li>previous<\/li>\n  <li>price<\/li>\n  <li>print<\/li>\n  <li>pr<span class='match'>ivat<\/span>e<\/li>\n  <li>pr<span class='match'>obab<\/span>le<\/li>\n  <li>problem<\/li>\n  <li>proceed<\/li>\n  <li>pr<span class='match'>oces<\/span>s<\/li>\n  <li>pr<span class='match'>oduc<\/span>e<\/li>\n  <li>pr<span class='match'>oduc<\/span>t<\/li>\n  <li>programme<\/li>\n  <li>pr<span class='match'>ojec<\/span>t<\/li>\n  <li>pr<span class='match'>oper<\/span><\/li>\n  <li>pr<span class='match'>opos<\/span>e<\/li>\n  <li>pr<span class='match'>otec<\/span>t<\/li>\n  <li>pr<span class='match'>ovid<\/span>e<\/li>\n  <li>public<\/li>\n  <li>pull<\/li>\n  <li>purpose<\/li>\n  <li>push<\/li>\n  <li>put<\/li>\n  <li>qu<span class='match'>alit<\/span>y<\/li>\n  <li>quarter<\/li>\n  <li>question<\/li>\n  <li>quick<\/li>\n  <li>quid<\/li>\n  <li>quiet<\/li>\n  <li>quite<\/li>\n  <li>radio<\/li>\n  <li>rail<\/li>\n  <li>raise<\/li>\n  <li>range<\/li>\n  <li>rate<\/li>\n  <li>rather<\/li>\n  <li>read<\/li>\n  <li>ready<\/li>\n  <li>real<\/li>\n  <li>re<span class='match'>alis<\/span>e<\/li>\n  <li>really<\/li>\n  <li>re<span class='match'>ason<\/span><\/li>\n  <li>receive<\/li>\n  <li>r<span class='match'>ecen<\/span>t<\/li>\n  <li>reckon<\/li>\n  <li>r<span class='match'>ecog<\/span>nize<\/li>\n  <li>r<span class='match'>ecom<\/span>mend<\/li>\n  <li>r<span class='match'>ecor<\/span>d<\/li>\n  <li>red<\/li>\n  <li>r<span class='match'>educ<\/span>e<\/li>\n  <li>r<span class='match'>efer<\/span><\/li>\n  <li>r<span class='match'>egar<\/span>d<\/li>\n  <li>region<\/li>\n  <li>r<span class='match'>elat<\/span>ion<\/li>\n  <li>r<span class='match'>emem<\/span>ber<\/li>\n  <li>r<span class='match'>epor<\/span>t<\/li>\n  <li>repr<span class='match'>esen<\/span>t<\/li>\n  <li>require<\/li>\n  <li>research<\/li>\n  <li>resource<\/li>\n  <li>respect<\/li>\n  <li>responsible<\/li>\n  <li>rest<\/li>\n  <li>r<span class='match'>esul<\/span>t<\/li>\n  <li>r<span class='match'>etur<\/span>n<\/li>\n  <li>rid<\/li>\n  <li>right<\/li>\n  <li>ring<\/li>\n  <li>rise<\/li>\n  <li>road<\/li>\n  <li>role<\/li>\n  <li>roll<\/li>\n  <li>room<\/li>\n  <li>round<\/li>\n  <li>rule<\/li>\n  <li>run<\/li>\n  <li>safe<\/li>\n  <li>sale<\/li>\n  <li>same<\/li>\n  <li>s<span class='match'>atur<\/span>day<\/li>\n  <li>save<\/li>\n  <li>say<\/li>\n  <li>scheme<\/li>\n  <li>school<\/li>\n  <li>science<\/li>\n  <li>score<\/li>\n  <li>scotland<\/li>\n  <li>seat<\/li>\n  <li>s<span class='match'>econ<\/span>d<\/li>\n  <li>secr<span class='match'>etar<\/span>y<\/li>\n  <li>section<\/li>\n  <li>s<span class='match'>ecur<\/span>e<\/li>\n  <li>see<\/li>\n  <li>seem<\/li>\n  <li>self<\/li>\n  <li>sell<\/li>\n  <li>send<\/li>\n  <li>sense<\/li>\n  <li>s<span class='match'>eparat<\/span>e<\/li>\n  <li>serious<\/li>\n  <li>serve<\/li>\n  <li>service<\/li>\n  <li>set<\/li>\n  <li>settle<\/li>\n  <li>s<span class='match'>even<\/span><\/li>\n  <li>sex<\/li>\n  <li>shall<\/li>\n  <li>share<\/li>\n  <li>she<\/li>\n  <li>sheet<\/li>\n  <li>shoe<\/li>\n  <li>shoot<\/li>\n  <li>shop<\/li>\n  <li>short<\/li>\n  <li>should<\/li>\n  <li>show<\/li>\n  <li>shut<\/li>\n  <li>sick<\/li>\n  <li>side<\/li>\n  <li>sign<\/li>\n  <li>s<span class='match'>imilar<\/span><\/li>\n  <li>simple<\/li>\n  <li>since<\/li>\n  <li>sing<\/li>\n  <li>single<\/li>\n  <li>sir<\/li>\n  <li>sister<\/li>\n  <li>sit<\/li>\n  <li>site<\/li>\n  <li>situate<\/li>\n  <li>six<\/li>\n  <li>size<\/li>\n  <li>sleep<\/li>\n  <li>slight<\/li>\n  <li>slow<\/li>\n  <li>small<\/li>\n  <li>smoke<\/li>\n  <li>so<\/li>\n  <li>social<\/li>\n  <li>society<\/li>\n  <li>some<\/li>\n  <li>son<\/li>\n  <li>soon<\/li>\n  <li>sorry<\/li>\n  <li>sort<\/li>\n  <li>sound<\/li>\n  <li>south<\/li>\n  <li>space<\/li>\n  <li>speak<\/li>\n  <li>special<\/li>\n  <li>sp<span class='match'>ecific<\/span><\/li>\n  <li>speed<\/li>\n  <li>spell<\/li>\n  <li>spend<\/li>\n  <li>square<\/li>\n  <li>staff<\/li>\n  <li>stage<\/li>\n  <li>stairs<\/li>\n  <li>stand<\/li>\n  <li>standard<\/li>\n  <li>start<\/li>\n  <li>state<\/li>\n  <li>station<\/li>\n  <li>stay<\/li>\n  <li>step<\/li>\n  <li>stick<\/li>\n  <li>still<\/li>\n  <li>stop<\/li>\n  <li>story<\/li>\n  <li>straight<\/li>\n  <li>str<span class='match'>ateg<\/span>y<\/li>\n  <li>street<\/li>\n  <li>strike<\/li>\n  <li>strong<\/li>\n  <li>structure<\/li>\n  <li>st<span class='match'>uden<\/span>t<\/li>\n  <li>study<\/li>\n  <li>stuff<\/li>\n  <li>st<span class='match'>upid<\/span><\/li>\n  <li>subject<\/li>\n  <li>succeed<\/li>\n  <li>such<\/li>\n  <li>sudden<\/li>\n  <li>suggest<\/li>\n  <li>suit<\/li>\n  <li>summer<\/li>\n  <li>sun<\/li>\n  <li>sunday<\/li>\n  <li>supply<\/li>\n  <li>support<\/li>\n  <li>suppose<\/li>\n  <li>sure<\/li>\n  <li>surprise<\/li>\n  <li>switch<\/li>\n  <li>system<\/li>\n  <li>table<\/li>\n  <li>take<\/li>\n  <li>talk<\/li>\n  <li>tape<\/li>\n  <li>tax<\/li>\n  <li>tea<\/li>\n  <li>teach<\/li>\n  <li>team<\/li>\n  <li>t<span class='match'>elep<\/span>hone<\/li>\n  <li>t<span class='match'>elevis<\/span>ion<\/li>\n  <li>tell<\/li>\n  <li>ten<\/li>\n  <li>tend<\/li>\n  <li>term<\/li>\n  <li>terrible<\/li>\n  <li>test<\/li>\n  <li>than<\/li>\n  <li>thank<\/li>\n  <li>the<\/li>\n  <li>then<\/li>\n  <li>there<\/li>\n  <li>th<span class='match'>erefor<\/span>e<\/li>\n  <li>they<\/li>\n  <li>thing<\/li>\n  <li>think<\/li>\n  <li>thirteen<\/li>\n  <li>thirty<\/li>\n  <li>this<\/li>\n  <li>thou<\/li>\n  <li>though<\/li>\n  <li>tho<span class='match'>usan<\/span>d<\/li>\n  <li>three<\/li>\n  <li>through<\/li>\n  <li>throw<\/li>\n  <li>thursday<\/li>\n  <li>tie<\/li>\n  <li>time<\/li>\n  <li>to<\/li>\n  <li>t<span class='match'>oday<\/span><\/li>\n  <li>t<span class='match'>oget<\/span>her<\/li>\n  <li>t<span class='match'>omor<\/span>row<\/li>\n  <li>t<span class='match'>onig<\/span>ht<\/li>\n  <li>too<\/li>\n  <li>top<\/li>\n  <li>t<span class='match'>otal<\/span><\/li>\n  <li>touch<\/li>\n  <li>t<span class='match'>owar<\/span>d<\/li>\n  <li>town<\/li>\n  <li>trade<\/li>\n  <li>traffic<\/li>\n  <li>train<\/li>\n  <li>transport<\/li>\n  <li>tr<span class='match'>avel<\/span><\/li>\n  <li>treat<\/li>\n  <li>tree<\/li>\n  <li>trouble<\/li>\n  <li>true<\/li>\n  <li>trust<\/li>\n  <li>try<\/li>\n  <li>tuesday<\/li>\n  <li>turn<\/li>\n  <li>twelve<\/li>\n  <li>twenty<\/li>\n  <li>two<\/li>\n  <li>type<\/li>\n  <li>under<\/li>\n  <li>understand<\/li>\n  <li>union<\/li>\n  <li><span class='match'>unit<\/span><\/li>\n  <li><span class='match'>unit<\/span>e<\/li>\n  <li><span class='match'>univer<\/span>sity<\/li>\n  <li>unless<\/li>\n  <li>until<\/li>\n  <li>up<\/li>\n  <li><span class='match'>upon<\/span><\/li>\n  <li>use<\/li>\n  <li>usual<\/li>\n  <li>value<\/li>\n  <li>various<\/li>\n  <li>very<\/li>\n  <li>video<\/li>\n  <li>view<\/li>\n  <li>village<\/li>\n  <li>v<span class='match'>isit<\/span><\/li>\n  <li>vote<\/li>\n  <li>wage<\/li>\n  <li>wait<\/li>\n  <li>walk<\/li>\n  <li>wall<\/li>\n  <li>want<\/li>\n  <li>war<\/li>\n  <li>warm<\/li>\n  <li>wash<\/li>\n  <li>waste<\/li>\n  <li>watch<\/li>\n  <li>w<span class='match'>ater<\/span><\/li>\n  <li>way<\/li>\n  <li>we<\/li>\n  <li>wear<\/li>\n  <li>wednesday<\/li>\n  <li>wee<\/li>\n  <li>week<\/li>\n  <li>weigh<\/li>\n  <li>welcome<\/li>\n  <li>well<\/li>\n  <li>west<\/li>\n  <li>what<\/li>\n  <li>when<\/li>\n  <li>where<\/li>\n  <li>whether<\/li>\n  <li>which<\/li>\n  <li>while<\/li>\n  <li>white<\/li>\n  <li>who<\/li>\n  <li>whole<\/li>\n  <li>why<\/li>\n  <li>wide<\/li>\n  <li>wife<\/li>\n  <li>will<\/li>\n  <li>win<\/li>\n  <li>wind<\/li>\n  <li>window<\/li>\n  <li>wish<\/li>\n  <li>with<\/li>\n  <li>within<\/li>\n  <li>without<\/li>\n  <li>w<span class='match'>oman<\/span><\/li>\n  <li>wonder<\/li>\n  <li>wood<\/li>\n  <li>word<\/li>\n  <li>work<\/li>\n  <li>world<\/li>\n  <li>worry<\/li>\n  <li>worse<\/li>\n  <li>worth<\/li>\n  <li>would<\/li>\n  <li>write<\/li>\n  <li>wrong<\/li>\n  <li>year<\/li>\n  <li>yes<\/li>\n  <li>yesterday<\/li>\n  <li>yet<\/li>\n  <li>you<\/li>\n  <li>young<\/li>\n<\/ul>"},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

  
4. Solve the beginner regexp crosswords at https://regexcrossword.com/challenges/

Exercise left to reader. That site validates its solutions, so they aren't repeated here.

### Grouping and backreferences

1. Describe, in words, what these expressions will match:

  1. `(.)\1\1` : The same character appearing three times in a row. E.g. `"aaa"`
  2. `"(.)(.)\\2\\1"`: A pair of characters followed by the same pair of characters in reversed order. E.g. `"abba"`.
  3. `(..)\1`: Any two characters repeated. E.g. `"a1a1"`.
  4. `"(.).\\1.\\1"`: A character followed by any character, the original character, any other character, the original character again. E.g. `"abaca"`, `"b8b.b"`.
  5. `"(.)(.)(.).*\\3\\2\\1"` Three characters followed by zero or more characters of any kind followed by the same three characters but in reverse order. E.g. `"abcsgasgddsadgsdgcba"` or `"abccba"` or `"abc1cba"`.
  
2. Construct regular expressions to match words that:

  1. Start and end with the same character. Assuming the word is more than one character and all strings are considered words, `^(.).*\1$`
  

```r
str_subset(words, "^(.).*\\1$")
#>  [1] "america"    "area"       "dad"        "dead"       "depend"    
#>  [6] "educate"    "else"       "encourage"  "engine"     "europe"    
#> [11] "evidence"   "example"    "excuse"     "exercise"   "expense"   
#> [16] "experience" "eye"        "health"     "high"       "knock"     
#> [21] "level"      "local"      "nation"     "non"        "rather"    
#> [26] "refer"      "remember"   "serious"    "stairs"     "test"      
#> [31] "tonight"    "transport"  "treat"      "trust"      "window"    
#> [36] "yesterday"
```

  2 Contain a repeated pair of letters (e.g. “church” contains “ch” repeated twice.). 
  

```r
# any two characters repeated
str_subset(words, "(..).*\\1")
```

```r
# more stringent, letters only, but also allowing for differences in capitalization
str_view(str_to_lower(words), "([a-z][a-z]).*\\1")
```


  3. Contain one letter repeated in at least three places (e.g. “eleven” contains three “e”s.)
  

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


2. What word has the highest number of vowels? What word has the highest proportion of vowels? (Hint: what is the denominator?)


```r
prop_vowels <- str_count(words, "[aeiou]") / str_length(words)
words[which(prop_vowels == max(prop_vowels))]
#> [1] "a"
```

### Extract Matches


1. In the previous example, you might have noticed that the regular expression matched “flickered”, which is not a color. Modify the regex to fix the problem.

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

### Replacing Matches


1. Replace all forward slashes in a string with backslashes.

```r
backslashed <- str_replace_all("past/present/future", "\\/", "\\\\")
writeLines(backslashed)
#> past\present\future
```

2. Implement a simple version of `str_to_lower()` using `replace_all()`.

```r
lower <- str_replace_all(words, c("A"="a", "B"="b", "C"="c", "D"="d", "E"="e", "F"="f", "G"="g", "H"="h", "I"="i", "J"="j", "K"="k", "L"="l", "M"="m", "N"="n", "O"="o", "P"="p", "Q"="q", "R"="r", "S"="s", "T"="t", "U"="u", "V"="v", "W"="w", "X"="x", "Y"="y", "Z"="z"))
```

3. Switch the first and last letters in `words`. Which of those strings are still words?

```r
# First, make a vector of all the words with first and last letters swapped
swapped <- str_replace_all(words, "^([A-Za-z])(.*)([a-z])$", "\\3\\2\\1")
# Next, find what of "swapped" is also in the original list using intersect() from previous chapter
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

### Find matches

No exercises

## Other types of patterns


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


1. Find the **stringi** functions that:

    1. Count the number of words. `stri_count_words`
    2. Find duplicated strings. `stri_duplicated`
    2. Generate random text. There are several functions beginning with `stri_rand_`. `stri_rand_lipsum` generates lorem ipsum text, `stri_rand_strings` generates random strings, `stri_rand_shuffle` randomly shuffles the code points in the text.

2. How do you control the language that `stri_sort()` uses for sorting?

Use the `locale` argument to the `opts_collator` argument.
