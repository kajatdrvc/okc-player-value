# ==================================================
# OKC Player Value Analysis
# 05 - Pythagorean Wins and MRP
# Season: 2024-25
# ==================================================

okc <- read.csv(
  "data/cleaned/okc_bpm_calculated.csv",
  check.names = FALSE
)

stopifnot(
  nrow(okc) == 19,
  sum(okc$total_MP) == 19707
)

stopifnot(
  all(abs(
    okc$bpm_calc -
      (okc$obpm_calc + okc$dbpm_calc)
  ) < 1e-8)
)

league_pp100 <- 114.5
pyth_exponent <- 14
replacement_win_pct <- 0.426

okc$points_for <-
  league_pp100 + okc$obpm_calc

okc$points_against <-
  league_pp100 - okc$dbpm_calc

stopifnot(
  all(okc$points_for > 0),
  all(okc$points_against > 0)
)

okc$pyth_win_pct <-
  okc$points_for^pyth_exponent /
  (
    okc$points_for^pyth_exponent +
      okc$points_against^pyth_exponent
  )

okc$wins_above_replacement <-
  (okc$total_MP / 48) *
  (okc$pyth_win_pct - replacement_win_pct)

current_win_revenue <- 486524
lagged_win_revenue <- 358241
discount_rate <- 0.05

mrq_historical <-
  current_win_revenue +
  lagged_win_revenue / (1 + discount_rate)

cap_2011 <- 58044000
cap_2025 <- 140588000

salary_cap_factor <- cap_2025 / cap_2011

mrq_2025 <-
  mrq_historical * salary_cap_factor

replacement_salary <- 1157153

okc$mrp_usd <-
  replacement_salary +
  okc$wins_above_replacement * mrq_2025

salaries <- read.csv(
  "data/cleaned/okc_salaries_working.csv",
  check.names = FALSE
)

final_salaries <- subset(
  salaries,
  finished_season == TRUE,
  select = c(
    player,
    salary_used_usd,
    salary_review,
    analysis_status
  )
)

player_values <- okc[
  , c(
    "Player",
    "total_MP",
    "bpm_calc",
    "obpm_calc",
    "dbpm_calc",
    "pyth_win_pct",
    "wins_above_replacement",
    "mrp_usd"
  )
]

names(player_values)[1] <- "player"

final_comparison <- merge(
  final_salaries,
  player_values,
  by = "player",
  all.x = TRUE,
  sort = FALSE
)

final_comparison$mrp_salary_gap <-
  final_comparison$mrp_usd -
  final_comparison$salary_used_usd

final_comparison <- final_comparison[
  order(-final_comparison$mrp_salary_gap,
        na.last = TRUE),
]

stopifnot(
  all(is.finite(okc$pyth_win_pct)),
  all(okc$pyth_win_pct > 0 &
        okc$pyth_win_pct < 1),
  all(is.finite(okc$wins_above_replacement)),
  all(is.finite(okc$mrp_usd)),
  nrow(final_comparison) == 18,
  sum(is.na(
    final_comparison$wins_above_replacement
  )) == 1
)

cat("Historical MRQ:",
    round(mrq_historical, 2), "
")
cat("Salary cap adjustment:",
    round(salary_cap_factor, 4), "
")
cat("2024-25 MRQ:",
    round(mrq_2025, 2), "
")

results_table <- data.frame(
  Player = final_comparison$player,
  Minutes = final_comparison$total_MP,
  BPM = round(final_comparison$bpm_calc, 2),
  Wins = round(
    final_comparison$wins_above_replacement, 2
  ),
  MRP_M = round(
    final_comparison$mrp_usd / 1e6, 2
  ),
  Salary_M = round(
    final_comparison$salary_used_usd / 1e6, 2
  ),
  Gap_M = round(
    final_comparison$mrp_salary_gap / 1e6, 2
  ),
  Salary_Review = final_comparison$salary_review
)

print(results_table, row.names = FALSE)

dir.create(
  "output/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  okc,
  "data/cleaned/okc_wins_mrp_all_players.csv",
  row.names = FALSE
)

write.csv(
  final_comparison,
  "data/cleaned/okc_final_salary_mrp_working.csv",
  row.names = FALSE
)

write.csv(
  results_table,
  "output/tables/okc_player_mrp_results_working.csv",
  row.names = FALSE
)
