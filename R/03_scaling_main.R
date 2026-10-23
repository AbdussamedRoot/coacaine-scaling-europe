# 03_scaling_main.R
# RQ1: scaling of per-capita load with population (fixest and multilevel
# model); reproduce the preliminary results first.
# Plan: PROJEKTPLAN.md §4.4 and §6; SPECIFICATIONS.md §2 and §3. Phase 3.
#
# Current state (phase 3, step 1): reproduction of the preliminary results.

source(here::here("R", "00_setup.R"))

ww <- readRDS(file.path(paths$processed, "ww_clean.rds"))

# ---- Reproduction of the preliminary results (plan §6; spec §2) ---------------
# Same specification as the preliminary Python analysis: main sample,
# 2022-2025, values above LOQ, country and year fixed effects, standard
# errors clustered by site. Criterion: delta within +-0.01 of plan §6.
preliminary <- tribble(
  ~metabolite,       ~delta_plan, ~ci_low_plan, ~ci_high_plan, ~n_plan, ~sites_plan,
  "cocaine",               0.391,         0.26,          0.52,     425,         169,
  "MDMA",                  0.357,         0.27,          0.44,     410,         165,
  "ketamine",              0.425,         0.26,          0.59,     224,         128,
  "methamphetamine",       0.401,         0.23,          0.57,     366,         157,
  "cannabis",              0.131,         0.08,          0.18,     269,         105,
  "amphetamine",           0.047,        -0.05,          0.15,     395,         162,
  "ets",                   0.107,        -0.07,          0.28,      33,          33,
  "cot",                   0.060,        -0.02,          0.14,      48,          48
)

repro_data <- filter(ww, is_main_sample, year >= 2022, !is_zero)

# n_data/sites_data: rows available. n_used/sites_used: rows fixest uses;
# by default it drops fixed-effect singletons (e.g. a country with a single
# measurement), which cannot affect delta but do change n and the
# small-sample corrections of the standard errors.
fit_preliminary <- function(m) {
  d <- filter(repro_data, metabolite == m)
  fit <- feols(log_load ~ log_pop_c | country + year, data = d,
               cluster = ~site_id)
  ci <- confint(fit, level = 0.95)["log_pop_c", ]
  tibble(
    metabolite = m,
    delta = unname(coef(fit)[["log_pop_c"]]),
    ci_low = ci[[1]],
    ci_high = ci[[2]],
    n_data = nrow(d),
    sites_data = n_distinct(d$site_id),
    n_used = nobs(fit),
    sites_used = n_distinct(d$site_id[obs(fit)])
  )
}

reproduction <- preliminary %>%
  left_join(bind_rows(lapply(preliminary$metabolite, fit_preliminary)),
            by = "metabolite") %>%
  mutate(
    delta_diff = delta - delta_plan,
    within_tolerance = abs(delta_diff) <= 0.01,
    same_data = n_data == n_plan & sites_data == sites_plan,
    across(c(delta, ci_low, ci_high, delta_diff), ~ round(.x, 3))
  ) %>%
  select(metabolite, delta_plan, delta, delta_diff, within_tolerance,
         ci_low_plan, ci_high_plan, ci_low, ci_high, n_plan, n_data,
         sites_plan, sites_data, same_data, n_used, sites_used)
save_table(reproduction, "reproduction_preliminary",
           title = "Reproduction of the preliminary results (plan §6): main sample, 2022-2025")

cat("Reproduction of the preliminary results",
    "(output/tables/reproduction_preliminary.csv):\n")
print(reproduction, width = Inf)

stopifnot(
  "preliminary results not reproduced: a delta differs by more than 0.01" =
    all(reproduction$within_tolerance)
)
cat("\nAll", nrow(reproduction), "deltas reproduced within +-0.01.\n")
