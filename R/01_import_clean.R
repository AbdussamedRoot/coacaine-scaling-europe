# 01_import_clean.R
# Import raw CSVs, fix known data problems, add flags, run checks, save
# data/processed/ww_clean.rds.
# Plan: PROJEKTPLAN.md §4.2. Phase 1.
#
# Current state (phase 1, step 1): import, country-code fix, checks, and
# logs of the data problems that need a decision. Step 2 adds the site-ID
# crosswalk and the flags and saves the cleaned data.

source(here::here("R", "00_setup.R"))

# ---- Read raw data -----------------------------------------------------------
# Explicit column types: an unexpected value (e.g. text in a number column)
# shows up in problems() instead of silently turning the column into text.
ww_raw <- read_csv(
  file.path(paths$raw, "ww2026-all-data.csv"),
  locale = locale(encoding = "latin1"),
  col_types = cols(
    Year = col_integer(), Metabolite = col_character(),
    `Site ID` = col_character(), Country = col_character(),
    City = col_character(), .default = col_double()
  )
)
sites_raw <- read_csv(
  file.path(paths$raw, "ww2026-site-info-table.csv"),
  locale = locale(encoding = "latin1"),
  col_types = cols(Population = col_double(), .default = col_character())
)
stopifnot(
  "parsing problems in the raw data" =
    nrow(problems(ww_raw)) == 0 && nrow(problems(sites_raw)) == 0,
  "unexpected number of rows or columns" =
    nrow(ww_raw) == 5238 && ncol(ww_raw) == 15 && nrow(sites_raw) == 258
)

# ---- snake_case names, country code ------------------------------------------
# "H" is not an ISO country code; the files use it for Hungary (Debrecen).
day_cols <- c("wednesday", "thursday", "friday", "saturday", "sunday",
              "monday", "tuesday")

ww <- ww_raw %>%
  rename_with(~ str_to_lower(str_replace_all(.x, " ", "_"))) %>%
  mutate(country = if_else(country == "H", "HU", country))

sites <- sites_raw %>%
  rename(site_id = SiteID) %>%
  rename_with(str_to_lower) %>%
  mutate(country = if_else(country == "H", "HU", country))

cat("Country code H -> HU:", sum(ww_raw$Country == "H"), "measurements,",
    sum(sites_raw$Country == "H"), "site(s)\n")

# ---- Checks and population ---------------------------------------------------
stopifnot(
  "key (year, metabolite, site_id) is not unique" =
    !anyDuplicated(ww[c("year", "metabolite", "site_id")]),
  "site IDs are not unique in the site table" = !anyDuplicated(sites$site_id),
  "measurements with a site ID missing from the site table" =
    all(ww$site_id %in% sites$site_id),
  "population missing or not positive in the site table" =
    !anyNA(sites$population) && all(sites$population > 0),
  "country differs between measurements and site table" =
    all(ww$country == sites$country[match(ww$site_id, sites$site_id)])
)

ww <- ww %>% left_join(select(sites, site_id, population), by = "site_id")
stopifnot("measurements without population" = !anyNA(ww$population))

# ---- Sample groups (plan §4.1) -------------------------------------------------
eu27 <- c("AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE",
          "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT",
          "RO", "SK", "SI", "ES", "SE")
europe_other <- c("CH", "GB", "IS", "RS", "BA")  # only in robustness check R8

sample_group_of <- function(country) {
  case_when(
    country %in% c(eu27, "NO", "TR") ~ "main",
    country %in% europe_other ~ "europe_other",
    TRUE ~ "non_europe"
  )
}
ww <- ww %>% mutate(sample_group = sample_group_of(country))

cat("\nMeasurements and sites per sample group:\n")
print(ww %>%
  group_by(sample_group) %>%
  summarise(measurements = n(), sites = n_distinct(site_id),
            countries = n_distinct(country), .groups = "drop"))

# ---- Recomputed means (plan §3.3, item 5) --------------------------------------
# Weekday = Tue/Wed/Thu, weekend = Fri/Sat/Sun/Mon, daily = all seven days.
# The file's daily_mean stays the primary value; the recomputed means are
# only a check. Tolerance 0.011: the published values are rounded to two
# decimals, so means of rounded day values can differ by up to 0.01.
day_values <- as.matrix(ww[day_cols])
row_mean <- function(cols) {
  m <- rowMeans(day_values[, cols, drop = FALSE], na.rm = TRUE)
  replace(m, is.nan(m), NA)
}
ww <- ww %>%
  mutate(
    n_days_missing = rowSums(is.na(day_values)),
    weekday_mean_calc = row_mean(c("tuesday", "wednesday", "thursday")),
    weekend_mean_calc = row_mean(c("friday", "saturday", "sunday", "monday")),
    daily_mean_calc = row_mean(day_cols)
  )

tol <- 0.011
deviations_for <- function(measure) {
  ww %>%
    transmute(
      year, metabolite, site_id, city, n_days_missing, measure = measure,
      file_value = .data[[paste0(measure, "_mean")]],
      calc_value = .data[[paste0(measure, "_mean_calc")]],
      abs_diff = abs(file_value - calc_value),
      rel_diff = if_else(calc_value > 0, abs_diff / calc_value, NA_real_)
    ) %>%
    filter(abs_diff > tol)
}
mean_deviations <- bind_rows(lapply(c("weekday", "weekend", "daily"),
                                    deviations_for))
write_csv(mean_deviations, file.path(paths$logs, "mean_deviations.csv"))

cat("\nFile means that differ from the recomputed means by more than", tol,
    "(details: output/logs/mean_deviations.csv):\n")
print(count(mean_deviations, measure))
cat("Weekday mean, deviations by year:\n")
print(table(mean_deviations$year[mean_deviations$measure == "weekday"]))
daily_dev <- filter(mean_deviations, measure == "daily")
cat("Daily mean, relative deviation > 5 %:", sum(daily_dev$rel_diff > 0.05,
    na.rm = TRUE), "rows; > 10 %:", sum(daily_dev$rel_diff > 0.10,
    na.rm = TRUE), "rows; of these with missing days:",
    sum(daily_dev$rel_diff > 0.10 & daily_dev$n_days_missing > 0,
        na.rm = TRUE), "\n")

# ---- Candidate pairs for a site-ID crosswalk (plan §3.3, item 2) ---------------
# Some plants get a new site ID in a later release. Candidates are pairs in
# the same country with the same city name (ignoring a "(n)" suffix), one
# name contained in the other, the same plant name, or coordinates less than
# 3 km apart. The list is checked by hand; the crosswalk follows in step 2.
site_info <- sites %>%
  filter(site_id %in% ww$site_id) %>%
  left_join(
    ww %>%
      group_by(site_id) %>%
      summarise(years = paste(sort(unique(year)), collapse = ","),
                .groups = "drop"),
    by = "site_id"
  ) %>%
  mutate(
    base = str_to_lower(str_trim(str_remove(city, "\\s*\\(.*\\)$"))),
    # a few coordinates are "N/A" or garbled; they become NA here
    lat = suppressWarnings(as.numeric(latitude)),
    lon = suppressWarnings(as.numeric(longitude))
  ) %>%
  select(site_id, country, city, location, population, years, base, lat, lon)

crosswalk_candidates <- site_info %>%
  inner_join(site_info, by = "country", suffix = c("_a", "_b"),
             relationship = "many-to-many") %>%
  filter(site_id_a < site_id_b) %>%
  mutate(
    distance_km = round(haversine_km(lat_a, lon_a, lat_b, lon_b), 1),
    same_name = base_a == base_b,
    name_contained = str_detect(base_b, fixed(base_a)) |
      str_detect(base_a, fixed(base_b)),
    same_location = coalesce(location_a == location_b, FALSE),
    close = coalesce(distance_km < 3, FALSE),
    pop_ratio = round(population_b / population_a, 3),
    sample_group = sample_group_of(country)
  ) %>%
  filter(same_name | name_contained | same_location | close) %>%
  select(sample_group, country, site_id_a, city_a, location_a, population_a,
         years_a, site_id_b, city_b, location_b, population_b, years_b,
         distance_km, pop_ratio, same_name, name_contained, same_location,
         close) %>%
  arrange(sample_group, country, site_id_a)
write_csv(crosswalk_candidates, file.path(paths$logs, "site_id_candidates.csv"))

cat("\nCandidate pairs for the site-ID crosswalk",
    "(details: output/logs/site_id_candidates.csv):\n")
print(select(crosswalk_candidates, sample_group, site_id_a, city_a, years_a,
             site_id_b, city_b, years_b, pop_ratio),
      n = Inf, width = Inf)

# ---- Candidates for multi-plant sites (plan §3.3, item 3) ----------------------
# Signs of several plants: more than one plant name in "location" (separated
# by ";"), a plant count in brackets in the city name, e.g. "(2)", "(IV)" or
# "(II-VII)", or "Sum of ..." in the name.
multi_plant_candidates <- site_info %>%
  mutate(
    n_plants_listed = str_count(coalesce(location, ""), ";") + 1,
    count_in_name = str_detect(city, "\\(([^)]*\\d[^)]*|[IVX]+(-[IVX]+)?)\\)"),
    sum_of = str_detect(paste(city, location), regex("sum of",
                                                     ignore_case = TRUE)),
    sample_group = sample_group_of(country)
  ) %>%
  filter(n_plants_listed > 1 | count_in_name | sum_of) %>%
  select(sample_group, site_id, country, city, location, n_plants_listed,
         count_in_name, population, years) %>%
  arrange(sample_group, site_id)
write_csv(multi_plant_candidates,
          file.path(paths$logs, "multi_plant_candidates.csv"))

cat("\nCandidates for multi-plant sites",
    "(details: output/logs/multi_plant_candidates.csv):\n")
print(select(multi_plant_candidates, sample_group, site_id, city,
             n_plants_listed, location),
      n = Inf, width = Inf)

# ---- Short report ----------------------------------------------------------------
cat("\nMeasurements per substance and year:\n")
print(table(ww$metabolite, ww$year))
cat("\nShare of zeros (below LOQ) in the daily mean, per substance:\n")
print(ww %>%
  group_by(metabolite) %>%
  summarise(n = n(), zeros = sum(daily_mean == 0),
            share = round(zeros / n, 3), .groups = "drop"))
cat("\nMissing day values per row:\n")
print(table(n_days_missing = ww$n_days_missing))

message("01_import_clean.R: step 1 done. Crosswalk, flags and saving ",
        "follow in step 2.")
