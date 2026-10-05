# Independent Instagram module; execute from the project root.
suppressPackageStartupMessages({library(tidyverse); library(lubridate); library(here)})
raw_dir <- here("data/raw/Meta/Insta")
clean_dir <- here("data/clean/Instagram")
analysis_dir <- here("data/analysis/Instagram")
figure_dir <- here("reports/figures/Instagram")
for (p in c(clean_dir, analysis_dir, figure_dir)) dir.create(p, recursive=TRUE, showWarnings=FALSE)
files <- c(views="Views - Insta.csv", reach="Reach - Insta.csv", visits="Visits - Insta.csv",
           link_clicks="Link clicks - Insta.csv", interactions="Interactions - Insta.csv", follows="Follows - Inta.csv")
metrics <- names(files)
calendar <- tibble(date=seq(as.Date("2025-07-01"), as.Date("2026-06-30"), by="day"))
sources <- imap(files, function(file, metric) {
  x <- read_csv(file.path(raw_dir,file), skip=2, locale=locale(encoding="UTF-16LE"),
                col_types=cols(.default=col_character()), show_col_types=FALSE)
  stopifnot(identical(names(x),c("Date","Primary")), nrow(problems(x))==0)
  stopifnot(all(str_detect(x$Date,"^\\d{4}-\\d{2}-\\d{2}T00:00:00$")),
            all(str_detect(x$Primary,"^[0-9]+$")))
  out <- tibble(date=as.Date(substr(x$Date,1,10)), value=as.numeric(x$Primary))
  stopifnot(!anyNA(out), !anyDuplicated(out$date), all(out$date %in% calendar$date))
  names(out)[2] <- metric
  out
})
manifest <- imap_dfr(sources, function(x,m) tibble(metric=m, source=file.path("data/raw/Meta/Insta",files[[m]]),
  md5=unname(tools::md5sum(file.path(raw_dir,files[[m]]))), rows=nrow(x), first_date=min(x$date),
  last_date=max(x$date), missing_days=nrow(calendar)-nrow(x), zero_days=sum(x[[m]]==0)))
daily <- reduce(sources, function(x,y) left_join(x,y,by="date"), .init=calendar)
# Missing source rows remain NA: absence does not establish zero activity.
ratio <- function(a,b) ifelse(is.na(a)|is.na(b)|b<=0,NA_real_,a/b)
summarise_period <- function(x, field) {
  x |> group_by(period=.data[[field]]) |> summarise(days=n(),
    across(all_of(metrics), list(observed_days=~sum(!is.na(.x)),
      observed_sum=~if(all(is.na(.x))) NA_real_ else sum(.x,na.rm=TRUE),
      total=~if(anyNA(.x)) NA_real_ else sum(.x)), .names="{.col}_{.fn}"), .groups="drop") |>
    mutate(interactions_per_100_daily_reach=100*ratio(interactions_total,reach_total),
           link_clicks_per_100_visits=100*ratio(link_clicks_total,visits_total))
}
monthly <- summarise_period(mutate(daily,month=floor_date(date,"month")),"month")
weekly <- summarise_period(mutate(daily,week=floor_date(date,"week",week_start=1)),"week") |>
  mutate(full_week=days==7)
overall <- summarise_period(mutate(daily,year="2025-07-01 to 2026-06-30"),"year")
weekly_long <- weekly |> filter(full_week) |> select(period,ends_with("_total")) |>
  pivot_longer(-period,names_to="metric",values_to="total") |> group_by(metric) |>
  mutate(q1=quantile(total,.25,na.rm=TRUE),q3=quantile(total,.75,na.rm=TRUE),
         unusually_strong=total>q3+1.5*(q3-q1), unusually_weak=total<q1-1.5*(q3-q1)) |> ungroup()
peaks <- monthly |> select(period,ends_with("_total")) |> pivot_longer(-period,names_to="metric",values_to="total") |>
  filter(!is.na(total)) |> group_by(metric) |> filter(total==max(total)|total==min(total)) |>
  mutate(position=case_when(max(total)==min(total)~"constant",total==max(total)~"peak",TRUE~"low")) |> ungroup()
write_csv(daily,file.path(clean_dir,"instagram_daily.csv"))
for(n in c("manifest","monthly","weekly","overall","weekly_long","peaks")) write_csv(get(n),file.path(analysis_dir,paste0("instagram_",n,".csv")))
plot_month <- monthly |> select(period,ends_with("_total")) |> pivot_longer(-period,names_to="metric",values_to="total")
p_month <- ggplot(filter(plot_month,!is.na(total)),aes(period,total))+geom_line(colour="#267B8B",na.rm=TRUE)+geom_point(colour="#267B8B",na.rm=TRUE)+
  facet_wrap(~metric,scales="free_y",ncol=2,labeller=as_labeller(c(views_total="Views",reach_total="Summed daily reach",visits_total="Profile visits",link_clicks_total="Link clicks",interactions_total="Interactions",follows_total="Follows")))+theme_minimal(base_size=12)+labs(x=NULL,y="Recorded monthly total",caption="Reach is summed daily reach; incomplete metric totals are omitted.")
p_week <- ggplot(filter(weekly_long,!is.na(total)),aes(period,total))+geom_line(colour="#267B8B",na.rm=TRUE)+
  geom_point(data=filter(weekly_long,unusually_strong|unusually_weak),colour="#C34C38",na.rm=TRUE)+
  facet_wrap(~metric,scales="free_y",ncol=2,labeller=as_labeller(c(views_total="Views",reach_total="Summed daily reach",visits_total="Profile visits",link_clicks_total="Link clicks",interactions_total="Interactions",follows_total="Follows")))+theme_minimal(base_size=12)+labs(x=NULL,y="Complete-week total",caption="Orange points exceed Tukey 1.5 IQR fences; incomplete metrics are omitted.")
ggsave(file.path(figure_dir,"instagram_monthly.png"),p_month,width=11,height=8,dpi=160)
ggsave(file.path(figure_dir,"instagram_weekly.png"),p_week,width=11,height=8,dpi=160)
# No validated monthly GA4 output exists. Reuse the exact existing export read by
# final_report.qmd in memory, without duplicating a GA4 dataset.
ga4_path <- here("data/raw/GA4/traffic_channel_monthly_20250701_20260630.csv")
ga4_comparison <- tibble()
if(file.exists(ga4_path)) {
 g <- read_csv(ga4_path,skip=9,show_col_types=FALSE,col_types=cols(.default=col_character()))
 g <- g |> filter(.data[[names(g)[1]]]=="Organic Social")
 month_num <- as.integer(g$Month); sessions <- as.numeric(g$Sessions)
 stopifnot(nrow(g)==12,!anyDuplicated(month_num),setequal(month_num,1:12),all(is.finite(sessions)),all(sessions>=0))
 g <- tibble(period=as.Date(sprintf("%d-%02d-01",ifelse(month_num>=7,2025,2026),month_num)),organic_social_sessions=sessions)
 ga4_comparison <- left_join(monthly,g,by="period")
 write_csv(ga4_comparison,file.path(analysis_dir,"instagram_ga4_comparison.csv"))
}
stopifnot(nrow(daily)==365, !anyDuplicated(daily$date))
for(m in metrics) stopifnot(sum(daily[[m]],na.rm=TRUE)==sum(sources[[m]][[m]],na.rm=TRUE),
                           sum(monthly[[paste0(m,"_observed_sum")]],na.rm=TRUE)==sum(daily[[m]],na.rm=TRUE))
message("Instagram preparation, reconciliation and analytical outputs completed.")
