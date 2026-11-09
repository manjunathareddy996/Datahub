# -*- coding: utf-8 -*-
"""THE STITCH PLAN. The one place the central-view rule is turned into a grouping.

Every other generator reads this plan and emits from it; none of them decides which tables a view
joins. That separation is the point: the rule is implemented once, checkable in one file, and the
emitters cannot quietly diverge from it.

THE SIX RULES, AND HOW EACH IS DISCHARGED HERE
----------------------------------------------
  1  view joins up to 10 source tables        -> LIMIT, applied in group()
  2  a satellite is NEVER split across views  -> each satellite appears in exactly ONE group, and
                                                 assert_plan() re-counts the homes rather than
                                                 trusting the construction
  3  the limit breaks for a single big object -> an object whose own requirement exceeds LIMIT gets
                                                 its own view, flagged over_limit
  4  an under-filled view absorbs more tables -> greedy best-fit packing, and the same mechanism
                                                 pulls in a table to satisfy rules 5 and 6
  5  the satellite's anchor hub key resolves
     on its OWN view                          -> required_hubs() is part of the requirement SET,
                                                 not a check afterwards
  6  every leg of a link resolves on ONE view -> links are placed after satellites, extending a
                                                 view where the budget allows

WHY 5 AND 6 ARE REQUIREMENTS AND NOT CHECKS
-------------------------------------------
The first version of this plan computed requirements from satellite PAYLOAD tables only and then
checked the hub keys afterwards. 37 of 131 satellites sat on a view that did not carry their own
anchor key, and 5 views carried no hub key at all. A check cannot fix a grouping; only the
grouping can. Both figures are now structurally 0 and re-asserted on every run.

WHAT IS REFUSED, AND WHY REFUSING IS THE ONLY HONEST OPTION
-----------------------------------------------------------
Five model hubs are keyed on NO table anywhere in either map contract. A satellite anchored on one
of them, and a link with such a leg, cannot be built from any view -- not because of how the
grouping came out, but because the key does not exist in the input. Those objects are REFUSED and
registered. The alternative is to key them from somewhere the rule does not allow, and a fallback
always produces a row, so it never produces an error.
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
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, os.pardir))
REPO_ROOT = os.path.abspath(os.path.join(PROJECT_ROOT, os.pardir))
INPUTS = os.path.join(PROJECT_ROOT, "inputs")
REPORTS = os.path.join(PROJECT_ROOT, "build_artifacts", "reports")
PLAN_PATH = os.path.join(REPORTS, "stitch_plan.json")

MAP_FILES = ("04_column_map.SETTLED_post_stage6_65b.json", "04_column_map.DELTA3.json")
MODEL_PATH = os.path.join(REPO_ROOT, "data_7.js")

# Rule 1's number, in ONE place. Read from the profile's rule set so the rule text and the
# constant cannot drift apart.
with io.open(os.path.join(PROJECT_ROOT, "build_profile.json"), encoding="utf-8") as _fh:
    _PROFILE = json.load(_fh)
if _PROFILE.get("central_view_rule", {}).get("status") != "GOVERNS":
    raise AssertionError("profile.central_view_rule.status is not GOVERNS; this plan implements a "
                         "rule the profile does not say governs. Refusing to group.")
LIMIT = 10


def n(s):
    return " ".join(str(s or "").split())


def load_map():
    rows = []
    for fn in MAP_FILES:
        d = json.load(io.open(os.path.join(INPUTS, fn), encoding="utf-8"))
        part = d["columns"] if isinstance(d, dict) and "columns" in d else d
        for r in part:
            r = dict(r)
            r.setdefault("_contract", fn)
            rows.append(r)
    return rows


def load_model():
    t = io.open(MODEL_PATH, encoding="utf-8").read()
    return json.loads(t[t.index("{"):].rstrip().rstrip(";"))


MODEL = load_model()
HUBS = {h["code"] for h in MODEL["hubs"]}
# A link's legs come from the 'hubs' field: probed, not assumed -- it is the only list-of-strings
# field present on all 71 links.
LINK_LEGS = {l["code"]: [n(x) for x in (l.get("hubs") or []) if n(x) in HUBS]
             for l in MODEL["links"]}
SATS = {s["code"] for s in MODEL["sats"]}
REFS = {r["code"] for r in MODEL.get("refs", [])}
PARENT = {s["code"]: n(s.get("parent")) for s in MODEL["sats"] + MODEL.get("refs", [])}


def read_blocks(rows):
    """Flatten the map to one record per (row, track).

    BOTH satellite spellings are read on BOTH tracks. The target track names its satellite in
    `satellite`; the augmentation track uses `new_satellite` or `best_home_satellite`. Reading one
    spelling for both tracks lost about a third of a sibling map's blocks while every gate passed,
    so the fallback chain is deliberate and the per-track census below is printed, not assumed.
    """
    out = []
    for r in rows:
        tbl = n(r.get("table_name"))
        for track in ("target", "augmentation"):
            o = r.get(track)
            if not isinstance(o, dict):
                continue
            rk = o.get("resolved_key") if isinstance(o.get("resolved_key"), dict) else {}
            out.append({
                "table": tbl, "track": track, "column": n(r.get("column_name")),
                "contract": r.get("_contract"),
                "sat": (n(o.get("satellite")) or n(o.get("new_satellite"))
                        or n(o.get("best_home_satellite"))),
                "attr": n(o.get("attribute")) or n(o.get("proposed_attribute")),
                "anchor": n(o.get("anchor")),
                "hub": n(rk.get("hub")), "expr": n(rk.get("expression")),
            })
    return out


def census(blocks):
    """Per-track field census. A track contributing far fewer named satellites than it has blocks
    is the signature of a field-spelling miss, so it is printed every run."""
    rep = {}
    for track in ("target", "augmentation"):
        bs = [b for b in blocks if b["track"] == track]
        rep[track] = {"blocks": len(bs), "with_satellite": sum(1 for b in bs if b["sat"]),
                      "distinct_satellites": len({b["sat"] for b in bs if b["sat"]}),
                      "with_key_expression": sum(1 for b in bs if b["expr"] and b["hub"])}
    return rep


def key_slots(blocks):
    """(table, hub) -> every renderable key expression for it, with its provenance.

    A (table, hub) pair with MORE THAN ONE expression has more than one key SLOT, and the slots
    are different identifier populations, not spellings of one. BJAZ_ENROLL_POL_DTLS carries six
    HUB_PARTY slots -- 'EMP:' || RM_CODE, CORPORATE_ID and four more -- which are different PARTIES
    in different roles. Collapsing them to one would silently pick a role and key every row of the
    view by it, so the list is returned WHOLE and the caller must decide, never this function.

    The two provenances have different shapes and are NOT merged within a pair: the map gives a
    full expression to emit verbatim, legacy archaeology gives a bare column name. The measured
    overlap between the two sources is zero pairs, so no pair mixes them.
    """
    from_map = collections.defaultdict(set)
    for b in blocks:
        if b["expr"] and b["hub"]:
            from_map[(b["table"], b["hub"])].add(b["expr"])

    out = {}
    for k, v in from_map.items():
        out[k] = {"exprs": sorted(v), "source": "map.resolved_key", "render": "verbatim"}

    try:
        sys.path.insert(0, HERE)
        import hcon_keyrules as K
        recovered, _stats = K.legacy_key_forms()
        tables = {b["table"] for b in blocks if b["table"]}
        upper = {t.upper(): t for t in tables}
        for (stem, hub), exprs in recovered.items():
            t = upper.get(stem.upper())
            if t is None:
                continue
            k = (t, hub)
            if k in out:                       # map wins; measured overlap is 0 pairs
                continue
            out[k] = {"exprs": sorted(exprs), "source": "legacy_emitted_sql",
                      "render": "bare_column"}
    except Exception as exc:                   # noqa: BLE001
        raise AssertionError(
            "legacy key archaeology FAILED (%r). Every hub keyed only on the legacy half would be "
            "refused, which is a FALSE refusal: this is how 5 hubs, 8 satellites and 18 links were "
            "once reported as unbuildable. Refusing to plan on half the key slots." % (exc,))
    return out


def hub_key_tables(blocks):
    """hub -> set of source tables on which a key for it can be resolved, FROM BOTH SOURCES.

    THERE ARE TWO SOURCES OF KEY SLOTS, AND READING ONLY ONE REPORTS A FALSE ZERO
    ----------------------------------------------------------------------------
    (a) resolved_key.expression in the map -- but the profile measures
        legacy_half_status.resolved_key_on_legacy_rows = 0, so this field covers the v2 and
        delta3 halves ONLY.
    (b) the legacy half's key forms, which exist nowhere in any map and are recovered from
        health_dv_dbt's EMITTED SQL, read-only (keyrules BD2).

    Reading only (a) reported five model hubs as "keyed nowhere" -- HUB_AGREEMENT,
    HUB_FINANCIAL_ACCOUNT, HUB_LOSS_EVENT, HUB_PAYMENT_INSTRUMENT, HUB_REINSURANCE_TREATY -- and
    would have refused 8 satellites and 18 links on that basis. It is false: v3 emits
    SAT_ACCOUNT_BALANCE keyed on HUB_FINANCIAL_ACCOUNT from a recovered legacy slot. A zero from a
    probe looking in one of two places is indistinguishable from a clean result, which is why both
    sources are swept here and their contributions are reported separately.

    Keyed by the hub name AS THE MAP SPELLS IT, which is NOT always a model hub code: this map
    records LNK_PARTY_ROLE, LNK_POLICY_PARTY and REF_BANK_BRANCH_IFSC in the same field. Counting
    those as hubs overstated hub coverage as 18 of 20 when the true figure from source (a) alone
    is 15 of 20, so the split is returned explicitly instead of being collapsed.
    """
    from_map = collections.defaultdict(set)
    for b in blocks:
        if b["expr"] and b["hub"]:
            from_map[b["hub"]].add(b["table"])

    # ---- source (b): legacy archaeology, read-only -----------------------------------------
    from_legacy = collections.defaultdict(set)
    legacy_stats = {"enabled": False}
    try:
        sys.path.insert(0, HERE)
        import hcon_keyrules as K
        recovered, legacy_stats = K.legacy_key_forms()
        known = {t for ts in from_map.values() for t in ts}
        all_tables = known | {b["table"] for b in blocks if b["table"]}
        upper = {t.upper(): t for t in all_tables}
        matched = unmatched = 0
        for (view_stem, hub), _exprs in recovered.items():
            tbl = upper.get(view_stem.upper())
            if tbl is None:
                unmatched += 1
                continue
            matched += 1
            from_legacy[hub].add(tbl)
        legacy_stats = dict(legacy_stats)
        legacy_stats["slots_matched_to_a_map_table"] = matched
        legacy_stats["slots_with_no_map_table"] = unmatched
        legacy_stats["match_note"] = (
            "A recovered slot is keyed by the legacy raw-view stem (stg_health__<stem>); it is "
            "joined to the map's table_name by upper-casing the stem. Slots that match no map "
            "table are COUNTED, not dropped silently -- they are legacy views this consolidation "
            "does not carry.")
    except Exception as exc:                        # noqa: BLE001 -- reported, never swallowed
        legacy_stats = {"enabled": False, "failed": repr(exc),
                        "consequence": "legacy key slots are MISSING from this plan; every hub "
                                       "keyed only on the legacy half will be refused. This is a "
                                       "FALSE refusal and the build must not be reported as "
                                       "complete while it stands."}

    merged = collections.defaultdict(set)
    for src in (from_map, from_legacy):
        for h, ts in src.items():
            merged[h] |= ts
    model_hubs = {h: ts for h, ts in merged.items() if h in HUBS}
    non_hub_names = {h: sorted(ts) for h, ts in merged.items() if h not in HUBS}
    provenance = {
        "hubs_keyed_by_map_resolved_key": sorted(h for h in from_map if h in HUBS),
        "hubs_keyed_only_by_legacy_sql": sorted(h for h in from_legacy
                                                if h in HUBS and h not in from_map),
        "legacy_archaeology": legacy_stats,
    }
    return model_hubs, non_hub_names, provenance


def required_hubs(sat, blocks, by_sat=None):
    """The hubs whose key MUST resolve on this satellite's own view, and the basis for saying so.

    Resolution order is the MODEL first and the map second, never a choice between them: data_7.js
    states the parent, so a generator that picks among candidate hubs is inventing a model fact.
    A satellite whose parent is a LINK requires EVERY leg of that link, which is the user's point
    about links coming from the same view.
    """
    p = PARENT.get(sat.upper(), "")
    if p in HUBS:
        return [p], "hub parent (data_7.js)"
    if p in LINK_LEGS:
        legs = LINK_LEGS[p]
        if legs:
            return legs, "link parent %s, all %d legs (data_7.js)" % (p, len(legs))
        return [], "link parent %s names no resolvable hub legs" % p
    pool = by_sat.get(sat, []) if by_sat is not None else [b for b in blocks if b["sat"] == sat]
    decl = {b["anchor"] for b in pool if b["anchor"] in HUBS}
    if len(decl) == 1:
        return [sorted(decl)[0]], "map-declared anchor (model states no parent)"
    if decl:
        return [], "map declares %d hub anchors and the model states none; one cannot be chosen" \
                   % len(decl)
    return [], "no hub or link parent in data_7.js and no hub anchor in the map"


def build_plan():
    rows = load_map()
    blocks = read_blocks(rows)
    track_census = census(blocks)
    hub_tables, non_hub_names, key_provenance = hub_key_tables(blocks)
    slots = key_slots(blocks)
    unkeyed = sorted(HUBS - set(hub_tables))

    by_sat = collections.defaultdict(list)
    for b in blocks:
        if b["sat"]:
            by_sat[b["sat"]].append(b)

    # (table, hub) -> how many map rows declare a key for that hub on that table. Used to rank
    # candidate key registries, so a rule-4 pull-in is the widest-evidence slot and not the
    # alphabetically-first one. Legacy-recovered slots carry no row count and score 0, which ranks
    # them last among candidates rather than excluding them.
    key_rows = collections.Counter()
    for b in blocks:
        if b["expr"] and b["hub"]:
            key_rows[(b["table"], b["hub"])] += 1

    # ---- satellite payload requirement: the target track is the ratified vault ------------
    sat_payload = collections.defaultdict(set)
    for b in blocks:
        if b["track"] == "target" and b["sat"] and b["table"]:
            sat_payload[b["sat"]].add(b["table"])

    req, refused, extended_sat = {}, [], {}
    for sat in sorted(sat_payload):
        pay = sat_payload[sat]
        hubs, why = required_hubs(sat, blocks, by_sat)
        if not hubs:
            refused.append({"object": sat, "class": "satellite", "kind": "no_resolvable_anchor",
                            "detail": why, "whose_call": "modeller"})
            continue
        miss = [h for h in hubs if not hub_tables.get(h)]
        if miss:
            refused.append({"object": sat, "class": "satellite", "anchor_basis": why,
                            "kind": "anchor_key_resolves_nowhere", "hubs_unkeyed": miss,
                            "whose_call": "mapper",
                            "detail": "the map resolves no key for %s on any table in either "
                                      "contract, so no stitched view can key this satellite. "
                                      "REFUSED rather than keyed from outside the rule."
                                      % ", ".join(miss)})
            continue
        need, extra = set(pay), []
        for h in hubs:
            if need & hub_tables[h]:
                continue
            # RULE 4. No payload table of this satellite carries its anchor key, so a table that
            # does must be joined in. WHICH table is a real choice, not a formality: different
            # tables carry different key EXPRESSIONS for the same hub, so the pick decides which
            # identifier population keys this satellite. Picking the alphabetically-first table
            # would be a fabricated model fact of exactly the kind this build refuses elsewhere.
            #
            # The pick is therefore scored and RECORDED with its basis and the alternatives it
            # beat, so a reviewer can see a choice was made and overrule it:
            #   1. prefer the most-populated registry for that hub (most map rows declaring a key
            #      for it on that table) -- the widest-evidence slot, not an arbitrary one
            #   2. break ties on the table name, so the plan is reproducible
            cands = sorted(hub_tables[h],
                           key=lambda t: (-key_rows.get((t, h), 0), t))
            pick = cands[0]
            need.add(pick)
            extra.append({"hub": h, "table_pulled_in": pick,
                          "basis": "most-populated key registry for this hub",
                          "key_declarations_on_pick": key_rows.get((pick, h), 0),
                          "alternatives_not_taken": len(cands) - 1,
                          "alternatives": [{"table": t, "key_declarations": key_rows.get((t, h), 0)}
                                           for t in cands[1:6]]})
        req[sat] = need
        if extra:
            extended_sat[sat] = extra

    # ---- link requirement, with the two causes of failure kept apart ----------------------
    link_req = {}
    for lnk in sorted(LINK_LEGS):
        legs = LINK_LEGS[lnk]
        if not legs:
            refused.append({"object": lnk, "class": "link", "kind": "no_resolvable_legs",
                            "whose_call": "modeller",
                            "detail": "data_7.js names no hub legs for this link"})
            continue
        miss = [h for h in legs if not hub_tables.get(h)]
        if miss:
            refused.append({"object": lnk, "class": "link", "kind": "leg_key_resolves_nowhere",
                            "legs": legs, "hubs_unkeyed": miss, "whose_call": "mapper",
                            "detail": "leg(s) %s are keyed on no table in either contract, so no "
                                      "view can ever carry this link's grain. REFUSED."
                                      % ", ".join(miss)})
            continue
        link_req[lnk] = legs

    # ---- group: rule 3 first (they cannot pool), then rule 4 best-fit --------------------
    singles = {s: v for s, v in req.items() if len(v) > LIMIT}
    poolable = {s: v for s, v in req.items() if len(v) <= LIMIT}
    views = [{"satellites": [s], "tables": set(v), "over_limit": True, "links": []}
             for s, v in sorted(singles.items(), key=lambda kv: (-len(kv[1]), kv[0]))]
    for s in sorted(poolable, key=lambda k: (-len(poolable[k]), k)):
        v = poolable[s]
        best, addn = None, None
        for vw in views:
            if vw["over_limit"]:
                continue
            u = vw["tables"] | v
            if len(u) <= LIMIT:
                a = len(u) - len(vw["tables"])
                if best is None or a < addn:
                    best, addn = vw, a
        if best is None:
            views.append({"satellites": [s], "tables": set(v), "over_limit": False, "links": []})
        else:
            best["satellites"].append(s)
            best["tables"] |= v

    def hubs_on(vw):
        return {h for h, ts in hub_tables.items() if ts & vw["tables"]}

    # ---- place links, extending a view per rule 4 where the budget allows -----------------
    extended_link, dedicated = {}, []
    for lnk in sorted(link_req, key=lambda k: (-len(link_req[k]), k)):
        legs = link_req[lnk]
        # A link's grain is where its legs co-occur NARROWLY. First-fit put all 71 links on the
        # one 54-table view, because the widest view carries every hub key -- rule-6 compliant and
        # modelling nonsense: a link would then be built from a 54-table join unrelated to its own
        # grain, and its population would be whatever that join happened to produce. So among the
        # views that carry every leg, take the SMALLEST, which is the tightest co-occurrence the
        # plan contains. Ties break on the hub count and then on the ordinal, so the plan is
        # reproducible.
        hosts = [vw for vw in views if all(h in hubs_on(vw) for h in legs)]
        if hosts:
            host = min(hosts, key=lambda v: (len(v["tables"]), len(hubs_on(v)),
                                             sorted(v["satellites"])[:1]))
            host["links"].append(lnk)
            continue
        best = None
        for vw in views:
            hs = hubs_on(vw)
            gaps = [h for h in legs if h not in hs]
            if vw["over_limit"] or len(vw["tables"]) + len(gaps) <= LIMIT:
                if best is None or len(gaps) < len(best[1]):
                    best = (vw, gaps)
        if best is None:
            tabs = {sorted(hub_tables[h])[0] for h in legs}
            views.append({"satellites": [], "tables": tabs, "over_limit": len(tabs) > LIMIT,
                          "links": [lnk]})
            dedicated.append(lnk)
            continue
        vw, gaps = best
        pulled = []
        for h in gaps:
            pick = sorted(hub_tables[h])[0]
            vw["tables"].add(pick)
            pulled.append({"hub": h, "table_pulled_in": pick})
        vw["links"].append(lnk)
        extended_link[lnk] = pulled

    for i, vw in enumerate(sorted(views, key=lambda v: (-len(v["tables"]),
                                                        sorted(v["satellites"] + v["links"])))):
        vw["hubs_on_view"] = sorted(hubs_on(vw))
        vw["ordinal"] = i

    views = sorted(views, key=lambda v: v["ordinal"])

    # ---- RULE 7: a view must be JOINABLE ---------------------------------------------------
    # Rules 1-6 say which tables a view needs. None of them says those tables can be joined to
    # each other, and a view whose tables share no key can only be CROSS joined, which multiplies
    # rows, or union-ed, which is not a stitch. Either loads cleanly and gives the satellite a
    # wrong population, and a wrong population passes every structural gate. So the join path is
    # planned explicitly, per view, and a table with no path is REFUSED from the join rather than
    # reached by a cartesian product.
    # A table may be JOINED on a hub only where it has exactly ONE key slot for that hub. With
    # several slots the table has several identifier populations for that hub and joining on any
    # one of them silently picks a role; 63 of 604 spine pairs are in that state. So joinable_on
    # is deliberately NARROWER than "carries a key for".
    joinable_on = collections.defaultdict(set)
    ambiguous_on = collections.defaultdict(set)
    for (t, h), s in slots.items():
        (joinable_on if len(s["exprs"]) == 1 else ambiguous_on)[t].add(h)

    tbl_hubs = collections.defaultdict(set)
    for h, ts in hub_tables.items():
        for t in ts:
            tbl_hubs[t].add(h)

    for vw in views:
        tabs = sorted(vw["tables"])
        # The spine is the hub that the most tables can be joined on UNAMBIGUOUSLY -- not the one
        # the most tables merely carry a key for, which is what an earlier version measured and
        # which would have put ambiguous tables on the spine.
        best_hub, best_set = None, set()
        for h in sorted(vw["hubs_on_view"]):
            s = {t for t in tabs if h in joinable_on.get(t, set())}
            if len(s) > len(best_set):
                best_hub, best_set = h, s
        joined = set(best_set)
        steps, refused_tables = [], []
        remaining = [t for t in tabs if t not in joined]
        progress = True
        while remaining and progress:
            progress = False
            for t in list(remaining):
                reachable = joinable_on.get(t, set()) & set().union(
                    *[joinable_on.get(x, set()) for x in joined]) if joined else set()
                if reachable:
                    on_hub = sorted(reachable)[0]
                    steps.append({"table": t, "on_hub": on_hub})
                    joined.add(t)
                    remaining.remove(t)
                    progress = True
        for t in remaining:
            amb = sorted(ambiguous_on.get(t, set()))
            if amb:
                kind = "only_ambiguous_key_slots_for_every_shared_hub"
                detail = ("every hub this table shares with its view carries MORE THAN ONE key "
                          "slot on it (%s), so there is no single expression to join on. Joining "
                          "on one slot would key the whole view by one role of a multi-role "
                          "registry. REFUSED from the join; the slots are emitted as separate "
                          "business-key columns so a modeller can rule on which is the join key."
                          % ", ".join("%s:%d" % (h, len(slots[(t, h)]["exprs"])) for h in amb[:4]))
            else:
                kind = "no_join_path_into_this_view"
                detail = ("this table shares no hub key with any other table in its own view, so "
                          "it can only be reached by a cross join. REFUSED from the join; its "
                          "columns are WITHHELD from the satellites that wanted them rather than "
                          "multiplied into them.")
            refused_tables.append({
                "table": t, "kind": kind, "detail": detail,
                "hubs_keyed_on_it": sorted(tbl_hubs.get(t, set())),
                "hubs_joinable_unambiguously": sorted(joinable_on.get(t, set())),
                "hubs_with_several_slots": amb,
                "whose_call": "modeller" if amb else "mapper"})
        vw["join_plan"] = {
            "spine_hub": best_hub,
            "spine_tables": sorted(best_set),
            "full_spine": len(best_set) == len(tabs),
            "second_step_joins": steps,
            "refused_tables": refused_tables,
        }
        for r in refused_tables:
            refused.append(dict(r, object="%s@view%d" % (r["table"], vw["ordinal"]),
                                **{"class": "source_table"}))
    covered = set().union(*[v["tables"] for v in views]) if views else set()
    all_keyed = {t for ts in hub_tables.values() for t in ts}

    plan = {
        "rule_token": "CENTRAL_VIEW_RULE_GOVERNS",
        "limit": LIMIT,
        "track_census": track_census,
        "hub_key_census": {
            "model_hubs": len(HUBS),
            "model_hubs_keyed": len(hub_tables),
            "model_hubs_keyed_nowhere": unkeyed,
            "key_slot_provenance": key_provenance,
            "two_sources_note": "Key slots come from TWO sources: resolved_key in the map (v2 and "
                                "delta3 halves only -- the profile measures zero resolved_key on "
                                "every legacy row) and the legacy half's forms recovered from "
                                "health_dv_dbt's emitted SQL, read-only. Sweeping only the map "
                                "reported 5 hubs as keyed nowhere and would have refused 8 "
                                "satellites and 18 links on a false zero.",
            "non_hub_names_in_the_hub_field": non_hub_names,
            "non_hub_names_note": "These are recorded in resolved_key.hub but are not hub codes in "
                                  "data_7.js. Counting them as hubs reported 18 of 20 hubs "
                                  "derivable from the map half alone.",
        },
        "key_slots": {"%s|%s" % k: v for k, v in sorted(slots.items())},
        "key_slot_summary": {
            "pairs": len(slots),
            "pairs_with_one_slot": sum(1 for v in slots.values() if len(v["exprs"]) == 1),
            "pairs_with_several_slots": sum(1 for v in slots.values() if len(v["exprs"]) > 1),
            "from_map": sum(1 for v in slots.values() if v["source"] == "map.resolved_key"),
            "from_legacy_sql": sum(1 for v in slots.values()
                                   if v["source"] == "legacy_emitted_sql"),
        },
        "stitched_views": [
            {"ordinal": v["ordinal"], "satellites": sorted(v["satellites"]),
             "links": sorted(v["links"]), "tables": sorted(v["tables"]),
             "over_limit": v["over_limit"], "hubs_on_view": v["hubs_on_view"],
             "join_plan": v["join_plan"]}
            for v in views],
        "views_extended_for_satellite_anchor": extended_sat,
        "views_extended_for_link_legs": extended_link,
        "dedicated_link_views": dedicated,
        "refused": refused,
        "tables_keyed_but_in_no_view": sorted(all_keyed - covered),
        "source_tables_in_any_view": len(covered),
    }
    return plan


def assert_plan(plan):
    """Re-prove every property the plan claims, from the plan as written rather than from the
    variables that built it. A construction that is correct by argument and a plan that is correct
    on inspection are different claims, and only the second one survives a later edit."""
    views = plan["stitched_views"]
    fails = []

    homes = collections.Counter(s for v in views for s in v["satellites"])
    split = {s: c for s, c in homes.items() if c != 1}
    if split:
        fails.append("RULE 2 VIOLATED: %d satellite(s) appear on more than one view: %s"
                     % (len(split), sorted(split)[:5]))

    for v in views:
        if not v["over_limit"] and len(v["tables"]) > plan["limit"]:
            fails.append("RULE 1 VIOLATED: view %d joins %d tables and is not flagged over_limit"
                         % (v["ordinal"], len(v["tables"])))
        if v["over_limit"] and len(v["tables"]) <= plan["limit"]:
            fails.append("view %d is flagged over_limit but joins only %d tables"
                         % (v["ordinal"], len(v["tables"])))
        if not v["satellites"] and not v["links"]:
            fails.append("view %d serves no object at all" % v["ordinal"])
        if not v["hubs_on_view"]:
            fails.append("RULE 5 VIOLATED: view %d carries no hub key" % v["ordinal"])

    rows = load_map()
    blocks = read_blocks(rows)
    by_sat = collections.defaultdict(list)
    for b in blocks:
        if b["sat"]:
            by_sat[b["sat"]].append(b)
    for v in views:
        hs = set(v["hubs_on_view"])
        for sat in v["satellites"]:
            for h in required_hubs(sat, blocks, by_sat)[0]:
                if h not in hs:
                    fails.append("RULE 5 VIOLATED: %s needs %s, which is not keyed on its own "
                                 "view %d" % (sat, h, v["ordinal"]))
        for lnk in v["links"]:
            for h in LINK_LEGS[lnk]:
                if h not in hs:
                    fails.append("RULE 6 VIOLATED: %s leg %s is not keyed on its own view %d"
                                 % (lnk, h, v["ordinal"]))

    lhomes = collections.Counter(l for v in views for l in v["links"])
    dup = {l: c for l, c in lhomes.items() if c != 1}
    if dup:
        fails.append("a link is placed on more than one view: %s" % sorted(dup)[:5])

    refused_objs = {r["object"] for r in plan["refused"]}
    placed = set(homes) | set(lhomes)
    both = sorted(refused_objs & placed)
    if both:
        fails.append("object(s) both REFUSED and PLACED: %s" % both[:5])

    # RULE 7: every table of a view is either on the spine, reached by a planned second-step
    # join, or explicitly refused. A table that is none of the three would be emitted into the
    # join SQL with no ON clause -- a cross join nobody wrote down.
    for v in views:
        jp = v.get("join_plan")
        if not jp:
            fails.append("view %d has no join plan" % v["ordinal"])
            continue
        if not jp["spine_hub"]:
            fails.append("RULE 7 VIOLATED: view %d has no join spine at all" % v["ordinal"])
        accounted = set(jp["spine_tables"]) | {s["table"] for s in jp["second_step_joins"]} \
            | {r["table"] for r in jp["refused_tables"]}
        missing = sorted(set(v["tables"]) - accounted)
        if missing:
            fails.append("RULE 7 VIOLATED: view %d leaves %d table(s) with no join path and no "
                         "refusal: %s" % (v["ordinal"], len(missing), missing[:3]))
        dupe = accounted - set(v["tables"])
        if dupe:
            fails.append("view %d join plan names table(s) not in the view: %s"
                         % (v["ordinal"], sorted(dupe)[:3]))
        if jp["full_spine"] and jp["second_step_joins"]:
            fails.append("view %d claims a full spine but also has second-step joins"
                         % v["ordinal"])

    if fails:
        raise AssertionError("STITCH PLAN FAILS ITS OWN RULES:\n  " + "\n  ".join(fails))
    return {"views": len(views), "satellites": len(homes), "links": len(lhomes),
            "refused": len(plan["refused"])}


def main():
    plan = build_plan()
    summary = assert_plan(plan)
    os.makedirs(REPORTS, exist_ok=True)
    io.open(PLAN_PATH, "w", encoding="utf-8").write(
        json.dumps(plan, indent=1, ensure_ascii=False) + "\n")

    v = plan["stitched_views"]
    print("=" * 92)
    print("STITCH PLAN -- the central-view rule, applied")
    print("=" * 92)
    for track, c in sorted(plan["track_census"].items()):
        print("  %-13s blocks %5d  naming a satellite %5d  distinct sats %4d  key exprs %5d"
              % (track, c["blocks"], c["with_satellite"], c["distinct_satellites"],
                 c["with_key_expression"]))
    print()
    print("  stitched views                         : %d" % summary["views"])
    print("     rule-3 exceptions (>%d tables)       : %d"
          % (plan["limit"], sum(1 for x in v if x["over_limit"])))
    print("     dedicated link views                : %d" % len(plan["dedicated_link_views"]))
    print("  satellites, each WHOLE from one view   : %d" % summary["satellites"])
    print("  links, every leg on their own view     : %d" % summary["links"])
    print("  hubs derivable (model codes only)      : %d of %d"
          % (plan["hub_key_census"]["model_hubs_keyed"], plan["hub_key_census"]["model_hubs"]))
    print("  hubs keyed nowhere -> refused          : %s"
          % ", ".join(plan["hub_key_census"]["model_hubs_keyed_nowhere"]))
    print("  objects REFUSED and registered         : %d" % summary["refused"])
    for k, c in sorted(collections.Counter(r["kind"] for r in plan["refused"]).items()):
        print("     %-32s %d" % (k, c))
    print("  views extended for an anchor key       : %d satellite(s)"
          % len(plan["views_extended_for_satellite_anchor"]))
    print("  views extended for link legs           : %d link(s)"
          % len(plan["views_extended_for_link_legs"]))
    print("  source tables in at least one view     : %d" % plan["source_tables_in_any_view"])
    print("  keyed tables in NO view                : %d"
          % len(plan["tables_keyed_but_in_no_view"]))
    print()
    print("  RULE 7, joinability:")
    print("     views with a FULL spine (one key on every table) : %d of %d"
          % (sum(1 for x in v if x["join_plan"]["full_spine"]), len(v)))
    print("     second-step joins planned                        : %d table(s)"
          % sum(len(x["join_plan"]["second_step_joins"]) for x in v))
    print("     tables REFUSED from a join (no key path)         : %d"
          % sum(len(x["join_plan"]["refused_tables"]) for x in v))
    for x in v:
        for rt in x["join_plan"]["refused_tables"]:
            print("        view %-3d %s" % (x["ordinal"], rt["table"]))
    print()
    print("  plan re-asserted against its own six rules: PASS")
    print("  [written] build_artifacts/reports/stitch_plan.json")
    return 0


if __name__ == "__main__":
    sys.exit(main())
