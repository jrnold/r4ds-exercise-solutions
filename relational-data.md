# Relational data {#relational-data .r4ds-section}

## Introduction {#introduction-7 .r4ds-section}

The datamodelr package is used to draw database schema.


```r
library("tidyverse")
library("nycflights13")
library("viridis")
library("datamodelr")
```

## nycflights13 {#nycflights13-relational .r4ds-section}

### Exercise 13.2.1 {.unnumbered .exercise data-number="13.2.1"}

<div class="question">

Imagine you wanted to draw (approximately) the route each plane flies from its origin to its destination.
What variables would you need? 
What tables would you need to combine?

</div>

<div class="answer">

Drawing the routes requires the latitude and longitude of the origin and the destination airports of each flight.
This requires the `flights` and `airports` tables.
The `flights` table has the origin (`origin`) and destination (`dest`) airport of each flight.
The `airports` table has the longitude (`lon`) and latitude (`lat`) of each airport.
To get the latitude and longitude for the origin and destination of each flight,
requires two joins for `flights` to `airports`,
once for the latitude and longitude of the origin airport,
and once for the latitude and longitude of the destination airport.
I use an inner join in order to drop any flights with missing airports since they will not have a longitude or latitude.

```r
flights_latlon <- flights %>%
  inner_join(select(airports, origin = faa, origin_lat = lat, origin_lon = lon),
    by = "origin"
  ) %>%
  inner_join(select(airports, dest = faa, dest_lat = lat, dest_lon = lon),
    by = "dest"
  )
```

This plots the approximate flight paths of the first 100 flights in the `flights` dataset.

```r
flights_latlon %>%
  slice(1:100) %>%
  ggplot(aes(
    x = origin_lon, xend = dest_lon,
    y = origin_lat, yend = dest_lat
  )) +
  borders("state") +
  geom_segment(arrow = arrow(length = unit(0.1, "cm"))) +
  coord_quickmap() +
  labs(y = "Latitude", x = "Longitude")
```

<img src="relational-data_files/figure-html/unnamed-chunk-2-1.png" width="70%" style="display: block; margin: auto;" />

</div>

### Exercise 13.2.2 {.unnumbered .exercise data-number="13.2.2"}

<div class="question">

I forgot to draw the relationship between `weather` and `airports`. 
What is the relationship and how should it appear in the diagram?

</div>

<div class="answer">

The column `airports$faa` is a foreign key of `weather$origin`.
The following drawing updates the one in [Section 13.2](https://r4ds.had.co.nz/relational-data.html#nycflights13-relational) to include this relation.
The line representing the new relation between `weather` and `airports` is colored black.
The lines representing the old relations are gray and thinner.

<img src="diagrams/nycflights.png" style="display: block; margin: auto;" />

</div>

### Exercise 13.2.3 {.unnumbered .exercise data-number="13.2.3"}

<div class="question">

Weather only contains information for the origin (NYC) airports. 
If it contained weather records for all airports in the USA, what additional relation would it define with `flights`?

</div>

<div class="answer">

If the weather was included for all airports in the US, then it would provide the weather for the destination of each flight.
The `weather` data frame columns (`year`, `month`, `day`, `hour`, `origin`) are a foreign key for the `flights` data frame columns (`year`, `month`, `day`, `hour`, `dest`).
This would provide information about the weather at the destination airport at the time of the flight take off, unless the arrival date-time were calculated.

So why was this not a relationship prior to adding additional rows to the `weather` table?
In a foreign key relationship, the collection of columns in the child table 
must refer to a unique collection of columns in the parent table. 
When the `weather` table only contained New York airports,
there were many values of  (`year`, `month`, `day`, `hour`, `dest`) in `flights` that
did not appear in the `weather` table. 
Therefore, it was not a foreign key. It was only after
all combinations of year, month, day, hour, and airports that are defined in `flights`
were added to the `weather` table that there existed this relation between these tables.

</div>

### Exercise 13.2.4 {.unnumbered .exercise data-number="13.2.4"}

<div class="question">
We know that some days of the year are “special”, and fewer people than usual fly on them. 
How might you represent that data as a data frame? 
What would be the primary keys of that table? 
How would it connect to the existing tables?
</div>

<div class="answer">

I would add a table of special dates, similar to the following table.

```r
special_days <- tribble(
  ~year, ~month, ~day, ~holiday,
  2013, 01, 01, "New Years Day",
  2013, 07, 04, "Independence Day",
  2013, 11, 29, "Thanksgiving Day",
  2013, 12, 25, "Christmas Day"
)
```

The primary key of the table would be the (`year`, `month`, `day`) columns.
The (`year`, `month`, `day`) columns could be used to join `special_days` with other tables.

</div>

## Keys {#keys .r4ds-section}

### Exercise 13.3.1 {.unnumbered .exercise data-number="13.3.1"}

<div class="question">
Add a surrogate key to flights.
</div>

<div class="answer">

I add the column `flight_id` as a surrogate key.
I sort the data prior to making the key, even though it is not strictly necessary, so the order of the rows has some meaning.

```r
flights %>%
  arrange(year, month, day, sched_dep_time, carrier, flight) %>%
  mutate(flight_id = row_number()) %>%
  glimpse()
#> Rows: 336,776
#> Columns: 20
#> $ year           <int> 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, 2013, …
#> $ month          <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ day            <int> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, …
#> $ dep_time       <int> 517, 533, 542, 544, 554, 559, 558, 559, 558, 558, 557,…
#> $ sched_dep_time <int> 515, 529, 540, 545, 558, 559, 600, 600, 600, 600, 600,…
#> $ dep_delay      <dbl> 2, 4, 2, -1, -4, 0, -2, -1, -2, -2, -3, NA, 1, 0, -5, …
#> $ arr_time       <int> 830, 850, 923, 1004, 740, 702, 753, 941, 849, 853, 838…
#> $ sched_arr_time <int> 819, 830, 850, 1022, 728, 706, 745, 910, 851, 856, 846…
#> $ arr_delay      <dbl> 11, 20, 33, -18, 12, -4, 8, 31, -2, -3, -8, NA, -6, -7…
#> $ carrier        <chr> "UA", "UA", "AA", "B6", "UA", "B6", "AA", "AA", "B6", …
#> $ flight         <int> 1545, 1714, 1141, 725, 1696, 1806, 301, 707, 49, 71, 7…
#> $ tailnum        <chr> "N14228", "N24211", "N619AA", "N804JB", "N39463", "N70…
#> $ origin         <chr> "EWR", "LGA", "JFK", "JFK", "EWR", "JFK", "LGA", "LGA"…
#> $ dest           <chr> "IAH", "IAH", "MIA", "BQN", "ORD", "BOS", "ORD", "DFW"…
#> $ air_time       <dbl> 227, 227, 160, 183, 150, 44, 138, 257, 149, 158, 140, …
#> $ distance       <dbl> 1400, 1416, 1089, 1576, 719, 187, 733, 1389, 1028, 100…
#> $ hour           <dbl> 5, 5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, …
#> $ minute         <dbl> 15, 29, 40, 45, 58, 59, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ time_hour      <dttm> 2013-01-01 05:00:00, 2013-01-01 05:00:00, 2013-01-01 …
#> $ flight_id      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…
```

</div>

### Exercise 13.3.2 {.unnumbered .exercise data-number="13.3.2"}

<div class="question">
Identify the keys in the following datasets

1.  `Lahman::Batting`
1.  `babynames::babynames`
1.  `nasaweather::atmos`
1.  `fueleconomy::vehicles`
1.  `ggplot2::diamonds`

(You might need to install some packages and read some documentation.)

</div>

<div class="answer">

The answer to each part follows.

1.  The primary key for `Lahman::Batting` is (`playerID`, `yearID`, `stint`).
    The columns (`playerID`, `yearID`) are not a primary key because players can play on different teams within the same year.

    
    ```r
    Lahman::Batting %>%
      count(playerID, yearID, stint) %>%
      filter(n > 1) %>%
      nrow()
    #> [1] 0
    ```

1.  The primary key for `babynames::babynames` is (`year`, `sex`, `name`).
    The columns (`year`, `name`) are not a primary key since there are separate counts for each name for each sex, and the same names can be used by more than one sex.

    
    ```r
    babynames::babynames %>%
      count(year, sex, name) %>%
      filter(n > 1) %>%
      nrow()
    #> Using `n` as weighting variable
    #> ℹ Quiet this message with `wt = n` or count rows with `wt = 1`
    #> [1] 1924665
    ```

1.  The primary key for `nasaweather::atmos` is (`lat`, `long`, `year`, `month`).
    The primary key represents the location and time that the measurement was taken.

    
    ```r
    nasaweather::atmos %>%
      count(lat, long, year, month) %>%
      filter(n > 1) %>%
      nrow()
    #> [1] 0
    ```

1.  The column `id`, the unique EPA identifier of the vehicle, is the primary key for `fueleconomy::vehicles`.

    
    ```r
    fueleconomy::vehicles %>%
      count(id) %>%
      filter(n > 1) %>%
      nrow()
    #> [1] 0
    ```

1.  There is no primary key for `ggplot2::diamonds` since there is no combination of variables that uniquely identifies each observation.
    This is implied by the fact that the number of distinct rows in the dataset is less than the total number of rows, meaning that there are some duplicate rows.

    
    ```r
    ggplot2::diamonds %>%
      distinct() %>%
      nrow()
    #> [1] 53794
    nrow(ggplot2::diamonds)
    #> [1] 53940
    ```
    
    If we need a unique identifier for our analysis, we could add a surrogate key.
    
    
    ```r
    diamonds <- mutate(ggplot2::diamonds, id = row_number())
    ```

</div>

### Exercise 13.3.3 {.unnumbered .exercise data-number="13.3.3"}

<div class="question">

Draw a diagram illustrating the connections between the `Batting`, `Master`, and `Salaries` tables in the Lahman package. 
Draw another diagram that shows the relationship between `Master`, `Managers`, `AwardsManagers`.

How would you characterize the relationship between the `Batting`, `Pitching`, and `Fielding` tables?

</div>

<div class="answer">

For the `Batting`, `Master`, and `Salaries` tables:

-   `Master`

    -   Primary key: `playerID`

-   `Batting`

    -   Primary key: `playerID`, `yearID`, `stint`

    -   Foreign keys:

        -   `playerID` = `Master$playerID` (many-to-1)

-   `Salaries`

    -   Primary key: `yearID`, `teamID`, `playerID`

    -   Foreign keys:

        -   `playerID` = `Master$playerID` (many-to-1)

The columns `teamID` and `lgID` are not foreign keys even though they appear in multiple tables (with the same meaning) because they are not primary keys for any of the tables considered in this exercise.
The `teamID` variable references `Teams$teamID`, and `lgID` does not have its own table.

*R for Data Science* uses database schema diagrams to illustrate relations between the tables.
Most flowchart or diagramming software can be used used to create database schema diagrams, as well as some specialized database software.
The diagrams in *R for Data Science* were created with [OmniGraffle](https://www.gliffy.com/), and their sources can be found in its [GitHub repository](https://github.com/hadley/r4ds/tree/master/diagrams).

The following diagram was created with OmniGraffle in the same style as those 
in *R for Data Science* . 
It shows the relations between the `Master`, `Batting` and `Salaries` tables.

<img src="diagrams/Lahman1.png" style="display: block; margin: auto;" />

Another option to draw database schema diagrams is the R package [datamodelr](https://github.com/bergant/datamodelr), which can programmatically create database schema diagrams.
The following code uses datamodelr to draw a diagram of the relations between the `Batting`, `Master`, and `Salaries` tables.


```r
dm1 <- dm_from_data_frames(list(
  Batting = Lahman::Batting,
  Master = Lahman::Master,
  Salaries = Lahman::Salaries
)) %>%
  dm_set_key("Batting", c("playerID", "yearID", "stint")) %>%
  dm_set_key("Master", "playerID") %>%
  dm_set_key("Salaries", c("yearID", "teamID", "playerID")) %>%
  dm_add_references(
    Batting$playerID == Master$playerID,
    Salaries$playerID == Master$playerID
  )

dm_create_graph(dm1, rankdir = "LR", columnArrows = TRUE) %>%
  dm_render_graph()
```

<!--html_preserve--><div id="htmlwidget-ac96cb3ee4656e2e9ec3" style="width:70%;height:415.296px;" class="grViz html-widget"></div>
<script type="application/json" data-for="htmlwidget-ac96cb3ee4656e2e9ec3">{"x":{"diagram":"#data_model\ndigraph {\ngraph [rankdir=LR tooltip=\"Data Model\" ]\n\nnode [margin=0 fontcolor = \"#444444\" ]\n\nedge [color = \"#555555\", arrowsize = 1, ]\n\n\n  \"Batting\" [label = <<TABLE ALIGN=\"LEFT\" BORDER=\"1\" CELLBORDER=\"0\" CELLSPACING=\"0\" COLOR=\"#555555\">\n    <TR>\n      <TD COLSPAN=\"1\" BGCOLOR=\"#EFEBDD\" BORDER=\"0\"><FONT COLOR=\"#000000\">Batting<\/FONT>\n<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"playerID\"><U>playerID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"yearID\"><U>yearID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"stint\"><U>stint<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">teamID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">lgID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">G<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">AB<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">R<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">H<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">X2B<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">X3B<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">HR<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">RBI<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">SB<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">CS<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">BB<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">SO<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">IBB<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">HBP<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">SH<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">SF<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">GIDP<\/TD>\n    <\/TR>\n  <\/TABLE>>, shape = \"plaintext\"] \n\n  \"Master\" [label = <<TABLE ALIGN=\"LEFT\" BORDER=\"1\" CELLBORDER=\"0\" CELLSPACING=\"0\" COLOR=\"#555555\">\n    <TR>\n      <TD COLSPAN=\"1\" BGCOLOR=\"#EFEBDD\" BORDER=\"0\"><FONT COLOR=\"#000000\">Master<\/FONT>\n<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"playerID\"><U>playerID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthYear<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthMonth<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthDay<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthCountry<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthState<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthCity<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathYear<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathMonth<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathDay<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathCountry<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathState<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathCity<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">nameFirst<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">nameLast<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">nameGiven<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">weight<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">height<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">bats<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">throws<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">debut<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">finalGame<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">retroID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">bbrefID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathDate<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthDate<\/TD>\n    <\/TR>\n  <\/TABLE>>, shape = \"plaintext\"] \n\n  \"Salaries\" [label = <<TABLE ALIGN=\"LEFT\" BORDER=\"1\" CELLBORDER=\"0\" CELLSPACING=\"0\" COLOR=\"#555555\">\n    <TR>\n      <TD COLSPAN=\"1\" BGCOLOR=\"#EFEBDD\" BORDER=\"0\"><FONT COLOR=\"#000000\">Salaries<\/FONT>\n<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"yearID\"><U>yearID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"teamID\"><U>teamID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">lgID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"playerID\"><U>playerID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">salary<\/TD>\n    <\/TR>\n  <\/TABLE>>, shape = \"plaintext\"] \n\n\"Batting\":\"playerID\"->\"Master\":\"playerID\"\n\"Salaries\":\"playerID\"->\"Master\":\"playerID\"\n}","config":{"engine":null,"options":null}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

For the `Master`, `Manager`, and `AwardsManagers` tables:

-   `Master`

    -   Primary key: `playerID`

-   `Managers`

    -   Primary key: `yearID`, `teamID`, `inseason`

    -   Foreign keys:

        -   `playerID` references `Master$playerID` (many-to-1)

-   `AwardsManagers`:

    -   Primary key: `playerID`, `awardID`, `yearID`

    -   Foreign keys:

        -   `playerID` references `Master$playerID` (many-to-1)

For `AwardsManagers`, the columns (`awardID`, `yearID`, `lgID`) are not a primary
key because there can be, and have been ties, as indicated by the `tie` variable.

The relations between the `Master`, `Managers`, and `AwardsManagers` tables
are shown in the following two diagrams: the first created manually with OmniGraffle,
and the second programmatically in R with the datamodelr package.

<img src="diagrams/Lahman2.png" style="display: block; margin: auto;" />


```r
dm2 <- dm_from_data_frames(list(
  Master = Lahman::Master,
  Managers = Lahman::Managers,
  AwardsManagers = Lahman::AwardsManagers
)) %>%
  dm_set_key("Master", "playerID") %>%
  dm_set_key("Managers", c("yearID", "teamID", "inseason")) %>%
  dm_set_key("AwardsManagers", c("playerID", "awardID", "yearID")) %>%
  dm_add_references(
    Managers$playerID == Master$playerID,
    AwardsManagers$playerID == Master$playerID
  )

dm_create_graph(dm2, rankdir = "LR", columnArrows = TRUE) %>%
  dm_render_graph()
```

<!--html_preserve--><div id="htmlwidget-e5c8c404fe174e4c81bd" style="width:70%;height:415.296px;" class="grViz html-widget"></div>
<script type="application/json" data-for="htmlwidget-e5c8c404fe174e4c81bd">{"x":{"diagram":"#data_model\ndigraph {\ngraph [rankdir=LR tooltip=\"Data Model\" ]\n\nnode [margin=0 fontcolor = \"#444444\" ]\n\nedge [color = \"#555555\", arrowsize = 1, ]\n\n\n  \"AwardsManagers\" [label = <<TABLE ALIGN=\"LEFT\" BORDER=\"1\" CELLBORDER=\"0\" CELLSPACING=\"0\" COLOR=\"#555555\">\n    <TR>\n      <TD COLSPAN=\"1\" BGCOLOR=\"#EFEBDD\" BORDER=\"0\"><FONT COLOR=\"#000000\">AwardsManagers<\/FONT>\n<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"playerID\"><U>playerID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"awardID\"><U>awardID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"yearID\"><U>yearID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">lgID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">tie<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">notes<\/TD>\n    <\/TR>\n  <\/TABLE>>, shape = \"plaintext\"] \n\n  \"Managers\" [label = <<TABLE ALIGN=\"LEFT\" BORDER=\"1\" CELLBORDER=\"0\" CELLSPACING=\"0\" COLOR=\"#555555\">\n    <TR>\n      <TD COLSPAN=\"1\" BGCOLOR=\"#EFEBDD\" BORDER=\"0\"><FONT COLOR=\"#000000\">Managers<\/FONT>\n<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"playerID\">playerID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"yearID\"><U>yearID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"teamID\"><U>teamID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">lgID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"inseason\"><U>inseason<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">G<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">W<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">L<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">rank<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">plyrMgr<\/TD>\n    <\/TR>\n  <\/TABLE>>, shape = \"plaintext\"] \n\n  \"Master\" [label = <<TABLE ALIGN=\"LEFT\" BORDER=\"1\" CELLBORDER=\"0\" CELLSPACING=\"0\" COLOR=\"#555555\">\n    <TR>\n      <TD COLSPAN=\"1\" BGCOLOR=\"#EFEBDD\" BORDER=\"0\"><FONT COLOR=\"#000000\">Master<\/FONT>\n<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\" PORT=\"playerID\"><U>playerID<\/U><\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthYear<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthMonth<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthDay<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthCountry<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthState<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthCity<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathYear<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathMonth<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathDay<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathCountry<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathState<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathCity<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">nameFirst<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">nameLast<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">nameGiven<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">weight<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">height<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">bats<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">throws<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">debut<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">finalGame<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">retroID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">bbrefID<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">deathDate<\/TD>\n    <\/TR>\n    <TR>\n      <TD ALIGN=\"LEFT\" BGCOLOR=\"#FFFFFF\">birthDate<\/TD>\n    <\/TR>\n  <\/TABLE>>, shape = \"plaintext\"] \n\n\"Managers\":\"playerID\"->\"Master\":\"playerID\"\n\"AwardsManagers\":\"playerID\"->\"Master\":\"playerID\"\n}","config":{"engine":null,"options":null}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

The primary keys of `Batting`, `Pitching`, and `Fielding` are the following:

-   `Batting`: (`playerID`, `yearID`, `stint`)
-   `Pitching`: (`playerID`, `yearID`, `stint`)
-   `Fielding`: (`playerID`, `yearID`, `stint`, `POS`).

While `Batting` and `Pitching` has one row per player, year, stint, the `Fielding`
table has additional rows for each position (`POS`) a player played within a stint.

Since `Batting`, `Pitching`, and `Fielding` all share the `playerID`, `yearID`, and `stint`
we would expect some foreign key relations between these tables.
The columns (`playerID`, `yearID`, `stint`) in `Pitching` are a foreign key which
references the same columns in `Batting`. We can check this by checking that
all observed combinations of values of these columns appearing in `Pitching`
also appear in `Batting`. To do this I use an anti-join, which is discussed
in the section [Filtering Joins](https://r4ds.had.co.nz/relational-data.html#filtering-joins).

```r
nrow(anti_join(Lahman::Pitching, Lahman::Batting,
  by = c("playerID", "yearID", "stint")
))
#> [1] 0
```
Similarly, the columns (`playerID`, `yearID`, `stint`) in `Fielding` are a foreign key which references the same columns in `Batting`.

```r
nrow(anti_join(Lahman::Fielding, Lahman::Batting,
  by = c("playerID", "yearID", "stint")
))
#> [1] 0
```

The following diagram shows the relations between the `Batting`, `Pitching`, and
`Fielding` tables.

<img src="diagrams/Lahman3.png" style="display: block; margin: auto;" />

</div>

## Mutating joins {#mutating-joins .r4ds-section}


```r
flights2 <- flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier)
```

### Exercise 13.4.1 {.unnumbered .exercise data-number="13.4.1"}

<div class="question">
Compute the average delay by destination, then join on the `airports` data frame so you can show the spatial distribution of delays. Here’s an easy way to draw a map of the United States:


```r
airports %>%
  semi_join(flights, c("faa" = "dest")) %>%
  ggplot(aes(lon, lat)) +
  borders("state") +
  geom_point() +
  coord_quickmap()
```

<img src="relational-data_files/figure-html/unnamed-chunk-20-1.png" width="70%" style="display: block; margin: auto;" />

(Don’t worry if you don’t understand what `semi_join()` does — you’ll learn about it next.)

You might want to use the size or color of the points to display the average delay for each airport.

</div>

<div class="answer">


```r
avg_dest_delays <-
  flights %>%
  group_by(dest) %>%
  # arrival delay NA's are cancelled flights
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  inner_join(airports, by = c(dest = "faa"))
#> `summarise()` ungrouping output (override with `.groups` argument)
```

```r
avg_dest_delays %>%
  ggplot(aes(lon, lat, colour = delay)) +
  borders("state") +
  geom_point() +
  coord_quickmap()
```

<img src="relational-data_files/figure-html/unnamed-chunk-22-1.png" width="70%" style="display: block; margin: auto;" />

</div>

### Exercise 13.4.2 {.unnumbered .exercise data-number="13.4.2"}

<div class="question">
Add the location of the origin and destination (i.e. the `lat` and `lon`) to `flights`.
</div>

<div class="answer">

You can perform one join after another. If duplicate variables are found, by default, dplyr will distinguish the two by adding `.x`, and `.y` to the ends of the variable names to solve naming conflicts.

```r
airport_locations <- airports %>%
  select(faa, lat, lon)

flights %>%
  select(year:day, hour, origin, dest) %>%
  left_join(
    airport_locations,
    by = c("origin" = "faa")
  ) %>%
  left_join(
    airport_locations,
    by = c("dest" = "faa")
  )
#> # A tibble: 336,776 x 10
#>    year month   day  hour origin dest  lat.x lon.x lat.y lon.y
#>   <int> <int> <int> <dbl> <chr>  <chr> <dbl> <dbl> <dbl> <dbl>
#> 1  2013     1     1     5 EWR    IAH    40.7 -74.2  30.0 -95.3
#> 2  2013     1     1     5 LGA    IAH    40.8 -73.9  30.0 -95.3
#> 3  2013     1     1     5 JFK    MIA    40.6 -73.8  25.8 -80.3
#> 4  2013     1     1     5 JFK    BQN    40.6 -73.8  NA    NA  
#> 5  2013     1     1     6 LGA    ATL    40.8 -73.9  33.6 -84.4
#> 6  2013     1     1     5 EWR    ORD    40.7 -74.2  42.0 -87.9
#> # … with 336,770 more rows
```
The `suffix` argument overrides this default behavior.
Since is always good practice to have clear variable names, I will use the 
suffixes `"_dest"` and `"_origin`" to specify whether the column refers to 
the destination or origin airport.

```r
airport_locations <- airports %>%
  select(faa, lat, lon)

flights %>%
  select(year:day, hour, origin, dest) %>%
  left_join(
    airport_locations,
    by = c("origin" = "faa")
  ) %>%
  left_join(
    airport_locations,
    by = c("dest" = "faa"),
    suffix = c("_origin", "_dest")
    # existing lat and lon variables in tibble gain the _origin suffix
    # new lat and lon variables are given _dest suffix
  )
#> # A tibble: 336,776 x 10
#>    year month   day  hour origin dest  lat_origin lon_origin lat_dest lon_dest
#>   <int> <int> <int> <dbl> <chr>  <chr>      <dbl>      <dbl>    <dbl>    <dbl>
#> 1  2013     1     1     5 EWR    IAH         40.7      -74.2     30.0    -95.3
#> 2  2013     1     1     5 LGA    IAH         40.8      -73.9     30.0    -95.3
#> 3  2013     1     1     5 JFK    MIA         40.6      -73.8     25.8    -80.3
#> 4  2013     1     1     5 JFK    BQN         40.6      -73.8     NA       NA  
#> 5  2013     1     1     6 LGA    ATL         40.8      -73.9     33.6    -84.4
#> 6  2013     1     1     5 EWR    ORD         40.7      -74.2     42.0    -87.9
#> # … with 336,770 more rows
```

</div>

### Exercise 13.4.3 {.unnumbered .exercise data-number="13.4.3"}

<div class="question">

Is there a relationship between the age of a plane and its delays?

</div>

<div class="answer">

The question does not specify whether the relationship is with departure delay
or arrival delay. 
I will look at both.

To compare the age of the plane to flights delay, I merge `flights` with the `planes`, which contains a variable `plane_year`, with the year in which the plane was built.
To look at the relationship between plane age and departure delay, I will calculate the average arrival and departure delay for each age of a flight.
Since there are few planes older than 25 years, so I truncate `age` at 25 years.


```r
plane_cohorts <- inner_join(flights,
  select(planes, tailnum, plane_year = year),
  by = "tailnum"
) %>%
  mutate(age = year - plane_year) %>%
  filter(!is.na(age)) %>%
  mutate(age = if_else(age > 25, 25L, age)) %>%
  group_by(age) %>%
  summarise(
    dep_delay_mean = mean(dep_delay, na.rm = TRUE),
    dep_delay_sd = sd(dep_delay, na.rm = TRUE),
    arr_delay_mean = mean(arr_delay, na.rm = TRUE),
    arr_delay_sd = sd(arr_delay, na.rm = TRUE),
    n_arr_delay = sum(!is.na(arr_delay)),
    n_dep_delay = sum(!is.na(dep_delay))
  )
#> `summarise()` ungrouping output (override with `.groups` argument)
```

I will look for a relationship between departure delay and age by plotting age against the average departure delay. 
The average departure delay is increasing for planes with ages up until 10 years. After that the departure delay decreases or levels off. 
The decrease in departure delay could be because older planes with many mechanical issues are removed from service or because air lines schedule these planes with enough time so that mechanical issues do not delay them.


```r
ggplot(plane_cohorts, aes(x = age, y = dep_delay_mean)) +
  geom_point() +
  scale_x_continuous("Age of plane (years)", breaks = seq(0, 30, by = 10)) +
  scale_y_continuous("Mean Departure Delay (minutes)")
```

<img src="relational-data_files/figure-html/unnamed-chunk-26-1.png" width="70%" style="display: block; margin: auto;" />

There is a similar relationship in arrival delays. 
Delays increase with the age of the plane until ten years, then it declines and flattens out.

```r
ggplot(plane_cohorts, aes(x = age, y = arr_delay_mean)) +
  geom_point() +
  scale_x_continuous("Age of Plane (years)", breaks = seq(0, 30, by = 10)) +
  scale_y_continuous("Mean Arrival Delay (minutes)")
```

<img src="relational-data_files/figure-html/unnamed-chunk-27-1.png" width="70%" style="display: block; margin: auto;" />

</div>

### Exercise 13.4.4 {.unnumbered .exercise data-number="13.4.4"}

<div class="question">

What weather conditions make it more likely to see a delay?

</div>

<div class="answer">

Almost any amount of precipitation is associated with a delay.
However, there is not a strong a trend above 0.02 in. of precipitation.

```r
flight_weather <-
  flights %>%
  inner_join(weather, by = c(
    "origin" = "origin",
    "year" = "year",
    "month" = "month",
    "day" = "day",
    "hour" = "hour"
  ))
```

```r
flight_weather %>%
  group_by(precip) %>%
  summarise(delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = precip, y = delay)) +
  geom_line() + geom_point()
#> `summarise()` ungrouping output (override with `.groups` argument)
```

<img src="relational-data_files/figure-html/unnamed-chunk-29-1.png" width="70%" style="display: block; margin: auto;" />

There seems to be a stronger relationship between visibility and delay.
Delays are higher when visibility is less than 2 miles.

```r
flight_weather %>%
  ungroup() %>%
  mutate(visib_cat = cut_interval(visib, n = 10)) %>%
  group_by(visib_cat) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ggplot(aes(x = visib_cat, y = dep_delay)) +
  geom_point()
#> `summarise()` ungrouping output (override with `.groups` argument)
```

<img src="relational-data_files/figure-html/unnamed-chunk-30-1.png" width="70%" style="display: block; margin: auto;" />

</div>

### Exercise 13.4.5 {.unnumbered .exercise data-number="13.4.5"}

<div class="question">

What happened on June 13, 2013? 
Display the spatial pattern of delays, and then use Google to cross-reference with the weather.

</div>

<div class="answer">

There was a large series of storms (derechos) in the southeastern US (see [June 12-13, 2013 derecho series](https://en.wikipedia.org/wiki/June_12%E2%80%9313,_2013_derecho_series)).
The following plot show that the largest delays were in Tennessee (Nashville), the Southeast, and the Midwest, which were the locations of the derechos.


```r
flights %>%
  filter(year == 2013, month == 6, day == 13) %>%
  group_by(dest) %>%
  summarise(delay = mean(arr_delay, na.rm = TRUE)) %>%
  inner_join(airports, by = c("dest" = "faa")) %>%
  ggplot(aes(y = lat, x = lon, size = delay, colour = delay)) +
  borders("state") +
  geom_point() +
  coord_quickmap() +
  scale_colour_viridis()
#> `summarise()` ungrouping output (override with `.groups` argument)
#> Warning: Removed 3 rows containing missing values (geom_point).
```

<img src="relational-data_files/figure-html/unnamed-chunk-31-1.png" width="70%" style="display: block; margin: auto;" />

</div>

## Filtering joins {#filtering-joins .r4ds-section}

### Exercise 13.5.1 {.unnumbered .exercise data-number="13.5.1"}

<div class="question">

What does it mean for a flight to have a missing `tailnum`? 
What do the tail numbers that don’t have a matching record in planes have in common? 
(Hint: one variable explains ~90% of the problems.)

</div>

<div class="answer">

Flights that have a missing `tailnum` all have missing values of `arr_time`, meaning that the flight was canceled.


```r
flights %>%
  filter(is.na(tailnum), !is.na(arr_time)) %>%
  nrow()
#> [1] 0
```

Many of the tail numbers that don't have a matching value in `planes` are 
registered to American Airlines (AA) or Envoy Airlines (MQ).
The documentation for `planes` states

> American Airways (AA) and Envoy Air (MQ) report fleet numbers rather than tail numbers so can't be matched.


```r
flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(carrier, sort = TRUE) %>%
  mutate(p = n / sum(n))
#> # A tibble: 10 x 3
#>   carrier     n      p
#>   <chr>   <int>  <dbl>
#> 1 MQ      25397 0.483 
#> 2 AA      22558 0.429 
#> 3 UA       1693 0.0322
#> 4 9E       1044 0.0198
#> 5 B6        830 0.0158
#> 6 US        699 0.0133
#> # … with 4 more rows
```

However, not all tail numbers appearing in`flights` from these carriers are missing from the `planes` table. I don't know how to reconcile this discrepancy.


```r
flights %>%
  distinct(carrier, tailnum) %>%
  left_join(planes, by = "tailnum") %>%
  group_by(carrier) %>%
  summarise(total_planes = n(),
            not_in_planes = sum(is.na(model))) %>%
  mutate(missing_pct = not_in_planes / total_planes) %>%
  arrange(desc(missing_pct))
#> `summarise()` ungrouping output (override with `.groups` argument)
#> # A tibble: 16 x 4
#>   carrier total_planes not_in_planes missing_pct
#>   <chr>          <int>         <int>       <dbl>
#> 1 MQ               238           234      0.983 
#> 2 AA               601           430      0.715 
#> 3 F9                26             3      0.115 
#> 4 FL               129            12      0.0930
#> 5 UA               621            23      0.0370
#> 6 US               290             9      0.0310
#> # … with 10 more rows
```

</div>

### Exercise 13.5.2 {.unnumbered .exercise data-number="13.5.2"}

<div class="question">

Filter flights to only show flights with planes that have flown at least 100 flights.

</div>

<div class="answer">

First, I find all planes that have flown at least 100 flights.
I need to filter flights that are missing a tail number otherwise all flights missing a tail number will be treated as a single plane.

```r
planes_gte100 <- flights %>%
  filter(!is.na(tailnum)) %>%
  group_by(tailnum) %>%
  count() %>%
  filter(n >= 100)
```

Now, I will semi join the data frame of planes that have flown at least 100 flights to the data frame of flights to select the flights by those planes.

```r
flights %>%
  semi_join(planes_gte100, by = "tailnum")
#> # A tibble: 228,390 x 19
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      517            515         2      830            819
#> 2  2013     1     1      533            529         4      850            830
#> 3  2013     1     1      544            545        -1     1004           1022
#> 4  2013     1     1      554            558        -4      740            728
#> 5  2013     1     1      555            600        -5      913            854
#> 6  2013     1     1      557            600        -3      709            723
#> # … with 228,384 more rows, and 11 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>
```

This can also be answered with a grouped mutate.

```r
flights %>%
  filter(!is.na(tailnum)) %>%
  group_by(tailnum) %>%
  mutate(n = n()) %>%
  filter(n >= 100)
#> # A tibble: 228,390 x 20
#> # Groups:   tailnum [1,217]
#>    year month   day dep_time sched_dep_time dep_delay arr_time sched_arr_time
#>   <int> <int> <int>    <int>          <int>     <dbl>    <int>          <int>
#> 1  2013     1     1      517            515         2      830            819
#> 2  2013     1     1      533            529         4      850            830
#> 3  2013     1     1      544            545        -1     1004           1022
#> 4  2013     1     1      554            558        -4      740            728
#> 5  2013     1     1      555            600        -5      913            854
#> 6  2013     1     1      557            600        -3      709            723
#> # … with 228,384 more rows, and 12 more variables: arr_delay <dbl>,
#> #   carrier <chr>, flight <int>, tailnum <chr>, origin <chr>, dest <chr>,
#> #   air_time <dbl>, distance <dbl>, hour <dbl>, minute <dbl>, time_hour <dttm>,
#> #   n <int>
```

</div>

### Exercise 13.5.3 {.unnumbered .exercise data-number="13.5.3"}

<div class="question">

Combine `fueleconomy::vehicles` and `fueleconomy::common` to find only the records for the most common models.

</div>

<div class="answer">


```r
fueleconomy::vehicles %>%
  semi_join(fueleconomy::common, by = c("make", "model"))
#> # A tibble: 14,531 x 12
#>      id make  model   year class   trans   drive     cyl displ fuel    hwy   cty
#>   <dbl> <chr> <chr>  <dbl> <chr>   <chr>   <chr>   <dbl> <dbl> <chr> <dbl> <dbl>
#> 1  1833 Acura Integ…  1986 Subcom… Automa… Front-…     4   1.6 Regu…    28    22
#> 2  1834 Acura Integ…  1986 Subcom… Manual… Front-…     4   1.6 Regu…    28    23
#> 3  3037 Acura Integ…  1987 Subcom… Automa… Front-…     4   1.6 Regu…    28    22
#> 4  3038 Acura Integ…  1987 Subcom… Manual… Front-…     4   1.6 Regu…    28    23
#> 5  4183 Acura Integ…  1988 Subcom… Automa… Front-…     4   1.6 Regu…    27    22
#> 6  4184 Acura Integ…  1988 Subcom… Manual… Front-…     4   1.6 Regu…    28    23
#> # … with 14,525 more rows
```

Why does the above code join on `make` and `model` and not just `model`?
It is possible for two car brands (`make`) to produce a car with the same name (`model`).
In both the `vehicles` and `common` data we can find some examples.
For example, "Truck 4WD" is produced by many different brands.

```r
fueleconomy::vehicles %>%
  distinct(model, make) %>%
  group_by(model) %>%
  filter(n() > 1) %>%
  arrange(model)
#> # A tibble: 126 x 2
#> # Groups:   model [60]
#>   make                   model              
#>   <chr>                  <chr>              
#> 1 Audi                   200                
#> 2 Chrysler               200                
#> 3 Mcevoy Motors          240 DL/240 GL Wagon
#> 4 Volvo                  240 DL/240 GL Wagon
#> 5 Lambda Control Systems 300E               
#> 6 Mercedes-Benz          300E               
#> # … with 120 more rows
```

```r
fueleconomy::common %>%
  distinct(model, make) %>%
  group_by(model) %>%
  filter(n() > 1) %>%
  arrange(model)
#> # A tibble: 8 x 2
#> # Groups:   model [3]
#>   make       model    
#>   <chr>      <chr>    
#> 1 Dodge      Colt     
#> 2 Plymouth   Colt     
#> 3 Mitsubishi Truck 2WD
#> 4 Nissan     Truck 2WD
#> 5 Toyota     Truck 2WD
#> 6 Mitsubishi Truck 4WD
#> # … with 2 more rows
```
If we were to merge these data on the `model` column alone, there would be incorrect matches.

</div>

### Exercise 13.5.4 {.unnumbered .exercise data-number="13.5.4"}

<div class="question">

Find the 48 hours (over the course of the whole year) that have the worst delays.
Cross-reference it with the weather data. 
Can you see any patterns?

</div>

<div class="answer">

I will start by clarifying how I will be measuring the concepts in the question.
There are three concepts that need to be defined more precisely.

1.  What is meant by "delay"? 
    I will use departure delay.
    Since the `weather` data only contains data for the New York City airports, and
    departure delays will be more sensitive to New York City weather conditions than arrival delays.

1.  What is meant by "worst"? I define  worst delay as the average departure delay per flight for flights *scheduled* to depart in that hour.
    For hour, I will use the scheduled departure time rather than the actual departure time.
    If planes are delayed due to weather conditions, the weather conditions during the scheduled time are more important than the actual departure time, at which point, the weather could have improved.

1.  What is meant by "48 hours over the course of the year"? This could mean two days, a span of 48 contiguous hours,
    or 48 hours that are not necessarily contiguous hours. 
    I will find 48 not-necessarily contiguous hours.
    That definition makes better use of the methods introduced in this section and chapter.

1.  What is the unit of analysis? Although the question mentions only hours, I will use airport hours.
    The weather dataset has an observation for each airport for each hour.
    Since all the departure airports are in the vicinity of New York City, their weather should be similar, it will not be the same.

First, I need to find the 48 hours with the worst delays. 
I group flights by hour of scheduled departure time and calculate the average delay.
Then I select the 48 observations (hours) with the highest average delay.


```r
worst_hours <- flights %>%
  mutate(hour = sched_dep_time %/% 100) %>%
  group_by(origin, year, month, day, hour) %>%
  summarise(dep_delay = mean(dep_delay, na.rm = TRUE)) %>%
  ungroup() %>%
  arrange(desc(dep_delay)) %>%
  slice(1:48)
#> `summarise()` regrouping output by 'origin', 'year', 'month', 'day' (override with `.groups` argument)
```

Then I can use `semi_join()` to get the weather for these hours.

```r
weather_most_delayed <- semi_join(weather, worst_hours, 
                                  by = c("origin", "year",
                                         "month", "day", "hour"))
```

For weather, I'll focus on precipitation, wind speed, and temperature. 
I will display these in both a table and a plot.  
Many of these observations have a higher than average wind speed (10 mph) or some precipitation. 
However, I would have expected the weather for the hours with the worst delays to be much worse.


```r
select(weather_most_delayed, temp, wind_speed, precip) %>%
  print(n = 48)
#> # A tibble: 48 x 3
#>     temp wind_speed precip
#>    <dbl>      <dbl>  <dbl>
#>  1  27.0      13.8    0   
#>  2  28.0      19.6    0   
#>  3  28.9      28.8    0   
#>  4  33.8       9.21   0.06
#>  5  34.0       8.06   0.05
#>  6  80.1       8.06   0   
#>  7  86        13.8    0   
#>  8  73.4       6.90   0.08
#>  9  84.0       5.75   0   
#> 10  78.8      18.4    0.23
#> 11  53.6       0      0   
#> 12  60.8      31.1    0.11
#> 13  55.4      17.3    0.14
#> 14  53.1       9.21   0.01
#> 15  55.9      11.5    0.1 
#> 16  55.4       8.06   0.15
#> 17  57.0      29.9    0   
#> 18  33.8      20.7    0.02
#> 19  34.0      19.6    0.01
#> 20  36.0      21.9    0.01
#> 21  37.9      16.1    0   
#> 22  32        13.8    0.12
#> 23  60.1      33.4    0.14
#> 24  60.8      11.5    0.02
#> 25  62.1      17.3    0   
#> 26  66.9      10.4    0   
#> 27  66.9      13.8    0   
#> 28  79.0      10.4    0   
#> 29  77        16.1    0.07
#> 30  75.9      13.8    0   
#> 31  82.4       8.06   0   
#> 32  86         9.21   0   
#> 33  80.1       9.21   0   
#> 34  80.6      11.5    0   
#> 35  78.1       6.90   0   
#> 36  75.2      10.4    0.01
#> 37  73.9       5.75   0.03
#> 38  73.9       8.06   0   
#> 39  75.0       4.60   0   
#> 40  75.0       4.60   0.01
#> 41  80.1       0      0.01
#> 42  80.1       0      0   
#> 43  77        10.4    0   
#> 44  82.0      10.4    0   
#> 45  72.0      13.8    0.3 
#> 46  72.0       4.60   0.03
#> 47  51.1       4.60   0   
#> 48  54.0       6.90   0
```


```r
ggplot(weather_most_delayed, aes(x = precip, y = wind_speed, color = temp)) +
  geom_point()
```

<img src="relational-data_files/figure-html/unnamed-chunk-44-1.png" width="70%" style="display: block; margin: auto;" />

It's hard to say much more than that without using the tools from [Exploratory Data Analysis](https://r4ds.had.co.nz/exploratory-data-analysis.html#covariation) section
to look for covariation between weather and flight delays using all flights.
Implicitly in my informal analysis of trends in weather using only the 48 hours with the worst delays, I was comparing the weather in these hours to some belief I had about what constitutes "normal" or "good" weather.
It would be better to actually use data to make that comparison.

</div>

### Exercise 13.5.5 {.unnumbered .exercise data-number="13.5.5"}

<div class="question">

What does `anti_join(flights, airports, by = c("dest" = "faa"))` tell you? 
What does `anti_join(airports, flights, by = c("faa" = "dest"))` tell you?

</div>

<div class="answer">

The expression `anti_join(flights, airports, by = c("dest" = "faa"))` returns the flights that went to an airport that is not in the FAA list of destinations. 
Since the FAA list only contains domestic airports, these are likely foreign flights. 
However, running that expression that there are only four airports in this list.


```r
anti_join(flights, airports, by = c("dest" = "faa")) %>% 
  distinct(dest)
#> # A tibble: 4 x 1
#>   dest 
#>   <chr>
#> 1 BQN  
#> 2 SJU  
#> 3 STT  
#> 4 PSE
```

In this set of four airports three are in Puerto Rico ([BQN](https://en.wikipedia.org/wiki/Rafael_Hern%C3%A1ndez_Airport), [SJU](https://en.wikipedia.org/wiki/Luis_Mu%C3%B1oz_Mar%C3%ADn_International_Airport), and [PSE](https://en.wikipedia.org/wiki/Mercedita_International_Airport)) and one is in the US Virgin Islands ( [STT](https://en.wikipedia.org/wiki/Cyril_E._King_Airport)).

The reason for this discrepancy is that the `flights` and `airports` tables are derived from different sources.
The `flights` data comes from the US Department of Transportation [Bureau of Transportation Statistics](https://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236), while the airport metadata comes from [openflights.org](https://openflights.org/data.html).
The BTS includes Puerto Rico and U.S. Virgin Islands as "domestic" (part of the US), while the [openflights.org](https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat) give use different values of country for airports in the US states (`"United States"`)  Puerto Rico (`"Puerto Rico"`) and US Virgin Islands (`"Virgin Islands"`).

The expression `anti_join(airports, flights, by = c("faa" = "dest"))` returns the US airports that were not the destination of any flight in the data.
Since the data contains all flights from New York City airports, this is also the list of US airports that did not have a nonstop flight from New York City in 2013.


```r
anti_join(airports, flights, by = c("faa" = "dest"))
#> # A tibble: 1,357 x 8
#>   faa   name                          lat   lon   alt    tz dst   tzone         
#>   <chr> <chr>                       <dbl> <dbl> <dbl> <dbl> <chr> <chr>         
#> 1 04G   Lansdowne Airport            41.1 -80.6  1044    -5 A     America/New_Y…
#> 2 06A   Moton Field Municipal Airp…  32.5 -85.7   264    -6 A     America/Chica…
#> 3 06C   Schaumburg Regional          42.0 -88.1   801    -6 A     America/Chica…
#> 4 06N   Randall Airport              41.4 -74.4   523    -5 A     America/New_Y…
#> 5 09J   Jekyll Island Airport        31.1 -81.4    11    -5 A     America/New_Y…
#> 6 0A9   Elizabethton Municipal Air…  36.4 -82.2  1593    -5 A     America/New_Y…
#> # … with 1,351 more rows
```

</div>

### Exercise 13.5.6 {.unnumbered .exercise data-number="13.5.6"}

<div class="question">

You might expect that there’s an implicit relationship between plane and airline, because each plane is flown by a single airline. 
Confirm or reject this hypothesis using the tools you’ve learned above.

</div>

<div class="answer">

At each point in time, each plane is flown by a single airline.
However, a plane can be sold and fly for multiple airlines.
Logically, it is possible that a plane can fly for multiple airlines over the course of its lifetime.
But, it is not necessarily the case that a plane will fly for more than one airline in this  data, especially since it comprises only a year of data.
So let's check to see if there are any planes in the data flew for multiple airlines.

First, find all distinct airline, plane combinations.

```r
planes_carriers <-
  flights %>%
  filter(!is.na(tailnum)) %>%
  distinct(tailnum, carrier)
```

The number of planes that have flown for more than one airline are those `tailnum` that appear more than once in the `planes_carriers` data.

```r
planes_carriers %>%
  count(tailnum) %>%
  filter(n > 1) %>%
  nrow()
#> [1] 17
```

The names of airlines are easier to understand than the two-letter carrier codes.
The `airlines` data frame contains the names of the airlines.


```r
carrier_transfer_tbl <- planes_carriers %>%
  # keep only planes which have flown for more than one airline
  group_by(tailnum) %>%
  filter(n() > 1) %>%
  # join with airlines to get airline names
  left_join(airlines, by = "carrier") %>%
  arrange(tailnum, carrier)

carrier_transfer_tbl
#> # A tibble: 34 x 3
#> # Groups:   tailnum [17]
#>   carrier tailnum name                    
#>   <chr>   <chr>   <chr>                   
#> 1 9E      N146PQ  Endeavor Air Inc.       
#> 2 EV      N146PQ  ExpressJet Airlines Inc.
#> 3 9E      N153PQ  Endeavor Air Inc.       
#> 4 EV      N153PQ  ExpressJet Airlines Inc.
#> 5 9E      N176PQ  Endeavor Air Inc.       
#> 6 EV      N176PQ  ExpressJet Airlines Inc.
#> # … with 28 more rows
```

</div>

## Join problems {#join-problems .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->

## Set operations {#set-operations .r4ds-section}

<!--html_preserve--><div class="alert alert-warning hints-alert">
<div class="hints-icon">
<i class="fa fa-exclamation-circle"></i>
</div>
<div class="hints-container">No exercises</div>
</div><!--/html_preserve-->
