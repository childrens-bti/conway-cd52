#!/bin/bash

set -e
set -o pipefail

cd "$(dirname "$0")"

# Run Conway CD52 KO analyses
Rscript -e "rmarkdown::render('01-cd52-analysis.Rmd')"
Rscript -e "rmarkdown::render('02-cd52-celltype-de.Rmd')"
