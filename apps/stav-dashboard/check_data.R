# From the repository root: source('apps/stav-dashboard/check_data.R')
local({
  app_dir <- if (file.exists('apps/stav-dashboard/config.R')) {
    normalizePath('apps/stav-dashboard')
  } else if (file.exists('config.R') && file.exists('R/data.R')) {
    normalizePath('.')
  } else stop('Run this script from the repository root or dashboard directory.')
  root <- normalizePath(file.path(app_dir, '../..'))
  config_file <- if (identical(Sys.getenv('STAV_DASHBOARD_MODE'), 'demo')) 'config-demo.R' else 'config.R'
  config <- dget(file.path(app_dir, config_file))
  source(file.path(app_dir, 'R/data.R'), local = TRUE)
  data <- load_dashboard_data(root, config)
  cat('PASS: configured files, required columns, GA4 export dates, month mapping and count checks.\n')
  cat('CRM summary snapshot:', config$crm$snapshot_date, '\n')
  cat('GA4 period:', config$ga4$start_date, 'to', config$ga4$end_date, '\n')
  cat('GA4 traffic rows:', nrow(data$monthly), '; page rows:', nrow(data$pages), '\n')
  cat('This checks prepared inputs; it does not regenerate CRM summaries or verify their source provenance.\n')
})
