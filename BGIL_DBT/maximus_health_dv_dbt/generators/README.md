# generators — how Maximus Health v4's models are written

Plain `python3`, standard library only. The models are generated and never edited by hand.

```bash
python3 generators/mxh4_guard.py baseline   # once, BEFORE the first build
python3 generators/run_mxh4_build.py        # the whole build, from empty, twice
```

Each layer's model counts are in `build_artifacts/BUILD_STATUS.json → models.by_layer`
(source: BUILD_STATUS.json).

| Script | What it does |
| --- | --- |
| `mxh4_common.py` | pinned inputs (md5 asserted), the shred graph, naming (staging names are abbreviated and asserted injective to stay inside Windows path limits), the register, writing |
| `mxh4_spine.py` | renders a map key expression as SQL in one branch: climbs and descends become joins; every other column is qualified to the branch's own table; only ratified functions |
| `mxh4_feeds.py` | every map block becomes a feed or a registered refusal; every key and child key is dry-rendered first; directives come from typed fields |
| `mxh4_plan.py` | the central-view rule as a grouping, re-asserted |
| `mxh4_emit.py` | every model in the partner/travel layout, plus `dbt_project.yml` and `packages.yml` |
| `mxh4_verify.py` | static checks over the emitted SQL, plus the shared `vault_tools` gates |
| `mxh4_status.py` | `BUILD_STATUS.json` and the measured triage of the shared gate's findings |
| `mxh4_guard.py` | the absolute rule: no file outside this project changes |
| `run_mxh4_build.py` | generate, delete, generate again, compare digests, verify, status |

## Things worth knowing before changing anything

**A walk's direction comes from the graph.** Named hops are waypoints. They must lie on the
graph's ancestor path in order, or the key is refused.

**A descend never picks.** A 1:N descend yields NULL and the row is rejected.

**Only the first branch of a central view is null-padded in full.** In a UNION ALL, later
branches match by position, so they write bare `null`s. Padding every branch in full had pushed
the largest view past Snowflake's statement limit. The verifier checks every branch's positional
alignment against the first one.
