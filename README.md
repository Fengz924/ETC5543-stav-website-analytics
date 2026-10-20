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

## Main Deliverables

- [CRM data preparation and validation](reports/CRM/01_crm_data_preparation.qmd)
- [CRM analysis report](reports/CRM/02_crm_analysis_report.qmd)
- [GA4 website analysis report](reports/GA4/stav_website_report.qmd)
- [Interactive CRM and GA4 dashboard](apps/stav-dashboard/README.md)
- [Presentation and build instructions](presentation/README.md)

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

Run report commands from the repository root with authorised input data present.

### CRM

Prepare and validate the data before running the analysis report:

```sh
quarto render reports/CRM/01_crm_data_preparation.qmd --to html
quarto render reports/CRM/02_crm_analysis_report.qmd --to html
```

See [CRM documentation](docs/CRM/README.md) for the source contract, required inputs and validation rules. A new CRM export may require changes to the source contract and snapshot-specific checks before analysis.

### GA4

```sh
quarto render reports/GA4/stav_website_report.qmd
```

The root `_quarto.yml` renders only this GA4 report by default, uses the repository root for execution and writes output under `outputs/build/`.

The separate script can also be run:

```sh
Rscript R/ga4/GA4_Web_Analytics.R
```

The script and report retain separate analytical implementations; the report reads its own inputs rather than consuming an object produced by the script.

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

See [data sources](docs/data_sources.md), [CRM documentation](docs/CRM/README.md) and [reproducibility notes](docs/reproducibility.md) for additional context. Some historical documentation and files may describe an earlier, broader project scope; the scope stated in this README is the current scope.
