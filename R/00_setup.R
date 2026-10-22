# 00_setup.R
# Shared setup, sourced at the top of every script in R/:
# loads packages, sets options and the random seed, defines paths and
# verifies that the raw data are unchanged.
#
# here::here() finds the project root via kokain-skalierung.Rproj, so R must
# be started inside the project folder (or one of its subfolders).

# ---- Packages ----------------------------------------------------------------
required_packages <- c(
  "readr", "dplyr", "tidyr", "stringr", "ggplot2", "here",
  "fixest", "lme4", "lmerTest", "broom.mixed", "modelsummary", "patchwork"
)

# Check all packages first, so the error lists every missing one at once
is_installed <- vapply(required_packages, requireNamespace, logical(1),
                       quietly = TRUE)
if (!all(is_installed)) {
  stop("Missing R packages: ",
       paste(required_packages[!is_installed], collapse = ", "),
       "\nRun renv::restore() in the project root to install them.",
       call. = FALSE)
}

# Explicit library() calls (this is also how renv detects the dependencies)
suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(stringr)
  library(ggplot2)
  library(here)
  library(fixest)
  library(lme4)
  library(lmerTest)   # loaded after lme4: its lmer() adds p-values
  library(broom.mixed)
  library(modelsummary)
  library(patchwork)
})

# ---- Options and seed --------------------------------------------------------
# Wide console output so that tables in output/logs/ are not wrapped
options(readr.show_col_types = FALSE, width = 200)

# Baseline seed; scripts that use randomness call set.seed(2026) again
# directly before the random step.
set.seed(2026)

# ---- Paths -------------------------------------------------------------------
paths <- list(
  raw       = here::here("data", "raw"),
  processed = here::here("data", "processed"),
  figures   = here::here("output", "figures"),
  tables    = here::here("output", "tables"),
  logs      = here::here("output", "logs")
)
for (p in paths[c("processed", "figures", "tables", "logs")]) {
  dir.create(p, recursive = TRUE, showWarnings = FALSE)
}

# ---- Helper functions and raw data check -------------------------------------
source(here::here("R", "functions.R"))
check_raw_data()
