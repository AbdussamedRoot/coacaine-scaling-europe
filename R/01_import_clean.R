# 01_import_clean.R
# Import raw CSVs, fix known data problems, add flags, run checks, save
# data/processed/ww_clean.rds.
# Plan: PROJEKTPLAN.md §4.2. Phase 1. Decisions: DECISIONS.md D005-D008.

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
  "daily mean missing" = !anyNA(ww$daily_mean),
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

# ---- Sample groups (plan §4.1; D008) --------------------------------------------
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

# ---- Recomputed means (plan §3.3, item 5; D007) ---------------------------------
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

# ---- Site IDs that may denote the same plant (plan §3.3, item 2; D005) ----------
# Site IDs are never merged: every ID is its own site. Pairs that may denote
# the same plant under a new ID are only documented. Candidates are pairs in
# the same country with the same city name (ignoring a "(n)" suffix), one
# name contained in the other, the same plant name, or coordinates less than
# 3 km apart.
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
    lon = suppressWarnings(as.numeric(longitude)),
    sample_group = sample_group_of(country)
  ) %>%
  select(site_id, country, sample_group, city, location, population, years,
         base, lat, lon)

site_id_candidates <- site_info %>%
  inner_join(select(site_info, -sample_group), by = "country",
             suffix = c("_a", "_b"), relationship = "many-to-many") %>%
  filter(site_id_a < site_id_b) %>%
  mutate(
    distance_km = round(haversine_km(lat_a, lon_a, lat_b, lon_b), 1),
    same_name = base_a == base_b,
    name_contained = str_detect(base_b, fixed(base_a)) |
      str_detect(base_a, fixed(base_b)),
    same_location = coalesce(location_a == location_b, FALSE),
    close = coalesce(distance_km < 3, FALSE),
    pop_ratio = round(population_b / population_a, 3)
  ) %>%
  filter(same_name | name_contained | same_location | close) %>%
  select(sample_group, country, site_id_a, city_a, location_a, population_a,
         years_a, site_id_b, city_b, location_b, population_b, years_b,
         distance_km, pop_ratio, same_name, name_contained, same_location,
         close) %>%
  arrange(sample_group, country, site_id_a)
write_csv(site_id_candidates, file.path(paths$logs, "site_id_candidates.csv"))

cat("\nSite-ID pairs that may denote the same plant (not merged, D005;",
    "details: output/logs/site_id_candidates.csv):\n")
print(select(site_id_candidates, sample_group, site_id_a, city_a, years_a,
             site_id_b, city_b, years_b, pop_ratio),
      n = Inf, width = Inf)

# ---- Multi-plant sites (plan §3.3, item 3; D006) --------------------------------
# multi_plant: several plants are named, i.e. more than one plant in
#   "location" (separated by ";") or "Sum of ...", plus Berlin (4) (DE001),
#   whose four plants are named under its later ID DE002.
# multi_plant_unclear: a plant count in brackets in the name, e.g. "(2)",
#   but only one plant named. Exception: Basel (2) (CH003) and Zurich (2)
#   (CH019) name the same single plant as their older IDs CH002 and CH018,
#   so they count as single plants.
# Robustness check R6 excludes both groups.
site_flags <- site_info %>%
  mutate(
    n_plants_listed = str_count(coalesce(location, ""), ";") + 1,
    count_in_name = str_detect(city, "\\(([^)]*\\d[^)]*|[IVX]+(-[IVX]+)?)\\)"),
    sum_of = str_detect(paste(city, location),
                        regex("sum of", ignore_case = TRUE)),
    multi_plant = n_plants_listed > 1 | sum_of | site_id == "DE001",
    multi_plant_unclear = !multi_plant & count_in_name &
      !site_id %in% c("CH003", "CH019")
  )
main_flags <- filter(site_flags, sample_group == "main")
stopifnot(
  "unexpected number of flagged multi-plant sites in the main sample" =
    sum(main_flags$multi_plant) == 16 && sum(main_flags$multi_plant_unclear) == 3
)

multi_plant_sites <- site_flags %>%
  filter(multi_plant | multi_plant_unclear) %>%
  mutate(status = if_else(multi_plant, "multi_plant", "unclear")) %>%
  select(sample_group, site_id, country, city, status, n_plants_listed,
         location, population, years) %>%
  arrange(sample_group, status, site_id)
write_csv(multi_plant_sites, file.path(paths$logs, "multi_plant_sites.csv"))

cat("\nMulti-plant sites (D006; details: output/logs/multi_plant_sites.csv):\n")
print(select(multi_plant_sites, sample_group, site_id, city, status,
             n_plants_listed, location),
      n = Inf, width = Inf)

ww <- ww %>%
  left_join(select(site_flags, site_id, multi_plant, multi_plant_unclear),
            by = "site_id")

# ---- Flags and analysis variables (plan §4.1 and §4.2) ---------------------------
# Values below the limit of quantification are stored as 0 (plan §3.2);
# log_load is missing for them.
ww <- ww %>%
  mutate(
    is_main_sample = sample_group == "main",
    is_zero = daily_mean == 0,
    log_load = if_else(daily_mean > 0, log(daily_mean), NA_real_),
    log_pop_c = log(population) - log(100000),
    t = (year - 2018) / 10
  )

# ---- Final checks and save ---------------------------------------------------------
ww_clean <- ww %>%
  select(year, metabolite, site_id, country, city, sample_group,
         is_main_sample, population, all_of(day_cols), weekday_mean,
         weekend_mean, daily_mean, n_days_missing, is_zero, multi_plant,
         multi_plant_unclear, log_load, log_pop_c, t) %>%
  arrange(year, metabolite, site_id)

stopifnot(
  "rows were lost or added" = nrow(ww_clean) == 5238,
  "key (year, metabolite, site_id) is not unique" =
    !anyDuplicated(ww_clean[c("year", "metabolite", "site_id")]),
  "missing values in population, flags or analysis variables" =
    !anyNA(ww_clean[c("sample_group", "is_main_sample", "population",
                      "is_zero", "multi_plant", "multi_plant_unclear",
                      "log_pop_c", "t")]),
  "log_load must be missing exactly for the zeros" =
    identical(is.na(ww_clean$log_load), ww_clean$is_zero)
)
saveRDS(ww_clean, file.path(paths$processed, "ww_clean.rds"))
cat("\nSaved data/processed/ww_clean.rds:", nrow(ww_clean), "rows,",
    ncol(ww_clean), "columns\n")

# ---- Report (plan §4.2: rows per substance and year, sites, zeros) ---------------
main <- filter(ww_clean, is_main_sample)

cat("\nOverview:\n")
print(ww_clean %>%
  group_by(sample_group) %>%
  summarise(measurements = n(), sites = n_distinct(site_id),
            countries = n_distinct(country), .groups = "drop"))

cat("\nMain sample: measurements per substance and year:\n")
print(table(main$metabolite, main$year))

cat("\nMain sample: sites, zeros and multi-plant flags per substance:\n")
print(main %>%
  group_by(metabolite) %>%
  summarise(measurements = n(), sites = n_distinct(site_id),
            years = paste0(min(year), "-", max(year)),
            zeros = sum(is_zero), zero_share = round(mean(is_zero), 3),
            multi_plant = sum(multi_plant),
            multi_plant_unclear = sum(multi_plant_unclear), .groups = "drop"))

cat("\nAll data: missing day values per row:\n")
print(table(n_days_missing = ww_clean$n_days_missing))
