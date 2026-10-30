# Reproducing the current project

This guide covers the CRM, GA4 website analysis, Shiny dashboard, presentation
and the final integrated report. Run commands from the repository root unless
stated otherwise. The CRM and GA4 reports are supporting component reports; the
final report in `reports/final/` is the main deliverable.

## Environment

Use R, Python 3 and Quarto. RStudio is optional. Python is used for CRM import
validation; the dashboard and presentation do not require Python. Quarto is
needed to render reports and slides, but not to run the Shiny app.

Install the R packages used by the current CRM, GA4 and dashboard sources:

```r
install.packages(c(
  "tidyverse", "janitor", "lubridate", "here", "jsonlite", "knitr",
  "shiny", "bslib", "DT", "scales", "naniar"
))
```

`tidyverse` supplies packages including `readr`, `dplyr`, `stringr`, `purrr`,
`tibble`, `tidyr`, `ggplot2` and `forcats`. No `renv.lock` or other complete
version lock is provided. Package installation alone is not a guarantee of
identical results on another environment. Record `sessionInfo()` and
`quarto --version` when validating a build. The presentation can render from
its bundled images without R or private data.

If `quarto` is not on the shell PATH, locate the installed executable. On the
current macOS machine, RStudio includes it at:

```text
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto
```

This is an installation-specific fallback, not a required project path.

## Inputs and access

See [data sources](data_sources.md) for the required files, periods and schemas.
Operational data under `data/raw/`, `data/clean/` and `data/analysis/` remain
private and Git-ignored. Obtain them through an authorised STAV channel.
The public source repository cannot reproduce real-data findings without
those inputs. Do not substitute fictional fixtures for the production CRM
source contract.

## 1. CRM preparation and analysis

The current component reports are:

1. `reports/CRM/01_crm_data_preparation.qmd`
2. `reports/CRM/02_crm_analysis_report.qmd`

Run the synthetic parser checks first, then prepare the authorised snapshot:

```sh
python3 R/CRM/test_import_parser.py
quarto render reports/CRM/01_crm_data_preparation.qmd --to html
```

Report 01 executes `R/CRM/prepare_crm.R`, which calls the Python validator.
It checks the source contract and writes prepared private data, diagnostics
and validation metadata. A rerun invalidates previous final prepared datasets
and the success marker before processing; it is not a read-only inspection.
Do not rerun it merely to browse an existing report.

Report 02 also requires the reviewed organisation mapping. If that mapping
needs to be rebuilt, obtain the private reviewed input first and run:

```sh
Rscript R/crm_organisation_master_mapping.R
```

The author developed the mapping; Catie provided manual review and feedback.
The mapping script processes the reviewed input into mapping tables. It does
not apply changes to the operational CRM. Where the required reviewed outputs
already exist, rebuilding them is not a prerequisite for every report render.

Then render the analysis:

```sh
quarto render reports/CRM/02_crm_analysis_report.qmd --to html
```

Report 02 reads the prepared CSV and canonical source import, uses the reviewed
mapping, and writes aggregate analysis tables and figures. It does not edit
operational contact records. Its assertions and narrative describe the
29 July 2026 snapshot; a new export requires review of the contract, mapping,
checks and narrative, not removal of assertions simply to obtain a render.
See [CRM workflow](CRM/README.md) for the input/output paths.

## 2. GA4 website report

With the nine annual/monthly CSV exports and report images in place:

```sh
quarto render reports/GA4/stav_website_report.qmd
```

The report reads its own inputs. The separate exploratory script is optional:

```sh
Rscript R/ga4/GA4_Web_Analytics.R
```

Running that script first does not supply a results object to the QMD.
The two implementations should not be assumed to execute each other's checks.
The annual reporting period is 1 July 2025–30 June 2026. The report additionally
references two manually exported path images associated with August–September
2026; exact exploration settings remain incompletely documented.

## 3. Shiny dashboard

The app consumes prepared CRM summaries and monthly GA4 traffic/page exports.
It does not run the CRM preparation or regenerate analysis summaries.
Check the inputs before launching:

```r
source("apps/stav-dashboard/check_data.R")
shiny::runApp("apps/stav-dashboard", launch.browser = TRUE)
```

Paths and reporting dates are set in `apps/stav-dashboard/config.R`.
Replacing raw CRM data alone does not refresh the dashboard.
See the [dashboard README](../apps/stav-dashboard/README.md) for refresh
requirements, filter scope, comparison logic and limitations.

### Fictional demonstration without private data

From a fresh R session at the repository root:

```r
source("apps/stav-dashboard/demo/generate_data.R")
Sys.setenv(STAV_DASHBOARD_MODE = "demo")
source("apps/stav-dashboard/check_data.R")
shiny::runApp("apps/stav-dashboard", launch.browser = TRUE)
```

The generator does not read private data. It creates reproducible fictional
fixtures under `data/example/dashboard/`. They demonstrate the app's inputs
and interactions, not STAV findings or the production CRM parsing workflow.
Stop the app and run `Sys.unsetenv("STAV_DASHBOARD_MODE")` before returning
to real-data mode. See [example data](../data/example/README.md).

## 4. Presentation

The presentation is a separate Quarto project. In a terminal initially at the
repository root:

```sh
cd presentation
quarto render stav_presentation.qmd
```

Its local output is `presentation/build/stav_presentation.html`. The source
disables code execution and uses bundled charts, so rendering does not run the
analysis or launch the dashboard. See [presentation instructions](../presentation/README.md).

## 5. Final report

Render after the CRM reports (step 1), because the final report reads the
aggregate summaries written by Report 02, selected fields of the validated clean
CRM file, the reviewed school-name candidate file and the GA4 exports:

```sh
quarto render reports/final/final_report.qmd
```

The output is `reports/final/final_report.pdf`, produced with Typst (bundled with
Quarto; no LaTeX installation is required). Page classification reuses
`apps/stav-dashboard/R/content.R`, so the report and dashboard apply identical
rules. The report prints only aggregate results and organisation names.

## Outputs and verification boundaries

The root `_quarto.yml` uses project-root execution, writes to `outputs/build/`
and selects only the GA4 report for a default project render. CRM reports and
the presentation must be requested explicitly. Check Quarto's reported output
path for each render; do not assume that an older HTML beside a QMD was just
refreshed. The nested presentation configuration has its own `build/` folder.

Generated HTML, support libraries and caches are build products. Keep necessary
source images and presentation assets; they are not disposable caches.
Review operational outputs for disclosure before sharing, including small
aggregates, school names and identifying page paths.

This document describes the current source workflow. Updating documentation or
passing input checks does not establish that every report was rerun, that an
application was evaluated in a browser, or that a stakeholder adopted it.
Source-specific checks and actual render/test logs are needed for those claims.
