# Consolidated CRM workflow

The existing ETC5543 repository organisation is retained. The current approved analytical reports are `reports/CRM/01_crm_data_preparation.qmd` and `reports/CRM/02_crm_analysis_report.qmd`. Earlier CRM reports and datasets are historical reference material; they were not overwritten.

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

The clean CSV is the primary Report 02 input; the RDS remains optional. The older repository clean datasets differ and remain untouched. The raw repository export was identical to the standalone source and was reused. Report 01 was identical and received only path/root adjustments; Report 02 retains the approved standalone analytical content with repository path/root adjustments. Existing organisation mapping outputs were preserved.

## Run from the repository root

```sh
python3 R/CRM/test_import_parser.py
quarto render reports/CRM/01_crm_data_preparation.qmd
quarto render reports/CRM/02_crm_analysis_report.qmd
```

The reports anchor execution using `here::i_am()`; no personal absolute working-folder path is required. Report 01 revalidates the source and prepares the dataset. Report 02 does not change contact data. Rendered HTML/support files are generated beside the reports and ignored by Git. The main Quarto configuration and default render list were not changed.

## Privacy and exclusions

All real CRM data under `data/` remains Git-ignored, including raw/clean/source/contact review and mapping inputs. Only the field dictionary and source contract have explicit CSV/JSON ignore exceptions in `docs/CRM/`; neither contains contact values. Aggregate figures contain no contact-level details. No data files were staged or committed.

The standalone folder remains a backup. Its project configuration, RStudio project, temporary caches, duplicate raw/clean CSVs, old rendered reports and non-CRM content were not imported. Historic delivery manifests under the ignored validation directory are provenance records, not execution dependencies. The local consolidation inventory records individual copied/reused files.
