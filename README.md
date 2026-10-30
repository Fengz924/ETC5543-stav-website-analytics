# STAV CRM and Website Analytics

This project analyses the Science Teachers’ Association of Victoria (STAV)'s CRM records and Google Analytics 4 (GA4) website data. It assesses data quality, school-contact relationships, membership information, website use and measurement limitations to support STAV's decisions.

## Project Scope

The project covers two data sources:

- **CRM:** contact-record quality and completeness, potential duplicate records, school-name standardisation, school-contact relationships and recorded membership information.
- **Google Analytics 4 (GA4):** website traffic acquisition, content use, audience and device patterns, recorded interactions and tracking limitations.

The Shiny dashboard and presentation communicate findings from these two workstreams.
The [final report](reports/final/final_report.qmd) brings the CRM analysis, the GA4
analysis and the dashboard together and is the main submitted deliverable.

## Analysis Periods

- **GA4:** 1 July 2025–30 June 2026. Supplementary path exploration covers 1 August–30 September 2026 and is identified separately in the report.
- **CRM:** export snapshot dated 29 July 2026.

The CRM snapshot and GA4 reporting period describe different units and timeframes. CRM records are not a verified count of unique people, and recorded membership status does not establish engagement. Website interactions do not by themselves establish registrations, memberships or other organisational outcomes.

## Main Deliverables

**Primary submission:** [Final report](reports/final/final_report.qmd) (Quarto, rendered to PDF with Typst).

| Deliverable | What it is | Audience and role |
|---|---|---|
| [Final report](reports/final/final_report.qmd) | Integrated academic report combining the CRM audit, school-name matching, GA4 analysis and the dashboard, with research questions, methods, diagnostics, recommendations and limitations | **Main deliverable** for assessment; reads the outputs of the workstreams below |
| [CRM data preparation and validation](reports/CRM/01_crm_data_preparation.qmd) | Report 01: validated import and preparation of the CRM export | Technical workstream; must run before the CRM analysis |
| [CRM analysis report](reports/CRM/02_crm_analysis_report.qmd) | Report 02: detailed CRM findings for STAV, and the aggregate summaries used by the final report and dashboard | Supporting stakeholder report for STAV |
| [GA4 website analysis report](reports/GA4/stav_website_report.qmd) | Detailed website findings for STAV (traffic, content, audience, events, measurement gaps) | Supporting stakeholder report for STAV |
| [Interactive dashboard](apps/stav-dashboard/README.md) | Shiny app for exploring CRM summaries and GA4 exports with filters, monthly comparison and CSV export | Ongoing tool for STAV staff |
| [Presentation](presentation/README.md) | Quarto slides and speaker notes | Oral presentation |

The CRM and GA4 reports are detailed, stand-alone analyses written for STAV. The
final report is the condensed, integrated version written for assessment: it
frames the work around research questions, adds the matching-rule evaluation
and missingness analysis, and connects the two data sources into one set of
strategic recommendations. The dashboard is a tool rather than a report; the
final report describes its design and functionality.

## Repository Structure

```text
.
├── README.md
├── _quarto.yml
├── ETC5543-stav-website-analytics.Rproj
├── R/
│   ├── CRM/                       # CRM preparation and validation
│   └── ga4/                       # GA4 analysis script
├── reports/
│   ├── final/                     # Final integrated report (main deliverable)
│   ├── CRM/                       # Preparation and analysis reports
│   ├── GA4/                       # Website analysis report
│   └── figures/                   # Report figures
├── presentation/                  # Quarto slides, theme and bundled charts
├── apps/stav-dashboard/           # Shiny app, configuration and demo generator
├── docs/                          # Source definitions and workflow documentation
└── data/
    ├── raw/                       # Private inputs, ignored
    ├── clean/                     # Prepared private data, ignored
    ├── analysis/                  # Derived private data, ignored
    └── example/                   # Fictional example data
```

## Reports and Execution

Use R and Quarto; RStudio is optional. Install the R packages required by each workflow. There is no dependency lockfile, so package versions are not automatically reproduced on another computer.

Start with [reproduction instructions](docs/reproducibility.md) for dependencies,
private-input requirements, execution order and the fictional dashboard demo.
See [data sources](docs/data_sources.md) for the current input contracts.

Run report commands from the repository root with authorised input data present.

### CRM

Prepare and validate the authorised snapshot before running the analysis report.
Report 02 also requires the reviewed organisation mapping; see the
[CRM workflow](docs/CRM/README.md) for that prerequisite.

```sh
quarto render reports/CRM/01_crm_data_preparation.qmd --to html
quarto render reports/CRM/02_crm_analysis_report.qmd --to html
```

See [CRM documentation](docs/CRM/README.md) for the source contract, required inputs and validation rules. A new CRM export may require changes to the source contract and snapshot-specific checks before analysis.
Report 01 regenerates private prepared data and validation outputs; it is not a
read-only check. Report 02 writes summaries and figures without editing the
operational CRM.

### GA4

```sh
quarto render reports/GA4/stav_website_report.qmd
```

The root `_quarto.yml` renders only this GA4 report by default, uses the repository root for execution and writes output under `outputs/build/`.
Request CRM reports explicitly. The presentation has a separate configuration
and writes to `presentation/build/`. Check the output path reported by Quarto;
an existing HTML file beside a QMD may be an earlier build.

The separate script can also be run:

```sh
Rscript R/ga4/GA4_Web_Analytics.R
```

The script and report retain separate analytical implementations; the report reads its own inputs rather than consuming an object produced by the script.

### Final report

Run after the CRM reports, because it reads the CRM summaries written by Report 02,
the validated clean CRM file, the reviewed school-name candidate file and the
GA4 exports:

```sh
quarto render reports/CRM/01_crm_data_preparation.qmd --to html
quarto render reports/CRM/02_crm_analysis_report.qmd --to html
quarto render reports/final/final_report.qmd
```

The report renders to `reports/final/final_report.pdf` using Typst, which is
bundled with Quarto, so no LaTeX installation is needed. It additionally
requires the `naniar` package for the missingness analysis. Bibliography
entries are in `reports/final/references.bib`, and dashboard screenshots are in
`reports/final/figures/`.

### Dashboard

For setup, required packages, input checks and the fictional demonstration mode, see the [dashboard README](apps/stav-dashboard/README.md). Real-data mode requires prepared CRM summaries and GA4 exports. Replacing raw CRM data alone does not refresh the dashboard.

### Presentation

From the repository root:

```sh
cd presentation
quarto render stav_presentation.qmd
```

The presentation is an independent Quarto project. It uses bundled charts and disables code execution, so rendering requires Quarto but does not require R or private datasets. The generated `build/stav_presentation.html` embeds resources for offline use. Running the live Shiny demonstration requires its own R environment and data setup.

## Data Privacy and Reproducibility

Operational CRM records and GA4 exports are excluded from Git using `.gitignore`. Keep private raw, cleaned and derived datasets local. Only approved non-sensitive outputs, sanitised documentation, analysis code and explicitly fictional examples should be shared.

A public clone cannot reproduce real-data findings without authorised inputs. Fictional dashboard fixtures support a separate demonstration; they do not validate the production CRM preparation workflow or reproduce STAV's actual findings.

The source contract and field dictionary are shareable metadata; they do not
authorise sharing other CRM files. Existing blanket CSV/JSON ignore rules can
also hide new non-sensitive fixtures, so review each proposed exception rather
than enabling all data files.

Use [data sources](docs/data_sources.md), [CRM workflow](docs/CRM/README.md) and
[reproduction instructions](docs/reproducibility.md) as the current guides. The
sanitised inventory workbook may describe a broader historical data collection.
