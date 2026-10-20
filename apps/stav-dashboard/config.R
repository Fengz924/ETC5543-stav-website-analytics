# Edit this file when using a new set of prepared data.
# All paths are relative to the repository root.
list(
  title = 'STAV Insights Dashboard',
  crm = list(
    summary_dir = 'data/analysis/CRM/02_analysis',
    snapshot_date = '2026-07-29'
  ),
  ga4 = list(
    start_date = '2025-07-01',
    end_date = '2026-06-30',
    traffic_file = 'data/raw/GA4/traffic_channel_monthly_20250701_20260630.csv',
    pages_file = 'data/raw/GA4/pages_screens_page_path_month_20250701_20260630.csv',
    header_lines = 9L
  )
)
