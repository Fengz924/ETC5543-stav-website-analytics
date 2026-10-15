# Fully fictional dashboard fixture. Never reads operational STAV data.
# Run from repository root: source('apps/stav-dashboard/demo/generate_data.R')
local({
  if (!file.exists('apps/stav-dashboard/config.R')) stop('Run from repository root.')
  out <- 'data/example/dashboard'
  dir.create(file.path(out, 'crm'), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(out, 'ga4'), recursive = TRUE, showWarnings = FALSE)
  n <- 120L
  i <- seq_len(n)
  # Deterministic inputs: no random seed, private files or copied real names.
  raw <- data.frame(
    id = sprintf('DEMO-%03d', i),
    full_name = paste(' Fictional Contact ', ceiling(i / 2)),
    email = sprintf('demo%03d@example.invalid', i),
    organisation = ifelse(i %% 5 == 0, '', paste(' Fictional School ', i %% 9 + 1)),
    phone = ifelse(i %% 3 == 0, '', sprintf('DEMO-PHONE-%03d', i)),
    status = rep(c('Active', 'Expired', 'Cancelled', ''), length.out = n),
    plan = rep(c('School Group', 'Individual', 'Student', '', 'Individual'), length.out = n),
    end_date = ifelse(i %% 3 == 0, '2026-06-30', '2027-06-30'),
    role = rep(c('Group Admin only', 'Group Member only', 'Both', 'Neither'), length.out = n)
  )
  write.csv(raw, file.path(out, 'fictional_contacts_raw.csv'), row.names = FALSE)
  clean <- raw
  clean[] <- lapply(clean, trimws)
  clean$status <- tolower(clean$status)
  clean$end_date <- as.Date(clean$end_date)
  write.csv(clean, file.path(out, 'fictional_contacts_clean.csv'), row.names = FALSE)
  save_summary <- function(name, x) write.csv(x, file.path(out, 'crm', paste0('crm_', name, '.csv')), row.names = FALSE, na = '')
  count_values <- function(x, column) {
    t <- as.data.frame(table(x[nzchar(x)]), stringsAsFactors = FALSE)
    names(t) <- c(column, 'records'); t
  }
  save_summary('record_overview', data.frame(metric = 'Total CRM records', records = n))
  fields <- c('email', 'full_name', 'organisation', 'phone', 'status', 'plan')
  counts <- vapply(clean[fields], function(x) sum(nzchar(x)), integer(1))
  save_summary('key_field_coverage', data.frame(field = fields, records_populated = counts, coverage = counts/n))
  same_name <- duplicated(clean$full_name) | duplicated(clean$full_name, fromLast = TRUE)
  save_summary('duplicate_review_categories', data.frame(category = 'Same name only — fictional demonstration', records = sum(same_name)))
  save_summary('membership_status_counts', count_values(clean$status, 'status_key'))
  save_summary('membership_plan_counts', count_values(clean$plan, 'plan'))
  save_summary('membership_review_indicators', data.frame(
    'Review indicator' = c('Membership plan recorded but no membership status',
      'Membership status recorded but no membership plan',
      'Active status with subscription end date before 29 July 2026'),
    Records = c(sum(nzchar(clean$plan) & !nzchar(clean$status)),
      sum(nzchar(clean$status) & !nzchar(clean$plan)),
      sum(clean$status == 'active' & clean$end_date < as.Date('2026-07-29'))), check.names = FALSE))
  school <- clean[clean$plan == 'School Group', ]
  save_summary('school_contact_link_review', data.frame(finding = 'School-plan records without organisation information', count = sum(!nzchar(school$organisation))))
  roles <- count_values(school$role, 'group_role'); roles$share <- roles$records/nrow(school)
  save_summary('school_contact_roles', roles)
  dates <- seq(as.Date('2025-07-01'), by = 'month', length.out = 12)
  traffic <- expand.grid(channel = c('Direct', 'Organic Search', 'Referral'), index = seq_along(dates), stringsAsFactors = FALSE)
  traffic$sessions <- 100 + traffic$index * 17 + match(traffic$channel, unique(traffic$channel)) * 23
  traffic$engaged <- floor(traffic$sessions * c(.3, .6, .5)[match(traffic$channel, unique(traffic$channel))])
  traffic_out <- data.frame(traffic$channel, format(dates[traffic$index], '%m'), traffic$sessions, traffic$engaged)
  names(traffic_out) <- c('Session primary channel group (Default Channel Group)', 'Month', 'Sessions', 'Engaged sessions')
  pages <- expand.grid(page = c('/', '/fictional-events/', '/fictional-resources/', '/fictional-membership/'), index = seq_along(dates), stringsAsFactors = FALSE)
  pages_out <- data.frame(pages$page, format(dates[pages$index], '%m'), 200 + pages$index * 19 + match(pages$page, unique(pages$page)) * 31)
  names(pages_out) <- c('Page path and screen class', 'Month', 'Views')
  export_ga4 <- function(name, x) {
    path <- file.path(out, 'ga4', name)
    writeLines(c('# FICTIONAL DEMO DATA', '# Not an actual GA4 export', '# No STAV operational data', '# Deterministic fixture', '# Generated locally', '# All demonstration rows', '# Monthly aggregates', '# Start date: 20250701', '# End date: 20260630'), path)
    suppressWarnings(write.table(x, path, sep = ',', row.names = FALSE, col.names = TRUE, append = TRUE, quote = TRUE))
  }
  export_ga4('traffic.csv', traffic_out)
  export_ga4('pages.csv', pages_out)
  cat('Created fictional raw/clean contacts, CRM summaries and GA4 fixtures in', out, '\n')
})
