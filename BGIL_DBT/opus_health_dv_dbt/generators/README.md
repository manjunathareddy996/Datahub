# generators — how v5's models are written

Plain `python3`, standard library only. The models are generated and never edited by hand: change
a generator, or `build_profile.json`, and re-run.

```bash
python3 generators/v5_guard.py baseline     # once, BEFORE the first build: snapshot every other build
python3 generators/run_v5_build.py          # the whole build, from empty, twice
```

Each layer's model counts are in `build_artifacts/BUILD_STATUS.json → models.by_layer`
(source: BUILD_STATUS.json). They aren't repeated here.

## Run order

| Script | What it does |
| --- | --- |
| `v5_common.py` | pinned inputs (md5 asserted before use), naming, the refusal register, writing |
| `v5_keys.py` | business-key expressions: map `resolved_key` for v2 and delta3; recovery of the legacy half's forms from `health_dv_dbt` (read-only); the emit-ability checks |
| `v5_feeds.py` | every map row becomes a feed (satellite, table, attribute, key legs, child key) or a registered refusal; link candidates; satellite specs from `data_7.js` |
| `v5_plan.py` | **the one place the central-view rule becomes a grouping**; writes `stitch_plan.json` and re-asserts every rule |
| `v5_emit.py` | every model in the partner/travel layout, plus `dbt_project.yml`, `packages.yml` and the manifest |
| `v5_verify.py` | static checks over the emitted SQL, plus the shared `vault_tools` gates |
| `v5_status.py` | `BUILD_STATUS.json`, including the measured triage of the shared gate's findings |
| `v5_guard.py` | the absolute rule: baseline and check of every file outside this project |
| `run_v5_build.py` | generate from empty, delete, generate again, compare digests, verify, status |

## Things worth knowing before changing anything

**Keys come from two sources.** The v2 and delta3 rows carry `resolved_key` in the map; the
legacy rows carry none. The legacy forms are read from `health_dv_dbt`'s emitted stages and
stitched views. Precedence: (table, satellite) form, then (table, hub) form when exactly one
exists, then the map's own `hub_key` row; otherwise the row is refused. Several distinct forms
with nothing on the row to choose between them is a refusal, never a pick.

**A refusal is not a fallback.** An unresolvable key, child key or anchor is written to the
register with whose call it is. A NULL child key is the one exception: the row is landed with the
unresolved grain *declared*, the ratified remedy for legacy multi-active feeds, and is registered
all the same.

**Verification reads the SQL, not the manifest.** The manifest records what the generator
believes it wrote. Every contract check parses the emitted models themselves.
