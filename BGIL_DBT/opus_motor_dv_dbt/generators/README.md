# generators — how OPUS Motor v3's models are written

Plain `python3`, standard library only. The models are generated and never edited by hand.

```bash
python3 generators/om3_guard.py baseline    # once, BEFORE the first build
python3 generators/run_om3_build.py         # the whole build, from empty, twice
```

Each layer's model counts are in `build_artifacts/BUILD_STATUS.json → models.by_layer`
(source: BUILD_STATUS.json).

These are derived from the Maximus Health v4 generators, which use the same decided structure and
the same mechanics. Inputs, the flat-source rule and the motor directives are rewritten for this
map.

| Script | What it does |
| --- | --- |
| `om3_common.py` | every pinned input asserted by digest, naming, the register, writing |
| `om3_spine.py` | renders an on-view key expression in one branch; refuses any walk notation and any function off the ratified list |
| `om3_feeds.py` | every map block becomes a feed or a registered refusal; applies E-7, G-3 and P-2 and the child-key resolution order; writes `single_writer_decisions.json` |
| `om3_plan.py` | the central-view rule as a grouping, re-asserted |
| `om3_emit.py` | every model in the partner/travel layout; stamps P-2 and G-3 into satellite headers |
| `om3_verify.py` | static checks over the emitted SQL, including scope, G-3 and P-2, plus the shared `vault_tools` gates |
| `om3_status.py` | `BUILD_STATUS.json` and the measured triage of the shared gate's findings |
| `om3_guard.py` | the absolute rule: no file outside this project changes |
| `run_om3_build.py` | generate, delete, generate again, compare digests, verify, status |

## Child-key resolution order

There is no fallback at any step:

1. **`child_key_components` where present.** Each leg takes its `source_column` when
   `resolved_on_view` is true, and otherwise its literal value. A leg that offers neither refuses
   the block.
2. **Otherwise `child_key_value`**, read as `Leg = VALUE | Leg = VALUE`.
3. **A declared leg still unresolved** lands NULL, and its grain is declared in the register.
