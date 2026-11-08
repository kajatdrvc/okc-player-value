# ==================================================
# OKC Player Value Analysis
# 04 - Calculate BPM, OBPM and DBPM
# Season: 2024-25
# ==================================================

okc <- read.csv(
  "data/cleaned/okc_position_creation.csv",
  check.names = FALSE
)

stopifnot(
  nrow(okc) == 19,
  sum(okc$total_MP) == 19707
)

league_ratings <- read.csv(
  "data/raw/basketball_reference/nba_team_ratings.csv",
  check.names = FALSE
)

team_row <- subset(
  league_ratings,
  Team == "Oklahoma City Thunder"
)
league_row <- subset(
  league_ratings,
  Team == "League Average"
)

stopifnot(nrow(team_row) == 1, nrow(league_row) == 1)

team_net <- as.numeric(team_row$NRtg)
team_off <- as.numeric(team_row$ORtg)
league_off <- as.numeric(league_row$ORtg)

stopifnot(
  abs(team_net - 12.8) < 0.01,
  abs(team_off - 120.3) < 0.01,
  abs(league_off - 114.5) < 0.01
)

team_points_per_shot <- sum(okc$total_PTS) /
  sum(okc$total_FGA + 0.44 * okc$total_FTA)

player_shot_attempts <-
  okc$total_FGA + 0.44 * okc$total_FTA

stopifnot(all(okc$total_PTS > 0))

okc$adjusted_pts_p100 <-
  (
    okc$total_PTS -
      (team_points_per_shot - 1) *
      player_shot_attempts
  ) *
  (okc$p100_PTS / okc$total_PTS)

total_coef <- list(
  pts = 0.860,
  threes = 0.389,
  ast = c(0.580, 1.034),
  tov = c(-0.964, -0.964),
  orb = c(0.613, 0.181),
  drb = c(0.116, 0.181),
  stl = c(1.369, 1.008),
  blk = c(1.327, 0.703),
  pf = c(-0.367, -0.367),
  fga = c(-0.560, -0.780),
  fta = c(-0.246, -0.343),
  position_constant = -0.818,
  creation_constant = -2.774
)

offensive_coef <- list(
  pts = 0.605,
  threes = 0.477,
  ast = c(0.476, 0.476),
  tov = c(-0.579, -0.882),
  orb = c(0.606, 0.422),
  drb = c(-0.112, 0.103),
  stl = c(0.177, 0.294),
  blk = c(0.725, 0.097),
  pf = c(-0.439, -0.439),
  fga = c(-0.330, -0.472),
  fta = c(-0.145, -0.208),
  position_constant = -1.698,
  creation_constant = -0.860
)

interpolate <- function(values, x) {
  values[1] +
    (values[2] - values[1]) * (x - 1) / 4
}

calculate_raw_bpm <- function(coef) {
  pos <- okc$position_final
  cre <- okc$creation_final

  position_adjustment <- pmin(
    coef$position_constant *
      (3 - pos) / 2,
    0
  )

  creation_adjustment <-
    coef$creation_constant * (3 - cre) / 2

  coef$pts * okc$adjusted_pts_p100 +
    coef$threes * okc[["p100_3P"]] +
    interpolate(coef$ast, pos) * okc$p100_AST +
    interpolate(coef$tov, pos) * okc$p100_TOV +
    interpolate(coef$orb, pos) * okc$p100_ORB +
    interpolate(coef$drb, pos) * okc$p100_DRB +
    interpolate(coef$stl, pos) * okc$p100_STL +
    interpolate(coef$blk, pos) * okc$p100_BLK +
    interpolate(coef$pf, pos) * okc$p100_PF +
    interpolate(coef$fga, cre) * okc$p100_FGA +
    interpolate(coef$fta, cre) * okc$p100_FTA +
    position_adjustment +
    creation_adjustment
}

okc$raw_bpm <- calculate_raw_bpm(total_coef)
okc$raw_obpm <- calculate_raw_bpm(offensive_coef)

minutes <- okc$total_MP
lead_bonus <- team_net / 2 * 0.175 * 0.99
team_bpm_target <- (team_net + lead_bonus) / 5
team_obpm_target <-
  (team_off - league_off + lead_bonus / 2) / 5

raw_bpm_average <- weighted.mean(
  okc$raw_bpm, minutes
)

raw_obpm_average <- weighted.mean(
  okc$raw_obpm, minutes
)

bpm_adjustment <-
  team_bpm_target - raw_bpm_average

obpm_adjustment <-
  team_obpm_target - raw_obpm_average

okc$bpm_calc <- okc$raw_bpm + bpm_adjustment
okc$obpm_calc <- okc$raw_obpm + obpm_adjustment
okc$dbpm_calc <- okc$bpm_calc - okc$obpm_calc

okc$bpm_difference <-
  okc$bpm_calc - okc$adv_BPM
okc$obpm_difference <-
  okc$obpm_calc - okc$adv_OBPM
okc$dbpm_difference <-
  okc$dbpm_calc - okc$adv_DBPM

stopifnot(
  all(is.finite(okc$bpm_calc)),
  all(is.finite(okc$obpm_calc)),
  all(is.finite(okc$dbpm_calc)),
  abs(weighted.mean(okc$bpm_calc, minutes) -
        team_bpm_target) < 1e-8,
  abs(weighted.mean(okc$obpm_calc, minutes) -
        team_obpm_target) < 1e-8
)

bpm_results <- data.frame(
  Player = okc$Player,
  Minutes = okc$total_MP,
  BPM = round(okc$bpm_calc, 2),
  Published_BPM = okc$adv_BPM,
  BPM_Difference = round(okc$bpm_difference, 2),
  OBPM = round(okc$obpm_calc, 2),
  DBPM = round(okc$dbpm_calc, 2)
)

bpm_results <- bpm_results[
  order(-bpm_results$Minutes),
]

print(bpm_results, row.names = FALSE)

cat("
Team BPM adjustment:",
    round(bpm_adjustment, 4), "
")
cat("Team OBPM adjustment:",
    round(obpm_adjustment, 4), "
")
cat("Maximum absolute BPM difference:",
    round(max(abs(okc$bpm_difference)), 3),
    "
")
cat("Mean absolute BPM difference:",
    round(mean(abs(okc$bpm_difference)), 3),
    "
")

write.csv(
  okc,
  "data/cleaned/okc_bpm_calculated.csv",
  row.names = FALSE
)
