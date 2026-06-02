WITH omni AS (
    SELECT DISTINCT referring_domain
    FROM {{ ref('stg_referring_domains') }}
    WHERE company = 'omni'
),
competitors AS (
    SELECT company, referring_domain
    FROM {{ ref('stg_referring_domains') }}
    WHERE company != 'omni'
)
SELECT
    c.company AS competitor,
    COUNT(DISTINCT c.referring_domain) AS competitor_total_domains,
    COUNT(DISTINCT CASE WHEN o.referring_domain IS NOT NULL
                        THEN c.referring_domain END) AS shared_with_omni,
    ROUND(
        COUNT(DISTINCT CASE WHEN o.referring_domain IS NOT NULL
                            THEN c.referring_domain END) * 100.0
        / NULLIF(COUNT(DISTINCT c.referring_domain), 0), 1
    ) AS overlap_pct
FROM competitors c
LEFT JOIN omni o ON c.referring_domain = o.referring_domain
GROUP BY 1
ORDER BY shared_with_omni DESC
