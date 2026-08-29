# Status — Deprecating the R4DS 1st-Edition Solutions

**Last updated:** 2026-08-28
**Branch:** `deprecate-1e`
**Plan:** `docs/superpowers/plans/2026-08-28-deprecate-r4ds-1e.md`
**Spec:** `docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md`

## How to resume

Read the spec, then the plan, then this file. Execution was running under
`superpowers:subagent-driven-development` — one implementer subagent per task,
a task review after each. The controller ledger (rulings, dispatch history) is
at `.superpowers/sdd/2026-08-28-deprecate-r4ds-1e/progress.md`, which is
excluded via `.git/info/exclude` and therefore **local to this machine only**.
Everything needed to continue without it is in this file.

Resume at **Task 1, Step 5** (generate `renv.lock`). The Docker image already
exists and is verified; do not rebuild it.

## The headline result: the pin works

The whole approach rested on an untested assumption — that a 2021-01-31 CRAN
snapshot could still reconstruct this book's environment. It can. The image
built clean and the verification gate passed exactly:

```
           want   got
tidyverse 1.3.0 1.3.0
ggplot2   3.3.3 3.3.3
dplyr     1.0.3 1.0.3
tidyr     1.1.2 1.1.2
bookdown   0.21  0.21
rmarkdown   2.6   2.6
knitr      1.31  1.31
archived-from-CRAN packages present
pandoc: 2.11.4
PIN OK
```

Notable details from the build:

- Packages installed as **binaries** (`installing *binary* package ...`), not
  from source — the focal binary path in the snapshot URL is doing its job.
  The package stage took ~317s despite x86 emulation on Apple Silicon.
- `lvplot`, `nasaweather`, `fueleconomy`, `ggstance` — all four packages since
  removed from CRAN — resolved from the snapshot. This was the single biggest
  risk to reproducibility and it is now retired.
- `datamodelr` installed from the pinned SHA `dbc3111b`.
- Ubuntu focal's apt repositories still serve, which the build depends on for
  system libraries. No extra libraries beyond the plan's list were needed.
- Image: `r4ds-solutions:pinned`, 618MB.

Reproduce the gate at any time with the command in Task 1, Step 4 of the plan.

## Task status

| Task | State |
|---|---|
| 1. Pinned build environment | **Steps 1-4 and 6-7 done, verified.** Step 5 (`renv.lock`) not run. Not committed at time of writing — see below. |
| 2. Baseline render + chunk repair | Not started. **This is the real unknown.** |
| 3. Superseded banner | Not started. Corrected insertion script ready — see ruling R6. |
| 4. Remove trackers, freeze contributor lists | Not started. |
| 5. Retire contribution invitations | Not started. |
| 6. CI in the pinned container | Not started. |
| 7. Deploy + verify live | Not started. **Stop-and-ask** — pushes to a shared branch and publishes. |
| 8. Archive the repository | Not started. **Stop-and-ask** — irreversible-feeling, outward-facing. |

## Rulings made during execution

Six decisions were taken without asking. Three were plan defects that would
have failed at execution time. Each is listed with what it costs if wrong.

**R1 — Task 3 double-inserted the banner into `index.Rmd`.** The Step 2 script
iterates `rmd_files`, which includes `index.Rmd`, and Step 4 then inserted the
same call after the same heading. Ruling: the script owns insertion for every
file including `index.Rmd`; Step 4 is reduced to rewriting the prose paragraph
only. *Cost if wrong: a duplicated banner, visible in Step 5's grep count.*

**R2 — Task 2's baseline render precedes Task 4**, so `index.Rmd` still calls
the GitHub and hypothes.is APIs during it. Ruling: pass `GITHUB_PAT` into the
container. If the render still fails *solely* on those calls, Task 2 may apply
Task 4 Step 2 (freezing the lookups) early. *Cost if wrong: work shifts between
tasks; no output difference.*

**R3 — `htmltools` was missing from `DESCRIPTION`.** `_common.R` calls
`htmltools::tags` directly but the package arrived only transitively via
rmarkdown. Ruling: add it to `Suggests:`. Applied. *Cost if wrong: one
redundant line.*

**R4 — Tasks 7 and 8 are stop-and-ask**, not autonomous. Task 7 pushes to a
shared branch, merges, and publishes to a live site; Task 8 archives the repo.
*Cost if wrong: none; the user can simply approve.*

**R5 — `pyyaml` is not installed for any `python3` on this machine** (checked
system, homebrew, `/usr/bin`), but Task 3 Step 2 and Task 6 Step 2 both need
it. Ruling: invoke as `uv run --quiet --with pyyaml python3` (uv 0.12.6 is
present). *Cost if wrong: the step errors immediately and visibly.*

**R6 — Task 3's script would have corrupted `index.Rmd`.** It anchors on the
first line starting with `# `. In `index.Rmd` that is the R comment
`# don't cache anything on this page` at line 22, **inside a ```{r} chunk**;
the real heading `# Welcome {-}` is line 25. The script would have injected an
inline R call into an R chunk, breaking it and silently omitting the banner
from the most-read page. `#` is a comment in R and a heading in Markdown, and
`.Rmd` is both at once, so any line-oriented match must be fence-aware.
Ruling: use the corrected fence-aware script, saved at
`.superpowers/sdd/2026-08-28-deprecate-r4ds-1e/task-3-insert-banner.py`.
Verified by dry run: 26 chapters targeted, 6 part dividers correctly skipped
(`explore`, `wrangle`, `program`, `model`, `communicate`, `appendixes`),
`index.Rmd` resolving to line 25. *Cost if wrong: caught by Step 3's grep and
Step 5's render.*

**If that workspace file is gone,** the correction is: track ```` ``` ````
fence toggles while scanning, and match `# ` only when outside a fence.

## Next concrete step

Task 1, Step 5 — generate the lockfile as an audit record. Do **not** run
`renv::init()` and do **not** create `.Rprofile` or a `renv/` directory:
activating renv would repoint `.libPaths()` at an empty project library and
break every later render. The packages live in the image's system library.

```bash
docker run --rm --platform linux/amd64 -v "$PWD:/proj" r4ds-solutions:pinned Rscript -e '
  libs <- .libPaths()
  proj <- tempfile(); dir.create(proj)
  renv::snapshot(project = proj, library = libs, type = "all",
                 lockfile = "/proj/renv.lock", prompt = FALSE)'
```

Then confirm `bookdown` is actually in it — its omission is exactly what made
the abandoned `use-renv` branch useless, because renv's dependency detection
never sees bookdown (the knit engine invokes it; no `library()` call names it):

```bash
uv run --quiet --with pyyaml python3 -c "import json; d=json.load(open('renv.lock')); print('bookdown', d['Packages']['bookdown']['Version']); print('R', d['R']['Version']); print('n', len(d['Packages']))"
```

After that, Task 2's cold render is the next real unknown: 2021-era packages
meeting 2018-era code. Per the spec, chunks that fail there get **rewritten**
(minimal, chunk-local, logged in `docs/build-notes.md`); solutions that already
work are left alone.

## Known cosmetic issue

The Docker build emits one warning:
`FromPlatformFlagConstDisallowed: FROM --platform flag should not use constant
value "linux/amd64"`. It is advisory. The constant is deliberate here — the
image must be amd64 regardless of builder architecture, because
`rocker/r-ver:4.0.3` publishes no arm64 variant. Leave it.
