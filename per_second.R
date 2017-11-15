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
# system("scp stat5:/home/bearloga/wdqs-oct17-per-sec.csv ./")
