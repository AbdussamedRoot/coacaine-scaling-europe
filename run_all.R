# run_all.R
# Runs all scripts in R/ in order. Each script runs in its own fresh R
# process, which proves that it works on its own. The console output of each
# script is saved to output/logs/<script>.log, the session info to
# output/logs/session_info.txt.
#
# Usage, from the project folder:  Rscript run_all.R

source(here::here("R", "00_setup.R"))

scripts <- c(
  "01_import_clean.R",
  "02_audit_descriptives.R",
  "03_scaling_main.R",
  "04_diffusion.R",
  "05_saturation.R",
  "06_robustness.R",
  "07_figures.R"
)

rscript <- file.path(R.home("bin"), "Rscript")

for (script in scripts) {
  message("\n==== ", script, " ====")
  # system2() warns on a non-zero exit status; the status is checked below
  out <- suppressWarnings(
    system2(rscript, shQuote(here::here("R", script)),
            stdout = TRUE, stderr = TRUE)
  )
  writeLines(out, file.path(paths$logs, sub("\\.R$", ".log", script)))
  writeLines(out)
  status <- attr(out, "status")
  if (!is.null(status) && status != 0) {
    stop(script, " failed (exit status ", status, "), see output/logs/",
         call. = FALSE)
  }
}

writeLines(capture.output(sessionInfo()),
           file.path(paths$logs, "session_info.txt"))
message("\nAll scripts finished.")
