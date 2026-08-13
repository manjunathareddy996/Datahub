# AutomateDV full-scale build — standard-model + augmented

Full-scale rework of the AutomateDV prototype (`docs/prototype_automate_dv/`) across the
entire Health LOB model. Lives under `models/automate_dv/`, entirely separate from the
original hand-written `models/staging/` (kept, reused as input) / `models/intermediate/` /
`models/raw_vault/` build — nothing existing was modified or deleted. Not yet `dbt deps`'d
or run; dbt isn't available in this environment. Verified by: reusing already-proven join/
key logic wherever possible (not re-derived from scratch), automated cross-checks against
the existing verified key inventory, and full hand review of every stitch view and every
link model (see "What was hand-verified" below).

## Layout

```
models/automate_dv/
  standard/            -- the canonical, mapper-confirmed model (data_v4.js + mapping)
    stitched/           43 files  -- attribute-joined satellite table clusters
    staging/            863 files -- 1:1 or per-cluster stage() (hash keys + hashdiff)
    hubs/                20 files
    links/               58 files
    satellites/          108 files (11 known gaps, same as production -- no source at all)
  augmented/            -- previously-unmapped columns, NOT mapper-confirmed
    staging/             72 files
    satellites/          15 files (SAT_AUG_<HUB>)
```

## How the standard-model build was generated

Rather than re-deriving join logic, hub-key ownership, or link definitions from scratch,
every generator **parses and reuses the existing, already mapper-reviewed production
files** (`models/intermediate/health/*`, `models/raw_vault/health/*`) and re-emits them in
the AutomateDV shape. The underlying source columns and business keys are identical to
what's already been verified over the course of this build — only the layering changed:

- **Stitch views** (`stitched/stitch_*.sql`) — reuse `join_helpers.build_stitch_block`
  (the exact function that built the current production intermediate satellite views) to
  emit the same `FULL OUTER JOIN` + `COALESCE` logic, reading raw production staging
  directly. **No hashing happens here** — there is deliberately no per-table `stage()` for
  a table that's attribute-joined into a stitch (see the routing rule below).
- **Stage-on-stitch** (`staging/stg2_<stitch>.sql`) — one `automate_dv.stage()` pass per
  stitch, the single place that hashes the cluster's hub key (namespaced) and computes
  `HASHDIFF`.
- **Hubs / links** (`hubs/hub_*.sql`, `links/lnk_*.sql`) — parsed from the existing
  production `hub_*.sql` / `lnk_*.sql` files' `generate_surrogate_key(...)` calls and their
  union branches, then re-emitted as `automate_dv.hub()`/`link()` calls fed from a list of
  per-table `stage()` outputs (for links: each contributing table gets its own small
  stage() computing both member-end hkeys with the SAME namespaced formula the hub side
  uses, so they're guaranteed to match real hub rows — not independently re-derived).
- **Satellites** (`satellites/sat_*.sql`) — the 44 stitch-backed ones read the stage-on-
  stitch output (`sat()`/`ma_sat()` per satellite, even when 2 share a stitch). The other
  75 (56 single-table + 19 union-only) get their own per-table `stage()` and are fed to
  `sat()`/`ma_sat()` as a list — pure union, matching the confirmed routing rule.

## The routing rule (confirmed during the design discussion, applied throughout)

**Attribute-joined** tables (columns `COALESCE`d against another table's columns for the
same key) are read **only** through their stitch's stage-on-stitch output — never also
given an individual per-table `stage()`, since that would bypass the coalesce/dedupe the
stitch exists for. **Union-only** tables (each contributes a whole, distinct row — no
merge) are read directly from their own per-table `stage()`, since `hub()`/`link()`/
`ma_sat()` already union natively — no reason to route them through a stitch just because
they happen to also appear in one for a different satellite.

## Hash-key namespacing

Every hkey is computed as `hash('{HUB_OR_LINK_CODE}|' || raw_key)`, via a derived
namespaced-text helper column (`*_NK`) hashed in a separate step — not a bare
`hash(raw_key)`. This preserves the same cross-hub collision-prevention guarantee the
original `dbt_utils.generate_surrogate_key(["'HUB_X'", key])` pattern had; AutomateDV's
`hashed_columns` only accepts column names, not literals, so the namespacing has to be its
own derived column first. **This was caught as a real regression partway through the
build** (the first prototype draft hashed raw keys directly) and retrofitted everywhere.

Link member-end hkeys use the exact same formula as that hub's own `stage()` models, so
they're guaranteed identical for the same raw value — genuine foreign keys, not
independently re-derived. A link's own hkey doesn't need to match anything external, so
it's computed directly from concatenated raw key text in one pass (no hash-of-hash
ambiguity, which was deliberately avoided as an unverified assumption about AutomateDV's
internals).

## What was hand-verified (not just script-trusted)

Per explicit instruction, all **43 stitch views** and all **58 links** were individually
reviewed, not just spot-checked:
- Every stitch: header/grain/join-count read for all 43 (join count = tables − 1 in every
  case, as expected for the coalesce-chain pattern; CDK columns present and correctly
  named on every multi-active stitch; role-special satellites correctly show
  `role_type_ck`; the one shared-view case correctly combines both satellites' attributes).
- An automated sweep confirmed **0 dangling `ref()`s** across all 43.
- Every link: structurally reviewed for sensible hub pairings (58/58), including the 3
  same-hub-twice cases (`ORG_UNIT` hierarchy, `PRODUCT` variant, `POLICY` renewal), which
  correctly use distinct `_FROM_`/`_TO_` aliasing.
- An automated cross-check verified **850 of 851** link branch `(table, hub, column)`
  triples against `enriched_table_hub_keys_v3.json` (the already-vetted key inventory) —
  the 1 exception (`BJAZ_GRP_HLT_DTLS.PREV_POL_REF` for `LNK_POLICY_RENEWAL`) was checked
  by hand against the original production file and confirmed genuine: it's a
  "reference to a different policy's key" (the renewal chain), which is legitimately absent
  from a table's-own-key inventory, not a fabricated key.

**3 real bugs were found and fixed** during this verification, all in the generator
scripts (fixed once, regenerated everywhere, not patched file-by-file):
1. A quote-parsing bug that swapped hub codes and column names when reading the existing
   link hash formulas (would have produced nonsense SQL — caught before any file was
   written from it).
2. A dedup-logic bug producing duplicate `source_model` entries in hub definitions, plus
   `src_nk` pointing at the internal namespaced-hash helper column instead of the raw
   business key.
3. A Python operator-precedence bug that silently dropped the `{{ config(...) }}` block
   from every stitch-backed satellite whose stitch wasn't shared with another satellite —
   i.e. most of the 44 — which would have left them defaulting to view materialization
   instead of incremental.

The remaining ~1,000 per-table `stage()` models (staging config only — no join/merge logic
of their own) were generated by the same reviewed scripts and validated by an automated
full-repo dependency sweep (every `ref()`/`source_model` entry across all 1,179 generated
files resolves to a real model — 0 dangling references) rather than individually read, per
the agreed split between "hand-verify the structural pieces" and "trust the high-volume
config layer."

## Part B: augmented satellites (not mapper-confirmed)

`augmentation_buckets.json` (built earlier this session: 514 previously-unmapped columns,
classified by keyword + table-anchor into a likely hub) is the input. Deliberately
conservative: a column is only actually **built** if its table already carries a real,
previously-verified key to that hub (per `enriched_table_hub_keys_v3.json`) — in practice
this means only the "high confidence (table already keys this hub)" tier. Everything else
— medium/low-confidence guesses and the whole `UNCLEAR` bucket (table has multiple
candidate hubs, no way to pick) — is **not built**, listed instead in
`docs/automate_dv_build/augmented_gap_report.json`-equivalent data (see scratchpad
`augmented_gap_report.json`) for mapper review.

Result: **219 of 514 columns built**, across **15 `SAT_AUG_<HUB>` satellites**, one per
hub with buildable columns. **295 excluded**: 165 for "table has no verified key to that
hub" (the keyword match was plausible but nothing confirms it), 130 in the `UNCLEAR`
bucket. Every augmented satellite is a plain **union** across its contributing tables — no
attribute-level merge was attempted, because these columns were never analysed for
cross-table overlap the way the standard-model satellites were. These are proposals, not
confirmed model additions — genuine keys (verified against the same inventory as
everything else), unconfirmed groupings (nobody has reviewed whether these columns
actually belong together on one satellite).

## Known open items, carried forward from this session

- Hash-namespacing convention is new to this build (see above) — not yet cross-validated
  against the original hand-written hashes (not expected to match; this is a parallel
  system, not a replacement, until a cutover decision is made).
- The composite-address-key fragmentation risk (two spellings of the same address won't
  dedupe) from the original prototype discussion is unchanged and still needs a
  data-quality decision.
- `SAT_PARTY_ADDRESS_USAGE`'s remaining canonical gaps (`Role Context`, `Preferred
  Indicator`, `Effective From Date`) are still gaps here too — no source column exists.
- Whether to migrate hub/link wholesale onto this pattern (replacing the hand-written
  production build) vs. keep both in parallel is still an open decision — this build
  answers "can it be done, is it correct," not "should we cut over."
