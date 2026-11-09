# -*- coding: utf-8 -*-
"""Emit BUILDER_ASKS_HEALTH_V4.md -- what goes back, routed by whose call each item is.

The builder raises and leaves. It does not correct the mapping, and it does not decide a question
of meaning on the mapper's or the modeller's behalf -- a builder who resolves a grain question has
changed a primary key, and nobody downstream can tell that happened.

Every count in this document is cited to the artifact that holds it, never restated, because a
count written into prose goes stale the moment the build changes and then reads as a measurement.
"""
import collections
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
REPORTS = os.path.join(PROJECT, "build_artifacts", "reports")
OUT = os.path.join(PROJECT, "BUILDER_ASKS_HEALTH_V4.md")

PROVENANCE = ("source: every count in this section is in "
              "`build_artifacts/reports/unresolved_register.json`, recomputed each build")


def jload(p):
    return json.load(io.open(p, encoding="utf-8")) if os.path.exists(p) else None


# What each refusal kind means for the counterparty, and what would unblock it. A kind with no
# entry here raises rather than being emitted with an empty ask -- an unexplained refusal is a
# refusal nobody can act on.
ASKS = {
    "no_resolvable_anchor": (
        "modeller",
        "data_7.js states no hub or link parent for this satellite and the map declares no single "
        "hub anchor for it, so there is nothing to key it to.",
        "State the parent in data_7.js, or name one anchor in the map. The builder will not pick "
        "among candidates: choosing an anchor chooses the satellite's primary key."),
    "source_table_grouped_but_never_joined": (
        "mapper",
        "The plan grouped this table into one or more views because a satellite needs its "
        "columns, but every one of those views refused it from its join. Nothing reads it, so no "
        "staging model is emitted for it -- an unread staging model is dead code that reads as "
        "work (source: build_profile.json and BUILD_STATUS.json cross_build_facts, for how many "
        "a sibling build shipped).",
        "Resolve the join-path or ambiguous-slot item registered against the same table, and it "
        "will be staged and joined on the next build."),
    "no_join_path_into_this_view": (
        "mapper",
        "This source table shares no hub key with any other table in the view that needs it, so "
        "it can only be reached by a cross join.",
        "Supply a key for it that one of its view's other tables also carries, or confirm the "
        "columns it contributes should be dropped."),
    "only_ambiguous_key_slots_for_every_shared_hub": (
        "modeller",
        "Every hub this table shares with its view carries MORE THAN ONE key slot on it, so there "
        "is no single expression to join on. The slots are different identifier populations -- "
        "BJAZ_ENROLL_POL_DTLS carries six HUB_PARTY slots, which are six roles.",
        "Rule which slot is the join key for this table, or confirm the table should be split by "
        "role first. Joining on one slot would key the whole view by one role."),
    "child_key_leg_unresolved": (
        "mapper",
        "data_7.js declares the satellite multi-active with a child key, and at least one leg of "
        "that child key resolves to no column on any table of the satellite's own view. The legs "
        "are NOT rendered: a wrong child key is unrecoverable after load.",
        "Map each declared leg to a real column on a table that view joins, or have the modeller "
        "narrow the declared child key to the legs the source can supply."),
    "payload_withheld_table_not_joinable": (
        "mapper",
        "Attributes of this satellite sit on a table refused from its own view's join, so they "
        "are withheld rather than multiplied in by a cross join.",
        "Same fix as the join-path item: give the table a shared key, or confirm the attributes "
        "are dropped."),
    "satellite_anchor_key_not_staged": (
        "mapper",
        "The satellite's own central view stages no hash key for its anchor hub, so it cannot be "
        "keyed from the view it is built on.",
        "Supply a key expression for that hub on a table the view joins."),
    "satellite_has_no_renderable_payload_on_its_view": (
        "mapper",
        "The satellite's own central view rendered none of its attributes, so there is nothing to "
        "hash and no satellite is emitted.",
        "Check the attribute names against data_7.js; an attribute recorded as a descriptive "
        "phrase is not rendered into a column."),
    "satellite_payload_entirely_withheld": (
        "mapper",
        "After withholding, no payload column remained.",
        "Resolve the underlying withholding reason recorded against the same satellite."),
    "payload_column_is_also_a_child_key_leg": (
        "modeller",
        "A column is both a child-key leg and a payload attribute of the same satellite. The leg "
        "is kept because it is part of the grain; the payload copy is withheld rather than "
        "selected twice.",
        "Confirm the column belongs in the grain and not also in the payload, or rename one."),
    "link_leg_not_staged_on_its_view": (
        "mapper",
        "The link's view stages no hash key for one of its legs, usually because that hub's key "
        "slot on the relevant table is ambiguous. The link is not emitted from a partial grain: a "
        "link row with a null leg records a relationship to nothing.",
        "Disambiguate the leg hub's key slot on a table that view joins."),
    "proposed_satellite_has_no_central_view": (
        "modeller",
        "The map proposes attributes for a satellite that no central view feeds, so there is "
        "nothing to propose them FROM.",
        "Either ratify the satellite in data_7.js so it acquires an anchor and a view, or "
        "withdraw the proposal."),
    "proposed_satellite_anchor_not_staged": (
        "mapper",
        "A proposed payload could not be keyed: no hash key for its anchor is staged on its view.",
        "Supply a key expression for that hub on a table the view joins."),
    "proposed_attribute_name_is_prose": (
        "mapper",
        "A proposed attribute name is a descriptive phrase, not an attribute name. It is not "
        "rendered: a phrase in an identifier position becomes a column that cannot exist.",
        "Give each proposed attribute a name, with the description in a note field."),
    "undefined_udf_normalise": (
        "source owner",
        "normalise() appears verbatim inside map-supplied content-hash key expressions and is "
        "defined nowhere in this project or in either original project.",
        "Create the UDF in the warehouse, or have the mapper replace the expressions. The builder "
        "did not rewrite them, because a tidied key is a different key and would not reproduce "
        "legacy's hash values."),
    "no_grain_assertion_possible": (
        "mapper",
        "A central view's spine hub has no staged hash key, so the grain that view claims cannot "
        "be asserted at run time. The view is not left silently unchecked; this is the gap.",
        "Supply a key for the spine hub on a table that view joins."),
    "stitched_view_has_no_joinable_table": (
        "mapper",
        "Every table of a view was refused from its join, so no central view could be built.",
        "Resolve the per-table join-path items for that view."),
    "source_table_names_no_column": (
        "mapper", "The map names a table but no column on it.",
        "Supply its columns, or remove the table from the map."),
    "attribute_name_is_prose": (
        "mapper", "An attribute name is a descriptive phrase and is not rendered into a column.",
        "Give it an attribute name and move the description to a note field."),
    "stage_would_hash_nothing": (
        "mapper", "A view yielded no hub key and no satellite payload to hash.",
        "Resolve that view's key and payload items."),
    "stitched_view_selects_nothing": (
        "mapper", "No key and no attribute could be rendered for a view.",
        "Resolve that view's upstream items."),
    "join_column_not_renderable": (
        "mapper", "The plan joins a table on a hub for which no single slot renders a join column.",
        "Disambiguate that hub's key slot on that table."),
}


def main():
    reg = jload(os.path.join(REPORTS, "unresolved_register.json")) or {"entries": [], "count": 0}
    plan = jload(os.path.join(REPORTS, "stitch_plan.json")) or {}
    ver = jload(os.path.join(REPORTS, "verification.json")) or {}

    unknown = sorted({e["kind"] for e in reg["entries"]} - set(ASKS))
    if unknown:
        raise AssertionError(
            "refusal kind(s) %s have no routed ask. An unexplained refusal is one nobody can act "
            "on, so this raises instead of emitting an empty item." % unknown)

    by_call = collections.defaultdict(lambda: collections.defaultdict(list))
    for e in reg["entries"]:
        by_call[ASKS[e["kind"]][0]][e["kind"]].append(e)

    L = []
    w = L.append
    w("# Builder asks -- OPUS Health, central-view rebuild (v4)")
    w("")
    w("This is what the builder could not resolve from the pinned inputs, routed by whose call "
      "each item is. The builder raises and leaves: it does not correct the mapping, and it does "
      "not settle a question of meaning on anyone's behalf. A builder who resolves a grain "
      "question has changed a primary key, and nothing downstream can tell that happened.")
    w("")
    w("No count in this document is restated in prose. Every figure lives in "
      "`build_artifacts/BUILD_STATUS.json` and `build_artifacts/reports/`, and is recomputed on "
      "every build.")
    w("")

    w("## 0. The first item is not a mapping question")
    w("")
    w("`BUILD_RULES.md` section 6 describes its per-source-table layer architecture as "
      "*\"Invariant across every build\"*: one cast per mapped view, one wide stage per view, and "
      "satellites whose payload is the union over all feeders. The rule this build was instructed "
      "to follow says the opposite -- a satellite is fed WHOLE by one central view, so it has one "
      "feeder by construction and there is nothing to union.")
    w("")
    w("Both cannot hold. This build implements the central-view rule, as instructed, and did "
      "**not** edit section 6: a build does not rewrite the law it is judged by. The rule as "
      "stated is recorded verbatim in `build_profile.json` under `central_view_rule`, together "
      "with the hub and link extension.")
    w("")
    w("Worth recording why this matters beyond this build: the rule was implemented once before, "
      "in gen 1's `health_dv_dbt/models/automate_dv/standard/stitched/` views, and was written "
      "down nowhere. That is why every build after gen 1 drifted away from it, each one passing "
      "its gates. **Whose call:** the user's.")
    w("")

    w("## 1. A correction to a figure this builder already reported")
    w("")
    w("An earlier pass of this rebuild reported that five model hubs -- `HUB_AGREEMENT`, "
      "`HUB_FINANCIAL_ACCOUNT`, `HUB_LOSS_EVENT`, `HUB_PAYMENT_INSTRUMENT`, "
      "`HUB_REINSURANCE_TREATY` -- were keyed nowhere in the map, and refused a number of "
      "satellites and links on that basis. The superseded figures are recorded by reference in "
      "`build_artifacts/BUILD_STATUS.json` under `corrections`, rather than restated here: a "
      "corrected figure typed into prose goes stale exactly as readily as the wrong one did.")
    w("")
    w("That was wrong, and the fault was the builder's. Key slots come from **two** sources: "
      "`resolved_key` in the map, which the profile measures as present on zero legacy rows, and "
      "the legacy half's key forms, which exist in no map and are recovered read-only from "
      "`health_dv_dbt`'s emitted SQL. The first pass swept only the map. All five hubs are keyed "
      "on the legacy half; the real figure is in `BUILD_STATUS.json` under "
      "`map_coverage.model_hubs_keyed`. No mapper action is needed on those five.")
    w("")
    w(PROVENANCE)
    w("")
    w("It is recorded here rather than quietly fixed because the wrong figure was reported before "
      "it was caught, and a zero from a probe that looked in one of two places is "
      "indistinguishable from a clean result.")
    w("")

    titles = {"mapper": "2. For the mapper", "modeller": "3. For the modeller",
              "source owner": "4. For the source owner"}
    for call in ("mapper", "modeller", "source owner"):
        kinds = by_call.get(call)
        if not kinds:
            continue
        w("## %s" % titles[call])
        w("")
        w(PROVENANCE)
        w("")
        for kind in sorted(kinds):
            _c, what, fix = ASKS[kind]
            items = kinds[kind]
            w("### %s" % kind.replace("_", " "))
            w("")
            w("**What it is.** %s" % what)
            w("")
            w("**What would unblock it.** %s" % fix)
            w("")
            objs = sorted({str(e["object"]) for e in items})
            w("**Affected objects** (full list in the register): %s%s"
              % (", ".join("`%s`" % o for o in objs[:12]),
                 ", and more" if len(objs) > 12 else ""))
            w("")

    w("## 5. What the builder decided, and how to overrule each one")
    w("")
    w("Each of these is a RENDERING choice the builder is entitled to make. None is a question of "
      "meaning. Each is named so it can be overruled in one place.")
    w("")
    w("| Decision | Where it lives | Overrule by |")
    w("| --- | --- | --- |")
    w("| Run precedence for a sideways merge: v2 > legacy > delta3 | `hcon4_emit.RUN_RANK` | "
      "change that mapping |")
    w("| A link is placed on the SMALLEST view carrying all its legs | "
      "`hcon4_plan.build_plan`, link placement | change the `min()` key |")
    w("| A rule-4 pull-in takes the most-populated key registry for the hub | "
      "`hcon4_plan.build_plan`, candidate scoring | change the sort key; alternatives not taken "
      "are recorded per satellite in `stitch_plan.json` |")
    w("| Every column is cast to varchar | `gen_hcon4_staging.py` | supply a datatype catalogue; "
      "the bundle carries none, and a type inferred from a column name is a fabricated datum |")
    w("| A child-key leg that is also a payload attribute keeps the LEG | "
      "`gen_hcon4_vault.py` | reverse it, or rename one of the two |")
    w("")

    w("## 6. What was verified, and what was not")
    w("")
    w("Results are in `build_artifacts/reports/verification.json`, with four outcomes per check "
      "-- PASS, FAIL, NOT RUN, DID NOT COMPLETE -- each carrying the population it ran over. A "
      "PASS over an empty population is reported as NOT RUN.")
    w("")
    w("Three of this architecture's assumptions are facts about DATA, not about SQL, so no "
      "generator can verify them. They are emitted as runtime assertions in `models/assertions/` "
      "instead of being assumed: whether each central view holds the grain its dedupe claims, "
      "whether a satellite lost its payload to the hashdiff guard, and whether any satellite row "
      "is orphaned from its hub. Their count is in `BUILD_STATUS.json`.")
    w("")

    io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(L) + "\n")
    print("  BUILDER_ASKS_HEALTH_V4.md written: %d routed item kind(s) over %d register entry/ies"
          % (sum(len(v) for v in by_call.values()), reg["count"]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
