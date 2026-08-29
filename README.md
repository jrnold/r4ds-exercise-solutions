[![Lifecycle: superseded](https://img.shields.io/badge/lifecycle-superseded-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#superseded)

# Exercise Solutions to R for Data Science

These are solutions to the **1st edition** of R for Data Science. The solutions to the 2nd edition of [R for Data Science](https://r4ds.hadley.nz/) are available at [R for Data Science (2e) - Solutions to Exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/).

This repository contains the code and text behind the [Solutions for R for Data Science](https://jrnold.github.io/r4ds-exercise-solutions/), which, as its name suggests, has solutions to the the exercises in [R for Data Science](https://r4ds.had.co.nz/) by Garrett Grolemund and Hadley Wickham.

> **This repository is archived and no longer maintained.** It is kept online
> for reference. See [Build](#build) if you want to reproduce the site.

## Contributing

This repository is archived and read-only. Issues and pull requests are closed,
including for typos, so nothing here can be merged. Please direct your
contributions to [R for Data Science (2e) - Solutions to Exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/)
instead.

## Build

The site is built with [bookdown](https://bookdown.org/yihui/bookdown/) and pandoc.

Because this book targets the 1st edition, it is built in a **pinned,
period-correct environment**: R 4.0.3 against the Posit CRAN snapshot of
2021-01-31, with pandoc 2.11.4. Several of its dependencies — `lvplot`,
`nasaweather`, `fueleconomy` and `ggstance` — have since been removed from
CRAN, so a build against current CRAN cannot succeed. `Dockerfile` defines that
environment and `renv.lock` records exactly what it resolves to.

```sh
docker build -t r4ds-solutions:pinned .
./bin/docker-render.sh
```

Output lands in `_build/`.
