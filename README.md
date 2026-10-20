# STAV CRM and Website Analytics

This project analyses the Science Teachers’ Association of Victoria (STAV)'s CRM records and Google Analytics 4 (GA4) website data. It assesses data quality, school-contact relationships, membership information, website use and measurement limitations to support STAV's decisions.

## Project Scope

The project covers two data sources:

- **CRM:** contact-record quality and completeness, potential duplicate records, school-name standardisation, school-contact relationships and recorded membership information.
- **Google Analytics 4 (GA4):** website traffic acquisition, content use, audience and device patterns, recorded interactions and tracking limitations.

The Shiny dashboard and presentation communicate findings from these two workstreams.

## Analysis Periods

- **GA4:** 1 July 2025–30 June 2026. Supplementary path exploration covers 1 August–30 September 2026 and is identified separately in the report.
- **CRM:** export snapshot dated 29 July 2026.

The CRM snapshot and GA4 reporting period describe different units and timeframes. CRM records are not a verified count of unique people, and recorded membership status does not establish engagement. Website interactions do not by themselves establish registrations, memberships or other organisational outcomes.

## Data Privacy

STAV operational data may contain confidential or sensitive information.

Raw datasets and platform exports are excluded from this repository using `.gitignore`.

Only sanitised documentation, reproducible analysis code, and approved non-sensitive outputs will be committed.

## Project Status

The main university component focuses on GA4 website analytics. The authoritative
GA4 files are `R/ga4/GA4_Web_Analytics.R` and `reports/final_report.qmd`.
They currently retain their separate analytical implementations.

The Event audit is supporting analysis. CRM authority is unresolved: the files
under `reports/CRM/` remain unchanged pending confirmation of the reorganised
version. No presentation source has been identified or added. Meta and LinkedIn
remain potential separate STAV deliverables rather than prerequisites for the
GA4 report. No project software licence has been added yet.

## Repository Structure

```text
.
├── README.md
├── .gitignore
├── _quarto.yml
├── ETC5543-stav-website-analytics.Rproj
├── R/ga4/GA4_Web_Analytics.R
├── reports/
│   ├── final_report.qmd
│   ├── supporting/event_analysis.qmd
│   ├── CRM/                       # Authority awaiting confirmation
│   ├── ga4_analysis.qmd           # Legacy GA4 audit retained
│   ├── ga4_analysis.html          # Existing output retained
│   ├── ga4_analysis_files/        # Existing support assets retained
│   └── event_analysis.html        # Existing output retained
├── docs/
│   ├── STAV_Master_Data_Inventory_Sanitized.xlsx
│   ├── data_sources.md
│   └── reproducibility.md
└── data/
    ├── raw/                       # Local, ignored
    ├── clean/                     # Local, ignored
    ├── analysis/                  # Local, ignored
    └── example/CRM/crm_contacts_synthetic.csv
```

Quarto creates ignored `outputs/build/` when rendering. Empty presentation,
asset, and final-output directories are not included.

## Software and Execution

Use R and Quarto. RStudio is optional. Existing code uses `tidyverse`, `janitor`,
`lubridate`, `here`, `readxl`, `knitr`, `scales`, and `forcats` across the project.
No dependency lockfile is provided. The tested environment and render warnings
are recorded in `docs/reproducibility.md`.

Run commands from the repository root, with authorised input data present:

```bash
Rscript R/ga4/GA4_Web_Analytics.R
quarto render reports/final_report.qmd
```

The script displays analytical summaries and plots; it does not supply an input
object to the report. The report independently reads the same GA4 exports.
`_quarto.yml` sets project-root execution and sends rendered output to
`outputs/build/`. The report's existing format is HTML; PDF rendering is not
configured. Build outputs are private review artifacts, not approved publications.

The supporting Event audit can be rendered separately:

```bash
quarto render reports/supporting/event_analysis.qmd
```

It requires the private participant workbook and writes cleaned CSVs under
`data/clean/Events/`. Review its rendered participant-level information before
sharing. The default project render list includes only the final GA4 report.
Presentation rendering instructions await an authoritative source.

## Confidential Data and Reproducibility

The original STAV datasets are not included because they may contain
confidential, identifying or commercially sensitive information. Keep raw,
cleaned, and analysis datasets local and ignored. Their existing component
folder names (`GA4`, `CRM`, `Events`) are preserved.

See [data sources](docs/data_sources.md) for required inputs and
[reproducibility instructions](docs/reproducibility.md) for workflow details.
Authorised users must obtain private inputs separately; a public clone alone
cannot reproduce real-data results.

Analysis code retains relevant variable names to document methodology. The
allowlisted CRM example contains fictional values and illustrates structure;
it is not a complete runnable replacement for the private CRM export. No
synthetic GA4 workflow is introduced in this migration.

Existing legacy HTML and historical versions remain in Git. Ignore rules do
not remove already tracked files or history. Their presence does not establish
publication clearance. Screenshots and rendered findings also require review
before sharing. The inventory workbook is retained unchanged and may describe
an earlier project stage.
