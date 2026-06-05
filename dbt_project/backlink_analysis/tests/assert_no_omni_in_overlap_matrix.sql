-- The overlap matrix should only contain competitors, never omni itself.
-- Omni is the baseline being compared against, not a competitor row.
SELECT competitor
FROM {{ ref('fct_overlap_matrix') }}
WHERE competitor = 'omni'
