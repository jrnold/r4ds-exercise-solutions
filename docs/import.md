
---
output: html_document
editor_options:
  chunk_output_type: console
---
# Data import

## Introduction


```r
library("tidyverse")
```

## Getting started

### Exercise <span class="exercise-number">11.2.1</span> {.unnumbered .exercise}

<div class="question">
What function would you use to read a file where fields were separated with “|”?
</div>

<div class="answer">

Use the `read_delim()` function with the argument `delim="|"`.

```r
read_delim(file, delim = "|")
```

</div>

### Exercise <span class="exercise-number">11.2.2</span> {.unnumbered .exercise}

<div class="question">
Apart from `file`, `skip`, and `comment`, what other arguments do `read_csv()` and `read_tsv()` have in common?
</div>

<div class="answer">

They have the following arguments in common:

```r
union(names(formals(read_csv)), names(formals(read_tsv)))
#>  [1] "file"      "col_names" "col_types" "locale"    "na"       
#>  [6] "quoted_na" "quote"     "comment"   "trim_ws"   "skip"     
#> [11] "n_max"     "guess_max" "progress"
```

-   `col_names` and `col_types` are used to specify the column names and how to parse the columns
-   `locale` is important for determining things like the encoding and whether "." or "," is used as a decimal mark.
-   `na` and `quoted_na` control which strings are treated as missing values when parsing vectors
-   `trim_ws` trims whitespace before and after cells before parsing
-   `n_max` sets how many rows to read
-   `guess_max` sets how many rows to use when guessing the column type
-   `progress` determines whether a progress bar is shown.

</div>

### Exercise <span class="exercise-number">11.2.3</span> {.unnumbered .exercise}

<div class="question">
What are the most important arguments to `read_fwf()`?
</div>

<div class="answer">

The most important argument to `read_fwf()` which reads "fixed-width formats", is `col_positions` which tells the function where data columns begin and end.

</div>

### Exercise <span class="exercise-number">11.2.4</span> {.unnumbered .exercise}

<div class="question">
Sometimes strings in a CSV file contain commas.
To prevent them from causing problems they need to be surrounded by a quoting character, like `"` or `'`.
By convention, `read_csv()` assumes that the quoting character will be `"`, and if you want to change it you’ll need to use `read_delim()` instead.
What arguments do you need to specify to read the following text into a data frame?

```
"x,y\n1,'a,b'"
```

</div>

<div class="answer">

For `read_delim()`, we will will need to specify a delimiter, in this case `","`, and a quote argument.

```r
x <- "x,y\n1,'a,b'"
read_delim(x, ",", quote = "'")
#> # A tibble: 1 x 2
#>       x y    
#>   <int> <chr>
#> 1     1 a,b
```

However, this question is out of date. `read_csv()` now supports a quote argument, so the following code works.

```r
read_csv(x, quote = "'")
#> # A tibble: 1 x 2
#>       x y    
#>   <int> <chr>
#> 1     1 a,b
```

</div>

### Exercise <span class="exercise-number">11.2.5</span> {.unnumbered .exercise}

<div class="question">
Identify what is wrong with each of the following inline CSV files.
What happens when you run the code?
</div>

<div class="answer">


```r
read_csv("a,b\n1,2,3\n4,5,6")
#> Warning: 2 parsing failures.
#> row # A tibble: 2 x 5 col     row col   expected  actual    file         expected   <int> <chr> <chr>     <chr>     <chr>        actual 1     1 <NA>  2 columns 3 columns literal data file 2     2 <NA>  2 columns 3 columns literal data
#> # A tibble: 2 x 2
#>       a     b
#>   <int> <int>
#> 1     1     2
#> 2     4     5
```

Only two columns are specified in the header "a" and "b", but the rows have three columns, so the last column is dropped.


```r
read_csv("a,b,c\n1,2\n1,2,3,4")
#> Warning: 2 parsing failures.
#> row # A tibble: 2 x 5 col     row col   expected  actual    file         expected   <int> <chr> <chr>     <chr>     <chr>        actual 1     1 <NA>  3 columns 2 columns literal data file 2     2 <NA>  3 columns 4 columns literal data
#> # A tibble: 2 x 3
#>       a     b     c
#>   <int> <int> <int>
#> 1     1     2    NA
#> 2     1     2     3
```

The numbers of columns in the data do not match the number of columns in the header (three).
In row one, there are only two values, so column `c` is set to missing.
In row two, there is an extra value, and that value is dropped.


```r
read_csv("a,b\n\"1")
#> Warning: 2 parsing failures.
#> row # A tibble: 2 x 5 col     row col   expected                     actual    file         expected   <int> <chr> <chr>                        <chr>     <chr>        actual 1     1 a     closing quote at end of file ""        literal data file 2     1 <NA>  2 columns                    1 columns literal data
#> # A tibble: 1 x 2
#>       a b    
#>   <int> <chr>
#> 1     1 <NA>
```
It's not clear what the intent was here.
The opening quote `"1` is dropped because it is not closed, and `a` is treated as an integer.


```r
read_csv("a,b\n1,2\na,b")
#> # A tibble: 2 x 2
#>   a     b    
#>   <chr> <chr>
#> 1 1     2    
#> 2 a     b
```
Both "a" and "b" are treated as character vectors since they contain non-numeric strings.
This may have been intentional, or the author may have intended the values of the columns to be "1,2" and "a,b".


```r
read_csv("a;b\n1;3")
#> # A tibble: 1 x 1
#>   `a;b`
#>   <chr>
#> 1 1;3
```

The values are separated by ";" rather than ",". Use `read_csv2()` instead:

```r
read_csv2("a;b\n1;3")
#> Using ',' as decimal and '.' as grouping mark. Use read_delim() for more control.
#> # A tibble: 1 x 2
#>       a     b
#>   <int> <int>
#> 1     1     3
```

</div>

## Parsing a vector

### Exercise <span class="exercise-number">11.3.1</span> {.unnumbered .exercise}

<div class="question">
What are the most important arguments to `locale()`?
</div>

<div class="answer">

The locale object has arguments to set the following:

-   date and time formats: `date_names`, `date_format`, and `time_format`
-   time zone: `tz`
-   numbers: `decimal_mark`, `grouping_mark`
-   encoding: `encoding`

</div>

### Exercise <span class="exercise-number">11.3.2</span> {.unnumbered .exercise}

<div class="question">
What happens if you try and set `decimal_mark` and `grouping_mark` to the same character?
What happens to the default value of `grouping_mark` when you set `decimal_mark` to `","`?
What happens to the default value of `decimal_mark` when you set the `grouping_mark` to `"."`?
</div>

<div class="answer">

If the decimal and grouping marks are set to the same character, `locale` throws an error:

```r
locale(decimal_mark = ".", grouping_mark = ".")
#> Error: `decimal_mark` and `grouping_mark` must be different
```
If the `decimal_mark` is set to the comma "`,"`, then the grouping mark is set to the period `"."`:

```r
locale(decimal_mark = ",")
#> <locale>
#> Numbers:  123.456,78
#> Formats:  %AD / %AT
#> Timezone: UTC
#> Encoding: UTF-8
#> <date_names>
#> Days:   Sunday (Sun), Monday (Mon), Tuesday (Tue), Wednesday (Wed),
#>         Thursday (Thu), Friday (Fri), Saturday (Sat)
#> Months: January (Jan), February (Feb), March (Mar), April (Apr), May
#>         (May), June (Jun), July (Jul), August (Aug), September
#>         (Sep), October (Oct), November (Nov), December (Dec)
#> AM/PM:  AM/PM
```

If the grouping mark is set to a period, then the decimal mark is set to a comma

```r
locale(grouping_mark = ",")
#> <locale>
#> Numbers:  123,456.78
#> Formats:  %AD / %AT
#> Timezone: UTC
#> Encoding: UTF-8
#> <date_names>
#> Days:   Sunday (Sun), Monday (Mon), Tuesday (Tue), Wednesday (Wed),
#>         Thursday (Thu), Friday (Fri), Saturday (Sat)
#> Months: January (Jan), February (Feb), March (Mar), April (Apr), May
#>         (May), June (Jun), July (Jul), August (Aug), September
#>         (Sep), October (Oct), November (Nov), December (Dec)
#> AM/PM:  AM/PM
```

</div>

### Exercise <span class="exercise-number">11.3.3</span> {.unnumbered .exercise}

<div class="question">
I didn’t discuss the `date_format` and `time_format` options to `locale()`.
What do they do?
Construct an example that shows when they might be useful.
</div>

<div class="answer">

They provide default date and time formats.
The [readr vignette](https://cran.r-project.org/web/packages/readr/vignettes/locales.html) discusses using these to parse dates: since dates can include languages specific weekday and month names, and different conventions for specifying AM/PM

```r
locale()
#> <locale>
#> Numbers:  123,456.78
#> Formats:  %AD / %AT
#> Timezone: UTC
#> Encoding: UTF-8
#> <date_names>
#> Days:   Sunday (Sun), Monday (Mon), Tuesday (Tue), Wednesday (Wed),
#>         Thursday (Thu), Friday (Fri), Saturday (Sat)
#> Months: January (Jan), February (Feb), March (Mar), April (Apr), May
#>         (May), June (Jun), July (Jul), August (Aug), September
#>         (Sep), October (Oct), November (Nov), December (Dec)
#> AM/PM:  AM/PM
```

Examples from the **readr** vignette of parsing French dates

```r
parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))
#> [1] "2015-01-01"
parse_date("14 oct. 1979", "%d %b %Y", locale = locale("fr"))
#> [1] "1979-10-14"
```
Apparently the time format is not used for anything, but the date format is used for guessing column types.

</div>

### Exercise <span class="exercise-number">11.3.4</span> {.unnumbered .exercise}

<div class="question">
If you live outside the US, create a new locale object that encapsulates the settings for the types of file you read most commonly.
</div>

<div class="answer">

Read the help page for `locale()` using `?locale` to learn about the different variables that can be set.

As an example, consider Australia.
Most of the defaults values are valid, except that the date format is "(d)d/mm/yyyy", meaning that January 2, 2006 is written as `02/01/2006`.

However, default locale will parse that date as February 1, 2006.


```r
parse_date("02/01/2006")
#> Warning: 1 parsing failure.
#> row # A tibble: 1 x 4 col     row   col expected     actual     expected   <int> <int> <chr>        <chr>      actual 1     1    NA "date like " 02/01/2006
#> [1] NA
```

To correctly parse Australian dates, define a new `locale` object.


```r
au_locale <- locale(date_format = "%d/%m/%Y")
```

Using `parse_date()` with the `au_locale` as its locale will correctly parse our example date.


```r
parse_date("02/01/2006", locale = au_locale)
#> [1] "2006-01-02"
```

</div>

### Exercise <span class="exercise-number">11.3.5</span> {.unnumbered .exercise}

<div class="question">
What’s the difference between `read_csv()` and `read_csv2()`?
</div>

<div class="answer">

The delimiter. The function `read_csv()` uses a comma, while `read_csv2()` uses a semi-colon (`;`). Using a semi-colon is useful when commas are used as the decimal point (as in Europe).

div>

### Exercise <span class="exercise-number">11.3.6</span> {.unnumbered .exercise}

<div class="question">
What are the most common encodings used in Europe?
What are the most common encodings used in Asia?
Do some googling to find out.
</div>

<div class="answer">

UTF-8 is standard now, and ASCII has been around forever.

For the European languages, there are separate encodings for Romance languages and Eastern European languages using Latin script, Cyrillic, Greek, Hebrew, Turkish: usually with separate ISO and Windows encoding standards.
There is also Mac OS Roman.

For Asian languages Arabic and Vietnamese have ISO and Windows standards. The other major Asian scripts have their own:

-   Japanese: JIS X 0208, Shift JIS, ISO-2022-JP
-   Chinese: GB 2312, GBK, GB 18030
-   Korean: KS X 1001, EUC-KR, ISO-2022-KR

The list in the documentation for `stringi::stri_enc_detect()` is a good list of encodings since it supports the most common encodings.

-   Western European Latin script languages: ISO-8859-1, Windows-1250 (also CP-1250 for code-point)
-   Eastern European Latin script languages: ISO-8859-2, Windows-1252
-   Greek: ISO-8859-7
-   Turkish: ISO-8859-9, Windows-1254
-   Hebrew: ISO-8859-8, IBM424, Windows 1255
-   Russian: Windows 1251
-   Japanese: Shift JIS, ISO-2022-JP, EUC-JP
-   Korean: ISO-2022-KR, EUC-KR
-   Chinese: GB18030, ISO-2022-CN (Simplified), Big5 (Traditional)
-   Arabic: ISO-8859-6, IBM420, Windows 1256

For more information on character encodings see the following sources.

-   The Wikipedia page [Character encoding](https://en.wikipedia.org/wiki/Character_encoding), has a good list of encodings.
-   Unicode [CLDR](http://cldr.unicode.org/) project
-   [What is the most common encoding of each language](https://stackoverflow.com/questions/8509339/what-is-the-most-common-encoding-of-each-language) (Stack Overflow)
-   "What Every Programmer Absolutely, Positively Needs To Know About Encodings And Character Sets To Work With Text", <http://kunststube.net/encoding/>.

Programs that identify the encoding of text include

-   `guess_encoding()` in the **reader** package
-   `str_enc_detect()` in the **stringi** package
-   [iconv](https://en.wikipedia.org/wiki/Iconv)
-   [chardet](https://github.com/chardet/chardet) (Python)

</div>

### Exercise <span class="exercise-number">11.3.7</span> {.unnumbered .exercise}

<div class="question">
Generate the correct format string to parse each of the following dates and times:
</div>

<div class="answer">


```r
d1 <- "January 1, 2010"
d2 <- "2015-Mar-07"
d3 <- "06-Jun-2017"
d4 <- c("August 19 (2015)", "July 1 (2015)")
d5 <- "12/30/14" # Dec 30, 2014
t1 <- "1705"
t2 <- "11:15:10.12 PM"
```

The correct formats are:

```r
parse_date(d1, "%B %d, %Y")
#> [1] "2010-01-01"
parse_date(d2, "%Y-%b-%d")
#> [1] "2015-03-07"
parse_date(d3, "%d-%b-%Y")
#> [1] "2017-06-06"
parse_date(d4, "%B %d (%Y)")
#> [1] "2015-08-19" "2015-07-01"
parse_date(d5, "%m/%d/%y")
#> [1] "2014-12-30"
parse_time(t1, "%H%M")
#> 17:05:00
```
The time `t2` uses real seconds,

```r
parse_time(t2, "%H:%M:%OS %p")
#> 23:15:10.12
```

</div>

## Parsing a file

No exercises

## Writing to a file

No exercises

## Other Types of Data

No code

</div><!-- close unclosed div -->
