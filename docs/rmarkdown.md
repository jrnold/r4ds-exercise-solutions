
---
output: html_document
editor_options:
  chunk_output_type: console
---

# R Markdown

## R Markdown Basics

### Exercises

#### Exercise 1 {.exercise}



Create a new notebook using *File > New File > R Notebook*. Read the instructions. Practice running the chunks. Verify that you can modify the code, re-run it, and see modified output.





This exercise is left to the reader.



#### Exercise 2 {.exercise}


Create a new R Markdown document with *File > New File > R Markdown ...* Knit it by clicking the appropriate button. Knit it by using the appropriate keyboard short cut. Verify that you can modify the input and see the output update.




This exercise is mostly left to the reader.
Recall that the keyboard shortcut to knit a file is `Cmd/Ctrl + Alt + I`.



#### Exercise 3 {.exercise}


Compare and contrast the R notebook and R markdown files you created above. How are the outputs similar? How are they different? How are the inputs similar? How are they different? What happens if you copy the YAML header from one to the other?




R notebook files show the output inside the editor, while hiding the console. R markdown files shows the output inside the console, and does not show output inside the editor.
They differ in the value of `output` in their YAML headers.

The YAML header for the R notebook will have the line,
```
---
ouptut: html_notebook
---
```
For example, this is a R notebook,
```
---
title: "Diamond sizes"
date: 2016-08-25
output: html_notebook
---

Text of the document.
```

The YAML header for the R markdown file will have the line,
```
ouptut: html_document
```
For example, this is a R markdown file.
```
---
title: "Diamond sizes"
date: 2016-08-25
output: html_document
---

Text of the document.
```

Copying the YAML header from an R notebook to a R markdown file changes it to an R markdown file, and vice-versa.
More specifically, changing the value of `output` to
This is because the RStudio IDE when opening and the **rmarkdown** package when knitting uses the YAML header of a file, and in particular the
value of the `output` key in the YAML header, to determine what type of document it is.



#### Exercise 4 {.exercise}



Create one new R Markdown document for each of the three built-in formats:
HTML, PDF and Word. Knit each of the three documents. How does the output
differ? How does the input differ? (You may need to install LaTeX in order to
build the PDF output — RStudio will prompt you if this is necessary.)





They produce different outputs, both in the final documents and intermediate
files (notably the type of plots produced). The only difference in the inputs
is the value of `output` in the YAML header: `word_document` for Word
documents, `pdf_document` for PDF documents, and `html_document` for HTML
documents.



## Text formatting with R Markdown

### Exercise 1 {.exercise}


Practice what you’ve learned by creating a brief CV. The title should be your name, and you should include headings for (at least) education or employment. Each of the sections should include a bulleted list of jobs/degrees. Highlight the year in bold.




Exercise left to reader.



### Exercise 2 {.exercise}



Using the R Markdown quick reference, figure out how to:

1.  Add a footnote.
1.  Add a horizontal rule.
1.  Add a block quote.





```
The quick brown fox jumped over the lazy dog.[^quick-fox]

Use three or more `-` for a horizontal rule. For example,

---

The horizontal rule uses the same syntax as a YAML block? So how does R markdown
distinguish between the two?  Three dashes ("---") is only treated the start of
a YAML block if it is at the start of the document.

> This would be a block quote. Generally, block quotes are used to indicate
> quotes longer than a three or four lines.

[^quick-fox]: This is an example of a footnote. The sentence this is footnoting
  is often used for displaying fonts because it includes all 26 letters of the
  English alphabet.

```



### Exercise 3 {.exercise}


Copy and paste the contents of `diamond-sizes.Rmd` from <https://github.com/hadley/r4ds/tree/master/rmarkdown> in to a local R markdown document. Check that you can run it, then add text after the frequency polygon that describes its most striking features.




For an example R markdown document, see the exercises in the next section.



## Code Chunks

Exercises 1--3 are answered in this document.


```
#> ---
#> title: "Exercise 24.4.7.4"
#> author: "Jeffrey Arnold"
#> date: "2/1/2018"
#> output: html_document
#> ---
#> 
#> ```{r setup, include=FALSE}
#> knitr::opts_chunk$set(echo = TRUE, cache = TRUE)
#> ```
#> 
#> The chunk `a` has no dependencies.
#> ```{r a}
#> print(lubridate::now())
#> x <- 1
#> ```
#> 
#> The chunk `b` depends on `a`.
#> ```{r b, dependson = c("a")}
#> print(lubridate::now())
#> y <- x + 1
#> ```
#> 
#> The chunk `c` depends on `a`.
#> ```{r c, dependson = c("a")}
#> print(lubridate::now())
#> z <- x * 2
#> ```
#> 
#> The chunk `d` depends on `c` and `b`:
#> ```{r d, dependson = c("c", "b")}
#> print(lubridate::now())
#> w <- y + z
#> ```
#> 
#> If this document is knit repeatedly, the value  printed by `lubridate::now()` will be the same for all chunks,
#> and the same as the first time the document was run with caching.
```

### Exercise 1 {.exercise}


Add a section that explores how diamond sizes vary by cut, color, and clarity. Assume you’re writing a report for someone who doesn’t know R, and instead of setting `echo = FALSE` on each chunk, set a global option.


### Exercise 2 {.exercise}


Download `diamond-sizes.Rmd` from <https://github.com/hadley/r4ds/tree/master/rmarkdown>. Add a section that describes the largest 20 diamonds, including a table that displays their most important attributes.




For the this, I use `arrange()` and `slice()` to select the largest twenty diamonds, and `knitr::kable()` to produce a formatted table.



### Exercise 3 {.exercise}


Modify `diamonds-sizes.Rmd` to use comma() to produce nicely formatted output. Also include the percentage of diamonds that are larger than 2.5 carats.




I moved the computation of the number larger and percent of diamonds larger than 2.5 carats into a code chunk.
I find that it is best to keep inline R expressions simple, usually consisting of an object and a formatting function.
This makes it both easier to read and test the R code, while simultaneously making the prose easier to read.
It helps the readability of the code and document to keep the computation of objects used in prose close to their use.
Calculating those objects in a code chunk with the `include = FALSE` option (as is done in `diamonds-size.Rmd`) is useful in this regard.



### Exercise 4 {.exercise}



Set up a network of chunks where `d` depends on `c` and `b`, and both `b` and `c` depend on `a`. Have each chunk print lubridate::now(), set cache = TRUE, then verify your understanding of caching.






```r
cat(readr::read_file("rmarkdown/caching.Rmd"))
#> ---
#> title: "Exercise 24.4.7.4"
#> author: "Jeffrey Arnold"
#> date: "2/1/2018"
#> output: html_document
#> ---
#> 
#> ```{r setup, include=FALSE}
#> knitr::opts_chunk$set(echo = TRUE, cache = TRUE)
#> ```
#> 
#> The chunk `a` has no dependencies.
#> ```{r a}
#> print(lubridate::now())
#> x <- 1
#> ```
#> 
#> The chunk `b` depends on `a`.
#> ```{r b, dependson = c("a")}
#> print(lubridate::now())
#> y <- x + 1
#> ```
#> 
#> The chunk `c` depends on `a`.
#> ```{r c, dependson = c("a")}
#> print(lubridate::now())
#> z <- x * 2
#> ```
#> 
#> The chunk `d` depends on `c` and `b`:
#> ```{r d, dependson = c("c", "b")}
#> print(lubridate::now())
#> w <- y + z
#> ```
#> 
#> If this document is knit repeatedly, the value  printed by `lubridate::now()` will be the same for all chunks,
#> and the same as the first time the document was run with caching.
```



