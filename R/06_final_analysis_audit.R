# ==================================================
# Final Analysis Audit
# OKC 2024-25
# ==================================================

okc <- read.csv(
  "data/cleaned/okc_wins_mrp_all_players.csv"
)

comparison <- read.csv(
  "data/cleaned/okc_final_salary_mrp_working.csv"
)

stopifnot(
  nrow(okc) == 19,
  nrow(comparison) == 18,
  sum(is.na(comparison$mrp_usd)) == 1
)

stopifnot(
  isTRUE(all.equal(
    okc$wins_above_replacement,
    (okc$total_MP / 48) *
      (okc$pyth_win_pct - 0.426)
  ))
)

mrq <- (486524 + 358241 / 1.05) *
  (140588000 / 58044000)

stopifnot(
  max(abs(
    okc$mrp_usd -
      (1157153 + okc$wins_above_replacement * mrq)
  )) < 0.01
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

comparison <- comparison[
  order(-comparison$mrp_salary_gap, na.last = TRUE),
]

print(
  comparison[
    , c(
      "player",
      "wins_above_replacement",
      "mrp_usd",
      "salary_used_usd",
      "mrp_salary_gap"
    )
  ],
  row.names = FALSE
)

salary_alternatives <- data.frame(
  player = c(
    "Luguentz Dort",
    "Aaron Wiggins",
    "Adam Flagler"
  ),
  alternative_salary_usd = c(
    17000000,
    10981303,
    578577
  )
)

salary_sensitivity <- merge(
  comparison,
  salary_alternatives,
  by = "player"
)

salary_sensitivity$alternative_gap_usd <-
  salary_sensitivity$mrp_usd -
  salary_sensitivity$alternative_salary_usd

salary_sensitivity$gap_change_usd <-
  salary_sensitivity$alternative_gap_usd -
  salary_sensitivity$mrp_salary_gap

print(
  salary_sensitivity[
    , c(
      "player",
      "salary_used_usd",
      "alternative_salary_usd",
      "mrp_salary_gap",
      "alternative_gap_usd",
      "gap_change_usd"
    )
  ],
  row.names = FALSE
)

write.csv(
  salary_sensitivity,
  "output/tables/salary_sensitivity.csv",
  row.names = FALSE
)

cat("
All calculation checks passed.
")
