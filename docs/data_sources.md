# Existing data sources

This document describes existing inputs; it introduces no new workflow.
All operational data are private by default. Obtain them through an authorised
STAV channel; do not commit records, credentials, or private access links.

## Final GA4 analysis and report

Reporting period: 1 July 2025 to 30 June 2026. Preserve export filenames and
place the following files under `data/raw/GA4/`:

| File | View |
| --- | --- |
| traffic_channel_20250701_20260630.csv | Annual acquisition channels |
| traffic_channel_monthly_20250701_20260630.csv | Monthly acquisition channels |
| traffic_source_medium_20250701_20260630.csv | Source/medium |
| landing_page_20250701_20260630.csv | Landing pages |
| pages_screens_page_path_20250701_20260630.csv | Page paths |
| pages_screens_page_path_month_20250701_20260630.csv | Monthly page paths |
| device_category_20250701_20260630.csv | Devices |
| country_20250701_20260630.csv | Countries |
| events_20250701_20260630.csv | Events |

Existing code skips nine export metadata rows and cleans column names with
`janitor`. Inputs must retain the columns expected by the existing code;
substituting a differently structured export is not supported automatically.
Export settings beyond the existing code and source metadata are not fully
documented. No new extraction or validation system is introduced here.

The report additionally includes these private screenshots from the same folder:

- `ga4_sts_path_exploration_aug_sep_2026.png`
- `ga4_homepage_path_exploration_aug_sep_2026.png`

These concern August–September 2026, a supplementary period distinct from the
annual analysis. They are manually exported evidence, not R-generated figures.
Detailed reconstruction settings remain incompletely documented. Review account
identifiers, internal routes, small groups, and other disclosures before sharing.

## Supporting Event analysis

Input: `data/raw/Events/Webinar_Participants_July_2026.xlsx`.
Worksheet: `Webinar Participants`. Existing fields are `Name`,
`Organisation/School`, and `Role/Subjects`. This is a participant-list audit,
not a verified registration/attendance conversion dataset.

The existing audit writes three CSV outputs under `data/clean/Events/`:
`webinar_participants_july_2026_clean.csv`, `event_cleaning_log.csv`, and
`event_output_manifest.csv`. Names are excluded from the analysis-ready output,
but organisation/role combinations can remain identifying. Keep outputs private.

## CRM: authority unresolved

Current sources remain under `reports/CRM/`. They reference
`data/raw/CRM/CRM20260729.csv`, with derived files under `data/clean/CRM/`
and `data/analysis/CRM/`, including restricted record-level outputs.
These locations and files have not been migrated. Confirmation of the
reorganised authoritative CRM version is pending.

`data/example/CRM/crm_contacts_synthetic.csv` is a fictional, one-row schema
illustration. It does not replace the full private import contract.

## Retained supporting and legacy material

The older `reports/ga4_analysis.qmd` references earlier export filenames not
present in the inspected raw folder. It is retained, not selected for default
rendering, and must not be assumed interchangeable with the final GA4 analysis.
Meta and LinkedIn data remain local and ignored; neither is required by the
final GA4 workflow. The inventory workbook in this directory is unchanged and
may describe an earlier stage rather than the current annual GA4 exports.
