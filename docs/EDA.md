
# Exploratory Data Analysis

## Introduction


```r
library("tidyverse")
```

### Questions

### Variation

#### Exercises

<!-- 7.3.4 Exercises -->

*1. Explore the distribution of each of the x, y, and z variables in diamonds. What do you learn? Think about a diamond and how you might decide which dimension is the length, width, and depth.*

In order to make it eaiser to plot them, I'll reshape the dataset so that I 
can use the variables as facets.

```r
diamonds %>%
  mutate(id = row_number()) %>%
  select(x, y, z, id) %>%
  gather(variable, value, -id)  %>%
  ggplot(aes(x = value)) +
  geom_density() +
  geom_rug() +
  facet_grid(variable ~ .)
```

<img src="EDA_files/figure-html/unnamed-chunk-3-1.png" width="70%" style="display: block; margin: auto;" />

There several noticeable features of thedistributions

1. They are right skewed, with most diamonds small, but a few very large ones.
2. There is an outlier in `y`, and `z` (see the rug)
3. All three distributions have a bimodality (perhaps due to some sort of threshhold)

According to the documentation for `diamonds`:
`x` is length, `y` is width, and `z` is depth.
I don't know if I would have figured that out before; maybe if there was data on the type of cuts.


*2. Explore the distribution of price. Do you discover anything unusual or surprising? (Hint: Carefully think about the binwidth and make sure you try a wide range of values.)*

- The price data is spikey, but I can't tell what that corresponds to, as the following plots don't show much difference in the distributions in the last one and last two digits.
- There are no diamonds with a price of 1500
- There's a bulge in the distribution around 7500.


```r
ggplot(filter(diamonds, price < 2500), aes(x = price)) +
  geom_histogram(binwidth = 10, center = 0)
```

<img src="EDA_files/figure-html/unnamed-chunk-4-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(filter(diamonds), aes(x = price)) +
  geom_histogram(binwidth = 100, center = 0)
```

<img src="EDA_files/figure-html/unnamed-chunk-5-1.png" width="70%" style="display: block; margin: auto;" />

Distribution of last digit

```r
diamonds %>%
  mutate(ending = price %% 10) %>%
  ggplot(aes(x = ending)) +
  geom_histogram(binwidth = 1, center = 0) +
  geom_bar()
```

<img src="EDA_files/figure-html/unnamed-chunk-6-1.png" width="70%" style="display: block; margin: auto;" />


```r
diamonds %>%
  mutate(ending = price %% 100) %>%
  ggplot(aes(x = ending)) +
  geom_histogram(binwidth = 1) +
  geom_bar()
```

<img src="EDA_files/figure-html/unnamed-chunk-7-1.png" width="70%" style="display: block; margin: auto;" />



```r
diamonds %>%
  mutate(ending = price %% 1000) %>%
  filter(ending >= 500, ending <= 800)  %>%
  ggplot(aes(x = ending)) +
  geom_histogram(binwidth = 1) +
  geom_bar()
```

<img src="EDA_files/figure-html/unnamed-chunk-8-1.png" width="70%" style="display: block; margin: auto;" />

*3. How many diamonds are 0.99 carat? How many are 1 carat? What do you think is the cause of the difference?*

There are more than 70 times as many 1 carat diamonds as 0.99 carat diamond.

```r
diamonds %>%
  filter(carat >= 0.99, carat <= 1) %>%
  count(carat)
#> # A tibble: 2 × 2
#>   carat     n
#>   <dbl> <int>
#> 1  0.99    23
#> 2  1.00  1558
```

I don't know exactly the process behind how carats are measured, but some way or another some diamonds carat values are being "rounded up", because presumably there is a premium for a 1 carat diamond vs. a 0.99 carat diamond beyond the expected increase in price due to a 0.01 carat increase.

To check this intuition, we'd want to look at the number of diamonds in each carat range to seem if there is an abnormally low number at 0.99 carats, and an abnormally high number at 1 carat.


```r
diamonds %>%
   filter(carat >= 0.9, carat <= 1.1) %>%
   count(carat) %>%
   print(n = 30)
#> # A tibble: 21 × 2
#>    carat     n
#>    <dbl> <int>
#> 1   0.90  1485
#> 2   0.91   570
#> 3   0.92   226
#> 4   0.93   142
#> 5   0.94    59
#> 6   0.95    65
#> 7   0.96   103
#> 8   0.97    59
#> 9   0.98    31
#> 10  0.99    23
#> 11  1.00  1558
#> 12  1.01  2242
#> 13  1.02   883
#> 14  1.03   523
#> 15  1.04   475
#> 16  1.05   361
#> 17  1.06   373
#> 18  1.07   342
#> 19  1.08   246
#> 20  1.09   287
#> 21  1.10   278
```



**Q** Can you think of other examples of similar phenoma where you might expect to see similar discontinuities in areas related to your research.

4. Compare and contrast `coord_cartesian()` vs `xlim()` or `ylim()` when zooming in on a histogram. What happens if you leave `binwidth` unset? What happens if you try and zoom so only half a bar shows?

`coord_cartesian` simply zooms in on the area specified by the limits. The calculation of the histogram is unaffected.


```r
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = price)) +
  coord_cartesian(xlim = c(100, 5000), ylim = c(0, 3000))
#> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="EDA_files/figure-html/unnamed-chunk-11-1.png" width="70%" style="display: block; margin: auto;" />

However, the `xlim` and `ylim` functions first drop any values outside the limits (the `ylim` doesn't matter in this case), then calculates the histogram, and draws the graph with the given limits.


```r
ggplot(diamonds) + 
  geom_histogram(mapping = aes(x = price)) +
  xlim(100, 5000) +
  ylim(0, 3000)
#> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
#> Warning: Removed 14714 rows containing non-finite values (stat_bin).
#> Warning: Removed 5 rows containing missing values (geom_bar).
```

<img src="EDA_files/figure-html/unnamed-chunk-12-1.png" width="70%" style="display: block; margin: auto;" />


## Missing Values

### Exercises

1. What happens to missing values in a histogram? What happens to missing values in a bar chart? Why is there a difference?

Missing values are removed when the number of observations in each bin are calculated. See the warning message: `Removed 9 rows containing non-finite values (stat_bin)`

```r
diamonds2 <- diamonds %>% 
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

ggplot(diamonds2, aes(x = y)) +
  geom_histogram()
#> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
#> Warning: Removed 9 rows containing non-finite values (stat_bin).
```

<img src="EDA_files/figure-html/unnamed-chunk-13-1.png" width="70%" style="display: block; margin: auto;" />

In `geom_bar`, `NA` is treated as another category. This is because the `x` aesthetic in `geom_bar` should be a discrete (categorical) variable, and missing values are just another category.

```r
diamonds %>%
  mutate(cut = if_else(runif(n()) < 0.1, NA_character_, as.character(cut))) %>%
  ggplot() +
  geom_bar(mapping = aes(x = cut))
```

<img src="EDA_files/figure-html/unnamed-chunk-14-1.png" width="70%" style="display: block; margin: auto;" />

In a histogram, the `x` aesthetic variable needs to be numeric, and `stat_bin` groups the observations by ranges into bins.
Since the numeric value of the `NA` observations is unknown, they cannot be placed in a particular bin, and are dropped.


2. What does `na.rm = TRUE` do in `mean()` and `sum()`?

This option removes `NA` values from the vector prior to calculating the mean and sum. 


```r
mean(c(0, 1, 2, NA), na.rm = TRUE)
#> [1] 1
sum(c(0, 1, 2, NA), na.rm = TRUE)
#> [1] 3
```

## Covariation

### A categorical and continuous variable

For a history of the boxplot see Wikckham [40 years of the boxplot] (http://vita.had.co.nz/papers/boxplots.pdf)

Krywinski, Martin, and Naomi Altman. 2014. "Points of Significance: Visualizing samples with box plots." *Nature Methods* [URL](http://www.nature.com/nmeth/journal/v11/n2/full/nmeth.2813.html)

Where does the 1.5 x IQR come from? It's kind of arbitrary. But in a normal distribution, the IQR is approximatley 2, and 1.5 x IQR is approx 4, so the outliers are approximately within 4 standard deviations of the median (mean).


#### Excercises

1.  Use what you've learned to improve the visualisation of the departure times
    of cancelled vs. non-cancelled flights.
 
Instead of a `freqplot` use a box-plot

```r
nycflights13::flights %>% 
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %% 100,
    sched_dep_time = sched_hour + sched_min / 60
  ) %>% 
  ggplot() +
    geom_boxplot(mapping = aes(y = sched_dep_time, x = cancelled))
```

<img src="EDA_files/figure-html/unnamed-chunk-16-1.png" width="70%" style="display: block; margin: auto;" />

2. What variable in the diamonds dataset is most important for predicting
    the price of a diamond? How is that variable correlated with cut?
    Why does the combination of those two relationships lead to lower quality
    diamonds being more expensive?

I'm not exactly sure what this question is asking conditional on using only the tools introduced in the book thus far.

3. Install the **ggstance** package, and create a horizontal boxplot.
   How does this compare to using `coord_flip()`?
   
Earlier we created a horizontal boxplot of the distribution `hwy` by `class`, using `geom_boxplot` and `coord_flip`:   

```r
ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median), y = hwy)) +
  coord_flip()
```

<img src="EDA_files/figure-html/unnamed-chunk-17-1.png" width="70%" style="display: block; margin: auto;" />

In this case the output looks the same, but in the aesthetics the `x` and `y` are flipped from the previous case.

```r
library("ggstance")
#> 
#> Attaching package: 'ggstance'
#> The following objects are masked from 'package:ggplot2':
#> 
#>     geom_errorbarh, GeomErrorbarh

ggplot(data = mpg) +
  geom_boxploth(mapping = aes(y = reorder(class, hwy, FUN = median), x = hwy))
```

<img src="EDA_files/figure-html/unnamed-chunk-18-1.png" width="70%" style="display: block; margin: auto;" />

4. One problem with boxplots is that they were developed in an era of much smaller datasets and tend to display a prohibitively large number of “outlying values”. One approach to remedy this problem is the letter value plot. Install the **lvplot** package, and try using `geom_lv()` to display the distribution of price vs cut. What do you learn? How do you interpret the plots?

The boxes of the letter-value plot correspond to many more quantiles.
They are useful for larger datasets because

1. larger datasets can give precise estiamtes of quantiles beyond the quartiles
2. in expectation, larger datasets should have many more outliers

The letter-value plot is described in:

>  Heike Hofmann, Karen Kafadar, and Hadley Wickham. 2011. "Letter-value plots: Boxplots for large data" http://vita.had.co.nz/papers/letter-value-plot.pdf


```r
library("lvplot")
ggplot(diamonds, aes(x = cut, y = price)) +
  geom_lv()
```

<img src="EDA_files/figure-html/unnamed-chunk-19-1.png" width="70%" style="display: block; margin: auto;" />

5. Compare and contrast `geom_violin()` with a facetted `geom_histogram()`,
   or a coloured `geom_freqpoly()`. What are the pros and cons of each 
   method?

I produce plots for these three methods below. The `geom_freqpoly` is better for look-up: meaning that given a price, it is easy to tell which `cut` has the highest density. However, the overlapping lines makes it difficult to distinguish how the overall distributions relate to each other.
The `geom_violin` and facetted `geom_histogram` have similar strengths and weaknesses.
It is easy to visually distinguish differences in the overall shape of the distributions (skewness, central values, variance, etc).
However, since we can't easily compare the vertical values of the distribution, its difficult to look up which category has the highest density for a given price.
All of these methods depend on tuning parameters to determine the level of smoothness of the distribution.



```r
ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) + 
  geom_freqpoly(mapping = aes(colour = cut), binwidth = 500)
```

<img src="EDA_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_histogram() +
  facet_wrap(~ cut, ncol = 1, scales = "free_y")
#> `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.
```

<img src="EDA_files/figure-html/unnamed-chunk-21-1.png" width="70%" style="display: block; margin: auto;" />



```r
ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_violin() +
  coord_flip()
```

<img src="EDA_files/figure-html/unnamed-chunk-22-1.png" width="70%" style="display: block; margin: auto;" />

The violin plot was first described in 

> Hintze JL, Nelson RD (1998). "Violin Plots: A Box Plot-Density Trace Synergism." The American Statistician, 52(2), 181–184


6.  If you have a small dataset, it's sometimes useful to use `geom_jitter()`
    to see the relationship between a continuous and categorical variable.
    The **ggbeeswarm** package provides a number of methods similar to 
    `geom_jitter()`. List them and briefly describe what each one does.

There are two methods:

- `geom_quasirandom` that produces plots that resemble something between jitter and violin. There are several different methods that determine exactly how the random location of the points is generated.
- `geom_beeswarm` creates a shape similar to a violin plot, but by offsetting the points.
    
I'll use the `mpg`  boxplot example since these methods display individual points, they are better suited for smaller datasets.


```r
library("ggbeeswarm")
ggplot(data = mpg) +
  geom_quasirandom(mapping = aes(x = reorder(class, hwy, FUN = median),
                                 y = hwy))
```

<img src="EDA_files/figure-html/unnamed-chunk-23-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(data = mpg) +
  geom_quasirandom(mapping = aes(x = reorder(class, hwy, FUN = median),
                                 y = hwy),
                   method = "tukey")
```

<img src="EDA_files/figure-html/unnamed-chunk-24-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(data = mpg) +
  geom_quasirandom(mapping = aes(x = reorder(class, hwy, FUN = median),
                                 y = hwy),
                   method = "tukeyDense")
```

<img src="EDA_files/figure-html/unnamed-chunk-25-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(data = mpg) +
  geom_quasirandom(mapping = aes(x = reorder(class, hwy, FUN = median),
                                 y = hwy),
                   method = "frowney")
```

<img src="EDA_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />


```r
ggplot(data = mpg) +
  geom_quasirandom(mapping = aes(x = reorder(class, hwy, FUN = median),
                                 y = hwy),
                   method = "smiley")
```

<img src="EDA_files/figure-html/unnamed-chunk-27-1.png" width="70%" style="display: block; margin: auto;" />



```r
ggplot(data = mpg) +
  geom_beeswarm(mapping = aes(x = reorder(class, hwy, FUN = median),
                                 y = hwy))
```

<img src="EDA_files/figure-html/unnamed-chunk-28-1.png" width="70%" style="display: block; margin: auto;" />


### Two categorical variables

1. 

2. Use geom_tile() together with dplyr to explore how average flight delays vary by destination and month of year. What makes the plot difficult to read? How could you improve it?

3. Why is it slightly better to use `aes(x = color, y = cut)` rather than `aes(x = cut, y = color)` in the example above?


It's usually better to use the categorical variable with a larger number of categories or the longer labels on the y axis. 
If at all possible, labels should be horizontal because that is easier to read. 

However, switching the order doesn't result in overlapping labels.

```r
diamonds %>% 
  count(color, cut) %>%  
  ggplot(mapping = aes(y = color, x = cut)) +
    geom_tile(mapping = aes(fill = n))
```

<img src="EDA_files/figure-html/unnamed-chunk-29-1.png" width="70%" style="display: block; margin: auto;" />

Another justification, for switching the order is that the larger numbers are at the top when `x = color` and `y = cut`, and that lowers the cognitive burden of interpreting the plot.


### Two continuous variables

