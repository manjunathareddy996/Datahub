# DEV_DV_DBT — Data Vault 2.0 on Snowflake

A **dbt** project implementing **Data Vault 2.0** methodology for Bajaj Allianz General Insurance (BAGIC). It ingests data from the upstream OPUS system into a structured Snowflake data warehouse using the [AutomateDV](https://automate-dv.readthedocs.io/) package.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Lines of Business (LOBs)](#lines-of-business-lobs)
- [Source Systems](#source-systems)
- [Configuration](#configuration)
- [Custom Macros](#custom-macros)
- [Orchestration](#orchestration)
- [How to Run](#how-to-run)
- [Tags Reference](#tags-reference)
- [Documentation](#documentation)

---

## Overview

| Item | Value |
|------|-------|
| **Project Name** | `dev_dv_dbt` |
| **Version** | 1.0.0 |
| **Platform** | Snowflake |
| **Methodology** | Data Vault 2.0 |
| **Key Packages** | AutomateDV 0.11.5, dbt_utils 1.1.1 |
| **Database** | BAGIC_PREPROD_CURATED_DB |
| **Schema** | BGIL_DEV_DATA_MODEL |
| **Warehouse** | BAGIC_DPM_MAXI_RAW_WH |
| **Source System** | OPUS (GG_DWHSTAGE) |

---

## Architecture

The project follows a three-layer pattern:

```
┌──────────────────────────────────────────────────────────────────────┐
│  LAYER 1: Staging (views)                                            │
│  stg_<lob>__<table>  →  1:1 with source tables, typed/cast only     │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│  LAYER 2: Intermediate Staging + Stitching (views)                   │
│  stg2_*       →  Hash key computation, role-based fan-out            │
│  stitch_*     →  FULL OUTER JOIN to assemble complete satellite rows │
└──────────────────────────────┬───────────────────────────────────────┘
                               │
                               ▼
┌──────────────────────────────────────────────────────────────────────┐
│  LAYER 3: Raw Vault (incremental tables)                             │
│  hub_*   →  Business keys, hash key, load datetime, record source   │
│  lnk_*   →  Relationships between hubs                              │
│  sat_*   →  Descriptive attributes with change detection (hashdiff) │
└──────────────────────────────────────────────────────────────────────┘
```

**Key principle:** Every hub, link, and satellite reads from exactly ONE upstream `ref()`. Multiple source tables are unified at the stg2/stitch layer before reaching the vault.

---

## Project Structure

```
DEV_DV_DBT/
├── dbt_project.yml            # Project configuration
├── profiles.yml               # Snowflake connection profiles (dev / prod)
├── packages.yml               # dbt package dependencies
├── dbt_schedular.sql          # Snowflake orchestrator stored procedure
│
├── models/
│   ├── staging/               # Layer 1: Source-aligned views
│   │   ├── partner/           # 31 staging models from OPUS partner tables
│   │   ├── health/            # 117 staging models from OPUS health tables
│   │   └── travel/            # (placeholder — not yet built)
│   │
│   └── raw_vault/             # Layers 2 & 3: Vault models
│       ├── partner/
│       │   ├── standard/      # Core vault entities
│       │   │   ├── hubs/      # 8 hub tables
│       │   │   ├── links/     # 3 link tables
│       │   │   ├── satellites/# 35 satellite tables
│       │   │   ├── staging/   # ~120 stg2_* intermediate views
│       │   │   ├── stitched/  # 13 stitch views (multi-table joins)
│       │   │   └── references/# Reference data (placeholder)
│       │   └── augmented/     # Extended attributes
│       │       ├── staging/   # 41 stg2_aug_* views
│       │       └── satellites/# 11 augmented satellites
│       │
│       ├── health/
│       │   └── augmented/     # Health-specific extended attributes
│       │       ├── staging/   # 71 stg2_aug_* views
│       │       └── satellites/# 15 augmented satellites
│       │
│       └── travel/            # (placeholder — not yet built)
│
├── macros/                    # Custom Jinja macros
├── seeds/                     # (empty)
├── tests/                     # (empty)
├── docs/                      # Build notes & design documentation
│   ├── partner/
│   └── health/
└── dbt_packages/              # Vendored packages (automate_dv, dbt_utils)
```

---

## Lines of Business (LOBs)

### Partner (fully built)

Core entities for party/customer/intermediary data:

| Entity Type | Models | Examples |
|------------|--------|----------|
| Hubs | 8 | hub_party, hub_policy, hub_location, hub_claim, hub_agreement, hub_distribution_channel, hub_product, hub_risk_object |
| Links | 3 | lnk_party_location, lnk_policy_party, lnk_claim_party |
| Satellites | 35 | sat_party_identity, sat_party_demographics, sat_policy_header, sat_common_address, sat_common_contact, etc. |
| Augmented Sats | 11 | sat_aug_party, sat_aug_policy, sat_aug_location, etc. |

### Health (augmented layer built)

Health insurance claims, policies, and members:

| Entity Type | Models | Source Tables |
|------------|--------|--------------|
| Augmented Staging | 71 | 107 OPUS health tables |
| Augmented Sats | 15 | sat_aug_claim, sat_aug_policy, sat_aug_party, sat_aug_product, sat_aug_coverage, etc. |

### Travel (placeholder)

Not yet implemented — folder structure created.

---

## Source Systems

All data originates from the **OPUS** core insurance platform:

| Source | Database | Schema | LOB |
|--------|----------|--------|-----|
| partner_raw | BAGIC_PROD_MIRROR_DB | OPUS_GG_DWHSTAGE | Partner |
| health_raw | BAGIC_PROD_MIRROR_DB | OPUS_GG_DWHSTAGE | Health |
| partner_test_raw | BAGIC_PREPROD_CURATED_DB | UTILS | Partner (test) |
| health_test_raw | BAGIC_PREPROD_CURATED_DB | UTILS | Health (test) |

Source definitions are in:
- `models/staging/partner/_partner__sources.yml`
- `models/staging/health/_health__sources.yml`

---

## Configuration

### Profiles (`profiles.yml`)

| Target | Role | Warehouse | Database |
|--------|------|-----------|----------|
| **dev** | INGESTION_PREPROD_ROLE | BAGIC_DPM_MAXI_RAW_WH | BAGIC_PREPROD_CURATED_DB |
| **prod** | EMPOWER_FOUNDATION_ROLE | BAGIC_DPM_MAXI_RAW_WH | BAGIC_PREPROD_CURATED_DB |

Connection credentials are managed via Snowflake CLI environment variables at deploy time.

### Key Variables (`dbt_project.yml`)

| Variable | Default | Purpose |
|----------|---------|---------|
| `partner_raw_database` | BAGIC_PROD_MIRROR_DB | Partner source database |
| `partner_raw_schema` | OPUS_GG_DWHSTAGE | Partner source schema |
| `health_raw_database` | BAGIC_PROD_MIRROR_DB | Health source database |
| `health_raw_schema` | OPUS_GG_DWHSTAGE | Health source schema |
| `run_date` | 2026-02-20 | Filter source data to a single day |

### Model Hooks (dev target only)

- **Pre-hook**: Inserts a `RUNNING` status row into `MAXI_RAW_DBT_MODEL_RUN_LOG`
- **Post-hook**: Updates status to `SUCCESS` on completion

---

## Custom Macros

| Macro | Purpose |
|-------|---------|
| `generate_schema_name` | Uses the custom schema name directly (no default prefix concatenation) |
| `get_run_date` | Returns a configurable date for source filtering. Override: `--vars '{"run_date": "2024-02-20"}'` |
| `hash` | MD5 hashing for single or composite columns (UPPER + TRIM + COALESCE + CONCAT_WS) |
| `hash_diff` | MD5-based hashdiff for satellite change detection |
| `location_address_key` | Documents the canonical composite-text-key rule for HUB_LOCATION (reference only) |
| `sat_multi_source` | Extends `automate_dv.sat()` to handle multiple source models via UNION ALL with superset column alignment and change detection |

---

## Orchestration

The project includes a Snowflake stored procedure (`dbt_schedular.sql`) for automated execution:

**Procedure:** `BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_ORCHESTRATOR_SP2`

### Run Modes

| Mode | Description |
|------|-------------|
| `full` | Runs all models end-to-end |
| `retry` | Re-runs only failed models from a specific run |
| `rerun` | Re-runs a complete prior run |
| `manual` | Runs specific models by name |

### Features
- Executes dbt via Snowflake-native `EXECUTE DBT PROJECT`
- Tracks every model run in `MAXI_RAW_DBT_MODEL_RUN_LOG`
- Sends HTML email reports on success/failure via AWS SES
- Cross-validates run results against checkpoint table
- 30-day log retention with automatic cleanup

---

## How to Run

### Prerequisites
- Snowflake account with appropriate roles
- dbt installed (or use Snowflake-native dbt execution)
- Packages are vendored locally (no `dbt deps` needed)

### Basic Commands

```bash
# Run all models
dbt run

# Run a specific LOB
dbt run --select tag:partner
dbt run --select tag:health

# Run specific layer
dbt run --select tag:partner_hub
dbt run --select tag:partner_lnk
dbt run --select tag:partner_sat

# Run with a specific date filter
dbt run --vars '{"run_date": "2024-03-15"}'

# Run augmented models only
dbt run --select tag:partner_aug
dbt run --select tag:health_aug

# Run staging only
dbt run --select tag:partner_stg

# Full refresh (rebuild incremental tables from scratch)
dbt run --full-refresh --select tag:partner
```

### Via Snowflake Orchestrator

```sql
-- Full run
CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_ORCHESTRATOR_SP2('full');

-- Retry failed models from a specific run
CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_ORCHESTRATOR_SP2('retry', '<run_id>');

-- Run specific models
CALL BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_ORCHESTRATOR_SP2('manual', '', 'hub_party+lnk_party_location');
```

---

## Tags Reference

| Tag | Scope |
|-----|-------|
| `partner` | All partner LOB models |
| `partner_stg` | Partner staging views |
| `partner_stg2` | Partner intermediate staging (stg2_*) |
| `partner_stitch` | Partner stitch views |
| `partner_hub` | Partner hub tables |
| `partner_lnk` | Partner link tables |
| `partner_sat` | Partner satellite tables |
| `partner_ref` | Partner reference data |
| `partner_aug` | Partner augmented (all) |
| `partner_aug_stg` | Partner augmented staging |
| `partner_aug_sat` | Partner augmented satellites |
| `health` | All health LOB models |
| `health_stg` | Health staging views |
| `health_stg2` | Health intermediate staging |
| `health_stitch` | Health stitch views |
| `health_hub` | Health hub tables |
| `health_lnk` | Health link tables |
| `health_sat` | Health satellite tables |
| `health_ref` | Health reference data |
| `health_aug` | Health augmented (all) |
| `health_aug_stg` | Health augmented staging |
| `health_aug_sat` | Health augmented satellites |

---

## Documentation

Detailed build notes and architecture decisions are in `docs/`:

- `docs/partner/` — Partner LOB design notes
- `docs/health/HEALTH_DV_BUILD_NOTES.md` — Comprehensive health vault architecture including satellite stitching methodology, composite key strategy, hash namespacing, and subject-attribution corrections

---

## Data Vault Concepts (Quick Reference)

| Concept | Implementation |
|---------|---------------|
| **Hub** | Stores unique business keys (e.g., party ID, policy number). Uses `automate_dv.hub()` |
| **Link** | Captures relationships between hubs. Uses `automate_dv.link()` |
| **Satellite** | Stores descriptive attributes with full history (change detection via hashdiff). Uses `automate_dv.sat()` |
| **Stitch** | FULL OUTER JOIN of multiple source tables into one complete satellite row per key |
| **Hash Key** | MD5 hash of business key(s) — deterministic, collision-resistant surrogate |
| **Hashdiff** | MD5 hash of all payload columns — detects attribute changes for incremental loads |
| **Load Datetime** | Timestamp of when data was loaded into the vault |
| **Record Source** | Identifies which source system/table the data came from |
