# ============================================================
# STAV WEBSITE ANALYTICS
# Reporting period: 1 July 2025 – 30 June 2026
# ============================================================


# ============================================================
# 0. SETUP
# ============================================================

library(tidyverse)
library(janitor)


# ============================================================
# 1. TRAFFIC ACQUISITION — ANNUAL CHANNEL ANALYSIS
# ============================================================


# ------------------------------------------------------------
# 1.1 Import and clean annual channel data
# ------------------------------------------------------------

channel <- read_csv(
  "data/raw/GA4/traffic_channel_20250701_20260630.csv",
  skip = 9,
  show_col_types = FALSE
) %>%
  clean_names()

glimpse(channel)


# ------------------------------------------------------------
# 1.2 Calculate annual channel shares
# ------------------------------------------------------------

channel_summary <- channel %>%
  mutate(
    session_share = sessions / sum(sessions),
    engaged_session_share =
      engaged_sessions / sum(engaged_sessions)
  ) %>%
  arrange(desc(sessions))

channel_summary %>%
  select(
    session_primary_channel_group_default_channel_group,
    sessions,
    session_share,
    engaged_sessions,
    engagement_rate,
    average_engagement_time_per_session
  )


# Key finding:
# Direct generated the largest share of website sessions (50.6%),
# followed by Organic Search (43.5%).
#
# However, Organic Search showed substantially stronger engagement,
# with a 59.3% engagement rate compared with 29.2% for Direct.


# ------------------------------------------------------------
# 1.3 Visualise annual sessions by channel
# ------------------------------------------------------------

ggplot(
  channel_summary,
  aes(
    x = reorder(
      session_primary_channel_group_default_channel_group,
      sessions
    ),
    y = sessions
  )
) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "STAV Website Sessions by Channel",
    subtitle = "1 July 2025 – 30 June 2026",
    x = NULL,
    y = "Sessions"
  ) +
  theme_minimal()


# ============================================================
# 2. TRAFFIC ACQUISITION — MONTHLY DATA
# ============================================================


# ------------------------------------------------------------
# 2.1 Import and clean monthly channel data
# ------------------------------------------------------------

monthly <- read_csv(
  "data/raw/GA4/traffic_channel_monthly_20250701_20260630.csv",
  skip = 9,
  show_col_types = FALSE
) %>%
  clean_names()

glimpse(monthly)


# ------------------------------------------------------------
# 2.2 Create calendar dates
# ------------------------------------------------------------

# The reporting period covers July 2025 to June 2026.
# GA4 exported Month as month number only.
#
# Therefore:
# 07–12 = 2025
# 01–06 = 2026

monthly <- monthly %>%
  mutate(
    month_num = as.integer(month),
    year = if_else(month_num >= 7, 2025L, 2026L),
    date = ymd(sprintf("%d-%02d-01", year, month_num))
  )

# Check date mapping
monthly %>%
  select(
    session_primary_channel_group_default_channel_group,
    month,
    year,
    date,
    sessions
  ) %>%
  arrange(date) %>%
  print(n = 20)


