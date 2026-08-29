# Deprecating the R4DS 1st-Edition Solutions — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebuild this book reproducibly at period-correct 1st-edition package versions, strip Google Analytics and hypothes.is from the live site, label every page as superseded, redeploy, and archive the repository.

**Architecture:** A pinned Docker image (`rocker/r-ver:4.0.3` + Posit CRAN snapshot `2021-01-31`) is the single build environment; CI runs the book *inside that same image* so local and CI cannot drift. Content changes are source-level edits to `.Rmd`/YAML. Deployment stays `bookdown` → `gh-pages`. Archival is a GitHub repo setting applied last, because it makes the repo read-only.

**Tech Stack:** R 4.0.3, bookdown 0.21, renv, Docker (linux/amd64), pandoc 2.11.4, GitHub Actions, GitHub Pages.

**Spec:** `docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md`

**Branch:** `deprecate-1e`

## Global Constraints

- R version: **4.0.3**. CRAN snapshot: **https://packagemanager.posit.co/cran/__linux__/focal/2021-01-31**.
- Docker platform: **linux/amd64**. `rocker/r-ver:4.0.3` publishes no arm64 image, and PPM Linux binaries are amd64-only, so emulation is the intended path — it is faster than compiling 130+ packages natively.
- Base image distro is **focal**; the snapshot URL must say `focal` or binaries silently degrade to source builds.
- `datamodelr` pins to `bergant/datamodelr@dbc3111bd77cd4e26d13849001e6555216dfdab4`.
- `hypothesisr` is **removed**, not pinned. No `.Rmd` references it.
- Copy rule: the notice uses the word **superseded**, never "deprecated" or "obsolete", and links **both** https://r4ds.hadley.nz/ and https://mine-cetinkaya-rundel.github.io/r4ds-solutions/.
- Solutions are **not** rewritten for the 2nd edition. Chunk edits are permitted **only** where a chunk errors under the pinned environment; see Task 2.
- No task pushes to `gh-pages` except Task 7. No task archives the repo except Task 8.

## File Structure

| File | Responsibility | Task |
|---|---|---|
| `Dockerfile` | Pinned build environment. Rewritten. | 1 |
| `docker-compose.yml` | Local dev service. Dead `nodejs` service removed. | 1 |
| `DESCRIPTION` | Dependency list. `hypothesisr` dropped, `datamodelr` pinned by SHA. | 1 |
| `renv.lock` | Audit record of what the image resolved to. Not activated. | 1 |
| `docs/build-notes.md` | Records chunks rewritten to render, and why. | 2 |
| `_common.R` | Adds `deprecation_banner()` beside `no_exercises()`. | 3 |
| 27 chapter `.Rmd` files | Inline banner call after the chapter heading. | 3 |
| `index.Rmd` | Welcome-page notice; frozen contributor lists. | 3, 4 |
| `_output.yaml` | Drops `includes:` block and `edit:` block. | 4, 5 |
| `includes/hypothesis.html`, `includes/ort.css` | Deleted. | 4 |
| `bin/hypothesis.r` | Deleted. | 4 |
| `_bookdown.yml` | Drops `edit:`/`history:` keys. | 5 |
| `.github/CONTRIBUTING.md`, `.github/ISSUE_TEMPLATE.md` | Replaced with superseded notices. | 5 |
| `contributions.Rmd` | Deleted (orphaned dead source). | 5 |
| `.github/workflows/bookdown.yaml` | Runs the build inside the pinned image. | 6 |

---

### Task 1: Pinned build environment

**Files:**
- Modify: `Dockerfile` (full rewrite)
- Modify: `docker-compose.yml`
- Modify: `DESCRIPTION`
- Create: `renv.lock`, `.Rprofile`, `renv/activate.R`, `renv/settings.json`, `renv/.gitignore`
- Modify: `.Rbuildignore`, `.gitignore`

**Interfaces:**
- Produces: a Docker image tagged `r4ds-solutions:pinned` containing R 4.0.3, pandoc 2.11.4, and every book dependency; a committed `renv.lock`. Tasks 2 and 7 render inside this image. Task 6 builds it in CI.

- [ ] **Step 1: Drop hypothesisr and pin datamodelr in DESCRIPTION**

In `DESCRIPTION`, delete the `hypothesisr,` line from `Suggests:` and replace the `Remotes:` block with:

```
Remotes:
    github::bergant/datamodelr@dbc3111bd77cd4e26d13849001e6555216dfdab4
```

`rstudio/bookdown` is dropped from Remotes — the snapshot serves bookdown 0.21, which satisfies the `>= 0.7.17` floor, so there is no reason to build from GitHub.

- [ ] **Step 2: Write the Dockerfile**

Replace `Dockerfile` entirely:

```dockerfile
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
```

- [ ] **Step 3: Build the image**

Run: `docker build --platform linux/amd64 -t r4ds-solutions:pinned .`

Expected: completes without error. This is slow on first run (package install); subsequent builds hit the layer cache.

- [ ] **Step 4: Verify the pin — this is the test for this task**

Run:

```bash
docker run --rm --platform linux/amd64 r4ds-solutions:pinned Rscript -e '
  stopifnot(getRversion() == "4.0.3")
  want <- c(tidyverse = "1.3.0", ggplot2 = "3.3.3", dplyr = "1.0.3",
            tidyr = "1.1.2", bookdown = "0.21", rmarkdown = "2.6",
            knitr = "1.31")
  got <- vapply(names(want), function(p) as.character(packageVersion(p)), "")
  print(data.frame(want, got))
  stopifnot(identical(unname(got), unname(want)))
  for (p in c("lvplot","nasaweather","fueleconomy","ggstance","datamodelr","DiagrammeR"))
    stopifnot(requireNamespace(p, quietly = TRUE))
  stopifnot(rmarkdown::pandoc_version() >= "2")
  cat("PIN OK\n")'
```

Expected: prints the want/got table with every row matching, then `PIN OK`. A mismatch means the snapshot URL or base image drifted — stop and investigate rather than relaxing the assertion.

- [ ] **Step 5: Generate and commit the lockfile**

The lockfile here is an **audit record, not an activation mechanism**. The
pin is enforced by the image; `renv.lock` documents exactly what that image
resolved to. Do **not** run `renv::init()` and do **not** create `.Rprofile`
or a `renv/` directory: activating renv would repoint `.libPaths()` at an
empty project library, and every render after this task would fail to find
its packages.

```bash
docker run --rm --platform linux/amd64 -v "$PWD:/proj" r4ds-solutions:pinned Rscript -e '
  libs <- .libPaths()
  proj <- tempfile(); dir.create(proj)
  renv::snapshot(project = proj, library = libs, type = "all",
                 lockfile = "/proj/renv.lock", prompt = FALSE)'
```

Verify bookdown actually made it in — this is the exact failure that made the
`use-renv` branch useless, because renv's dependency detection never sees
bookdown (it is invoked by the knit engine, not by a `library()` call):

```bash
python3 -c "import json; d=json.load(open('renv.lock')); print('bookdown', d['Packages']['bookdown']['Version']); print('R', d['R']['Version']); print('n packages', len(d['Packages']))"
```

Expected: `bookdown 0.21`, `R 4.0.3`, and a package count well above 133.

- [ ] **Step 6: Trim docker-compose.yml**

Remove the `nodejs` service entirely (Node was dropped in commit `e5605c5`; the service references `npm test`, which no longer exists). Leave only:

```yaml
services:
  r:
    build: "."
    platform: "linux/amd64"
    volumes:
    - type: bind
      target: /home/rstudio/r4ds-exercise-solutions
      source: "."
    working_dir: /home/rstudio/r4ds-exercise-solutions
```

The top-level `version:` key is obsolete in current Compose; drop it.

- [ ] **Step 7: Keep the lockfile out of the package build**

Add to `.Rbuildignore`:

```
^renv\.lock$
```

There is no `renv/` directory to ignore, by design (see Step 5).

- [ ] **Step 8: Commit**

```bash
git add Dockerfile docker-compose.yml DESCRIPTION renv.lock .Rbuildignore
git status --short
git commit -m "Pin build environment to R 4.0.3 and the 2021-01-31 CRAN snapshot"
```

---

### Task 2: Baseline render and chunk repair

Runs **before** any content change so that breakage from the pinned environment is never confused with breakage we introduced. The `_bookdown_files` cache this produces is reused by Task 7, so the expensive cold render happens exactly once.

**Files:**
- Create: `docs/build-notes.md`
- Modify: whichever `.Rmd` files contain failing chunks (unknown until Step 2)

**Interfaces:**
- Consumes: `r4ds-solutions:pinned` from Task 1.
- Produces: a book that renders end-to-end into `_build/`; a populated `_bookdown_files/` cache; `docs/build-notes.md` listing every chunk rewritten.

- [ ] **Step 1: Add a render helper**

Create `bin/docker-render.sh`, executable:

```bash
#!/bin/sh
# Render the book inside the pinned container.
set -e
exec docker run --rm --platform linux/amd64 \
  -v "$(pwd):/home/rstudio/r4ds-exercise-solutions" \
  -w /home/rstudio/r4ds-exercise-solutions \
  r4ds-solutions:pinned \
  Rscript -e 'bookdown::render_book("index.Rmd", output_format = "bookdown::gitbook")' "$@"
```

`bin/render.R` is not used here: it calls `git2r` to refuse rendering with uncommitted changes, which fights an iterative repair loop. It stays in the repo for compatibility.

- [ ] **Step 2: Run the cold render and capture the log**

Run: `chmod +x bin/docker-render.sh && ./bin/docker-render.sh 2>&1 | tee /tmp/render-baseline.log`

Expected: either a completed book in `_build/`, or a chunk error. Note that `index.Rmd` makes live GitHub and hypothes.is API calls at render time; **if it fails on rate limiting or network, that is expected** and Task 4 removes the cause. Set `GITHUB_PAT` in the environment if the GitHub call rate-limits, or proceed to Task 4 first and return here.

- [ ] **Step 3: Triage failures**

Run: `grep -nE "^Quitting|Error in|error:" /tmp/render-baseline.log | head -40`

For each failure, record the chapter, chunk label, and error text. Then apply the repair rules from the spec:

- Minimal and chunk-local. Fix the failure, nothing else.
- Preserve the pedagogical intent and the surrounding prose.
- No 2e-motivated rewrites, no style modernisation, no cleanup of chunks that already work.

- [ ] **Step 4: Record every rewrite**

Create `docs/build-notes.md`:

```markdown
# Build notes

The book is built in the pinned container defined by `Dockerfile`
(R 4.0.3, CRAN snapshot 2021-01-31). See
`docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md`.

## Chunks rewritten to render

Solutions were not updated for the 2nd edition. The chunks below were
edited only because they failed to execute under the pinned environment.

| File | Chunk | Failure | Fix |
|---|---|---|---|
```

Append one row per rewrite. If nothing needed rewriting, write `None — the book rendered unmodified.` under the heading and keep the file: its absence is indistinguishable from a forgotten step.

- [ ] **Step 5: Re-render until clean**

Run: `./bin/docker-render.sh 2>&1 | tee /tmp/render-clean.log`

Expected: exits 0. Verify the output landed where `_bookdown.yml` says:

```bash
test -f _build/index.html && echo "output dir OK" || echo "WRONG OUTPUT DIR"
ls _build/*.html | wc -l
```

Expected: `output dir OK` and roughly 28 HTML files.

- [ ] **Step 6: Commit**

```bash
git add bin/docker-render.sh docs/build-notes.md
git add -u
git status --short
git commit -m "Render cleanly under the pinned environment"
```

---

### Task 3: Superseded banner on every page

**Files:**
- Modify: `_common.R`
- Modify: `index.Rmd`
- Modify: every chapter `.Rmd` listed in `_bookdown.yml` that is not a part divider

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: `deprecation_banner()` in `_common.R`, returning an `htmltools` div. Task 7 greps the rendered HTML for its text.

**Why per-chapter and not an include:** `bookdown::gitbook` renders one HTML document and then splits it. An `includes: in_header` entry is copied into the `<head>` of *every* split page — which is exactly how the old Google Analytics snippet reached every page. A `before_body` include lands in the body only once, so after splitting it appears on the first page alone. A banner therefore has to be emitted per chapter to appear on every page as real HTML rather than script-injected content.

- [ ] **Step 1: Add the helper to `_common.R`**

Append to `_common.R`, after `no_exercises()`:

```r
# Superseded notice. Emitted at the top of every chapter -- readers arrive
# from search engines on interior pages, so an index-only notice reaches
# almost nobody. Rendered as the same Bootstrap alert as no_exercises().
deprecation_banner <- function() {
  tags <- htmltools::tags
  tags$div(
    class = "alert alert-warning",
    role = "alert",
    tags$p(
      tags$strong("This book is superseded."),
      " These are solutions to the ", tags$strong("1st edition"), " of ",
      tags$em("R for Data Science"), ". A ",
      tags$a(href = "https://r4ds.hadley.nz/", "2nd edition"),
      " has since been published, with its own ",
      tags$a(
        href = "https://mine-cetinkaya-rundel.github.io/r4ds-solutions/",
        "solutions to the exercises"
      ), "."
    ),
    tags$p("This site is no longer maintained. It is kept online for reference.")
  )
}
```

- [ ] **Step 2: Insert the call into every chapter**

Part dividers (`# (PART)`) are not chapters and must be skipped. Run this from the repo root:

```bash
python3 - <<'PY'
import re, yaml, pathlib
cfg = yaml.safe_load(open("_bookdown.yml"))
call = "`r deprecation_banner()`\n"
touched, skipped = [], []
for f in cfg["rmd_files"]:
    p = pathlib.Path(f)
    text = p.read_text()
    if "(PART)" in text or "deprecation_banner()" in text:
        skipped.append(f); continue
    lines = text.splitlines(keepends=True)
    # insert after the first ATX heading line
    for i, ln in enumerate(lines):
        if ln.startswith("# "):
            lines.insert(i + 1, "\n" + call)
            break
    else:
        skipped.append(f); continue
    p.write_text("".join(lines))
    touched.append(f)
print("inserted:", len(touched))
print("skipped :", skipped)
PY
```

- [ ] **Step 3: Verify insertion**

Run: `grep -l "deprecation_banner()" *.Rmd | wc -l`

Expected: one per real chapter (roughly 22). Then confirm no part divider got one:

```bash
grep -l "(PART)" *.Rmd | xargs grep -l "deprecation_banner()" || echo "no part dividers touched"
```

Expected: `no part dividers touched`.

- [ ] **Step 4: Update the welcome page**

In `index.Rmd`, immediately after the `# Welcome {-}` heading, insert:

```
`r deprecation_banner()`
```

Also replace the paragraph beginning "*R for Data Science* itself is available online at" so it names the edition and points forward:

```markdown
*R for Data Science* (1st edition) is available online at
[r4ds.had.co.nz](https://r4ds.had.co.nz/). It has since been superseded by the
[2nd edition](https://r4ds.hadley.nz/), whose exercise solutions are maintained
separately at
[R for Data Science (2e) - Solutions to Exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/).
```

- [ ] **Step 5: Render and confirm the banner reaches interior pages**

Run: `./bin/docker-render.sh`

Then:

```bash
grep -c "This book is superseded" _build/index.html _build/strings.html _build/iteration.html
```

Expected: at least 1 for each. `strings.html` and `iteration.html` are the check that matters — they are interior pages a search engine would land on.

- [ ] **Step 6: Commit**

```bash
git add _common.R index.Rmd *.Rmd
git status --short
git commit -m "Add superseded notice to every page"
```

---

### Task 4: Remove trackers and freeze contributor lists

**Files:**
- Delete: `includes/hypothesis.html`, `includes/ort.css`, `bin/hypothesis.r`
- Modify: `_output.yaml`, `index.Rmd`

**Interfaces:**
- Consumes: nothing.
- Produces: an `index.Rmd` with no network calls at render time. Task 7 verifies the deployed site is free of both trackers.

- [ ] **Step 1: Capture the contributor lists before deleting the code that builds them**

Order matters — resolve the live values first, then remove the calls that
produce them. Resolve them directly rather than through the book, so the
result is inspectable:

```bash
gh api "repos/jrnold/r4ds-exercise-solutions/issues?state=all&filter=all&per_page=100" --paginate \
  --jq '.[].user.login' | sort -u | grep -v '^jrnold$' > /tmp/gh-contribs.txt
wc -l < /tmp/gh-contribs.txt

curl -s "https://hypothes.is/api/search?wildcard_uri=https://jrnold.github.io/r4ds-exercise-solutions/*&limit=200" \
  | python3 -c "import json,sys,re; rows=json.load(sys.stdin)['rows']; print('\n'.join(sorted({re.match(r'acct:(.*)@',r['user']).group(1) for r in rows if not r.get('flagged')} - {'jrnold'})))" \
  > /tmp/hyp-contribs.txt
cat /tmp/hyp-contribs.txt
```

Cross-check the hypothes.is names against the currently deployed page so that
no one who is credited today is dropped:

```bash
git show origin/gh-pages:index.html | grep -o 'hypothes.is/users/[a-zA-Z0-9_]*' | sort -u
```

Expected: the deployed page credits `electricdinosaurs` and `inkish`. If the
API returns fewer names than the deployed page, prefer the deployed page —
annotations can be deleted, and dropping an existing credit is not acceptable.

- [ ] **Step 2: Replace the live lookups with static text**

In `index.Rmd`, delete the entire `{r include=FALSE,purl=FALSE,cache=FALSE}` block that defines `github_repo_spec`, `parse_repo_spec`, `spec_owner`, `spec_repo`, `github_contribs`, and `hypothesis_contribs` (it spans from the `library("magrittr")` line to the close of `hypothesis_contribs`). Then replace the two inline calls.

Replace:

```
(in alphabetical order): `r github_contribs()`
```

with a literal, alphabetised markdown list of the logins from `/tmp/gh-contribs.txt`, each as `[\@login](https://github.com/login)`, comma-separated with ", and " before the last.

Replace the hypothes.is sentence with the same treatment using `/tmp/hyp-contribs.txt`, keeping the names but pointing them at `https://hypothes.is/users/<name>` as they are today.

Add a line immediately after both lists:

```markdown
*This list was frozen when the book was archived and is no longer updated.*
```

- [ ] **Step 3: Verify no network calls remain**

```bash
grep -nE "gh::gh|httr::GET|hypothes\.is/api" index.Rmd && echo "STILL CALLING OUT" || echo "no render-time network calls"
```

Expected: `no render-time network calls`.

- [ ] **Step 4: Remove the hypothes.is embed and orphaned CSS**

Delete the files:

```bash
git rm includes/hypothesis.html includes/ort.css bin/hypothesis.r
```

In `_output.yaml`, delete the whole trailing block:

```yaml
  includes:
    in_header:
    - "includes/hypothesis.html"
```

Remove the entire `includes:` key, not just the list entry — an empty `includes:` is not valid here. Also remove `- "includes/ort.css"` from the `css:` list, leaving `includes/r4ds.css` and `includes/r4ds-solutions.css`.

- [ ] **Step 5: Render and verify the trackers are gone from the output**

Run: `./bin/docker-render.sh`

```bash
grep -rlE "hypothes\.is/embed\.js|googletagmanager|gtag\(|UA-61453123" _build/ && echo "TRACKER STILL PRESENT" || echo "clean"
```

Expected: `clean`.

- [ ] **Step 6: Commit**

```bash
git add -A
git status --short
git commit -m "Remove hypothes.is embed and freeze contributor lists"
```

---

### Task 5: Retire contribution invitations

An archived repository is read-only, so anything inviting edits becomes a broken promise.

**Files:**
- Modify: `_output.yaml`, `_bookdown.yml`, `.github/CONTRIBUTING.md`, `.github/ISSUE_TEMPLATE.md`, `README.md`
- Delete: `contributions.Rmd`

- [ ] **Step 1: Remove the sidebar Edit link**

From `_output.yaml`, delete:

```yaml
    edit:
      link: https://github.com/jrnold/r4ds-exercise-solutions/edit/master/%s
      text: "Edit"
```

From `_bookdown.yml`, delete the `edit:` and `history:` keys. Both point at branch `master`, which is not this repo's branch (`main`), so they are already broken links on every page today.

- [ ] **Step 2: Delete the orphaned contributions chapter**

```bash
git rm contributions.Rmd
```

It is absent from `rmd_files` in `_bookdown.yml` and absent from the deployed site — dead source that solicits pull requests. Confirm nothing references it:

```bash
grep -rn "contributions" _bookdown.yml *.Rmd | grep -v "contributors" || echo "no references"
```

- [ ] **Step 3: Replace the contributing docs**

Overwrite `.github/CONTRIBUTING.md`:

```markdown
# Contributing

This repository is **superseded** and no longer accepts contributions.

These are solutions to the 1st edition of *R for Data Science*. The book has
since been published in a [2nd edition](https://r4ds.hadley.nz/), and its
exercise solutions are maintained at
[R for Data Science (2e) - Solutions to Exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/).

Please direct contributions there.
```

Overwrite `.github/ISSUE_TEMPLATE.md` with the same notice, phrased for the issue form.

- [ ] **Step 4: Point the README's build section at the container**

In `README.md`, replace the `## Build` section with:

```markdown
## Build

The site is built with [bookdown](https://bookdown.org/yihui/bookdown/) inside a
pinned container (R 4.0.3, CRAN snapshot 2021-01-31) so that it still builds
against the package versions of the 1st-edition era:

```sh
docker build --platform linux/amd64 -t r4ds-solutions:pinned .
./bin/docker-render.sh
```

Output is written to `_build/`. See `docs/build-notes.md`.
```

Also correct the install instruction, which currently tells readers to
`devtools::install_github("jrnold/r4ds-exercise-solutions")` — that will not
resolve the archived-from-CRAN dependencies. Replace it with a pointer to the
container.

- [ ] **Step 5: Verify no Edit link survives**

Run: `./bin/docker-render.sh && grep -c 'class="edit"' _build/strings.html || echo "no edit link"`

Expected: `no edit link` (or grep returning 0 matches).

- [ ] **Step 6: Commit**

```bash
git add -A
git status --short
git commit -m "Retire contribution invitations"
```

---

### Task 6: Build in CI inside the pinned image

**Files:**
- Modify: `.github/workflows/bookdown.yaml`

**Why this replaces the spec's approach:** the spec said to pin `r-version: 4.0.3` on the runner. That does not hold up — `ubuntu-latest` is now jammy/noble, `ubuntu-20.04` runners were retired, and PPM's binary path for a 2021 snapshot is built for focal. Pinning the R version on a mismatched distro silently falls back to source builds or resolves different binaries than local. Running the job **inside the same image** removes the entire class of drift, and is the only way "reproducible" is honest here.

- [ ] **Step 1: Rewrite the workflow**

```yaml
on:
  push:
    branches: [main]
  workflow_dispatch:

name: bookdown

jobs:
  bookdown:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Build the pinned image
        run: docker build --platform linux/amd64 -t r4ds-solutions:pinned .

      - name: Cache bookdown results
        uses: actions/cache@v4
        with:
          path: _bookdown_files
          key: bookdown-${{ hashFiles('**/*.Rmd') }}
          restore-keys: bookdown-

      - name: Build site
        run: |
          docker run --rm --platform linux/amd64 \
            -v "$PWD:/home/rstudio/r4ds-exercise-solutions" \
            -w /home/rstudio/r4ds-exercise-solutions \
            r4ds-solutions:pinned \
            Rscript -e 'bookdown::render_book("index.Rmd", output_format = "bookdown::gitbook")'

      - name: Deploy to GitHub Pages
        if: github.event_name != 'pull_request'
        uses: JamesIves/github-pages-deploy-action@v4.5.0
        with:
          branch: gh-pages
          folder: _build
          force: false
```

Three fixes are folded in: the deploy folder is `_build` (matching `output_dir` in `_bookdown.yml`, not the `_book` the old workflow used), `setup-renv` is gone along with its missing-lockfile failure, and the R version is pinned by the image rather than by the runner. `permissions: contents: write` is required for the deploy action to push to `gh-pages`. `force: false` is deliberate: the action force-pushes by default, which would rewrite the Travis-era `gh-pages` history the spec says to preserve.

- [ ] **Step 2: Validate the workflow parses**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/bookdown.yaml')); print('valid')"`

Expected: `valid`.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/bookdown.yaml
git status --short
git commit -m "Build in CI inside the pinned container"
```

---

### Task 7: Deploy and verify the live site

**This is the task that actually removes Google Analytics from what readers load.** Everything before it only changed source.

- [ ] **Step 1: Push the branch and open a PR**

```bash
git push -u origin deprecate-1e
gh pr create --title "Deprecate the 1st-edition solutions" --body "Implements docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md"
```

- [ ] **Step 2: Merge to main**

Merge once the user approves. The workflow triggers on push to `main`.

- [ ] **Step 3: Watch the run**

Run: `gh run watch $(gh run list --workflow=bookdown --limit 1 --json databaseId --jq '.[0].databaseId')`

Expected: success. If the build fails in CI but passed locally, the cause is almost certainly the `_bookdown_files` cache being cold in CI — allow the longer run rather than changing the pin.

- [ ] **Step 4: Verify the deployed site — the real test**

Wait for Pages to publish, then:

```bash
BASE=https://jrnold.github.io/r4ds-exercise-solutions
for page in index.html strings.html iteration.html transform.html; do
  echo "--- $page ---"
  html=$(curl -s "$BASE/$page")
  echo "$html" | grep -qE "googletagmanager|gtag\(|UA-61453123" && echo "FAIL: analytics present" || echo "ok: no analytics"
  echo "$html" | grep -q "hypothes.is/embed.js" && echo "FAIL: hypothesis present" || echo "ok: no hypothesis"
  echo "$html" | grep -q "This book is superseded" && echo "ok: banner present" || echo "FAIL: banner missing"
  echo "$html" | grep -q 'r4ds.hadley.nz' && echo "ok: 2e book linked" || echo "FAIL: 2e book link missing"
  echo "$html" | grep -q 'mine-cetinkaya-rundel.github.io/r4ds-solutions' && echo "ok: 2e solutions linked" || echo "FAIL: 2e solutions link missing"
done
```

Expected: every line `ok:`. Any `FAIL:` blocks Task 8 — do not archive a repo you still need to push fixes to.

- [ ] **Step 5: Spot-check figures against the 2020 archive**

```bash
curl -s -o /tmp/new.png "$BASE/EDA_files/figure-html/plot_diamond_carat_price-1.png"
git show origin/gh-pages:EDA_files/figure-html/plot_diamond_carat_price-1.png > /tmp/old.png
ls -l /tmp/new.png /tmp/old.png
```

Expected: both exist and are comparable in size. Byte-identical is not expected across a six-month package span; a wildly different size or a missing file means a plot silently changed and is worth a look.

---

### Task 8: Archive the repository

**Last, and only after Task 7 verifies clean.** Archiving makes the repo read-only; pushes stop working. `gh-pages` keeps serving.

- [ ] **Step 1: Update repo metadata**

```bash
gh repo edit jrnold/r4ds-exercise-solutions \
  --description "[SUPERSEDED] Solutions to the 1st edition of R for Data Science. See https://mine-cetinkaya-rundel.github.io/r4ds-solutions/ for the 2nd edition." \
  --add-topic superseded
```

- [ ] **Step 2: Confirm with the user, then archive**

Archiving is outward-facing and closes the open branches and any open issues to further contribution. Confirm explicitly before running:

```bash
gh repo archive jrnold/r4ds-exercise-solutions --yes
```

- [ ] **Step 3: Verify**

```bash
gh repo view jrnold/r4ds-exercise-solutions --json isArchived,description --jq '{archived: .isArchived, description: .description}'
curl -s -o /dev/null -w "site still up: %{http_code}\n" https://jrnold.github.io/r4ds-exercise-solutions/
```

Expected: `archived: true` and `site still up: 200`.
