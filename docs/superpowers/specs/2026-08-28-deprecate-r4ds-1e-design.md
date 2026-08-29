# Deprecating the R4DS 1st-Edition Exercise Solutions

Date: 2026-08-28
Status: Approved (design); implementation not started

## Goal

Freeze this book as a clearly-labelled archive of the **1st edition** of
*R for Data Science*, rebuilt reproducibly at period-correct package
versions, stripped of third-party tracking and annotation services, and
marked deprecated at the repository level.

Solutions are **not** being updated for the 2nd edition. The one
exception is code that fails to render under the pinned environment;
see "Failing chunks" below.

## Current state

Established by inspection of the repository and the deployed site.

| Item | State |
|---|---|
| README | Already has superseded badge + 2e link (commit `ff1f2f0`) |
| Google Analytics in source | Already removed (commit `dc5227a`) |
| Google Analytics on the live site | **Still present** — `UA-61453123-2` |
| hypothes.is in source | Present — `_output.yaml:30` |
| hypothes.is on the live site | **Still present** |
| Deprecation notice in the book | **Absent** — README only |
| `renv.lock` on `main` | **Absent** |
| Last deploy | 2020-07-19, by Travis CI |

The live site has not been rebuilt since 2020-07-19. Removing trackers
from source has therefore had **no effect on what readers load**. Only a
redeploy actually removes them.

### CI is broken three ways

`.github/workflows/bookdown.yaml`:

1. Calls `r-lib/actions/setup-renv@v2`, but there is no `renv.lock`.
2. Deploys `_book/`, but `_bookdown.yml` sets `output_dir: "_build"`.
3. Pins no R version, so it drifts to whatever is current.

### Stale branches

- `remove-google-analytics` — superseded; its deletions already landed
  on `main` via `dc5227a`. Do not merge.
- `use-renv` — pins R 4.3.2 / tidyverse 2.0.0 / ggplot2 3.4.4, omits
  `bookdown` entirely (133 packages, no bookdown), and was never green.
  **Regenerate from scratch; do not repair.**

## The pinned environment

### Why this date

`hadley/r4ds` has **never contained a lockfile** (verified: code search
for `renv.lock` across the repo returns 0). Its CI resolves latest on
every build. There is no pinned 2e or 1e environment to inherit.

It does have a **`first-ed` tag** — commit `2390ed2`, dated
**2021-01-31** — marking the canonical end-state of the 1st edition. A
date reconstructs an environment more reliably than a lockfile would.

### The pin

**R 4.0.3 + Posit Package Manager CRAN snapshot `2021-01-31`.**

| Package | Version | Package | Version |
|---|---|---|---|
| R | 4.0.3 | tidyverse | 1.3.0 |
| ggplot2 | 3.3.3 | dplyr | 1.0.3 |
| tidyr | 1.1.2 | bookdown | 0.21 |
| rmarkdown | 2.6 | knitr | 1.31 |

R 4.0.3 (2020-10-10) is the release current at the snapshot date; 4.0.4
did not ship until 2021-02-15.

### Verified against live services

- Snapshot serves **sources and focal binaries** (both HTTP 200).
  `rocker/r-ver:4.0.3` is Ubuntu focal, so the distro matches and we get
  binaries rather than source builds.
- Snapshot still serves **all four packages since removed from CRAN**:
  `lvplot` 0.2.0, `nasaweather`, `fueleconomy`, `ggstance`. These are
  unobtainable from CRAN today. This is the single biggest reason the
  build is currently unreproducible.
- Every version floor in `DESCRIPTION` is satisfied:
  `ggplot2 >= 3.3.0`, `tidyr >= 1.0.0`, `bookdown >= 0.7.17`.
- The snapshot sits 6 months after this repo's own last green deploy
  (2020-07-19) on the same major stack, so output should closely match
  the archived site.

### Architecture

`rocker/r-ver:4.0.3` is amd64-only (4.1.0 is the first with arm64). PPM
Linux binaries are *also* amd64-only, so running the container as
`linux/amd64` under emulation is the **faster** path — binaries beat
natively compiling 130+ packages on arm64.

### Non-CRAN dependencies

- `datamodelr` — GitHub-only, used in `relational-data.Rmd`. Pin to
  `bergant/datamodelr@dbc3111` (2019-08-10), the commit current at the
  snapshot date.
- `hypothesisr` — **drop**. Referenced only by `bin/hypothesis.r`, never
  by any `.Rmd`. Removed from `DESCRIPTION` along with the script.

## Work items

### 1. Reproducible build

Replace the `Dockerfile`. The current one is `rocker/verse:latest` plus
a Node 10 install — unpinned and no longer buildable.

- Base `rocker/r-ver:4.0.3`, platform `linux/amd64`.
- Point the default repo at the dated snapshot, focal binary path.
- Install from `DESCRIPTION`; pin `datamodelr` by SHA.
- Generate `renv.lock` **inside that container** and commit it.
- Drop the dead `nodejs` service from `docker-compose.yml`.

### 2. Book content: superseded notice

Wording decisions (settled): use the word **superseded**; link **both**
the 2e book and the 2e solutions; render as a warning-styled block.

Add `deprecation_banner()` to `_common.R`, beside the existing
`no_exercises()` helper and following its `htmltools` style. Emit it on
the welcome page **and every chapter** — readers arrive from search
engines on interior pages such as `strings.html`, so an index-only
notice reaches almost nobody.

Draft text, for review:

> **This book is superseded.**
>
> These are solutions to the **1st edition** of *R for Data Science*.
> A [2nd edition](https://r4ds.hadley.nz/) has since been published,
> with its own
> [solutions to the exercises](https://mine-cetinkaya-rundel.github.io/r4ds-solutions/).
>
> This site is no longer maintained. It is kept online for reference.

Rendered as `class = "alert alert-warning"`, matching the existing
`no_exercises()` alert.

Also update `index.Rmd`, which still directs readers to
`r4ds.had.co.nz` with no mention of the 2e.

### 3. Remove third-party services

- Delete `includes/hypothesis.html` and its `_output.yaml:30` reference.
- Delete `includes/ort.css` — Open Review styling, orphaned since
  `dc5227a`.
- Delete `bin/hypothesis.r`.
- **Freeze the render-time API calls in `index.Rmd`.** `github_contribs()`
  calls the GitHub API and `hypothesis_contribs()` calls
  `hypothes.is/api/search` *during the build*. An archival book cannot
  depend on live services, and one of them is a service being removed.
  Resolve both to static text, **preserving every contributor name
  currently credited**. Names stay; the live lookup goes.
- Google Analytics is already out of source. It is still live on the
  site; **only the redeploy removes it**.
- Keep the twitter/linkedin share buttons in `_output.yaml` — plain
  links, no trackers.

### 3b. Retire contribution invitations

An archived repository is read-only, so anything inviting edits becomes a
broken promise. Three places do:

- **`_output.yaml` `edit:` block and `_bookdown.yml` `edit:`/`history:`
  keys** render an "Edit" link in the sidebar of every page. They point
  at the `master` branch, which is not even this repo's branch (`main`),
  so they are *already* broken. Remove them.
- **`.github/CONTRIBUTING.md` and `.github/ISSUE_TEMPLATE.md`** still
  walk people through filing issues and pull requests. Replace the body
  of each with a short superseded notice pointing at the 2e solutions.
- **`contributions.Rmd`** solicits contributions ("Click the edit this
  page on the sidebar", "Submit a pull request"). It is **orphaned** —
  absent from `rmd_files` in `_bookdown.yml` and absent from the
  deployed site. Delete it as dead source rather than editing it.

Note that after removing the `in_header` include in item 3, the
`includes:` key in `_output.yaml` is left empty; remove the whole block,
not just the list entry.

### 4. Fix and run CI

Fix all three defects: commit the lockfile, correct the deploy folder to
`_build`, and pin `r-version: 4.0.3` plus the snapshot so CI and local
agree. Then run it once to deploy.

### 5. Archive the repository

**Last.** Only after the deploy is verified live and GA is confirmed
gone. Archiving blocks pushes, so the ordering is not optional.

Also update the repo description and topics to say superseded.

## Failing chunks

Under the pinned environment some chunks may error. **Rewrite them** so
the book renders. Constraints:

- Minimal, chunk-local edits. Fix the failure, nothing else.
- Preserve the pedagogical intent and the prose around the solution.
- No 2e-motivated rewrites, no style modernisation, no opportunistic
  cleanup of chunks that already work.
- Record every rewrite so the final report lists them explicitly.

## Verification

Against the **deployed site**, not the local build:

1. No `googletagmanager`, `gtag`, or `UA-61453123-2` in any page.
2. No `hypothes.is/embed.js`.
3. Banner present on the index **and** on a random interior chapter.
4. Spot-check figures against the archived 2020 output.
5. No "Edit" link in the page sidebar.
6. Repo shows GitHub's archived banner.

## Risks

1. **The snapshot is not identical to the 2020-07-19 build.** Close, but
   chunks may error. Handled by "Failing chunks" above.
2. **No `_bookdown_files` cache**, so this is a cold render of 27
   chapters under emulation. Slow.
3. **`gh-pages` history is a Travis-era artifact.** Add a fresh commit;
   do not rewrite the history.
4. **Frozen contributor lists go stale by construction.** Accepted — the
   book is an archive.
