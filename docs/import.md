
# Data Import

## Introduction 


```r
library("tidyverse")
```

## Getting started

No code
    
### Exercises

1. What function would you use to read a file where fields were separated with
“|”?

I'd use `read_delim` with `delim="|"`:

```r
read_delim(file, delim = "|")
```


2. Apart from `file`, `skip`, and `comment`, what other arguments do `read_csv()` and `read_tsv()` have in common?

They have the following arguments in common:

```r
union(names(formals(read_csv)), names(formals(read_tsv)))
#>  [1] "file"      "col_names" "col_types" "locale"    "na"       
#>  [6] "quoted_na" "quote"     "comment"   "trim_ws"   "skip"     
#> [11] "n_max"     "guess_max" "progress"
```

- `col_names` and `col_types` are used to specify the column names and how to parse the columns
- `locale` is important for determining things like the enecoding and whether "." or "," is used as a decimal mark.
- `na` and `quoted_na` control which strings are treated as missing values when parsing vectors
- `trim_ws` trims whitespace before and after cells before parsing
- `n_max` sets how many rows to read
- `guess_max` sets how many rows to use when guessing the column type
- `progress` determines whether a progress bar is shown.

3. What are the most important arguments to `read_fwf()`?

The most important argument to `read_fwf` which reads "fixed-width formats", is `col_positions` which tells the function where data columns begin and end.

4. Sometimes strings in a CSV file contain commas. To prevent them from causing problems they need to be surrounded by a quoting character, like `"` or `'`. By convention, `read_csv()` assumes that the quoting character will be `"`, and if you want to change it you’ll need to use `read_delim()` instead. What arguments do you need to specify to read the following text into a data frame?

```
"x,y\n1,'a,b'"
```


```r
x <- "x,y\n1,'a,b'"
read_delim(x, ",", quote = "'")
#> # A tibble: 1 x 2
#>       x y    
#>   <int> <chr>
#> 1     1 a,b
```



6. Identify what is wrong with each of the following inline CSV files. What happens when you run the code?


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

Only two columns are specified in the header "a" and "b", but the rows have three columns, so the last column in dropped.


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
The opening quote `\\"1` is dropped because it is not closed, and `a` is treated as an integer.


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

The values are separated by ";" rather than ",". Use `read_csv2` instead:

```r
read_csv2("a;b\n1;3")
#> Using ',' as decimal and '.' as grouping mark. Use read_delim() for more control.
#> # A tibble: 1 x 2
#>       a     b
#>   <int> <int>
#> 1     1     3
```


  
## Parsing a vector


### Exercises 

1. What are the most important arguments to `locale()`?

The locale broadly controls the following:

- date and time formats: `date_names`, `date_format`, and `time_format`
- time_zone: `tz`
- numbers: `decimal_mark`, `grouping_mark`
- encoding: `encoding`


2. What happens if you try and set `decimal_mark` and `grouping_mark` to the same character?
  What happens to the default value of `grouping_mark` when you set `decimal_mark` to “,”? What happens to the default value of `decimal_mark` when you set the `grouping_mark` to “.”?

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



3. I didn’t discuss the `date_format` and `time_format` options to `locale()`. What do they do? Construct an example that shows when they might be useful.

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

Examples from the readr vignette of parsing French dates

```r
parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))
#> [1] "2015-01-01"
parse_date("14 oct. 1979", "%d %b %Y", locale = locale("fr"))
#> [1] "1979-10-14"
```
Apparently the time format is not used for anything, but the date format is used for guessing column types.



4. If you live outside the US, create a new locale object that encapsulates the settings for the types of file you read most commonly.


```r
?locale
```


5. What’s the difference between `read_csv()` and `read_csv2()`?

The delimiter. The function `read_csv` uses a comma, while `read_csv2` uses a semi-colon (`;`). Using a semi-colon is useful when commas are used as the decimal point (as in Europe).

6. What are the most common encodings used in Europe? What are the most common encodings used in Asia? Do some googling to find out. 

UTF-8 is standard now, and ASCII has been around forever.

For the European languages, there are separate encodings for Romance languages and Eastern European languages using Latin script, Cyrillic, Greek, Hebrew, Turkish: usually with separate ISO and Windows encoding standards.
There is also Mac OS Roman.

For Asian languages Arabic and Vietnamese have ISO and Windows standards. The other major Asian scripts have their own: 

- Japanese: JIS X 0208, Shift JIS, ISO-2022-JP
- Chinese: GB 2312, GBK, GB 18030
- Korean: KS X 1001, EUC-KR, ISO-2022-KR

The list in the documentation for `stringi::stri_enc_detect` is pretty good since it supports the most common encodings:

- Western European Latin script languages: ISO-8859-1, Windows-1250 (also CP-1250 for code-point)
- Eastern European Latin script languages: ISO-8859-2, Windows-1252 
- Greek: ISO-8859-7
- Turkish: ISO-8859-9, Windows-1254
- Hebrew: ISO-8859-8, IBM424, Windows 1255
- Russian: Windows 1251
- Japanese: Shift JIS, ISO-2022-JP, EUC-JP
- Korean: ISO-2022-KR, EUC-KR
- Chinese: GB18030, ISO-2022-CN (Simplified), Big5 (Traditional)
- Arabic: ISO-8859-6, IBM420, Windows 1256


For more information:

- https://en.wikipedia.org/wiki/Character_encoding has a good list
- http://stackoverflow.com/questions/8509339/what-is-the-most-common-encoding-of-each-language
- http://kunststube.net/encoding/

Some of the more useful programs for this

- In R see `readr::guess_encoding` and the **stringi** package with `str_enc_detect`
- iconv: https://en.wikipedia.org/wiki/Iconv
- chardet: https://github.com/chardet/chardet (Python)

7. Generate the correct format string to parse each of the following dates and times:

## Other Types of Data

No code
