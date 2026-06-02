import duckdb
import os
import gzip
import requests
import pandas as pd
from dotenv import load_dotenv

load_dotenv()
TOKEN = os.getenv("MOTHERDUCK_TOKEN")

RELEASE = "cc-main-2026-mar-apr-may"
BASE = f"https://data.commoncrawl.org/projects/hyperlinkgraph/{RELEASE}/domain"

DOMAINS = {
    "omni":      "omniapp.co",
    "looker":    "looker.com",
    "tableau":   "tableau.com",
    "metabase":  "metabase.com",
    "mode":      "mode.com",
    "lightdash": "lightdash.com",
    "hex":       "hex.tech",
    "sigma":     "sigmacomputing.com",
}

def main():
    print("Connecting to MotherDuck...")
    con = duckdb.connect(f"md:backlink_analysis?motherduck_token={TOKEN}")
    con.execute("CREATE SCHEMA IF NOT EXISTS raw")
    con.execute("CREATE SCHEMA IF NOT EXISTS staging")

    # Step 1: Stream vertices, build ID maps
    print("\nStep 1: Streaming vertices to build ID maps...")
    vert_url = f"{BASE}/{RELEASE}-domain-vertices.txt.gz"
    resp = requests.get(vert_url, stream=True, timeout=120)
    resp.raise_for_status()

    target_rev = {".".join(reversed(d.split("."))): (company, d)
                  for company, d in DOMAINS.items()}

    id_to_target = {}   # node_id -> (target_domain, company) for our 8 targets
    id_to_domain = {}   # node_id -> domain string for ALL nodes (for source lookup)

    with gzip.GzipFile(fileobj=resp.raw) as f:
        for line in f:
            parts = line.decode("utf-8").strip().split("\t")
            if len(parts) < 2:
                continue
            try:
                nid = int(parts[0])
                rev = parts[1].strip()
                domain = ".".join(reversed(rev.split(".")))
                id_to_domain[nid] = domain
                if rev in target_rev:
                    company, d = target_rev[rev]
                    id_to_target[nid] = (d, company)
            except ValueError:
                continue

    target_ids = set(id_to_target.keys())
    print(f"  Target IDs found: {len(target_ids)} — {target_ids}")
    print(f"  Total domains in map: {len(id_to_domain)}")

    # Step 2: Stream edges, filter only edges pointing TO our targets
    print("\nStep 2: Streaming edges (filtering on the fly)...")
    edges_url = f"{BASE}/{RELEASE}-domain-edges.txt.gz"
    resp2 = requests.get(edges_url, stream=True, timeout=300)
    resp2.raise_for_status()

    records = []
    count = 0
    with gzip.GzipFile(fileobj=resp2.raw) as f:
        for line in f:
            count += 1
            if count % 50_000_000 == 0:
                print(f"  Processed {count:,} edges, found {len(records):,} matches so far...")
            parts = line.decode("utf-8").strip().split("\t")
            if len(parts) < 2:
                continue
            try:
                from_id = int(parts[0])
                to_id = int(parts[1])
                if to_id in target_ids:
                    target_domain, company = id_to_target[to_id]
                    referring_domain = id_to_domain.get(from_id, f"id_{from_id}")
                    records.append((referring_domain, target_domain, company))
            except ValueError:
                continue

    print(f"  Done. Processed {count:,} edges, found {len(records):,} matching edges")

    if not records:
        print("No edges found.")
        return

    # Step 3: Aggregate and load
    print("\nStep 3: Aggregating and loading to MotherDuck...")
    df = pd.DataFrame(records, columns=["referring_domain", "target_domain", "company"])
    result = df.groupby(["target_domain", "company", "referring_domain"]).size().reset_index(name="link_count")

    con.execute("CREATE OR REPLACE TABLE staging.referring_domains AS SELECT * FROM result")

    count = con.execute("SELECT COUNT(*) FROM staging.referring_domains").fetchone()[0]
    print(f"\nLoaded {count} referring domain rows into MotherDuck ✅")

    print("\nReferring domains per company:")
    print(con.execute("""
        SELECT company, COUNT(DISTINCT referring_domain) AS total_referring_domains
        FROM staging.referring_domains
        GROUP BY 1 ORDER BY 2 DESC
    """).df())

    con.close()

if __name__ == "__main__":
    main()
