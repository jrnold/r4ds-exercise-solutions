
# R Markdown

## R Markdown Basics

Doesn't describe what YAML is.

- https://en.wikipedia.org/wiki/YAML
- The Ansible Guide to YAML is pretty simple; you don't need to know what Ansible is: http://docs.ansible.com/ansible/YAMLSyntax.html
- https://learnxinyminutes.com/docs/yaml/
- http://codebeautify.org/yaml-validator
- https://docs.saltstack.com/en/latest/topics/yaml/

### Exercise 

1. Create a new notebook using File > New File > R Notebook. Read the instructions. Practice running the chunks. Verify that you can modify the code, re-run it, and see modified output.

*Nothing to show*

2. Create a new R Markdown document with File > New File > R Markdown… Knit it by clicking the appropriate button. Knit it by using the appropriate keyboard short cut. Verify that you can modify the input and see the output update.

3. Compare and contrast the R notebook and R markdown files you created above. How are the outputs similar? How are they different? How are the inputs similar? How are they different? What happens if you copy the YAML header from one to the other?

R notebook files show the output inside the editor, while hiding the console. R markdown files shows the output inside the console, and does not show output inside the editor.
They differ in the value of `output` in their YAML headers. The YAML header for the R notebook is
```yaml
ouptut: html_notebook
```
while the header for the R markdown file is
```yaml
ouptut: html_document 
```

4. Create one new R Markdown document for each of the three built-in formats: HTML, PDF and Word. Knit each of the three documents. How does the output differ? How does the input differ? (You may need to install LaTeX in order to build the PDF output — RStudio will prompt you if this is necessary.)

They produce different outputs, both in the final documents and intermediate files (notably the type of plots produced). The only difference in the inputs is the value of `output` in the YAML header: `word_document` for Word documents, `pdf_document` for PDF documents, and `html_document` for HTML documents.

## Text formatting with R Markdown

**Continue**


