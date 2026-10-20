# STAV presentation

This folder is an independent Quarto Reveal.js project, alongside `reports/`.
The latest slides and English speaker notes are in `stav_presentation.qmd`.
Keep this file together with `theme.css`, `_quarto.yml` and `figures/`.

## Preview and build on another computer

Install Quarto CLI (https://quarto.org/docs/get-started/). Then, from the repository root:

```sh
cd presentation
quarto preview stav_presentation.qmd
```

To build an HTML presentation:

```sh
cd presentation
quarto render stav_presentation.qmd
```

Run either command from the repository root in a fresh terminal; if already in
`presentation/`, omit `cd presentation`. Output: `build/stav_presentation.html`.
The nested project configuration keeps this build separate from the GA4 report.
The slides disable code execution, so rendering needs no R installation, private
CRM data, GA4 exports or machine-specific paths. All referenced charts are included.
Resources are embedded in the generated HTML for offline presentation. Press S
for speaker view. Browser font availability can cause small layout differences.

## Optional chart regeneration

The included PNGs are sufficient for rendering. To edit and regenerate charts,
install R and the `ggplot2` package, then run from this directory:

```r
install.packages("ggplot2")
```

```sh
Rscript make_figures.R
quarto render stav_presentation.qmd
```

`make_figures.R` uses report aggregates and the included
`figures/school_name_distribution.csv`, not confidential source data. Update these
aggregates if the analytical reports change. R package versions are not locked.

## Live dashboard demonstration

Rendering the slides does not run the Shiny app. A live demonstration separately
requires R, the dashboard packages, and configured data. For a portable fictional
demo, follow `../apps/stav-dashboard/README.md`. Installing Quarto alone does not
make the live dashboard runnable.

`build/`, `.quarto/` and `Rplots.pdf` are local generated files and are ignored.
The separate Markdown speaker script has been removed; use the QMD speaker notes.
