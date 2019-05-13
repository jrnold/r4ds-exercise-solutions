#!/bin/sh
# build website
# exit when any command fails
set -e
set +x

Rscript bin/render.R --force --quiet
Rscript bin/create-sitemap.R
Rscript bin/create-toc.R
# Rscript bin/add-r4ds-links.R
