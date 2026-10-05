# Report 01 only. No business membership/group/activity classifications.
suppressPackageStartupMessages({library(readr); library(dplyr); library(stringr);
  library(lubridate); library(janitor); library(purrr); library(tibble); library(jsonlite)})
root <- normalizePath(here::here(), mustWork=TRUE)
stopifnot(file.exists(file.path(root,"docs/CRM/source_contract.json")))
restricted <- file.path(root,"data/clean/CRM/restricted/source_import")
summary_dir <- file.path(root,"data/analysis/CRM/01_preparation")
review_dir <- file.path(root,"data/analysis/CRM/01_preparation/restricted")
clean_dir <- file.path(root,"data/clean/CRM/restricted")
dir.create(clean_dir,recursive=TRUE,showWarnings=FALSE)
final_csv <- file.path(clean_dir,"crm_contacts_clean.csv")
final_rds <- file.path(restricted,"crm_contacts_analysis_internal.rds")
# No stale success marker or final dataset survives a failed rerun.
unlink(c(final_csv,final_rds,file.path(root,"data/analysis/CRM/01_preparation/validation/preparation_passed.json")))
tryCatch({
python <- Sys.which("python3")
if (!nzchar(python)) stop("Python3 is required for strict source validation.")
dir.create(file.path(root,"data/analysis/CRM/01_preparation/validation"),recursive=TRUE,showWarnings=FALSE)
probe <- system2(python,shQuote(file.path(root,"R/CRM/validate_import.py")),stdout=TRUE,stderr=TRUE)
if (!is.null(attr(probe,"status")) && attr(probe,"status")!=0) stop("Source import failed; see data/analysis/CRM/01_preparation/validation/import_failure.txt")
manifest <- fromJSON(file.path(root,"data/analysis/CRM/01_preparation/validation/source_manifest.json"))
stopifnot(isTRUE(manifest$import_passed),isTRUE(manifest$R_canonical_exact_roundtrip))
source_data <- read_csv(file.path(restricted,"crm_source_import_internal.csv"),
  col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,
  name_repair="minimal",show_col_types=FALSE,progress=FALSE,lazy=FALSE)
stopifnot(nrow(problems(source_data))==0L,nrow(source_data)==manifest$records,ncol(source_data)==71L)
source_headers <- names(source_data)
source_data <- clean_names(source_data)
source_fields <- names(source_data)
stopifnot(!anyDuplicated(source_fields))
record_map <- read_csv(file.path(restricted,"crm_source_record_map_internal.csv"),show_col_types=FALSE)
stopifnot(nrow(record_map)==nrow(source_data),identical(as.integer(record_map$source_record_number),seq_len(nrow(source_data))))
crm <- bind_cols(record_map,source_data)
date_fields <- c("date_created","date_optin_status_changed","gdpr_consent_date",
 "marketing_consent_date","unsub_date","subscription_start_date","subscription_end_date",
 "date_of_cancellation","date_retired","last_sponsorship_purchase")
original_fields <- unique(c("id","full_name","first_name","last_name","email","company_name",date_fields))
for (field in original_fields) crm[[paste0(field,"_original")]] <- crm[[field]]
no_as_missing_fields <- intersect(c("birthday","mobile_phone","primary_phone",
 "primary_phone_extension","street_address_1","street_address_2","city","postal_zip",
 "region","country","time_zone","ip_address","lead_source","source_page",
 "gdpr_consent_date","marketing_consent_date","notes","tags","utm_campaign",
 "utm_content","utm_medium","utm_term","utm_source","unsub_date","unsub_reason",
 "unsub_feedback","membership_status","membership_plan","subscription_start_date",
 "subscription_end_date","date_of_cancellation","reason_for_cancellation","if_other",
 "date_retired","year_level","subjects","job_title_position",
 "do_you_hold_an_identified_leadership_role_other","your_role","last_sponsorship_purchase",
 "sponsorships_details_sections","sponsorship_details_divisions","supporting_sponsorships",
 "company_name","company_website","company_address","company_phone",
 "company_phone_extension","job_title","company_department"),source_fields)
# Free text/JSON: trim edges only; preserve internal whitespace and escapes.
trim_only_fields <- c("notes","unsub_feedback","reason_for_cancellation","if_other",
 "do_you_hold_an_identified_leadership_role_other","company_address")
clean_text <- function(x,field) {
  x <- if(field %in% trim_only_fields) str_trim(x) else str_squish(x)
  x <- na_if(x,"")
  if(field %in% no_as_missing_fields) x <- if_else(!is.na(x)&str_to_lower(x)=="no",NA_character_,x)
  x
}
cleaning_changes <- map_dfr(source_fields,function(field) {
  before <- crm[[field]]; after <- clean_text(before,field)
  tibble(field=field,records_changed=sum(!is.na(before)&(is.na(after)|before!=after)),
   blank_to_missing=sum(!is.na(before)&str_trim(before)==""),
   no_placeholder_to_missing=if(field %in% no_as_missing_fields) sum(str_to_lower(str_trim(before))=="no",na.rm=TRUE) else 0L,
   method=if(field %in% trim_only_fields) "Trim edges; preserve internal whitespace" else "Squish whitespace",
   no_is_missing=field %in% no_as_missing_fields)
})
for(field in source_fields) crm[[field]] <- clean_text(crm[[field]],field)
normalise_name <- function(x) str_replace_all(str_squish(str_to_lower(x)),"[^[:alnum:]]","") |> na_if("")
normalise_organisation <- function(x) str_replace_all(str_squish(str_to_lower(x)),"[^[:alnum:] ]","") |> str_squish() |> na_if("")
normalise_phone <- function(x) str_replace_all(x,"[^0-9+]","") |> na_if("")
normalise_region <- function(x) {
 key <- str_to_lower(str_squish(x))
 case_when(key %in% c("vic","victoria")~"VIC",key %in% c("nsw","new south wales")~"NSW",
 key %in% c("qld","queensland")~"QLD",key %in% c("act","australian capital territory")~"ACT",
 key %in% c("sa","south australia")~"SA",key %in% c("wa","western australia")~"WA",
 key %in% c("tas","tasmania")~"TAS",key %in% c("nt","northern territory")~"NT",
 key=="metro"~"Metro",key=="country"~"Country",is.na(key)~NA_character_,TRUE~str_to_title(key))
}
crm <- crm |> mutate(
 email_key=na_if(str_to_lower(str_squish(email)),""),
 first_name_key=normalise_name(first_name),last_name_key=normalise_name(last_name),
 name_key=if_else(!is.na(first_name_key)&!is.na(last_name_key),str_c(first_name_key,last_name_key,sep="|"),NA_character_),
 organisation_name_key=normalise_organisation(company_name),
 mobile_phone_clean=normalise_phone(mobile_phone),primary_phone_clean=normalise_phone(primary_phone),
 preferred_phone=coalesce(mobile_phone_clean,primary_phone_clean),
 suburb_candidate=city,region_clean=normalise_region(region),
 # Preserve nonnumeric values for review instead of manufacturing valid postcodes.
 postal_zip_clean=postal_zip)
parse_crm_date <- function(x) as.Date(suppressWarnings(parse_date_time(x,
 orders=c("ymd HMS","ymd HM","ymd","dmy HMS","dmy HM","dmy","mdy HMS","mdy HM","mdy","B d Y IMS p","B d Y IM p"),
 tz="Australia/Melbourne",quiet=TRUE)))
ambiguous_numeric_date <- function(x) {
 parts <- str_match(x,"^([0-9]{1,2})[/-]([0-9]{1,2})[/-]([0-9]{4})(?:$|[ T])")
 a<-suppressWarnings(as.integer(parts[,2]));b<-suppressWarnings(as.integer(parts[,3]))
 !is.na(a)&!is.na(b)&a>=1&a<=12&b>=1&b<=12&a!=b
}
crm$date_parse_failure <- FALSE
crm$date_parse_ambiguous <- FALSE
date_validation <- map_dfr(date_fields,function(field) {
 raw <- crm[[field]];parsed_values<-parse_crm_date(raw);ambiguous<-ambiguous_numeric_date(raw)
 crm[[paste0(field,"_clean")]] <<- parsed_values
 crm$date_parse_failure <<- crm$date_parse_failure | (!is.na(raw)&is.na(parsed_values))
 crm$date_parse_ambiguous <<- crm$date_parse_ambiguous | ambiguous
 tibble(field=field,populated=sum(!is.na(raw)),parsed=sum(!is.na(parsed_values)),
  parse_failures=sum(!is.na(raw)&is.na(parsed_values)),ambiguous_day_month=sum(ambiguous),
  earliest=if(all(is.na(parsed_values))) as.Date(NA) else min(parsed_values,na.rm=TRUE),
  latest=if(all(is.na(parsed_values))) as.Date(NA) else max(parsed_values,na.rm=TRUE))
})
flag_duplicates <- function(x) !is.na(x)&(duplicated(x)|duplicated(x,fromLast=TRUE))
crm <- crm |> mutate(
 structure_issue=FALSE,
 missing_crm_id=is.na(id),missing_email=is.na(email_key),
 duplicate_crm_id_candidate=flag_duplicates(id),duplicate_email_candidate=flag_duplicates(email_key),
 duplicate_name_candidate=flag_duplicates(name_key),
 email_format_valid=if_else(is.na(email_key),NA,str_detect(email_key,"^[^[:space:]@]+@[^[:space:]@]+\\.[^[:space:]@]+$")),
 australian_postcode_format_valid=if_else(is.na(postal_zip_clean),NA,str_detect(postal_zip_clean,"^[0-9]{4}$")),
 full_name_component_mismatch=!is.na(normalise_name(full_name))&!is.na(first_name_key)&!is.na(last_name_key)&
   normalise_name(full_name)!=str_c(first_name_key,last_name_key),
 organisation_key_missing_for_populated_name=!is.na(company_name)&is.na(organisation_name_key))
checks <- tibble(check=c("Source record count retained","All 71 source fields retained",
 "Source record numbers unique and sequential","Source original audit values retained exactly",
 "No unresolved source structure issue","Canonical readr parser problems zero",
 "No populated date parse failures","No ambiguous day/month dates","No organisation key lost for a populated name"),
 passed=c(nrow(crm)==manifest$records,all(source_fields %in% names(crm)),
 identical(as.integer(crm$source_record_number),seq_len(nrow(crm))),
 all(map_lgl(original_fields,~identical(crm[[paste0(.x,"_original")]],source_data[[.x]]))),
 !any(crm$structure_issue),nrow(problems(source_data))==0L,
 !any(crm$date_parse_failure),!any(crm$date_parse_ambiguous),!any(crm$organisation_key_missing_for_populated_name)),
 severity=c(rep("BLOCKING",6),"REVIEW","REVIEW","REVIEW"))
write_csv(checks,file.path(summary_dir,"crm_post_cleaning_validation.csv"),na="")
if(any(!checks$passed & checks$severity=="BLOCKING")) stop("Blocking preparation checks failed; final dataset not written.")
flag_summary <- tibble(flag=c("Missing CRM ID","Missing email","Duplicate CRM ID candidate",
 "Duplicate email candidate","Duplicate name candidate","Invalid populated email syntax",
 "Invalid populated Australian postcode format","Full-name component mismatch",
 "Any date parse failure","Any ambiguous day/month date","Source quoting exception resolved","Multiline source record"),
 records=c(sum(crm$missing_crm_id),sum(crm$missing_email),sum(crm$duplicate_crm_id_candidate),
 sum(crm$duplicate_email_candidate),sum(crm$duplicate_name_candidate),sum(!crm$email_format_valid,na.rm=TRUE),
 sum(!crm$australian_postcode_format_valid,na.rm=TRUE),sum(crm$full_name_component_mismatch),
 sum(crm$date_parse_failure),sum(crm$date_parse_ambiguous),sum(crm$source_quote_dialect_exception),sum(crm$source_multiline_record)))
review <- crm |> filter(missing_crm_id|missing_email|duplicate_crm_id_candidate|duplicate_email_candidate|
 duplicate_name_candidate|coalesce(!email_format_valid,FALSE)|coalesce(!australian_postcode_format_valid,FALSE)|
 full_name_component_mismatch|date_parse_failure|date_parse_ambiguous|organisation_key_missing_for_populated_name)
# Source definitions are deliberately conservative; semantic authority remains STAV.
meaning <- c(id="Source CRM record identifier; not established as a unique-person identifier",
 full_name="Supplied full name",first_name="Supplied first name",last_name="Supplied last name",
 email="Supplied email address",optin_status="Recorded opt-in status; not engagement",
 user_id="Source user identifier; business semantics unconfirmed",owner_id="Source owner identifier; business semantics unconfirmed",
 date_created="Recorded creation date/time; not last contact",date_optin_status_changed="Recorded opt-in status change date/time; not last contact",
 company_name="Supplied school or other organisation name",city="Supplied city; suburb interpretation unconfirmed",
 postal_zip="Supplied postal/ZIP value",region="Supplied region; may include state and other categories",
 tags="Source tags; no business classification in Report 01",notes="Source JSON notes; literal escapes preserved; not interpreted as contact activity",
 membership_status="Recorded membership status; authority not established",
 membership_plan="Recorded membership plan; no member classification in Report 01",
 subscription_start_date="Recorded subscription start date",subscription_end_date="Recorded subscription end date")
derived_meaning <- c(source_record_number="One-based logical source record number, excludes header; not physical line number",
 physical_line_start="First physical line of logical source record",physical_line_end="Last physical line of logical source record",
 source_multiline_record="Source logical record spans more than one physical line",
 source_quote_dialect_exception="Default Python parser disagreed on field width; resolved by validated literal-preserving dialect",
 email_key="Lowercase and whitespace-standardised email comparison key; original retained",
 first_name_key="Lowercase first name with all nonalphanumeric characters removed",
 last_name_key="Lowercase last name with all nonalphanumeric characters removed",
 name_key="First and last comparison keys joined with |; missing if either part absent; candidate matching only",
 organisation_name_key="Lowercase organisation name; punctuation removed; whitespace squished; not approved organisation identity",
 mobile_phone_clean="Mobile characters restricted to digits and plus; not verified phone validity",
 primary_phone_clean="Primary phone characters restricted to digits and plus; not verified phone validity",
 preferred_phone="Clean mobile first, clean primary phone second; not verified reachability",
 suburb_candidate="City copied as provisional suburb candidate; requires business confirmation",
 region_clean="Known Australian state names mapped to abbreviations; other values retained/title-cased",
 postal_zip_clean="Trimmed/squished postal value; invalid characters retained for review",
 structure_issue="FALSE only after strict source alignment and exact round-trip gates pass",
 missing_crm_id="Missing cleaned source CRM ID",missing_email="Missing normalised email",
 duplicate_crm_id_candidate="All records sharing a populated cleaned CRM ID; no automatic merging",
 duplicate_email_candidate="All records sharing a populated email key; no automatic merging",
 duplicate_name_candidate="All records sharing a populated name key; not confirmed duplicate people",
 email_format_valid="Simple email syntax check; NA when missing; no deliverability verification",
 australian_postcode_format_valid="Exactly four digits; NA when missing; country applicability not inferred",
 full_name_component_mismatch="Normalised full name differs from normalised first plus last name, only when comparable",
 organisation_key_missing_for_populated_name="Populated organisation loses all alphanumeric characters under key creation",
 date_parse_failure="At least one populated date could not be parsed",
 date_parse_ambiguous="At least one numeric day/month date has two distinct components both 1-12; parsed value needs review")
dictionary <- map_dfr(names(crm),function(field) {
 source <- field %in% source_fields
 original <- str_ends(field,"_original")
 parsed_date <- field %in% paste0(date_fields,"_clean")
 m <- if(source) {if(field %in% names(meaning)) meaning[[field]] else paste("Supplied source field:",source_headers[match(field,source_fields)],"— detailed business semantics not verified")}
 else if(original) paste("Exact decoded source value of",str_remove(field,"_original$"),"before cleaning")
 else if(parsed_date) paste("Parsed",str_remove(field,"_clean$"),"using documented format priority; Melbourne timezone; date only")
 else derived_meaning[[field]]
 tibble(position=match(field,names(crm)),field=field,role=if(source) "cleaned_source" else if(original) "original_audit" else "derived",
 source_header=if(source) source_headers[match(field,source_fields)] else "",
 data_type=class(crm[[field]])[1],definition=m,
 transformation=if(source) paste(if(field %in% trim_only_fields) "Trim edges" else "Squish whitespace","; blank to NA;",if(field %in% no_as_missing_fields) "No placeholder to NA" else "No preserved") else m,
 missing_rule="Empty CSV fields represent NA in the analysis CSV; original decoded values in canonical source import",
 privacy="Restricted contact-level data")
})
write_csv(dictionary,file.path(root,"docs/CRM/crm_field_dictionary.csv"),na="")
write_csv(cleaning_changes,file.path(summary_dir,"crm_cleaning_log.csv"),na="")
write_csv(date_validation,file.path(summary_dir,"crm_date_parse_validation.csv"),na="")
write_csv(flag_summary,file.path(summary_dir,"crm_preparation_flag_summary.csv"),na="")
write_csv(crm,final_csv,na="")
saveRDS(crm,final_rds)
write_csv(review,file.path(review_dir,"crm_preparation_review_internal.csv"),na="")
# Validate typed RDS and CSV values, field order and logical row retention.
stopifnot(identical(readRDS(final_rds),crm))
check_csv <- read_csv(final_csv,col_types=cols(.default=col_character()),na="",trim_ws=FALSE,show_col_types=FALSE,progress=FALSE,lazy=FALSE)
stopifnot(nrow(problems(check_csv))==0L,nrow(check_csv)==nrow(crm),identical(names(check_csv),names(crm)))
for(field in names(crm)) stopifnot(identical(check_csv[[field]],na_if(as.character(crm[[field]]),"")))
checks <- bind_rows(checks,tibble(check=c("Typed RDS exact round trip","Analysis CSV values and missing-value convention round trip"),passed=TRUE,severity="BLOCKING"))
write_csv(checks,file.path(summary_dir,"crm_post_cleaning_validation.csv"),na="")
output_summary <- tibble(metric=c("Final analysis records","Source fields","Source original audit copies",
 "Derived/audit fields","Final analysis fields","Preparation review records"),
 result=c(nrow(crm),length(source_fields),length(original_fields),ncol(crm)-length(source_fields)-length(original_fields),ncol(crm),nrow(review)))
write_csv(output_summary,file.path(summary_dir,"crm_output_summary.csv"))
write_json(list(preparation_passed=TRUE,source_sha256=manifest$source_sha256,records=nrow(crm),fields=ncol(crm),
 csv="data/clean/CRM/restricted/crm_contacts_clean.csv",rds="data/clean/CRM/restricted/source_import/crm_contacts_analysis_internal.rds",
 review_flags_are_not_business_decisions=TRUE),file.path(root,"data/analysis/CRM/01_preparation/validation/preparation_passed.json"),pretty=TRUE,auto_unbox=TRUE)
# Restrict generated contact-level files. Folder convention is not system-wide access control.
Sys.chmod(c(final_csv,list.files(restricted,full.names=TRUE),list.files(review_dir,full.names=TRUE)),mode="0600")
message("Report 01 preparation PASS: ",nrow(crm)," records; ",ncol(crm)," fields. No later-report analysis executed.")

}, error=function(e) {
 unlink(c(final_csv,final_rds,file.path(root,"data/analysis/CRM/01_preparation/validation/preparation_passed.json")))
 stop(conditionMessage(e),call.=FALSE)
})
