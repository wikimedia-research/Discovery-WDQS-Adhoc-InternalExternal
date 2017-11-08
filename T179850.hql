WITH wdqs_requests AS (
  SELECT
    CONCAT(year, '-', LPAD(month, 2, '0'), '-', LPAD(day, 2, '0')) AS date,
    IF(client_ip RLIKE '^10\\.', 'internal', 'external') AS traffic,
    referer_class AS referrer, agent_type,
    IF(agent_type = 'spider' OR (
      user_agent RLIKE 'https?://'
      OR INSTR(user_agent, 'github') > 0
      OR INSTR(user_agent, 'www') > 0
      OR LOWER(user_agent) RLIKE '([a-z0-9._%-]+@[a-z0-9.-]+\.(com|us|net|org|edu|gov|io|ly|co|uk))' -- emails
      OR user_agent IN('Mozilla', 'WikiDataMovieDB', 'C++ WikiAPI', 'Mozilla/5.0', 'Mozzila/5.0', 'Asparagus/Asparagus 0.1', 'tp', 'PHP')
      OR INSTR(user_agent, 'ChemAxon-Marvin') > 0
      OR INSTR(user_agent, 'cozy-stack') > 0
      OR INSTR(user_agent, 'petscan-agent') > 0
      OR INSTR(user_agent, 'Virtuoso') > 0
      OR INSTR(user_agent, 'rest-client') > 0
      OR INSTR(user_agent, 'axios') > 0
      OR INSTR(LOWER(user_agent), 'wikidata') > 0
      OR INSTR(LOWER(user_agent), 'node.js') > 0
      OR INSTR(LOWER(user_agent), 'sparql') > 0
      OR INSTR(LOWER(user_agent), 'script') > 0
      OR INSTR(user_agent, 'libcurl') > 0
    ), 'bot', 'user') AS agent_type_plus,
    CASE WHEN uri_path IN('/sparql', '/bigdata/namespace/wdq/sparql') THEN 'SPARQL endpoint'
         WHEN uri_path = '/bigdata/ldf' THEN 'LDF endpoint'
         ELSE 'homepage' END AS destination
  FROM wmf.webrequest
  WHERE
    webrequest_source = 'misc'
    AND year = ${year}
    AND uri_host = 'query.wikidata.org'
    AND uri_path IN('/', '/bigdata/namespace/wdq/sparql', '/bigdata/ldf', '/sparql')
    AND http_status IN('200','304')
)
SELECT date, traffic, referrer, agent_type, agent_type_plus, destination, COUNT(1) AS requests
FROM wdqs_requests
GROUP BY date, traffic, referrer, agent_type, agent_type_plus, destination;
