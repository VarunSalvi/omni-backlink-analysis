WITH omni_domains AS (
    SELECT DISTINCT referring_domain
    FROM {{ ref('stg_referring_domains') }}
    WHERE company = 'omni'
),
competitor_links AS (
    SELECT
        referring_domain,
        COUNT(DISTINCT company)                    AS competitor_count,
        SUM(link_count)                            AS total_competitor_links,
        STRING_AGG(company, ', ' ORDER BY company) AS linked_competitors
    FROM {{ ref('stg_referring_domains') }}
    WHERE company != 'omni'
    GROUP BY 1
)
SELECT
    c.referring_domain,
    c.competitor_count,
    c.total_competitor_links,
    c.linked_competitors,
    CASE
        WHEN c.competitor_count >= 5 THEN 'High priority'
        WHEN c.competitor_count >= 3 THEN 'Medium priority'
        ELSE 'Low priority'
    END AS opportunity_tier,
    NTILE(100) OVER (ORDER BY c.total_competitor_links) AS link_volume_percentile
FROM competitor_links c
LEFT JOIN omni_domains o ON c.referring_domain = o.referring_domain
WHERE o.referring_domain IS NULL
ORDER BY c.competitor_count DESC, c.total_competitor_links DESC
