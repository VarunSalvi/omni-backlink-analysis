# Omni Backlink Competitive Analysis

## How to reproduce
1. Clone repo: `git clone https://github.com/VarunSalvi/omni-backlink-analysis`
2. `python3 -m venv venv && source venv/bin/activate`
3. `pip install -r requirements.txt`
4. Copy `.env.example` to `.env` and add your `MOTHERDUCK_TOKEN`
5. `python etl/extract_backlinks.py` (~20 min, streams 4.3B edges)
6. `cd dbt_project/backlink_analysis && dbt run`
7. Connect MotherDuck to Omni via Settings -> Connections
8. Create topics from each mart table in Omni Develop
9. Dashboard: https://vmsalvi.omniapp.co/dashboards/c271aa05

## Key design decisions
- Used Common Crawl Web Graph (cc-main-2026-mar-apr-may) - domain-level edges
- Streamed 4.3B edges filtering only 8 target domains to avoid OOM errors
- Chose 8 competitors: Looker, Tableau, Metabase, Mode, Lightdash, Hex, Sigma
- dbt-duckdb adapter connects directly to MotherDuck - no separate warehouse needed
- Opportunity tier scoring: 5+ competitors = High, 3+ = Medium, else Low

## Explicit limitations
- CC Web Graph domain edges use numeric IDs - domain names resolved via vertices file
- No domain authority score (would require Ahrefs/Moz API - paid)
- Data reflects crawls from March-May 2026 snapshot only
- Omni (omniapp.co) had only 9 referring domains - likely underrepresented in CC crawl

## Executive Summary

Omni has 9 referring domains compared to Tableau's 41,118 - a 4,500x gap. Mid-tier
competitors Metabase (1,713), Looker (1,587), and Mode (1,038) show what is achievable
at Omni's stage. Lightdash (187) and Hex (761) are closest peers by backlink profile.

Analysis of 4.3 billion web graph edges identified 47,114 domains linking to at least
one competitor but not Omni. Of these, 107 are High priority (linking to 5+ competitors),
419 are Medium priority (3-4 competitors), and 43,558 are Low priority (1-2 competitors).

The top High priority targets - querio.ai, zenn.dev, beehiiv.com, holistics.io,
getdbt.com, ycombinator.com, and secoda.co - each link to all 7 competitors and represent
the strongest signal of editorial interest in the analytics/BI space. Backlink strength
is approximated by total_competitor_links percentile rank, a proxy for domain activity
within this category (true authority scores require a paid API such as Ahrefs or Moz).

Omni's growth marketing team should prioritize outreach to the 107 High priority domains
first. A secondary pipeline of 419 Medium priority domains provides further reach. The
data suggests Omni is severely underlinked relative to peers and has significant untapped
backlink opportunity in the analytics/BI content ecosystem.