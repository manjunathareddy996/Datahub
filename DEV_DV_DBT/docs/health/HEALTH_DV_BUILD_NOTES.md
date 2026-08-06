# Health LOB Data Vault — dbt Build Notes

Generated from:
- `data_v4.js` — canonical GI Data Vault 2.0 model (20 hubs / 71 links / 363 sats / 54 refs)
- `Health_SourceToModel_Mapping_v5.xlsx` — Health LOB source-to-model mapping (129 source
  tables, 3,103 columns processed, 2,394 mapped)
- `DWH_OPUS_columns_list_3185_tables.xlsx` — full OPUS source schema (used for column data
  types, and for hub-key discovery — see §2)

Target platform: **Snowflake**. This is a build (no `dbt run`/`dbt test` executed yet) — see
"Before you run this" at the end.

**This is v5 of the build.** Sections 1-11 below describe the original architecture and are
still accurate on *method*, but several of their coverage numbers (hub/link/satellite counts,
gap lists) are from v1/v2 and are superseded by **§12** (mapper Q&A round — composite keys,
hash namespacing) and **§14** (the mapping workbook's own v5 subject-attribution fix, folded
in on top). Read §12 and §14 for the current state; MAPPER_NOTE_V5_FOLLOWUP.md has the open
items from §14 that still need the mapper's input.

## 14. Subject-attribution fix (v5 mapping) — read this section last, it's the current state

The mapping workbook was independently corrected at the source for a real data-correctness bug:
several columns (nominee name, RM name, intermediary name, hospital name, hospital address)
were being loaded onto the **wrong party** — whichever business key the table's *other* columns
happened to use, not the actual subject of that column. E.g. `PD_IMD_RM_NAME` (the IMD
relationship manager's name) was being recorded as if it were the premium payer's name. This is
the same bug independently confirmed and worked through with you earlier in this session (see
the `SAT_PARTY_IDENTITY` / "office vs home" discussion above) — the mapping owner fixed it at
the source in parallel via `Health_SourceToModel_Mapping_v5.xlsx` (see `V5_CHANGE_NOTE.md` in
the project root) and it's now been fully integrated.

**How it works**: the workbook's `Subject-Attribution Fixes` sheet marks each affected column
`EXCLUDE+FLAG` (no key exists for the true subject — Outcome flips to `unmapped`, needs zero
special handling, the existing `Outcome == 'mapped'` filter already drops it) or `RE-ANCHOR`
(the true subject *does* have a key column on the same table — named in `Subject key / Role`).
RE-ANCHOR rows still show their *original* (wrong) `Model Target` in the main sheet — the fix
is only in the Rationale text — so they needed active rerouting, not passive filtering.

**Before trusting the `Subject key / Role` pairings, I verified every one against the real OPUS
schema** (not on faith): 15 of 24 were wrong — the pattern was each row pointing at the
*previous* row's companion column instead of its own. Corrected all 15 (each fix targets a
column that provably exists on that table); held 1 genuinely ambiguous case as-stated per the
mapping owner's own flag. Full detail and the one still-open confirmation needed:
`docs/MAPPER_NOTE_V5_FOLLOWUP.md` and `docs/appendix_9_subject_attribution.csv`.

**Architecture**: a RE-ANCHOR row's satellite grouping is generalized from "by table" to "by
(table, subject label)" — a virtual sub-table sharing the same physical staging model but keyed
by its own companion column, contributing its own independent row to the satellite (join-stitch
or union-fallback, same mechanics as any other branch). 22 of 24 RE-ANCHOR rows integrate this
way, into `SAT_PARTY_IDENTITY` and `SAT_LNK_ROLE_EMPLOYEE` (both already `HUB_PARTY`-anchored,
so no hub-type conflict). 2 rows (`SAT_COMMON_ADDRESS`, canonical parent `HUB_LOCATION`) don't
fit — reanchoring them to `HUB_PARTY` would mix two hkey types in one physical satellite table —
so they're excluded rather than force-fit; see `appendix_10_reanchor_hub_mismatch_excluded.csv`
and the open question in the follow-up note.

Companion keys are added to `HUB_PARTY` (provenance `reanchor` in the appendices) even where
the same column already keys a different hub (e.g. `IMD_CODE` also keys `HUB_DISTRIBUTION_CHANNEL`)
— safe via the hash namespacing from §12.2.

| | v3 (§12) | v5 (current) |
|---|---|---|
| Links built | 57 | 58 |
| Satellite subject-attribution branches corrected | — | 22 built, 2 excluded (mismatch), 1 pending confirmation |
| Total dbt models | 450 | 451 |


treat earlier sections as background on how the pipeline works.

---

## 1. Architecture: three layers; satellites are stitched into complete rows

```
stg_health__<table>            staging: 1:1 with a source table, typed/cast, nothing else
        |
        v
int_health__hub_<x>            intermediate: hub/link fan-in is UNION ALL (0-join). Satellite
int_health__lnk_<x>            fan-in is a real FULL OUTER JOIN + COALESCE stitch (see §1.1)
int_health__sat_<x>            wherever 2+ tables share the same grain -- one complete row
                                per key, not one partial row per source table.
        |
        v
hub_<x> / lnk_<x> / sat_<x>    raw vault: hashes business keys -> hkeys, computes hashdiff
                                (sats), dedupes. Reads from exactly ONE upstream reference.
```

**Absolute invariant, unchanged from the first cut: a satellite (and every hub/link) is
populated from exactly one upstream `ref()`, never more than one.** Every hub/link/sat gets
one dedicated view (or, when collapsed, one staging model) that is *already* the complete
input; the vault model never reaches across two `ref()`s to assemble a satellite. Two
satellites that happen to need the identical stitched result (same grain, same contributing
tables) point at the **same shared view** rather than each re-deriving it — still one `ref()`
per satellite, just possibly a shared one (§1.2).

### 1.1 Satellite stitching: real joins, not `UNION ALL`

The first cut of this build used `UNION ALL` for satellites fed by multiple tables — each
table contributed its own row, with `NULL` for whatever it didn't have. That avoided joins
entirely, but it meant a satellite whose data lived across e.g. 4 tables produced up to 4
separate partial rows per key instead of one complete one. **This was changed on request**:
satellites are now stitched with a real `FULL OUTER JOIN` chain plus `COALESCE`, so a
satellite with N contributing tables at the same grain produces **one row per key** with
every attribute filled in from whichever table actually has it.

- Each contributing table gets its own CTE, deduplicated to exactly one row per join key
  (`parent_bk` [+ resolved multi-active child key]) via
  `qualify row_number() over (partition by <key> order by <its own attribute columns>) = 1`
  — this is a safety guard against fan-out if a table genuinely has more than one row per
  key; ties are broken deterministically (same input -> same output every run), not
  arbitrarily.
- The N tables are then chained with `FULL OUTER JOIN`, using the standard N-way
  progressive-`COALESCE` join-key pattern (`coalesce(t0.key, t1.key) = t2.key`, etc.), so a
  key present in any one table still produces a row even if absent from the others.
  **Join count is uncapped** — per explicit instruction, the <10-join guidance does not
  block a satellite that genuinely needs more. The largest, `SAT_PARTY_IDENTITY`, stitches
  36 tables (35 joins); `SAT_POLICY_HEADER` stitches 31; several others are in the teens.
- Each attribute in the final row is `COALESCE(t_i.attr, t_j.attr, ...)` across every table
  that supplies it — normally exactly one table does, per the mapping's design (each
  attribute is sourced from one specific source column), so this is a structural safeguard
  rather than a real conflict-resolution engine. If two tables ever did disagree, the first
  in table-name order wins and there is no separate flag for it — documented here as the
  rule, not per-occurrence, since the mapping's own design means it shouldn't occur.
- `record_source` on a stitched row lists every table that actually contributed to *that*
  row (comma-separated, via `array_to_string(array_construct_compact(...))`), not a single
  table — since the row itself is no longer single-sourced.

**Multi-active satellites: joining is only safe at the correct grain.** For a satellite with
a resolved child key (e.g. `SAT_COMMON_CONTACT`'s "Contact Point Type + Contact Priority
Order"), a table can only be joined into the stitch if it carries the **full** child-key
grain — joining on `parent_bk` alone when the true grain is `(parent_bk, child_key)` would
silently fan out (one contact row per party in table A cross-joining every contact row per
party in table B). Tables that have the parent key but not the full child-key grain are
**not** joined; they instead contribute their own row via a `UNION ALL` fallback appended to
the stitched result — the same behaviour as the first cut of this build for that table,
with the same `-- JOINABILITY ISSUE` caveat. This is what keeps satellite coverage at 87/119
unchanged after switching to joins — nothing that was buildable before became unbuildable;
tables that can be safely joined now are, and tables that can't still contribute as before.

### 1.2 Shared views (checked, not assumed)

40 satellites needed a genuine join (2+ full-grain contributing tables). Before generating
each one's join chain, satellites were grouped by an exact signature — `(parent hub,
multi-active grain, set of full-grain tables, set of union-fallback tables)` — and only
satellites with an **identical** signature share one stitched view. This found 4 genuine
groups (10 satellites): e.g. `SAT_COMMON_CONSENT` and `SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS`
both stitch the same 4 tables at the same single-active `HUB_PARTY` grain, so one shared
view (`int_health__sat_shared__common_consent_party_individual_demographics`) carries the
union of both satellites' attributes, and each satellite's vault model selects just its own
subset from it. Satellites with the same table set but a *different* grain (e.g.
`SAT_LNK_PARTY_ROLE_CORE`'s multi-active role grain vs. `SAT_COMMON_CONSENT`'s single-active
grain, despite sharing the same 4 source tables) are **not** merged — sharing across
different grains would either lose the child-key discriminator or risk fan-out, so it wasn't
done. Full detail in `docs/appendix_4_satellites_built.csv`.

### 1.3 View collapsing (hubs and links)

Hub and link fan-in is still `UNION ALL` (no per-row grain conflict is possible there — a
hub is just its set of distinct business keys). When a hub/link has only **one** contributing
source table, the intermediate view is skipped and the vault model reads that one staging
model directly.

| Layer | Files |
|---|---|
| Staging | 123 |
| Intermediate views | 113 (includes 40 satellite join-stitch views + 4 shared views) |
| Hub vault models | 18 (3 collapsed, no view) |
| Link vault models | 43 (9 collapsed, no view) |
| Satellite vault models | 87 (17 collapsed, no view; 40 joined; 24 with a union fallback in play; 10 sharing a view) |
| **Total .sql files** | **384** |

Materialization: staging/intermediate = `view`; hub/link/satellite = `incremental`
(insert-only on a new hkey for hubs/links; a new row only when hashdiff changes, for
satellites — via Snowflake `QUALIFY` for in-batch dedup and `NOT EXISTS`/`NOT IN` for the
incremental delta).

---

## 2. Hub-key discovery — not every hub key was explicitly tagged

The same problem that affected links (§4) turned out to affect hubs too: a business key can
be genuinely present on a source table without the mapping workbook ever tagging it as that
table's `hub_key`. Rather than leave every such table's satellite data stranded (as the first
cut of this build did — 32 satellites, 317 excluded table-branches), hub keys were
**discovered** by cross-referencing column names:

1. Build the vocabulary of column names already used, explicitly, as a `hub_key` for each
   hub anywhere in the Health mapping (e.g. `HUB_POLICY` -> `CONTRACT_ID`, `POLICY_REF`,
   `POL_SERIAL_NO`, `POLICY_NO`, `REG_NO`, ... 15 variant names in total).
2. **Exclude ambiguous names.** Only one of 117 distinct key-column names is used for more
   than one hub anywhere in the mapping: `REFERENCE_ID` (used for `HUB_CLAIM`, `HUB_POLICY`,
   *and* `HUB_PROPOSAL` depending on table). That name was excluded from auto-discovery
   entirely — any table where `REFERENCE_ID` is the only candidate stays undecided rather
   than guessed.
3. For every one of the 129 Health source tables, using the **full OPUS column list** (not
   just the columns the mapping happened to touch), check whether the table has a column
   whose name exactly matches one of the unambiguous vocabulary names for a hub it doesn't
   already have an explicit key for. A match is treated as a **discovered** key.

Result: **213 discovered (table, hub, column) triples across 51 tables**, on top of the 328
explicit ones — full audit trail in `docs/appendix_7_discovered_hub_keys.csv` (table, hub,
column, evidence). Every generated model comments explicitly where a branch's anchor key is
`-- DISCOVERED` rather than explicitly mapped, so this is traceable in the SQL itself, not
just the docs.

**Discovery is deliberately conservative — it only finds a key that's genuinely there.**
Checked directly: `BJAZ_ECARD_POL_DTLS_CONFIG` (behind `SAT_PRODUCT_RATING_FACTOR`,
`SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES`) has 78 columns and **none** of them match any
`HUB_PRODUCT` vocabulary name — discovery correctly found nothing there, because the table
genuinely doesn't carry a product identifier (it does carry `POLICY_REF`/`QUOTE_REF`, both
already explicit). This is why discovery only recovered part of the original gap list (see
§7.3) — it can't invent a key the source doesn't have, and several of the original 25
"table-level gap" satellites are on tables that really do lack that specific hub's key,
where the fix (if any) is re-anchoring the satellite to a different hub, not discovery.

**Net effect of discovery**: excluded satellite table-branches dropped from 317 to 289; 6
built satellites gained additional source tables (e.g. `SAT_CLAIM_HEALTH_DETAIL` gained 13
more contributing tables, `SAT_PARTY_HEALTH_PROFILE` gained 7); one link
(`LNK_CASE_POLICY`) went from "no evidence" to populatable; several already-populatable
links gained materially more source-table evidence (e.g. `LNK_POLICY_PARTY` 30 -> 47
tables, `LNK_POLICY_CHANNEL` 24 -> 44). Full detail in the appendix CSVs.

---

## 3. Naming conventions

| Concept | Convention | Example |
|---|---|---|
| Staging model | `stg_health__<source_table_lower>` | `stg_health__bjaz_hm_hospital_master` |
| Hub business key | `<hub_short>_bk` | `party_bk` |
| Hub hash key | `<hub_short>_hkey` | `party_hkey` |
| Link hash key | `<link_short>_hkey` | `policy_party_hkey` |
| Satellite multi-active child key | `<attribute>_ck` | `contact_point_type_ck` |
| Satellite change-detection column | `hashdiff` | — |
| ETL metadata | `record_source` (source table literal), `load_dts` (`current_timestamp()`) | — |

`<hub_short>` / `<link_short>` = the hub/link code with its `HUB_`/`LNK_` prefix stripped and
lower-cased (`HUB_DISTRIBUTION_CHANNEL` -> `distribution_channel`).

---

## 4. Key normalisation & hashing

- **Hashing**: `dbt_utils.generate_surrogate_key(...)` (MD5-based) throughout — requires the
  `dbt-labs/dbt_utils` package (see `packages.yml`).
- **Business/link key columns are cast to a canonical trimmed VARCHAR
  (`nullif(trim(to_varchar(col)), '')`) regardless of native Oracle type**, in the staging
  layer — this applies identically to discovered keys, since the same business key can
  surface as `NUMBER` in one source table and `VARCHAR2` in another (e.g. `HOSID`); without
  normalisation the two tables would hash to different hkeys for the same real-world entity.
- **Satellite descriptive attributes are normalised to VARCHAR** in the intermediate
  harmonisation view (`nullif(trim(to_varchar(col)), '')`), regardless of native staging
  type. This is required, not stylistic: 128 mapped attributes are consistently
  `NUMBER`/`DATE` typed from source, and 71 more are `NUMBER`/`DATE` in one contributing
  table but a different type in another — a `UNION ALL` across those branches, with a bare
  `VARCHAR` `NULL` placeholder for tables missing the attribute, fails to compile on
  Snowflake (`TIMESTAMP_NTZ` and `VARCHAR` don't share an implicit common type across
  `UNION ALL` branches). Consumers needing a typed value should cast at the point of use,
  e.g. `try_to_date(completed_date)`.
- **Composite keys** (links, multi-active satellite grain) are hashed in two CTE steps
  (`keyed` then `hashed`), not by referencing a sibling alias inside the same `SELECT` list.
  Snowflake does support that via lateral column aliasing, but the two-step form is portable
  and easier to read.

---

## 5. Date & type convention (Snowflake)

| OPUS/Oracle type | Cast |
|---|---|
| `VARCHAR2`, `CHAR` | `trim(col)::varchar`, blank string -> `NULL` |
| `NUMBER` | `col::number` |
| `DATE`, `TIMESTAMP(6)` | `col::timestamp_ntz` |
| `CLOB` | `trim(col)::varchar` |

All date/datetime attributes are standardised to `TIMESTAMP_NTZ` at rest (not `DATE`), so
every date-typed column in the vault has one consistent type.

**Assumption to verify**: this project assumes the Health raw tables are already landed in
Snowflake with native types preserved from Oracle (an Oracle `DATE` column lands as a
Snowflake `DATE`/`TIMESTAMP`, not a formatted string). If your ingestion tool instead lands
dates as `VARCHAR` strings, the casts in every `stg_health__*` model need to change from
`::timestamp_ntz` to an explicit `TRY_TO_DATE(col, '<format>')` — no sample data was
available to confirm the actual landed representation, so this is flagged, not guessed.

---

## 6. Hubs — 18 built (3 with a single contributing table, view collapsed)

Every Health-relevant hub is a `UNION ALL` of every source column carrying its business key
— explicit mapping tags plus discovered keys (§2). `HUB_AGREEMENT`, `HUB_FINANCIAL_TRANSACTION`
and `HUB_REINSURANCE_TREATY` each have only one contributing (table, column), so their
intermediate view was skipped and `hub_<x>.sql` reads that single staging model directly.
Full table-by-table detail, with discovered-column counts, in
`docs/appendix_1_hubs.csv`.

---

## 7. Links — derived, not explicitly mapped (read this section first)

**Only one link in the entire Health mapping was explicitly tagged** (`LNK_PARTY_ROLE`, via 2
`link_key` rows). Building the other links required checking, per source table, whether the
business keys for **both** member hubs of a candidate link (from the canonical 71-link
model) co-occur on the same row — row-level co-occurrence of two hubs' business keys is
standard DV evidence of an association. This is a materially lower-certainty provenance than
an explicit mapped key, and is called out explicitly throughout rather than presented as
equivalent.

**Self-referencing links need a stricter rule.** A link with the *same* hub on both ends
(e.g. `LNK_PARTY_RELATIONSHIP` = party-to-party) cannot be evidenced by "two columns both
mapped to `HUB_PARTY` on the same table" alone — several such pairs are, per the mapping's
own rationale text, **redundant identifiers for the same party** (not two different
parties), or unrelated roles already covered elsewhere. Every self-link candidate's evidence
was checked against its rationale text and redundant/unrelated pairs excluded.
`LNK_PARTY_RELATIONSHIP`, `LNK_PARTY_GROUP` and `LNK_POLICY_RENEWAL` did not survive this
check (see §7.2).

### 7.1 Links built — 43 (9 with a single contributing table, view collapsed)

Full detail (source-branch count, business-key aliases, collapsed flag) in
`docs/appendix_2_links_built.csv`. Highlights after hub-key discovery: `LNK_POLICY_PARTY`
(47 source tables, up from 30), `LNK_POLICY_CHANNEL` (44, up from 24), `LNK_POLICY_PRODUCT`
(37, up from 20), `LNK_CLAIM_POLICY` (14), `LNK_CLAIM_PARTY` (14). `LNK_CASE_POLICY` moved
from "no evidence" to populatable once discovered `HUB_CASE`/`HUB_POLICY` keys co-located on
a table that previously had neither tagged.

### 7.2 Links NOT built — 16 documented gaps

Full list with reasons in `docs/appendix_3_links_gaps.csv`. Three categories:

1. **No co-occurrence anywhere, even after discovery** (10 links, e.g. `LNK_AGREEMENT_PARTY`,
   `LNK_FINTXN_CLAIM`, `LNK_TREATY_PARTY`) — no Health source table carries business keys
   for both member hubs together.
2. **Redundant-only self-link evidence** (3 links: `LNK_PARTY_RELATIONSHIP`,
   `LNK_PARTY_GROUP`, `LNK_POLICY_RENEWAL`) — every candidate column pair was either a
   duplicate identifier for the *same* entity, or an already-covered role pairing. For
   `LNK_POLICY_RENEWAL` specifically: ~20 tables carry two policy-identifier columns, but in
   every one the second is explicitly "redundant"/"duplicate of" the first — no
   `PREV_POLICY_NO`-style second policy reference was ever found. A true renewal chain
   cannot be built from this mapping as it stands.
3. **`LNK_POLICY_ENDORSEMENT`** — a single-hub transactional/event link needing an
   endorsement sequence column tagged as its own key; none was tagged or discovered (no
   vocabulary exists for it, since it was never explicitly tagged anywhere either).

---

## 8. Satellites — 87 built (17 single-source/view-collapsed, 40 genuinely joined, 24 with a union-fallback table, 10 view-sharing), 119 candidates

### 8.1 Multi-active child key resolution

The canonical model documents each multi-active satellite's intended grain in a `childkey`
description (e.g. `SAT_COMMON_CONTACT` -> *"Contact Point Type + Contact Priority Order"*).
Where those concepts matched one of the satellite's own mapped attributes (35 satellites),
that attribute's source column became the physical discriminator (`<attribute>_ck`).
Per table, this plays out one of two ways (see §1.1): a table carrying the **full** resolved
child-key grain is joined into the stitched row at that grain; a table carrying the parent
key but **not** the full child-key grain cannot be safely joined (fan-out risk) and instead
contributes its own row via a `UNION ALL` fallback, flagged with an explicit
`-- JOINABILITY ISSUE` comment, since `(parent hkey, hashdiff)` dedup on that fallback row
could in principle collapse two genuinely distinct child rows that happen to share identical
attribute values. A satellite can have both kinds of table at once — e.g.
`SAT_POLICY_CERTIFICATE` joins 1 table properly and falls back to `UNION ALL` for 13 more.

### 8.2 Party-role satellites — a modelling deviation, called out explicitly

Six satellites (`SAT_LNK_ROLE_CUSTOMER`, `_AGENT`, `_PROVIDER`, `_TPA`, `_EMPLOYEE`,
`_NOMINEE_BENEFICIARY`) are canonically parented to the link `LNK_PARTY_ROLE`, but no Health
table feeding their attributes carries a role-instance/sequence column (only the 2 tables
that evidence `LNK_PARTY_ROLE` itself do, via `MEM_SEQNO`, and neither feeds these 6
satellites). They are built instead directly off `HUB_PARTY` with a literal (not
source-derived) role-type discriminator, e.g. `'PROVIDER' as role_type_ck` — a constant
label for provenance, not a fabricated business key. Flagged inline with
`-- MODELLING DEVIATION`.

### 8.3 Satellites NOT built — 32 gaps, and why discovery didn't close them all

Full list in `docs/appendix_5_satellites_gaps.csv`.

**(a) Structural — 7 satellites, canonical parent hub has zero vocabulary to discover
against:**

| Satellite | Canonical parent |
|---|---|
| `SAT_RISK_PERSON_MEMBER`, `SAT_RISK_PERSON_INSURED`, `SAT_RISK_OBJECT_CORE`, `SAT_RISK_HEALTH_MEMBER_COVERAGE`, `SAT_RISK_HEALTH_MEMBER_MEDICAL`, `SAT_RISK_HEALTH_PED_WAITING` | `HUB_RISK_OBJECT` |
| `SAT_LOSS_EVENT_DETAIL` | `HUB_LOSS_EVENT` |

**No source column was ever explicitly tagged as a `HUB_RISK_OBJECT` or `HUB_LOSS_EVENT` key
anywhere in the Health mapping**, so §2's discovery method — which only works by matching
against an *existing* vocabulary of key-column names for a hub — has nothing to match
against for these two hubs. This is the single most important gap in this build: these are
core Health member/insured satellites with real attribute data (member enrolment,
medical/PED details), but every member/insured identifier the mapping saw was routed to
`HUB_PARTY`/`LNK_PARTY_ROLE` instead. Recommended next step: a mapping-owner decision on
whether the insured-member business key (`MEM_SEQNO` scoped by policy, most likely) should
be tagged `KEY:HUB_RISK_OBJECT`, or whether these satellites should be re-parented to
`HUB_PARTY`/`LNK_PARTY_ROLE` in the canonical model for Health. This is a modelling decision,
not something discovery-by-name-match can resolve on its own.

**(b) Table-level — 25 satellites, parent hub IS mapped elsewhere in Health, just not on
these tables — and discovery genuinely could not find it either.** Checked directly for
several (see §2): the tables behind these satellites simply do not carry a column matching
the parent hub's known vocabulary, even after the full-schema, cross-table search. These
tables are, in the majority of cases, otherwise well-integrated (e.g. `BJAZ_HM_HOSPITAL_MASTER_EXTN`,
behind `SAT_AGREEMENT_*`, already feeds 10+ other satellites via its `HUB_PARTY`/`HUB_POLICY`/
`HUB_DISTRIBUTION_CHANNEL` keys) — they just don't have *this* hub's key. **This is now a
re-anchoring question, not a discovery question**: e.g. the hospital-master-derived
"agreement" attributes are plausibly better anchored to `HUB_PARTY` (via `HOSID`, which the
table already carries) than to `HUB_AGREEMENT`. Re-anchoring changes what a satellite means,
so it wasn't done unilaterally here — full per-satellite detail (which tables, what keys
they DO have) is available on request; `docs/appendix_5_satellites_gaps.csv` lists the
satellite/reason, cross-reference against `docs/appendix_1_hubs.csv` for what each table's
tables already anchor to.

### 8.4 Per-table treatment within built satellites

Every table that contributes to a built satellite falls into exactly one of three
categories — full detail in `docs/appendix_6_satellite_table_exclusions.csv`:

- **`joined`** — has the parent hub key (and, for multi-active satellites, the full
  resolved child-key grain) — stitched into the complete row via the join chain in §1.1.
- **`union_fallback`** — has the parent hub key but not the full multi-active child-key
  grain, so it cannot be safely joined without fan-out risk — contributes its own row via
  `UNION ALL` instead (24 satellites have at least one such table; see the
  `-- JOINABILITY ISSUE` comment in the affected models).
- **`excluded`** — no parent hub key at all, explicit or discovered — does not contribute
  to the satellite. This is the same set of gaps described in §7-8.3 for hubs/links/sats;
  it is not a separate loss.

---

## 9. Reference tables — not built (no authoritative source identified)

The mapping tags 2 columns as `reference_key` (`REF:REF_RELATIONSHIP_TYPE`,
`REF:REF_EXCLUSION`, on `BJAZ_CTNGY_PA_MEM_DTLS`) — but these are *usages* of a code, not a
source of the code list. No table in the Health mapping was tagged as the definitional
master for either (for `REF_EXCLUSION`, `BJAZ_HM_EXCLUSION_MASTER` is a plausible candidate —
it has `EXCLUSION_ID`/`EXCLUSION_CODE` — but has zero mapped rows, i.e. was never actually
connected). Neither was built from usage-side distinct values alone. The workbook's `REF:`
prefix (vs. `KEY:` used everywhere else) also means these 2 low-confidence rows (0.55/0.45)
are not yet exposed in staging — trivial to add once a real reference source is identified.

---

## 10. Coverage summary (v2 — superseded by §12)

| | Count |
|---|---|
| Health source tables in mapping | 129 |
| Tables with a staging model (mapped column, or a discovered key) | 123 |
| Hub key rows | 541 (328 explicit + 213 discovered, see §2) |
| Hubs built | 18 / 18 (3 single-source, view collapsed) |
| Links built | 43 (+ redundant `LNK_PARTY_ROLE` counted within) / 59 structurally-relevant candidates (9 single-source, view collapsed) |
| Links documented as gaps | 16 |
| Satellites built | 87 / 119 with mapped attributes (17 single-source view-collapsed, 40 genuinely joined across 2-36 tables, 24 with a union-fallback table in the mix, 10 sharing a view with a sibling — see §1) |
| Satellites documented as gaps | 32 (7 structural — no hub-key vocabulary exists; 25 table-level — key genuinely absent on those tables) |
| Reference masters built | 0 / 2 tagged (no source master identified, §9) |
| Total dbt models generated | 384 (123 staging + 113 intermediate + 148 raw vault) |

*(See §12 for the current numbers — 20 hubs, 57 links, 108 satellites, 1 reference master.)*

---

## 12. Mapper-confirmed corrections (v3) — read this section for current state

A round of questions went to the Health mapping owner (`docs/MAPPER_QUESTIONS.md`). Every
specific column citation in the reply (`docs/MAPPER_QUESTIONS_ANSWERS.md`) was cross-checked
against the real OPUS schema and the current mapping state before being applied — not taken
on faith. Two corrections came out of that check (see `docs/appendix_8_mapper_resolutions.csv`
for the full log) and two structural changes were needed to apply the confirmed keys safely:

### 12.1 Composite business keys

Several confirmed keys are only unique **within a policy**, not globally — e.g. the insured
member's `MEMBER_NO`/`MD_SEQ_NO` sequence repeats across different policies. Those are now
composite business keys: `TRIM(col1) || '|' || TRIM(col2)`, e.g.
`HUB_RISK_OBJECT`'s key on `BJAZ_HCF_MEMBER_DTLS` is `CONTRACT_ID || '|' || MEMBER_NO`, not
bare `MEMBER_NO`. Composite keys are a first-class shape everywhere now (staging, hub,
link, and satellite generation all handle 1-or-more-column keys uniformly).

### 12.2 Per-hub hash namespacing (all 20 hubs, not just the 2 known cases)

Several confirmed keys deliberately reuse a raw value that **another** hub already keys on
the same table — e.g. `QUOTE_REF_NO` now keys both `HUB_QUOTE` (existing) and `HUB_PROPOSAL`
(confirmed: proposal≡quote identity in Health). Hashing both the same way
(`generate_surrogate_key(['business_key'])`) would make `HUB_QUOTE_HKEY` and
`HUB_PROPOSAL_HKEY` byte-identical for that row — accidental collision between two
conceptually distinct hubs. Every hub/link/satellite hash key is now namespaced with its own
hub (or link, or satellite) code as a literal first argument:
`generate_surrogate_key(["'HUB_PROPOSAL'", 'business_key'])`. This was applied project-wide,
not just to the two cases that prompted it, since it's the same one-line cost per model
either way and closes the door on any future accidental collision. Every hkey computation
(hub build, link ends, satellite parent) uses the identical formula independently — still no
joins anywhere.

### 12.3 What got unblocked

| | Before (§10) | After |
|---|---|---|
| Hubs built | 18 | **20** (+`HUB_RISK_OBJECT`, +`HUB_LOSS_EVENT`) |
| Links built | 43 | **57** |
| Link gaps | 16 | 14 |
| Satellites built | 87 | **108** |
| Satellite gaps | 32 | **11** |
| Reference masters built | 0 | **1** (`REF_EXCLUSION`) |
| Total dbt models | 384 | **450** |

Specifically resolved (21 satellites moved from gap to built, zero regressions — verified by
diffing the gap lists before/after):
- **The 6 core member/insured satellites** (`SAT_RISK_PERSON_MEMBER`, `SAT_RISK_PERSON_INSURED`,
  `SAT_RISK_OBJECT_CORE`, `SAT_RISK_HEALTH_MEMBER_COVERAGE`, `SAT_RISK_HEALTH_MEMBER_MEDICAL`)
  plus `SAT_LOSS_EVENT_DETAIL` — this was the single most important gap in the earlier build.
- 10 links attaching to `HUB_RISK_OBJECT` (per the mapper's "unit of work" framing — a source
  row populates every link whose component hubs are all keyed on that row, which is exactly
  the co-occurrence methodology this build already used, so most of these fell out of
  re-running the existing link derivation on the enriched key set, not new bespoke logic).
- `LNK_POLICY_ENDORSEMENT` and `LNK_POLICY_RENEWAL` — the former generalises the existing
  single-hub "explicit link key" mechanism (previously only `LNK_PARTY_ROLE` used it) to a
  second case (`POLICY_REF` + `ENDT_NO` on `BJAZ_PMJAY_PRMBOOK_DTLS`); the latter uses a
  manually confirmed pair (`POLICY_NO` + `PREV_POL_REF` on `BJAZ_GRP_HLT_DTLS`) rather than
  the generic redundancy-filtered self-link heuristic, because the mapper explicitly
  distinguished it from **portability** (`PREV_POLICY_NO`/`FIRST_POLICY_REF`/`CON_POLICY_REF`,
  which reference a *different insurer's* policy number and don't belong in this insurer's
  own `HUB_POLICY` at all — those stay as plain `SAT_POLICY_PORTABILITY_MIGRATION` attributes).
- **6 satellites re-anchored, not given a fabricated key** — `SAT_FIN_CHARGE_RATE` →
  `HUB_POLICY` (it's policy-grain, not a financial transaction), `SAT_COMMON_ADMIN_GEOGRAPHY`
  and `SAT_COMMON_STATUS` → `HUB_PARTY` (both are provider/hospital attributes keyed by
  `HOSID`, not location/policy respectively), `SAT_PARTY_CORRESPONDENCE` → `HUB_CLAIM` (the
  recipient is name-only, no party-id column exists on that table), `SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES`
  and `SAT_PRODUCT_RATING_FACTOR` → `HUB_POLICY` (not product-scoped). Each is flagged inline
  in the generated SQL with a `-- RE-ANCHORED (mapper-confirmed)` comment. See
  `docs/appendix_8_mapper_resolutions.csv`.
- `REF_EXCLUSION` — built from `BJAZ_HM_EXCLUSION_MASTER` (confirmed as the master; previously
  zero mapped rows). `REF_RELATIONSHIP_TYPE` is confirmed as needing an **external seed** —
  no Health source table defines that code list — and was correctly left unbuilt, not guessed.

### 12.4 Verified corrections to the mapper's answers before applying them

- **`MEM_COVERED_POL_YN`/`PREV_DISEASE_COVERED_YN`/`PREV_ACCIDENT_YN`** were cited on
  `BA_HCP_PROD_8433_FHC_LOADER`; confirmed those columns don't exist on that table — they're
  on `BJAZ_HG_POL_DTLS` (already mapped there to `SAT_PROPOSAL_QUESTIONNAIRE`). No build
  impact, citation only.
- **Renewal vs. portability** — the mapper's first answer treated `PREV_POL_REF`,
  `PREV_POLICY_NO`, `FIRST_POLICY_REF` as interchangeable evidence for `LNK_POLICY_RENEWAL`;
  the existing mapping already separates them into two different satellites
  (`SAT_POLICY_RENEWAL` vs. `SAT_POLICY_PORTABILITY_MIGRATION`), and only the former is a
  same-insurer prior-term reference. Confirmed and narrowed on follow-up — see §12.3.

### 12.5 Still open — not built, flagged rather than guessed

11 satellite gaps and 14 link gaps remain; full lists in `docs/appendix_5_satellites_gaps.csv`
and `docs/appendix_3_links_gaps.csv`. Three items specifically need one more concrete answer
from the mapper before they can be built (asked, not yet answered with a citable column):

1. **`LNK_PARTY_RELATIONSHIP` / `LNK_PARTY_GROUP`** — the mapper's answer was conceptual
   ("pair the proposer's party key with the member's party key + the `RELATION` code") but
   didn't cite a column carrying the *proposer's own* distinct party identifier, separate
   from the member's, on any specific table. Building this without one repeats the exact
   redundant-pairing mistake already caught and excluded in the original build (§7).
2. **`HUB_PROPOSAL` on `BA_HCP_PROD_8433_FHC_LOADER` and `BJAZ_EC_MEM_DTLS_EXTN`** — only
   `BJAZ_HG_POL_DTLS`/`BJAZ_GRP_HLT_DTLS`'s `QUOTE_REF_NO` was cited concretely.
3. **`HUB_FINANCIAL_TRANSACTION` on `BJAZ_PMJAY_PRMBOOK_DTLS` and `BJAZ_REMEDINET_CLAIM_DETAILS`**
   — only `BJAZ_TPA_CLAIM_DETAILS_WS`/`BJAZ_HM_HCM_EXTRACT` got concrete columns.

Additionally, **`HUB_COVERAGE`** (22 tables, 6 satellites: `SAT_COVERAGE_CONDITIONS`,
`SAT_COVERAGE_DEFINITION`, `SAT_COVERAGE_LIMITS`, `SAT_COVERAGE_LIVES_COUNT`,
`SAT_COVERAGE_MEMBER_BENEFIT`, `SAT_COVERAGE_SUBLIMIT_SCHEDULE`) needs an **unpivot**, not a
column tag — the mapper's answer says coverage on the wide benefit-loader tables is one
column per benefit (`MLAC_ROAD_AMBULANCE_COVER`, `PLC_HOSP_CASH_SI`, …), and the coverage key
is minted as `POLICY_REF + <benefit-code>` during that unpivot. That's a genuinely different
kind of model (`LATERAL FLATTEN` over a column list, not a straight key tag) and the mapper's
own answer calls it out as needing a modeler/ETL design ruling, not a mapping fix — correctly
left unbuilt here rather than improvised.

`SAT_PRODUCT_EXCLUSION_CATALOGUE` and `SAT_RI_CESSION_DETAIL` remain gaps as explicitly
confirmed (not product-scoped; no treaty key in Health source, respectively) — not oversights.

---

## 13. Before you run this

1. Point `vars.health_raw_database` / `vars.health_raw_schema` in `dbt_project.yml` at
   wherever the Health OPUS tables actually land in Snowflake.
2. `dbt deps` to pull `dbt_utils` (see `packages.yml`).
3. **Verify the date-cast assumption in §5** against real data before the first run.
4. **Review the discovered hub keys** (`docs/appendix_7_discovered_hub_keys.csv`) — the
   name-matched ones are evidence-based but not eyeballed row-by-row by a domain owner; the
   mapper-confirmed ones (§12) came from a targeted review but weren't independently
   re-verified beyond the schema/mapping cross-checks in §12.4.
5. **Send the three items in §12.5 back to the mapper** — `LNK_PARTY_RELATIONSHIP`/
   `LNK_PARTY_GROUP`'s proposer-key column, and the two `HUB_PROPOSAL`/
   `HUB_FINANCIAL_TRANSACTION` tables still missing a concrete citation.
6. **The `HUB_COVERAGE` unpivot (§12.5)** is a separate, larger design task (turning wide
   benefit columns into coverage rows) — get that ratified before attempting it; it's a
   different shape of work than everything else in this build.
7. This build was generated, not hand-reviewed line-by-line for all 450 models — `dbt run`/
   `dbt test` have not been executed against a live warehouse. The largest join chains
   (`SAT_PARTY_IDENTITY` at 36 tables, `SAT_POLICY_HEADER` at 31) are mechanically generated
   from a consistent pattern but are worth a manual read given their size.
