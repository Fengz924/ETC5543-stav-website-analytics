# Import investigation

The source mixes doubled CSV quotes with literal backslash-quote sequences in nested JSON notes. Default Python permissive parsing returns 59 over-width records; strict default parsing rejects the syntax. Legacy readr (backslash escaping disabled) returns three problem records, with logical source numbers 291, 868 and 4897. readr diagnostic row numbers include the header (292, 869, 4898); logical source numbers exclude it.

Explicit backslash-consuming R/Python dialects align all records but remove literal backslashes. They are independent boundary checks only. The accepted strict state machine preserves those literal characters and decodes CSV doubled quotes. It rejects malformed quote boundaries, validates every notes value as a JSON list, writes standard quoted canonical CSV, and compares every decoded cell after exact Python and R round trips.

Quoted commas are legitimate field content. Five multiline company-address values account for five additional physical lines. They are retained. Neither extra commas nor physical line counts should be interpreted as additional contacts.

No source rows are dropped or quarantined. The old three-row post-notes quarantine is replaced by verified alignment. Old saved business results must be recomputed later; they are not guaranteed to match.

Evidence: `data/analysis/CRM/01_preparation/crm_parser_comparison.csv`, `crm_import_validation.csv`, and `data/analysis/CRM/01_preparation/validation/source_manifest.json`. Source-number diagnostics remain in restricted outputs. No personal examples are published.
