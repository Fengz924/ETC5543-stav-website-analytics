# Report 01 decisions and limitations

- Reference date is the 2026-07-29 export date. No relationship activity definitions are introduced.
- The source header contains 71 fields. All decoded source fields and all logical records are retained.
- Mixed quoted JSON dialect is validated explicitly; source bytes remain unchanged.
- Selected No-as-missing fields follow field-specific conventions discussed and confirmed with STAV staff, as reported by the author. Genuine yes/no fields retain No. This does not independently verify each source response.
- Free text and notes preserve internal whitespace and escapes. Ordinary text is squished.
- Comparison keys are candidates, not confirmed identity or organisation mapping.
- Postcode preparation retains invalid characters for review, a proposed improvement over digit-stripping that could manufacture a valid-looking postcode.
- Dates retain source text, parse with documented format priority, and flag ambiguous numeric day/month values. Derived dates do not retain time of day; originals do.
- Report 02 uses the prepared CSV with explicit types; the typed RDS is optional. CSV empty fields represent missing; the canonical import retains exact original empty strings.
- Report 01 does not classify memberships or school relationships. Report 02 performs the documented record-level membership and school-plan analysis using conventions discussed with STAV staff. It does not establish verified current entitlements, engaged/dormant populations or operational CRM changes.
