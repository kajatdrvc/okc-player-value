# ==================================================
# OKC Player Value Analysis
# 03 - Player Position and Creation Role
# Season: 2024-25
# ==================================================

okc <- read.csv(
  "data/cleaned/okc_player_data_working.csv",
  check.names = FALSE
)

required <- c(
  "Player", "adv_Pos", "total_MP", "total_TRB",
  "total_AST", "total_STL", "total_BLK",
  "total_PF", "total_FGA", "total_FTA",
  "total_PTS"
)

stopifnot(
  all(required %in% names(okc)),
  nrow(okc) == 19,
  sum(okc$total_MP) == 19707
)

minutes <- okc$total_MP

clamp <- function(x) {
  pmax(1, pmin(5, x))
}

stat_share <- function(x) {
  (x / sum(x)) /
    (minutes / sum(minutes)) / 5
}

recenter_twice <- function(x) {
  shift1 <- weighted.mean(clamp(x), minutes) - 3
  first <- clamp(x - shift1)
  shift2 <- weighted.mean(first, minutes) - 3
  clamp(x - shift1 - shift2)
}

position_codes <- c(
  PG = 1, SG = 2, SF = 3, PF = 4, C = 5
)

okc$listed_position <- unname(
  position_codes[okc$adv_Pos]
)

stopifnot(!anyNA(okc$listed_position))

okc$share_trb <- stat_share(okc$total_TRB)
okc$share_ast <- stat_share(okc$total_AST)
okc$share_stl <- stat_share(okc$total_STL)
okc$share_blk <- stat_share(okc$total_BLK)
okc$share_pf  <- stat_share(okc$total_PF)

okc$position_raw <-
  2.13 +
  8.668 * okc$share_trb -
  3.536 * okc$share_ast -
  2.486 * okc$share_stl +
  1.667 * okc$share_blk +
  0.992 * okc$share_pf

okc$position_regressed <- (
  minutes * okc$position_raw +
    50 * okc$listed_position
) / (minutes + 50)

okc$position_final <- recenter_twice(
  okc$position_regressed
)

team_points_per_shot <- sum(okc$total_PTS) /
  (
    sum(okc$total_FGA) +
      0.44 * sum(okc$total_FTA)
  )

okc$threshold_points <-
  okc$total_PTS -
  (team_points_per_shot - 0.33) *
  (
    okc$total_FGA +
      0.44 * okc$total_FTA
  )

okc$share_threshold <-
  (okc$threshold_points /
     sum(okc$threshold_points)) /
  (minutes / sum(minutes)) / 5

okc$creation_raw <-
  6 -
  6.642 * okc$share_ast -
  8.544 * okc$share_threshold

okc$creation_regressed <- (
  minutes * okc$creation_raw +
    50 * 4
) / (minutes + 50)

okc$creation_final <- recenter_twice(
  okc$creation_regressed
)

stopifnot(
  all(is.finite(okc$position_final)),
  all(is.finite(okc$creation_final)),
  all(okc$position_final >= 1 &
        okc$position_final <= 5),
  all(okc$creation_final >= 1 &
        okc$creation_final <= 5)
)

cat("Team points per shot:",
    round(team_points_per_shot, 4), "
")

cat("Weighted average position:",
    round(weighted.mean(
      okc$position_final, minutes
    ), 4), "
")

cat("Weighted average creation:",
    round(weighted.mean(
      okc$creation_final, minutes
    ), 4), "
")

position_creation_results <- data.frame(
  Player = okc$Player,
  Minutes = okc$total_MP,
  Position = round(okc$position_final, 2),
  Creation = round(okc$creation_final, 2)
)

position_creation_results <-
  position_creation_results[
    order(-position_creation_results$Minutes),
  ]

print(position_creation_results, row.names = FALSE)

write.csv(
  okc,
  "data/cleaned/okc_position_creation.csv",
  row.names = FALSE
)
