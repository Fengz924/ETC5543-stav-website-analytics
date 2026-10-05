# STAV Data Analytics Project

A data analytics project exploring STAV's digital, CRM and event data to assess data quality, understand engagement patterns and generate evidence-based marketing and member insights.

## Project Overview

The overall goal of this project is to develop a clearer understanding of STAV's data landscape and establish a foundation for evidence-based marketing and member engagement decisions.


### Phase 1 — Understand the Data

Identify what data exists, where it is stored, how it is structured, and how reliable and usable it is.

Key activities include:

* identifying and documenting available data sources
* understanding key variables, metrics and data structures
* assessing data completeness, consistency and quality
* identifying tracking and measurement limitations
* evaluating the usability of each data source for future analysis

### Phase 2 — Use the Data

Use reliable and relevant data sources to generate meaningful insights that can support STAV's marketing and member engagement decisions.

Potential areas of analysis include:

* website traffic and user engagement
* traffic acquisition and channel performance
* website content performance
* social media performance
* event engagement
* member and CRM engagement
* cross-platform marketing performance

## Data Sources

The project currently considers data from:

* Google Analytics 4 (GA4)
* Meta
* LinkedIn
* CRM
* Events

## Analysis Period

Where possible, analysis will use a consistent 12-month period:

**1 July 2025 – 30 June 2026**

This provides a consistent basis for comparing performance across different data sources.

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
