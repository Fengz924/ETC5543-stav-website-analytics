# Instagram analytical module

Run from the repository root:

```sh
Rscript R/Instagram/instagram_analysis.R
quarto render reports/Instagram/instagram_analysis.qmd
```

The report runs the script itself, so rendering rebuilds every result from source.
On this machine Quarto is at `/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto`.
Dependencies: tidyverse, lubridate, here and knitr, matching the existing R/Quarto approach.

Original files remain unchanged in `data/raw/Meta/Insta/`: Views, Reach, Visits,
Link clicks and Interactions (` - Insta.csv`), plus `Follows - Inta.csv`.
No additional raw folder or duplicate export is created.

Outputs:
- `data/clean/Instagram/instagram_daily.csv`: 365 calendar dates joined by date; missing stays NA.
- `data/analysis/Instagram/instagram_manifest.csv`: source paths, checksums and coverage.
- `instagram_overall.csv`, `instagram_monthly.csv`, `instagram_weekly.csv`: observed-day counts, observed sums and complete-coverage totals.
- `instagram_weekly_long.csv`: full-week metric totals and descriptive IQR flags.
- `instagram_peaks.csv`: monthly peak/low periods, retaining ties.
- `instagram_ga4_comparison.csv`: Instagram monthly results joined to the existing GA4 export when available.
- `reports/figures/Instagram/instagram_monthly.png` and `instagram_weekly.png`.
- `outputs/build/reports/Instagram/instagram_analysis.html`: standalone report.

Reach totals are sums of daily reach, not unique period audiences. Missing Follows
rows are not zeros; partial observed sums are not complete-period totals.
Weeks begin Monday; partial boundary weeks are excluded from period comparisons.
Outlier flags use 1.5 IQR fences and are descriptive, not significance tests.

The GA4 monthly source is reused from the authoritative GA4 report's existing
input because there is no saved validated monthly derived output. It is not copied.
Organic Social cannot isolate Instagram. No existing CRM/GA4 files or project
configuration are modified. The default Quarto render selection stays unchanged. A module-local `reports/Instagram/_quarto.yml` sends this independent report
to the established build location without editing the root configuration.
Generated data and HTML are covered by existing ignore rules; PNGs must be reviewed
before publication. This module does not publish or commit any outputs.
