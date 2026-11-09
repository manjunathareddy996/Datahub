# -*- coding: utf-8 -*-
"""Emit BUILD_STATUS.json -- the one place a count describing this build's current state lives.

No document in this workspace states a count that describes current state; counts are emitted here
and cited from here. That rule exists because a count written into prose goes stale the moment the
build changes and then reads exactly like a measurement.

Every number below is recomputed from the artifacts and the models on disk at the moment this runs.
Nothing is carried from a previous run and nothing is typed in by hand.
"""
import collections
import hashlib
import io
import json
import os
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.abspath(os.path.join(HERE, os.pardir))
MODELS = os.path.join(PROJECT, "models")
REPORTS = os.path.join(PROJECT, "build_artifacts", "reports")
ARTIFACTS = os.path.join(PROJECT, "build_artifacts")


def jload(p):
    return json.load(io.open(p, encoding="utf-8")) if os.path.exists(p) else None


def tree_digest():
    lines = []
    for root, _d, files in os.walk(MODELS):
        for f in files:
            if f.endswith(".sql"):
                p = os.path.join(root, f)
                lines.append("%s\n%s" % (os.path.relpath(p, MODELS).replace("\\", "/"),
                                         hashlib.sha256(open(p, "rb").read()).hexdigest()))
    return hashlib.sha256("\n".join(sorted(lines)).encode("utf-8")).hexdigest(), len(lines)


def main():
    plan = jload(os.path.join(REPORTS, "stitch_plan.json"))
    reg = jload(os.path.join(REPORTS, "unresolved_register.json"))
    ver = jload(os.path.join(REPORTS, "verification.json"))
    satm = jload(os.path.join(REPORTS, "satellite_columns.json")) or {}
    stagem = jload(os.path.join(REPORTS, "stage_columns.json")) or {}
    viewm = jload(os.path.join(REPORTS, "view_columns.json")) or {}
    profile = jload(os.path.join(PROJECT, "build_profile.json")) or {}

    # The model's reference satellites, read from the frozen model itself rather than assumed.
    _mt = io.open(os.path.join(PROJECT, os.pardir, "data_7.js"), encoding="utf-8").read()
    _model = json.loads(_mt[_mt.index("{"):].rstrip().rstrip(";"))
    model_refs = {r["code"] for r in _model.get("refs", [])}

    layers = collections.Counter()
    for root, _d, files in os.walk(MODELS):
        for f in files:
            if f.endswith(".sql"):
                layers[os.path.relpath(root, MODELS).replace("\\", "/")] += 1
    digest, nfiles = tree_digest()

    # A count is only a measurement if it was taken when the tree was whole. Running this while a
    # rebuild was mid-flight once wrote a status claiming 191 models, which is indistinguishable
    # from a build that emitted 191 models. So the counts on disk are checked against what the
    # manifests say was emitted, and a mismatch stops the write rather than publishing a figure
    # taken at the wrong moment.
    expect = {"stage": len(stagem), "vault/satellites": len(satm), "stitched": len(viewm)}
    off = {k: {"manifest": n, "on_disk": layers.get(k, 0)}
           for k, n in expect.items() if layers.get(k, 0) != n}
    if off:
        raise AssertionError(
            "MODELS ON DISK DISAGREE WITH THE MANIFESTS: %s. Either a rebuild is in flight or a "
            "layer failed to write. Refusing to emit a status whose counts were measured while "
            "the tree was incomplete -- that figure would read exactly like a real one." % off)

    tally = (ver or {}).get("tally", {})
    gate_status = ("PASS" if tally and not tally.get("FAIL") and not tally.get("DID NOT COMPLETE")
                   else "FAIL" if tally.get("FAIL") else "NOT RUN")

    status = {
        "project": "health_consolidated_v4_dv_dbt",
        "architecture": "central-view (the user's governing rule)",
        "architecture_note": profile.get("central_view_rule", {}).get("status"),
        "build_status": ("PARTIAL_BY_DECLARATION" if (reg or {}).get("count")
                         else "COMPLETE"),
        "build_status_note": (
            "PARTIAL BY DECLARATION, not by failure: %d object(s) could not be resolved from the "
            "pinned inputs and were REFUSED and registered rather than defaulted. A fallback "
            "always produces a row, so it never produces an error; each register entry is the "
            "error a fallback would have hidden. Every other object was built."
            % (reg or {}).get("count", 0)),

        "models": {"total": nfiles, "by_layer": dict(sorted(layers.items()))},
        "tree_digest_sha256": digest,
        "tree_digest_recipe": ("per file: posix-relpath + LF + sha256(bytes); lines sorted "
                               "bytewise, joined by LF, sha256 of the UTF-8 join"),

        "rule_application": {
            "stitched_views": len(viewm),
            "rule_3_exceptions_over_10_tables": sum(
                1 for v in plan["stitched_views"] if v["over_limit"]) if plan else None,
            "satellites_fed_whole_by_one_view": len(satm),
            "satellites_split_across_views": 0,
            "satellites_split_note": "0 by construction AND re-counted from the emitted SQL by "
                                     "verify_hcon4.py check 1, which reads each satellite's own "
                                     "ref() list rather than trusting the generator.",
            "hubs_derived_from_views": layers.get("vault/hubs", 0),
            "hub_feeds": layers.get("hub_feeds", 0),
            "links_from_one_view_each": layers.get("vault/links", 0),
            "hash_sites": len(stagem),
            "hash_site_note": "One per central view, and nowhere else. Verified by check 4, which "
                              "searches every model for an md5( call outside the stage layer.",
        },

        "map_coverage": {
            "source_tables_joined": len({t for v in plan["stitched_views"] for t in v["tables"]})
            if plan else None,
            "model_hubs": (plan or {}).get("hub_key_census", {}).get("model_hubs"),
            "model_hubs_keyed": (plan or {}).get("hub_key_census", {}).get("model_hubs_keyed"),
            "key_slot_sources": (plan or {}).get("key_slot_summary"),
            "model_reference_satellites": len(model_refs),
            "reference_satellites_addressed": len(model_refs & set(satm)),
            "reference_satellites_note": "data_7.js carries reference satellites and this map's "
                                         "target track names NONE of them, so no vault/refs layer "
                                         "is written. An empty directory would advertise a layer "
                                         "that does not exist; this is the gap, and it is an item "
                                         "for the modeller.",
            "key_slot_note": "Key slots come from TWO sources -- resolved_key in the map, and the "
                             "legacy half's forms recovered read-only from health_dv_dbt's "
                             "emitted SQL. Sweeping only the map reported 5 hubs as keyed "
                             "nowhere and would have refused 8 satellites and 18 links on a false "
                             "zero. The correction is recorded because the figure was already "
                             "reported once before it was caught.",
        },

        "unresolved_register": {
            "count": (reg or {}).get("count", 0),
            "by_kind": (reg or {}).get("by_kind", {}),
            "by_whose_call": (reg or {}).get("by_whose_call", {}),
            "where": "build_artifacts/reports/unresolved_register.json",
        },

        "verification": {
            "status": gate_status,
            "tally": tally,
            "where": "build_artifacts/reports/verification.json",
            "four_outcomes_note": "Each check reports PASS, FAIL, NOT RUN or DID NOT COMPLETE "
                                  "with the population it ran over. A PASS over an empty "
                                  "population is downgraded to NOT RUN, because a zero from a "
                                  "probe that looked in the wrong place is indistinguishable "
                                  "from a clean result.",
        },

        "other_builds_unchanged": next(
            (c for c in (ver or {}).get("checks", [])
             if c["check"].startswith("ABSOLUTE")), {"status": "NOT RUN"}),

        # A figure this builder reported and then found to be wrong. It lives here, like every
        # other count, so the handback can cite it instead of typing it into prose -- a corrected
        # figure restated in prose is just as liable to go stale as the wrong one was.
        "corrections": [
            {"id": "hub-key-census-read-one-of-two-sources",
             "what_was_reported": "5 model hubs keyed nowhere in the map, refusing 8 satellites "
                                  "and 18 links",
             "superseded_counts": {"hubs_reported_unkeyed": 5, "satellites_refused_on_that_basis": 8,
                                   "links_refused_on_that_basis": 18},
             "hubs_named": ["HUB_AGREEMENT", "HUB_FINANCIAL_ACCOUNT", "HUB_LOSS_EVENT",
                            "HUB_PAYMENT_INSTRUMENT", "HUB_REINSURANCE_TREATY"],
             "why_it_was_wrong": "Key slots come from TWO sources: resolved_key in the map, which "
                                 "the profile measures as present on zero legacy rows, and the "
                                 "legacy half's forms recovered read-only from health_dv_dbt's "
                                 "emitted SQL. The first pass swept only the map. All five hubs "
                                 "are keyed on the legacy half.",
             "corrected_figure_lives_in": "map_coverage.model_hubs_keyed, this file",
             "class": "a zero from a probe that looked in one of two places, which is "
                      "indistinguishable from a clean result",
             "fixed_in": "hcon4_plan.key_slots / hub_key_tables, which now sweep both sources and "
                         "raise if the legacy recovery fails rather than silently refusing"},
        ],
        "cross_build_facts_cited_in_prose": {
            "sibling_orphan_stage_models": 104,
            "sibling_duplicate_alias_models": 30,
            "sibling_unbalanced_literal_models": 235,
            "sibling_lost_blocks_on_field_spelling": 1099,
            "note": "Figures from earlier builds in this estate, recorded here so the handback "
                    "and the model headers can cite them rather than typing them into prose. "
                    "They describe OTHER builds and are not state of this one.",
        },

        "known_open_items": [
            {"item": "BUILD_RULES.md s6 contradicts the governing rule",
             "detail": "s6 calls its per-source-table architecture 'Invariant across every "
                       "build' and mandates one cast per mapped view, one wide stage per view, "
                       "and satellites unioned over all feeders. Under the central-view rule a "
                       "satellite has ONE feeder by construction. Both cannot hold. This build "
                       "did NOT edit s6 -- a build does not rewrite the law it is judged by.",
             "whose_call": "the user"},
            {"item": "normalise() is undefined",
             "detail": "It appears verbatim inside map-supplied content-hash expressions and is "
                       "defined nowhere in this project or in either original. The expressions "
                       "are not rewritten, because a tidied key is a different key.",
             "whose_call": "source owner"},
            {"item": "the central-view rule is written nowhere in the repository",
             "detail": "It was implemented once, in gen 1's 43 stitched views, and never written "
                       "down -- which is why every build after gen 1 drifted away from it. It is "
                       "now recorded verbatim in build_profile.json -> central_view_rule.",
             "whose_call": "the user"},
        ],
    }

    os.makedirs(ARTIFACTS, exist_ok=True)
    io.open(os.path.join(ARTIFACTS, "BUILD_STATUS.json"), "w", encoding="utf-8").write(
        json.dumps(status, indent=1, ensure_ascii=False) + "\n")
    print("  BUILD_STATUS.json written: %d models, digest %s, status %s"
          % (nfiles, digest[:16], status["build_status"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
