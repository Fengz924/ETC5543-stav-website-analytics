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


# ============================================================
# 3. DATA VALIDATION — ANNUAL VS MONTHLY TRAFFIC ACQUISITION
# ============================================================


# ------------------------------------------------------------
# 3.1 Check monthly data structure
# ------------------------------------------------------------

# Confirm that all 12 months are present
monthly %>%
  distinct(date) %>%
  arrange(date)

# Check for duplicate month-channel combinations
monthly %>%
  count(
    date,
    session_primary_channel_group_default_channel_group
  ) %>%
  filter(n > 1)


# ------------------------------------------------------------
# 3.2 Reconcile annual and monthly channel totals
# ------------------------------------------------------------

reconciliation <- channel %>%
  transmute(
    channel =
      session_primary_channel_group_default_channel_group,
    annual_sessions = sessions
  ) %>%
  full_join(
    monthly %>%
      group_by(
        channel =
          session_primary_channel_group_default_channel_group
      ) %>%
      summarise(
        monthly_sum_sessions = sum(sessions),
        .groups = "drop"
      ),
    by = "channel"
  ) %>%
  mutate(
    difference =
      monthly_sum_sessions - annual_sessions,
    difference_pct =
      100 * difference / annual_sessions
  ) %>%
  arrange(desc(abs(difference)))

reconciliation


# ------------------------------------------------------------
# 3.3 Overall reconciliation
# ------------------------------------------------------------

annual_total <- sum(channel$sessions)

monthly_total_check <- sum(monthly$sessions)

total_difference <-
  monthly_total_check - annual_total

total_difference_pct <-
  total_difference / annual_total * 100

annual_total
monthly_total_check
total_difference
total_difference_pct


# ------------------------------------------------------------
# Data validation note
# ------------------------------------------------------------

# Data validation identified a small discrepancy between aggregation
# levels.
#
# Annual Traffic Acquisition export:
# 92,227 sessions
#
# Sum of monthly Traffic Acquisition export:
# 91,715 sessions
#
# Difference:
# -512 sessions (-0.56%)
#
# Checks confirmed that all 12 months were present and that there were
# no duplicate month-channel combinations.
#
# One likely explanation is GA4's use of approximate distinct counting
# for session metrics, combined with differences in query granularity
# when the Month dimension is added. Google notes that session counts
# may use HyperLogLog++ estimation and that discrepancies are generally
# below 1%.
#
# Other GA4 reporting mechanisms, including differences in aggregation,
# attribution, reporting tables, thresholding, or sampling, may also
# contribute to differences between queries. However, the exported data
# do not provide sufficient evidence to identify one specific mechanism
# as the definitive cause.
#
# Analysis decision:
# - Annual export is used for annual channel composition and
#   annual channel-level metrics.
# - Monthly export is used for monthly trends and month-to-month
#   channel changes.
# - Monthly values are not manually adjusted to force agreement
#   with the annual total.
#
# Reference:
# Google Analytics Help – Unique count approximation with HLL++
# https://support.google.com/analytics/answer/13331292


# ============================================================
# 4. MONTHLY WEBSITE TRAFFIC ANALYSIS
# ============================================================


# ------------------------------------------------------------
# 4.1 Calculate total sessions by month
# ------------------------------------------------------------

monthly_total <- monthly %>%
  group_by(date) %>%
  summarise(
    sessions = sum(sessions),
    engaged_sessions = sum(engaged_sessions),
    .groups = "drop"
  ) %>%
  arrange(date)

monthly_total

# Rank months by total sessions
monthly_total %>%
  arrange(desc(sessions))


# ------------------------------------------------------------
# 4.2 Visualise monthly website sessions
# ------------------------------------------------------------

ggplot(
  monthly_total,
  aes(x = date, y = sessions)
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_date(
    date_breaks = "1 month",
    date_labels = "%b\n%Y"
  ) +
  scale_y_continuous(
    labels = scales::comma
  ) +
  labs(
    title = "Monthly Website Sessions",
    subtitle = "STAV, July 2025 – June 2026",
    x = NULL,
    y = "Sessions"
  ) +
  theme_minimal()


# Key observations:
# - Sessions declined from 7,290 in July 2025 to 3,494 in
#   September 2025.
# - Traffic recovered strongly in October 2025 to 8,729 sessions.
# - Traffic increased again from January to February 2026.
# - May 2026 recorded the highest monthly total at 10,559 sessions.
#
# These patterns describe changes in traffic only.
# They should not be attributed to specific STAV campaigns or events
# without additional evidence.


# ============================================================
# 5. MONTHLY CHANNEL ANALYSIS
# ============================================================


# ------------------------------------------------------------
# 5.1 Select major acquisition channels
# ------------------------------------------------------------

monthly_channel <- monthly %>%
  filter(
    session_primary_channel_group_default_channel_group %in%
      c(
        "Direct",
        "Organic Search",
        "Referral",
        "Organic Social"
      )
  )


# Check annual sums from monthly data for selected channels
monthly_channel %>%
  group_by(
    session_primary_channel_group_default_channel_group
  ) %>%
  summarise(
    sessions = sum(sessions),
    .groups = "drop"
  ) %>%
  arrange(desc(sessions))


# ------------------------------------------------------------
# 5.2 Visualise monthly sessions by channel
# ------------------------------------------------------------

ggplot(
  monthly_channel,
  aes(
    x = date,
    y = sessions,
    colour =
      session_primary_channel_group_default_channel_group
  )
) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  scale_x_date(
    date_breaks = "1 month",
    date_labels = "%b\n%Y"
  ) +
  scale_y_continuous(
    labels = scales::comma
  ) +
  labs(
    title = "Monthly Website Sessions by Channel",
    subtitle = "STAV, July 2025 – June 2026",
    x = NULL,
    y = "Sessions",
    colour = "Channel"
  ) +
  theme_minimal()


# ============================================================
# 6. MONTH-TO-MONTH CHANNEL CHANGE
# ============================================================


# ------------------------------------------------------------
# 6.1 Calculate month-to-month changes
# ------------------------------------------------------------

monthly_change <- monthly_channel %>%
  select(
    date,
    channel =
      session_primary_channel_group_default_channel_group,
    sessions
  ) %>%
  arrange(channel, date) %>%
  group_by(channel) %>%
  mutate(
    previous_sessions = lag(sessions),
    change = sessions - previous_sessions,
    pct_change =
      (sessions / previous_sessions - 1) * 100
  ) %>%
  ungroup()

monthly_change %>%
  arrange(date, desc(change)) %>%
  print(n = 48)


# ------------------------------------------------------------
# 6.2 Examine key traffic transitions
# ------------------------------------------------------------

key_month_changes <- monthly_change %>%
  filter(
    date %in% as.Date(c(
      "2025-10-01",
      "2026-01-01",
      "2026-02-01",
      "2026-05-01",
      "2026-06-01"
    ))
  ) %>%
  select(
    date,
    channel,
    sessions,
    previous_sessions,
    change,
    pct_change
  ) %>%
  arrange(date, desc(change))

key_month_changes


# Key observations:
#
# September -> October 2025:
# Direct increased by 2,522 sessions (+202%).
# Organic Search increased by 2,519 sessions (+121%).
# Referral increased by 155 sessions (+122%).
# The October recovery therefore occurred across multiple channels.
#
# January -> February 2026:
# Organic Search increased by 2,182 sessions (+123%).
# Direct increased by 1,954 sessions (+58.9%).
# Referral and Organic Social also increased.
#
# May -> June 2026:
# Direct increased by 816 sessions (+16.2%),
# while Organic Search decreased by 1,648 (-34.1%)
# and Referral decreased by 324 (-53.2%).
#
# Therefore, the overall decline in June masks different movements
# across acquisition channels.
#
# These are descriptive findings only. Additional source/medium,
# landing-page, campaign, and STAV activity data are required before
# attributing the changes to specific causes.


# ============================================================
# 7. LANDING PAGE ANALYSIS
# ============================================================


# ------------------------------------------------------------
# 7.1 Import and clean landing page data
# ------------------------------------------------------------

landing_file <-
  "data/raw/GA4/landing_page_20250701_20260630.csv"

landing <- read_csv(
  landing_file,
  skip = 9,
  show_col_types = FALSE
) %>%
  clean_names()

glimpse(landing)


# ------------------------------------------------------------
# 7.2 Basic data validation
# ------------------------------------------------------------

nrow(landing)

sum(landing$sessions)
sum(landing$active_users)
sum(landing$new_users)

# Check missing values
landing %>%
  summarise(
    missing_landing_page = sum(is.na(landing_page)),
    missing_sessions = sum(is.na(sessions)),
    missing_active_users = sum(is.na(active_users)),
    missing_new_users = sum(is.na(new_users))
  )

# Check duplicate landing-page values
landing %>%
  count(landing_page) %>%
  filter(n > 1)


# ------------------------------------------------------------
# 7.3 Validate row-level sessions against GA4 report total
# ------------------------------------------------------------

# GA4 report-level total shown in the Landing Page report
landing_report_sessions <- 91062

landing_row_sessions <- sum(landing$sessions)

landing_session_difference <-
  landing_row_sessions - landing_report_sessions

landing_session_difference_pct <-
  landing_session_difference /
  landing_report_sessions * 100

landing_row_sessions
landing_report_sessions
landing_session_difference
landing_session_difference_pct


# Data validation note:
#
# The GA4 Landing Page report displayed a report-level total of
# 91,062 sessions, while summing the 1,759 landing-page rows produced
# 91,178 sessions.
#
# Difference = 116 sessions (approximately 0.13%).
#
# No missing landing-page values (NA) or duplicate landing-page rows
# were found.
#
# GA4 report totals and dimension-level rows are not always strictly
# additive. Approximate distinct counting and differences in query
# aggregation may contribute to small discrepancies.
#
# Analysis decision:
# - Use the GA4 report-level total when describing overall sessions.
# - Use row-level values when comparing individual landing pages.
# - Do not manually adjust row-level values to force totals to match.
#
# Active users should NOT be summed across landing-page rows because
# the same user may appear under multiple landing pages across
# different sessions.


# ------------------------------------------------------------
# 7.4 Investigate "(not set)"
# ------------------------------------------------------------

not_set_check <- landing %>%
  filter(landing_page == "(not set)") %>%
  mutate(
    session_share_of_report =
      sessions / landing_report_sessions * 100
  )

not_set_check


# Data-quality finding:
#
# "(not set)" accounted for 6,566 sessions, approximately 7.2% of
# the GA4 report-level session total.
#
# This represents sessions for which GA4 did not populate an
# identifiable landing-page value.
#
# It is retained as a measurement/data-quality finding and excluded
# only when analysing identifiable content landing pages.


# ------------------------------------------------------------
# 7.5 Inspect highest-traffic landing pages
# ------------------------------------------------------------

landing %>%
  arrange(desc(sessions)) %>%
  select(
    landing_page,
    sessions,
    active_users,
    new_users,
    average_engagement_time_per_session
  ) %>%
  print(n = 20)


# ------------------------------------------------------------
# 7.6 Top 15 identifiable landing pages
# ------------------------------------------------------------

top_landing <- landing %>%
  filter(landing_page != "(not set)") %>%
  arrange(desc(sessions)) %>%
  slice_head(n = 15) %>%
  mutate(
    session_share =
      sessions / landing_report_sessions * 100
  ) %>%
  select(
    landing_page,
    sessions,
    session_share,
    active_users,
    new_users,
    average_engagement_time_per_session
  )

top_landing


# ------------------------------------------------------------
# 7.7 Landing-page traffic concentration
# ------------------------------------------------------------

landing_concentration <- landing %>%
  filter(landing_page != "(not set)") %>%
  arrange(desc(sessions)) %>%
  mutate(
    rank = row_number(),
    cumulative_sessions = cumsum(sessions),
    cumulative_share =
      cumulative_sessions / landing_report_sessions * 100
  )

# Examine concentration at selected ranks
landing_concentration_summary <- landing_concentration %>%
  filter(
    rank %in% c(1, 2, 5, 10, 15, 20, 50, 100)
  ) %>%
  select(
    rank,
    landing_page,
    sessions,
    cumulative_sessions,
    cumulative_share
  )

landing_concentration_summary

# ------------------------------------------------------------
# 7.8 Classify landing pages by content type
# Final classification rules
# ------------------------------------------------------------

landing_classified <- landing %>%
  mutate(
    landing_category = case_when(
      
      # Data quality
      landing_page == "(not set)" ~
        "Not set",
      
      # Homepage
      landing_page == "/" ~
        "Homepage",
      
      # Science Talent Search
      str_detect(
        landing_page,
        "science-talent-search|^/sts-"
      ) ~
        "Science Talent Search",
      
      # Events, conferences and workshops
      str_detect(
        landing_page,
        "^/event/|^/events|^/events-calendar|^/workshops|conference|stavcon|call-for-abstracts|submitting-a-session|^/series/"
      ) ~
        "Events & Conferences",
      
      # Publications and educational resources
      str_detect(
        landing_page,
        "^/publications|^/resources|^/stav-publishing|labtalk|conference-resources|teaching-science-journals"
      ) ~
        "Resources & Publications",
      
      # Science programs and initiatives
      str_detect(
        landing_page,
        "science-in-construction|national-science-week"
      ) ~
        "Science Programs & Initiatives",
      
      # Shop / products / cart
      str_detect(
        landing_page,
        "^/shop|^/product|^/product-category|^/cart|^/checkout"
      ) ~
        "Shop",
      
      # Membership
      str_detect(
        landing_page,
        "member|membership"
      ) ~
        "Membership",
      
      # User account / login
      str_detect(
        landing_page,
        "^/my-account|^/login"
      ) ~
        "Account",
      
      # STAV organisational information
      str_detect(
        landing_page,
        "^/about-us|^/our-team|^/contact-us|^/stav-council|^/our-partners|annual-general-meeting"
      ) ~
        "Organisation",
      
      # Forums / community
      str_detect(
        landing_page,
        "^/forums"
      ) ~
        "Forums / Community",
      
      # Direct files
      str_detect(
        landing_page,
        "^/wp-content/uploads/"
      ) ~
        "Files",
      
      # System / preference pages
      str_detect(
        landing_page,
        "^/gh"
      ) ~
        "System / Preferences",
      
      # Everything not clearly classified
      TRUE ~
        "Other"
    )
  )
# ------------------------------------------------------------
# 7.9 Validate landing-page classification
# ------------------------------------------------------------

landing_category_summary <- landing_classified %>%
  group_by(landing_category) %>%
  summarise(
    landing_pages = n(),
    sessions = sum(sessions),
    .groups = "drop"
  ) %>%
  mutate(
    session_share =
      sessions / landing_report_sessions * 100
  ) %>%
  arrange(desc(sessions))

landing_category_summary


# Check that classification has not lost any rows or sessions
classification_check <- tibble(
  original_rows = nrow(landing),
  classified_rows = nrow(landing_classified),
  original_sessions = sum(landing$sessions),
  classified_sessions = sum(landing_classified$sessions)
)

classification_check


# ------------------------------------------------------------
# 7.10 Visualise sessions by landing-page category
# ------------------------------------------------------------

landing_category_plot <- landing_category_summary %>%
  filter(landing_category != "Not set")

ggplot(
  landing_category_plot,
  aes(
    x = reorder(landing_category, sessions),
    y = sessions
  )
) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(
    labels = scales::comma
  ) +
  labs(
    title = "Website Sessions by Landing Page Category",
    subtitle = "STAV, July 2025 – June 2026",
    x = NULL,
    y = "Sessions"
  ) +
  theme_minimal()


