
# Factors

Functions and packages:

- **forcats**
- `factor`
- `fct_inorder`
- `levels`
- `readr::parse_factor`
- `fct_reorder`
- `fct_relevel`
- `fct_reorder2`
- `fct_infreq`
- `fct_rev`
- `fct_recode`
- `fct_lump`
- `fct_collapse`

## Introduction


```r
library(tidyverse)
library(forcats)
```


## Creating Factors


```r
x1 <- c("Dec", "Apr", "Jan", "Mar")
month_levels <- c(
  "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
)
y1 <- factor(x1, levels = month_levels)
```


```r
y1 <- factor(x1, levels = month_levels)
y1
#> [1] Dec Apr Jan Mar
#> Levels: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
sort(y1)
#> [1] Jan Mar Apr Dec
#> Levels: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
```


```r
x2 <- c("Dec", "Apr", "Jam", "Mar")
y2 <- factor(x2, levels = month_levels)
y2
#> [1] Dec  Apr  <NA> Mar 
#> Levels: Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
```

No warnings with factor. Use `readr::parse_factor` for warning.


```r
y2 <- parse_factor(x2, levels = month_levels)
#> Warning: 1 parsing failure.
#> row col           expected actual
#>   3  -- value in level set    Jam
```

Change order of levels, e.g. first appearance:

```r
f1 <- factor(x1, levels = unique(x1))
f1
#> [1] Dec Apr Jan Mar
#> Levels: Dec Apr Jan Mar
f2 <- x1 %>% factor() %>% fct_inorder()
f2
#> [1] Dec Apr Jan Mar
#> Levels: Dec Apr Jan Mar
```


```r
levels(f2)
#> [1] "Dec" "Apr" "Jan" "Mar"
```

## GSS


```r
gss_cat
#> # A tibble: 21,483 × 9
#>    year       marital   age   race        rincome            partyid
#>   <int>        <fctr> <int> <fctr>         <fctr>             <fctr>
#> 1  2000 Never married    26  White  $8000 to 9999       Ind,near rep
#> 2  2000      Divorced    48  White  $8000 to 9999 Not str republican
#> 3  2000       Widowed    67  White Not applicable        Independent
#> 4  2000 Never married    39  White Not applicable       Ind,near rep
#> 5  2000      Divorced    25  White Not applicable   Not str democrat
#> 6  2000       Married    25  White $20000 - 24999    Strong democrat
#> # ... with 2.148e+04 more rows, and 3 more variables: relig <fctr>,
#> #   denom <fctr>, tvhours <int>
```


```r
gss_cat %>%
  count(race)
#> # A tibble: 3 × 2
#>     race     n
#>   <fctr> <int>
#> 1  Other  1959
#> 2  Black  3129
#> 3  White 16395
```


```r
ggplot(gss_cat, aes(race)) +
  geom_bar()
```

<img src="factors_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(gss_cat, aes(race)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)
```

<img src="factors_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />

Use `drop = FALSE` to not drop valid values.

### Exercise

1. Explore the distribution of `rincome` (reported income). What makes the default bar chart hard to understand? How could you improve the plot?


```r
rincome_plot <-
  gss_cat %>%
  ggplot(aes(rincome)) +
  geom_bar()
rincome_plot
```

<img src="factors_files/figure-html/unnamed-chunk-13-1.png" width="70%" style="display: block; margin: auto;" />

The default bar chart labels are too squished to read.
One solution is to change the angle of the labels,

```r
rincome_plot +
  theme(axis.text.x = element_text(angle = 90))
```

<img src="factors_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />

But that's not natural either, because text is vertical, and we read horizontally.
So with long labels, it is better to flip it.

```r
rincome_plot +
  coord_flip()
```

<img src="factors_files/figure-html/unnamed-chunk-15-1.png" width="70%" style="display: block; margin: auto;" />

This is better, but it unituively goes from low to high. It would help if the
scale is reversed. Also, if all the missing factors were differentiated.


3. What is the most common `relig` in this survey? What’s the most common `partyid`?

The most common `relig` is "Protestant"

```r
gss_cat %>%
  count(relig) %>%
  arrange(-n) %>%
  head(1)
#> # A tibble: 1 × 2
#>        relig     n
#>       <fctr> <int>
#> 1 Protestant 10846
```

The most common `partyid` is "Independent"

```r
gss_cat %>%
  count(partyid) %>% 
  arrange(-n) %>%
  head(1)
#> # A tibble: 1 × 2
#>       partyid     n
#>        <fctr> <int>
#> 1 Independent  4119
```


3. Which `relig` does `denom` (denomination) apply to? How can you find out with a table? How can you find out with a visualisation?


```r
levels(gss_cat$denom)
#>  [1] "No answer"            "Don't know"           "No denomination"     
#>  [4] "Other"                "Episcopal"            "Presbyterian-dk wh"  
#>  [7] "Presbyterian, merged" "Other presbyterian"   "United pres ch in us"
#> [10] "Presbyterian c in us" "Lutheran-dk which"    "Evangelical luth"    
#> [13] "Other lutheran"       "Wi evan luth synod"   "Lutheran-mo synod"   
#> [16] "Luth ch in america"   "Am lutheran"          "Methodist-dk which"  
#> [19] "Other methodist"      "United methodist"     "Afr meth ep zion"    
#> [22] "Afr meth episcopal"   "Baptist-dk which"     "Other baptists"      
#> [25] "Southern baptist"     "Nat bapt conv usa"    "Nat bapt conv of am" 
#> [28] "Am bapt ch in usa"    "Am baptist asso"      "Not applicable"
```

From the context it is clear that `denom` refers to "Protestant" (and unsurprising given that it is the largest category in `freq`).
Let's filter out the non-responses, no answers, others, not-applicable, or
no denomination, to leave only answers to denominations.
After doing that, the only remaining responses are "Protestant".

```r
gss_cat %>%
  filter(!denom %in% c("No answer", "Other", "Don't know", "Not applicable",
                       "No denomination")) %>%
  count(relig)
#> # A tibble: 1 × 2
#>        relig     n
#>       <fctr> <int>
#> 1 Protestant  7025
```

This is also clear in a scatter plot of `relig` vs. `denom` where the points are
proportional to the size of the number of answers (since otherwise there would be overplotting).

```r
gss_cat %>%
  count(relig, denom) %>%
  ggplot(aes(x = relig, y = denom, size = n)) +
  geom_point() +
  theme(axis.text.x = element_text(angle = 90))
```

<img src="factors_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" />

## Modifying factor order


```r
relig <- gss_cat %>%
  group_by(relig) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )
ggplot(relig, aes(tvhours, relig)) + geom_point()
```

<img src="factors_files/figure-html/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(relig, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()
```

<img src="factors_files/figure-html/unnamed-chunk-22-1.png" width="70%" style="display: block; margin: auto;" />

Move most data analysis out of the ggplot function call

```r
rincome <- gss_cat %>%
  group_by(rincome) %>%
  summarise(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(rincome, aes(age, fct_reorder(rincome, age))) + geom_point()
```

<img src="factors_files/figure-html/unnamed-chunk-23-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(rincome, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()
```

<img src="factors_files/figure-html/unnamed-chunk-24-1.png" width="70%" style="display: block; margin: auto;" />


```r
by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, colour = marital)) +
  geom_line(na.rm = TRUE)

ggplot(by_age, aes(age, prop, colour = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(colour = "marital")
```

<img src="factors_files/figure-html/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" /><img src="factors_files/figure-html/unnamed-chunk-25-2.png" width="70%" style="display: block; margin: auto;" />


```r
gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital)) +
  geom_bar()
```

<img src="factors_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />

### Exercises

1. There are some suspiciously high numbers in `tvhours`. Is the `mean` a good summary?


```r
summary(gss_cat[["tvhours"]])
#>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max.    NA's 
#>       0       1       2       3       4      24   10146
```



```r
gss_cat %>%
  filter(!is.na(tvhours)) %>%
  ggplot(aes(x = tvhours)) +
  geom_histogram(binwidth = 1)
```

<img src="factors_files/figure-html/unnamed-chunk-28-1.png" width="70%" style="display: block; margin: auto;" />

Whether the mean is the best summary epends on what you are using it for :-), i.e. your objective. 
But probably the median would be what most people prefer. 
And the hours of tv doesn't look that surprising to me.

2. For each factor in gss_cat identify whether the order of the levels is arbitrary or principled.

The following piece of code uses functions covered in Ch 21, to print out the names of only the factors.

```r
keep(gss_cat, is.factor) %>% names()
#> [1] "marital" "race"    "rincome" "partyid" "relig"   "denom"
```

There are five six categorical variables: `marital`, `race`, `rincome`, `partyid`, `relig`, `denom`.

The ordering of marital is "somewhat principled". There is some sort of logic in that the levels are grouped "never married", married at some point (separated, divorced, widowed), and "married"; though it would seem that "Never Married", "Divorced", "Widowed", "Separated", "Married" might be more natural. 
I find that the question of ordering can be determined by the level of aggregation in a categorical variable, and there can be more "partially ordered" factors than one would expect.


```r
levels(gss_cat[["marital"]])
#> [1] "No answer"     "Never married" "Separated"     "Divorced"     
#> [5] "Widowed"       "Married"
```

```r
gss_cat %>%
  ggplot(aes(x = marital)) +
  geom_bar()
```

<img src="factors_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

The ordering of race is principled in that the categories are ordered by count of observations in the data.

```r
levels(gss_cat$race)
#> [1] "Other"          "Black"          "White"          "Not applicable"
```

```r
gss_cat %>%
  ggplot(aes(race)) +
  geom_bar(drop = FALSE)
#> Warning: Ignoring unknown parameters: drop
```

<img src="factors_files/figure-html/unnamed-chunk-33-1.png" width="70%" style="display: block; margin: auto;" />

The levels of `rincome` are ordered in decreasing order of the income; however the placement of "No answer", "Don't know", and "Refused" before, and "Not applicable" after the income levels is arbitrary. It would be better to place all the missing income level categories either before or after all the known values.

```r
levels(gss_cat$rincome)
#>  [1] "No answer"      "Don't know"     "Refused"        "$25000 or more"
#>  [5] "$20000 - 24999" "$15000 - 19999" "$10000 - 14999" "$8000 to 9999" 
#>  [9] "$7000 to 7999"  "$6000 to 6999"  "$5000 to 5999"  "$4000 to 4999" 
#> [13] "$3000 to 3999"  "$1000 to 2999"  "Lt $1000"       "Not applicable"
```

The levels of `relig` is arbitrary: there is no natural ordering, and they don't appear to be ordered by stats within the dataset.

```r
levels(gss_cat$relig)
#>  [1] "No answer"               "Don't know"             
#>  [3] "Inter-nondenominational" "Native american"        
#>  [5] "Christian"               "Orthodox-christian"     
#>  [7] "Moslem/islam"            "Other eastern"          
#>  [9] "Hinduism"                "Buddhism"               
#> [11] "Other"                   "None"                   
#> [13] "Jewish"                  "Catholic"               
#> [15] "Protestant"              "Not applicable"
```


```r
gss_cat %>%
  ggplot(aes(relig)) +
  geom_bar() +
  coord_flip()
```

<img src="factors_files/figure-html/unnamed-chunk-36-1.png" width="70%" style="display: block; margin: auto;" />

The same goes for `denom`.

```r
levels(gss_cat$denom)
#>  [1] "No answer"            "Don't know"           "No denomination"     
#>  [4] "Other"                "Episcopal"            "Presbyterian-dk wh"  
#>  [7] "Presbyterian, merged" "Other presbyterian"   "United pres ch in us"
#> [10] "Presbyterian c in us" "Lutheran-dk which"    "Evangelical luth"    
#> [13] "Other lutheran"       "Wi evan luth synod"   "Lutheran-mo synod"   
#> [16] "Luth ch in america"   "Am lutheran"          "Methodist-dk which"  
#> [19] "Other methodist"      "United methodist"     "Afr meth ep zion"    
#> [22] "Afr meth episcopal"   "Baptist-dk which"     "Other baptists"      
#> [25] "Southern baptist"     "Nat bapt conv usa"    "Nat bapt conv of am" 
#> [28] "Am bapt ch in usa"    "Am baptist asso"      "Not applicable"
```


Ignoring "No answer", "Don't know", and "Other party", the levels of `partyid` are ordered from "Strong Republican"" to "Strong Democrat".

```r
levels(gss_cat$partyid)
#>  [1] "No answer"          "Don't know"         "Other party"       
#>  [4] "Strong republican"  "Not str republican" "Ind,near rep"      
#>  [7] "Independent"        "Ind,near dem"       "Not str democrat"  
#> [10] "Strong democrat"
```


3. Why did moving “Not applicable” to the front of the levels move it to the bottom of the plot?

Because that gives the level "Not applicable" an integer value of 1.

## Modifying factor levels


```r
gss_cat %>% count(partyid)
#> # A tibble: 10 × 2
#>              partyid     n
#>               <fctr> <int>
#> 1          No answer   154
#> 2         Don't know     1
#> 3        Other party   393
#> 4  Strong republican  2314
#> 5 Not str republican  3032
#> 6       Ind,near rep  1791
#> # ... with 4 more rows
```


```r
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
    "Republican, strong"    = "Strong republican",
    "Republican, weak"      = "Not str republican",
    "Independent, near rep" = "Ind,near rep",
    "Independent, near dem" = "Ind,near dem",
    "Democrat, weak"        = "Not str democrat",
    "Democrat, strong"      = "Strong democrat"
  )) %>%
  count(partyid)
#> # A tibble: 10 × 2
#>                 partyid     n
#>                  <fctr> <int>
#> 1             No answer   154
#> 2            Don't know     1
#> 3           Other party   393
#> 4    Republican, strong  2314
#> 5      Republican, weak  3032
#> 6 Independent, near rep  1791
#> # ... with 4 more rows
```


```r
gss_cat %>%
  mutate(partyid = fct_recode(partyid,
    "Republican, strong"    = "Strong republican",
    "Republican, weak"      = "Not str republican",
    "Independent, near rep" = "Ind,near rep",
    "Independent, near dem" = "Ind,near dem",
    "Democrat, weak"        = "Not str democrat",
    "Democrat, strong"      = "Strong democrat",
    "Other"                 = "No answer",
    "Other"                 = "Don't know",
    "Other"                 = "Other party"
  )) %>%
  count(partyid)
#> # A tibble: 8 × 2
#>                 partyid     n
#>                  <fctr> <int>
#> 1                 Other   548
#> 2    Republican, strong  2314
#> 3      Republican, weak  3032
#> 4 Independent, near rep  1791
#> 5           Independent  4119
#> 6 Independent, near dem  2499
#> # ... with 2 more rows
```


```r
gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)
#> # A tibble: 2 × 2
#>        relig     n
#>       <fctr> <int>
#> 1 Protestant 10846
#> 2      Other 10637
```


```r
gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)
#> # A tibble: 10 × 2
#>                      relig     n
#>                     <fctr> <int>
#> 1               Protestant 10846
#> 2                 Catholic  5124
#> 3                     None  3523
#> 4                Christian   689
#> 5                    Other   458
#> 6                   Jewish   388
#> 7                 Buddhism   147
#> 8  Inter-nondenominational   109
#> 9             Moslem/islam   104
#> 10      Orthodox-christian    95
```

### Exercises

1. How have the proportions of people identifying as Democrat, Republican, and Independent changed over time?

To answer that, we need to combine the multiple levels into Democrat, Republican, and Independent

```r
levels(gss_cat$partyid)
#>  [1] "No answer"          "Don't know"         "Other party"       
#>  [4] "Strong republican"  "Not str republican" "Ind,near rep"      
#>  [7] "Independent"        "Ind,near dem"       "Not str democrat"  
#> [10] "Strong democrat"
```



```r
gss_cat %>% 
  mutate(partyid = 
           fct_collapse(partyid,
                        other = c("No answer", "Don't know", "Other party"),
                        rep = c("Strong republican", "Not str republican"),
                        ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                        dem = c("Not str democrat", "Strong democrat"))) %>%
  count(year, partyid)  %>%
  group_by(year) %>%
  mutate(p = n / sum(n)) %>%
  ggplot(aes(x = year, y = p,
             colour = fct_reorder2(partyid, year, p))) +
  geom_point() +
  geom_line() +
  labs(colour = "Party ID.")
  

                                  
```

<img src="factors_files/figure-html/unnamed-chunk-45-1.png" width="70%" style="display: block; margin: auto;" />

2. How could you collapse rincome into a small set of categories?

Group all the non-responses into one category, and then group other categories into a smaller number. Since there is a clear ordering, we wouldn't want to use something like `fct_lump`.

```r
levels(gss_cat$rincome)
#>  [1] "No answer"      "Don't know"     "Refused"        "$25000 or more"
#>  [5] "$20000 - 24999" "$15000 - 19999" "$10000 - 14999" "$8000 to 9999" 
#>  [9] "$7000 to 7999"  "$6000 to 6999"  "$5000 to 5999"  "$4000 to 4999" 
#> [13] "$3000 to 3999"  "$1000 to 2999"  "Lt $1000"       "Not applicable"
```


```r
library("stringr")
gss_cat %>%
  mutate(rincome = 
           fct_collapse(
             rincome,
             `Unknown` = c("No answer", "Don't know", "Refused", "Not applicable"),
             `Lt $5000` = c("Lt $1000", str_c("$", c("1000", "3000", "4000"),
                                              " to ", c("2999", "3999", "4999"))),
             `$5000 to 10000` = str_c("$", c("5000", "6000", "7000", "8000"),
                                      " to ", c("5999", "6999", "7999", "9999"))
           )) %>%
  ggplot(aes(x = rincome)) +
  geom_bar() + 
  coord_flip()
```

<img src="factors_files/figure-html/unnamed-chunk-47-1.png" width="70%" style="display: block; margin: auto;" />

