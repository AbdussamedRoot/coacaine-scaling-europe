# Urban scaling of illicit drug use in European wastewater

Working title: *Urban scaling and hierarchical diffusion of illicit drug use:
evidence from wastewater in ~200 European catchments, 2011–2025*

Does the per-capita load of drug residues in wastewater grow with the
population of the catchment ("urban scaling"), for which substances, and does
the big-city advantage for cocaine shrink over time ("hierarchical
diffusion")? The full analysis plan is in [`PROJEKTPLAN.md`](PROJEKTPLAN.md)
(German). All decisions and deviations from the plan are logged in
[`DECISIONS.md`](DECISIONS.md).

## Data

Source: European Union Drugs Agency (EUDA, formerly EMCDDA) and the SCORE
group, *Drugs in municipal wastewater in Europe: source data*, release 2026
(measurement years 2011–2025),
<https://www.euda.europa.eu/data/drugs-municipal-wastewater-europe-source-data_en>.
Reuse requires attribution to both EUDA and SCORE.

| File in `data/raw/` | Content |
|---|---|
| `ww2026-all-data.csv` | All measurements: year, substance, site, daily values Wed–Tue, means |
| `ww2026-site-info-table.csv` | Treatment plants: site ID, coordinates, population, institution |
| `ww2026-changes-all-substance.csv` | Change 2024→2025 per city and substance (EUDA classification) |
| `GPS-30.xlsx` | National surveys: cocaine use in the last 12 months, young adults (15–34), latest survey per country |
| `GPS-29.xlsx` | The same for all adults (15–64); used only in a robustness check |

`GPS-30.xlsx` and `GPS-29.xlsx` are tables GPS-30 and GPS-29 of the EUDA
Statistical Bulletin 2026, "Prevalence of drug use > Cocaine > Last year
prevalence > Young adults (15-34)" and "> All adults (15-64)",
<https://www.euda.europa.eu/data/stats2026/gps_en>, downloaded on
2026-10-23.

The files in `data/raw/` are the original downloads and are never modified.
Their MD5 checksums are stored in `data/raw_md5.txt`; every script checks them
at start-up and stops if a file has changed.

## How to reproduce

1. Install R 4.6 (`renv.lock` records the exact version used, 4.6.1).
2. Open `kokain-skalierung.Rproj` in RStudio, or start R in the project folder.
3. Install the exact package versions recorded in `renv.lock` with
   `renv::restore()`. On Linux the packages are compiled from source, which
   takes 10–20 minutes.
4. Run everything: `Rscript run_all.R` in a terminal, or `source("run_all.R")`
   in the R console.

`run_all.R` runs the scripts in `R/` one after another, each in a fresh R
process, and writes one log per script plus the session info to
`output/logs/`.

### Fresh Ubuntu 24.04 machine (e.g. a cloud container)

```bash
# R from the official CRAN apt repository, plus libraries needed to compile
curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
  -o /etc/apt/keyrings/cran_ubuntu_key.asc
echo "deb [signed-by=/etc/apt/keyrings/cran_ubuntu_key.asc] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
  > /etc/apt/sources.list.d/cran-r.list
apt-get update
apt-get install -y --no-install-recommends r-base r-base-dev \
  libnlopt-dev libicu-dev cmake pkg-config

# In the project folder: renv installs itself, then all packages
MAKEFLAGS=-j"$(nproc)" Rscript -e 'renv::restore(prompt = FALSE)'
```

## Project structure

```
├── CLAUDE.md            # working rules for Claude Code
├── PROJEKTPLAN.md       # analysis plan (German)
├── SPECIFICATIONS.md    # final specifications, fixed before the analyses (German)
├── DECISIONS.md         # log of decisions and deviations (German)
├── README.md
├── run_all.R            # runs all scripts in order
├── kokain-skalierung.Rproj
├── renv.lock            # exact R and package versions
├── .Rprofile, renv/     # activate renv when R starts in the project
├── data/
│   ├── raw/             # original files, never modified
│   ├── raw_md5.txt      # checksums of the raw files
│   └── processed/       # cleaned data (generated, not in git)
├── R/
│   ├── 00_setup.R       # packages, options, seed, paths, raw-data check
│   ├── functions.R      # helper functions
│   └── 01_import_clean.R … 07_figures.R
├── output/
│   ├── figures/         # PDF + PNG (300 dpi)
│   ├── tables/          # CSV + HTML
│   └── logs/
└── paper/
    └── literature_check.md  # literature search, candidates to verify
```

## Status

Phases 0–2 complete: setup, data cleaning and audit, national prevalence
data, literature search, and the analysis specifications, frozen on
2026-10-23 in `SPECIFICATIONS.md` before any result was computed. Still open:
the author's reading of the cited sources and confirmation of the meaning of
`cot`/`ets`.

Phase 3 in progress: the preliminary results of plan §6 are reproduced (all
eight deltas within 0.001). Next: RQ1 main analysis.
