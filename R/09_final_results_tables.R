# ==================================================
# Final Results Tables
# 2024-25 Oklahoma City Thunder
# Report and Website Versions
# ==================================================

library(grid)

comparison <- read.csv(
  "data/cleaned/okc_final_salary_mrp_final.csv",
  stringsAsFactors = FALSE
)

stopifnot(
  nrow(comparison) == 18,
  sum(is.na(comparison$mrp_usd)) == 1
)

comparison <- comparison[
  order(
    -comparison$mrp_salary_gap,
    na.last = TRUE
  ),
]

fmt_number <- function(x, digits = 2) {
  ifelse(
    is.na(x),
    "N/A",
    sprintf(paste0("%.", digits, "f"), x)
  )
}

fmt_millions <- function(x) {
  fmt_number(x / 1e6)
}

fmt_gap <- function(x) {
  ifelse(
    is.na(x),
    "N/A",
    sprintf("%+.2f", x / 1e6)
  )
}

table_data <- data.frame(
  Player = comparison$player,
  Minutes = ifelse(
    is.na(comparison$total_MP),
    "N/A",
    as.character(comparison$total_MP)
  ),
  BPM = fmt_number(comparison$bpm_calc),
  WAR = fmt_number(
    comparison$wins_above_replacement
  ),
  MRP = fmt_millions(comparison$mrp_usd),
  Salary = fmt_millions(
    comparison$salary_used_usd
  ),
  Gap = fmt_gap(comparison$mrp_salary_gap),
  stringsAsFactors = FALSE
)

dir.create(
  "output/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  comparison,
  "output/tables/okc_final_results_data.csv",
  row.names = FALSE
)

report_style <- list(
  bg = "#FFFFFF",
  text = "#302B27",
  muted = "#786F68",
  header = "#4F4039",
  stripe = "#F8F6F4",
  line = "#E8E2DD",
  positive = "#A36E5C",
  negative = "#75665C"
)

website_style <- list(
  bg = "#0F0D0C",
  text = "#EAE0D3",
  muted = "#B4A597",
  header = "#F1E7DA",
  stripe = "#191513",
  line = "#332A25",
  positive = "#C48B75",
  negative = "#B3A091"
)

draw_results_table <- function(
    table_data,
    style,
    filename
) {
  png(
    filename = filename,
    width = 3200,
    height = 2500,
    res = 300,
    bg = style$bg
  )

  grid.newpage()

  grid.rect(
    gp = gpar(
      fill = style$bg,
      col = NA
    )
  )

  grid.text(
    "OKC player value and salary",
    x = 0.04,
    y = 0.965,
    just = "left",
    gp = gpar(
      col = style$text,
      fontsize = 16,
      fontface = "bold"
    )
  )

  grid.text(
    "2024-25 Oklahoma City Thunder | Regular season",
    x = 0.04,
    y = 0.932,
    just = "left",
    gp = gpar(
      col = style$muted,
      fontsize = 10
    )
  )

  xs <- c(
    0.04, 0.46, 0.54, 0.62,
    0.73, 0.85, 0.96
  )

  headers <- c(
    "Player",
    "Minutes",
    "BPM",
    "WAR",
    "MRP ($M)",
    "Salary ($M)",
    "Gap ($M)"
  )

  for (j in seq_along(headers)) {
    grid.text(
      headers[j],
      x = xs[j],
      y = 0.882,
      just = if (j == 1) "left" else "right",
      gp = gpar(
        col = style$header,
        fontsize = 9,
        fontface = "bold"
      )
    )
  }

  grid.lines(
    x = c(0.04, 0.96),
    y = c(0.858, 0.858),
    gp = gpar(
      col = style$line,
      lwd = 1.1
    )
  )

  row_y <- seq(
    from = 0.835,
    to = 0.115,
    length.out = nrow(table_data)
  )

  for (i in seq_len(nrow(table_data))) {
    if (i %% 2 == 0) {
      grid.rect(
        x = 0.5,
        y = row_y[i],
        width = 0.94,
        height = 0.039,
        gp = gpar(
          fill = style$stripe,
          col = NA
        )
      )
    }

    grid.text(
      table_data$Player[i],
      x = xs[1],
      y = row_y[i],
      just = "left",
      gp = gpar(
        col = style$text,
        fontsize = 9
      )
    )

    values <- unlist(
      table_data[i, 2:7],
      use.names = FALSE
    )

    for (j in seq_along(values)) {
      text_colour <- style$text

      if (j == 6) {
        gap <- comparison$mrp_salary_gap[i]

        if (!is.na(gap)) {
          text_colour <- if (gap >= 0) {
            style$positive
          } else {
            style$negative
          }
        }
      }

      grid.text(
        values[j],
        x = xs[j + 1],
        y = row_y[i],
        just = "right",
        gp = gpar(
          col = text_colour,
          fontsize = 9,
          fontface = if (j == 6) "bold" else "plain"
        )
      )
    }
  }

  dev.off()
}

draw_results_table(
  table_data = table_data,
  style = report_style,
  filename = paste0(
    "output/tables/",
    "okc_player_value_report.png"
  )
)

draw_results_table(
  table_data = table_data,
  style = website_style,
  filename = paste0(
    "output/tables/",
    "okc_player_value_website.png"
  )
)

cat(
  "
Both final table versions saved successfully.
"
)

cat(
  "Players included:",
  nrow(table_data),
  "
"
)
