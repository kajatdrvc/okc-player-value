# ==================================================
# Final Salary Reconciliation
# 2024-25 Oklahoma City Thunder
# ==================================================

salaries <- read.csv(
  "data/cleaned/okc_salaries_working.csv",
  stringsAsFactors = FALSE
)

comparison <- read.csv(
  "data/cleaned/okc_final_salary_mrp_working.csv",
  stringsAsFactors = FALSE
)

stopifnot(
  nrow(salaries) == 20,
  nrow(comparison) == 18,
  anyDuplicated(salaries$player) == 0
)

hoopshype_url <- paste0(
  "https://hoops-hype-us-east1-664912083968.",
  "us-east1.run.app/salaries/teams/",
  "oklahoma-city-thunder/25/?season=2024"
)

decisions <- data.frame(
  player = c(
    "Branden Carlson",
    "Adam Flagler",
    "Ajay Mitchell"
  ),

  final_salary_usd = c(
    717538,
    584412,
    3347451
  ),

  primary_source = c(
    hoopshype_url,
    "https://www.salaryswish.com/players/adam-flagler",
    hoopshype_url
  ),

  explanation = c(
    paste(
      "Joined OKC Nov 16, 2024.",
      "Multiple short-term and two-way deals.",
      "Use reported OKC season total;",
      "do not prorate a second time."
    ),

    paste(
      "2024-25 two-way contract.",
      "SalarySwish reports 584412;",
      "HoopsHype reports 578577.",
      "Use individual contract figure."
    ),

    paste(
      "Already on OKC at season start.",
      "Converted contract Feb 6, 2025.",
      "Use historical season total,",
      "not only the 3000000 standard deal."
    )
  ),

  stringsAsFactors = FALSE
)

salaries$salary_source_primary <- salaries$source_url

salaries$salary_basis <-
  "Reported 2024-25 player salary, not cap hit"

salaries$proration_note <-
  "No midseason arrival adjustment required"

idx <- match(decisions$player, salaries$player)

stopifnot(!anyNA(idx))

salaries$salary_used_usd[idx] <-
  decisions$final_salary_usd

salaries$salary_source_primary[idx] <-
  decisions$primary_source

salaries$proration_note[idx] <-
  decisions$explanation

salaries$proration_note[
  !salaries$finished_season
] <- "Not in final-roster MRP comparison"

salaries$proration_note[
  salaries$player == "Nikola Topic"
] <- "Rostered all season; no regular-season games"

salaries$salary_review <- ifelse(
  salaries$player %in% decisions$player,
  "Audited: documented source decision",
  "Audited"
)

match_idx <- match(
  comparison$player,
  salaries$player
)

stopifnot(!anyNA(match_idx))

original_mrp <- comparison$mrp_usd
original_wins <- comparison$wins_above_replacement
original_bpm <- comparison$bpm_calc

comparison$salary_used_usd <-
  salaries$salary_used_usd[match_idx]

comparison$salary_source_primary <-
  salaries$salary_source_primary[match_idx]

comparison$proration_note <-
  salaries$proration_note[match_idx]

comparison$salary_review <-
  salaries$salary_review[match_idx]

comparison$mrp_salary_gap <-
  comparison$mrp_usd -
  comparison$salary_used_usd

stopifnot(
  nrow(comparison) == 18,
  anyDuplicated(comparison$player) == 0,
  setequal(
    comparison$player,
    salaries$player[salaries$finished_season]
  ),
  sum(is.na(comparison$mrp_usd)) == 1,
  comparison$player[
    is.na(comparison$mrp_usd)
  ] == "Nikola Topic",
  all(!is.na(comparison$salary_used_usd)),
  identical(comparison$mrp_usd, original_mrp),
  identical(
    comparison$wins_above_replacement,
    original_wins
  ),
  identical(comparison$bpm_calc, original_bpm)
)

valid <- !is.na(comparison$mrp_usd)

stopifnot(
  max(abs(
    comparison$mrp_salary_gap[valid] -
      (
        comparison$mrp_usd[valid] -
          comparison$salary_used_usd[valid]
      )
  )) < 0.01
)

dir.create(
  "data/cleaned",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "documentation",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  salaries,
  "data/cleaned/okc_salaries_final.csv",
  row.names = FALSE
)

write.csv(
  comparison,
  "data/cleaned/okc_final_salary_mrp_final.csv",
  row.names = FALSE
)

write.csv(
  decisions,
  "documentation/salary_decisions_2024_25.csv",
  row.names = FALSE
)

cat("
Final salary reconciliation complete.
")

cat(
  "Final-roster players:",
  nrow(comparison), "
"
)

cat(
  "Players with calculated MRP:",
  sum(!is.na(comparison$mrp_usd)), "
"
)

cat(
  "Missing player salaries:",
  sum(is.na(comparison$salary_used_usd)), "
"
)

cat(
  "BPM, wins and MRP unchanged: TRUE
"
)

print(
  comparison[
    comparison$player %in% decisions$player,
    c(
      "player",
      "salary_used_usd",
      "mrp_usd",
      "mrp_salary_gap"
    )
  ],
  row.names = FALSE
)
