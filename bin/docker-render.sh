#!/bin/sh
# Render the book inside the pinned container (see Dockerfile).
#
# index.Rmd still resolves its contributor list through the GitHub API at render
# time, so a token is forwarded from the host environment when one is available.
# It is only forwarded if it is a legacy 40-hex-digit PAT: gh 1.2.0 (the version
# in the 2021-01-31 snapshot) validates the token format and rejects the
# ghp_/gho_ tokens `gh auth token` returns today. Unauthenticated requests are
# sufficient for this repository's issue list. No token is written into this
# file.
#
# The repository is bind-mounted from the host, so its files are owned by the
# host uid while the container runs as root; git refuses to read such a tree
# ("dubious ownership") unless it is marked safe, and gh::gh_tree_remote() needs
# that read to resolve the repo spec.
set -e

PROJ=/home/rstudio/r4ds-exercise-solutions

set -- --rm --platform linux/amd64 \
  -v "$(pwd):${PROJ}" \
  -w "${PROJ}"

if printf '%s' "${GITHUB_PAT:-}" | grep -qE '^[0-9a-fA-F]{40}$'; then
  set -- "$@" -e "GITHUB_PAT=${GITHUB_PAT}"
fi

exec docker run "$@" \
  r4ds-solutions:pinned \
  sh -c "git config --global --add safe.directory ${PROJ} && Rscript -e 'bookdown::render_book(\"index.Rmd\", output_format = \"bookdown::gitbook\")'"
