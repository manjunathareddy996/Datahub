# -*- coding: utf-8 -*-
"""gen_mtv2_readme.py -- generators/README.md, generated.

BUILD_RULES 11.7 and CLAUDE.md: no document in this workspace states a count that describes
CURRENT STATE. The headline numbers are therefore emitted as REFERENCES into
build_artifacts/BUILD_STATUS.json -- a path the reader can resolve -- never as a number typed
here. The grammar census carries counts because those describe the BUNDLE, which is a frozen
input, and BUILD_RULES 4 requires the count as the evidence the parser was exercised.

The run-order block is read from run_all.sh, so the two cannot disagree.
"""
import json
import os
import sys

import mtv2_names as N
import mtv2_keyrules as K
import build_mtv2_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

README = os.path.join(N.GEN_DIR, "README.md")

LAYERS = [
    ("layer-1 casts", "models/staging/maximus_travel_v2/", "gen_mtv2_staging.py",
     "one cast per MAPPED view"),
    ("walk-only casts", "models/staging/maximus_travel_v2/", "gen_mtv2_hopviews.py",
     "one cast per view that appears anywhere on a walk, including intervening levels no "
     "expression names"),
    ("resolvers", "automate_dv/standard/resolvers/", "gen_mtv2_resolvers.py",
     "one per START view; every hop expanded into its real per-level chain"),
    ("unpivot", "automate_dv/standard/unpivot/", "gen_mtv2_unpivot.py",
     "one row per INSTANCE, column-as-instance families only"),
    ("wide stage", "automate_dv/standard/staging/", "gen_mtv2_stage.py",
     "one per view: every key it resolves, a hashdiff and a null-padded payload per satellite"),
    ("hub feed", "automate_dv/standard/hubfeed/", "gen_mtv2_vault.py",
     "unions every INSTANCE of a hub into one key pair; drops null business keys"),
    ("hubs", "automate_dv/standard/hubs/", "gen_mtv2_vault.py", "one per hub"),
    ("links", "automate_dv/standard/links/", "gen_mtv2_vault.py",
     "one link feed and one link per link, degenerate role leg carried"),
    ("satellite feed", "automate_dv/standard/satfeed/", "gen_mtv2_vault.py",
     "unions a satellite's feeders and renames the hashdiff to the sibling's bare HASHDIFF"),
    ("satellites", "automate_dv/standard/satellites/", "gen_mtv2_vault.py",
     "payload is the union over ALL feeders, null-padded to the SATELLITE"),
    ("audit", "automate_dv/standard/audit/", "gen_mtv2_vault.py",
     "the diagnostics that falsify this build's stated assumptions before any load"),
    ("augmented", "automate_dv/augmented/", "gen_mtv2_augmented.py",
     "the unratified track, one stage per (view, satellite), per-column reversible"),
    ("augmented alignment shim (BESPOKE)", "automate_dv/augmented/", "gen_mtv2_align.py",
     "the concepts the OPUS sibling already augments, written into ITS SAT_AUG_* under ITS "
     "contract"),
]

DIFFERENT = """\
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
"""


REPORTED_NOT_GUESSED = """\
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
"""



def run_order():
    lines = []
    for line in open(os.path.join(N.GEN_DIR, "run_all.sh"), encoding="utf-8"):
        line = line.rstrip("\n")
        if line.startswith("python3 ") or line.startswith("#") or line.startswith("set ") \
                or line.startswith("cd "):
            lines.append(line)
    return "\n".join(lines)


def main():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    status_path = os.path.join(N.ARTIFACTS, "BUILD_STATUS.json")
    if not os.path.exists(status_path):
        raise SystemExit("REFUSING TO WRITE README: BUILD_STATUS.json is absent. Every headline "
                         "number here is a reference into it; without it the README would have to "
                         "state a count, which is the thing BUILD_RULES 11.7 forbids.")

    out = []
    out.append("# Maximus Travel V2 -- generators\n")
    out.append("Models are **generated, never hand-edited**. Edit the generator and re-run "
               "`sh run_all.sh`.\n")
    out.append("## Headline numbers\n")
    out.append("This file states no count that describes current state. Every number below is a "
               "path into `../build_artifacts/BUILD_STATUS.json`, which a script emits.\n")
    out.append("| figure | path |")
    out.append("|---|---|")
    for label, path in [
        ("models written", "`.models.total` (and `.models.by_layer`)"),
        ("views needing a cast / of them walk-only", "`.layers.cast_views` / `.layers.walk_only_casts`"),
        ("key slots / link slots", "`.layers.key_slots` / `.layers.link_slots`"),
        ("satellites, standard / augmented", "`.layers.satellites_standard` / `.layers.satellites_augmented`"),
        ("multi-active satellites", "`.layers.multi_active`"),
        ("feeders / of them instance fan-outs", "`.layers.feeders` / `.layers.unpivot_feeders`"),
        ("grammar counters (hops, LNK legs, residue)", "`.grammar`"),
        ("unresolved keys", "`.unresolved_keys`"),
        ("unbuilt items, by routing", "`.unbuilt` / `.unbuilt_by_routing`"),
        ("self-check results", "`.self_checks` / `.self_checks_failed`"),
        ("input digest over the named file set", "`.input_digest`"),
    ]:
        out.append("| %s | %s |" % (label, path))
    out.append("")
    out.append("The per-item detail behind every one of those sits in "
               "`../build_artifacts/mtv2_spec.json`.\n")

    out.append("## Run order\n")
    out.append("```sh")
    out.append(run_order())
    out.append("```\n")

    out.append("## Layers\n")
    out.append("| layer | output | generator | owes |")
    out.append("|---|---|---|---|")
    for name, path, gen, owes in LAYERS:
        out.append("| %s | `%s` | `%s` | %s |" % (name, path, gen, owes))
    out.append("")

    out.append("## What is different about this LOB\n")
    out.append(DIFFERENT)

    out.append("## Grammar census\n")
    out.append("Counts are the BUNDLE's, not this build's: a form with a count of zero was never "
               "tested, so the count is the evidence the parser was exercised (BUILD_RULES 4). "
               "`mtv2_keyrules.py` re-derives every one of them on each run and prints the parse "
               "residue.\n")
    out.append("| form | count | semantics | skips levels |")
    out.append("|---|---|---|---|")
    for g in N.PROFILE["grammar"]:
        out.append("| `%s` | %d | %s | %s |"
                   % (g["form"], g["count"], g["semantics"],
                      "yes" if g.get("skips_levels") else "no"))
    out.append("")
    out.append("Component kinds, swept as a SET and raising on a member the profile does not "
               "census: %s.\n"
               % ", ".join("`%s` %d" % (k, v)
                           for k, v in sorted(N.PROFILE["component_kinds"].items())))

    out.append("## Build directives\n")
    out.append("Every directive is implemented and NAMED in the generator that implements it, "
               "so this table is emitted from the code rather than remembered. Every quantity in "
               "it is taken from `build_profile.json` `.build_directives`, which is a frozen "
               "input.\n")
    out.append("| bundle item | mechanism | implemented in |")
    out.append("|---|---|---|")
    for d in N.PROFILE["build_directives"]:
        out.append("| %s | %s | %s |"
                   % (d["bundle_item"].replace("|", "/"),
                      d["mechanism"].split(".")[0].replace("|", "/").replace("\n", " ")[:190],
                      DIRECTIVE_HOME.get(d["bundle_item"], "see the module named in the mechanism")))
    out.append("")

    out.append("## Reported, not guessed\n")
    out.append(REPORTED_NOT_GUESSED)

    out.append("## Builder decisions -- one line each to overrule\n")
    out.append("They live in `BUILDER_DECISIONS` in `mtv2_keyrules.py`, each with what it COSTS "
               "stated plainly. This table is generated from that structure, and every quantity "
               "in it is taken from there -- the decision and its cost were recorded together "
               "when the decision was taken.\n")
    out.append("| id | decision | what it costs | to overrule |")
    out.append("|---|---|---|---|")
    for d in K.BUILDER_DECISIONS:
        out.append("| `%s` | %s | %s | `%s` |"
                   % (d["id"], d["decision"].replace("|", "/"),
                      d["costs"].replace("|", "/"), d["overrule"]))
    out.append("")
    out.append("## The shared-vault HASHDIFF debt: NARROWED, not retired\n")
    out.append(
        "Both projects write into one vault, so a satellite written by both must agree about "
        "what its hashdiff means. Measured per satellite against the sibling BUILD on every run "
        "-- never taken from the decision record -- and reported at `.sibling.shared_surface` in "
        "`../build_artifacts/BUILD_STATUS.json`:\n")
    out.append("| what was measured | path |")
    out.append("|---|---|")
    for label, path in [
        ("satellites this build writes / the sibling writes",
         "`.sibling.shared_surface.satellites_here` / `.satellites_in_the_sibling`"),
        ("satellites BOTH write, by name", "`.sibling.shared_surface.shared_by_name`"),
        ("hashdiff COLUMN NAME disagreements across them",
         "`.sibling.shared_surface.hashdiff_name_disagreements`"),
        ("hashdiff INPUT LIST disagreements across them",
         "`.sibling.shared_surface.hashdiff_input_list_disagreements` (detail per satellite in "
         "`.hashdiff_input_list_detail`)"),
        ("what the input list means here", "`.sibling.shared_surface.input_list_definition`"),
    ]:
        out.append("| %s | %s |" % (label, path))
    out.append("")
    out.append(
        "**The column NAME half is retired; the residual is not.** The name agrees on every "
        "shared satellite -- that is what `BD7-HASHDIFF-FOLLOWS-THE-SIBLING` bought. The INPUT "
        "LIST does not agree on nearly all of them, so a row written by one project and read by "
        "the other still compares as CHANGED. Same name, different contents is the worse of the "
        "two failures, because the name agreeing is exactly what hides it. Reconciling the input "
        "lists is a MODELLER decision about one shared table, not a builder one, and this build "
        "does not make it.\n")

    out.append("## Link legs: SAY WHICH QUESTION YOU ARE ANSWERING\n")
    out.append(
        "FIVE figures have now been published for this LOB's LNK legs -- 4, 34, 52, 57 and 19 -- "
        "and every one of them is true of some scope. They are not a disagreement about the map, "
        "which has been byte-identical throughout; they are five answers to three different "
        "questions over two different populations, published without the question beside them. "
        "The build therefore counts all of it in ONE place and names the question each figure "
        "answers: `.link_leg_census` in `../build_artifacts/BUILD_STATUS.json`, where "
        "`.THE_THREE_QUESTIONS` states each question in words with its own numerator and "
        "denominator, and "
        "`.FIGURES_PUBLISHED_ON_THIS_PROJECT_AND_WHAT_EACH_ANSWERED` records every prior figure "
        "with the scope that produced it. No count here is typed by hand.\n")
    out.append(
        "The three questions are NOT interchangeable. **Does the leg NAME a hub** is a question "
        "about the map's text, and it must be swept over BOTH declared separators -- this map "
        "names legs with `=` and with `:`, and an equals-only reader silently drops the "
        "colon-named ones and reports a smaller numerator over a larger complement. **Does the "
        "leg BIND to a hub** is a question about whether the leg's expression also appears as a "
        "hub key resolved on the same view, and it has a different answer. **Is the leg "
        "POSITIONAL** asks whether it carries no name token at all, so that its hub comes from "
        "the link's hub order in `data_7.js`. The figure to quote for the COVERAGE LIMIT is "
        "`.link_leg_census.not_named_for_a_hub`, and the limit itself is in "
        "`.link_leg_census.coverage_limit`: where the map does not name the hub, the leg and the "
        "hub key are rendered by the SAME renderer and agree by construction, so "
        "`audit_mtv2_link_leg_divergence` cannot see a mis-bound leg there.\n")
    out.append(
        "The earliest figure counted only legs that were BOTH positional AND uncorroborated -- a "
        "subset of a subset -- and understated the limit by an order of magnitude. The most "
        "recent one fused the leg total of the distinct-call-site population with the "
        "hub-naming count of that same population, and presented the pair as a split of the "
        "per-occurrence population. See `BD15` in the table above for the separator sweep and "
        "for the one line that reproduces the equals-only reading.\n")

    out.append("## Coverage: every uncovered column has a reason\n")
    out.append(
        "The build measures coverage the way the shared gate measures it, and adds what the gate "
        "cannot: WHY. See `.coverage` in `../build_artifacts/BUILD_STATUS.json` for the totals "
        "and `../build_artifacts/mtv2_spec.json` `census.coverage.uncovered` for one record per "
        "gap, each with its class -- carried as the child key, satellite not built, or an "
        "executable derivation this build refuses -- and its routing. "
        "`gen_mtv2_exemptions.py` writes those records as the exemption text "
        "`vault_tools/accepted_uncovered.txt` must carry for this project (BUILD_RULES 8.2), and "
        "`selfcheck_mtv2.py` asserts the shared file still carries them. The generator does not "
        "write into `vault_tools`: that file is shared by every project here, and one LOB's "
        "chain must not edit another LOB's gate.\n")

    out.append("## The profile: every key disposed of, none ignored\n")
    out.append(
        "`mtv2_names.PROFILE_KEY_DISPOSITION` carries one line per key in `build_profile.json`: "
        "`consumed` where something in this generator set builds or asserts from it, "
        "`acknowledged` where a person read it and it deliberately builds nothing, with the "
        "reason on the line. An unrecognised key is FATAL and the guard is never widened -- "
        "widening it would trade a loud failure for the silent one the rule exists to prevent. "
        "A key RENAMED between revisions is declared in `PROFILE_KEY_RENAMES`, and carrying both "
        "spellings is fatal. What the consumed keys are checked against is reported at "
        "`.profile_crosschecks`: where the profile and the map on disk disagree about an "
        "identically defined population, the build stops.\n")

    out.append("## Reproducibility\n")
    out.append(
        "`python3 prove_mtv2_reproducibility.py` IS the proof: it digests the tree, deletes "
        "exactly what the chain rewrites, runs `run_all.sh` from empty, runs it again over the "
        "populated tree, and writes `../build_artifacts/reproducibility.json` with all three "
        "digests, the named file set and the COMBINING METHOD beside them. "
        "`build_artifacts/reports/` is never deleted and never backed up (BUILD_RULES 9.3); the "
        "script records its contents before and after and fails if they moved. No digest in this "
        "project is stated by any document that did not compute it: the input digest is at "
        "`.input_digest` in `BUILD_STATUS.json`, emitted by `build_mtv2_spec.py`.\n")

    N.write_model(README, "\n".join(out))
    print("gen_mtv2_readme -> %s" % README)
    print("  layers documented   : %d" % len(LAYERS))
    print("  grammar forms       : %d" % len(N.PROFILE["grammar"]))
    print("  build directives    : %d" % len(N.PROFILE["build_directives"]))
    print("  builder decisions   : %d" % len(K.BUILDER_DECISIONS))
    print("  headline numbers typed by hand: 0 -- every one is a path into BUILD_STATUS.json")


DIRECTIVE_HOME = {
    "MESSAGE_TO_BUILDER.md item 1 / BUILD_INSTRUCTIONS 2.1":
        "`mtv2_keyrules.render_key` (BD9) + `gen_mtv2_vault.audit_body`",
    "KEY_FUNCTIONS.md section 7 / 12_round1_fixes.json items 1a and 1b":
        "`mtv2_keyrules.render_key` emits verbatim; `_static` proves the applied guard fires",
    "BUILD_INSTRUCTIONS 2.1, the 103 / 19 guard idioms":
        "`mtv2_keyrules._render` -- no rewrite rule anywhere in the chain",
    "KEY_FUNCTIONS.md section 5": "`mtv2_keyrules.normalise_sql` -- defined exactly once",
    "STAGE-0 finding: 10 rows use md5(upper(trim(...)))":
        "`mtv2_keyrules.content_hash_form` (BD8) + `BUILD_STATUS.json`",
    "KEY_FUNCTIONS.md section 8.2": "`mtv2_keyrules.resolve_destination`",
    "KEY_FUNCTIONS.md section 8.1": "`mtv2_keyrules.expand_chain` (LCA cross)",
    "STAGE-0 finding: 787 arrows skip levels": "`mtv2_keyrules.expand_chain` + `gen_mtv2_hopviews`",
    "BUILD_INSTRUCTIONS 2.3 / KEY_FUNCTIONS.md section 9":
        "`mtv2_keyrules.parse_link` + `build_mtv2_spec` link pass (BD4, BD5)",
    "BUILD_INSTRUCTIONS 2.4 and 5":
        "`mtv2_keyrules.render_key` (the qualifier is in the map's expression, isolated there) + "
        "`gen_mtv2_vault.audit_namespaces`",
    "MESSAGE_TO_BUILDER.md item 4":
        "`build_mtv2_spec` -- the two satellites are separate spec entries and separate models",
    "augmentation.child_key_stability (NEW, 11 rows)":
        "`mtv2_keyrules.ordinal_legs` + spec `census.ordinal_child_key_legs`",
    "augmentation.child_key_legs_missing (NEW, 39 rows)":
        "`build_mtv2_spec` leg-set reconciliation + spec `unbuilt`",
    "augmentation.child_key_components_gap (NEW, 2 rows)":
        "`mtv2_keyrules.render_child_leg` returns None; spec `unresolved`",
    "STAGE-0 finding on the 281 emitted components":
        "`mtv2_keyrules.render_child_leg` -- reads `child_key_components[]` only; no prose branch "
        "exists",
    "STAGE-0 finding on Source-Target.'Source Column'":
        "`mtv2_names.quote_source_column` + `mtv2_names.cast_alias`",
    "BUILD_RULES.md 7.2 / 7.7 and the OPUS build":
        "`mtv2_names.sibling_contract` + `gen_mtv2_align.py` (declared bespoke)",
    "KEY_DEGENERATE_VALUES.csv":
        "NOT read as a predicate source; `mtv2_keyrules._static` evaluates the expressions "
        "instead (BD9)",
}

if __name__ == "__main__":
    main()
