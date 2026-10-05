# Build organisation mappings from Catie's independent A/B reviews.
# Run from the project root: Rscript R/crm_organisation_master_mapping.R
library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
input_file <- if (length(args)) args[[1]] else
  "data/analysis/CRM/organisation_mapping/restricted/crm_school_name_fuzzy_candidates_review.csv"
output_dir <- "data/analysis/CRM/organisation_mapping"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

review <- read_csv(input_file, col_types = cols(.default = col_character()))
required <- c("display_name_a", "display_name_b",
              "CH suggest name based on review of Column A",
              "CH suggest name based on review of Column B",
              "CH suggest Campus A", "CH suggest Campus B")
stopifnot(all(required %in% names(review)))
review <- review |> mutate(source_csv_row = row_number() + 1L)
# A repeated header inside the CSV is not a review record.
repeated_headers <- review |>
  filter(display_name_a == "display_name_a", display_name_b == "display_name_b")
review <- review |>
  filter(!(display_name_a == "display_name_a" & display_name_b == "display_name_b"))

clean_text <- function(x) na_if(str_squish(x), "")
long <- bind_rows(
  review |> transmute(source_csv_row, side = "A", crm_name = display_name_a,
    approved_organization_name = .data[[required[[3]]]],
    campus = .data[[required[[5]]]]),
  review |> transmute(source_csv_row, side = "B", crm_name = display_name_b,
    approved_organization_name = .data[[required[[4]]]],
    campus = .data[[required[[6]]]])
) |>
  mutate(across(c(crm_name, approved_organization_name, campus), clean_text),
    review_issue = case_when(
      is.na(crm_name) ~ "Missing CRM name",
      is.na(approved_organization_name) ~ "Missing approved organisation",
      str_detect(approved_organization_name, regex("^CHECK\\b", TRUE)) ~ "Manual check requested",
      str_detect(approved_organization_name, regex("^REMOVE\\b", TRUE)) ~ "Removal instruction requires review",
      TRUE ~ NA_character_))

issues <- long |> filter(!is.na(review_issue))
mapping <- long |> filter(is.na(review_issue)) |>
  distinct(crm_name, approved_organization_name, campus)
# Preserve separate reviewed mappings when an alias points to multiple organisations.
# They remain visible in the master; do not use those aliases for automatic CRM joins.
conflict_names <- mapping |> distinct(crm_name, approved_organization_name) |>
  count(crm_name, name = "organisation_count") |> filter(organisation_count > 1)
conflicts <- mapping |> inner_join(conflict_names, by = "crm_name") |>
  arrange(crm_name, approved_organization_name, campus)
collapse_unique <- function(x) paste(sort(unique(x[!is.na(x) & x != ""])), collapse = " | ")
master <- mapping |> group_by(approved_organization_name) |>
  summarise(crm_names = collapse_unique(crm_name), campuses = collapse_unique(campus),
            .groups = "drop") |> arrange(approved_organization_name)
safe_mapping <- mapping |> anti_join(conflict_names, by = "crm_name")
summary <- tibble(
  measure = c("Source review rows excluding repeated headers", "Repeated headers removed",
    "Independent side reviews", "Side reviews requiring follow-up",
    "Distinct reviewed mapping triples", "Unique approved organisations",
    "CRM names mapped to multiple organisations"),
  count = c(nrow(review), nrow(repeated_headers), nrow(long), nrow(issues),
    nrow(mapping), nrow(master), nrow(conflict_names)))
outputs <- list(organisation_master_mapping = master,
  organisation_mapping_long = mapping, organisation_mapping_provenance = long,
  organisation_mapping_review_issues = issues, organisation_mapping_conflicts = conflicts,
  organisation_mapping_unambiguous = safe_mapping, organisation_mapping_summary = summary)
iwalk(outputs, ~ write_csv(.x, file.path(output_dir, paste0(.y, ".csv")), na = ""))
stopifnot(nrow(master) == n_distinct(master$approved_organization_name),
          !anyNA(master$approved_organization_name),
          nrow(long) == 2L * nrow(review))
print(summary, n = Inf)
