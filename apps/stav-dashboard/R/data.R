# Load existing report inputs once; never read contact-level CRM data.
load_dashboard_data <- function(root, config) {
  crm_dir <- file.path(root, config$crm$summary_dir)
  crm_read <- function(name) readr::read_csv(file.path(crm_dir, paste0('crm_', name, '.csv')), show_col_types = FALSE)
  start <- as.Date(config$ga4$start_date)
  end <- as.Date(config$ga4$end_date)
  if (is.na(start) || is.na(end) || start > end || format(start, '%d') != '01' ||
      end != seq(as.Date(format(end, '%Y-%m-01')), by = 'month', length.out = 2)[2] - 1)
    stop('GA4 period must contain complete calendar months.')
  calendar <- seq(start, as.Date(format(end, '%Y-%m-01')), by = 'month')
  if (anyDuplicated(format(calendar, '%m'))) stop('Month-only exports cannot distinguish repeated months across years.')
  if (is.na(as.Date(config$crm$snapshot_date))) stop('Invalid CRM snapshot date.')
  ga_read <- function(relative_path) {
    path <- file.path(root, relative_path)
    if (!file.exists(path)) stop('Missing GA4 file: ', relative_path)
    header <- readLines(path, n = config$ga4$header_lines, warn = FALSE)
    if (!any(grepl(paste0('# Start date: ', format(start, '%Y%m%d')), header, fixed = TRUE)) ||
        !any(grepl(paste0('# End date: ', format(end, '%Y%m%d')), header, fixed = TRUE)))
      stop('GA4 export dates do not match config: ', relative_path)
    x <- janitor::clean_names(readr::read_csv(path, skip = config$ga4$header_lines, show_col_types = FALSE))
    if (nrow(readr::problems(x))) stop('GA4 parsing problems: ', basename(path))
    x
  }
  monthly <- ga_read(config$ga4$traffic_file)
  needed <- c('session_primary_channel_group_default_channel_group', 'month', 'sessions', 'engaged_sessions')
  if (!all(needed %in% names(monthly))) stop('Missing GA4 traffic columns: ', paste(setdiff(needed, names(monthly)), collapse = ', '))
  names(monthly)[names(monthly) == needed[1]] <- 'channel'
  pages <- ga_read(config$ga4$pages_file)
  if (!all(c('page_path_and_screen_class', 'month', 'views') %in% names(pages))) stop('Missing GA4 page columns.')
  names(pages)[names(pages) == 'page_path_and_screen_class'] <- 'page'
  add_date <- function(x) {
    m <- as.integer(x$month)
    if (anyNA(m) || any(!m %in% 1:12)) stop('Invalid GA4 month')
    x$date <- calendar[match(sprintf('%02d', m), format(calendar, '%m'))]
    if (anyNA(x$date)) stop('GA4 month is outside configured period.')
    x
  }
  monthly <- add_date(monthly)
  pages <- add_date(pages)
  if (anyDuplicated(monthly[c('channel', 'date')])) stop('Duplicate month/channel rows')
  if (anyDuplicated(pages[c('page', 'date')])) stop('Duplicate month/page rows')
  result <- list(overview = crm_read('record_overview'), coverage = crm_read('key_field_coverage'),
       duplicates = crm_read('duplicate_review_categories'), statuses = crm_read('membership_status_counts'),
       plans = crm_read('membership_plan_counts'), reviews = crm_read('membership_review_indicators'),
       schools = crm_read('school_contact_link_review'), roles = crm_read('school_contact_roles'),
       monthly = monthly, pages = pages)
  schemas <- list(overview = c('metric', 'records'), coverage = c('field', 'records_populated', 'coverage'),
    duplicates = c('category', 'records'), statuses = c('status_key', 'records'),
    plans = c('plan', 'records'), reviews = c('Review indicator', 'Records'),
    schools = c('finding', 'count'), roles = c('group_role', 'records', 'share'))
  for (name in names(schemas)) {
    x <- result[[name]]
    if (!all(schemas[[name]] %in% names(x)) || nrow(readr::problems(x))) stop('Invalid CRM summary: ', name)
  }
  if (sum(result$overview$metric == 'Total CRM records') != 1) stop('CRM record total is missing or ambiguous.')
  for (x in list(monthly[c('sessions', 'engaged_sessions')], pages['views'])) {
    if (any(!vapply(x, is.numeric, logical(1))) || anyNA(x) || any(!is.finite(as.matrix(x))) || any(x < 0))
      stop('GA4 counts must be finite non-negative numbers.')
  }
  if (any(monthly$engaged_sessions > monthly$sessions)) stop('Engaged sessions exceed sessions.')
  # Date-bearing CRM review labels must match the configured snapshot.
  review_text <- paste(result$reviews[['Review indicator']], collapse = ' ')
  expected <- paste(as.integer(format(as.Date(config$crm$snapshot_date), '%d')),
                    month.name[as.integer(format(as.Date(config$crm$snapshot_date), '%m'))],
                    format(as.Date(config$crm$snapshot_date), '%Y'))
  if (!grepl(expected, review_text, fixed = TRUE)) stop('CRM review summary date does not match configured snapshot; regenerate summaries first.')
  result
}
traffic_summary <- function(x) {
  dplyr::summarise(dplyr::group_by(x, date), sessions = sum(sessions),
                   engaged_sessions = sum(engaged_sessions), .groups = 'drop')
}
