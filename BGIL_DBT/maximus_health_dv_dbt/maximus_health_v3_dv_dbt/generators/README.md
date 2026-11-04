# Maximus Health V3 -- generators

**Every number on this page is taken from `build_artifacts/BUILD_STATUS.json`
by reference.** Nothing here is typed by hand; re-run `gen_mxh3_readme.py` after
any build and the figures follow. Models are generated, never hand-edited --
edit the generator and re-run.

## Headline

| figure | value | where it comes from |
| --- | --- | --- |
| models emitted | 1016 | `BUILD_STATUS.models_total` |
| model tree sha256 | `58ba6c7ff07ea62cb15f407c7bf2e28a6039e3cbaabc7d27b883cb267a6bf995` | `BUILD_STATUS.model_tree_digest.tree_sha256` |
| generators in the chain | 12 | `BUILD_STATUS.generators_total` |
| map md5 | `f3f1fd8284b4aac8f10ef216e3dcf87d` | `BUILD_STATUS.map.md5` |
| map bytes | 7325889 | `BUILD_STATUS.map.bytes` |
| unresolved, reported | 334 | `BUILD_STATUS.unresolved_total` |
| build directives implemented | 15 | `BUILD_STATUS.build_directives_implemented` |

Digest combining method: per file: <posix-relpath> + LF + sha256(file bytes); lines sorted bytewise; joined with LF; sha256 of the UTF-8 encoding of that join.

## Run order

```
python3 run_mxh3_build.py      # deletes models/ and rebuilds FROM EMPTY
```

| # | generator | owes |
| --- | --- | --- |
| 1 | `build_mxh3_spec` | map -> the ONE spec artifact (the only reader of the map) |
| 2 | `gen_mxh3_staging` | layer-1 casts for views that NEED one |
| 3 | `gen_mxh3_hopviews` | walk-only casts: every intervening level |
| 4 | `gen_mxh3_resolvers` | one resolver per start view, joins per REAL level |
| 5 | `gen_mxh3_unpivot` | column-as-instance families -> one row per instance |
| 6 | `gen_mxh3_stage` | one wide stage per view: keys + EMIT flags |
| 7 | `gen_mxh3_rejectlog` | divert-and-COUNT, the exact complement of EMIT |
| 8 | `gen_mxh3_vault` | hub feeds, hubs, links, satellites |
| 9 | `gen_mxh3_augmented` | the unratified build-side track |
| 10 | `gen_mxh3_quarantine` | BESPOKE: surrogate_child_key_quarantine |
| 11 | `gen_mxh3_refdecode` | BESPOKE: reference_decode_gate |
| 12 | `gen_mxh3_tests` | 3 load-time assertions (runtime NOT RUN -- no source access) |

`check_mxh3_hashkeys.py` then runs INSIDE the chain, and the five shared gates
run as subprocesses with `PYTHONDONTWRITEBYTECODE=1`, never imported.

## Layers

| directory | models | layer owes |
| --- | --- | --- |
| `augmented` | 112 | the unratified build-side track |
| `hopviews` | 75 | casts for views on a walk, including every intervening level |
| `quarantine` | 7 | BESPOKE: surrogate_child_key_quarantine (declared) |
| `reference_decode` | 2 | BESPOKE: reference_decode_gate (declared) |
| `reject_log` | 77 | divert-and-COUNT, the exact complement of EMIT |
| `resolvers` | 61 | one per start view; joins expanded per REAL level |
| `stage` | 83 | one wide stage per view: keys and their EMIT flags |
| `staging` | 83 | layer-1 typed casts for views that NEED one |
| `tests` | 3 | load-time assertions; runtime verdict NOT RUN |
| `unpivot` | 14 | one row per instance, column-as-instance families only |
| `vault/hub_feeds` | 325 | one per (view, DECLARED ANCHOR EXPRESSION) |
| `vault/hubs` | 23 | assembled from the per-source feeds |
| `vault/link_feeds` | 11 | one per (view, DECLARED LEG EXPRESSIONS) |
| `vault/links` | 1 | assembled; completeness asserted both ways |
| `vault/satellites` | 139 | ratified track, payload NULL-PADDED TO THE SATELLITE |

## What is different about this LOB

**The shape inverts from the calibration sibling.** OPUS Health is flat: 0
hierarchy edges, 0 resolvers, 0 walk-only casts. This source is a shredded EAV
feed WITH a spine, so resolvers and unpivot are both REQUIRED and were derived
from the graph here, not inherited.

| property | value | source |
| --- | --- | --- |
| spans, climb / cross | 71 / 16 | `BUILD_STATUS.json` census.spans_climb/.spans_cross |
| spans skipping >=1 real level | 33 | `BUILD_STATUS.json` census |
| walk-only casts | 75 | `BUILD_STATUS.json` census |
| resolver views | 61 | `BUILD_STATUS.json` census |
| unpivot views | 14 | `BUILD_STATUS.json` census |

Only 52 of 1,812 climbs name the direct parent (`build_profile.json
hierarchy.level_skip_census`), so level-skipping is the dominant case and every
intervening level is materialised as its own join.

## Grammar census

| form | count | semantics | source |
| --- | --- | --- | --- |
| `spine[<start> -> <ancestor> [-> ...]].<column>` | 1489 | climb | `build_profile.json grammar[]` |
| `spine[<start> -> <ancestor> [-> ...]] >> <table>.<column>` | 323 | cross | `build_profile.json grammar[]` |
| `<start> >> <table>.<column>  (bare, no spine[ prefix)` | 2 | cross | `build_profile.json grammar[]` |
| `LNK(<HUB>=<expr> ; ...)  -- ratified call, not a walk` | 174 | link | `build_profile.json grammar[]` |
| `spine:<TABLE>.<COLUMN>  -- DISPLAY ONLY, NOT EXECUTABLE` | 398 | display | `build_profile.json grammar[]` |
| `{spine:KEY_HASH} / {spine:PARENT_KEY_HASH}  -- DISPLAY surrogate` | 90 | display | `build_profile.json grammar[]` |

Parse residue over all 2613 executable key slots: 0 (`build_profile.json
grammar_totals.executable_key_slots`, `parse_residue`).

## Build directives

Counts in this table are the BUNDLE's, taken from `build_profile.json`
build_directives[] and the map's own directive fields -- not current state.

| # | bundle item | mechanism | implemented in |
| --- | --- | --- | --- |
| 1 | BUILD_INSTRUCTIONS s2 / KEY_FUNCTIONS s7.11 / map build_directive x45 | surrogate_child_key_quarantine layer, scoped by leg_backing=='surrogate' | `gen_mxh3_quarantine.py` |
| 2 | KEY_FUNCTIONS s7.11b | operand splitter on U+0040/U+0023 inside a leg value, separator PRESERVED | `mxh3_keyrules.py:split_operands/render_leg_value` |
| 3 | KEY_FUNCTIONS s1.0 / s3.3 / s5.8 | legs from child_key_components, else ' | ' at brace depth zero; '#' is an OPERAND separator only | `mxh3_keyrules.py:declared_legs/split_depth_zero` |
| 4 | KEY_FUNCTIONS s2.3 | reject_log predicate driven by resolved_key.degenerate_verdict; the one no-source-operand constant is ACCEPTED | `mxh3_keyrules.py:emit_predicate + gen_mxh3_rejectlog.py` |
| 5 | KEY_FUNCTIONS s2.5 | key expressions emitted VERBATIM; no normalisation pass over key text; namespace prefixes asserted still present after rendering | `mxh3_keyrules.py:render_key_expression/assert_namespaces_intact` |
| 6 | KEY_FUNCTIONS s1.3 | walk resolver reads resolved_key.expression/.legs only; the 'spine:' display form is never parsed as SQL | `mxh3_keyrules.py:parse_spans + gen_mxh3_resolvers.py` |
| 7 | BUILD_INSTRUCTIONS s5.3 / KEY_FUNCTIONS s9.3 | per-walk row-count column emitted beside every cross, plus a row-count assertion model; an empty join is counted, never silent | `gen_mxh3_resolvers.py + gen_mxh3_rejectlog.py` |
| 8 | BUILD_INSTRUCTIONS s3 / KEY_FUNCTIONS s5.4 | build-side multi-active satellite, 7-attribute union via ATTRIBUTE_UNION_ALIASES, OPUS feeder compound key, VERSION_NO dropped | `gen_mxh3_augmented.py` |
| 9 | BUILD_INSTRUCTIONS s4.1 | ATTRIBUTE_ROUTING_SUPPRESS: 2 attributes suppressed on the placeholder, built on the ratified SAT_CLAIM_BENEFIT_HEAD | `mxh3_keyrules.py + gen_mxh3_augmented.py` |
| 10 | BUILD_INSTRUCTIONS s1.4 / KEY_FUNCTIONS s5.3 | child-key leg completeness asserted against data_7.js sats[].childkey keyed by sats[].code; never reconciled down to a 1-leg form | `build_mxh3_spec.py:assert_fully_keyed` |
| 11 | BUILD_INSTRUCTIONS s5.5 / KEY_FUNCTIONS s9.2 | do_not_build honoured at BOTH block and component scope (3 + 5 = 8) | `mxh3_keyrules.py:do_not_build_block/do_not_build_component` |
| 12 | BUILD_INSTRUCTIONS s5.5 | augmented track emits with an explicit unresolved-child-key marker column | `gen_mxh3_augmented.py` |
| 13 | map transformation_kind == reference_decode (3 directive rows) | reference_decode_gate bespoke predicate, refusing the row when the decode is unavailable (see decision D1/D2 for the scope) | `gen_mxh3_refdecode.py` |
| 14 | KEY_FUNCTIONS s2.2 | hash expressions emitted verbatim; an inner coalesce and a separator are never tidied; the OUTER guard is the expression's own degenerate value | `mxh3_keyrules.py:emit_predicate/render_key_expression` |
| 15 | SAMPLE_VINTAGE_NOTE.md | no build decision rests on sample absence: membership is tested against the COLUMN LIST in 00_tables_index.json, never against sample coverage | `mxh3_keyrules.py:view_columns/leg_resolves` |

## Reported, not guessed

Nothing below was resolved by the builder. Each is counted and routed.

| what | count | source |
| --- | --- | --- |
| anchor does not resolve uniquely | 147 | `BUILD_STATUS.unresolved_by_kind` |
| anchor has no declared expression on this view | 43 | `BUILD_STATUS.unresolved_by_kind` |
| child key leg does not resolve on its own view | 6 | `BUILD_STATUS.unresolved_by_kind` |
| s54 payload attribute is also a child key leg | 6 | `BUILD_STATUS.unresolved_by_kind` |
| spine display rung with no declared walk | 132 | `BUILD_STATUS.unresolved_by_kind` |
| anchors resolved uniquely | 315 | `BUILD_STATUS.anchor_resolution` |
| anchors REFUSED, ambiguous | 147 | `BUILD_STATUS.anchor_resolution` |
| anchors REFUSED, none declared | 43 | `BUILD_STATUS.anchor_resolution` |

A feeder is `(view, DECLARED ANCHOR EXPRESSION)` and never `(view)` alone. An
anchor that does not resolve uniquely is REFUSED and REPORTED -- never keyed on
a guess, because a fallback that guesses converts a loud gap into a silent
corruption that compiles cleanly.

## Validator dispositions

| disposition | declared blocks | re-derived | verdict |
| --- | --- | --- | --- |
| REFUSE | 18 | 0 | STALE_NOT_REFUSED |
| REFUSE | 10 | 0 | STALE_NOT_REFUSED |
| REFUSE | 3 | 3 | LIVE_REFUSED |
| EMIT, resolving hop direction FROM THE GRAPH | 12 | n/a | APPLIED_AS_DECLARED |
| EMIT, with the instability declared | 45 | n/a | APPLIED_AS_DECLARED |
| EMIT BOTH, do not normalise | None | n/a | APPLIED_AS_DECLARED |
| REFUSE | 3 | 3 | LIVE_REFUSED |

Each REFUSE has its PRECONDITION verified before being executed: a REFUSE is the
destructive direction and is unrecoverable at load, so where a finding's stated
mechanism is measurably absent from the map in hand the blocks are NOT deleted,
and the staleness is reported instead. See decision `D11`.

## Where to overrule a decision

Every builder decision is one line to overrule. They live in
`mxh3_keyrules.BUILDER_DECISIONS`, each with its reasoning and WHAT IT COSTS.

Any quantity in a switch description is taken from `build_profile.json` or the
map, describing the DECISION's scope rather than current state.

| id | switch |
| --- | --- |
| `D1-REFDECODE-DEFAULT-REFUSE` | Set dbt var mxh3_reference_decode_available to true (one line in dbt_project.yml), or pass --vars on the run. |
| `D2-REFDECODE-SCOPE-IS-THE-DIRECTIVE` | Set REFDECODE_SCOPE = 'transformation_kind' in this module. |
| `D3-QUARANTINE-RENAMES-THE-UNSTABLE-LEG` | Set QUARANTINE_EMIT_DECLARED_NAME = True in this module -- which re-enables the duplicate-row defect the directive exists to prevent. |
| `D4-EMI-HOME-IS-THE-RATIFIED-SATELLITE` | Remove the 2 entries from ATTRIBUTE_ROUTING_SUPPRESS in this module. |
| `D5-TRANSITION-IS-BUILD-SIDE` | Remove the pair from ATTRIBUTE_UNION_ALIASES in this module. |
| `D6-CROSS-VALUE-ONLY-WHEN-UNIQUE` | Set CROSS_REQUIRE_UNIQUE = False in this module (restores arbitrary pick semantics -- not recommended). |
| `D7-UNRESOLVED-KEYS-GET-NO-KEY` | Supply an expression in the map; this build will not synthesise one. |
| `D8-COVERGRAIN-BUILT-WITH-A-FANOUT-COUNT` | Set COVERGRAIN_DIVERT_FANOUT = False in this module. |
| `D9-MEMBERSHIP-RE-DERIVED-NOT-TRUSTED` | Set TRUST_RESOLVED_ON_VIEW = True in this module -- which emits a column that does not exist. |
| `D10-SPINE-DISPLAY-RUNG-RESOLVED-FROM-THE-GRAPH` | Supply the table in the map's resolved_key; the display form will not be promoted to executable here. |

## Gates

| gate | verdict | exit |
| --- | --- | --- |
| `check_patterns` | PASS | 0 |
| `check_prose_counts` | PASS | 0 |
| `check_prose_shape` | PASS | 0 |
| `check_internal` | PASS | 0 |
| `check_vault_alignment` | FAIL | 1 |
| `check_mxh3_hashkeys` (in-chain) | PASS | 0 |

The three load-time assertions in `models/tests/` have runtime verdict **NOT
RUN**: there is no source access in this environment, so each one is written to
fail loudly at first load instead of passing silently.
