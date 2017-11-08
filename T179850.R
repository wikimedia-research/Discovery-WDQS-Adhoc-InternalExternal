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
