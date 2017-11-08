# Remotely:
library(magrittr)

query <- "WITH wdqs_requests AS (
  SELECT
    ts,
    IF(client_ip RLIKE '^10\\.', 'internal', 'external') AS traffic,
    IF(uri_path = '/bigdata/namespace/wdq/sparql', '/sparql', uri_path) AS destination,
    COUNT(1) AS requests
  FROM wmf.webrequest
  WHERE
    webrequest_source = 'misc'
    AND year = ${year} AND month = ${month} AND day = ${day}
    AND uri_host = 'query.wikidata.org'
    AND uri_path IN('/bigdata/namespace/wdq/sparql', '/bigdata/ldf', '/sparql')
    AND http_status IN('200','304')
  GROUP BY
    ts,
    IF(client_ip RLIKE '^10\\.', 'internal', 'external'),
    IF(uri_path = '/bigdata/namespace/wdq/sparql', '/sparql', uri_path)
)
SELECT
  CONCAT(TO_DATE(ts), ' ', HOUR(ts), ':00:00') AS ts,
  traffic, destination,
  PERCENTILE(requests, 0.5) AS median,
  PERCENTILE(requests, 0.99) AS percentile99,
  MAX(requests) AS maximum
FROM wdqs_requests
GROUP BY CONCAT(TO_DATE(ts), ' ', HOUR(ts), ':00:00'), traffic, destination"

start_date <- as.Date("2017-10-01")
end_date <- as.Date("2017-10-31")
results <- dplyr::bind_rows(lapply(seq(start_date, end_date, by = "day"), function(.date) {
  year <- lubridate::year(.date)
  month <- lubridate::month(.date)
  day <- lubridate::mday(.date)
  query <- glue::glue(query, .open = "${")
  message(glue::glue("Fetching WDQS traffic from {year}-{month}-{day}"))
  result <- wmf::query_hive(query)
  result$ts <- lubridate::ymd_hms(result$ts)
  result$median <- as.integer(ceiling(result$median))
  result$percentile99 <- as.integer(ceiling(result$percentile99))
  result$maximum <- as.integer(ceiling(result$maximum))
  return(result)
}))

results <- results[order(results$ts, results$traffic, results$destination), ]

readr::write_csv(results, "wdqs-oct17-per-sec.csv")

# Locally:
library(magrittr)
library(ggplot2)

# system("scp stat5:/home/bearloga/wdqs-oct17-per-sec.csv ./")
requests <- readr::read_csv("wdqs-oct17-per-sec.csv") %>%
  dplyr::rename(`99th percentile` = percentile99) %>%
  tidyr::gather("summary", "requests", -c(ts, traffic, destination)) %>%
  tidyr::spread(summary, requests, fill = 0) %>%
  tidyr::gather("per-hour summary", "requests", -c(ts, traffic, destination))

ggplot(requests, aes(x = ts, y = requests, color = `per-hour summary`)) +
  geom_line() +
  scale_color_brewer(palette = "Set1") +
  facet_grid(destination ~ traffic, scales = "free_y") +
  wmf::theme_facet(14, "Open Sans", strip.text.y = element_text(angle = 0)) +
  labs(
    x = "Date", y = "Requests per second",
    title = "WDQS per-second internal vs external SPARQL & LDF endpoint usage during Oct 2017",
    subtitle = "Internal means the IP address started with a \"10.\"; aggregates were made on an hourly basis",
    caption = "Most of the time there are fewer than 100 internal requests per second to the SPARQL endpoint.
    External usage of SPARQL endpoint varies considerably, with as many as 500 reqs/sec observed during one hour on October 14th."
  )
