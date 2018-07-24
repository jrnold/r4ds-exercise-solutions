[![Build Status](https://travis-ci.org/jrnold/r4ds-exercise-solutions.svg?branch=master)](https://travis-ci.org/jrnold/r4ds-exercise-solutions)

# Exercise Solutions to R for Data Science

This repository contains the code and text behind the [Solutions for R for Data Science](https://jrnold.github.io/r4ds-exercise-solutions/), which, as its name suggests, has solutions to the the exercises in [R for Data Science](http://r4ds.had.co.nz/) by Garrett Grolemund and Hadley Wickham.

The R packages used in this book can be installed via
```r
devtools::install_github("jrnold/r4ds-exercise-solutions")
```

## Build

The site is built using the [bookdown](https://bookdown.org/yihui/bookdown/) package.
pandoc

For development and testing, this project uses several scripts and Node packages installed.

To install necessary Node packages,
```console
$ npm install
```

To check spelling
```console
$ Rscript ./bin/check-spelling.R
```

To lint R code (broken for most pages with the latest version of the **lintr** package) run
```console
$ Rscript ./bin/check-r.R
```

To check the markdown for style and issues (using `remark`) run
```console
$ ./bin/check-markdown.sh
```

To check for broken links. Serve the site locally and then run
```console
$ ./bin/check-links.sh $URL
```

To check the generated HTML files for any problems run
```console
$ ./bin/check-html.sh
```

To render both PDF and HTML versions of the book,
```console
$ ./bin/render.R
```

To locally serve the book
```console
$ ./bin/serve.R
```
