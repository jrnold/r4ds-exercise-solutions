[![Lifecycle: superseded](https://img.shields.io/badge/lifecycle-superseded-blue.svg)](https://lifecycle.r-lib.org/articles/stages.html#superseded)

# Exercise Solutions to R for Data Science (1st edition)

**Read the solutions at <https://jrnold.github.io/r4ds-exercise-solutions/>**

> [!WARNING]
> **This repository is archived and no longer maintained.**
>
> These are solutions to the **1st edition** of *R for Data Science*. A
> [2nd edition](https://r4ds.hadley.nz/) has since been published, with its own
> [solutions to the exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/)
> — go there instead.
>
> This repository is read-only: issues and pull requests are closed, including
> for typos. The [site](https://jrnold.github.io/r4ds-exercise-solutions/) is
> kept online for reference, and can still be rebuilt — see [Build](#build).

This repository contains the code and text behind the [Solutions for R for Data Science](https://jrnold.github.io/r4ds-exercise-solutions/), which, as its name suggests, has solutions to the exercises in [R for Data Science](https://r4ds.had.co.nz/) by Garrett Grolemund and Hadley Wickham.

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
