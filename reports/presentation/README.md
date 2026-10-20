# STAV Quarto presentation

## Preview and edit

From this directory:

```sh
quarto preview stav_presentation.qmd
```

If Quarto is not on PATH on this Mac:

```sh
/Applications/RStudio.app/Contents/Resources/app/quarto/bin/quarto preview stav_presentation.qmd
```

Edit `stav_presentation.qmd`. Each `##` starts a slide. Speaker notes are inside `.notes` blocks. Press S in the HTML presentation for speaker view. Use arrow keys to navigate and Esc for the overview.

## Build

```sh
quarto render stav_presentation.qmd
```

The output is `build/stav_presentation.html`. It embeds resources for offline use. Open it in a browser to present. This is a Quarto HTML slide deck, not a PowerPoint `.pptx` file. Confirm the Moodle upload format before submission.

## Rehearsal

Read `speaker_script.md`, then practise in your own words. There are 12 main slides and 4 appendix slides. End the talk on Conclusions and open the appendix only for questions. Aim for 9–10 minutes, leaving 5 minutes for questions.

Before delivery, confirm your name, talk date, individual/group timing and exact contribution to candidate generation. Verify the fuzzy matching algorithm from its original code before naming a metric or threshold. GA4 inspection findings describe the report's inspection, not a fresh live audit.

The existing analytical reports and project-wide configuration are unchanged. Figures and numbers are based on those reports. The deck does not execute the restricted raw-data workflows.

## Figures

Five result charts replace text-heavy result slides. Aggregate values come from the approved analytical reports. Rebuild with `Rscript make_figures.R` from this directory, then render the Quarto file. The R source preserves editable chart definitions. Charts use manually transcribed report aggregates, so update the values if the analytical reports change.

## Visual structure

Slides 1, 2, 8 and 9 use editable HTML/CSS diagrams. Edit the labels in the QMD and layout in theme.css. CRM results use blue section labels and GA4 results use teal. Workflow lanes remain separate and jointly inform recommendations. The independent speaking script matches the revised workflow.

The repeated title slide has been removed. Four result slides now include explicit report-based counts, denominators and comparisons. The school-name chart uses the copied report aggregate in figures/school_name_distribution.csv. The 22.8% and 7.8% CRM shares are derived from 1,379/6,051 and 49/632 respectively.

## Current talk structure

The opening is the original Business questions and data slide, with no separate title slide. CRM examples are explicitly illustrative and contain no contact-level data. The school example comes from the reviewed mapping in the CRM report. GA4 terminology has a dedicated slide. The Shiny feature map and 60-second demo run sheet reflect the current app source. The script includes the lecturer’s four Q&A tips and sample discussion phrases. Target timing: 9 minutes 50 seconds including the demo.
