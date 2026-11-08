# ==================================================
# Report and Website Outputs
# OKC 2024-25
# Graph: Estimated MRP minus salary
# ==================================================

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}

library(ggplot2)

comparison <- read.csv(
  "data/cleaned/okc_final_salary_mrp_final.csv"
)

report_table <- data.frame(
  Player = comparison$player,
  Minutes = comparison$total_MP,
  BPM = round(comparison$bpm_calc, 2),
  Wins = round(comparison$wins_above_replacement, 2),
  MRP_M = round(comparison$mrp_usd / 1e6, 2),
  Salary_M = round(comparison$salary_used_usd / 1e6, 2),
  Gap_M = round(comparison$mrp_salary_gap / 1e6, 2)
)

dir.create(
  "output/figures",
  recursive = TRUE,
  showWarnings = FALSE
)

dir.create(
  "output/tables",
  recursive = TRUE,
  showWarnings = FALSE
)

write.csv(
  report_table,
  "output/tables/okc_report_table_working.csv",
  row.names = FALSE
)

plot_data <- subset(
  comparison,
  !is.na(mrp_salary_gap) & total_MP >= 750
)

plot_data$gap_m <- plot_data$mrp_salary_gap / 1e6

plot_data$group <- ifelse(
  plot_data$gap_m >= 0,
  "MRP exceeds salary",
  "Salary exceeds MRP"
)

plot_data$player <- reorder(
  plot_data$player,
  plot_data$gap_m
)

stopifnot(nrow(plot_data) == 11)

base_plot <- ggplot(
  plot_data,
  aes(
    x = gap_m,
    y = player,
    fill = group
  )
) +
  geom_vline(
    xintercept = 0,
    color = "#837970",
    linewidth = 0.5
  ) +
  geom_col(
    width = 0.7
  ) +
  labs(
    title = "Estimated MRP minus salary",
    subtitle = paste(
      "2024-25 Oklahoma City Thunder",
      "| Players with at least 750 minutes"
    ),
    x = "MRP minus salary (USD millions)",
    y = NULL,
    fill = NULL
  )

report_colours <- c(
  "MRP exceeds salary" = "#B58070",
  "Salary exceeds MRP" = "#9B8B7C"
)

website_colours <- c(
  "MRP exceeds salary" = "#C48B75",
  "Salary exceeds MRP" = "#A99A8A"
)

report_bg <- "#FFFFFF"
website_bg <- "#0F0D0C"

report_theme <- theme_minimal(
  base_size = 11,
  base_family = "sans"
) +
  theme(
    plot.background = element_rect(fill = report_bg, color = NA),
    panel.background = element_rect(fill = report_bg, color = NA),
    legend.background = element_rect(fill = report_bg, color = NA),
    legend.key = element_rect(fill = report_bg, color = NA),
    text = element_text(color = "#33302D"),
    plot.title = element_text(
      size = 15, face = "bold", color = "#292624",
      margin = margin(b = 7)
    ),
    plot.subtitle = element_text(
      size = 10, color = "#706A65",
      margin = margin(b = 16)
    ),
    axis.text = element_text(color = "#504B47", size = 9.5),
    axis.title.x = element_text(
      color = "#504B47", size = 10,
      margin = margin(t = 10)
    ),
    plot.caption = element_text(
      color = "#807A75", size = 8, hjust = 0,
      margin = margin(t = 16)
    ),
    panel.grid.major.x = element_line(
      color = "#EEEAE6", linewidth = 0.35
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.text = element_text(color = "#504B47", size = 9),
    plot.margin = margin(20, 24, 18, 18)
  )

website_theme <- theme_minimal(
  base_size = 11,
  base_family = "sans"
) +
  theme(
    plot.background = element_rect(fill = website_bg, color = NA),
    panel.background = element_rect(fill = website_bg, color = NA),
    legend.background = element_rect(fill = website_bg, color = NA),
    legend.key = element_rect(fill = website_bg, color = NA),
    text = element_text(color = "#EAE0D3"),
    plot.title = element_text(
      size = 15, face = "bold", color = "#F1E7DA",
      margin = margin(b = 7)
    ),
    plot.subtitle = element_text(
      size = 10, color = "#B8A99A",
      margin = margin(b = 16)
    ),
    axis.text = element_text(color = "#D2C3B3", size = 9.5),
    axis.title.x = element_text(
      color = "#D2C3B3", size = 10,
      margin = margin(t = 10)
    ),
    plot.caption = element_text(
      color = "#A89989", size = 8, hjust = 0,
      margin = margin(t = 16)
    ),
    panel.grid.major.x = element_line(
      color = "#38302B", linewidth = 0.35
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    legend.position = "bottom",
    legend.text = element_text(color = "#D2C3B3", size = 9),
    plot.margin = margin(20, 24, 18, 18)
  )

p_report <- base_plot +
  scale_fill_manual(values = report_colours) +
  report_theme

p_website <- base_plot +
  scale_fill_manual(values = website_colours) +
  website_theme

ggsave(
  filename = "output/figures/okc_mrp_salary_gap_report.png",
  plot = p_report,
  width = 9,
  height = 6,
  units = "in",
  dpi = 300,
  bg = report_bg
)

ggsave(
  filename = "output/figures/okc_mrp_salary_gap_website.png",
  plot = p_website,
  width = 9,
  height = 6,
  units = "in",
  dpi = 300,
  bg = website_bg
)

print(p_report)
print(p_website)

cat("
Both graph versions saved successfully.
")
