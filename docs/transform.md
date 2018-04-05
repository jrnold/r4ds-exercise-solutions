
---
output: html_document
editor_options:
  chunk_output_type: console
---
# Data Transformation

## Introduction


```r
library("nycflights13")
library("tidyverse")
```

## Filter rows with `filter()`


```r
glimpse(flights)
#> Observations: 336,776
#> Variables: 19
#> $ year           <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013,...
#> $ month          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
#> $ day            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,...
#> $ dep_time       <int> 517, 533, 542, 544, 554, 554, 555, 557, 557, 55...
#> $ sched_dep_time <int> 515, 529, 540, 545, 600, 558, 600, 600, 600, 60...
#> $ dep_delay      <dbl> 2, 4, 2, -1, -6, -4, -5, -3, -3, -2, -2, -2, -2...
#> $ arr_time       <int> 830, 850, 923, 1004, 812, 740, 913, 709, 838, 7...
#> $ sched_arr_time <int> 819, 830, 850, 1022, 837, 728, 854, 723, 846, 7...
#> $ arr_delay      <dbl> 11, 20, 33, -18, -25, 12, 19, -14, -8, 8, -2, -...
#> $ carrier        <chr> "UA", "UA", "AA", "B6", "DL", "UA", "B6", "EV",...
#> $ flight         <int> 1545, 1714, 1141, 725, 461, 1696, 507, 5708, 79...
#> $ tailnum        <chr> "N14228", "N24211", "N619AA", "N804JB", "N668DN...
#> $ origin         <chr> "EWR", "LGA", "JFK", "JFK", "LGA", "EWR", "EWR"...
#> $ dest           <chr> "IAH", "IAH", "MIA", "BQN", "ATL", "ORD", "FLL"...
#> $ air_time       <dbl> 227, 227, 160, 183, 116, 150, 158, 53, 140, 138...
#> $ distance       <dbl> 1400, 1416, 1089, 1576, 762, 719, 1065, 229, 94...
#> $ hour           <dbl> 5, 5, 5, 5, 6, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5,...
#> $ minute         <dbl> 15, 29, 40, 45, 0, 58, 0, 0, 0, 0, 0, 0, 0, 0, ...
#> $ time_hour      <dttm> 2013-01-01 05:00:00, 2013-01-01 05:00:00, 2013...
```

### Exercise 1 {.exercise}


<div class='question'>
Find all flights that

1. Had an arrival delay of two or more hours
2. Flew to Houston (IAH or HOU)
3. Were operated by United, American, or Delta
4. Departed in summer (July, August, and September)
5. Arrived more than two hours late, but didn’t leave late
6. Were delayed by at least an hour, but made up over 30 minutes in flight
7. Departed between midnight and 6am (inclusive)

</div>


<div class='answer'>

*Had an arrival delay of two or more hours* Since delay is in minutes, we are looking for flights where `arr_delay > 120`:

```r
filter(flights, arr_delay > 120)
#> # A tibble: 10,034 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      811            630       101     1047
#> 2  2013     1     1      848           1835       853     1001
#> 3  2013     1     1      957            733       144     1056
#> 4  2013     1     1     1114            900       134     1447
#> 5  2013     1     1     1505           1310       115     1638
#> 6  2013     1     1     1525           1340       105     1831
#> # ... with 1.003e+04 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

*Flew to Houston (IAH or HOU)*:

```r
filter(flights, dest %in% c("IAH", "HOU"))
#> # A tibble: 9,313 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      517            515      2.00      830
#> 2  2013     1     1      533            529      4.00      850
#> 3  2013     1     1      623            627     -4.00      933
#> 4  2013     1     1      728            732     -4.00     1041
#> 5  2013     1     1      739            739      0        1104
#> 6  2013     1     1      908            908      0        1228
#> # ... with 9,307 more rows, and 12 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

*Were operated by United, American, or Delta* The variable `carrier` has the airline, but it is in two-digit carrier codes. 
However, we can look it up in the `airlines` dataset.

```r
airlines
#> # A tibble: 16 x 2
#>   carrier name                    
#>   <chr>   <chr>                   
#> 1 9E      Endeavor Air Inc.       
#> 2 AA      American Airlines Inc.  
#> 3 AS      Alaska Airlines Inc.    
#> 4 B6      JetBlue Airways         
#> 5 DL      Delta Air Lines Inc.    
#> 6 EV      ExpressJet Airlines Inc.
#> # ... with 10 more rows
```
Since there are only 16 rows, its not even worth filtering.
Delta is `DL`, American is `AA`, and United is `UA`:

```r
filter(flights, carrier %in% c("AA", "DL", "UA"))
#> # A tibble: 139,504 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      517            515      2.00      830
#> 2  2013     1     1      533            529      4.00      850
#> 3  2013     1     1      542            540      2.00      923
#> 4  2013     1     1      554            600     -6.00      812
#> 5  2013     1     1      554            558     -4.00      740
#> 6  2013     1     1      558            600     -2.00      753
#> # ... with 1.395e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

*Departed in summer (July, August, and September)* The variable `month` has the month, and it is numeric.

```r
filter(flights, between(month, 7, 9))
#> # A tibble: 86,326 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     7     1        1           2029    212         236
#> 2  2013     7     1        2           2359      3.00      344
#> 3  2013     7     1       29           2245    104         151
#> 4  2013     7     1       43           2130    193         322
#> 5  2013     7     1       44           2150    174         300
#> 6  2013     7     1       46           2051    235         304
#> # ... with 8.632e+04 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

*Arrived more than two hours late, but didn’t leave late*

```r
filter(flights, !is.na(dep_delay), dep_delay <= 0, arr_delay > 120)
#> # A tibble: 29 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1    27     1419           1420     -1.00     1754
#> 2  2013    10     7     1350           1350      0        1736
#> 3  2013    10     7     1357           1359     -2.00     1858
#> 4  2013    10    16      657            700     -3.00     1258
#> 5  2013    11     1      658            700     -2.00     1329
#> 6  2013     3    18     1844           1847     -3.00       39
#> # ... with 23 more rows, and 12 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

*Were delayed by at least an hour, but made up over 30 minutes in flight*

```r
filter(flights, !is.na(dep_delay), 
       dep_delay >= 60, dep_delay - arr_delay > 30)
#> # A tibble: 1,844 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1     2205           1720     285         46
#> 2  2013     1     1     2326           2130     116        131
#> 3  2013     1     3     1503           1221     162       1803
#> 4  2013     1     3     1839           1700      99.0     2056
#> 5  2013     1     3     1850           1745      65.0     2148
#> 6  2013     1     3     1941           1759     102       2246
#> # ... with 1,838 more rows, and 12 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

*Departed between midnight and 6am (inclusive)*.

```r
filter(flights, dep_time <= 600 | dep_time == 2400)
#> # A tibble: 9,373 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      517            515      2.00      830
#> 2  2013     1     1      533            529      4.00      850
#> 3  2013     1     1      542            540      2.00      923
#> 4  2013     1     1      544            545     -1.00     1004
#> 5  2013     1     1      554            600     -6.00      812
#> 6  2013     1     1      554            558     -4.00      740
#> # ... with 9,367 more rows, and 12 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

</div>

### Exercise 2 {.exercise}


<div class='question'>
Another useful **dplyr** filtering helper is `between()`. What does it do? Can you use it to simplify the code needed to answer the previous challenges?
</div>


<div class='answer'>

`between(x, left, right)` is equivalent to `x >= left & x <= right`.

</div>

### Exercise 3 {.exercise}


<div class='question'>
How many flights have a missing `dep_time`? What other variables are missing? What might these rows represent?
</div>


<div class='answer'>


```r
filter(flights, is.na(dep_time))
#> # A tibble: 8,255 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1       NA           1630        NA       NA
#> 2  2013     1     1       NA           1935        NA       NA
#> 3  2013     1     1       NA           1500        NA       NA
#> 4  2013     1     1       NA            600        NA       NA
#> 5  2013     1     2       NA           1540        NA       NA
#> 6  2013     1     2       NA           1620        NA       NA
#> # ... with 8,249 more rows, and 12 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>
```

Since `arr_time` is also missing, these are canceled flights.

</div>

### Exercise 4 {.exercise}


<div class='question'>
Why is `NA ^ 0` not missing? Why is `NA | TRUE` not missing? Why is `FALSE & NA` not missing? Can you figure out the general rule? (`NA * 0` is a tricky counterexample!)
</div>


<div class='answer'>

`NA ^ 0 == 1` since for all numeric values $x ^ 0 = 1$.

```r
NA ^ 0
#> [1] 1
```

`NA | TRUE` is `TRUE` because the it doesn't matter whether the missing value is `TRUE` or `FALSE`, `x \lor T = T` for all values of `x`.

```r
NA | TRUE
#> [1] TRUE
```
Likewise, anything and `FALSE` is always `FALSE`.

```r
NA & FALSE
#> [1] FALSE
```
Because the value of the missing element matters in `NA | FALSE` and `NA & TRUE`, these are missing:

```r
NA | FALSE
#> [1] NA
NA & TRUE
#> [1] NA
```

Wut?? Since `x * 0 = 0` for all $x$ (except `Inf`) we might expect `NA * 0 = 0`, but that's not the case.

```r
NA * 0
#> [1] NA
```
The reason that `NA * 0` is not equal to `0` is that `x * 0 = NaN` is undefined when `x = Inf` or `x = -Inf`.

```r
Inf * 0
#> [1] NaN
-Inf * 0
#> [1] NaN
```


</div>

## Arrange rows with `arrange()`


### Exercise 1 {.exercise}


<div class='question'>
How could you use `arrange()` to sort all missing values to the start? (Hint: use `is.na()`).
</div>


<div class='answer'>

This sorts by increasing `dep_time`, but with all missing values put first.

```r
arrange(flights, desc(is.na(dep_time)), dep_time)
#> # A tibble: 336,776 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1       NA           1630        NA       NA
#> 2  2013     1     1       NA           1935        NA       NA
#> 3  2013     1     1       NA           1500        NA       NA
#> 4  2013     1     1       NA            600        NA       NA
#> 5  2013     1     2       NA           1540        NA       NA
#> 6  2013     1     2       NA           1620        NA       NA
#> # ... with 3.368e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

</div>

### Exercise 2 {.exercise}


<div class='question'>
Sort flights to find the most delayed flights. Find the flights that left earliest.
</div>


<div class='answer'>

The most delayed flights are found by sorting by `dep_delay` in descending order.

```r
arrange(flights, desc(dep_delay))
#> # A tibble: 336,776 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     9      641            900      1301     1242
#> 2  2013     6    15     1432           1935      1137     1607
#> 3  2013     1    10     1121           1635      1126     1239
#> 4  2013     9    20     1139           1845      1014     1457
#> 5  2013     7    22      845           1600      1005     1044
#> 6  2013     4    10     1100           1900       960     1342
#> # ... with 3.368e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```
If we sort `dep_delay` in ascending order, we get those that left earliest.
There was a flight that left 43 minutes early.

```r
arrange(flights, dep_delay)
#> # A tibble: 336,776 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013    12     7     2040           2123     -43.0       40
#> 2  2013     2     3     2022           2055     -33.0     2240
#> 3  2013    11    10     1408           1440     -32.0     1549
#> 4  2013     1    11     1900           1930     -30.0     2233
#> 5  2013     1    29     1703           1730     -27.0     1947
#> 6  2013     8     9      729            755     -26.0     1002
#> # ... with 3.368e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

</div>

### Exercise 3 {.exercise}


<div class='question'>
Sort flights to find the fastest flights.
</div>


<div class='answer'>

I assume that by by "fastest flights" it means the flights with the minimum air time.
So I sort by `air_time`. The fastest flights. The fastest flights area couple of flights between EWR and BDL with an air time of 20 minutes.

```r
arrange(flights, air_time)
#> # A tibble: 336,776 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1    16     1355           1315     40.0      1442
#> 2  2013     4    13      537            527     10.0       622
#> 3  2013    12     6      922            851     31.0      1021
#> 4  2013     2     3     2153           2129     24.0      2247
#> 5  2013     2     5     1303           1315    -12.0      1342
#> 6  2013     2    12     2123           2130    - 7.00     2211
#> # ... with 3.368e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```


</div>

### Exercise 4 {.exercise}


<div class='question'>
Which flights traveled the longest? Which traveled the shortest?
</div>


<div class='answer'>

I'll assume hat traveled the longest or shortest refers to distance, rather than air-time.

The longest flights are the Hawaii Air (HA 51) between JFK and HNL (Honolulu) at 4,983 miles.

```r
arrange(flights, desc(distance))
#> # A tibble: 336,776 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      857            900    - 3.00     1516
#> 2  2013     1     2      909            900      9.00     1525
#> 3  2013     1     3      914            900     14.0      1504
#> 4  2013     1     4      900            900      0        1516
#> 5  2013     1     5      858            900    - 2.00     1519
#> 6  2013     1     6     1019            900     79.0      1558
#> # ... with 3.368e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

Apart from an EWR to LGA flight that was canceled, the shortest flights are the Envoy Air Flights between EWR and PHL at 80 miles.

```r
arrange(flights, distance)
#> # A tibble: 336,776 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     7    27       NA            106     NA          NA
#> 2  2013     1     3     2127           2129   -  2.00     2222
#> 3  2013     1     4     1240           1200     40.0      1333
#> 4  2013     1     4     1829           1615    134        1937
#> 5  2013     1     4     2128           2129   -  1.00     2218
#> 6  2013     1     5     1155           1200   -  5.00     1241
#> # ... with 3.368e+05 more rows, and 12 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```



</div>

## Select columns with `select()`

### Exercise 1 {.exercise}


<div class='question'>
Brainstorm as many ways as possible to select `dep_time`, `dep_delay`, `arr_time`, and `arr_delay` from flights.
</div>


<div class='answer'>

A few ways include:

```r
select(flights, dep_time, dep_delay, arr_time, arr_delay)
#> # A tibble: 336,776 x 4
#>   dep_time dep_delay arr_time arr_delay
#>      <int>     <dbl>    <int>     <dbl>
#> 1      517      2.00      830      11.0
#> 2      533      4.00      850      20.0
#> 3      542      2.00      923      33.0
#> 4      544     -1.00     1004     -18.0
#> 5      554     -6.00      812     -25.0
#> 6      554     -4.00      740      12.0
#> # ... with 3.368e+05 more rows
select(flights, starts_with("dep_"), starts_with("arr_"))
#> # A tibble: 336,776 x 4
#>   dep_time dep_delay arr_time arr_delay
#>      <int>     <dbl>    <int>     <dbl>
#> 1      517      2.00      830      11.0
#> 2      533      4.00      850      20.0
#> 3      542      2.00      923      33.0
#> 4      544     -1.00     1004     -18.0
#> 5      554     -6.00      812     -25.0
#> 6      554     -4.00      740      12.0
#> # ... with 3.368e+05 more rows
select(flights, matches("^(dep|arr)_(time|delay)$"))
#> # A tibble: 336,776 x 4
#>   dep_time dep_delay arr_time arr_delay
#>      <int>     <dbl>    <int>     <dbl>
#> 1      517      2.00      830      11.0
#> 2      533      4.00      850      20.0
#> 3      542      2.00      923      33.0
#> 4      544     -1.00     1004     -18.0
#> 5      554     -6.00      812     -25.0
#> 6      554     -4.00      740      12.0
#> # ... with 3.368e+05 more rows
```
using `ends_with()` doesn't work well since it would return both `sched_arr_time` and `sched_dep_time`.

</div>

### Exercise 2 {.exercise}


<div class='question'>
What happens if you include the name of a variable multiple times in a select() call?
</div>


<div class='answer'>

It ignores the duplicates, and that variable is only included once. No error, warning, or message is emitted.

```r
select(flights, year, month, day, year, year)
#> # A tibble: 336,776 x 3
#>    year month   day
#>   <int> <int> <int>
#> 1  2013     1     1
#> 2  2013     1     1
#> 3  2013     1     1
#> 4  2013     1     1
#> 5  2013     1     1
#> 6  2013     1     1
#> # ... with 3.368e+05 more rows
```

</div>

### Exercise 3 {.exercise}


<div class='question'>
What does the `one_of()` function do? Why might it be helpful in conjunction with this vector?
</div>


<div class='answer'>

The `one_of` vector allows you to select variables with a character vector rather than as unquoted variable names.
It's useful because then you can easily pass vectors to `select()`.


```r
vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, one_of(vars))
#> # A tibble: 336,776 x 5
#>    year month   day dep_delay arr_delay
#>   <int> <int> <int>     <dbl>     <dbl>
#> 1  2013     1     1      2.00      11.0
#> 2  2013     1     1      4.00      20.0
#> 3  2013     1     1      2.00      33.0
#> 4  2013     1     1     -1.00     -18.0
#> 5  2013     1     1     -6.00     -25.0
#> 6  2013     1     1     -4.00      12.0
#> # ... with 3.368e+05 more rows
```


</div>

### Exercise 4 {.exercise}


<div class='question'>
Does the result of running the following code surprise you? How do the select helpers deal with case by default? How can you change that default?
</div>


<div class='answer'>


```r
select(flights, contains("TIME"))
#> # A tibble: 336,776 x 6
#>   dep_time sched_dep_time arr_time sched_arr_time air_time
#>      <int>          <int>    <int>          <int>    <dbl>
#> 1      517            515      830            819      227
#> 2      533            529      850            830      227
#> 3      542            540      923            850      160
#> 4      544            545     1004           1022      183
#> 5      554            600      812            837      116
#> 6      554            558      740            728      150
#> # ... with 3.368e+05 more rows, and 1 more variable: time_hour <dttm>
```

The default behavior for contains is to ignore case.
Yes, it surprises me.
Upon reflection, I realized that this is likely the default behavior because `dplyr` is designed to deal with a variety of data backends, and some database engines don't differentiate case.

To change the behavior add the argument `ignore.case = FALSE`. Now no variables are selected.

```r
select(flights, contains("TIME", ignore.case = FALSE))
#> # A tibble: 336,776 x 0
```

</div>

## Add new variables with `mutate()`

### Exercise 1 {.exercise}


<div class='question'>
Currently `dep_time` and `sched_dep_time` are convenient to look at, but hard to compute with because they’re not really continuous numbers. Convert them to a more convenient representation of number of minutes since midnight.
</div>


<div class='answer'>

To get the departure times in the number of minutes, (integer) divide `dep_time` by 100 to get the hours since midnight and multiply by 60 and add the remainder of `dep_time` divided by 100.

```r
mutate(flights,
       dep_time_mins = dep_time %/% 100 * 60 + dep_time %% 100,
       sched_dep_time_mins = sched_dep_time %/% 100 * 60 + sched_dep_time %% 100) %>%
  select(dep_time, dep_time_mins, sched_dep_time, sched_dep_time_mins)
#> # A tibble: 336,776 x 4
#>   dep_time dep_time_mins sched_dep_time sched_dep_time_mins
#>      <int>         <dbl>          <int>               <dbl>
#> 1      517           317            515                 315
#> 2      533           333            529                 329
#> 3      542           342            540                 340
#> 4      544           344            545                 345
#> 5      554           354            600                 360
#> 6      554           354            558                 358
#> # ... with 3.368e+05 more rows
```

This would be more cleanly done by first defining a function and reusing that:

```r
time2mins <- function(x) {
  x %/% 100 * 60 + x %% 100
}
mutate(flights,
       dep_time_mins = time2mins(dep_time),
       sched_dep_time_mins = time2mins(sched_dep_time)) %>%
  select(dep_time, dep_time_mins, sched_dep_time, sched_dep_time_mins)
#> # A tibble: 336,776 x 4
#>   dep_time dep_time_mins sched_dep_time sched_dep_time_mins
#>      <int>         <dbl>          <int>               <dbl>
#> 1      517           317            515                 315
#> 2      533           333            529                 329
#> 3      542           342            540                 340
#> 4      544           344            545                 345
#> 5      554           354            600                 360
#> 6      554           354            558                 358
#> # ... with 3.368e+05 more rows
```


</div>

### Exercise 2 {.exercise}


<div class='question'>
Compare `air_time` with `arr_time - dep_time`. What do you expect to see? What do you see? What do you need to do to fix it?
</div>


<div class='answer'>

Since `arr_time` and `dep_time` may be in different time zones, the `air_time` doesn't equal the difference.
We would need to account for time-zones in these calculations.

```r
mutate(flights,
       air_time2 = arr_time - dep_time,
       air_time_diff = air_time2 - air_time) %>%
  filter(air_time_diff != 0) %>%
  select(air_time, air_time2, dep_time, arr_time, dest)
#> # A tibble: 326,128 x 5
#>   air_time air_time2 dep_time arr_time dest 
#>      <dbl>     <int>    <int>    <int> <chr>
#> 1      227       313      517      830 IAH  
#> 2      227       317      533      850 IAH  
#> 3      160       381      542      923 MIA  
#> 4      183       460      544     1004 BQN  
#> 5      116       258      554      812 ATL  
#> 6      150       186      554      740 ORD  
#> # ... with 3.261e+05 more rows
```


</div>

### Exercise 3 {.exercise}


<div class='question'>
Compare `dep_time`, `sched_dep_time`, and `dep_delay`. How would you expect those three numbers to be related?
</div>


<div class='answer'>

I'd expect `dep_time`, `sched_dep_time`, and `dep_delay` to be related so that `dep_time - sched_dep_time = dep_delay`.

```r
mutate(flights,
       dep_delay2 = dep_time - sched_dep_time) %>%
  filter(dep_delay2 != dep_delay) %>%
  select(dep_time, sched_dep_time, dep_delay, dep_delay2)
#> # A tibble: 99,777 x 4
#>   dep_time sched_dep_time dep_delay dep_delay2
#>      <int>          <int>     <dbl>      <int>
#> 1      554            600     -6.00        -46
#> 2      555            600     -5.00        -45
#> 3      557            600     -3.00        -43
#> 4      557            600     -3.00        -43
#> 5      558            600     -2.00        -42
#> 6      558            600     -2.00        -42
#> # ... with 9.977e+04 more rows
```
Oops, I forgot to convert to minutes. I'll reuse the `time2mins` function I wrote earlier.

```r
mutate(flights,
       dep_delay2 = time2mins(dep_time) - time2mins(sched_dep_time)) %>%
  filter(dep_delay2 != dep_delay) %>%
  select(dep_time, sched_dep_time, dep_delay, dep_delay2)
#> # A tibble: 1,207 x 4
#>   dep_time sched_dep_time dep_delay dep_delay2
#>      <int>          <int>     <dbl>      <dbl>
#> 1      848           1835     853        - 587
#> 2       42           2359      43.0      -1397
#> 3      126           2250     156        -1284
#> 4       32           2359      33.0      -1407
#> 5       50           2145     185        -1255
#> 6      235           2359     156        -1284
#> # ... with 1,201 more rows
```
Well, that solved most of the problems, but these two numbers don't match because we aren't accounting for flights where the departure time is the next day from the scheduled departure time.


</div>

### Exercise 4 {.exercise}


<div class='question'>
Find the 10 most delayed flights using a ranking function. How do you want to handle ties? Carefully read the documentation for `min_rank()`.
</div>


<div class='answer'>

I'd want to handle ties by taking the minimum of tied values. If three flights are have the same value and are the most delayed, we would say they are tied for first, not tied for third or second.

```r
mutate(flights,
       dep_delay_rank = min_rank(-dep_delay)) %>%
  arrange(dep_delay_rank) %>%
  filter(dep_delay_rank <= 10)
#> # A tibble: 10 x 20
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     9      641            900      1301     1242
#> 2  2013     6    15     1432           1935      1137     1607
#> 3  2013     1    10     1121           1635      1126     1239
#> 4  2013     9    20     1139           1845      1014     1457
#> 5  2013     7    22      845           1600      1005     1044
#> 6  2013     4    10     1100           1900       960     1342
#> # ... with 4 more rows, and 13 more variables: sched_arr_time <int>,
#> #   arr_delay <dbl>, carrier <chr>, flight <int>, tailnum <chr>,
#> #   origin <chr>, dest <chr>, air_time <dbl>, distance <dbl>, hour <dbl>,
#> #   minute <dbl>, time_hour <dttm>, dep_delay_rank <int>
```


</div>

### Exercise 5 {.exercise}


<div class='question'>
What does `1:3 + 1:10` return? Why?
</div>


<div class='answer'>

It returns `c(1 + 1, 2 + 2, 3 + 3, 1 + 4, 2 + 5, 3 + 6, 1 + 7, 2 + 8, 3 + 9, 1 + 10)`.
When adding two vectors recycles the shorter vector's values to get vectors of the same length.
We get a warning vector since the shorter vector is not a multiple of the longer one (this often, but not necessarily, means we made an error somewhere).


```r
1:3 + 1:10
#> Warning in 1:3 + 1:10: longer object length is not a multiple of shorter
#> object length
#>  [1]  2  4  6  5  7  9  8 10 12 11
```


</div>

### Exercise 6 {.exercise}


<div class='question'>
What trigonometric functions does R provide?
</div>


<div class='answer'>

These are all described in the same help page,

```r
help("Trig")
```

Cosine (`cos`), sine (`sin`), tangent (`tan`) are provided:

```r
tibble(
  x = seq(-3, 7, by = 1 / 2),
  cosx = cos(pi * x),
  sinx = cos(pi * x),
  tanx = tan(pi * x)
)
#> # A tibble: 21 x 4
#>        x                   cosx                   sinx                tanx
#>    <dbl>                  <dbl>                  <dbl>               <dbl>
#> 1 -3.00  -1.00                  -1.00                             3.67e⁻¹⁶
#> 2 -2.50   0.000000000000000306   0.000000000000000306            -3.27e⁺¹⁵
#> 3 -2.00   1.00                   1.00                             2.45e⁻¹⁶
#> 4 -1.50  -0.000000000000000184  -0.000000000000000184            -5.44e⁺¹⁵
#> 5 -1.00  -1.00                  -1.00                             1.22e⁻¹⁶
#> 6 -0.500  0.0000000000000000612  0.0000000000000000612           -1.63e⁺¹⁶
#> # ... with 15 more rows
```
The convenience function `cospi(x)` is equivalent to `cos(pi * x)`, with `sinpi` and `tanpi` similarly defined,

```r
tibble(
  x = seq(-3, 7, by = 1 / 2),
  cosx = cospi(x),
  sinx = cos(x),
  tanx = tan(x)
)
#> # A tibble: 21 x 4
#>        x  cosx    sinx    tanx
#>    <dbl> <dbl>   <dbl>   <dbl>
#> 1 -3.00  -1.00 -0.990    0.143
#> 2 -2.50   0    -0.801    0.747
#> 3 -2.00   1.00 -0.416    2.19 
#> 4 -1.50   0     0.0707 -14.1  
#> 5 -1.00  -1.00  0.540  - 1.56 
#> 6 -0.500  0     0.878  - 0.546
#> # ... with 15 more rows
```

The inverse function arc-cosine (`acos`), arc-sine (`asin`), and arc-tangent (`atan`) are provided,

```r
tibble(
  x = seq(-1, 1, by = 1 / 4),
  acosx = acos(x),
  asinx = asin(x),
  atanx = atan(x)
)
#> # A tibble: 9 x 4
#>        x acosx  asinx  atanx
#>    <dbl> <dbl>  <dbl>  <dbl>
#> 1 -1.00   3.14 -1.57  -0.785
#> 2 -0.750  2.42 -0.848 -0.644
#> 3 -0.500  2.09 -0.524 -0.464
#> 4 -0.250  1.82 -0.253 -0.245
#> 5  0      1.57  0      0    
#> 6  0.250  1.32  0.253  0.245
#> # ... with 3 more rows
```

The function `atan2` is the angle between the x-axis and the the vector (0,0) to (`x`, `y`).

```r
atan2(c(1, 0, -1, 0), c(0, 1, 0, -1))
#> [1]  1.57  0.00 -1.57  3.14
```


</div>

## Grouped summaries with `summarise()`

### Exercise 1 {.exercise}


<div class='question'>
Brainstorm at least 5 different ways to assess the typical delay characteristics of a group of flights. Consider the following scenarios:
- A flight is 15 minutes early 50% of the time, and 15 minutes late 50% of the time.
- A flight is always 10 minutes late.
- A flight is 30 minutes early 50% of the time, and 30 minutes late 50% of the time.
- 99% of the time a flight is on time. 1% of the time it’s 2 hours late.
</div>


<div class='answer'>

> Which is more important: arrival delay or departure delay?

Arrival delay is more important.
Arriving early is nice, but equally as good as arriving late is bad.
Variation is worse than consistency; if I know the plane will always arrive 10 minutes late, then I can plan for it arriving as if the actual arrival time was 10 minutes later than the scheduled arrival time.

So I'd try something that calculates the expected time of the flight, and then aggregates over any delays from that time. I would ignore any early arrival times.
A better ranking would also consider cancellations, and need a way to convert them to a delay time (perhaps using the arrival time of the next flight to the same destination).

**TOOD: Answer this**

</div>

### Exercise 2 {.exercise}


<div class='question'>
Come up with another approach that will give you the same output as `not_cancelled %>% count(dest)` and `not_cancelled %>% count(tailnum, wt = distance)` (without using `count()`).
</div>


<div class='answer'>

The data frame `not_cancelled` is defined in the chapter as,

```r
not_cancelled <- flights %>%
  filter(!is.na(dep_delay), !is.na(arr_delay))
```

Count will group a dataset on the given variable and then determine the number of instances within each group.
This can be done by by first grouping by the given variable, and then finding the number of observations in each group.
The number of observations in each group can be found by calling the `length()` function on any variable.
To make the result match `count()`, the value should go in a new column `n`.

```r
not_cancelled %>%
  group_by(dest) %>%
  summarise(n = length(dest))
#> # A tibble: 104 x 2
#>   dest      n
#>   <chr> <int>
#> 1 ABQ     254
#> 2 ACK     264
#> 3 ALB     418
#> 4 ANC       8
#> 5 ATL   16837
#> 6 AUS    2411
#> # ... with 98 more rows
```
A more concise way to get the number of observations in a data frame, or a group, is the function `n()`,

```r
not_cancelled %>%
  group_by(dest) %>%
  summarise(n = n())
#> # A tibble: 104 x 2
#>   dest      n
#>   <chr> <int>
#> 1 ABQ     254
#> 2 ACK     264
#> 3 ALB     418
#> 4 ANC       8
#> 5 ATL   16837
#> 6 AUS    2411
#> # ... with 98 more rows
```

For a weighted count, take the sum of the weight variable in each group.

```r
not_cancelled %>%
  group_by(tailnum) %>%
  summarise(n = sum(distance))
#> # A tibble: 4,037 x 2
#>   tailnum      n
#>   <chr>    <dbl>
#> 1 D942DN    3418
#> 2 N0EGMQ  239143
#> 3 N10156  109664
#> 4 N102UW   25722
#> 5 N103US   24619
#> 6 N104UW   24616
#> # ... with 4,031 more rows
```


Alternatively, we could have used `group_by` followed by `tally()`,
since `count()` itself is a shortcut for calling `group_by()` then `tally()`,

```r
not_cancelled %>%
  group_by(tailnum) %>%
  tally()
#> # A tibble: 4,037 x 2
#>   tailnum     n
#>   <chr>   <int>
#> 1 D942DN      4
#> 2 N0EGMQ    352
#> 3 N10156    145
#> 4 N102UW     48
#> 5 N103US     46
#> 6 N104UW     46
#> # ... with 4,031 more rows
```
and

```r
not_cancelled %>%
  group_by(tailnum) %>%
  tally(distance)
#> # A tibble: 4,037 x 2
#>   tailnum      n
#>   <chr>    <dbl>
#> 1 D942DN    3418
#> 2 N0EGMQ  239143
#> 3 N10156  109664
#> 4 N102UW   25722
#> 5 N103US   24619
#> 6 N104UW   24616
#> # ... with 4,031 more rows
```




</div>

### Exercise 3 {.exercise}


<div class='question'>
Our definition of canceled flights `(is.na(dep_delay) | is.na(arr_delay))` is slightly suboptimal. Why? Which is the most important column?
</div>


<div class='answer'>

If a flight never departs, then it won't arrive.
A flight could also depart and not arrive if it crashes, or if it is redirected and lands in an airport other than its intended destination.

The more important column is `arr_delay`, which indicates the amount of delay in arrival.

```r
filter(flights, !is.na(dep_delay), is.na(arr_delay)) %>%
  select(dep_time, arr_time, sched_arr_time, dep_delay, arr_delay)
#> # A tibble: 1,175 x 5
#>   dep_time arr_time sched_arr_time dep_delay arr_delay
#>      <int>    <int>          <int>     <dbl>     <dbl>
#> 1     1525     1934           1805    - 5.00        NA
#> 2     1528     2002           1647     29.0         NA
#> 3     1740     2158           2020    - 5.00        NA
#> 4     1807     2251           2103     29.0         NA
#> 5     1939       29           2151     59.0         NA
#> 6     1952     2358           2207     22.0         NA
#> # ... with 1,169 more rows
```
Okay, I'm not sure what's going on in this data. `dep_time` can be non-missing and `arr_delay` missing but `arr_time` not missing.
They may be combining different flights?

</div>

### Exercise 4 {.exercise}


<div class='question'>
Look at the number of canceled flights per day. Is there a pattern? Is the proportion of canceled flights related to the average delay?
</div>


<div class='answer'>


```r
canceled_delayed <-
  flights %>%
  mutate(canceled = (is.na(arr_delay) | is.na(dep_delay))) %>%
  group_by(year, month, day) %>%
  summarise(prop_canceled = mean(canceled),
            avg_dep_delay = mean(dep_delay, na.rm = TRUE))

ggplot(canceled_delayed, aes(x = avg_dep_delay, prop_canceled)) +
  geom_point() +
  geom_smooth()
#> `geom_smooth()` using method = 'loess'
```

<img src="transform_files/figure-html/unnamed-chunk-48-1.png" width="70%" style="display: block; margin: auto;" />


</div>

### Exercise 5 {.exercise}


<div class='question'>
Which carrier has the worst delays? Challenge: can you disentangle the effects of bad airports vs. bad carriers? Why/why not? (Hint: think about `flights %>% group_by(carrier, dest) %>% summarise(n())`)
</div>


<div class='answer'>


```r
flights %>%
  group_by(carrier) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(desc(arr_delay))
#> # A tibble: 16 x 2
#>   carrier arr_delay
#>   <chr>       <dbl>
#> 1 F9           21.9
#> 2 FL           20.1
#> 3 EV           15.8
#> 4 YV           15.6
#> 5 OO           11.9
#> 6 MQ           10.8
#> # ... with 10 more rows
```


```r
filter(airlines, carrier == "F9")
#> # A tibble: 1 x 2
#>   carrier name                  
#>   <chr>   <chr>                 
#> 1 F9      Frontier Airlines Inc.
```

Frontier Airlines (FL) has the worst delays.

You can get part of the way to disentangling the effects of airports vs. carriers by
comparing each flight's delay to the average delay of destination airport.
However, you'd really want to compare it to the average delay of the destination airport, *after* removing other flights from the same airline.

FiveThirtyEight conducted a [similar analysis](http://fivethirtyeight.com/features/the-best-and-worst-airlines-airports-and-flights-summer-2015-update/).


</div>

### Exercise 6 {.exercise}


<div class='question'>
For each plane, count the number of flights before the first delay of greater than 1 hour.
</div>


<div class='answer'>

I think this requires grouped mutate (but I may be wrong):

```r
flights %>%
  arrange(tailnum, year, month, day) %>%
  group_by(tailnum) %>%
  mutate(delay_gt1hr = dep_delay > 60) %>%
  mutate(before_delay = cumsum(delay_gt1hr)) %>%
  filter(before_delay < 1) %>%
  count(sort = TRUE)
#> # A tibble: 3,755 x 2
#> # Groups:   tailnum [3,755]
#>   tailnum     n
#>   <chr>   <int>
#> 1 N954UW    206
#> 2 N952UW    163
#> 3 N957UW    142
#> 4 N5FAAA    117
#> 5 N38727     99
#> 6 N3742C     98
#> # ... with 3,749 more rows
```


</div>

### Exercise 7 {.exercise}


<div class='question'>
What does the sort argument to `count()` do. When might you use it?
</div>


<div class='answer'>

The sort argument to `count` sorts the results in order of `n`.
You could use this anytime you would do `count` followed by `arrange`.

</div>

## Grouped mutates (and filters)

### Exercise 1 {.exercise}


<div class='question'>
Refer back to the table of useful mutate and filtering functions. Describe how each operation changes when you combine it with grouping.
</div>


<div class='answer'>

They operate within each group rather than over the entire data frame. E.g. `mean` will calculate the mean within each group.

</div>

### Exercise 2 {.exercise}


<div class='question'>
Which plane (`tailnum`) has the worst on-time record?
</div>


<div class='answer'>


```r
flights %>%
  group_by(tailnum) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  filter(rank(desc(arr_delay)) <= 1)
#> # A tibble: 1 x 2
#>   tailnum arr_delay
#>   <chr>       <dbl>
#> 1 N844MH        320
```


</div>

### Exercise 3 {.exercise}


<div class='question'>
What time of day should you fly if you want to avoid delays as much as possible?
</div>


<div class='answer'>

Let's group by hour. The earlier the better to fly. This is intuitive as delays early in the morning are likely to propagate throughout the day.

```r
flights %>%
  group_by(hour) %>%
  summarise(arr_delay = mean(arr_delay, na.rm = TRUE)) %>%
  arrange(arr_delay)
#> # A tibble: 20 x 2
#>    hour arr_delay
#>   <dbl>     <dbl>
#> 1  7.00    -5.30 
#> 2  5.00    -4.80 
#> 3  6.00    -3.38 
#> 4  9.00    -1.45 
#> 5  8.00    -1.11 
#> 6 10.0      0.954
#> # ... with 14 more rows
```


</div>

### Exercise 4 {.exercise}


<div class='question'>
For each destination, compute the total minutes of delay. For each, flight, compute the proportion of the total delay for its destination.
</div>


<div class='answer'>


```r
flights %>%
  filter(!is.na(arr_delay), arr_delay > 0) %>%  
  group_by(dest) %>%
  mutate(total_delay = sum(arr_delay),
         prop_delay = arr_delay / sum(arr_delay))
#> # A tibble: 133,004 x 21
#> # Groups:   dest [103]
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      517            515      2.00      830
#> 2  2013     1     1      533            529      4.00      850
#> 3  2013     1     1      542            540      2.00      923
#> 4  2013     1     1      554            558     -4.00      740
#> 5  2013     1     1      555            600     -5.00      913
#> 6  2013     1     1      558            600     -2.00      753
#> # ... with 1.33e+05 more rows, and 14 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>,
#> #   total_delay <dbl>, prop_delay <dbl>
```

Alternatively, consider the delay as relative to the *minimum* delay for any flight to that destination. Now all non-canceled flights have a proportion.

```r
flights %>%
  filter(!is.na(arr_delay), arr_delay > 0) %>%  
  group_by(dest) %>%
  mutate(total_delay = sum(arr_delay - min(arr_delay)),
         prop_delay = arr_delay / sum(arr_delay))
#> # A tibble: 133,004 x 21
#> # Groups:   dest [103]
#>    year month   day dep_time sched_dep_time dep_delay arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>
#> 1  2013     1     1      517            515      2.00      830
#> 2  2013     1     1      533            529      4.00      850
#> 3  2013     1     1      542            540      2.00      923
#> 4  2013     1     1      554            558     -4.00      740
#> 5  2013     1     1      555            600     -5.00      913
#> 6  2013     1     1      558            600     -2.00      753
#> # ... with 1.33e+05 more rows, and 14 more variables:
#> #   sched_arr_time <int>, arr_delay <dbl>, carrier <chr>, flight <int>,
#> #   tailnum <chr>, origin <chr>, dest <chr>, air_time <dbl>,
#> #   distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>,
#> #   total_delay <dbl>, prop_delay <dbl>
```



</div>

### Exercise 5 {.exercise}


<div class='question'>
Delays are typically temporally correlated: even once the problem that caused the initial delay has been resolved, later flights are delayed to allow earlier flights to leave. Using `lag()` explore how the delay of a flight is related to the delay of the immediately preceding flight.
</div>


<div class='answer'>

We want to group by day to avoid taking the lag from the previous day.
Also, I want to use departure delay, since this mechanism is relevant for departures.
Also, I remove missing values both before and after calculating the lag delay.
However, it would be interesting to ask the probability or average delay after a cancellation.

```r
flights %>%
  group_by(year, month, day) %>%
  filter(!is.na(dep_delay)) %>%
  mutate(lag_delay = lag(dep_delay)) %>%
  filter(!is.na(lag_delay)) %>%
  ggplot(aes(x = dep_delay, y = lag_delay)) +
  geom_point() +
  geom_smooth()
#> `geom_smooth()` using method = 'gam'
```

<img src="transform_files/figure-html/unnamed-chunk-56-1.png" width="70%" style="display: block; margin: auto;" />


</div>

### Exercise 6 {.exercise}


<div class='question'>
Look at each destination. Can you find flights that are suspiciously fast? (i.e. flights that represent a potential data entry error). Compute the air time a flight relative to the shortest flight to that destination. Which flights were most delayed in the air?
</div>


<div class='answer'>

The shorter BOS and PHL flights that are 20 minutes for 30+ minutes flights seem plausible - though maybe entries of +/- a few minutes can easily create large changes.
I assume that departure time has a standardized definition, but I'm not sure; if there is some discretion, that could create errors that are small in absolute time, but large in relative time for small flights.
The ATL, GSP, and BNA flights look suspicious as they are almost half the time of longer flights.

```r
flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest) %>%
  mutate(med_time = median(air_time),
         fast = (air_time - med_time) / med_time) %>%
  arrange(fast) %>%
  select(air_time, med_time, fast, dep_time, sched_dep_time, arr_time, sched_arr_time) %>%
  head(15)
#> Adding missing grouping variables: `dest`
#> # A tibble: 15 x 8
#> # Groups:   dest [9]
#>   dest  air_time med_time   fast dep_time sched_dep_time arr_time
#>   <chr>    <dbl>    <dbl>  <dbl>    <int>          <int>    <int>
#> 1 BOS       21.0     38.0 -0.447     1450           1500     1547
#> 2 ATL       65.0    112   -0.420     1709           1700     1923
#> 3 GSP       55.0     92.0 -0.402     2040           2025     2225
#> 4 BOS       23.0     38.0 -0.395     1954           2000     2131
#> 5 BNA       70.0    113   -0.381     1914           1910     2045
#> 6 MSP       93.0    149   -0.376     1558           1513     1745
#> # ... with 9 more rows, and 1 more variable: sched_arr_time <int>
```

I could also try a z-score. Though the standard deviation and mean will be affected by large delays.

```r
flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest) %>%
  mutate(air_time_mean = mean(air_time),
         air_time_sd = sd(air_time),
         z_score = (air_time - air_time_mean) / air_time_sd) %>%
  arrange(z_score) %>%
  select(z_score, air_time_mean, air_time_sd, air_time, dep_time, sched_dep_time, arr_time, sched_arr_time)
#> Adding missing grouping variables: `dest`
#> # A tibble: 327,346 x 9
#> # Groups:   dest [104]
#>   dest  z_score air_time_mean air_time_sd air_time dep_time sched_dep_time
#>   <chr>   <dbl>         <dbl>       <dbl>    <dbl>    <int>          <int>
#> 1 MSP     -4.90         151         11.8      93.0     1558           1513
#> 2 ATL     -4.88         113          9.81     65.0     1709           1700
#> 3 GSP     -4.72          93.4        8.13     55.0     2040           2025
#> 4 BNA     -4.05         114         11.0      70.0     1914           1910
#> 5 CVG     -3.98          96.0        8.52     62.0     1359           1343
#> 6 BOS     -3.63          39.0        4.95     21.0     1450           1500
#> # ... with 3.273e+05 more rows, and 2 more variables: arr_time <int>,
#> #   sched_arr_time <int>
```


```r
flights %>%
  filter(!is.na(air_time)) %>%
  group_by(dest) %>%
  mutate(air_time_diff = air_time - min(air_time)) %>%
  arrange(desc(air_time_diff)) %>%
  select(dest, year, month, day, carrier, flight, air_time_diff, air_time, dep_time, arr_time) %>%
  head()
#> # A tibble: 6 x 10
#> # Groups:   dest [5]
#>   dest   year month   day carrier flight air_time_diff air_time dep_time
#>   <chr> <int> <int> <int> <chr>    <int>         <dbl>    <dbl>    <int>
#> 1 SFO    2013     7    28 DL         841           195      490     1727
#> 2 LAX    2013    11    22 DL         426           165      440     1812
#> 3 EGE    2013     1    28 AA         575           163      382     1806
#> 4 DEN    2013     9    10 UA         745           149      331     1513
#> 5 LAX    2013     7    10 DL          17           147      422     1814
#> 6 LAS    2013    11    22 UA         587           143      399     2142
#> # ... with 1 more variable: arr_time <int>
```


</div>

### Exercise 7 {.exercise}


<div class='question'>
Find all destinations that are flown by at least two carriers. Use that information to rank the carriers.
</div>


<div class='answer'>

The carrier that flies to the most locations is ExpressJet Airlines (EV).
ExpressJet is a regional airline and partner for major airlines, so its one of those that flies small planes to close airports


```r
flights %>%
  group_by(dest, carrier) %>%
  count(carrier) %>%
  group_by(carrier) %>%
  count(sort = TRUE)
#> # A tibble: 16 x 2
#> # Groups:   carrier [16]
#>   carrier    nn
#>   <chr>   <int>
#> 1 EV         61
#> 2 9E         49
#> 3 UA         47
#> 4 B6         42
#> 5 DL         40
#> 6 MQ         20
#> # ... with 10 more rows
```


```r
filter(airlines, carrier == "EV")
#> # A tibble: 1 x 2
#>   carrier name                    
#>   <chr>   <chr>                   
#> 1 EV      ExpressJet Airlines Inc.
```

</div>

