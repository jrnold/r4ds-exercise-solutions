# Period-correct build environment for the R4DS 1st-edition solutions.
#
# Pinned to R 4.0.3 and the Posit CRAN snapshot of 2021-01-31 -- the date of
# the `first-ed` tag in hadley/r4ds. The snapshot is the only remaining source
# for lvplot, nasaweather, fueleconomy and ggstance, all since removed from
# CRAN. See docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md
#
# amd64 is deliberate: rocker/r-ver:4.0.3 publishes no arm64 image, and PPM
# Linux binaries are amd64-only. Emulation beats compiling 130+ packages.
FROM --platform=linux/amd64 rocker/r-ver:4.0.3

ENV PROJ_DIR=/home/rstudio/r4ds-exercise-solutions
ENV PANDOC_VERSION=2.11.4
ENV CRAN=https://packagemanager.posit.co/cran/__linux__/focal/2021-01-31
ENV RENV_CONFIG_REPOS_OVERRIDE=${CRAN}
ENV DEBIAN_FRONTEND=noninteractive

# System libraries needed by the R dependency tree. libglpk-dev is required by
# igraph, which datamodelr pulls in; omitting it fails late and confusingly.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl git \
      libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev \
      libfontconfig1-dev libfreetype6-dev libpng-dev libjpeg-dev \
      libtiff5-dev libglpk-dev libgmp-dev \
    && rm -rf /var/lib/apt/lists/*

# Pandoc is not present in rocker/r-ver; pin it rather than taking apt's build.
RUN curl -sL -o /tmp/pandoc.deb \
      https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-1-amd64.deb \
    && dpkg -i /tmp/pandoc.deb \
    && rm /tmp/pandoc.deb

RUN echo "options(repos = c(CRAN = '${CRAN}'), Ncpus = parallel::detectCores())" \
      >> ${R_HOME}/etc/Rprofile.site

RUN install2.r --error --skipinstalled remotes renv

# Install book dependencies from DESCRIPTION in their own layer so that
# editing the book does not invalidate the (slow) package install.
WORKDIR /tmp/install
COPY DESCRIPTION .
RUN Rscript -e "remotes::install_deps(dependencies = TRUE, upgrade = 'never')"

WORKDIR ${PROJ_DIR}
