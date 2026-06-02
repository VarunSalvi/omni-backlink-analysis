SELECT
    target_domain,
    company,
    referring_domain,
    link_count
FROM {{ source('staging', 'referring_domains') }}
WHERE referring_domain IS NOT NULL
  AND referring_domain != ''
