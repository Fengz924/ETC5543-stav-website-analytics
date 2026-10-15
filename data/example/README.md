# Fictional example data

These files are synthetic demonstrations, not STAV operational data or results.

- `CRM/crm_contacts_synthetic.csv`: original single-contact, reduced-schema example.
- `GA4/`: copies of the fictional monthly GA4 tables in `dashboard/ga4/`.
- `dashboard/`: 120 fictional raw/clean contacts, CRM summaries and 12 months of fictional GA4 data.

Recreate the dashboard fixtures from the repository root:

```r
source('apps/stav-dashboard/demo/generate_data.R')
```

The generator does not read private source data. Its simplified preparation demonstrates the dashboard input format; it does not exercise the complete production CRM preparation and validation process.
