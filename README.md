# STAV Data Analytics Project

A data analytics project exploring STAV's digital, CRM and event data to assess data quality, understand engagement patterns and generate evidence-based marketing and member insights.

## Project Overview

The overall goal of this project is to develop a clearer understanding of STAV's data landscape and establish a foundation for evidence-based marketing and member engagement decisions.


### Phase 1 — Understand the Data

Identify what data exists, where it is stored, how it is structured, and how reliable and usable it is.

Key activities include:

* identifying and documenting available data sources
* understanding key variables, metrics and data structures
* assessing data completeness, consistency and quality
* identifying tracking and measurement limitations
* evaluating the usability of each data source for future analysis

### Phase 2 — Use the Data

Use reliable and relevant data sources to generate meaningful insights that can support STAV's marketing and member engagement decisions.

Potential areas of analysis include:

* website traffic and user engagement
* traffic acquisition and channel performance
* website content performance
* social media performance
* event engagement
* member and CRM engagement
* cross-platform marketing performance

## Data Sources

The project currently considers data from:

* Google Analytics 4 (GA4)
* Meta
* LinkedIn
* CRM
* Events

## Analysis Period

Where possible, analysis will use a consistent 12-month period:

**1 July 2025 – 30 June 2026**

This provides a consistent basis for comparing performance across different data sources.

## Data Privacy

STAV operational data may contain confidential or sensitive information.

Raw datasets and platform exports are excluded from this repository using `.gitignore`.

Only sanitised documentation, reproducible analysis code, and approved non-sensitive outputs will be committed.

## Project Status

**Current stage: Phase 1 — Data understanding and data audit**

Current work includes:

* developing the Master Data Inventory
* reviewing available data sources
* standardising analysis periods
* preparing platform exports
* assessing data quality and usability

## Repository Structure

```text
.
├── data/       # Local STAV data — excluded from Git
├── R/          # Data cleaning and analysis scripts
├── docs/       # Project documentation
├── figures/    # Generated visualisations
└── reports/    # Analysis reports
```
