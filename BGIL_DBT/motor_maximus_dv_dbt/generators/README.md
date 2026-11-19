# generators — how Maximus Motor v2's models are written

Plain `python3`, standard library only. The models are generated and never edited by hand.

```bash
python3 generators/mm2_guard.py baseline    # once, BEFORE the first build
python3 generators/run_mm2_build.py         # the whole build, from empty, twice
```

Each layer's model counts are in `build_artifacts/BUILD_STATUS.json → models.by_layer`
(source: BUILD_STATUS.json).

These are derived from the Maximus Health v4 generators (spine walks) and the OPUS Motor v3 feeds
(motor directives), which use the same decided structure. Inputs, the graph field, the span grammar
and the directives are rewritten for this map.

| Script | What it does |
| --- | --- |
| `mm2_common.py` | every pinned input asserted by digest; the shred graph from `shred.parent_table`; abbreviated, injective staging names |
| `mm2_spine.py` | renders a key expression in one branch: both span types, all three start spellings, root-relative hop names; descends only when the value is unique |
| `mm2_feeds.py` | every map block becomes a feed or a registered refusal; withheld rows, link-leg identity, writer decisions, the dual-grain flag |
| `mm2_plan.py` | the central-view rule as a grouping, re-asserted |
| `mm2_emit.py` | every model in the partner/travel layout; dual-grain banners and writer decisions in satellite headers |
| `mm2_verify.py` | static checks over the emitted SQL, plus the shared `vault_tools` gates |
| `mm2_status.py` | `BUILD_STATUS.json` and the measured triage of the shared gate's findings |
| `mm2_guard.py` | the absolute rule: no file outside this project changes |
| `run_mm2_build.py` | generate, delete, generate again, compare digests, verify, status |

## Lesson carried from the previous build

A check that cannot resolve something **reports**; it never gates a key. The previous build once
let an incomplete per-hop audit withhold half its key surface. Here every hop resolves against the
graph, and a hop that didn't would refuse only its own row, with a reason.
