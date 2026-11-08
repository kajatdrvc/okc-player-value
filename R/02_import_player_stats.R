# ==================================================
# OKC Player Value Analysis
# 02 - Import and Combine Player Statistics
# Season: 2024-25
# ==================================================

# STEP 13: Import Basketball-Reference CSV snapshots
totals <- read.csv(
  "data/raw/basketball_reference/okc_totals.csv",
  check.names = FALSE
)

per100 <- read.csv(
  "data/raw/basketball_reference/okc_per100.csv",
  check.names = FALSE
)

advanced <- read.csv(
  "data/raw/basketball_reference/okc_advanced.csv",
  check.names = FALSE
)

clean_players <- function(df) {
  subset(df, !is.na(Player) & Player != "Team Totals")
}

totals <- clean_players(totals)
per100 <- clean_players(per100)
advanced <- clean_players(advanced)

stopifnot(
  nrow(totals) == 19,
  nrow(per100) == 19,
  nrow(advanced) == 19,
  setequal(totals$Player, per100$Player),
  setequal(totals$Player, advanced$Player)
)

prefix_columns <- function(df, prefix) {
  cols <- names(df) != "Player"
  names(df)[cols] <- paste0(
    prefix, names(df)[cols]
  )
  df
}

totals <- prefix_columns(totals, "total_")
per100 <- prefix_columns(per100, "p100_")
advanced <- prefix_columns(advanced, "adv_")

player_stats <- merge(
  totals, per100,
  by = "Player",
  sort = FALSE
)

player_stats <- merge(
  player_stats, advanced,
  by = "Player",
  sort = FALSE
)

salaries_working <- read.csv(
  "data/cleaned/okc_salaries_working.csv"
)

salary_columns <- salaries_working[
  , c(
    "player",
    "salary_used_usd",
    "analysis_status",
    "salary_review"
  )
]

okc_data <- merge(
  player_stats,
  salary_columns,
  by.x = "Player",
  by.y = "player",
  all.x = TRUE,
  sort = FALSE
)

stopifnot(
  nrow(okc_data) == 19,
  anyDuplicated(okc_data$Player) == 0,
  sum(as.numeric(okc_data$total_MP)) == 19707,
  sum(is.na(okc_data$salary_used_usd)) == 0
)

cat("Players:", nrow(okc_data), "
")
cat("Total minutes:", sum(okc_data$total_MP), "
")
cat("Missing salaries:",
    sum(is.na(okc_data$salary_used_usd)), "
")

write.csv(
  okc_data,
  "data/cleaned/okc_player_data_working.csv",
  row.names = FALSE
)
