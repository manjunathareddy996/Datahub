# -*- coding: utf-8 -*-
"""Turn the inherited v3 profile into the v4 profile.

WHAT IS INHERITED AND WHY THAT IS LEGITIMATE
--------------------------------------------
v4 reads the SAME two pinned map contracts as v3, byte for byte (the md5s are re-asserted below),
and against the SAME frozen data_7.js. Every BUNDLE fact in the profile -- field spellings, the
grammar census, the child-key component kinds, the collapse traps, the abbreviation seed, the
prose-bearing spreadsheet columns -- is therefore a fact about an input that has not changed, and
re-deriving it would produce the same values from the same bytes.

What is NOT inherited is every LAYER fact. v3's architecture is per-source-table: a cast and a
stage per table, then satellites unioned over feeders. v4's is the central-view architecture the
user states as the governing rule, in which a satellite is fed WHOLE by one stitched view. Those
profile keys are REPLACED here, not edited, and the replacement records the rule verbatim so the
next reader does not have to reconstruct it from the generated SQL -- which is how this rule got
lost between gen 1 and gen 3 in the first place.
"""
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
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, os.pardir))
REPO_ROOT = os.path.abspath(os.path.join(PROJECT_ROOT, os.pardir))
PROFILE = os.path.join(PROJECT_ROOT, "build_profile.json")
INPUTS = os.path.join(PROJECT_ROOT, "inputs")

# The two contracts, with the md5s MEASURED off v3's copies before the copy was made. Inheriting
# a bundle fact is only legitimate while the bundle bytes are identical, so this is asserted and
# not asserted-in-a-comment.
EXPECT = {
    "04_column_map.SETTLED_post_stage6_65b.json": "cd8e0261eb9761abf8ef72db49532fad",
    "04_column_map.DELTA3.json": "15e31afced7f2d4cf8b7d0889657bf55",
}
EXPECT_MODEL_MD5 = "082b92d7650cf4e192b6e9bb931cdc7e"


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    for fn, want in EXPECT.items():
        got = md5(os.path.join(INPUTS, fn))
        if got != want:
            raise AssertionError(
                "INPUT CONTRACT CHANGED: %s is md5 %s, expected %s. The inherited bundle facts in "
                "this profile were derived from the expected bytes; with different bytes they must "
                "be RE-DERIVED, not carried." % (fn, got, want))
    got_model = md5(os.path.join(REPO_ROOT, "data_7.js"))
    if got_model != EXPECT_MODEL_MD5:
        raise AssertionError("data_7.js is md5 %s, expected the frozen %s"
                             % (got_model, EXPECT_MODEL_MD5))
    print("input contracts re-asserted: 2 maps + data_7.js, all md5-identical to v3's")

    p = json.load(io.open(PROFILE, encoding="utf-8"))
    inherited = sorted(p)

    p["lob"] = "opus_health_consolidated_v4"
    p["generated"] = "v4 central-view rebuild"
    p["derived_from_profile"] = {
        "project": "health_consolidated_v3_dv_dbt",
        "inherited_keys": len(inherited),
        "basis_token": "SAME_PINNED_BYTES",
        "basis_note": "Bundle facts are inherited because the two map contracts and data_7.js are "
                      "md5-identical to the ones they were derived from; the md5s are asserted by "
                      "amend_hcon4_profile.py at the top of every run, so a changed input stops "
                      "the build instead of silently reusing a stale fact.",
        "replaced_keys": ["layers", "layers_note", "bespoke_layers", "layer_plan_one_loader"],
        "not_inherited_note": "Every LAYER fact is replaced. v3 is per-source-table; v4 is "
                              "central-view. Nothing about v3's layer shape carries over.",
    }

    # ------------------------------------------------------------------ THE GOVERNING RULE
    p["central_view_rule"] = {
        "status": "GOVERNS",
        "stated_by": "the user, in this engagement, verbatim",
        "verbatim": (
            "1. we create a central view from source tables (by joining them , max upto 10). The "
            "join are selected so that it can feed sat as a whole (one or moew). That is we do "
            "not split sat across these views. Restriction of 10 can be broken if a sat needs "
            "more than source tables to build. If a view as less source tables join, we add more "
            "tables to it efficiently so that new sats can be built."),
        "hub_and_link_extension_verbatim": (
            "the views will have hub keys -- effectively each sat is primary key goes to hub -- so "
            "hub has to come from there, 2nd the links will also be from same view , as different "
            "hub keys and sat populatin comes from there"),
        "rules": [
            {"id": 1, "rule": "A stitched view is built by joining source tables, up to 10."},
            {"id": 2, "rule": "Joins are chosen so the view feeds WHOLE satellites, one or more. "
                              "A satellite is NEVER split across views."},
            {"id": 3, "rule": "The 10-table limit may be exceeded when a SINGLE object needs more "
                              "than 10 tables to be built whole."},
            {"id": 4, "rule": "An under-filled view absorbs more tables, efficiently, so further "
                              "objects can be built from it."},
            {"id": 5, "rule": "Hubs are derived FROM the stitched view: each satellite's anchor "
                              "hub key must resolve on its own view."},
            {"id": 6, "rule": "Links are derived FROM the stitched view: every hub leg of a link "
                              "must resolve on one single view."},
        ],
        "rule_5_6_origin": "Rules 5 and 6 are the user's hub/link extension, quoted above. They "
                           "are planning INPUTS, not post-hoc checks: the first grouping was "
                           "computed from satellite payload tables alone and left 37 satellites "
                           "on a view that could not key them, which is why they are stated here "
                           "as rules and enforced in hcon4_plan.py.",
        "contradicts": "BUILD_RULES.md s6, which calls its per-source-table layer architecture "
                       "'Invariant across every build' and mandates one cast per mapped view, one "
                       "wide stage per view, and satellites unioned over all feeders. Under this "
                       "rule a satellite has ONE feeder by construction. s6 and this rule cannot "
                       "both hold; the user has ruled that this rule governs. s6 is NOT edited by "
                       "this build -- a build does not rewrite the law it is judged by -- and the "
                       "conflict is carried to the handback as the first item.",
        "gen1_precedent": "This rule was implemented once before, in health_dv_dbt's 43 "
                          "models/automate_dv/standard/stitched/ views (FULL OUTER JOIN + "
                          "attribute COALESCE, hashed exactly once downstream in the companion "
                          "stg2_ model). It was never written down anywhere in the repo, which is "
                          "why every build after gen 1 drifted away from it.",
    }

    # ------------------------------------------------------------------ the v4 layer set
    p["layers"] = [
        "staging",      # one per source table: raw passthrough, typed, no business logic
        "stitched",     # THE central views. One per satellite group, joins its source tables
        "stage",        # one per stitched view: the ONE place hashes are computed
        "hub_feeds",    # one per (hub, stitched view) that carries that hub's key
        "hubs",         # one per model hub keyed anywhere, unioned over its feeds
        "links",        # one per model link whose every leg co-occurs on one stitched view
        "satellites",   # one per satellite, fed WHOLE by exactly one stage
        "augmented",    # the augmentation track, same shape, kept separate
        "reject_log",   # declared rejections, countable
        "assertions",   # the invariants this architecture claims, as runnable tests
    ]
    p["layers_note"] = (
        "The chain is staging -> stitched -> stage -> {hub_feeds -> hubs, links, satellites}. "
        "Hashing happens in exactly ONE layer, stage, and exactly once per view, because there is "
        "nothing to hash until the stitch has produced one clean row per key. A satellite reads "
        "ONE stage model and no other, which is what makes rule 2 checkable rather than hoped "
        "for: a satellite with two sources is a rule-2 violation a gate can see. No walk-only "
        "casts, no resolvers and no hopviews: under this rule a parent is JOINED IN, not climbed "
        "to, so the resolver layer has nothing to range over -- and the grammar census already "
        "found zero walk operators in this map.")
    p["bespoke_layers"] = [
        {"name": "stitched",
         "reason_note": "Not a layer BUILD_RULES.md s6 defines. It is the central view of the "
                        "governing rule: a sideways merge of the source tables one satellite "
                        "group needs, at that group's grain, producing one clean row per key "
                        "BEFORE anything is hashed. s6's per-source-table stage cannot express it, "
                        "because s6 hashes per table and then unions, which is precisely the "
                        "satellite-splitting rule 2 forbids."},
        {"name": "declared_unresolved_register",
         "reason_note": "Carried from v3. Every object this build REFUSED rather than fabricated, "
                        "counted, with the hub or leg that could not be keyed named. Required "
                        "because under rules 5 and 6 an object whose key resolves nowhere cannot "
                        "be emitted at all, and an absent model is not a defect any gate sees."},
    ]
    p["layer_plan_one_loader"] = {
        "rule_token": "ONE_STAGE_PER_STITCHED_VIEW_ONE_SOURCE_PER_SATELLITE",
        "mechanism_note": "v3's dual-feed loader is NOT carried. Under the central-view rule the "
                          "two runs' feeds for one satellite are joined INSIDE that satellite's "
                          "stitched view, so by the time the stage hashes a row the reconciliation "
                          "has already happened in one place and the satellite has exactly one "
                          "source. The R8 source precedence still applies -- it moves from the "
                          "satellite loader into the stitched view's COALESCE order, which is "
                          "where a sideways merge belongs.",
    }

    io.open(PROFILE, "w", encoding="utf-8").write(
        json.dumps(p, indent=1, ensure_ascii=False) + "\n")
    print("profile amended: %d keys (%d inherited, %d layer keys replaced, 2 added)"
          % (len(p), len(inherited), 4))
    return 0


if __name__ == "__main__":
    sys.exit(main())
