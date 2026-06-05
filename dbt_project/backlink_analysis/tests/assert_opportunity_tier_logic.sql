-- Validates that opportunity_tier labels match the competitor_count thresholds.
-- High priority must have competitor_count >= 5,
-- Medium priority must have competitor_count between 3 and 4,
-- Low priority must have competitor_count <= 2.
-- Any rows returned mean the CASE logic is misaligned with the tier labels.
SELECT referring_domain, competitor_count, opportunity_tier
FROM {{ ref('fct_backlink_opportunities') }}
WHERE
    (opportunity_tier = 'High priority'   AND competitor_count < 5)
 OR (opportunity_tier = 'Medium priority' AND competitor_count NOT BETWEEN 3 AND 4)
 OR (opportunity_tier = 'Low priority'    AND competitor_count > 2)
