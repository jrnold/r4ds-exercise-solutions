
---
title: "Ch 16: Dates and Times"
output: html_notebook
---

Notes

- **lubridate**

  - `today`, `now`
  - `ymd` etc., `ymd_hms` etc.
  - `make_datetime`, `make_date`
  - `as_datetime`, `as_date`
  - `year`, `month`, `mday`, `yday`, `wday` and `year<-`
  - `floor_date`, `round_date`, `ceiling_date`
  - `update`
  - `as.duration`, duration functions (`ddays`, etc)
  - period functions (`days`, `months`, etc)
  - interval creation with `%--%`
  - `with_tz`, `force_tz`

- **hms** package has times
- Ideas for applications: CDB90 data, COW war start end and duration 
- Read more on time-zones: https://en.wikipedia.org/wiki/Time_zone
- Computerphile [The Problem with Time & Timezones - Computerphile](https://www.youtube.com/watch?v=-5wpm-gesOY)
- The history of the tz database are themselves interesting: https://en.wikipedia.org/wiki/Tz_database
- [A literary appreciation of the Olson/Zoneinfo/tz database]( https://blog.jonudell.net/2009/10/23/a-literary-appreciation-of-the-olsonzoneinfotz-database/)

I think time-zones are likely a point for social science research in and of themselves. Policy choices. Coordination. Regression discontinuity designs. Just sayin...


## Prerequisite


```r
library(tidyverse)
library(lubridate)
library(nycflights13)
```

## Creating date/times

`today` and `now` are both lubridate functions

```r
today()
#> [1] "2017-01-08"
now()
#> [1] "2017-01-08 13:29:10 PST"
```

From strings

```r
ymd("2017-01-31")
#> [1] "2017-01-31"
mdy("January 31st, 2017")
#> [1] "2017-01-31"
dmy("31-Jan-2017")
#> [1] "2017-01-31"
```

They allow for unquoted numbers

```r
ymd(20170131)
#> [1] "2017-01-31"
```


```r
ymd_hms("2017-01-31 20:11:59")
#> [1] "2017-01-31 20:11:59 UTC"
mdy_hm("01/31/2017 08:01")
#> [1] "2017-01-31 08:01:00 UTC"
ymd(20170131, tz = "UTC")
#> [1] "2017-01-31 UTC"
```

From individual components


```r
flights %>%
  select(year, month, day, hour, minute) %>%
  mutate(departure = make_datetime(year, month, day, hour, minute))
#> # A tibble: 336,776 × 6
#>    year month   day  hour minute           departure
#>   <int> <int> <int> <dbl>  <dbl>              <dttm>
#> 1  2013     1     1     5     15 2013-01-01 05:15:00
#> 2  2013     1     1     5     29 2013-01-01 05:29:00
#> 3  2013     1     1     5     40 2013-01-01 05:40:00
#> 4  2013     1     1     5     45 2013-01-01 05:45:00
#> 5  2013     1     1     6      0 2013-01-01 06:00:00
#> 6  2013     1     1     5     58 2013-01-01 05:58:00
#> # ... with 3.368e+05 more rows
```



```r
flights %>% select(dep_time) %>% head()
#> # A tibble: 6 × 1
#>   dep_time
#>      <int>
#> 1      517
#> 2      533
#> 3      542
#> 4      544
#> 5      554
#> 6      554
```

**NOTE** %/% is integer division, divide and throw away the remainder. %% calculates the modulus (remainder of division). For example to test for an even number: `x %% 2 == 0`, or odd `x %% 2 == 1`. To get the thousands value of a number `x %/% 1000`.


```r
make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights_dt <- flights %>%
  filter(!is.na(dep_time), !is.na(arr_time)) %>%
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>%
  select(origin, dest, ends_with("delay"), ends_with("time"))
flights_dt %>% head
#> # A tibble: 6 × 9
#>   origin  dest dep_delay arr_delay            dep_time      sched_dep_time
#>    <chr> <chr>     <dbl>     <dbl>              <dttm>              <dttm>
#> 1    EWR   IAH         2        11 2013-01-01 05:17:00 2013-01-01 05:15:00
#> 2    LGA   IAH         4        20 2013-01-01 05:33:00 2013-01-01 05:29:00
#> 3    JFK   MIA         2        33 2013-01-01 05:42:00 2013-01-01 05:40:00
#> 4    JFK   BQN        -1       -18 2013-01-01 05:44:00 2013-01-01 05:45:00
#> 5    LGA   ATL        -6       -25 2013-01-01 05:54:00 2013-01-01 06:00:00
#> 6    EWR   ORD        -4        12 2013-01-01 05:54:00 2013-01-01 05:58:00
#> # ... with 3 more variables: arr_time <dttm>, sched_arr_time <dttm>,
#> #   air_time <dbl>
```


```r
flights_dt %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 86400) # 86400 seconds = 1 day
```

<img src="datetimes_files/figure-html/unnamed-chunk-10-1.png" width="70%" style="display: block; margin: auto;" />



```r
flights_dt %>% 
  filter(dep_time < ymd(20130102)) %>% 
  ggplot(aes(dep_time)) + 
  geom_freqpoly(binwidth = 600) # 600 s = 10 minutes
```

<img src="datetimes_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />


```r
as_datetime(today())
#> [1] "2017-01-08 UTC"
as_date(now())
#> [1] "2017-01-08"
```

**Note** Say something about Unix epochs.

Calculate dates and datetimes from number of seconds (`as_datetime`) or days (`as_date`) from Unix epoch.

```r
as_datetime(60 * 60 * 10)
#> [1] "1970-01-01 10:00:00 UTC"
```


```r
as_date(365 * 10 + 2)
#> [1] "1980-01-01"
```

### Exercises 

1. What happens if you parse a string that contains invalid dates?


```r
ret <- ymd(c("2010-10-10", "bananas"))
#> Warning: 1 failed to parse.
print(class(ret))
#> [1] "Date"
ret
#> [1] "2010-10-10" NA
```

It produces an `NA` and an warning message.

2. What does the tzone argument to `today()` do? Why is it important?

It determines the time-zone of the date. Since different time-zones can have different dates, the value of `today()` can vary depending on the time-zone specified.

3. Use the appropriate lubridate function to parse each of the following dates:


```r
d1 <- "January 1, 2010"
mdy(d1)
#> [1] "2010-01-01"
d2 <- "2015-Mar-07"
ymd(d2)
#> [1] "2015-03-07"
d3 <- "06-Jun-2017"
dmy(d3)
#> [1] "2017-06-06"
d4 <- c("August 19 (2015)", "July 1 (2015)")
mdy(d4)
#> [1] "2015-08-19" "2015-07-01"
d5 <- "12/30/14" # Dec 30, 2014
mdy(d5)
#> [1] "2014-12-30"
```

## Date-Time Components


```r
datetime <- ymd_hms("2016-07-08 12:34:56")
year(datetime)
#> [1] 2016
month(datetime)
#> [1] 7
mday(datetime)
#> [1] 8
yday(datetime)
#> [1] 190
wday(datetime)
#> [1] 6
```

 

```r
month(datetime, label = TRUE)
#> [1] Jul
#> 12 Levels: Jan < Feb < Mar < Apr < May < Jun < Jul < Aug < Sep < ... < Dec
wday(datetime, label = TRUE, abbr = FALSE)
#> [1] Friday
#> 7 Levels: Sunday < Monday < Tuesday < Wednesday < Thursday < ... < Saturday
```


```r
flights_dt %>%
  mutate(wday = wday(dep_time, label = TRUE)) %>%
  ggplot(aes(x = wday)) + geom_bar()
```

<img src="datetimes_files/figure-html/unnamed-chunk-19-1.png" width="70%" style="display: block; margin: auto;" />


```r
flights_dt %>%
  mutate(minute = minute(dep_time)) %>%
  group_by(minute) %>%
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n()) %>%
  ggplot(aes(minute, avg_delay)) +
  geom_line()
```

<img src="datetimes_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" />


```r
sched_dep <- flights_dt %>%
  mutate(minute = minute(sched_dep_time)) %>%
  group_by(minute) %>%
  summarise(
    avg_delay = mean(arr_delay, na.rm = TRUE),
    n = n())

ggplot(sched_dep, aes(minute, avg_delay)) +
  geom_line()
```

<img src="datetimes_files/figure-html/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(sched_dep, aes(minute, n)) +
  geom_line()
```

<img src="datetimes_files/figure-html/unnamed-chunk-22-1.png" width="70%" style="display: block; margin: auto;" />


```r
flights_dt %>%
  count(week = floor_date(dep_time, "week")) %>%
  ggplot(aes(week, n)) +
  geom_line()
  
```

<img src="datetimes_files/figure-html/unnamed-chunk-23-1.png" width="70%" style="display: block; margin: auto;" />

**Note** difference between rounded and unrounded date can give the within period time.


```r
(datetime <- ymd_hms("2016-07-08 12:34:56"))
#> [1] "2016-07-08 12:34:56 UTC"
year(datetime) <- 2020
datetime
#> [1] "2020-07-08 12:34:56 UTC"
month(datetime) <- 01
datetime
#> [1] "2020-01-08 12:34:56 UTC"
hour(datetime) <- hour(datetime) + 1
datetime
#> [1] "2020-01-08 13:34:56 UTC"
```


```r
update(datetime, year = 2020, month = 2, mday = 2, hour = 2)
#> [1] "2020-02-02 02:34:56 UTC"
```

roll-over for large values

```r
ymd("2015-02-01") %>% update(mday = 30)
#> [1] "2015-03-02"
```

```r
ymd("2015-02-01") %>%
  update(hour = 400)
#> [1] "2015-02-17 16:00:00 UTC"
```


```r
flights_dt %>%
  mutate(dep_hour = update(dep_time, yday = 1)) %>%
  ggplot(aes(dep_hour)) +
  geom_freqpoly(binwidth = 300)
```

<img src="datetimes_files/figure-html/unnamed-chunk-28-1.png" width="70%" style="display: block; margin: auto;" />

### Exercises

1. How does the distribution of flight times within a day change over the course of the year?

Let's try plotting this by month? 

```r
flights_dt %>%
  mutate(time = hour(dep_time) * 100 + minute(dep_time),
         mon = as.factor(month
                         (dep_time))) %>%
  ggplot(aes(x = time, group = mon, color = mon)) +
  geom_freqpoly(binwidth = 100)
```

<img src="datetimes_files/figure-html/unnamed-chunk-29-1.png" width="70%" style="display: block; margin: auto;" />

This will look better if everything is normalized within groups. The reason
that February is lower is that there are fewer days and thus fewer flights.

```r
flights_dt %>%
  mutate(time = hour(dep_time) * 100 + minute(dep_time),
         mon = as.factor(month
                         (dep_time))) %>%
  ggplot(aes(x = time, y = ..density.., group = mon, color = mon)) +
  geom_freqpoly(binwidth = 100)
```

<img src="datetimes_files/figure-html/unnamed-chunk-30-1.png" width="70%" style="display: block; margin: auto;" />

At least to me there doesn't appear to much difference in within-day distribution over the year, but I maybe thinking about it incorrectly.

2. Compare `dep_time`, `sched_dep_time` and `dep_delay`. Are they consistent? Explain your findings.

If they are consistent, then `dep_time = sched_dep_time + dep_delay`.


```r
flights_dt %>%
  mutate(dep_time_ = sched_dep_time + dep_delay * 60) %>%
  filter(dep_time_ != dep_time) %>%
  select(dep_time_, dep_time, sched_dep_time, dep_delay)
#> # A tibble: 1,205 × 4
#>             dep_time_            dep_time      sched_dep_time dep_delay
#>                <dttm>              <dttm>              <dttm>     <dbl>
#> 1 2013-01-02 08:48:00 2013-01-01 08:48:00 2013-01-01 18:35:00       853
#> 2 2013-01-03 00:42:00 2013-01-02 00:42:00 2013-01-02 23:59:00        43
#> 3 2013-01-03 01:26:00 2013-01-02 01:26:00 2013-01-02 22:50:00       156
#> 4 2013-01-04 00:32:00 2013-01-03 00:32:00 2013-01-03 23:59:00        33
#> 5 2013-01-04 00:50:00 2013-01-03 00:50:00 2013-01-03 21:45:00       185
#> 6 2013-01-04 02:35:00 2013-01-03 02:35:00 2013-01-03 23:59:00       156
#> # ... with 1,199 more rows
```

There exist discrepencies. It looks like there are mistakes in the dates.
These are flights in which the actual departure time is on the *next* day relative to the scheduled departure time. We forgot to account for this when creating the date-times. The code would have had to check if the departure time is less than the scheduled departure time. Alternatively, simply adding the delay time is more robust because it will automatically account for crossing into the next day.

3. Compare `air_time` with the duration between the departure and arrival. Explain your findings. 


```r
flights_dt %>%
  mutate(flight_duration = as.numeric(arr_time - dep_time),
         air_time_mins = air_time,
         diff = flight_duration - air_time_mins) %>%
  select(origin, dest, flight_duration, air_time_mins, diff)
#> # A tibble: 328,063 × 5
#>   origin  dest flight_duration air_time_mins  diff
#>    <chr> <chr>           <dbl>         <dbl> <dbl>
#> 1    EWR   IAH             193           227   -34
#> 2    LGA   IAH             197           227   -30
#> 3    JFK   MIA             221           160    61
#> 4    JFK   BQN             260           183    77
#> 5    LGA   ATL             138           116    22
#> 6    EWR   ORD             106           150   -44
#> # ... with 3.281e+05 more rows
```

4. How does the average delay time change over the course of a day? Should you use `dep_time` or `sched_dep_time`? Why?

Use `sched_dep_time` because that is the relevant metric for someone scheduling a flight. Also, using `dep_time` will always bias delays to later in the day since delays will push flights later.


```r
flights_dt %>%
  mutate(sched_dep_hour = hour(sched_dep_time)) %>%
  group_by(sched_dep_hour) %>%
  summarise(dep_delay = mean(dep_delay)) %>%
  ggplot(aes(y = dep_delay, x = sched_dep_hour)) +
  geom_point() +
  geom_smooth()
#> `geom_smooth()` using method = 'loess'
```

<img src="datetimes_files/figure-html/unnamed-chunk-33-1.png" width="70%" style="display: block; margin: auto;" />

5. On what day of the week should you leave if you want to minimise the chance of a delay?

Sunday has the lowest average departure delay time and the lowest average arrival delay time.


```r
flights_dt %>%
  mutate(dow = wday(sched_dep_time)) %>%
  group_by(dow) %>%
  summarise(dep_delay = mean(dep_delay),
            arr_delay = mean(arr_delay, na.rm = TRUE))
#> # A tibble: 7 × 3
#>     dow dep_delay arr_delay
#>   <dbl>     <dbl>     <dbl>
#> 1     1      11.5      4.82
#> 2     2      14.7      9.65
#> 3     3      10.6      5.39
#> 4     4      11.7      7.05
#> 5     5      16.1     11.74
#> 6     6      14.7      9.07
#> # ... with 1 more rows
```

6. What makes the distribution of `diamonds$carat` and `flights$sched_dep_time` similar?


```r
ggplot(diamonds, aes(x = carat)) + 
  geom_density()
```

<img src="datetimes_files/figure-html/unnamed-chunk-35-1.png" width="70%" style="display: block; margin: auto;" />

In both `carat` and `sched_dep_time` there are abnormally large numbers of values are at nice "human" numbers. In `sched_dep_time` it is at 00 and 30 minutes. In carats, it is at 0, 1/3, 1/2, 2/3, 


```r
ggplot(diamonds, aes(x = carat %% 1 * 100)) +
  geom_histogram(binwidth = 1)
```

<img src="datetimes_files/figure-html/unnamed-chunk-36-1.png" width="70%" style="display: block; margin: auto;" />

In scheduled departure times it is 00 and 30 minutes, and minutes
ending in 0 and 5.


```r
ggplot(flights_dt, aes(x = minute(sched_dep_time))) +
  geom_histogram(binwidth = 1)
```

<img src="datetimes_files/figure-html/unnamed-chunk-37-1.png" width="70%" style="display: block; margin: auto;" />

7. Confirm my hypothesis that the early departures of flights in minutes 20-30 and 50-60 are caused by scheduled flights that leave early. Hint: create a binary variable that tells you whether or not a flight was delayed.

At the minute level, there doesn't appear to be anything:

```r
flights_dt %>%
  mutate(early = dep_delay < 0,
         minute = minute(sched_dep_time)) %>%
  group_by(minute) %>%
  summarise(early = mean(early)) %>%
  ggplot(aes(x = minute, y = early)) +
  geom_point()
```

<img src="datetimes_files/figure-html/unnamed-chunk-38-1.png" width="70%" style="display: block; margin: auto;" />


But if grouped in 10 minute intervals, there is a higher proportion of early flights during those minutes.


```r
flights_dt %>%
  mutate(early = dep_delay < 0,
         minute = minute(sched_dep_time) %% 10) %>%
  group_by(minute) %>%
  summarise(early = mean(early)) %>%
  ggplot(aes(x = minute, y = early)) +
  geom_point()
```

<img src="datetimes_files/figure-html/unnamed-chunk-39-1.png" width="70%" style="display: block; margin: auto;" />


## Time Spans

- duration: exact number of seconds
- period: human time periods - e.g. weeks, months
- interval: start and end points

### Durations


```r
h_age <- today() - ymd(19791014)
class(h_age)
#> [1] "difftime"
h_age
#> Time difference of 13601 days
```


```r
as.duration(h_age)
#> [1] "1175126400s (~37.24 years)"
```


```r
dseconds(15)
#> [1] "15s"
dminutes(10)
#> [1] "600s (~10 minutes)"
dhours(c(12, 24))
#> [1] "43200s (~12 hours)" "86400s (~1 days)"
ddays(0:5)
#> [1] "0s"                "86400s (~1 days)"  "172800s (~2 days)"
#> [4] "259200s (~3 days)" "345600s (~4 days)" "432000s (~5 days)"
dweeks(3)
#> [1] "1814400s (~3 weeks)"
dyears(1)
#> [1] "31536000s (~52.14 weeks)"
```

durations are always in seconds, and larger units are in the standard multiples of seconds.

Arithmetic with durations

```r
2 * dyears(1)
#> [1] "63072000s (~2 years)"
dyears(1) + dweeks(12) + dhours(15)
#> [1] "38847600s (~1.23 years)"
```


```r
tomorrow <- today() + ddays(1)
last_year <- today() - dyears(1)
```

Surprising results because doesn't account for weirdness like timezones

```r
one_pm <- ymd_hms("2016-03-12 13:00:00", tz = "America/New_York")
one_pm
#> [1] "2016-03-12 13:00:00 EST"
one_pm + ddays(1)
#> [1] "2016-03-13 14:00:00 EDT"
```

### Periods

Periods are durations for the irregular messy human time periods: months, days. 


```r
one_pm
#> [1] "2016-03-12 13:00:00 EST"
one_pm + days(1)
#> [1] "2016-03-13 13:00:00 EDT"
```


```r
seconds(15)
#> [1] "15S"
minutes(10)
#> [1] "10M 0S"
hours(c(12, 14))
#> [1] "12H 0M 0S" "14H 0M 0S"
days(7)
#> [1] "7d 0H 0M 0S"
months(1:6)
#> [1] "1m 0d 0H 0M 0S" "2m 0d 0H 0M 0S" "3m 0d 0H 0M 0S" "4m 0d 0H 0M 0S"
#> [5] "5m 0d 0H 0M 0S" "6m 0d 0H 0M 0S"
weeks(3)
#> [1] "21d 0H 0M 0S"
years(1)
#> [1] "1y 0m 0d 0H 0M 0S"
```

Add or multiply periods:

```r
10 * (months(6) + days(1))
#> [1] "60m 10d 0H 0M 0S"
days(50) + hours(25) + minutes(2)
#> [1] "50d 25H 2M 0S"
```


```r
# leap year
ymd("2016-01-01") + dyears(1)
#> [1] "2016-12-31"
ymd("2016-01-01") + years(1)
#> [1] "2017-01-01"
# DST
one_pm + ddays(1)
#> [1] "2016-03-13 14:00:00 EDT"
one_pm + days(1)
#> [1] "2016-03-13 13:00:00 EDT"
```

Define overnight when `arr_time < dep_time` (no flights > 24 hours):

```r
flights_dt <- flights_dt %>% 
  mutate(
    overnight = arr_time < dep_time,
    arr_time = arr_time + days(overnight * 1),
    sched_arr_time = sched_arr_time + days(overnight * 1)
  )
```


```r
flights_dt %>%
  filter(overnight, arr_time < dep_time)
#> # A tibble: 0 × 10
#> # ... with 10 variables: origin <chr>, dest <chr>, dep_delay <dbl>,
#> #   arr_delay <dbl>, dep_time <dttm>, sched_dep_time <dttm>,
#> #   arr_time <dttm>, sched_arr_time <dttm>, air_time <dbl>,
#> #   overnight <lgl>
```

### Intervals

**NOTE** This section seems less complete than the others.

Interval = duration with starting point.


```r
years(1) / days(1)
#> estimate only: convert to intervals for accuracy
#> [1] 365
```


```r
next_year <- today() + years(1)
(today() %--% next_year) / ddays(1)
#> [1] 365
```

For number of periods in an intervla, use integer division.


```r
(today() %--% next_year) %/% days(1)
#> Note: method with signature 'Timespan#Timespan' chosen for function '%/%',
#>  target signature 'Interval#Period'.
#>  "Interval#ANY", "ANY#Period" would also be valid
#> [1] 365
```

### Exercises

1. Why is there `months()` but no `dmonths()`? 

There is no direct unambigous value of months in seconds: 

- 31 days: Jan, Mar, May, Jul, Aug, Oct,
- 30 days: Apr, Jun, Sep, Nov, Dec
- 28 or 29 days: Feb

Though in the past, in the pre-computer era, for arithmetic convenience, bankers adopoted a 360 day year with 30 day months.

2. Explain `days(overnight * 1)` to someone who has just started learning R. How does it work? 

`overnight` is equal to TRUE (1) or FALSE (0). So if it is an overnight flight, this becomes 1 day, and if not, then overnight = 0, and no days are added to the date.

3. Create a vector of dates giving the first day of every month in 2015. Create a vector of dates giving the first day of every month in the current year.

A vector of the first day of the month for every month in 2015:

```r
ymd("2015-01-01") + months(0:11)
#>  [1] "2015-01-01" "2015-02-01" "2015-03-01" "2015-04-01" "2015-05-01"
#>  [6] "2015-06-01" "2015-07-01" "2015-08-01" "2015-09-01" "2015-10-01"
#> [11] "2015-11-01" "2015-12-01"
```

To get the vector of the first day of the month for *this* year, we first need to figure out what this year is, and get January 1st of it.
I can do that by taking `today()` and truncating it to the year using `floor_date`:

```r
floor_date(today(), unit = "year") + months(0:11)
#>  [1] "2017-01-01" "2017-02-01" "2017-03-01" "2017-04-01" "2017-05-01"
#>  [6] "2017-06-01" "2017-07-01" "2017-08-01" "2017-09-01" "2017-10-01"
#> [11] "2017-11-01" "2017-12-01"
```


4. Write a function that given your birthday (as a date), returns how old you are in years.


```r
age <- function(bday) {
  (bday %--% today()) %/% years(1)
}
age(ymd("1990-10-12"))
#> [1] 26
```

5. Why can’t `(today() %--% (today() + years(1)) / months(1)` work?

It appears to work. Today is a date. Today + 1 year is a valid endpoint for an interval. And months is period that is defined in this period.

```r
(today() %--% (today() + years(1))) %/% months(1)
#> [1] 12
(today() %--% (today() + years(1))) / months(1)
#> [1] 12
```

### Time Zones


```r
Sys.timezone()
#> [1] "America/Los_Angeles"
```


```r
length(OlsonNames())
#> [1] 589
head(OlsonNames())
#> [1] "Africa/Abidjan"     "Africa/Accra"       "Africa/Addis_Ababa"
#> [4] "Africa/Algiers"     "Africa/Asmara"      "Africa/Asmera"
```

In R, timezones only control printing.

```r
(x1 <- ymd_hms("2015-06-01 12:00:00", tz = "America/New_York"))
#> [1] "2015-06-01 12:00:00 EDT"
(x2 <- ymd_hms("2015-06-01 18:00:00", tz = "Europe/Copenhagen"))
#> [1] "2015-06-01 18:00:00 CEST"
(x3 <- ymd_hms("2015-06-02 04:00:00", tz = "Pacific/Auckland"))
#> [1] "2015-06-02 04:00:00 NZST"
```

```r
x1 - x2
#> Time difference of 0 secs
x1 - x3
#> Time difference of 0 secs
```

Lubridate always uses UTC unless otherwise specified.

```r
x4 <- c(x1, x2, x3)
x4
#> [1] "2015-06-01 09:00:00 PDT" "2015-06-01 09:00:00 PDT"
#> [3] "2015-06-01 09:00:00 PDT"
```

To keep time-zone

```r
x4a <- with_tz(x4, tzone = "Australia/Lord_Howe")
x4a
#> [1] "2015-06-02 02:30:00 LHST" "2015-06-02 02:30:00 LHST"
#> [3] "2015-06-02 02:30:00 LHST"
x4a - x4
#> Time differences in secs
#> [1] 0 0 0
```
Change underlying instant

```r
x4b <- force_tz(x4, tzone = "Australia/Lord_Howe")
x4b - x4
#> Time differences in hours
#> [1] -17.5 -17.5 -17.5
```

