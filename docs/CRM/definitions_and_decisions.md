# Report 01 decisions and limitations

- Reference date is the 2026-07-29 export date. No relationship activity definitions are introduced.
- The source header contains 71 fields. All decoded source fields and all logical records are retained.
- Mixed quoted JSON dialect is validated explicitly; source bytes remain unchanged.
- Selected No-as-missing fields reuse the old preparation assumption and need STAV confirmation. Genuine yes/no fields retain No.
- Free text and notes preserve internal whitespace and escapes. Ordinary text is squished.
- Comparison keys are candidates, not confirmed identity or organisation mapping.
- Postcode preparation retains invalid characters for review, a proposed improvement over digit-stripping that could manufacture a valid-looking postcode.
- Dates retain source text, parse with documented format priority, and flag ambiguous numeric day/month values. Derived dates do not retain time of day; originals do.
- The typed RDS is preferred for later R analysis. CSV empty fields represent missing; the canonical import retains exact original empty strings.
- Membership classifications, School Member analysis, reconciliation and active/dormant analysis are reserved for later approved reports.
