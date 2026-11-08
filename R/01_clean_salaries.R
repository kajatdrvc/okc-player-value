# ==================================================
# OKC Player Value Analysis
# Import and Clean Salary Data
# Season: 2024-25
# ==================================================

# Confirm project location
getwd()

# Confirm required source files
files <- c(
  "data/raw/basketball_reference/okc_totals.csv",
  "data/raw/basketball_reference/okc_per100.csv",
  "data/raw/basketball_reference/okc_advanced.csv",
  "data/raw/basketball_reference/nba_team_ratings.csv",
  "data/raw/salaries/okc_2024_25_salaries.csv",
  "data/raw/salaries/okc_2024_25_additional_contracts.csv"
)

data.frame(
  file = basename(files),
  found = file.exists(files)
)

# Import salary data
salaries_raw <- read.csv(
  "data/raw/salaries/okc_2024_25_salaries.csv",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

# Inspect salary structure
str(salaries_raw)

summary(salaries_raw)

# Clean salary records
salaries <- subset(
  salaries_raw,
  season == "2024-25" & !is.na(base_salary_usd)
)

nrow(salaries)
anyDuplicated(salaries$player)

# Import OKC player roster
totals_raw <- read.csv(
  "data/raw/basketball_reference/okc_totals.csv",
  check.names = FALSE
)

okc_players <- subset(
  totals_raw,
  Player != "Team Totals" & !is.na(Player)
)

nrow(okc_players)

# Reconcile roster and salary records
missing_salaries <- setdiff(
  okc_players$Player,
  salaries$player
)
print(missing_salaries)

no_playing_stats <- setdiff(
  salaries$player,
  okc_players$Player
)
print(no_playing_stats)

# Inspect additional contract records
additional_contracts <- read.csv(
  "data/raw/salaries/okc_2024_25_additional_contracts.csv",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

additional_contracts <- subset(
  additional_contracts,
  !is.na(cap_hit_usd)
)

subset(
  additional_contracts,
  player == "Branden Carlson"
)

# Add supplemental salary records
salary_sport_url <- paste0(
  "https://salarysport.com/basketball/nba/",
  "oklahoma-city-thunder/2024/"
)

hoopshype_url <- paste0(
  "https://hoops-hype-us-east1-664912083968.",
  "us-east1.run.app/salaries/teams/",
  "oklahoma-city-thunder/25/?season=2024"
)

new_salaries <- data.frame(
  player = c(
    "Branden Carlson",
    "Adam Flagler",
    "Alex Ducas",
    "Malevy Leons",
    "Alex Reese"
  ),
  season = rep("2024-25", 5),
  base_salary_usd = c(
    717538,
    584412,
    578577,
    126356,
    79804
  ),
  cap_hit_usd = c(
    NA,
    0,
    0,
    126356,
    79804
  ),
  contract_type = c(
    "Multiple contracts / two-way",
    "Two-way",
    "Two-way",
    "Short-term",
    "Short-term"
  ),
  source_url = c(
    hoopshype_url,
    "https://www.salaryswish.com/players/adam-flagler",
    "https://www.salaryswish.com/players/alex-ducas",
    salary_sport_url,
    salary_sport_url
  )
)

salaries_working <- rbind(
  as.data.frame(salaries),
  new_salaries
)

# Define salary and roster status
salaries_working$salary_used_usd <-
  salaries_working$base_salary_usd

salaries_working$salary_used_usd[
  salaries_working$player == "Ajay Mitchell"
] <- 3347451

salaries_working$finished_season <- !(
  salaries_working$player %in%
    c("Malevy Leons", "Alex Reese")
)

salaries_working$analysis_status <- ifelse(
  !salaries_working$finished_season,
  "Left during season",
  ifelse(
    salaries_working$player == "Nikola Topic",
    "Final roster - no games",
    "Final roster - played"
  )
)

salaries_working$salary_review <- ifelse(
  salaries_working$player %in%
    c("Branden Carlson", "Adam Flagler", "Ajay Mitchell"),
  "Review source differences",
  "Standard"
)

# Validate and save salary data
stopifnot(
  nrow(salaries_working) == 20,
  anyDuplicated(salaries_working$player) == 0,
  setequal(
    salaries_working$player,
    c(okc_players$Player, "Nikola Topic")
  )
)

table(salaries_working$analysis_status)
sum(is.na(salaries_working$salary_used_usd))

dir.create(
  "data/cleaned",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  salaries_working,
  "data/cleaned/okc_salaries_working.csv",
  row.names = FALSE
)
