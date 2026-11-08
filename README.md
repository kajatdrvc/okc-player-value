# Price of a Championship

**Player Value and Salary Disparities on the 2024-25 Oklahoma City Thunder**

This repository reproduces the R analysis behind Kaja Todorovic's sports-economics project on player productivity, estimated marginal revenue product (MRP), and salary disparities on the 2024-25 Oklahoma City Thunder.

## What the analysis does

1. Cleans and reconciles 2024-25 OKC salary data.
2. Imports Basketball-Reference player totals, per-100-possession statistics, and advanced statistics.
3. Constructs player position and creation-role measures.
4. Calculates BPM, OBPM and DBPM.
5. Converts player impact into Pythagorean win probability and wins above replacement.
6. Applies the Scully method to estimate marginal revenue product.
7. Compares estimated MRP with reported player salary and produces report/website outputs.

## Reproduce

Open `OKC_Player_Value_A2.Rproj` in RStudio, then run:

```r
source("install_packages.R")
source("R/run_all.R")
```

Generated figures and tables are written to `output/figures/` and `output/tables/`.

## Repository structure

```text
R/                 analysis scripts and run_all.R
data/raw/          CSV source snapshots used by the scripts
data/cleaned/      analysis-ready and intermediate CSV files
documentation/     salary reconciliation/audit notes
output/figures/    generated report and website figures
output/tables/     generated results tables and exports
```

## Notes

The analysis uses reported 2024-25 player salary rather than salary-cap charge. Salary decisions for players with multiple or two-way contracts are documented separately so the final comparison can be audited.

Course lecture notes, assignment briefs, and demonstration materials are not included in this public package.

The public repository stores the source tables as CSV snapshots so the project remains lightweight, transparent, and easy to inspect.
