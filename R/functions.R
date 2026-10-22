# functions.R
# Helper functions shared by all scripts (sourced by 00_setup.R).

# Stop if a raw data file is missing or has been modified.
# Compares MD5 checksums with data/raw_md5.txt, written once at project setup.
check_raw_data <- function(checksum_file = here::here("data", "raw_md5.txt")) {
  expected <- utils::read.table(checksum_file, col.names = c("md5", "file"),
                                colClasses = "character")
  actual <- unname(tools::md5sum(file.path(paths$raw, expected$file)))
  bad <- expected$file[is.na(actual) | actual != expected$md5]
  if (length(bad) > 0) {
    stop("Raw data missing or modified: ", paste(bad, collapse = ", "),
         call. = FALSE)
  }
  invisible(TRUE)
}
