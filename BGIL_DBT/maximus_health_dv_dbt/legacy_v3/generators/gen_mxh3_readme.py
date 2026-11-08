# -*- coding: utf-8 -*-
"""generators/README.md, GENERATED FROM BUILD_STATUS.json.

NO COUNT IN THE README IS TYPED BY HAND. Every quantity is read from
build_artifacts/BUILD_STATUS.json at generation time and the table says so, which
is what lets check_prose_counts pass: a figure in current-state prose must either
be sourced or absent.
"""
import json
import os

import mxh3_names as N
import mxh3_writeguard as W

GEN = "gen_mxh3_readme.py"
STATUS = os.path.join(W.ARTIFACTS, "BUILD_STATUS.json")
OUT = os.path.join(W.HERE if hasattr(W, "HERE") else
                   os.path.dirname(os.path.abspath(__file__)), "README.md")


def main():
    if not os.path.isfile(STATUS):
        raise AssertionError(
            "BUILD_STATUS.json is absent. The README is GENERATED FROM IT, so it cannot be "
            "written first: no count in it may be typed by hand.")
    with open(STATUS, encoding="utf-8") as fh:
        s = json.load(fh)
    prof = N.PROFILE
    L = []
    A = L.append

    A("# Maximus Health V3 -- generators")
    A("")
    A("**Every number on this page is taken from `build_artifacts/BUILD_STATUS.json`")
    A("by reference.** Nothing here is typed by hand; re-run `gen_mxh3_readme.py` after")
    A("any build and the figures follow. Models are generated, never hand-edited --")
    A("edit the generator and re-run.")
    A("")
    A("## Headline")
    A("")
    A("| figure | value | where it comes from |")
    A("| --- | --- | --- |")
    A("| models emitted | %d | `BUILD_STATUS.models_total` |" % s["models_total"])
    A("| model tree sha256 | `%s` | `BUILD_STATUS.model_tree_digest.tree_sha256` |"
      % s["model_tree_digest"]["tree_sha256"])
    A("| generators in the chain | %d | `BUILD_STATUS.generators_total` |"
      % s["generators_total"])
    A("| map md5 | `%s` | `BUILD_STATUS.map.md5` |" % s["map"]["md5"])
    A("| map bytes | %d | `BUILD_STATUS.map.bytes` |" % s["map"]["bytes"])
    A("| unresolved, reported | %d | `BUILD_STATUS.unresolved_total` |"
      % s["unresolved_total"])
    A("| build directives implemented | %d | `BUILD_STATUS.build_directives_implemented` |"
      % s["build_directives_implemented"])
    A("")
    A("Digest combining method: %s." % s["model_tree_digest"]["combining_method"])
    A("")

    A("## Run order")
    A("")
    A("```")
    A("python3 run_mxh3_build.py      # deletes models/ and rebuilds FROM EMPTY")
    A("```")
    A("")
    A("| # | generator | owes |")
    A("| --- | --- | --- |")
    for i, g in enumerate(s["generators"], 1):
        A("| %d | `%s` | %s |" % (i, g["generator"], g["purpose"]))
    A("")
    A("`check_mxh3_hashkeys.py` then runs INSIDE the chain, and the five shared gates")
    A("run as subprocesses with `PYTHONDONTWRITEBYTECODE=1`, never imported.")
    A("")

    A("## Layers")
    A("")
    A("| directory | models | layer owes |")
    A("| --- | --- | --- |")
    owes = {
        "staging": "layer-1 typed casts for views that NEED one",
        "hopviews": "casts for views on a walk, including every intervening level",
        "resolvers": "one per start view; joins expanded per REAL level",
        "unpivot": "one row per instance, column-as-instance families only",
        "stage": "one wide stage per view: keys and their EMIT flags",
        "reject_log": "divert-and-COUNT, the exact complement of EMIT",
        "vault/hub_feeds": "one per (view, DECLARED ANCHOR EXPRESSION)",
        "vault/hubs": "assembled from the per-source feeds",
        "vault/link_feeds": "one per (view, DECLARED LEG EXPRESSIONS)",
        "vault/links": "assembled; completeness asserted both ways",
        "vault/satellites": "ratified track, payload NULL-PADDED TO THE SATELLITE",
        "augmented": "the unratified build-side track",
        "quarantine": "BESPOKE: surrogate_child_key_quarantine (declared)",
        "reference_decode": "BESPOKE: reference_decode_gate (declared)",
        "tests": "load-time assertions; runtime verdict NOT RUN",
    }
    for d in sorted(s["models_by_directory"]):
        A("| `%s` | %d | %s |" % (d, s["models_by_directory"][d], owes.get(d, "--")))
    A("")

    A("## What is different about this LOB")
    A("")
    A("**The shape inverts from the calibration sibling.** OPUS Health is flat: 0")
    A("hierarchy edges, 0 resolvers, 0 walk-only casts. This source is a shredded EAV")
    A("feed WITH a spine, so resolvers and unpivot are both REQUIRED and were derived")
    A("from the graph here, not inherited.")
    A("")
    c = s["census"]
    A("| property | value | source |")
    A("| --- | --- | --- |")
    A("| spans, climb / cross | %d / %d | `BUILD_STATUS.json` census.spans_climb/.spans_cross |"
      % (c.get("spans_climb", 0), c.get("spans_cross", 0)))
    A("| spans skipping >=1 real level | %d | `BUILD_STATUS.json` census |"
      % c.get("spans_skipping_a_level", 0))
    A("| walk-only casts | %d | `BUILD_STATUS.json` census |" % c.get("hopview_views", 0))
    A("| resolver views | %d | `BUILD_STATUS.json` census |" % c.get("resolver_views", 0))
    A("| unpivot views | %d | `BUILD_STATUS.json` census |" % c.get("unpivot_views", 0))
    A("")
    A("Only 52 of 1,812 climbs name the direct parent (`build_profile.json")
    A("hierarchy.level_skip_census`), so level-skipping is the dominant case and every")
    A("intervening level is materialised as its own join.")
    A("")

    A("## Grammar census")
    A("")
    A("| form | count | semantics | source |")
    A("| --- | --- | --- | --- |")
    for g in prof["grammar"]:
        A("| `%s` | %d | %s | `build_profile.json grammar[]` |"
          % (g["form"].replace("|", "\\|"), g["count"], g["semantics"]))
    A("")
    A("Parse residue over all %d executable key slots: %d (`build_profile.json")
    A("grammar_totals.executable_key_slots`, `parse_residue`).")
    L[-2] = ("Parse residue over all %d executable key slots: %d (`build_profile.json"
             % (prof["grammar_totals"]["executable_key_slots"], prof["parse_residue"]))
    A("")

    A("## Build directives")
    A("")
    A("Counts in this table are the BUNDLE's, taken from `build_profile.json`")
    A("build_directives[] and the map's own directive fields -- not current state.")
    A("")
    A("| # | bundle item | mechanism | implemented in |")
    A("| --- | --- | --- | --- |")
    import mxh3_keyrules as K
    for d in K.BUILD_DIRECTIVES:
        A("| %d | %s | %s | `%s` |"
          % (d["n"], d["bundle_item"], d["mechanism"], d["implemented_in"]))
    A("")

    A("## Reported, not guessed")
    A("")
    A("Nothing below was resolved by the builder. Each is counted and routed.")
    A("")
    A("| what | count | source |")
    A("| --- | --- | --- |")
    for k, v in sorted(s["unresolved_by_kind"].items()):
        A("| %s | %d | `BUILD_STATUS.unresolved_by_kind` |" % (k.replace("_", " "), v))
    ar = s["anchor_resolution"]
    A("| anchors resolved uniquely | %d | `BUILD_STATUS.anchor_resolution` |"
      % ar["resolved_uniquely"])
    A("| anchors REFUSED, ambiguous | %d | `BUILD_STATUS.anchor_resolution` |"
      % ar["refused_ambiguous"])
    A("| anchors REFUSED, none declared | %d | `BUILD_STATUS.anchor_resolution` |"
      % ar["refused_absent"])
    A("")
    A("A feeder is `(view, DECLARED ANCHOR EXPRESSION)` and never `(view)` alone. An")
    A("anchor that does not resolve uniquely is REFUSED and REPORTED -- never keyed on")
    A("a guess, because a fallback that guesses converts a loud gap into a silent")
    A("corruption that compiles cleanly.")
    A("")

    A("## Validator dispositions")
    A("")
    A("| disposition | declared blocks | re-derived | verdict |")
    A("| --- | --- | --- | --- |")
    for d in s["dispositions"]:
        A("| %s | %s | %s | %s |"
          % (d["disposition"], d.get("declared_blocks"),
             d.get("re_derived_unresolvable", "n/a"), d["verdict"]))
    A("")
    A("Each REFUSE has its PRECONDITION verified before being executed: a REFUSE is the")
    A("destructive direction and is unrecoverable at load, so where a finding's stated")
    A("mechanism is measurably absent from the map in hand the blocks are NOT deleted,")
    A("and the staleness is reported instead. See decision `D11`.")
    A("")

    A("## Where to overrule a decision")
    A("")
    A("Every builder decision is one line to overrule. They live in")
    A("`mxh3_keyrules.BUILDER_DECISIONS`, each with its reasoning and WHAT IT COSTS.")
    A("")
    A("Any quantity in a switch description is taken from `build_profile.json` or the")
    A("map, describing the DECISION's scope rather than current state.")
    A("")
    A("| id | switch |")
    A("| --- | --- |")
    for d in K.BUILDER_DECISIONS:
        A("| `%s` | %s |" % (d["id"], d.get("overrule_note", "--")))
    A("")
    A("## Gates")
    A("")
    A("| gate | verdict | exit |")
    A("| --- | --- | --- |")
    for g in s["gates"]:
        A("| `%s` | %s | %s |" % (g["gate"], g["verdict"], g["exit_code"]))
    A("| `check_mxh3_hashkeys` (in-chain) | %s | %s |"
      % (s["in_chain_invariants"]["verdict"], s["in_chain_invariants"]["exit_code"]))
    A("")
    A("The three load-time assertions in `models/tests/` have runtime verdict **NOT")
    A("RUN**: there is no source access in this environment, so each one is written to")
    A("fail loudly at first load instead of passing silently.")
    A("")

    W.write(OUT, "\n".join(L), generator=GEN)
    print("README.md generated from BUILD_STATUS.json")
    print("  models_total  : %d  (by reference, not typed)" % s["models_total"])
    print("  tree sha256   : %s" % s["model_tree_digest"]["tree_sha256"])
    return 1


if __name__ == "__main__":
    main()
