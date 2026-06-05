-- Omni's own referring domains must never appear in the opportunities list.
-- The model filters them out via LEFT JOIN + WHERE IS NULL.
-- Any rows returned here mean that filter broke.
SELECT referring_domain
FROM {{ ref('fct_backlink_opportunities') }}
WHERE referring_domain IN (
    SELECT DISTINCT referring_domain
    FROM {{ ref('stg_referring_domains') }}
    WHERE company = 'omni'
)
