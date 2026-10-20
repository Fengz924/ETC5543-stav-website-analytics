# Run from the project root: shiny::runApp('apps/stav-dashboard')
required <- c('shiny', 'bslib', 'ggplot2', 'dplyr', 'readr', 'janitor', 'DT', 'scales', 'stringr')
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop('Install required packages: ', paste(missing, collapse = ', '))
library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
# Shiny sets the working directory to the application directory.
root <- normalizePath('../..', mustWork = TRUE)
source('R/data.R', local = TRUE)
config_file <- if (identical(Sys.getenv('STAV_DASHBOARD_MODE'), 'demo')) 'config-demo.R' else 'config.R'
config <- dget(config_file)
data <- load_dashboard_data(root, config)
source('R/content.R', local = TRUE)
source('R/comparison.R', local = TRUE)
data$pages$category <- classify_page(data$pages$page)
crm_date_label <- paste(as.integer(format(as.Date(config$crm$snapshot_date), '%d')),
                        month.name[as.integer(format(as.Date(config$crm$snapshot_date), '%m'))],
                        format(as.Date(config$crm$snapshot_date), '%Y'))
ga4_period_label <- paste(format(as.Date(config$ga4$start_date), '%b %Y'),
                          format(as.Date(config$ga4$end_date), '%b %Y'), sep = '–')
fmt <- function(x) format(x, big.mark = ',', scientific = FALSE, trim = TRUE)
note <- function(...) tags$p(..., class = 'text-muted')
# Use natural document height: charts and tables must not share one viewport.
dashboard_card <- function(...) bslib::card(
  ..., fill = FALSE,
  wrapper = function(...) bslib::card_body(..., fillable = FALSE)
)
table_card <- function(title, id) dashboard_card(card_header(title), DT::DTOutput(id))
ui <- page_navbar(
  fillable = FALSE,
  title = config$title, theme = bs_theme(version = 5, bootswatch = 'flatly'),
  header = tagList(tags$style(HTML('
    .overview-metrics .bslib-value-box { height: 100%; min-height: 190px; }
    .bslib-card { margin-bottom: 16px; }
    .card-header { font-weight: 600; }
    .dataTables_wrapper { padding: 4px; }
    .action-button, .shiny-download-link {
      background-color: #2c3e50 !important;
      border-color: #2c3e50 !important;
      color: #ffffff !important;
    }
    .action-button:hover, .shiny-download-link:hover,
    .action-button:active, .shiny-download-link:active {
      background-color: #1a2733 !important;
      border-color: #1a2733 !important;
      color: #ffffff !important;
    }
    .action-button:focus-visible, .shiny-download-link:focus-visible {
      outline: 3px solid #247c91;
      outline-offset: 3px;
    }
  ')), tags$div(class = 'container-fluid', note(paste0(if (isTRUE(config$demo)) 'FICTIONAL DEMO — all figures are simulated · CRM snapshot: ' else 'Local prototype · CRM snapshot: ', crm_date_label, ' · GA4: ', ga4_period_label)))),
  nav_panel('Overview',
    layout_columns(fill = FALSE, fillable = FALSE, class = 'overview-metrics', 
      value_box('Total contact records', fmt(data$overview$records[match('Total CRM records', data$overview$metric)]), paste('CRM snapshot as of', crm_date_label)),
      value_box('Website sessions', fmt(sum(data$monthly$sessions)), 'Full reporting period（repeat visits are included）'),
      value_box('CRM review candidates', fmt(sum(data$duplicates$records)), 'Same-name candidates; identity requires review.')
    ),
    dashboard_card(card_header('Where to focus'),
      tags$p('CRM: review same-name candidates and membership-field differences before making record changes.'),
      tags$p('Website: compare traffic channels, then explore the most-viewed content. These are separate datasets and do not identify individual membership conversions.')),
    dashboard_card(card_header('How to use this dashboard'),
      tags$p('Use CRM Data Quality to prioritise information review; use CRM Membership & Schools to inspect recorded membership fields and school relationships.'),
      tags$p('Use GA4 Traffic for channel trends and GA4 Content for page views and content categories. The two sources are displayed separately; they do not establish website-to-membership conversion.'),
      note('CRM is a historical snapshot. Recorded Active status does not establish current entitlement or engagement. Source data must be refreshed outside the app.'))
  ),
  nav_panel('CRM Data Quality',
    layout_columns(fill = FALSE, fillable = FALSE, dashboard_card(card_header('Key field coverage'), plotOutput('coverage', height = '420px', fill = FALSE)),
                   table_card('Potential duplicate review — strongest evidence per record', 'duplicates')),
    note('Potential matches are not confirmed duplicates. Coverage measures populated values, not accuracy.'),
    table_card('Field coverage — searchable summary', 'coverage_table'),
    downloadButton('download_coverage', 'Download coverage summary')
  ),
  nav_panel('CRM Membership & Schools',
    dashboard_card(card_header('Recorded membership status'), plotOutput('status_plot', height = '360px', fill = FALSE), DT::DTOutput('status_table')),
    layout_columns(fill = FALSE, fillable = FALSE, table_card('Recorded membership plans', 'plans'), table_card('Membership review indicators', 'reviews')),
    layout_columns(fill = FALSE, fillable = FALSE, table_card('School-contact review indicators', 'schools'), table_card('Roles among school-plan records', 'roles')),
    note('Review indicators can overlap and must not be added. School-contact findings mix record counts and organisation-group counts; read each row definition. Membership plans do not establish current membership.')
  ),
  nav_panel('GA4 Traffic',
    layout_sidebar(fillable = FALSE, fill = FALSE, sidebar = sidebar(
      sliderInput('months', 'Month range', min = min(data$monthly$date), max = max(data$monthly$date),
                  value = range(data$monthly$date), timeFormat = '%b %Y', step = 31),
      selectInput('channel', 'Traffic channel', c('All', sort(unique(data$monthly$channel)))),
      selectInput('traffic_compare_month', 'Month to compare', choices = format(sort(unique(data$monthly$date)), '%Y-%m'), selected = format(max(data$monthly$date), '%Y-%m')),
      note('Range controls charts, tables and range totals. Comparison uses its own month and the selected channel, including the previous calendar month outside the range.'),
      actionButton('reset_traffic', 'Reset Traffic filters'),
      downloadButton('download_traffic', 'Download filtered traffic')
    ),
    uiOutput('traffic_kpis'),
    uiOutput('traffic_comparison'),
    dashboard_card(card_header('Sessions by month — selected channels'), plotOutput('traffic_plot', height = '380px', fill = FALSE)),
    table_card('Monthly traffic — selected channels', 'traffic_table'),
    note('Engagement rate = selected engaged sessions / selected sessions. Active users are not summed across months.'))
  ),
  nav_panel('GA4 Content',
    layout_sidebar(fillable = FALSE, fill = FALSE, sidebar = sidebar(
      sliderInput('content_months', 'Content month range', min = min(data$pages$date), max = max(data$pages$date),
                  value = range(data$pages$date), timeFormat = '%b %Y', step = 31),
      selectInput('category', 'Content category', c('All', sort(unique(data$pages$category)))),
      selectInput('content_compare_month', 'Month to compare', choices = format(sort(unique(data$pages$date)), '%Y-%m'), selected = format(max(data$pages$date), '%Y-%m')),
      note('Range controls charts and tables. Comparison uses its own month and the selected category, including the previous calendar month outside the range. All channels are included.'),
      actionButton('reset_content', 'Reset Content filters'),
      downloadButton('download_pages', 'Download filtered page views')
    ),
    uiOutput('content_comparison'),
    dashboard_card(card_header('Top 15 pages by views — selected content'), plotOutput('pages_plot', height = '560px', fill = FALSE)),
    table_card('Page views — selected content', 'pages_table'),
    note('Categories follow URL rules used in the GA4 report. Full paths remain available in the table. Views count repeat page views; they are not unique visitors.'))
  )
)
server <- function(input, output, session) {
  observeEvent(input$reset_traffic, {
    updateSliderInput(session, 'months', value = range(data$monthly$date))
    updateSelectInput(session, 'channel', selected = 'All')
    updateSelectInput(session, 'traffic_compare_month', selected = format(max(data$monthly$date), '%Y-%m'))
  })
  observeEvent(input$reset_content, {
    updateSliderInput(session, 'content_months', value = range(data$pages$date))
    updateSelectInput(session, 'category', selected = 'All')
    updateSelectInput(session, 'content_compare_month', selected = format(max(data$pages$date), '%Y-%m'))
  })
  traffic_pair <- reactive({
    req(input$traffic_compare_month, input$channel)
    x <- data$monthly
    if (input$channel != 'All') x <- filter(x, channel == input$channel)
    month_pair(x, paste0(input$traffic_compare_month, '-01'))
  })
  content_pair <- reactive({
    req(input$content_compare_month, input$category)
    x <- data$pages
    if (input$category != 'All') x <- filter(x, category == input$category)
    month_pair(x, paste0(input$content_compare_month, '-01'))
  })
  output$traffic_comparison <- renderUI({
    p <- traffic_pair()
    if (!nrow(p$current) || !nrow(p$previous)) return(dashboard_card(
      card_header(paste('Monthly comparison:', p$label)),
      note('Comparison unavailable — selected channel has no exported rows for one or both months. Missing rows are not treated as zero.')))
    current <- sum(p$current$sessions); previous <- sum(p$previous$sessions)
    rate <- if (current > 0) 100 * sum(p$current$engaged_sessions) / current else NA_real_
    previous_rate <- if (previous > 0) 100 * sum(p$previous$engaged_sessions) / previous else NA_real_
    delta <- if (is.finite(rate) && is.finite(previous_rate)) sprintf('%+.1f percentage points vs previous month', rate - previous_rate) else 'Change unavailable — zero sessions'
    dashboard_card(card_header(paste('Monthly comparison:', p$label)),
      layout_columns(fill = FALSE, fillable = FALSE,
        value_box('Sessions in comparison month', fmt(current), relative_change(current, previous)),
        value_box('Engagement rate in comparison month', if (is.finite(rate)) sprintf('%.1f%%', rate) else 'Unavailable', delta)))
  })
  output$content_comparison <- renderUI({
    p <- content_pair()
    if (!nrow(p$current) || !nrow(p$previous)) return(dashboard_card(
      card_header(paste('Monthly comparison:', p$label)),
      note('Comparison unavailable — selected category has no exported rows for one or both months. Missing rows are not treated as zero.')))
    current <- sum(p$current$views); previous <- sum(p$previous$views)
    dashboard_card(card_header(paste('Monthly comparison:', p$label)),
      value_box('Views in comparison month', fmt(current), relative_change(current, previous)))
  })
  show_table <- function(x) {
    # Keep numeric values for correct sorting; format only their presentation.
    labels <- c(field = 'Field', records_populated = 'Records populated', coverage = 'Coverage',
      category = 'Review category', records = 'Records', status_key = 'Recorded status',
      plan = 'Membership plan', 'Review indicator' = 'Review indicator', Records = 'Records',
      finding = 'Review indicator', count = 'Count', group_role = 'Group role', share = 'Share',
      page = 'Page path', views = 'Views', Month = 'Month', Sessions = 'Sessions',
      'Engaged sessions' = 'Engaged sessions', content_category = 'Content category')
    headings <- ifelse(names(x) %in% names(labels), labels[names(x)], names(x))
    t <- DT::datatable(x, colnames = unname(headings), rownames = FALSE,
                      options = list(pageLength = 12, lengthMenu = c(12, 25, 50), scrollX = TRUE))
    numbers <- names(x)[vapply(x, is.numeric, logical(1))]
    percentages <- intersect(numbers, c('coverage', 'share'))
    counts <- setdiff(numbers, percentages)
    if (length(counts)) t <- DT::formatRound(t, counts, digits = 0, mark = ',')
    if (length(percentages)) t <- DT::formatPercentage(t, percentages, 1)
    t
  }
  output$coverage <- renderPlot({
    ggplot(data$coverage, aes(coverage, reorder(field, coverage))) + geom_col(fill = '#247c91') +
      scale_x_continuous(labels = scales::label_percent(), limits = c(0, 1)) + labs(x = 'Populated records (%)', y = NULL) + theme_minimal(base_size = 13)
  })
  output$coverage_table <- DT::renderDT(show_table(data$coverage |> select(field, records_populated, coverage)))
  output$duplicates <- DT::renderDT(show_table(data$duplicates))
  statuses <- reactive(data$statuses)
  output$status_plot <- renderPlot({
    ggplot(statuses(), aes(reorder(status_key, records), records)) + geom_col(fill = '#247c91') + coord_flip() + labs(x = NULL, y = 'CRM records') + theme_minimal(base_size = 13)
  })
  output$status_table <- DT::renderDT(show_table(statuses()))
  output$plans <- DT::renderDT(show_table(data$plans))
  output$reviews <- DT::renderDT(show_table(data$reviews))
  output$schools <- DT::renderDT(show_table(data$schools))
  output$roles <- DT::renderDT(show_table(data$roles))
  traffic <- reactive({
    x <- filter(data$monthly, date >= input$months[1], date <= input$months[2])
    if (input$channel != 'All') x <- filter(x, channel == input$channel)
    validate(need(nrow(x) > 0, 'No traffic data for this selection.'))
    x
  })
  totals <- reactive(traffic_summary(traffic()))
  output$traffic_kpis <- renderUI({
    x <- totals(); n <- sum(x$sessions)
    rate <- if (n > 0) sprintf('%.1f%%', 100 * sum(x$engaged_sessions) / n) else 'Unavailable'
    layout_columns(fill = FALSE, fillable = FALSE, value_box('Selected sessions', fmt(n)), value_box('Selected engagement rate', rate))
  })
  output$traffic_plot <- renderPlot({
    ggplot(totals(), aes(date, sessions)) +
      {if (nrow(totals()) > 1) geom_line(colour = '#247c91', linewidth = 1)} + geom_point(colour = '#247c91') +
      scale_x_date(date_labels = '%b %Y', date_breaks = '2 months') + scale_y_continuous(labels = scales::label_comma()) + labs(x = NULL, y = 'Sessions') + theme_minimal(base_size = 13)
  })
  # Present the monthly grain explicitly; retain Date internally for plotting.
  traffic_export <- reactive({
    totals() |> transmute(Month = format(date, '%Y-%m'),
                          Sessions = sessions, `Engaged sessions` = engaged_sessions)
  })
  output$traffic_table <- DT::renderDT(show_table(traffic_export()))
  page_views <- reactive({
    x <- filter(data$pages, date >= input$content_months[1], date <= input$content_months[2])
    if (input$category != 'All') x <- filter(x, category == input$category)
    x |> group_by(page, content_category = category) |>
      summarise(views = sum(views), .groups = 'drop') |> arrange(desc(views))
  })
  output$pages_plot <- renderPlot({
    x <- head(page_views(), 15)
    validate(need(nrow(x) > 0, 'No page data for this selection.'))
    ggplot(x, aes(views, reorder(page, views))) + geom_col(fill = '#247c91') +
      scale_y_discrete(labels = function(x) stringr::str_trunc(x, 55)) + labs(x = 'Views', y = NULL) + theme_minimal(base_size = 12)
  })
  output$pages_table <- DT::renderDT(show_table(page_views()))
  output$download_pages <- downloadHandler(filename = function() 'ga4_filtered_page_views.csv', content = function(file) readr::write_csv(page_views(), file))
  output$download_coverage <- downloadHandler(filename = function() 'crm_field_coverage.csv', content = function(file) readr::write_csv(data$coverage |> select(field, records_populated, coverage), file))
  output$download_traffic <- downloadHandler(filename = function() 'ga4_filtered_monthly_traffic.csv', content = function(file) readr::write_csv(traffic_export(), file))
}
shinyApp(ui, server)
