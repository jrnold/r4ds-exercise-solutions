# Status — Deprecating the R4DS 1st-Edition Solutions

**Last updated:** 2026-08-29
**Branch:** `deprecate-1e`
**Plan:** `docs/superpowers/plans/2026-08-28-deprecate-r4ds-1e.md`
**Spec:** `docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md`

## Where this stands

**Tasks 1–6 are complete and committed.** Tasks 7 (deploy) and 8 (archive) are
deliberately not started: both are outward-facing and were ruled stop-and-ask
(R4). Nothing so far has changed anything a reader sees — the live site is
still serving the stale 2019-era build, Google Analytics included.

| Task | State |
|---|---|
| 1. Pinned build environment | **Done** — `8e8d485`, `2b09baf` |
| 2. Baseline render + chunk repair | **Done** — `1260bad`. Nothing needed repair. |
| 3. Superseded banner | **Done** — `fce4361`, `675bc75` |
| 4. Remove trackers, freeze contributor lists | **Done** — `c849aa7` |
| 5. Retire contribution invitations | **Done** — `e5a5b90` |
| 6. CI in the pinned container | **Done** — `9df2529` |
| 7. Deploy + verify live | **Not started. STOP-AND-ASK.** |
| 8. Archive the repository | **Not started. STOP-AND-ASK.** |

Plus `c135de7`, which wires `contributions.Rmd` into the book at the user's
request; it had never been in `rmd_files`, so `contributing.html` has always
404'd.

## The two results that mattered

**The pin works.** A 2021-01-31 CRAN snapshot still reconstructs this book's
environment. All seven pinned versions matched exactly, and all four packages
since removed from CRAN — `lvplot`, `nasaweather`, `fueleconomy`, `ggstance` —
resolved. Packages install as focal *binaries*, so the stage takes ~317s even
under x86 emulation.

**Nothing was broken.** The cold render succeeded on the first attempt, every
chapter, no chunk errors. "Rewrite failing answers" was authorised and cost
nothing. That is the payoff from dating the snapshot by provenance — the
`first-ed` tag in `hadley/r4ds` — rather than picking a date that seemed old
enough.

## What Task 7 must verify

Everything up to here has changed only source. **Only the redeploy removes
Google Analytics from what readers load** — it was deleted from source back in
`dc5227a`, yet `UA-61453123-2` is still served today from the stale `gh-pages`
build. Confirmed live on 2026-08-28:

```
googletagmanager.com/gtag/js?id=UA-61453123-2
gtag('config', 'UA-61453123-2')
hypothes.is/embed.js
```

This also fixes the order of Tasks 7 and 8: archiving disables Actions, so
archiving before a successful deploy would leave the tracker live and
unfixable without unarchiving first.

## Verification gate (2026-08-29, against `_build/`)

Checked on the built HTML, not on source. Checking source would have missed
the part-introduction gap entirely.

```
render                    exit 0, 0 chunk failures, 33 pages
banner coverage           32 / 33 pages
  without banner          contributing.html (deliberate)
trackers in _build/       none
edit/history links        none
r4ds.hadley.nz link       33 / 33 pages
2e solutions link         33 / 33 pages
contributing.html         built
github credits            79
hypothes.is credits       130
```

One correction worth recording: the first run of this gate reported the edit
links as still present. That was a broken test, not a broken build —
`grep -rl ... | head && echo FAIL` takes the `&&` branch because `head` exits 0
on empty input. Any gate of the form `grep | head && FAIL` is unsound.

## Rulings

R1–R6 were made during Task 1 and are recorded in the local ledger at
`.superpowers/sdd/2026-08-28-deprecate-r4ds-1e/progress.md`. All have since
been applied and verified. The ones still worth knowing:

**R4 — Tasks 7 and 8 are stop-and-ask.** Task 7 publishes to a live site; Task
8 archives the repository.

**R6 — the banner script had to be fence-aware.** It anchored on the first line
starting with `# `, which in `index.Rmd` is the R comment
`# don't cache anything on this page` *inside* a ```{r} chunk; the real heading
is 4 lines later. Verified after the fact: 26 chapters, exactly one call each,
none inside a chunk.

**R7 — the deployed acknowledgments under-credit hypothes.is annotators by
128 people.** `hypothesis_contribs()` called the search API with no `limit`, so
it got the API default of 20 annotations and credited the 2 users who appeared
in them. There are 646 annotations by 130 people. The frozen list is all 130.
*Cost if wrong: over-inclusion, not loss; one paragraph to revert.*

**R8 — the frozen GitHub list is the union of the live API and the deployed
page.** Three contributors — `ihagerman`, `neander09`, `r2ressler` — appear
only on the deployed page; their accounts were renamed or deleted, and the API
now returns `ghost` and `r2resslergm`. `brshallo` is excluded: that link
credits the author of a different study guide. 78 names.

**R9 — `dependabot[bot]` excluded, `ghost` kept.** One is a bot; the other
stands in for real people whose accounts are gone.

**R10 — `contributions.Rmd` does not get the banner.** Its whole body already
says the book is superseded.

## Known cosmetic issues

- The Docker build warns `FromPlatformFlagConstDisallowed`. The constant is
  deliberate — `rocker/r-ver:4.0.3` publishes no arm64 image. Leave it.
- The render warns about `libXt.so.6` once per chapter. `grSoftVersion()`
  probing for X11 in a headless container; all graphics go through png/cairo.
  Silencing it means adding `libxt6` to the Dockerfile, which invalidates every
  layer after it and forces a full package reinstall. Documented in
  `docs/build-notes.md`.
