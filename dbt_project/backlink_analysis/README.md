# backlink_analysis dbt project

Transforms raw backlink data loaded by the ETL into three analytical mart tables.

## Models

- `staging/stg_referring_domains` - cleaned view over the raw ETL output in MotherDuck
- `marts/fct_backlink_summary` - referring domain counts and backlink volume per company
- `marts/fct_overlap_matrix` - backlink overlap between each competitor and Omni
- `marts/fct_backlink_opportunities` - domains linking to competitors but not Omni, tiered by priority

## Running

```
cd dbt_project/backlink_analysis
dbt run
dbt test
```

Requires a `~/.dbt/profiles.yml` entry named `backlink_analysis` pointing to your MotherDuck instance.