# Build notes

The book is built in the pinned container defined by `Dockerfile`
(R 4.0.3, Posit CRAN snapshot 2021-01-31, pandoc 2.11.4). See
`docs/superpowers/specs/2026-08-28-deprecate-r4ds-1e-design.md` for why that
date was chosen, and `renv.lock` for exactly what it resolves to.

To build:

```sh
docker build -t r4ds-solutions:pinned .
./bin/docker-render.sh
```

Output lands in `_build/`, per `output_dir` in `_bookdown.yml`.

## Chunks rewritten to render

Solutions were not updated for the 2nd edition. The chunks below were
edited only because they failed to execute under the pinned environment.

| File | Chunk | Failure | Fix |
|---|---|---|---|

None --- the book rendered unmodified.

Every chapter executed on the first cold render against the 2021-01-31
snapshot, with no chunk errors. This is the expected result and the reason the
snapshot date was pinned to the `first-ed` tag in `hadley/r4ds`: the code in
this book was written against those package versions, so nothing in it has had
to be adapted.

## Known warnings

The render emits one warning per chapter (32 in total):

```
In grSoftVersion() :
  unable to load shared object '/usr/local/lib/R/modules//R_X11.so':
  libXt.so.6: cannot open shared object file: No such file or directory
```

It is cosmetic. `grSoftVersion()` probes for X11 support, which a headless
container does not have and this book does not need --- all graphics are
written to files through the png/cairo devices. It could be silenced by adding
`libxt6` to the `apt-get install` list in `Dockerfile`, but doing so
invalidates every layer after it and forces a full reinstall of the package
tree, which is not worth it for log noise. Output is unaffected.

## Render-time network access

`index.Rmd` resolves its contributor lists through the GitHub and hypothes.is
APIs while the book builds. `bin/docker-render.sh` forwards a `GITHUB_PAT` from
the host when one is set, but only if it is a legacy 40-hex-digit token: the
`gh` package in this snapshot (1.2.0) validates the token format and rejects
the `ghp_`/`gho_` tokens that `gh auth token` returns today. Unauthenticated
requests are within rate limits for this repository.

The repository is bind-mounted from the host, so its files are owned by the
host user while the container runs as root. `bin/docker-render.sh` marks the
directory safe for git inside the container; without that, git refuses to read
the tree ("dubious ownership") and `gh::gh_tree_remote()` cannot resolve the
repository spec.
