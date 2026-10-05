# Existing project reproduction

## Environment

Run from the repository root, optionally by opening the existing RStudio project.
Use R and Quarto; RStudio is optional. Required packages across retained sources
include `tidyverse`, `janitor`, `lubridate`, `here`, `readxl`, `knitr`, `scales`,
and `forcats`. No `renv`, pipeline framework, or version lock is provided.
The Phase 1 GA4 render was tested on 5 October 2026 with R 4.5.2 and
RStudio-bundled Quarto 1.9.38. Installed package versions were: tidyverse 2.0.0,
janitor 2.2.1, lubridate 1.9.5, here 1.0.2, readxl 1.4.5, knitr 1.51,
scales 1.4.0, and forcats 1.0.1. This verifies the GA4 render attempt, not
execution of CRM or the supporting Event audit.

## Private inputs

Use the paths and filenames in [data sources](data_sources.md). Preserve existing
uppercase data component folders. Keep raw, cleaned, analysis, and rendered
build data ignored. An authorised user must obtain inputs separately.
A public clone cannot reproduce real-data results without them.

## GA4 script

```bash
Rscript R/ga4/GA4_Web_Analytics.R
```

This runs the existing script from the project root. It reads nine GA4 exports,
displays summaries, validation checks, and plots. The script's contents are
unchanged. It does not export a results object consumed by the final report.

## Final GA4 report

```bash
quarto render reports/final_report.qmd
```

The report independently reads the same exports plus two path-exploration
screenshots. Running the R script first is useful for inspection but is not a
report dependency. Existing report calculations and narrative are retained.
`_quarto.yml` uses project-root execution and `outputs/build` for render output.
The existing HTML format embeds resources; PDF is not configured. Consult
Quarto's reported output path for the generated document.

A default `quarto render` selects only this report. Rendering executes R code
and creates build outputs. Treat builds as private until reviewed; no final
public deliverable is selected or promoted automatically.

## Supporting Event audit

```bash
quarto render reports/supporting/event_analysis.qmd
```

This is independent of GA4. It reads the private participant workbook, renders
an audit, and writes CSVs into ignored `data/clean/Events/`. Review potential
identification through organisation/role combinations before distribution.
The retained older `reports/event_analysis.html` has missing support assets;
it is not the new build destination.

## CRM, legacy GA4, and presentation

CRM files and data are unchanged pending authoritative-version confirmation.
The retained current CRM dependencies are cleaning (`01`), then quality (`02`),
school groups (`03`), and membership (`04`), followed by summary (`06`). This
records the existing dependency order, not approval to run or adopt that version.
CRM rendering writes private derived data and can expose operational information.

The older root-level GA4 audit remains unchanged and expects unavailable older
filenames. It is excluded from default rendering. No presentation source has
been identified, so there is no presentation render command yet.

## Assessment and limits

Without private data, assessors can inspect source methods, documented inputs,
and the fictional CRM schema example. That example is not an end-to-end demo;
no synthetic GA4 mode has been added. Screenshot reconstruction, software
versions, CRM authority, presentation availability, and publication clearance
remain unresolved. Source availability does not imply successful runtime
verification. Existing Git history and retained outputs remain unchanged.

## Phase 1 render verification

Quarto was not on this machine's shell PATH. The existing bundled executable
was used without installation:

```bash
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto render reports/final_report.qmd
```

The command exited successfully and created
`outputs/build/reports/final_report.html`. However, Pandoc warned that it could
not fetch both `data/raw/GA4/ga4_*_path_exploration_aug_sep_2026.png` resources.
Both source PNGs exist locally, but screenshot inclusion/embedding is therefore
not verified. No additional report edits were made to resolve these warnings.
The HTML is an incomplete private verification build, not a final deliverable.
