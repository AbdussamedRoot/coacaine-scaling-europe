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

# Great-circle distance in km between points given in decimal degrees.
haversine_km <- function(lat1, lon1, lat2, lon2) {
  rad <- pi / 180
  a <- sin((lat2 - lat1) * rad / 2)^2 +
    cos(lat1 * rad) * cos(lat2 * rad) * sin((lon2 - lon1) * rad / 2)^2
  6371 * 2 * asin(sqrt(a))
}

# ---- Figures -------------------------------------------------------------------
# Colours of the validated reference chart palette (light mode). A single
# series uses series_1; context (de-emphasised) marks use the axis grey.
pal <- c(
  surface = "#fcfcfb", ink = "#0b0b0b", ink_2 = "#52514e", muted = "#898781",
  grid = "#e1e0d9", axis = "#c3c2b7", series_1 = "#2a78d6"
)

data_source <- "Data: EUDA and SCORE, wastewater source data (release 2026)."

# Common ggplot theme: hairline grid and axes in recessive greys, text in ink.
theme_project <- function(base_size = 9) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background = element_rect(fill = pal[["surface"]], colour = NA),
      panel.grid.major = element_line(colour = pal[["grid"]], linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.line = element_line(colour = pal[["axis"]], linewidth = 0.3),
      axis.ticks = element_line(colour = pal[["axis"]], linewidth = 0.3),
      axis.text = element_text(colour = pal[["ink_2"]]),
      axis.title = element_text(colour = pal[["ink_2"]]),
      plot.title = element_text(colour = pal[["ink"]], face = "bold"),
      plot.subtitle = element_text(colour = pal[["ink_2"]]),
      plot.caption = element_text(colour = pal[["muted"]], hjust = 0),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      strip.text = element_text(colour = pal[["ink"]], face = "bold",
                                hjust = 0),
      legend.title = element_blank(),
      legend.text = element_text(colour = pal[["ink_2"]])
    )
}

# Save a ggplot as PDF and PNG (300 dpi) in output/figures/.
# timestamp = FALSE keeps the PDF byte-identical between runs.
save_figure <- function(plot, name, width = 7, height = 4.5) {
  ggsave(file.path(paths$figures, paste0(name, ".pdf")), plot,
         width = width, height = height, device = "pdf", timestamp = FALSE)
  ggsave(file.path(paths$figures, paste0(name, ".png")), plot,
         width = width, height = height, dpi = 300, type = "cairo")
  invisible(plot)
}

# ---- Tables --------------------------------------------------------------------
# Write a data frame as a small self-contained HTML table: no external CSS or
# JavaScript, so the file works offline and is identical on every run.
write_html_table <- function(df, file, title = NULL) {
  esc <- function(x) {
    x <- gsub("&", "&amp;", x, fixed = TRUE)
    x <- gsub("<", "&lt;", x, fixed = TRUE)
    gsub(">", "&gt;", x, fixed = TRUE)
  }
  is_num <- vapply(df, is.numeric, logical(1))
  cells <- lapply(df, function(x) {
    out <- if (is.numeric(x)) {
      format(x, big.mark = ",", trim = TRUE, scientific = FALSE)
    } else {
      as.character(x)
    }
    out[is.na(x)] <- ""
    esc(out)
  })
  align <- ifelse(is_num, " class=\"num\"", "")
  header <- paste0("<th", align, ">", esc(names(df)), "</th>", collapse = "")
  rows <- vapply(seq_len(nrow(df)), function(i) {
    paste0("<tr>", paste0("<td", align, ">",
                          vapply(cells, `[`, "", i), "</td>", collapse = ""),
           "</tr>")
  }, "")
  html <- c(
    "<!DOCTYPE html>", "<html>", "<head>", "<meta charset=\"utf-8\">",
    paste0("<title>", esc(title %||% basename(file)), "</title>"),
    "<style>",
    "body { font-family: system-ui, -apple-system, 'Segoe UI', sans-serif; color: #0b0b0b; background: #fcfcfb; }",
    "table { border-collapse: collapse; font-size: 14px; font-variant-numeric: tabular-nums; }",
    "caption { text-align: left; font-weight: bold; padding-bottom: 8px; }",
    "th, td { padding: 4px 10px; border-bottom: 1px solid #e1e0d9; text-align: left; }",
    "th { color: #52514e; border-bottom-color: #c3c2b7; }",
    ".num { text-align: right; }",
    "</style>", "</head>", "<body>", "<table>",
    if (!is.null(title)) paste0("<caption>", esc(title), "</caption>"),
    paste0("<thead><tr>", header, "</tr></thead>"),
    "<tbody>", rows, "</tbody>", "</table>", "</body>", "</html>"
  )
  writeLines(enc2utf8(html), file, useBytes = TRUE)
}

# Save a table as CSV (exact values) and HTML (for reading) in output/tables/.
save_table <- function(df, name, title = NULL) {
  write_csv(df, file.path(paths$tables, paste0(name, ".csv")), na = "")
  write_html_table(df, file.path(paths$tables, paste0(name, ".html")), title)
  invisible(df)
}
