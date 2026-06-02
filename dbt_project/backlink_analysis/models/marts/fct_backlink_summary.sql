SELECT
    company,
    target_domain,
    COUNT(DISTINCT referring_domain) AS total_referring_domains,
    SUM(link_count)                  AS total_backlinks,
    ROUND(AVG(link_count), 2)        AS avg_links_per_domain
FROM {{ ref('stg_referring_domains') }}
GROUP BY 1, 2
ORDER BY total_referring_domains DESC
