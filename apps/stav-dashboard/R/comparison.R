# Calendar-month comparisons never substitute a missing month with zero.
month_pair <- function(x, month) {
  current <- as.Date(month)
  previous <- seq(current, by = '-1 month', length.out = 2)[2]
  list(current = x[x$date == current, , drop = FALSE],
       previous = x[x$date == previous, , drop = FALSE],
       label = paste(format(current, '%Y-%m'), 'vs', format(previous, '%Y-%m')))
}
relative_change <- function(current, previous) {
  if (!is.finite(current) || !is.finite(previous)) return('Unavailable')
  if (previous == 0) return('Unavailable — previous month is zero')
  sprintf('%+.1f%% vs previous month', 100 * (current - previous) / previous)
}
