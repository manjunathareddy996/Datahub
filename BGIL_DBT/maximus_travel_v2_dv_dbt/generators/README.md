# Maximus Travel V2 -- generators

Models are **generated, never hand-edited**. Edit the generator and re-run `sh run_all.sh`.

## Headline numbers

This file states no count that describes current state. Every number below is a path into `../build_artifacts/BUILD_STATUS.json`, which a script emits.

| figure | path |
|---|---|
| models written | `.models.total` (and `.models.by_layer`) |
| views needing a cast / of them walk-only | `.layers.cast_views` / `.layers.walk_only_casts` |
| key slots / link slots | `.layers.key_slots` / `.layers.link_slots` |
| satellites, standard / augmented | `.layers.satellites_standard` / `.layers.satellites_augmented` |
| multi-active satellites | `.layers.multi_active` |
| feeders / of them instance fan-outs | `.layers.feeders` / `.layers.unpivot_feeders` |
| grammar counters (hops, LNK legs, residue) | `.grammar` |
| unresolved keys | `.unresolved_keys` |
| unbuilt items, by routing | `.unbuilt` / `.unbuilt_by_routing` |
| self-check results | `.self_checks` / `.self_checks_failed` |
| input digest over the named file set | `.input_digest` |

The per-item detail behind every one of those sits in `../build_artifacts/mtv2_spec.json`.

## Run order

```sh
#!/usr/bin/env sh
# The documented run order for Maximus Travel V2. Anything that changes it changes
# generators/README.md too, which is GENERATED from this file's companion module.
#
# The ordering is not cosmetic:
#   * build_mtv2_spec must run first -- every downstream generator reads the SPEC, never the map;
#   * gen_mtv2_vault WIPES hubfeed/ hubs/ links/ satfeed/ satellites/ audit/ before writing, so it
#     must run AFTER the stage and unpivot layers (BUILD_RULES 6.3);
#   * gen_mtv2_augmented WIPES models/automate_dv/augmented, so gen_mtv2_align -- the declared
#     bespoke shim that writes the OPUS-named SAT_AUG_* -- must run AFTER it. Running the shim
#     first writes the models and then has them deleted, leaving a build that reports satellites
#     it does not have;
#   * EVERY layer directory is wiped by its FIRST writer, so a re-run cannot inherit a model
#     nobody generates any more. Two directories have two writers: the cast layer is wiped by
#     gen_mtv2_staging (not hopviews) and the stage layer by gen_mtv2_unpivot (not stage).
#     Moving either generator earlier deletes the other's output;
#   * gen_mtv2_exemptions reads the SPEC's coverage census and must run before selfcheck, which
#     asserts that vault_tools/accepted_uncovered.txt carries exactly the lines it generated;
#   * selfcheck runs before the README and the report so a failure stops the run rather than being
#     written up as a success.
#
# NOT IN THE CHAIN, run on demand, each writing its own artifact:
#   python3 probe_mtv2_keynorm.py            -> build_artifacts/keynorm_probe.json
#       proves superseded key history cannot reach a model: it rebuilds the whole spec from a
#       scratch map whose 1444 archived previous_expression values are poisoned. Too slow for
#       every build; its cheap half runs in selfcheck_mtv2.py every time.
#   python3 verify_mtv2_gates.py             -> build_artifacts/gate_verification.json
#       runs all five shared gates DIRECTLY -- each verdict is that gate's own exit status, never
#       a pipe's -- and proves each one can FAIL by injection, restoring the tree via the chain
#       and asserting the BINARY tree digest afterwards. Not in the chain: it rebuilds the tree
#       several times and must not run inside the build it verifies.
#   python3 prove_mtv2_reproducibility.py    -> build_artifacts/reproducibility.json
#       the deletion proof. It DELETES this chain's outputs and runs the chain twice, so it is
#       never part of the chain itself.
set -e
cd "$(dirname "$0")"
python3 mtv2_names.py
python3 mtv2_keyrules.py
python3 gen_mtv2_project.py
python3 build_mtv2_spec.py
python3 gen_mtv2_staging.py
python3 gen_mtv2_hopviews.py
python3 gen_mtv2_resolvers.py
python3 gen_mtv2_unpivot.py
python3 gen_mtv2_stage.py
python3 gen_mtv2_vault.py
python3 gen_mtv2_augmented.py
python3 gen_mtv2_align.py
python3 gen_mtv2_exemptions.py
python3 selfcheck_mtv2.py
python3 gen_mtv2_readme.py
python3 report_mtv2_stage1.py
```

## Layers

| layer | output | generator | owes |
|---|---|---|---|
| layer-1 casts | `models/staging/maximus_travel_v2/` | `gen_mtv2_staging.py` | one cast per MAPPED view |
| walk-only casts | `models/staging/maximus_travel_v2/` | `gen_mtv2_hopviews.py` | one cast per view that appears anywhere on a walk, including intervening levels no expression names |
| resolvers | `automate_dv/standard/resolvers/` | `gen_mtv2_resolvers.py` | one per START view; every hop expanded into its real per-level chain |
| unpivot | `automate_dv/standard/unpivot/` | `gen_mtv2_unpivot.py` | one row per INSTANCE, column-as-instance families only |
| wide stage | `automate_dv/standard/staging/` | `gen_mtv2_stage.py` | one per view: every key it resolves, a hashdiff and a null-padded payload per satellite |
| hub feed | `automate_dv/standard/hubfeed/` | `gen_mtv2_vault.py` | unions every INSTANCE of a hub into one key pair; drops null business keys |
| hubs | `automate_dv/standard/hubs/` | `gen_mtv2_vault.py` | one per hub |
| links | `automate_dv/standard/links/` | `gen_mtv2_vault.py` | one link feed and one link per link, degenerate role leg carried |
| satellite feed | `automate_dv/standard/satfeed/` | `gen_mtv2_vault.py` | unions a satellite's feeders and renames the hashdiff to the sibling's bare HASHDIFF |
| satellites | `automate_dv/standard/satellites/` | `gen_mtv2_vault.py` | payload is the union over ALL feeders, null-padded to the SATELLITE |
| audit | `automate_dv/standard/audit/` | `gen_mtv2_vault.py` | the diagnostics that falsify this build's stated assumptions before any load |
| augmented | `automate_dv/augmented/` | `gen_mtv2_augmented.py` | the unratified track, one stage per (view, satellite), per-column reversible |
| augmented alignment shim (BESPOKE) | `automate_dv/augmented/` | `gen_mtv2_align.py` | the concepts the OPUS sibling already augments, written into ITS SAT_AUG_* under ITS contract |

## What is different about this LOB

Counts in this section are paths into `../build_artifacts/BUILD_STATUS.json`, taken from there by
reference; none is typed here.

1. **The spine operator is an LCA cross, not a climb.** Two arrows reach a SIBLING
   (`PREMIUM_DETAILS` to `POLICY_DETAILS`). A climb-only resolver returns nothing for them and
   `COLLECTED_PREMIUM` / `OUTSTANDING_PREMIUM` go missing as a phantom source gap. Both are live
   in `stg2_mtv2__uwr_prem`. Population: `.grammar.lca_cross`.
2. **The sibling-cross operator has count ZERO here.** It is not implemented and is not inherited
   from another LOB. The detector still runs, so the zero can fail: `.grammar.cross_to_sibling`.
3. **Destination tokens are ABBREVIATED** (`.grammar.dest_abbreviated`) and resolve uniquely only
   when scoped to the start view's own ancestor chain. Resolved globally, `PARTY_PROPERTY` binds
   the proposer branch to the member branch and `POLICY_DETAILS` binds to
   `PREVIOUS_POLICY_DETAILS`.
4. **A named destination skips levels** (`.grammar.hops_skipping_levels`,
   `.grammar.levels_expanded`). Sizing the cast layer from named destinations alone under-builds
   it; sizing the JOIN chain that way returns the wrong ancestor row.
5. **TWO content-hash canonicalisations, on DISJOINT hubs.** `md5(normalise(...))` on
   `HUB_LOCATION` and `LNK_PARTY_LOCATION` -- addresses, where collapsing internal whitespace is
   right. `md5(upper(trim(...)))` on `HUB_PARTY`, `LNK_PARTY_ROLE` and `HUB_ORG_UNIT` -- nominee
   and branch NAMES, where only the ends are trimmed. **Zero hubs carry both**, per
   `.content_hash_canonicalisations.by_hub`. Both are emitted as written and the split is
   reported; unifying them would re-key a hub on the builder's authority.
6. **Key rejection is by SHAPE, never by constant.** Every key expression in this map evaluates to
   NULL on an all-blank row under Snowflake semantics, including the rows
   `KEY_DEGENERATE_VALUES.csv` calls NON-EMPTY CONSTANT. A predicate `key = 'RISK:'` could never
   fire and would read exactly like a working guard. See `.key_rejection`.
7. **Nothing parses `child_key_value` prose.** A parser left in would fire on the declared gaps
   and write prose into SQL.
8. **The renumbering ordinal class is swept BY SHAPE**, re-derived from `00_tables_index.json`
   and reconciled with the profile; a disagreement stops the build. One child key is still backed
   by an ordinal and says so in its own model. See `.ordinal_child_keys`.
9. **The augmented track is LARGER than the mapped track** (`.models.by_layer`). It gets its own
   staging models, one per (view, satellite), so withdrawing a proposal is deleting a model.
10. **The sibling is OPUS `travel_dv_dbt` and its contract is absolute** on both tracks -- bare
    `HASHDIFF`, `UPPER_SNAKE` payloads, `'HUB_<NAME>|' || (key)` natural keys, `_HKEY` suffix,
    `src_pk` and grain PER SATELLITE. The payload convention is COUNTED from the sibling build on
    every run, never read as a value: the profile rewrote that field from a token into a sentence
    and a reader comparing it to a token refused the whole build.
    `maximus_travel_dv_dbt` is superseded and is not read: it is in `READ_NEVER`, so touching it
    is fatal rather than quiet.
11. **Superseded key HISTORY is archived in the map itself.** Every normalised key keeps its prior
    text in `resolved_key.keynorm.previous_expression`: valid grammar, shape-identical to a live
    expression. A selector matching on the word `expression` would build the OLD key on all of
    them and every gate here would pass. The slot set key selection reads is DECLARED and
    asserted every run, and `probe_mtv2_keynorm.py` proves containment by poisoning every
    archived value and rebuilding the whole spec. See `../build_artifacts/keynorm_probe.json`.

## Grammar census

Counts are the BUNDLE's, not this build's: a form with a count of zero was never tested, so the count is the evidence the parser was exercised (BUILD_RULES 4). `mtv2_keyrules.py` re-derives every one of them on each run and prints the parse residue.

| form | count | semantics | skips levels |
|---|---|---|---|
| `spine[<ORIGIN> -> <VIEW> [-> <VIEW>...]].<COLUMN>` | 2390 | climb | yes |
| `LNK(HUB_A = <expr>[, HUB_B = <expr>])` | 51 | link | no |
| `-> (hop arrow, only ever inside spine[])` | 5496 | climb | yes |
| `{TOKEN} brace template (value slots only, never in an expression)` | 1238 | function | no |
| `>> (cross operator)` | 0 | cross | no |

Component kinds, swept as a SET and raising on a member the profile does not census: `column_as_instance` 27, `literal` 593, `spine` 55, `template` 443, `unresolved` 1.

## Build directives

Every directive is implemented and NAMED in the generator that implements it, so this table is emitted from the code rather than remembered. Every quantity in it is taken from `build_profile.json` `.build_directives`, which is a frozen input.

| bundle item | mechanism | implemented in |
|---|---|---|
| KEY_FUNCTIONS.md section 7 / 12_round1_fixes.json items 1a and 1b | Emit resolved_key | `mtv2_keyrules.render_key` emits verbatim; `_static` proves the applied guard fires |
| BUILD_INSTRUCTIONS 2.1, the 103 / 19 guard idioms | Copy content-hash expressions through unchanged; add NO coalesce-placement rewrite rule anywhere in the generator chain | `mtv2_keyrules._render` -- no rewrite rule anywhere in the chain |
| KEY_FUNCTIONS.md section 5 | One function in mtv2_keyrules | `mtv2_keyrules.normalise_sql` -- defined exactly once |
| STAGE-0 finding: 10 rows use md5(upper(trim(...))) | Emit those 10 verbatim as mapped - changing them would re-key a hub on my own authority - and raise the divergence to the mapper | `mtv2_keyrules.content_hash_form` (BD8) + `BUILD_STATUS.json` |
| KEY_FUNCTIONS.md section 8.2 | The resolver takes the start view, walks parent_table_candidate from 00_tables_index | `mtv2_keyrules.resolve_destination` |
| KEY_FUNCTIONS.md section 8.1 | Resolve every hop as lowest-common-ancestor; a climb-only resolver silently returns nothing for PREMIUM_DETAILS -> POLICY_DETAILS and the miss reads as a source gap | `mtv2_keyrules.expand_chain` (LCA cross) |
| STAGE-0 finding: 787 arrows skip levels | Expand each hop through the parent chain before emitting joins | `mtv2_keyrules.expand_chain` + `gen_mtv2_hopviews` |
| BUILD_INSTRUCTIONS 2.3 / KEY_FUNCTIONS.md section 9 | 25 of 51 LNK call sites are POSITIONAL and 11 have a single leg, so leg identity CANNOT be recovered from a name on those | `mtv2_keyrules.parse_link` + `build_mtv2_spec` link pass (BD4, BD5) |
| BUILD_INSTRUCTIONS 2.4 and 5 | Isolate the '#' qualifier in ONE function so a source answer drops it across all 210 rows in a single edit | `mtv2_keyrules.render_key` (the qualifier is in the map's expression, isolated there) + `gen_mtv2_vault.audit_namespaces` |
| MESSAGE_TO_BUILDER.md item 4 | Build them as two satellites | `build_mtv2_spec` -- the two satellites are separate spec entries and separate models |
| augmentation.child_key_stability (NEW, 11 rows) | Build the 11 rows as mapped, and emit the declaration into BUILD_STATUS | `mtv2_keyrules.ordinal_legs` + spec `census.ordinal_child_key_legs` |
| augmentation.child_key_legs_missing (NEW, 39 rows) | Do not invent the missing legs | `build_mtv2_spec` leg-set reconciliation + spec `unbuilt` |
| augmentation.child_key_components_gap (NEW, 2 rows) | Leave both unbuilt; accepted_uncovered with the mapper's reason | `mtv2_keyrules.render_child_leg` returns None; spec `unresolved` |
| STAGE-0 finding on the 281 emitted components | Read child_key_components[] only | `mtv2_keyrules.render_child_leg` -- reads `child_key_components[]` only; no prose branch exists |
| STAGE-0 finding on Source-Target.'Source Column' | Double-quote every source column identifier in emitted SQL | `mtv2_names.quote_source_column` + `mtv2_names.cast_alias` |
| BUILD_RULES.md 7.2 / 7.7 and the OPUS build | Emit the 94 same-concept rows into the OPUS-named SAT_AUG_<X> under OPUS's contract | `mtv2_names.sibling_contract` + `gen_mtv2_align.py` (declared bespoke) |
| profile STEP 2 / component kind census | Treat leg_backing=unresolved as a HARD SENTINEL: refuse the row at build time and report it as an unbuilt item, never synthesise a literal from its `value` | see the module named in the mechanism |
| KEY_FUNCTIONS.md 8.2 scoping rule | Resolve an abbreviated destination ONLY against the start view's own ancestor chain, longest matching prefix | see the module named in the mechanism |
| BUILD_INSTRUCTIONS 2.3 / KEY_FUNCTIONS 9 | Emit the hub key expression for the leg by construction, so the two cannot diverge | see the module named in the mechanism |
| map field resolved_key.degenerate_verdict (NEW in rev 4) | Read degenerate_verdict, not degenerate_value, and not the CSV's `verdict` column (different vocabulary) | see the module named in the mechanism |
| KEY_FUNCTIONS.md 'Function census (generated)' and scripts/check_key_function_census.py | Use the ALL-LIVE figures (trim 5094 / nullif 5084 / coalesce 1783 / spine[] 2390 / md5 138 / normalise 128 / lnk 51 / upper 19) in any build-side assertion, and add a build-side allowlist ch | see the module named in the mechanism |
| Workbook 'Key Derivations' sheet, column 'Degenerate Value (all-blank row)' | Do not read the workbook for the degenerate contract | see the module named in the mechanism |
| Source column names 1ST_/2ND_/3RD_REMINDER_DATE and 64_VB_STATUS (21 row instances) | Quote every source column reference in generated SQL unconditionally, rather than special-casing these four | see the module named in the mechanism |

## Reported, not guessed

Nothing in this list was guessed. Each is built as the map says, or not built, and reported.
Every quantity behind a row is in `../build_artifacts/BUILD_STATUS.json` or
`../build_artifacts/mtv2_spec.json` at the path named.

| what | where it is counted | routed to |
|---|---|---|
| Keys whose every operand can go blank | `audit_mtv2_key_rejections` -- per hub PER FEEDER, at run time | build |
| Keys with a statically computable degenerate constant | `BUILD_STATUS.json` `.key_rejection` | build |
| The `FOREIGN_KEY` round-trip, over the spine slots in `.grammar.fk_hops`, with no sample data | `audit_mtv2_fk_roundtrip` -- `max_business_numbers_per_handle > 1` falsifies it | source |
| `HUB_RISK_OBJECT`'s two namespaces and the `TRIP_NO` fallback | `audit_mtv2_riskobject_namespaces`, and `.profile_crosschecks` asserts both namespaces are still present | source |
| Rows with no key at all on `HUB_FINANCIAL_TRANSACTION` | spec `unbuilt`, routed `source` | source |
| Rows whose child-key leg set is not the satellite's | spec `unbuilt` + `census.leg_set_choice` | mapper |
| Satellites refused for a child key made only of constant legs | spec `unresolved`, kind `collapse_trap_only` | mapper |
| LNK legs that name no hub, and what cannot be checked about them | `BUILD_STATUS.json` `.link_leg_census` | mapper |
| A child key backed by a renumbering ordinal | `.ordinal_child_keys`, and the model itself says so | modeller |
| Child keys that are ordinal-SHAPED but backed by something else | `.ordinal_child_keys.ordinal_shaped_but_not_source_backed` | mapper |
| Mapped columns that reach no payload, each with its reason | `.coverage` and `../build_artifacts/accepted_uncovered.mtv2.txt` | mapper |
| Grain divergence against the sibling | `BUILD_STATUS.json` `.sibling.grain_divergences` | modeller |
| Satellites written by BOTH this build and the sibling, and their hashdiff INPUT LISTS | `.sibling.shared_surface` | build owner |
| Rows bound to an anchor key the map resolved elsewhere on the view | spec `census.anchor_bound_by_assumption` | mapper |

**A satellite left unbuilt says why.** Every entry in the spec's `unbuilt` list carries a reason
and a routing, and `gen_mtv2_vault.py` prints the ones it refused at the vault layer by name.

## Builder decisions -- one line each to overrule

They live in `BUILDER_DECISIONS` in `mtv2_keyrules.py`, each with what it COSTS stated plainly. This table is generated from that structure, and every quantity in it is taken from there -- the decision and its cost were recorded together when the decision was taken.

| id | decision | what it costs | to overrule |
|---|---|---|---|
| `BD1-FK-HOP-IS-ONE-JOIN` | spine[FOREIGN_KEY -> V].COL emits ONE join on the document handle (v.foreign_key = b.foreign_key), not a per-level climb through the parent chain. | If FOREIGN_KEY is a file/batch handle rather than a document handle, the join fans out and every key built on it is WRONG rather than empty. Open item P6-FK-ROUNDTRIP; 863 spine occurrences depend on it and there is no sample data in this run. The per-view diagnostic in audit_mtv2_fk_roundtrip falsifies it before any load. | `set FK_HOP_MODE = 'parent_chain' in mtv2_keyrules.py` |
| `BD2-FK-INTERVENING-CASTS-PROVISIONED` | The cast layer covers every view on the PARENT CHAIN between a hop's start and its named destination, including the levels a FOREIGN_KEY hop skips and therefore never joins under BD1. | A handful of cast models are referenced by no resolver while FK_HOP_MODE is 'document_handle'. They are counted and named in the build report so they are not mistaken for dead models. | `set CAST_COVERAGE = 'joined_only' in mtv2_keyrules.py` |
| `BD3-PIVOT-PARENT-IS-THE-BASE-NODE` | On a *_PIVOT_VW, PARENT_KEY_HASH is resolved to the view's own BASE NODE (the index's parent_table_candidate), and every hop is then expanded through that chain. | If PARENT_KEY_HASH actually points past the base node, up to 1464 spine slots resolve one level short and mint a second population in HUB_RISK_OBJECT / HUB_PARTY / HUB_POLICY. audit_mtv2_spine_variants counts rows reached by each variant per (view, join column) so one source answer applies in one pass. | `set PIVOT_PARENT = 'grandparent' in mtv2_keyrules.py` |
| `BD4-LNK-LEG-CORROBORATION-IS-REPORTED-NOT-FATAL` | A LNK leg is rendered by the SAME render_key() as a hub key, so it is byte-identical by construction. Where the leg's expression is ALSO used as a standalone hub key on the same view the binding is corroborated; where it is not, the leg is still built and the absence is REPORTED. | 21 legs are built on the mapper's word alone. They are listed individually in the build report, routed to the mapper. | `set LNK_LEG_UNCORROBORATED = 'fatal' in mtv2_keyrules.py` |
| `BD5-ROLE-CODE-IS-A-DEGENERATE-LINK-LEG` | LNK_PARTY_ROLE's second leg is a role CODE ('NOMINEE', 'CUSTOMER', ...), not a hub key -- data_7.js gives LNK_PARTY_ROLE hubs=['HUB_PARTY']. It is carried into the link as a degenerate leg so the link grain is party x role. | The role column in the link table is not a hash key; a consumer joining it to a hub finds none. It IS part of the link hash, so the grain is right. | `set LINK_DEGENERATE_LEG = 'drop' in mtv2_keyrules.py` |
| `BD6-MULTI-ACTIVE-WITHOUT-A-DISCRIMINATOR-IS-SINGLE-ACTIVE` | 277 augmentation rows declare multi_active with no child key in either form. They are built SINGLE-ACTIVE in the augmented track. | If the rows really are multi-valued per parent, the satellite keeps only the last-loaded row per hub key. Every one of the 277 is listed with its proposed child-key NAME in the build report, routed to the mapper. | `set MA_WITHOUT_CDK = 'unbuilt' in mtv2_keyrules.py` |
| `BD7-HASHDIFF-FOLLOWS-THE-SIBLING` | Satellites are written with a BARE HASHDIFF, matching travel_dv_dbt on both tracks (45 of 45, counted). The wide stage still needs a unique name per satellite, so the rename happens in the satfeed view. | One satfeed view per satellite -- a model per satellite that the Maximus house pattern does not have. In exchange BUILD_RULES 12 does not apply to this build. | `set HASHDIFF_POLICY = 'maximus_house' in mtv2_names.py` |
| `BD8-TWO-CONTENT-HASH-CANONICALISATIONS-EMITTED-AS-WRITTEN` | md5(normalise(...)) (128 rows) and md5(upper(trim(...))) (10 rows) are both emitted exactly as mapped. They are NOT unified. | For a hand-typed nominee name 'AB  CD' and 'AB CD' stay two parties under the name form and would be one under normalise. That is a modeller call on a hub OPUS also writes, not a build call. Reported, open item MD5-TWO-CANONICALISATIONS. | `set CONTENT_HASH_UNIFY = True in mtv2_keyrules.py` |
| `BD9-DEGENERATE-KEYS-REJECTED-BY-SHAPE-NEVER-BY-CONSTANT` | Every hub and link key is wrapped in a CASE over 'coalesce(<guarded operands>) is not null', then nullif(trim(...),''). An outer nullif(key,'<constant>') is added ONLY where the constant is statically computable. No predicate compares a key to a value from KEY_DEGENERATE_VALUES.csv. | None measured. The static-constant branch fires 0 times on this map, and zero is reported as zero -- a guard that never fires proves something about this map, not about the build. | `set DEGENERATE_OUTER_NULLIF = False in mtv2_keyrules.py` |
| `BD10-PURE-LITERAL-KEY-IS-CONSTANT-BY-CONSTRUCTION` | A key expression with no non-literal operand at all is ACCEPTED and emitted as that literal, counted separately. | Every row on that view keys to one hub row. That is correct for a single-population namespace and wrong for anything else; the count is printed per hub so it cannot hide. | `set ACCEPT_CONSTANT_KEY = False in mtv2_keyrules.py` |
| `BD11-ANCHOR-ONLY-ROWS-BIND-TO-THE-MAP-S-OWN-KEY` | 190 blocks carry an ANCHOR but no resolved_key at all. They are bound to the key slot the MAP ITSELF resolved for that anchor on the SAME VIEW -- by instance where the row names one, by the satellite's own placement next, by the single candidate next, and by the DOMINANT instance last. | The last rule is an assumption. On one view 101 augmentation attributes name HUB_PARTY with no instance while the map resolves a proposer key (129 rows), a bagic-employee key (2) and a parent-party key (1); they bind to proposer. If that is wrong the attribute attaches to the wrong party. Every such binding is listed with its vote in the build report, routed to the mapper, and the rows are augmentation-track and per-column reversible. | `set ANCHOR_AMBIGUOUS = 'unbuilt' in mtv2_keyrules.py` |
| `BD12-LINK-LEG-BUILT-AS-MAPPED-DIVERGENCE-MEASURED` | Where a LNK leg's expression differs from the hub key the same view resolves for that hub, the leg is built AS MAPPED and the divergence is counted at run time by audit_mtv2_link_leg_divergence. | 7 value-changing legs join to nothing until the mapper rules. That failure is silent by nature -- an empty join reads as sparse source data -- so the audit model counts legs with no matching hub row per link per view, which makes it visible without guessing. 9 further disagreements are whitespace-only and are already neutralised: render_key() normalises them to the same SQL. | `set LINK_LEG_SOURCE = 'hub_key' in mtv2_keyrules.py` |
| `BD13-HUB-DOCUMENT-TWO-KEY-FORMS-BUILT-AS-MAPPED` | Where one source column keys one hub both with a namespace prefix and bare, BOTH forms are built exactly as mapped and the split is COUNTED per hub per prefix from the map in hand -- never asserted from the profile. | The hub carries two rows for any identifier that appears in both forms. The measured split per hub per prefix is in BUILD_STATUS.json .hub_key_forms; a zero there is a measured zero, not evidence the check works. One mapper answer collapses it. | `set HUB_DOCUMENT_PREFIX = 'bare' in mtv2_keyrules.py` |
| `BD14-CHILD-KEY-COMPONENT-READER-ACCEPTS-EVERY-DECLARED-SPELLING` | The child_key_components reader accepts ALL leg-name spellings {name, leg, component, maps_to} and ALL value spellings {value, expression, raw, column, source_column}, in the profile-declared order first, and refuses `role` as a name key. Two spellings for one role on one element with DIFFERENT values is fatal. | NOTHING ON THIS MAP, and that is stated rather than implied: only name, value, leg_backing, expression, resolved_on_view, note and one `column` occur, so every new branch has ZERO live occurrences and is exercised only by the reader's own divergence probe. ck_spelling_census() prints which spellings were actually read and which were merely accepted, so the widening can never be mistaken for evidence about this bundle. The mapping side has ENDED, so no re-issue can ever exercise it either -- it is insurance with no remaining policy term, and it is implemented because a reader correct only for the bytes in front of it is the defect, not the accident. | `set CK_LEG_NAME_SPELLINGS = [LEG_NAME_FIELD] (and the two sibling lists) in mtv2_keyrules.py` |
| `BD15-LINK-LEG-NAME-READER-SWEEPS-BOTH-SEPARATORS` | A LNK leg's hub name is recognised before EITHER separator, '=' or ':'. The census reports which separator named each leg, and every published link-leg figure states WHICH QUESTION it answers -- names a hub, binds to a hub, or is positional -- beside its population. | None to the build: the shipped parser already accepted both separators, so no emitted SQL changes. The cost is to the REPORT -- the published figure moves from an instructed 34/57 to a measured 39/52, and every prior figure (4, 34, 52-as-a-bare-number, 57) is listed with the scope that produced it so the next reader can tell which question each answered (BUILD_RULES 11.8). | `set LNK_LEG_NAME_SEPARATORS = ('=',) in mtv2_keyrules.py and re-run; the census will report 34/57 and say so` |
| `BD16-A-PROFILE-FIGURE-IS-CROSS-CHECKED-ON-ITS-LOAD-BEARING-HALF-ONLY` | Where a profile figure is measured over a form this build does not emit, the build asserts the load-bearing property and REPORTS the arithmetic rather than asserting equality. Applied to longest_source_view_cast_name (41), to prose_test_counts.prose_columns_covered (7), and to the collapse-trap scope figures (18 / 9 / 20). | Three profile figures are carried rather than checked, and each says so at the point of use with the population beside it. What IS asserted in their place is load-bearing: that the abbreviation vocabulary still derives the profile's example stem, that every emitted name is inside the budget, that the prose entry COUNT and its `kind` split reproduce, and that collapse-trap scope B is a subset of scope A. | `in mtv2_names._probe() and build_mtv2_spec.collapse_trap_scope_reconciliation(), turn the reported comparison back into an equality check` |

## The shared-vault HASHDIFF debt: NARROWED, not retired

Both projects write into one vault, so a satellite written by both must agree about what its hashdiff means. Measured per satellite against the sibling BUILD on every run -- never taken from the decision record -- and reported at `.sibling.shared_surface` in `../build_artifacts/BUILD_STATUS.json`:

| what was measured | path |
|---|---|
| satellites this build writes / the sibling writes | `.sibling.shared_surface.satellites_here` / `.satellites_in_the_sibling` |
| satellites BOTH write, by name | `.sibling.shared_surface.shared_by_name` |
| hashdiff COLUMN NAME disagreements across them | `.sibling.shared_surface.hashdiff_name_disagreements` |
| hashdiff INPUT LIST disagreements across them | `.sibling.shared_surface.hashdiff_input_list_disagreements` (detail per satellite in `.hashdiff_input_list_detail`) |
| what the input list means here | `.sibling.shared_surface.input_list_definition` |

**The column NAME half is retired; the residual is not.** The name agrees on every shared satellite -- that is what `BD7-HASHDIFF-FOLLOWS-THE-SIBLING` bought. The INPUT LIST does not agree on nearly all of them, so a row written by one project and read by the other still compares as CHANGED. Same name, different contents is the worse of the two failures, because the name agreeing is exactly what hides it. Reconciling the input lists is a MODELLER decision about one shared table, not a builder one, and this build does not make it.

## Link legs: SAY WHICH QUESTION YOU ARE ANSWERING

FIVE figures have now been published for this LOB's LNK legs -- 4, 34, 52, 57 and 19 -- and every one of them is true of some scope. They are not a disagreement about the map, which has been byte-identical throughout; they are five answers to three different questions over two different populations, published without the question beside them. The build therefore counts all of it in ONE place and names the question each figure answers: `.link_leg_census` in `../build_artifacts/BUILD_STATUS.json`, where `.THE_THREE_QUESTIONS` states each question in words with its own numerator and denominator, and `.FIGURES_PUBLISHED_ON_THIS_PROJECT_AND_WHAT_EACH_ANSWERED` records every prior figure with the scope that produced it. No count here is typed by hand.

The three questions are NOT interchangeable. **Does the leg NAME a hub** is a question about the map's text, and it must be swept over BOTH declared separators -- this map names legs with `=` and with `:`, and an equals-only reader silently drops the colon-named ones and reports a smaller numerator over a larger complement. **Does the leg BIND to a hub** is a question about whether the leg's expression also appears as a hub key resolved on the same view, and it has a different answer. **Is the leg POSITIONAL** asks whether it carries no name token at all, so that its hub comes from the link's hub order in `data_7.js`. The figure to quote for the COVERAGE LIMIT is `.link_leg_census.not_named_for_a_hub`, and the limit itself is in `.link_leg_census.coverage_limit`: where the map does not name the hub, the leg and the hub key are rendered by the SAME renderer and agree by construction, so `audit_mtv2_link_leg_divergence` cannot see a mis-bound leg there.

The earliest figure counted only legs that were BOTH positional AND uncorroborated -- a subset of a subset -- and understated the limit by an order of magnitude. The most recent one fused the leg total of the distinct-call-site population with the hub-naming count of that same population, and presented the pair as a split of the per-occurrence population. See `BD15` in the table above for the separator sweep and for the one line that reproduces the equals-only reading.

## Coverage: every uncovered column has a reason

The build measures coverage the way the shared gate measures it, and adds what the gate cannot: WHY. See `.coverage` in `../build_artifacts/BUILD_STATUS.json` for the totals and `../build_artifacts/mtv2_spec.json` `census.coverage.uncovered` for one record per gap, each with its class -- carried as the child key, satellite not built, or an executable derivation this build refuses -- and its routing. `gen_mtv2_exemptions.py` writes those records as the exemption text `vault_tools/accepted_uncovered.txt` must carry for this project (BUILD_RULES 8.2), and `selfcheck_mtv2.py` asserts the shared file still carries them. The generator does not write into `vault_tools`: that file is shared by every project here, and one LOB's chain must not edit another LOB's gate.

## The profile: every key disposed of, none ignored

`mtv2_names.PROFILE_KEY_DISPOSITION` carries one line per key in `build_profile.json`: `consumed` where something in this generator set builds or asserts from it, `acknowledged` where a person read it and it deliberately builds nothing, with the reason on the line. An unrecognised key is FATAL and the guard is never widened -- widening it would trade a loud failure for the silent one the rule exists to prevent. A key RENAMED between revisions is declared in `PROFILE_KEY_RENAMES`, and carrying both spellings is fatal. What the consumed keys are checked against is reported at `.profile_crosschecks`: where the profile and the map on disk disagree about an identically defined population, the build stops.

## Reproducibility

`python3 prove_mtv2_reproducibility.py` IS the proof: it digests the tree, deletes exactly what the chain rewrites, runs `run_all.sh` from empty, runs it again over the populated tree, and writes `../build_artifacts/reproducibility.json` with all three digests, the named file set and the COMBINING METHOD beside them. `build_artifacts/reports/` is never deleted and never backed up (BUILD_RULES 9.3); the script records its contents before and after and fails if they moved. No digest in this project is stated by any document that did not compute it: the input digest is at `.input_digest` in `BUILD_STATUS.json`, emitted by `build_mtv2_spec.py`.
