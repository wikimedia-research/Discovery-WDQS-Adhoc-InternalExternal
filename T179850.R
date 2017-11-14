library(magrittr)
library(ggplot2)

requests <- readr::read_csv("T179850.csv") %>%
  dplyr::arrange(date, traffic)

requests %>%
  dplyr::group_by(date, traffic, destination, agent = agent_type_plus) %>%
  dplyr::summarize(requests = sum(requests)) %>%
  ggplot(aes(x = date, y = requests)) +
  geom_area(color = "black") +
  facet_grid(destination + agent ~ traffic, scales = "free_y") +
  scale_y_continuous(labels = polloi::compress) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_fill_brewer(palette = "Set1") +
  wmf::theme_facet(14, "Open Sans", strip.text.y = element_text(angle = 0)) +
  labs(
    x = "Date", y = "Requests per day",
    title = "Wikidata Query Service usage by traffic, agent type, and destination",
    subtitle = "Internal means the IP address started with a \"10.\"",
    caption = "In general we get quite a bit of external traffic from bots to the SPARQL endpoint.
    In addition to the current \"bot\" detection, this includes requests from user agents that include a GitHub URL."
  )

requests %>%
  dplyr::group_by(date, traffic, destination, agent = agent_type) %>%
  dplyr::summarize(requests = sum(requests)) %>%
  ggplot(aes(x = date, y = requests)) +
  geom_area(color = "black") +
  facet_grid(destination + agent ~ traffic, scales = "free_y") +
  scale_y_continuous(labels = polloi::compress) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_fill_brewer(palette = "Set1") +
  wmf::theme_facet(14, "Open Sans", strip.text.y = element_text(angle = 0)) +
  labs(
    x = "Date", y = "Requests per day",
    title = "Wikidata Query Service usage by traffic, agent type, and destination",
    subtitle = "Internal means the IP address started with a \"10.\"",
    caption = "In general we get quite a bit of external traffic from bots to the SPARQL endpoint.
    These requests were split according to the current \"bot\" detection."
  )

requests %>%
  dplyr::group_by(date, traffic) %>%
  dplyr::summarize(requests = sum(requests)) %>%
  ggplot(aes(x = date, y = requests)) +
  geom_area(color = "black") +
  facet_wrap(~ traffic, scales = "free_y") +
  scale_y_continuous(labels = polloi::compress) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b") +
  scale_fill_brewer(palette = "Set1") +
  wmf::theme_facet(14, "Open Sans", strip.text.y = element_text(angle = 0)) +
  labs(
    x = "Date", y = "Requests per day",
    title = "Wikidata Query Service usage by traffic, agent type, and destination",
    subtitle = "Internal means the IP address started with a \"10.\"",
    caption = "In general we get quite a bit of external traffic from bots to the SPARQL endpoint.
    These requests were split according to the current \"bot\" detection."
  )

sparql <- readr::read_csv("T179850v2.csv") %>%
  dplyr::arrange(date, traffic)

ggplot(sparql, aes(x = date, y = total_ttfb)) +
  geom_bar(stat = "identity") +
  facet_grid(agent_type ~ traffic, scales = "free_y") +
  scale_y_continuous(labels = function(x) {
    return(gsub(" 0s", "", tolower(lubridate::seconds_to_period(x)), fixed = TRUE))
  }) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b '%y") +
  wmf::theme_facet(14, "Open Sans", strip.text.y = element_text(angle = 0)) +
  labs(
    x = "Date", y = "Total time to first byte (s)",
    title = "SPARQL query execution time by traffic and (basic) agent type",
    subtitle = "Internal means the IP address started with a \"10.\""
  )

ggplot(sparql, aes(x = date, y = total_ttfb)) +
  geom_bar(stat = "identity") +
  facet_grid(agent_type_plus ~ traffic, scales = "free_y") +
  scale_y_continuous(labels = function(x) {
    return(gsub(" 0s", "", tolower(lubridate::seconds_to_period(x)), fixed = TRUE))
  }) +
  scale_x_date(date_breaks = "1 month", date_labels = "%b '%y") +
  wmf::theme_facet(14, "Open Sans", strip.text.y = element_text(angle = 0)) +
  labs(
    x = "Date", y = "Total time to first byte (s)",
    title = "SPARQL query execution time by traffic and (extended) agent type",
    subtitle = "Internal means the IP address started with a \"10.\"",
    caption = "Extended spider detection includes UAs with GitHub URLs (for example)."
  )
