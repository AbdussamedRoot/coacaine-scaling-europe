# 02_audit_descriptives.R
# Data audit and descriptive statistics: Table 1, population distribution,
# zero shares, panel structure, first scatter plots.
# Plan: PROJEKTPLAN.md §4.3. Phase 1.

source(here::here("R", "00_setup.R"))

ww <- readRDS(file.path(paths$processed, "ww_clean.rds"))

# Display names in the order of plan §6. The meaning of cot and ets is not
# confirmed yet (plan §3.2), hence the question marks.
substance_labels <- c(
  cocaine = "Cocaine (benzoylecgonine)", MDMA = "MDMA", ketamine = "Ketamine",
  methamphetamine = "Methamphetamine", cannabis = "Cannabis (THC-COOH)",
  amphetamine = "Amphetamine", ets = "ets (ethyl sulfate?)",
  cot = "cot (cotinine?)"
)
main <- ww %>%
  filter(is_main_sample) %>%
  mutate(substance = factor(substance_labels[metabolite],
                            levels = substance_labels))
stopifnot("unknown substance" = !anyNA(main$substance))

# ---- Table 1: data overview ------------------------------------------------------
# Population statistics are over sites, so that each site counts once.
table1 <- main %>%
  group_by(substance) %>%
  summarise(
    measurements = n(),
    above_loq = sum(!is_zero),
    sites = n_distinct(site_id),
    countries = n_distinct(country),
    years = paste0(min(year), "-", max(year)),
    n_years = n_distinct(year),
    .groups = "drop"
  ) %>%
  left_join(
    main %>%
      distinct(substance, site_id, population) %>%
      group_by(substance) %>%
      summarise(population_median = round(median(population)),
                population_min = min(population),
                population_max = max(population), .groups = "drop"),
    by = "substance"
  )
save_table(table1, "table1_data_overview",
           title = "Table 1. Data overview, main sample (EU27, Norway, Turkey)")

cat("Table 1 (output/tables/table1_data_overview.csv):\n")
print(table1, width = Inf)

# ---- Population distribution ---------------------------------------------------------
sites_main <- distinct(main, site_id, population)
stopifnot("a site has more than one population value" =
            nrow(sites_main) == n_distinct(main$site_id))

pop_breaks <- c(1e4, 3e4, 1e5, 3e5, 1e6, 3e6, 1e7)
pop_labels <- c("10k", "30k", "100k", "300k", "1M", "3M", "10M")

p_pop <- ggplot(sites_main, aes(population)) +
  geom_histogram(binwidth = 0.2, boundary = 0, fill = pal[["series_1"]],
                 colour = pal[["surface"]], linewidth = 0.5) +
  geom_vline(xintercept = 1e5, colour = pal[["ink_2"]], linewidth = 0.4) +
  annotate("text", x = 1e5, y = Inf, label = " 100k: reference city of log_pop_c",
           hjust = 0, vjust = 1.5, size = 2.8, colour = pal[["ink_2"]]) +
  scale_x_log10(breaks = pop_breaks, labels = pop_labels) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.1))) +
  labs(title = "Population of the catchments",
       subtitle = sprintf("Main sample, %d sites; bins of equal width on the log scale",
                          nrow(sites_main)),
       x = "Population (log scale)", y = "Number of sites",
       caption = data_source) +
  theme_project()
save_figure(p_pop, "audit_population_histogram", width = 6, height = 3.5)

cat("\nPopulation of the", nrow(sites_main), "sites in the main sample:\n")
print(summary(sites_main$population))

# ---- Zeros (below LOQ) per substance and year ------------------------------------------
zero_counts <- main %>%
  group_by(substance, year) %>%
  summarise(n = n(), zeros = sum(is_zero), .groups = "drop")
zero_table <- zero_counts %>%
  transmute(substance, year, zero_pct = round(100 * zeros / n, 1)) %>%
  pivot_wider(names_from = year, values_from = zero_pct, names_sort = TRUE)
save_table(zero_table, "zero_share_by_year",
           title = "Share of values below the limit of quantification (%), main sample")

cat("\nShare of zeros (%) per substance and year (output/tables/zero_share_by_year.csv):\n")
print(zero_table, width = Inf)

# ---- Panel structure: years per site ---------------------------------------------------
years_per_site <- main %>%
  group_by(substance, site_id) %>%
  summarise(n_years = n_distinct(year), .groups = "drop")
panel_table <- years_per_site %>%
  count(substance, n_years, name = "sites") %>%
  pivot_wider(names_from = substance, values_from = sites, values_fill = 0) %>%
  arrange(n_years)
save_table(panel_table, "panel_years_per_site",
           title = "Number of sites by number of years with a measurement, main sample")

cat("\nSites by number of years with a measurement",
    "(output/tables/panel_years_per_site.csv):\n")
print(panel_table, width = Inf)

# Sites that RQ2 can use: at least two years with a cocaine value above LOQ
rq2_sites <- main %>%
  filter(metabolite == "cocaine", !is_zero) %>%
  group_by(site_id) %>%
  summarise(n_years = n_distinct(year), n = n(), .groups = "drop")
cat("\nCocaine, values above LOQ: sites with >= 2 years:",
    sum(rq2_sites$n_years >= 2), "of", nrow(rq2_sites), "sites;",
    sum(rq2_sites$n[rq2_sites$n_years >= 2]), "of", sum(rq2_sites$n),
    "measurements\n")

# Single-year substances (cot, ets) are left out of the figure
p_panel <- years_per_site %>%
  filter(!substance %in% substance_labels[c("cot", "ets")]) %>%
  count(substance, n_years) %>%
  ggplot(aes(n_years, n)) +
  geom_col(width = 0.7, fill = pal[["series_1"]]) +
  facet_wrap(~ substance, ncol = 3) +
  scale_x_continuous(breaks = c(1, 5, 10, 15)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(title = "How many years is each site in the data?",
       subtitle = "Main sample; number of sites by number of years with a measurement",
       x = "Number of years with a measurement", y = "Number of sites",
       caption = data_source) +
  theme_project()
save_figure(p_panel, "audit_panel_structure", width = 7, height = 4.5)

# ---- Finland: composition of the sample over time (plan §3.3, item 4) -------------------
cocaine_sites <- main %>%
  filter(metabolite == "cocaine") %>%
  mutate(group = factor(if_else(country == "FI", "Finland", "Other countries"),
                        levels = c("Other countries", "Finland"))) %>%
  count(year, group)
fi_counts <- filter(cocaine_sites, group == "Finland")
fi_odd <- range(fi_counts$n[fi_counts$year %% 2 == 1])
fi_even <- range(fi_counts$n[fi_counts$year %% 2 == 0 & fi_counts$year >= 2014])

cat("\nCocaine: sites per year, Finland and other countries:\n")
print(cocaine_sites %>% pivot_wider(names_from = group, values_from = n,
                                    values_fill = 0), n = Inf)

p_fi <- ggplot(cocaine_sites, aes(year, n, fill = group)) +
  geom_col(width = 0.7, colour = pal[["surface"]], linewidth = 0.5) +
  scale_fill_manual(values = c("Finland" = pal[["series_1"]],
                               "Other countries" = pal[["axis"]]),
                    breaks = c("Finland", "Other countries")) +
  scale_x_continuous(breaks = seq(2011, 2025, 2)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
  labs(title = "Cocaine: sites per year, Finland highlighted",
       subtitle = sprintf(paste("Finland takes part with %d sites in odd years",
                                "and %d-%d sites in even years (since 2014)"),
                          fi_odd[1], fi_even[1], fi_even[2]),
       x = NULL, y = "Number of sites", caption = data_source) +
  theme_project() +
  theme(legend.position = "top", legend.justification = "left")
save_figure(p_fi, "audit_sites_per_year_finland", width = 6, height = 3.5)

# ---- First scatter plots: load vs population ----------------------------------------------
# Values above LOQ only (log of 0 is undefined). The line is a simple
# least-squares fit on the log scales without country or year effects: for
# orientation only, not the planned model of plan §4.4.
p_scatter <- main %>%
  filter(!is_zero) %>%
  ggplot(aes(population, daily_mean)) +
  geom_point(size = 0.9, alpha = 0.35, colour = pal[["series_1"]],
             stroke = 0) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
              colour = pal[["ink"]], linewidth = 0.6) +
  facet_wrap(~ substance, ncol = 4, scales = "free_y") +
  scale_x_log10(breaks = c(1e4, 1e5, 1e6, 1e7),
                labels = c("10k", "100k", "1M", "10M")) +
  scale_y_log10(breaks = scales::breaks_log(n = 5),
                labels = scales::label_comma(drop0trailing = TRUE)) +
  labs(title = "Per-capita load vs. population",
       subtitle = paste("Main sample, all years pooled, values above LOQ.",
                        "Line: simple fit without country or year effects",
                        "(orientation only, not the planned model)."),
       x = "Population (log scale)",
       y = "Load (mg/day per 1,000 inhabitants, log scale)",
       caption = data_source) +
  theme_project()
save_figure(p_scatter, "audit_scatter_load_population", width = 8, height = 5)

message("02_audit_descriptives.R: tables in output/tables/, ",
        "figures in output/figures/.")
