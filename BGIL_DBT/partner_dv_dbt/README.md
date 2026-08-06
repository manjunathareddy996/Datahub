# DEV_DV_DBT (partner_dv_dbt) — Partner Data Vault 2.0 (dbt on Snowflake)

This dbt project implements **Data Vault 2.0** for the **Partner** line of business at Bajaj Allianz General Insurance (BAGIC). It ingests party/customer/intermediary/provider data from the upstream OPUS system into a structured Snowflake data warehouse using [AutomateDV](https://automate-dv.readthedocs.io/).

> **Note:** Each LOB is maintained as its own separate dbt project. Health, Travel, and other LOBs have their own dedicated repositories/projects.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Partner Data Model](#partner-data-model)
- [Source Systems](#source-systems)
- [Configuration](#configuration)
- [Custom Macros](#custom-macros)
- [Orchestration](#orchestration)
- [How to Run](#how-to-run)
- [Tags Reference](#tags-reference)
- [Data Vault Concepts](#data-vault-concepts-quick-reference)

---

## Overview

| Item | Value |
|------|-------|
| **Project Name** | `dev_dv_dbt` |
| **Version** | 1.0.0 |
| **LOB Scope** | Partner (Party, Intermediary, Provider, Member) |
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
│  stg_partner__<table>  →  1:1 with source tables, typed/cast only   │
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
│   ├── staging/
│   │   └── partner/           # 31 staging models from 30 OPUS source tables
│   │
│   └── raw_vault/
│       └── partner/
│           ├── standard/      # Core vault entities
│           │   ├── hubs/      # 8 hub tables
│           │   ├── links/     # 3 link tables
│           │   ├── satellites/# 35 satellite tables
│           │   ├── staging/   # ~120 stg2_* intermediate views
│           │   ├── stitched/  # 13 stitch views (multi-table joins)
│           │   └── references/# Reference data (placeholder)
│           └── augmented/     # Extended attributes
│               ├── staging/   # 41 stg2_aug_* views
│               └── satellites/# 11 augmented satellites
│
├── macros/                    # Custom Jinja macros
├── seeds/                     # (empty)
├── tests/                     # (empty)
├── docs/
│   └── partner/               # Design documentation & build notes
└── dbt_packages/              # Vendored packages (automate_dv, dbt_utils)
```

---

## Partner Data Model

### Standard Layer (Core Vault)

| Entity Type | Count | Models |
|------------|-------|--------|
| **Hubs** | 8 | hub_party, hub_policy, hub_location, hub_claim, hub_agreement, hub_distribution_channel, hub_product, hub_risk_object |
| **Links** | 3 | lnk_party_location, lnk_policy_party, lnk_claim_party |
| **Satellites** | 35 | sat_party_identity, sat_party_demographics, sat_party_banking, sat_party_health, sat_party_identification, sat_policy_header, sat_policy_coverage, sat_policy_endorsement, sat_agreement, sat_common_address, sat_common_contact, sat_common_geo, and link-role satellites (agent, customer, provider, surveyor, nominee_beneficiary) |

### Augmented Layer (Extended Attributes)

| Entity Type | Count | Models |
|------------|-------|--------|
| **Augmented Staging** | 41 | stg2_aug_* views with unions |
| **Augmented Satellites** | 11 | sat_aug_party, sat_aug_policy, sat_aug_location, sat_aug_channel, sat_aug_agreement, sat_aug_affinity_membership, plus link-role augmented satellites |

### Source Tables

30 source tables from OPUS, including:
- `CP_PARTNERS`, `CP_ADDRESSES` — Core party and address master
- `BJAZ_INTERMEDIARY`, `BJAZ_INTERMEDIARY_HIST` — Intermediary/agent data
- `CLM_INTERESTED_PARTIES`, `CLM_SUPPLIERS` — Claim-related parties
- `AZBJ_ADDRESS_EXTN`, `AZBJ_PARTNER_EXTN` — Extension tables
- `BJAZ_HM_HOSPITAL_MASTER`, `BJAZ_HM_MEMBER_DTLS` — Hospital/member data

---

## Source Systems

| Source | Database | Schema | Purpose |
|--------|----------|--------|---------|
| partner_raw | BAGIC_PROD_MIRROR_DB | OPUS_GG_DWHSTAGE | Production source data |
| partner_test_raw | BAGIC_PREPROD_CURATED_DB | UTILS | Test/development data |

Source definitions: `models/staging/partner/_partner__sources.yml`

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
- 30-day log retention with automatic cleanup

---

## How to Run

### Prerequisites
- Snowflake account with appropriate roles
- dbt installed (or use Snowflake-native dbt execution)
- Packages are vendored locally (no `dbt deps` needed)

### Basic Commands

```bash
# Run all partner models
dbt run

# Run by vault layer
dbt run --select tag:partner_hub
dbt run --select tag:partner_lnk
dbt run --select tag:partner_sat

# Run augmented layer
dbt run --select tag:partner_aug

# Run staging only
dbt run --select tag:partner_stg

# Run with a specific date filter
dbt run --vars '{"run_date": "2024-03-15"}'

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
| `partner` | All partner models |
| `partner_stg` | Staging views (Layer 1) |
| `partner_stg2` | Intermediate staging (stg2_*) |
| `partner_stitch` | Stitch views (FULL OUTER JOINs) |
| `partner_hub` | Hub tables |
| `partner_lnk` | Link tables |
| `partner_sat` | Satellite tables |
| `partner_ref` | Reference data |
| `partner_aug` | All augmented models |
| `partner_aug_stg` | Augmented staging views |
| `partner_aug_sat` | Augmented satellite tables |

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

---

## Related Projects

| LOB | Repository | Status |
|-----|-----------|--------|
| **Partner** | This project | Active |
| **Health** | Separate dbt project | Separate repo |
| **Travel** | Separate dbt project | Planned |
