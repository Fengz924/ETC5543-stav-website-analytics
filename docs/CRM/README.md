# Consolidated CRM workflow

The current analytical reports are `reports/CRM/01_crm_data_preparation.qmd`
and `reports/CRM/02_crm_analysis_report.qmd`, for the 29 July 2026 snapshot.
Records, matching candidates and recorded membership fields are not verified
people, confirmed duplicates or authoritative current entitlements.

## Components

| Component | Repository location |
|---|---|
| Unchanged raw export | `data/raw/CRM/CRM20260729.csv` |
| Primary validated analytical CSV | `data/clean/CRM/restricted/crm_contacts_clean.csv` |
| Canonical source, source map and optional RDS | `data/clean/CRM/restricted/source_import/` |
| Preparation summaries and validation metadata | `data/analysis/CRM/01_preparation/` |
| Contact-level review queues | `data/analysis/CRM/01_preparation/restricted/` |
| Report 02 aggregate tables | `data/analysis/CRM/02_analysis/` |
| Figures | `reports/figures/CRM/` |
| Processing code and synthetic parser tests | `R/CRM/` |
| Source contract, field dictionary and method documentation | `docs/CRM/` |
| Independent fuzzy-review source | `data/analysis/CRM/organisation_mapping/restricted/crm_school_name_fuzzy_candidates_review.csv` |

The clean CSV is the primary Report 02 input; the RDS remains optional.
Report 02 additionally reads the canonical source import for exact-duplicate
checks and `organisation_master_mapping.csv` from
`data/analysis/CRM/organisation_mapping/` for reviewed naming analysis.
Historical datasets are not interchangeable with these inputs.

## Run from the repository root

```sh
python3 R/CRM/test_import_parser.py
quarto render reports/CRM/01_crm_data_preparation.qmd
quarto render reports/CRM/02_crm_analysis_report.qmd
```

Before rendering Report 02, ensure that the reviewed mapping outputs exist.
To regenerate those outputs from the authorised reviewed input:

```sh
Rscript R/crm_organisation_master_mapping.R
```

The author developed the mapping; Catie provided manual review and feedback.
The script processes that review into mapping tables; it does not alter the
operational CRM. Do not rebuild it without the required reviewed input.

The reports anchor execution using `here::i_am()`; no personal absolute
working-folder path is required. Report 01 revalidates the source and writes
prepared data. It invalidates previous final datasets and its success marker
before a rerun, so it is not a read-only inspection. Report 02 does not edit
contact records, but writes analysis summaries and figures. The root Quarto
project configures `outputs/build/`; check Quarto's reported output path rather
than assuming an older HTML beside the source has been updated. Generated HTML
and support files are ignored. The default render list selects GA4, so request
CRM reports explicitly.

## Privacy and exclusions

All real CRM data under `data/` remains Git-ignored, including raw/clean/source/contact review and mapping inputs. Only the field dictionary and source contract have explicit CSV/JSON ignore exceptions in `docs/CRM/`; neither contains contact values. Aggregate figures contain no contact-level details. No data files were staged or committed.

Historic delivery manifests and the consolidation inventory under the ignored
validation directory are provenance records, not execution dependencies.
See [reproduction instructions](../reproducibility.md) for dependencies and
[data sources](../data_sources.md) for input contracts and access limitations.
