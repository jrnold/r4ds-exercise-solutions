
# Graphics for communication

## Introduction


```r
library("tidyverse")
#> -- Attaching packages ---------------------------------- tidyverse 1.2.1 --
#> √ ggplot2 3.0.0     √ purrr   0.2.5
#> √ tibble  1.4.2     √ dplyr   0.7.6
#> √ tidyr   0.8.1     √ stringr 1.3.1
#> √ readr   1.1.1     √ forcats 0.3.0
#> -- Conflicts ------------------------------------- tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library("modelr")
library("lubridate")
#> 
#> Attaching package: 'lubridate'
#> The following object is masked from 'package:base':
#> 
#>     date
```

## Label

### Exercise <span class="exercise-number">28.2.1</span>  {.unnumbered .exercise}

<div class="question">
Create one plot on the fuel economy data with customized `title`,
`subtitle`, `caption`, `x`, `y`, and `colour` labels.
</div>

<div class="answer">


```r
ggplot(data = mpg,
       mapping = aes(x = reorder(class, hwy, median), y = hwy)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    title = "Compact Cars have > 10 Hwy MPG than Pickup Trucks",
    subtitle = "Comparing the median highway mpg in each class",
    caption = "Data from fueleconomy.gov",
    x = "Car Class",
    y = "Highway Miles per Gallon"
  )
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-3-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.2.2</span> {.unnumbered .exercise}

<div class="question">
The `geom_smooth()` is somewhat misleading because the `hwy` for large engines is skewed upwards due to the inclusion of lightweight sports cars with big engines.
Use your modeling tools to fit and display
</div>

<div class="answer">
a better model.


```r
ggplot(mpg, aes(displ, hwy, colour = class)) +
  geom_point(aes(colour = class)) +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Fuel efficiency generally decreases with engine size",
    subtitle = "Subcompact cars show the greatest sensitivity to engine size",
    caption = "Data from fueleconomy.gov"
  )
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-4-1} \end{center}


```r
mod <- lm(hwy ~ class, data = mpg)
mpg %>%
  add_residuals(mod) %>%
  ggplot(aes(displ, resid)) +
  geom_point() +
  geom_smooth(method = "lm", se = FALSE) +
  labs(
    title = "Fuel efficiency decreases with engine size",
    subtitle = "Highway MPG for Cars After Subtracing Mean MPG of their Class",
    caption = "Data from fueleconomy.gov",
    x = "Highway MPG Relative to Class",
    y = "Engine Displacement"
  )
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-5-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.2.3</span> {.unnumbered .exercise}

<div class="question">
Take an exploratory graphic that you've created in the last month, and add informative titles to make it easier for others to understand.
</div>

<div class="answer">

By its very nature, this exercise is left to readers.

</div>

## Annotations

### Exercise <span class="exercise-number">28.3.1</span> {.unnumbered .exercise}

<div class="question">
Use `geom_text()` with infinite positions to place text at the four corners of the plot.
</div>

<div class="answer">

I can use similar code as the example in the text.
However, I need to use `vjust` and `hjust` in order for the text to appear in the plot, and these need to be different for each corner.
But, `geom_text()` takes `hjust` and `vjust` as aesthetics, I can add them to the data and mappings, and use a single `geom_text()` call instead of four different `geom_text()` calls with four different data arguments, and four different values of `hjust` and `vjust` arguments.

```r
label <- tribble(
  ~displ, ~hwy, ~label, ~vjust, ~hjust,
     Inf,  Inf,    "Top right", "top", "right",
     Inf, -Inf,    "Bottom right", "bottom", "right",
    -Inf,  Inf,    "Top left", "top", "left",
    -Inf, -Inf,    "Bottom left", "bottom", "left"
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label, vjust = vjust, hjust = hjust), data = label)
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-6-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.3.2</span> {.unnumbered .exercise}

<div class="question">
Read the documentation for `annotate()`. How can you use it to add a text label to a plot without having to create a tibble?
</div>

<div class="answer">

With annotate you use what would be aesthetic mappings directly as arguments:

```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  annotate("text", x = Inf, y = Inf,
           label = "Increasing engine size is \nrelated to decreasing fuel economy.", vjust = "top", hjust = "right")
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-7-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.3.3</span> {.unnumbered .exercise}

<div class="question">
How do labels with `geom_text()` interact with faceting?
How can you add a label to a single facet?
How can you put a different label in each facet?
(Hint: think about the underlying data.)
</div>

<div class="answer">

If the facet variable is not specified, the text is drawn in all facets.

```r
label <- tibble(
  displ = Inf,
  hwy = Inf,
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right",
            size = 2) +
  facet_wrap(~ class)
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-8-1} \end{center}

To draw the label in only one facet, add a column to the label data frame with the value of the faceting variable(s) in which to draw it.

```r
label <- tibble(
  displ = Inf,
  hwy = Inf,
  class = "2seater",
  label = "Increasing engine size is \nrelated to decreasing fuel economy."
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right",
            size = 2) +
  facet_wrap(~ class)
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-9-1} \end{center}

To draw labels in different plots, simply have the facetting variable(s):

```r
label <- tibble(
  displ = Inf,
  hwy = Inf,
  class = unique(mpg$class),
  label = stringr::str_c("Label for ", class)
)

ggplot(mpg, aes(displ, hwy)) +
  geom_point() +
  geom_text(aes(label = label), data = label, vjust = "top", hjust = "right",
            size = 3) +
  facet_wrap(~ class)
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-10-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.3.4</span> {.unnumbered .exercise}

<div class="question">
What arguments to `geom_label()` control the appearance of the background box?
</div>

<div class="answer">

-   `label.padding`: padding around label
-   `label.r`: amount of rounding in the corners
-   `label.size`: size of label border

</div>

### Exercise <span class="exercise-number">28.3.5</span> {.unnumbered .exercise}

<div class="question">
What are the four arguments to `arrow()`? How do they work?
Create a series of plots that demonstrate the most important options.
</div>

<div class="answer">

The four arguments are: (from the help for [arrow](https://www.rdocumentation.org/packages/grid/versions/3.3.2/topics/arrow))

-   `angle` : angle of arrow head
-   `length` : length of the arrow head
-   `ends`: ends of the line to draw arrow head
-   `type`: `"open"` or `"close"`: whether the arrow head is a closed or open triangle

</div>

## Scales

### Exercise <span class="exercise-number">28.4.1</span> {.unnumbered .exercise}

<div class="question">
Why doesn’t the following code override the default scale?
</div>

<div class="answer">


```r
df <- tibble(
  x = rnorm(10000),
  y = rnorm(10000)
)
ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_colour_gradient(low = "white", high = "red") +
  coord_fixed()
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-11-1} \end{center}

It does not override the default scale because the colors in `geom_hex()` are set by the `fill` aesthetic, not the `color` aesthetic.


```r
ggplot(df, aes(x, y)) +
  geom_hex() +
  scale_fill_gradient(low = "white", high = "red") +
  coord_fixed()
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-12-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.4.2</span> {.unnumbered .exercise}

<div class="question">
The first argument to every scale is the label for the scale.
It is equivalent to using the `labs` function.
</div>

<div class="answer">


```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(se = FALSE) +
  labs(
    x = "Engine displacement (L)",
    y = "Highway fuel economy (mpg)",
    colour = "Car type"
  )
#> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-13-1} \end{center}


```r
ggplot(mpg, aes(displ, hwy)) +
  geom_point(aes(colour = class)) +
  geom_smooth(se = FALSE) +
  scale_x_continuous("Engine displacement (L)") +
  scale_y_continuous("Highway fuel economy (mpg)") +
  scale_colour_discrete("Car type")
#> `geom_smooth()` using method = 'loess' and formula 'y ~ x'
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-14-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.4.3</span> {.unnumbered .exercise}

<div class="question">
Change the display of the presidential terms by:

1.  Combining the two variants shown above.
1.  Improving the display of the y axis.
1.  Labeling each term with the name of the president.
1.  Adding informative plot labels.
1.  Placing breaks every 4 years (this is trickier than it seems!).

</div>

<div class="answer">


```r
years <- lubridate::make_date(seq(year(min(presidential$start)),
             year(max(presidential$end)),
             by = 4), 1, 1)

presidential %>%
  mutate(id = 33 + row_number(),
         name_id = stringr::str_c(name, " (", id, ")"),
         name_id = factor(name_id, levels = name_id)) %>%
  ggplot(aes(start, name_id, colour = party)) +
    geom_point() +
    geom_segment(aes(xend = end, yend = name_id)) +
    scale_colour_manual(values = c(Republican = "red", Democratic = "blue")) +
    scale_y_discrete(NULL) +
    scale_x_date(NULL, breaks = years, date_labels = "'%y") +
    theme(panel.grid.minor = element_blank())
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-15-1} \end{center}

</div>

### Exercise <span class="exercise-number">28.4.4</span> {.unnumbered .exercise}

<div class="question">
Use `override.aes` to make the legend on the following plot easier to see.
</div>

<div class="answer">


```r
ggplot(diamonds, aes(carat, price)) +
  geom_point(aes(colour = cut), alpha = 1/20)
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-16-1} \end{center}

The problem with the legend is that the `alpha` value make the colors hard to see. So I'll override the alpha value to make the points solid in the legend.

```r
ggplot(diamonds, aes(carat, price)) +
  geom_point(aes(colour = cut), alpha = 1/20)  +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(nrow = 1, override.aes = list(alpha = 1)))  
```



\begin{center}\includegraphics[width=0.7\linewidth]{graphics-for-communication_files/figure-latex/unnamed-chunk-17-1} \end{center}

</div>

## Zooming

No exercises.

## Themes

No exercises.

## Saving your plots

No exercises.

## Learning more

No exercises.
