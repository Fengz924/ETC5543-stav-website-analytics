# Data sources and input contracts

This document describes inputs to the current CRM, GA4 and dashboard workflows.
Operational inputs and derived datasets are private by default. Obtain them
through an authorised STAV channel; do not commit contact records, credentials,
private access links or identifying URL exports.

## CRM snapshot and preparation

Snapshot: **29 July 2026**.

| Input or output | Location | Role |
| --- | --- | --- |
| Original export | `data/raw/CRM/CRM20260729.csv` | Private raw input; preserve source bytes |
| Import contract | `docs/CRM/source_contract.json` | Expected checksum and source schema |
| Field dictionary | `docs/CRM/crm_field_dictionary.csv` | Source/derived definitions and transformations |
| Prepared CSV | `data/clean/CRM/restricted/crm_contacts_clean.csv` | Primary input to Report 02 |
| Canonical import and optional RDS | `data/clean/CRM/restricted/source_import/` | Exact decoded source, traceability and typed convenience copy |
| Preparation evidence | `data/analysis/CRM/01_preparation/` | Aggregate diagnostics and validation metadata |
| CRM analysis summaries | `data/analysis/CRM/02_analysis/` | Report outputs and real-data dashboard inputs |

The source contract is specific to the audited export. Production preparation
expects all 71 declared source fields and the observed quoting dialect. A
new export requires source review; the reduced-schema fictional CRM example
cannot be substituted. Preparation retains 6,051 records; records are not
verified unique people. Selected standalone `No` values are treated as missing
under field-specific conventions confirmed through discussion with STAV staff.

Current reports: `reports/CRM/01_crm_data_preparation.qmd` and
`reports/CRM/02_crm_analysis_report.qmd`. See [CRM workflow](CRM/README.md) for
restricted review outputs and [reproduction](reproducibility.md) for execution.

## Reviewed organisation mapping

The author developed the mapping; Catie provided manual review and feedback.
The default input to `R/crm_organisation_master_mapping.R` is:

```text
data/analysis/CRM/organisation_mapping/restricted/crm_school_name_fuzzy_candidates_review.csv
```

Required columns include `display_name_a`, `display_name_b`, the two
`CH suggest name based on review of Column A/B` fields and the two
`CH suggest Campus A/B` fields. The script writes master, long-form,
provenance, review-issue, conflict, unambiguous and summary tables under
`data/analysis/CRM/organisation_mapping/`. Report 02 reads
`organisation_master_mapping.csv` from that directory.

These private mapping files are not shipped in a public clone. They contain
organisation labels and review information. A reviewed alias is not a verified
person or permission to merge records; mapping outputs have not themselves
updated the operational CRM. Preserve ambiguous aliases and campus issues for
review. The mapping population includes schools and wider organisations.

## GA4 website exports

Annual reporting period: **1 July 2025–30 June 2026**. Place the following
CSV exports under `data/raw/GA4/` without changing their filenames or schemas:

| File | View |
| --- | --- |
| traffic_channel_20250701_20260630.csv | Annual acquisition channels |
| traffic_channel_monthly_20250701_20260630.csv | Monthly acquisition channels |
| traffic_source_medium_20250701_20260630.csv | Source/medium |
| landing_page_20250701_20260630.csv | Landing pages |
| pages_screens_page_path_20250701_20260630.csv | Annual page paths |
| pages_screens_page_path_month_20250701_20260630.csv | Monthly page paths |
| device_category_20250701_20260630.csv | Device categories |
| country_20250701_20260630.csv | Countries |
| events_20250701_20260630.csv | Events |

The report and script skip nine metadata rows and standardise column names.
They expect the existing dimensions and metrics; a differently structured export
is not an automatic replacement. Monthly reports use month numbers, mapped to
the stated year range. The dashboard separately validates the configured period
and does not support repeated month numbers across years in these exports.

CSV headers identify reporting dates and an All Users label, but do not fully
capture extraction timing, reporting identity, filters or sampling/threshold
settings. Totals differ between exported views; retain source-specific
denominators rather than forcing agreement. Active Users are not additive
across dimensions or months. Aggregate event counts do not establish linked
form completion or membership conversion.

### Supplementary path images

The current QMD references these report assets under `reports/figures/`:

- `ga4_sts_path_exploration_aug_sep_2026.png`
- `ga4_homepage_path_exploration_aug_sep_2026.png`

Local source copies also exist under `data/raw/GA4/`; the QMD's image references
use the report-assets location. The images are manually exported evidence,
associated by filenames and report narrative with August–September 2026, a
period distinct from the annual CSVs. The crops do not independently establish
all exploration dates, metric settings or complete path labels. Review these
limitations and any disclosure before using the images in a final report.

## Dashboard inputs and fictional examples

Real-data mode reads eight prepared CRM summary CSVs from the configured
`data/analysis/CRM/02_analysis/` directory and two GA4 monthly exports: traffic
channels and page paths. `apps/stav-dashboard/config.R` specifies their paths
and periods. The app does not read contact-level CRM data or regenerate those
summaries. See the [dashboard README](../apps/stav-dashboard/README.md).

The shareable examples are explicitly fictional:

- `data/example/CRM/crm_contacts_synthetic.csv`: reduced-schema illustration.
- `data/example/dashboard/`: generated fictional contacts, summaries and GA4 tables.
- `data/example/GA4/`: fictional GA4 example tables.

The dashboard generator creates 120 fictional contacts and twelve months of
GA4-style data without reading operational sources. These fixtures demonstrate
interfaces, not real findings or full production preparation. See the
[example README](../data/example/README.md).

## Scope and sharing

The current submission workflow concerns CRM, GA4 and the dashboard, with a
presentation communicating those workstreams. Other local datasets are not
execution dependencies of that workflow. The sanitised inventory workbook in
`docs/` may describe a broader historical collection; it is not a substitute
for the current input contracts above.

Raw, cleaned and analysis data remain ignored by Git. Only reviewed,
non-sensitive documentation, approved assets and fictional examples should be
shared. The source contract and dictionary have explicit ignore exceptions;
that does not make other CSV/JSON files safe to publish.
