# Exercise Solutions to R for Data Science


This repository contains the code and text behind the [Solutions for R for Data Science](https://jrnold.github.io/r4ds-exercise-solutions/), which, as its name suggests, has solutions to the the exercises in [R for Data Science](http://r4ds.had.co.nz/) by Garrett Grolemund and Hadley Wickham.

The R packages used in this book can be installed via
```r
devtools::install_github("jrnold/r4ds-exercise-solutions")
```

# Build

The site is built using the [bookdown](https://bookdown.org/yihui/bookdown/) package.
pandoc

For development and testing, this project uses several scripts and Node packages installed.

To check spelling
```console
$ Rscript ./bin/check-spelling.R
```

To lint R code (broken for most pages with the latest version of the **lintr** package) run
```
$ Rscript ./bin/lint.R
```

To update contributors run
```
$ Rscript ./bin/update-contribs.sh
```

To check the markdown for style and issues (using `remark`) run
```
$ npm test
```

To check for broken links. Serve the site locally and then run
```
$ ./node_modules/.bin/blc -ro http://127.0.0.1:1234
```

To check the generated HTML files for any problems run
```
$ ./node_modules/.bin/htmlhint docs/**/*.html
```
