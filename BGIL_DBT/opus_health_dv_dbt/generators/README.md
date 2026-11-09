# health_consolidated_v4_dv_dbt — the central-view build

This project implements the rule the user states as governing, in their words. The quotation and
its table limit are reproduced from `build_profile.json` under `central_view_rule.verbatim`
(source: build_profile.json) — the number in it is the rule's own parameter, not a measurement of
this build:

> we create a central view from source tables (by joining them , max upto 10). The join are
> selected so that it can feed sat as a whole (one or moew). That is we do not split sat across
> these views. Restriction of 10 can be broken if a sat needs more than source tables to build.
> If a view as less source tables join, we add more tables to it efficiently so that new sats can
> be built.

and its hub/link extension:

> the views will have hub keys -- effectively each sat is primary key goes to hub -- so hub has to
> come from there, 2nd the links will also be from same view , as different hub keys and sat
> populatin comes from there

The rule is recorded verbatim in `build_profile.json` under `central_view_rule`, because it was
implemented once before — in gen 1's `health_dv_dbt/models/automate_dv/standard/stitched/` views —
and written down nowhere, which is why every build after gen 1 drifted away from it while passing
its gates.

**No count in this file describes current state.** Counts live in
`build_artifacts/BUILD_STATUS.json` and `build_artifacts/reports/`, and are recomputed on every
build. Source: `build_profile.json` and `BUILD_STATUS.json`.

---

## The frozen directory structure

```
health_consolidated_v4_dv_dbt/
├── BUILDER_ASKS_HEALTH_V4.md        what goes back, routed by whose call each item is
├── build_profile.json               the inputs, the conventions, and the governing rule
├── inputs/                          the two PINNED map contracts, copied, read-only
├── generators/                      the Python that writes every model
└── models/
    ├── staging/        one per source table a view actually JOINS
    ├── stitched/       THE CENTRAL VIEWS — one per satellite group
    ├── stage/          THE HASH SITE — one per central view, nothing else hashes
    ├── hub_feeds/      one per (hub, view carrying that hub's key)
    ├── vault/
    │   ├── hubs/           one per keyed hub, unioned over its feeds
    │   ├── links/          one per link whose every leg co-occurs on ONE view
    │   └── satellites/     one per satellite, reading exactly ONE stage model
    ├── augmented/      the augmentation track, kept OUT of the ratified vault
    └── assertions/     the claims this architecture makes, as SQL that can fail
└── build_artifacts/
    ├── BUILD_STATUS.json            every count describing this build
    └── reports/
        ├── stitch_plan.json         the rule, applied — the frozen grouping
        ├── view_columns.json        what each central view emits
        ├── stage_columns.json       what each stage emits
        ├── satellite_columns.json   what each satellite reads
        ├── unresolved_register.json everything REFUSED rather than defaulted
        └── verification.json        every check, its outcome and its population
```

## The chain

```
source table
   → staging/        name and type only; no keys, no hashes, no business logic
   → stitched/       THE CENTRAL VIEW: joins this group's tables, merges attributes
                     sideways, produces ONE clean row per key. Nothing is hashed yet —
                     there is nothing to hash until this join has produced the row.
   → stage/          THE ONE PLACE A HASH IS COMPUTED, once per view
   → hub_feeds/ → vault/hubs/        rule 5: the hub comes from the view
     vault/links/                    rule 6: all legs from ONE view
     vault/satellites/               rule 2: fed WHOLE from one stage, one view
```

## The seven rules, and where each is enforced

Each rule's parameter is stated in `build_profile.json` under `central_view_rule.rules`
(source: build_profile.json); how many views, satellites and links it produced is in
`BUILD_STATUS.json`.

| # | Rule | Enforced in |
| --- | --- | --- |
| 1 | a view joins up to 10 source tables | `hcon4_plan.LIMIT`, applied in grouping |
| 2 | a satellite is NEVER split across views | the grouping; re-counted from the emitted SQL by `verify_hcon4.py` check 1 |
| 3 | the limit breaks for a single object that needs more | `over_limit` per view in the plan |
| 4 | an under-filled view absorbs more tables | best-fit packing, and the same mechanism satisfies rules 5 and 6 |
| 5 | a satellite's anchor hub key resolves on its OWN view | a planning requirement, not a check — see below |
| 6 | every leg of a link resolves on ONE view | links placed after satellites, on the smallest qualifying view |
| 7 | a view's tables can actually be JOINED to each other | the join plan per view; a table with no key path is refused, never cross-joined |

Rules 5 and 6 are **requirements, not checks.** The first grouping computed requirements from
satellite payload tables alone and then checked the hub keys afterwards; a large share of
satellites landed on a view that could not key them, and several views carried no hub key at all.
A check cannot fix a grouping. Both figures are now structurally zero and re-asserted every run.

## Generators, in run order

The layer each generator writes is named in `build_profile.json` under `layers`
(source: build_profile.json); how many models each emitted is in `BUILD_STATUS.json` under
`models.by_layer`.

| Script | What it does |
| --- | --- |
| `amend_hcon4_profile.py` | re-asserts the input md5s, then replaces every LAYER fact inherited from v3 |
| `hcon4_plan.py` | **the one place the rule becomes a grouping.** Emits `stitch_plan.json` and re-asserts it against all seven rules |
| `hcon4_emit.py` | shared rendering and the inter-layer manifest contract |
| `gen_hcon4_staging.py` | staging |
| `gen_hcon4_stitched.py` | the central views |
| `gen_hcon4_stage.py` | the hash site |
| `gen_hcon4_vault.py` | hub feeds, hubs, links, satellites |
| `gen_hcon4_augmented.py` | the proposed track, kept separate |
| `gen_hcon4_assertions.py` | the data facts no generator can verify |
| `run_hcon4_build.py` | the whole build, from empty |
| `verify_hcon4.py` | the checks, plus the shared `vault_tools` gates |
| `emit_hcon4_status.py` | `BUILD_STATUS.json` — where every count lives |
| `emit_hcon4_handback.py` | `BUILDER_ASKS_HEALTH_V4.md` |

`probe_hcon4_*.py` write nothing. They measure a shape before an emitter assumes it.

## Three things worth knowing before changing anything here

**Key slots come from two sources.** `resolved_key` in the map covers the v2 and delta3 halves
only — the profile measures it as present on zero legacy rows. The legacy half's key forms exist
in no map and are recovered read-only from `health_dv_dbt`'s emitted SQL. Sweeping only the map
reported several hubs as keyed nowhere and would have refused satellites and links on that basis;
the superseded figures are in `BUILD_STATUS.json` under `corrections`. `hcon4_plan.key_slots`
raises if the legacy recovery fails, rather than silently refusing.

**Ask the previous layer what it emitted; do not grep its SQL.** Payload reaches a stage model via
`src.*` and is aliased nowhere in it, so a search for `as <COL>` finds nothing and reports every
satellite as having an empty payload. That proxy emitted zero satellites once. Each layer now
declares what it emits in a manifest under `build_artifacts/reports/`.

**`vault_tools` is shared and is not edited by this build.** Where a shared gate cannot see this
architecture — `check_vault_alignment` globs a gen-1 satellite path — that is reported as NOT RUN
with the measurement behind it, never as a pass, and the gate is left alone. Changing a shared gate
to suit one build is a cross-build write.

## Two layers this build deliberately does NOT write

`reject_log/` and `vault/refs/` exist in v3 and are absent here, on purpose.

A rejection under this architecture is a **refusal**, and refusals live in
`build_artifacts/reports/unresolved_register.json`, where each one carries whose call it is and can
be counted and routed. An empty `reject_log/` would advertise a layer that does not exist.

`data_7.js` carries reference satellites and this map's target track names none of them — the
figure is in `BUILD_STATUS.json` under `map_coverage` (source: BUILD_STATUS.json). That is a gap
for the modeller, not an empty directory.

## Known conflict

`BUILD_RULES.md` section 6 describes its per-source-table architecture as *"Invariant across every
build"* and mandates one cast per mapped view, one wide stage per view, and satellites whose
payload is the union over all feeders. Under the central-view rule a satellite has one feeder by
construction. Both cannot hold. This build implements the central-view rule as instructed and does
**not** edit section 6 — a build does not rewrite the law it is judged by. It is the first item in
the handback.
