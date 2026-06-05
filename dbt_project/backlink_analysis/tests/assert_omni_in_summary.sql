-- Omni must have at least one row in the backlink summary.
-- If this returns rows it means the ETL produced no data for omniapp.co,
-- which would silently make every downstream comparison meaningless.
SELECT 'omni missing from summary' AS failure_reason
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ ref('fct_backlink_summary') }}
    WHERE company = 'omni'
)
