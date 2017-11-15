This shows a breakdown of internal vs external WDQS usage for
Phabricator task [T179850](https://phabricator.wikimedia.org/T179850).

Per-second traffic/usage
------------------------

![Per-second count of requests made to SPARQL & LDF endpoint during
October 2017, broken down by internal vs external
traffic.](figures/per_sec_requests-1.png)

Most of the time there are fewer than 100 internal requests per second
to the SPARQL endpoint. External usage of SPARQL endpoint varies
considerably, with as many as 500 reqs/sec observed during one hour on
October 14th.

Daily traffic/usage
-------------------

In general we get quite a bit of external traffic from bots to the
SPARQL endpoint:

### Requests

![](figures/by_traffic_agent_destination-1.png)

![](figures/by_traffic_agent_destination-2.png)

![](figures/by_traffic_agent_destination-3.png)

### Time to first byte (TTFB)

![](figures/ttfb-1.png)

![](figures/ttfb-2.png)
