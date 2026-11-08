# Data audit | OKC 2024-25 | November 4, 2026

## Confirmed input tables

- `data/raw/basketball_reference/okc_totals.csv`: 19 unique players + one Team Totals row; all 19 players' minutes sum to team total **19,707**; 82 OKC games.
- `data/raw/basketball_reference/okc_per100.csv`: same 19 unique player names; per-100 possession production columns.
- `data/raw/basketball_reference/okc_advanced.csv`: same 19 unique player names + Team Totals; published BPM, OBPM, DBPM for validation only.
- `data/raw/basketball_reference/nba_team_ratings.csv`: **30 NBA teams + League Average**; OKC 68-14, ORtg 120.3, NRtg +12.8; league mean ORtg = 114.5.

**Data provenance**: Basketball-Reference exports for 2024-25. The public repository stores CSV snapshots of the exact tables used by the analysis.

## Salary reconciliation

The supplied salary workbook was transcribed from Salary Sport's 2024 archive and contains 15 active-roster records plus additional contract rows.

The statistical players absent from the initial active-roster salary table include Adam Flagler, Alex Ducas, Alex Reese, Branden Carlson and Malevy Leons. Nikola Topic is retained as a final-roster salary case but has no regular-season playing minutes, so no BPM or MRP is estimated for him.

Useful sources:
- https://salarysport.com/basketball/nba/oklahoma-city-thunder/2024/
- https://www.salaryswish.com/players/adam-flagler
- https://www.salaryswish.com/players/alex-ducas
- https://www.salaryswish.com/players/ajay-mitchell
- https://www.salaryswish.com/players/branden-carlson
- https://hoops-hype-us-east1-664912083968.us-east1.run.app/salaries/teams/oklahoma-city-thunder/25/?season=2024

## Method inputs used in the analysis

- Position and creation-role measures are reconstructed from player production shares and minutes.
- Total BPM and Offensive BPM are calculated from per-100 production, position and creation measures, then adjusted to team ratings.
- DBPM = Total BPM minus Offensive BPM.
- Published Basketball-Reference BPM metrics are used only as a validation reference.
- Player win probability uses a Pythagorean exponent of **14**, league scoring baseline **114.5 per 100**, and replacement probability **0.426**.
- Revenue conversion uses the Berri et al. (2015) current and lagged win coefficients, discounted at **5%**, and scales them using the 2024-25 salary cap relative to the historical cap.
- The replacement-player salary proxy is **$1,157,153**, matching the 2024-25 zero-experience minimum salary used in the report.

## Interpretation caveats

- The calculation uses all statistical players for team-level normalization but the final salary comparison focuses on players who finished the season with OKC.
- Two-way and converted contracts require source reconciliation; the selected salary amounts and source decisions are documented separately.
- Very low minutes produce unstable rate statistics, so the report avoids strong claims about those players.
- The method estimates contribution within the 2024-25 season rather than long-term market value or future potential.
