# Packages come from CRAN; renv.lock pins the exact versions (DECISIONS.md D004).
options(repos = c(CRAN = "https://cloud.r-project.org"))
source("renv/activate.R")

# Linux machines without a configured locale run R in "C", which prints
# umlauts in city names as <U+00FC>. Switch the character set to UTF-8 there.
# (Must come after renv/activate.R, which resets the locale.)
if (.Platform$OS.type == "unix" && !isTRUE(l10n_info()[["UTF-8"]])) {
  invisible(Sys.setlocale("LC_CTYPE", "C.UTF-8"))
}
