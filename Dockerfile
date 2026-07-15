FROM rocker/tidyverse:4.4.0
LABEL maintainer="Sam Chen (schen8@childrensnational.org)"

WORKDIR /home/rstudio/conway-cd52

# Use current CRAN for package installation.
RUN echo 'options(repos = c(CRAN = "https://cloud.r-project.org"))' >> /usr/local/lib/R/etc/Rprofile.site

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    pkg-config \
    gfortran \
    pandoc \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libcairo2-dev \
    libblas-dev \
    liblapack-dev \
    libglpk-dev \
    libgmp-dev \
    libnlopt-dev \
 && rm -rf /var/lib/apt/lists/*

RUN R -e 'options(Ncpus = max(1, parallel::detectCores() - 1)); \
          install.packages(c("BiocManager", "ggplot2", "rprojroot", "ggrastr")); \
          install.packages("patchwork"); \
          BiocManager::install(c("diffcyt", "EnhancedVolcano", "SummarizedExperiment"), ask = FALSE, update = FALSE); \
          required <- c("tidyverse", "rprojroot", "ggrastr", "patchwork", "diffcyt", "EnhancedVolcano", "SummarizedExperiment", "rmarkdown"); \
          stopifnot(all(vapply(required, requireNamespace, logical(1), quietly = TRUE)))'
