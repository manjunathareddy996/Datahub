# -*- coding: utf-8 -*-
"""THE MAP -> ONE SPEC ARTIFACT. Every downstream generator reads the spec, never the map.

Why: a generator that re-reads the map re-implements the reader, and the second reader is the one
that is wrong. There is exactly one place in this build where the settled column map is interpreted,
and this is it. Everything after this file consumes build_artifacts/hcon_spec.json.

RUN ORDER: this is step 2, after hcon_keyrules selftest and before every gen_*.
"""
import collections
import hashlib
import json
import os
import re
import sys

import hcon_keyrules as K
import hcon_names as N
from hcon_writeguard import PROJECT_ROOT, guarded_open, assert_read_only_intact

ARTIFACTS = os.path.join(PROJECT_ROOT, "build_artifacts")
REPORTS = os.path.join(ARTIFACTS, "reports")
SPEC_PATH = os.path.join(ARTIFACTS, "hcon_spec.json")

# THREE runs now. The third comes from a SEPARATE map that carries no source_run of its
# own; K.load_map() stamps the label on read. Everything downstream that branches on run
# -- precedence, cross-run collision, per-run feeds -- then works unchanged.
RUNS = ("opus_health_legacy_v4", "opus_health_v2", "opus_health_delta3")
SOURCE_NAME_FOR_RUN = {"opus_health_delta3": "opus_health_delta3",
                       "opus_health_legacy_v4": "opus_health_legacy_v4",
                       "opus_health_v2": "opus_health_v2"}

# ------------------------------------------------------------------ input integrity
def verify_inputs():
    """Digest the build input BEFORE and AFTER. The PINNED file is never opened for building."""
    prof = K.PROFILE
    path = K.MAP_PATH
    want = prof["inputs_pinned"]["files"]["04_column_map.SETTLED_post_stage6_65b.json"]
    with open(path, "rb") as fh:
        blob = fh.read()
    got = hashlib.sha256(blob).hexdigest()
    md5 = hashlib.md5(blob).hexdigest()
    if got != want:
        raise AssertionError("BUILD INPUT MOVED: %s sha256 %s != pinned %s" % (path, got, want))
    if prof["inputs_pinned"]["build_input_token"] != \
            "04_column_map.SETTLED_post_stage6_65b.json":
        raise AssertionError("profile's declared build input is not the settled map")
    out = {"path": os.path.basename(path), "bytes": len(blob), "sha256": got, "md5": md5}
    # THE SECOND CONTRACT, pinned and verified the same way. Two maps, two digests, neither
    # merged on disk.
    d3 = K.DELTA3_MAP_PATH
    if os.path.exists(d3):
        with open(d3, "rb") as fh:
            b3 = fh.read()
        got3 = hashlib.md5(b3).hexdigest()
        want3 = prof["inputs_pinned"]["files"].get("04_column_map.DELTA3.json")
        if want3 and got3 not in want3:
            raise AssertionError("DELTA3 BUILD INPUT MOVED: md5 %s != pinned %s"
                                 % (got3, want3))
        out["delta3"] = {"path": os.path.basename(d3), "bytes": len(b3), "md5": got3,
                         "sha256": hashlib.sha256(b3).hexdigest(),
                         "run_label_assigned_on_read": K.DELTA3_RUN}
    return out


# ------------------------------------------------------------------ small readers
def homes(container):
    """Satellite homes declared on one container, in precedence order, PROSE STRIPPED.

    augmentation.new_satellite carries a code followed by a description on 131 rows. The code is
    extracted and the prose is DISCARDED -- never rendered, never used as a name.
    """
    out = []
    for sp in ("satellite", "best_home_satellite", "new_satellite"):
        v = container.get(sp)
        if isinstance(v, str) and v.strip():
            code, had_prose = N.vault_code(v)
            out.append({"spelling": sp, "code": code, "raw_had_prose": had_prose, "raw": v})
    return out


def primary_home(container):
    for h in homes(container):
        if h["code"]:
            return h
    return None


def attribute_of(container):
    for sp in ("attribute", "proposed_attribute"):
        v = container.get(sp)
        if isinstance(v, str) and v.strip():
            return v.strip(), sp
    return None, None


def instance_of(container):
    """BLOCK-LEVEL instance only.

    instance occurs at FOUR paths with ONE shared vocabulary and TWO ROLES: 170 distinct values at
    block level, 20 inside resolved_key, overlap 20, resolved_key-only ZERO. The resolved_key one
    QUALIFIES A KEY EXPRESSION and must never be attached to a row as its own label. Scoped by
    ROLE, not by name.

    And the value is READ, never inferred from a column prefix: P_ and M_ on
    BJAZ_BANDHAN_MEDI_CLAM mean PERMANENT and MAILING, not proposer/member, and the prefix reads
    naturally as the wrong one.
    """
    st = K.state_of(container, "instance")
    if st != "POPULATED":
        return None, st
    return str(container["instance"]).strip(), st


# ------------------------------------------------------------------ the spec
def build():
    print("[spec] verifying inputs")
    inp = verify_inputs()
    print("       %s %d bytes sha256 %s..." % (inp["path"], inp["bytes"], inp["sha256"][:16]))
    K.assert_profile_recognised()
    rows = K.load_map()
    K.assert_map_fields(rows)
    ck = K.assert_child_key_cooccurrence(rows)
    md = K.assert_matcher_discipline(rows)
    claims = K.assert_profile_claims(rows)

    # ---------------- grammar census, and the zero that licenses two omitted layers
    exprs, expr_rows = [], []
    for r in rows:
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if not isinstance(o, dict):
                continue
            rk = o.get("resolved_key")
            if isinstance(rk, dict) and rk.get("expression"):
                exprs.append(rk["expression"])
                expr_rows.append((r, cont, rk))
    grammar = collections.Counter(K.classify_expression(e) for e in exprs)
    sweepable = exprs + [str(v) for r in rows for cont in ("target", "augmentation")
                         for o in [r.get(cont)] if isinstance(o, dict)
                         for f in ("child_key", "child_key_value", "usage_child_key")
                         for v in [o.get(f)] if isinstance(v, str)]
    walk = K.assert_no_walk_operators(sweepable, "every key-bearing string in the map")
    if len(exprs) != K.PROFILE["grammar_population"]:
        raise AssertionError("grammar population drift: %d vs profile %d"
                             % (len(exprs), K.PROFILE["grammar_population"]))

    # ---------------- views
    view_rows = collections.defaultdict(list)
    for r in rows:
        view_rows[(r["source_run"], r["table_name"])].append(r)
    N.assert_view_names_injective([t for _run, t in view_rows])

    # ---------------- key slots
    slots = []            # one per (view, vault_table, business-key expression)
    seen_slot = {}

    def add_slot(view, run, vault_table, kind, expression, form_info, tier, source_columns,
                 instance, reject, degenerate, origin, legs=None, reject_declarations=None):
        if not source_columns:
            raise AssertionError("key slot on %s for %s has NO source columns" % (view, vault_table))
        bk = N.bk_column(vault_table, source_columns)
        key = (view, vault_table, bk)
        if key in seen_slot:
            s = seen_slot[key]
            if s["expression"] != expression:
                # SAME staged BK column name, DIFFERENT expression. Never merged: merging would
                # assert the two expressions denote one identifier population, which is the
                # undetermined registry question this build must not answer.
                K.refuse("key_slot_name_collision_differing_expression", view=view,
                         satellite=vault_table,
                         detail="two expressions render the same BK column %s: %r vs %r"
                                % (bk, s["expression"], expression))
            return s
        s = {"id": "%s|%s|%s" % (view, vault_table, bk), "view": view, "run": run,
             "vault_table": vault_table, "kind": kind, "bk_column": bk,
             "expression": expression, "form": form_info.get("form"),
             "semantics": form_info.get("semantics"), "tier": tier,
             "source_columns": list(source_columns), "instance": instance,
             "reject_class": reject, "degenerate_value": degenerate, "origin": origin,
             "legs": legs, "uses_normalise": form_info.get("uses_normalise", False),
             "reject_declarations": reject_declarations or []}
        seen_slot[key] = s
        slots.append(s)
        return s

    # ---- v2 slots: straight from resolved_key
    for r, cont, rk in expr_rows:
        hub = rk.get("hub")
        if not isinstance(hub, str) or not hub.strip():
            K.refuse("resolved_key_without_hub", view=r["table_name"],
                     detail="resolved_key carries an expression but no hub")
            continue
        hub = hub.strip()
        info = K.parse_expression(rk["expression"])
        srccols = rk.get("source_columns") or []
        if isinstance(srccols, str):
            srccols = [srccols]
        srccols = [c for c in srccols if isinstance(c, str) and N.RX_BARE_IDENT.match(c)]
        if not srccols:
            K.refuse("resolved_key_without_source_columns", view=r["table_name"], satellite=hub,
                     detail="source_columns is %r; a key slot cannot be named without them"
                            % (rk.get("source_columns"),))
            continue
        rejects = rk.get("key_reject_declaration") or []
        rclass, rdecls = None, []
        if isinstance(rejects, list):
            for d in rejects:
                # sweep EVERY declaration: four classes, seven sub-keys, free-form slot paths.
                K.assert_reject_declaration(d, "%s:%s" % (r["table_name"], hub))
                rdecls.append({"slot": d["slot"], "class": d["class"],
                               "operands": d["operands"],
                               "reject_rule": d.get("reject_rule"),
                               "degenerate_value": d.get("degenerate_value"),
                               "reclassified_from": d.get("reclassified_from")})
            classes = sorted({d["class"] for d in rdecls})
            rclass = classes[0] if classes else None
        kind = "link" if info["semantics"] == "link" else (
            "ref" if hub.startswith("REF_") else "hub")
        rkinst, _st = instance_of(rk)          # qualifies the KEY, not the row
        add_slot(r["table_name"], r["source_run"], hub, kind, rk["expression"], info,
                 rk.get("tier"), srccols, rkinst, rclass, rk.get("degenerate_value"),
                 "map.resolved_key", info.get("legs"), reject_declarations=rdecls)

    # ---- legacy slots: recovered from health_dv_dbt's EMITTED SQL (BD2)
    legacy_keys, legacy_stats = K.legacy_key_forms()
    legacy_views = {t for run, t in view_rows if run == "opus_health_legacy_v4"}
    legacy_anchors = collections.defaultdict(set)
    for r in rows:
        if r["source_run"] != "opus_health_legacy_v4":
            continue
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if isinstance(o, dict) and isinstance(o.get("anchor"), str) and o["anchor"].strip():
                legacy_anchors[r["table_name"]].add(o["anchor"].strip())
    legacy_slot_hits = legacy_slot_misses = 0
    for view in sorted(legacy_views):
        stem = view.lower()
        for anchor in sorted(legacy_anchors.get(view, ())):
            got = legacy_keys.get((stem, anchor))
            if not got:
                legacy_slot_misses += 1
                K.refuse("legacy_key_not_recoverable", view=view, satellite=anchor,
                         detail="the legacy half of the map carries no resolved_key and "
                                "health_dv_dbt's emitted SQL declares no namespaced NK for "
                                "(%s, %s). Reported, not guessed (s5.6)." % (view, anchor))
                continue
            for col in got:
                colu = col.upper()
                if not N.RX_BARE_IDENT.match(colu):
                    K.refuse("legacy_key_expression_not_an_identifier", view=view,
                             satellite=anchor, detail="recovered %r" % col)
                    continue
                expr = "nullif(trim(%s),'')" % colu
                info = K.parse_expression(expr)
                kind = "link" if anchor.startswith("LNK_") else (
                    "ref" if anchor.startswith("REF_") else "hub")
                add_slot(view, "opus_health_legacy_v4", anchor, kind, expr, info,
                         "tier1_business_code", [colu], None, "single_operand_guarded", None,
                         "legacy_emitted_sql", None)
                legacy_slot_hits += 1

    slots_by_view = collections.defaultdict(list)
    for s in slots:
        slots_by_view[s["view"]].append(s)

    # ---------------- satellites, keyed by (code, TRACK)
    # The TRACK is a property of the BLOCK, not of the satellite. A `target.satellite` block whose
    # attribute is declared in data_7.js is RATIFIED; an `augmentation` block, or any block whose
    # attribute the model does not declare, is a PROPOSAL and goes to the unratified track. One
    # satellite may legitimately have both, and conflating them either refuses real proposals or
    # smuggles unratified attributes into a standard satellite.
    sat = {}

    def ensure_sat(code, track, anchor, run):
        key = (code, track)
        if key not in sat:
            in_model = code in K.MODEL_SATS or code in K.MODEL_REFS
            sat[key] = {"code": code, "track": track, "anchors": collections.Counter(),
                        "in_model": in_model, "hist": K.model_hist(code),
                        "model_childkey": K.model_childkey(code),
                        "model_attrs": K.model_attrs(code),
                        "payload": collections.OrderedDict(), "feeders": {},
                        "runs": set(), "refusals": [], "ck_markers": set(),
                        "declared_legs": N.split_legs(K.model_childkey(code))}
        if anchor:
            sat[key]["anchors"][anchor] += 1
        sat[key]["runs"].add(run)
        return sat[key]

    prose_home_stripped = 0
    prose_home_unusable = 0
    proposals_routed = 0
    unrenderable = 0

    for r in rows:
        run = r["source_run"]
        view = r["table_name"]
        col = r["column_name"]
        for cont in ("target", "augmentation"):
            o = r.get(cont)
            if not isinstance(o, dict):
                continue
            h = primary_home(o)
            if h is None:
                for cand in homes(o):
                    if cand["code"] is None:
                        prose_home_unusable += 1
                        K.refuse("satellite_home_is_pure_prose", view=view,
                                 detail="%s.%s = %r carries no SAT_/REF_ code at all; refusing "
                                        "to coin a satellite name from a description"
                                        % (cont, cand["spelling"], cand["raw"]))
                continue
            if h["raw_had_prose"]:
                prose_home_stripped += 1
            code = h["code"]
            anchor = o.get("anchor") if isinstance(o.get("anchor"), str) else None
            if o.get("kind") in ("hub_key", "link_key"):
                continue                      # a key column, not a payload attribute
            attr, attr_sp = attribute_of(o)
            if not attr:
                continue
            model_attrs = K.model_attrs(code)
            in_model_attr = attr in model_attrs
            if code.startswith("REF_"):
                track = "reference" if in_model_attr else "unratified"
            elif cont == "target" and h["spelling"] == "satellite" and in_model_attr:
                track = "ratified"
            else:
                track = "unratified"
            if track == "unratified":
                proposals_routed += 1
            # The one refusal that stays: the attribute cannot be RENDERED as a column at all.
            # N.column() is the s3.3 gate -- it refuses parentheses, brackets and em-dashes, the
            # shapes that mean a DESCRIPTION arrived where an attribute name was expected. A
            # multi-word name is not prose; snake_case is what multi-word names are for.
            try:
                column = N.column(attr)
            except AssertionError as exc:
                unrenderable += 1
                K.refuse("attribute_unrenderable_prose_in_identifier_position",
                         satellite=code, view=view,
                         detail="%s.%s = %r cannot be rendered as a column: %s"
                                % (cont, attr_sp, attr, exc))
                continue
            S = ensure_sat(code, track, (anchor or "").strip() or None, run)
            S["ck_markers"] |= K.read_ck_markers(o)
            inst, inst_state = instance_of(o)
            ckr = K.read_child_key(o, code)
            p = S["payload"].setdefault(attr, {"attribute": attr, "column": column,
                                               "writers": [], "in_model": in_model_attr})
            # The TWO legitimate writer discriminators. A fan-in is arbitrary only among
            # writers that NOTHING separates, so both are read -- instance as a value, and
            # redundant_of as a PRESENCE FLAG only (its value is a pointer and is never rendered).
            redundant = K.populated(o, "redundant_of")
            p["writers"].append({"run": run, "view": view, "source_column": col,
                                 "instance": inst, "instance_state": inst_state,
                                 "redundant_of_declared": redundant,
                                 "discriminated": bool(inst) or redundant,
                                 "attribute_spelling": attr_sp, "container": cont,
                                 "outcome": r["outcome"]})
            fkey = (view, run)
            F = S["feeders"].setdefault(fkey, {"view": view, "run": run, "columns": [],
                                               "child_key": None, "instances": set()})
            F["columns"].append({"attribute": attr, "column": column, "source_column": col,
                                 "instance": inst})
            if inst:
                F["instances"].add(inst)
            if ckr["subpopulation"] != "nothing_at_all" or ckr["declared_legs"]:
                F["child_key"] = ckr

    # ---------------- child-key resolution, refusal, and the three sub-populations
    subpop = collections.Counter()
    for (code, track), S in sat.items():
        legs = S["declared_legs"]
        resolved_any = False
        for fkey, F in S["feeders"].items():
            ckr = F.get("child_key")
            if not ckr:
                continue
            subpop["%s|%s" % (F["run"], ckr["subpopulation"])] += 1
            if ckr["components"]:
                resolved_any = True
            elif legs and K.REFUSE_UNRESOLVED_LEGS:
                S["refusals"].append({
                    "view": F["view"], "run": F["run"],
                    "subpopulation": ckr["subpopulation"],
                    "declared_legs": legs,
                    "named_legs": ckr["named_legs"],
                    "states": ckr["states"],
                    "detail": _refusal_sentence(code, legs, ckr)})
                K.refuse("child_key_leg_refused", satellite=code, view=F["view"],
                         leg=" + ".join(legs), states=ckr["states"],
                         detail=_refusal_sentence(code, legs, ckr))
        S["child_key_resolved"] = resolved_any
        # No payload attribute may share a name with a child-key leg (s5.4). The legs to compare
        # against are BOTH the model-declared ones AND every leg a component actually resolves --
        # on the unratified track there is no model declaration and the components are the only
        # legs there are.
        legnames = set(legs)
        for F in S["feeders"].values():
            ckr = F.get("child_key")
            if ckr:
                legnames |= {c["leg"] for c in ckr["components"]}
        legcols = set()
        for l in sorted(legnames):
            try:
                legcols.add(N.column(l))
            except AssertionError:
                K.refuse("child_key_leg_name_unrenderable", satellite=code, leg=l,
                         detail="leg name %r cannot be rendered as a column" % l)
        for attr, p in list(S["payload"].items()):
            if p["column"] in legcols:
                K.refuse("payload_collides_with_child_key_leg", satellite=code,
                         leg=p["column"],
                         detail="payload attribute %r renders %s, which is also a child-key leg "
                                "column on %s (%s track); the PAYLOAD column is DROPPED rather "
                                "than aliasing one name twice in a select, which would lose the "
                                "leg -- and the leg is the thing that carries grain (s5.4)"
                                % (attr, p["column"], code, track))
                del S["payload"][attr]

    # ---------------- R8 declared source precedence
    r8 = []
    for (code, track), S in sat.items():
        for attr, p in S["payload"].items():
            runs = {w["run"] for w in p["writers"]}
            if len(runs) < 2:
                continue
            order = K.r8_precedence_for(attr, code, runs)
            # COUNT the runs; do not name two of them. The earlier form summed
            # legacy_writers + v2_writers, so a third run's writers counted as ZERO and r8_cols
            # silently undercounted the moment a run was added.
            per_run = collections.Counter(w["run"] for w in p["writers"])
            r8.append({"satellite": code, "track": track, "attribute": attr,
                       "column": p["column"], "precedence": order,
                       "writers_by_run": dict(per_run),
                       # kept for readers of the published artefact shape, derived from the same
                       # dict rather than recounted
                       "legacy_writers": per_run.get("opus_health_legacy_v4", 0),
                       "v2_writers": per_run.get("opus_health_v2", 0),
                       "delta3_writers": per_run.get("opus_health_delta3", 0)})
            p["precedence"] = order
    r8_cols = sum(sum(x["writers_by_run"].values()) for x in r8)

    # ---------------- unpivot families (column-as-instance ONLY)
    unpivot = []
    for (code, track), S in sat.items():
        if "column_as_instance" not in S["ck_markers"]:
            continue
        for fkey, F in S["feeders"].items():
            byinst = collections.defaultdict(list)
            for c in F["columns"]:
                if c["instance"]:
                    byinst[c["instance"]].append(c)
            if len(byinst) < 2:
                continue
            unpivot.append({"satellite": code, "track": track, "view": F["view"],
                            "run": F["run"],
                            "instances": sorted(byinst),
                            "branches": {k: v for k, v in sorted(byinst.items())},
                            "marker": "column_as_instance"})

    # ---------------- loaders: 62 shared / 140 legacy-only / 45 v2-only
    with open(os.path.join(REPORTS, "vault_table_sets.json"), encoding="utf-8") as fh:
        vts = json.load(fh)
    SETS = {"shared": list(vts["shared_62"]), "legacy_only": list(vts["legacy_only_140"]),
            "v2_only": list(vts["v2_only_45"])}
    allnames = [n for s in SETS.values() for n in s]
    if len(allnames) != len(set(allnames)):
        dup = [k for k, v in collections.Counter(allnames).items() if v > 1]
        raise AssertionError("THE 62/140/45 PARTITION IS NOT EXACT: %s in two sets" % dup)
    for a, b in (("shared", "legacy_only"), ("shared", "v2_only"), ("legacy_only", "v2_only")):
        inter = set(SETS[a]) & set(SETS[b])
        if inter:
            raise AssertionError("partition overlap %s/%s: %s" % (a, b, sorted(inter)))
    declared_counts = {"shared": K.PROFILE["layer_plan_one_loader"]["shared_tables"],
                       "legacy_only": K.PROFILE["layer_plan_one_loader"]["legacy_only_tables"],
                       "v2_only": K.PROFILE["layer_plan_one_loader"]["v2_only_tables"]}
    for k, want in declared_counts.items():
        if len(SETS[k]) != want:
            raise AssertionError("loader set %s has %d names, profile declares %d"
                                 % (k, len(SETS[k]), want))

    setof = {}
    for k, names in SETS.items():
        for n in names:
            setof[n] = k

    loaders = []
    for name in sorted(allnames):
        code = name.upper()
        kind = ("hub" if name.startswith("hub_") else
                "link" if name.startswith("lnk_") else
                "ref" if name.startswith("ref_") else "satellite")
        # a per-source FEED model, not an assembled table: lnk_x__view__hash
        feed_of = None
        m = re.match(r"^((?:lnk|hub|sat)_[a-z0-9_]+?)__([a-z0-9_]+)__([0-9a-f]{6,})$", name)
        if m and m.group(1) in setof:
            feed_of = m.group(1)
        key_feeds = [s for s in slots if s["vault_table"] == code] if kind in ("hub", "link",
                                                                              "ref") else []
        satrecs = [S for (c, _tr), S in sat.items() if c == code]
        sat_feeds = sorted({f for S in satrecs for f in S["feeders"]})
        runs_present = sorted({s["run"] for s in key_feeds} | {f[1] for f in sat_feeds})
        buildable = bool(key_feeds or any(S["payload"] for S in satrecs))
        loaders.append({"name": name, "code": code, "kind": kind, "set": setof[name],
                        "is_per_source_feed_of": feed_of,
                        "runs_with_feeds": runs_present,
                        "key_feed_slots": [s["id"] for s in key_feeds],
                        "satellite_feeders": ["%s|%s" % (v, r) for v, r in sat_feeds],
                        "buildable": buildable})
        if not buildable:
            K.refuse("loader_has_no_feed_in_the_map", satellite=code,
                     detail="vault table %r is emitted by a sibling but the settled map supplies "
                            "no column for it, so there is nothing to select. A loader is built "
                            "because it has a FEED, not because it is in a file list (s6.1). "
                            "Declared, not emitted as an empty model." % name,
                     extra={"loader_set": setof[name], "loader_kind": kind})

    # dual-feed assertion, both directions
    feed_consumed = collections.Counter()
    for L in loaders:
        if L["is_per_source_feed_of"]:
            feed_consumed[L["is_per_source_feed_of"]] += 1
    orphan_feeds = [L["name"] for L in loaders
                    if L["is_per_source_feed_of"] and
                    L["is_per_source_feed_of"] not in {x["name"] for x in loaders}]
    if orphan_feeds:
        raise AssertionError("per-source feed with no assembled loader: %s" % orphan_feeds)

    shared_dual = [L["name"] for L in loaders
                   if L["set"] == "shared" and len(L["runs_with_feeds"]) == 2]
    shared_single = [L["name"] for L in loaders
                     if L["set"] == "shared" and len(L["runs_with_feeds"]) == 1]
    for name in shared_single:
        K.refuse("shared_loader_has_one_run_of_feeds", satellite=name.upper(),
                 detail="both originals emit a file called %s.sql, so it is SHARED BY NAME, but "
                        "the settled map supplies columns from only one run. Built as a "
                        "single-feed loader. 'Shared' here is a property of the two FILE SETS, "
                        "not of the map." % name)

    spec = {
        "meta": {
            "intra_run_fanin_census": _fanin_census(sat),
            "lob": K.PROFILE["lob"],
            "generated_by": "build_hcon_spec.py",
            "profile_schema_version": K.PROFILE["schema_version"],
            "input": inp,
            "model_file": K.PROFILE["model_file"],
            "model_file_md5": K.PROFILE["model_file_md5"],
            "map_rows": len(rows),
            "runs": list(RUNS),
            "source_name_for_run": SOURCE_NAME_FOR_RUN,
            "grammar": dict(grammar),
            "grammar_population": len(exprs),
            "walk_operator_counts": walk,
            "walk_zero_note": "PROVEN, not omitted: the hop-view and resolver layers are empty "
                              "because every walk operator counts zero over every key-bearing "
                              "string in the map. Both layers still emit a model-count of 0 and "
                              "say why.",
            "child_key_cooccurrence": {"+".join(k) or "(none)": v
                                       for k, v in ck["cooccurrence"].items()},
            "child_key_vocabulary_values": ck["child_key_vocabulary_values"],
            "matcher_discipline": md,
            "profile_claims": claims,
            "legacy_archaeology": legacy_stats,
            "legacy_slots_recovered": legacy_slot_hits,
            "legacy_slots_unrecoverable": legacy_slot_misses,
            "prose_home_stripped": prose_home_stripped,
            "prose_home_unusable": prose_home_unusable,
            "proposals_routed_to_unratified_track": proposals_routed,
            "attributes_unrenderable_refused": unrenderable,
            "child_key_subpopulations": dict(subpop),
            "r8_pairs": len(r8),
            "r8_columns": r8_cols,
            "r8_precedence_order": list(K.R8_PRECEDENCE),
            "r8_fires_on_note": "The number to report is how many (satellite, attribute) PAIRS "
                                "the precedence actually fires on, measured here. "
                                "'R8 fires on 62 of 62' is TRUE BY CONSTRUCTION of an input set "
                                "DEFINED as the pairs having writers in two or more runs, and is "
                                "never reported as a measurement. THREE runs now feed this build, "
                                "so any figure phrased over 'both runs' is stale by construction.",
            "near_miss_62s_note": "Three different things coincide near 62 and are reconciled "
                                  "NOWHERE: 62 shared vault TABLES (unit = .sql basename in a "
                                  "vault dir), 62 cross-run (satellite, attribute) PAIRS (unit = "
                                  "pair), and 48 shared satellites + 15 anchors = 63 (unit = "
                                  "vault object). Do not add them.",
            "collapse_totals_token": "NOT_MEASURABLE",
            "collapse_totals_note": "Stage 6 never ran on the legacy half and check_collapse "
                                    "deliberately skips a multi-active target whose child key is "
                                    "unresolved, leaving 286 blocks unjudged. Every legacy "
                                    "collapse figure is a LOWER BOUND; a zero from that "
                                    "instrument is not a clean bill.",
            "normalise_policy": K.normalise_policy(),
        },
        "views": [],
        "key_slots": slots,
        "satellites": [],
        "loaders": loaders,
        "loader_sets": {k: len(v) for k, v in SETS.items()},
        "loader_summary": {
            "declared_total": len(allnames),
            "buildable": sum(1 for L in loaders if L["buildable"]),
            "not_buildable_no_feed": sum(1 for L in loaders if not L["buildable"]),
            "shared_dual_feed": len(shared_dual),
            "shared_single_feed": len(shared_single),
            "shared_single_feed_names": shared_single,
            "per_source_feed_models": sum(1 for L in loaders if L["is_per_source_feed_of"]),
            "buildable_by_set": {k: sum(1 for L in loaders if L["set"] == k and L["buildable"])
                                 for k in SETS},
        },
        "unpivot": unpivot,
        "r8": r8,
        "decisions": K.BUILDER_DECISIONS,
        "directives": K.BUILD_DIRECTIVES,
        "carried_forward_caveat_tables": K.all_carried_forward_tables(),
    }

    # ---------------- views, with the cast decision made on NEED
    for (run, table), rws in sorted(view_rows.items()):
        cols = sorted({r["column_name"] for r in rws})
        consumed = set()
        for s in slots_by_view.get(table, ()):
            consumed |= set(s["source_columns"])
        for S in sat.values():
            for (v, _rn), F in S["feeders"].items():
                if v == table:
                    consumed |= {c["source_column"] for c in F["columns"]}
        for u in unpivot:
            if u["view"] == table:
                for br in u["branches"].values():
                    consumed |= {c["source_column"] for c in br}
        needs = bool(consumed)
        spec["views"].append({
            "table": table, "run": run, "stem": N.view_stem(table),
            "staging_model": N.staging_model(table), "stage_model": N.stage_model(table),
            "source_name": SOURCE_NAME_FOR_RUN[run],
            "columns": cols, "column_count": len(cols),
            "consumed_columns": sorted(consumed), "consumed_count": len(consumed),
            "needs_cast": needs,
            "key_slot_ids": [s["id"] for s in slots_by_view.get(table, ())],
        })
        if not needs:
            K.refuse("view_needs_no_cast", view=table,
                     detail="every column of %s is unconsumed -- no key slot and no satellite "
                            "payload reads it -- so no layer-1 cast is emitted. A view gets a "
                            "cast because it NEEDS one, not because it is in the map (s6.1)."
                            % table)

    hubs_keyed_on_view = collections.defaultdict(set)
    for s in slots:
        hubs_keyed_on_view[s["view"]].add(s["vault_table"])

    for (code, track), S in sorted(sat.items()):
        anchors = S["anchors"].most_common()
        anchor = anchors[0][0] if anchors else None
        anchor_origin = "map.anchor"
        if anchor is None:
            # data_7.js DECLARES the parent. The canonical model is the authority for a ratified
            # satellite's parent; reading it is not a guess. A satellite the model does not
            # contain has no fallback and is refused.
            parent = (K.MODEL_SATS.get(code) or {}).get("parent")
            if isinstance(parent, str) and parent.strip():
                anchor = parent.strip()
                anchor_origin = "data_7.js.parent"
            elif code.startswith("REF_"):
                # A REFERENCE table is not hung off a hub -- it IS a key space, which is why
                # data_7.js refs[] carry no parent. REF_X anchors on REF_X. opus_health_v2 emits
                # the same form, so this reproduces the sibling rather than inventing one.
                anchor = code
                anchor_origin = "reference_table_is_its_own_key_space"
            else:
                anchor_origin = "NONE"
                K.refuse("satellite_has_no_anchor", satellite=code,
                         detail="no block declares an anchor for %s (%s track) and data_7.js "
                                "declares no parent for it either, so there is no hub to key "
                                "against. Reported, not guessed (s5.6)." % (code, track))
        akind = ("link" if (anchor or "").startswith("LNK_") else
                 "ref" if (anchor or "").startswith("REF_") else "hub")
        spec["satellites"].append({
            "code": code, "track": track, "anchor": anchor, "anchor_kind": akind,
            "anchor_distribution": dict(S["anchors"]), "anchor_origin": anchor_origin,
            "in_model": S["in_model"], "hist": S["hist"],
            "model_childkey": S["model_childkey"], "declared_legs": S["declared_legs"],
            "child_key_resolved": S["child_key_resolved"],
            "ck_markers": sorted(S["ck_markers"]),
            "runs": sorted(S["runs"]),
            "payload": [dict({"attribute": a, "column": p["column"],
                              "precedence": p.get("precedence"),
                              "in_model": p.get("in_model"),
                              "writers": p["writers"]},
                             **_fanin(p["writers"])) for a, p in S["payload"].items()],
            "payload_width": len(S["payload"]),
            "feeders": _bind_feeders(S, code, track, anchor, anchor_origin, slots,
                                     hubs_keyed_on_view),
            "refusals": S["refusals"],
            "loader_set": setof.get(code.lower(), "not_declared_by_either_original"),
        })

    spec["meta"]["unresolved"] = K.unresolved_summary()
    spec["unresolved"] = K.UNRESOLVED
    spec["by_design"] = K.BY_DESIGN

    with guarded_open(SPEC_PATH, "w") as fh:
        json.dump(spec, fh, indent=1, sort_keys=False, default=_jsonable)
    inp2 = verify_inputs()
    if inp2["sha256"] != inp["sha256"]:
        raise AssertionError("BUILD INPUT CHANGED DURING THE SPEC BUILD")
    print("[spec] input UNMOVED after build (sha256 %s...)" % inp2["sha256"][:16])
    return spec



def _bind_feeders(S, code, track, anchor, anchor_origin, slots, hubs_keyed_on_view):
    """Bind each feeder to the key slot that produces its anchor hash key, or REFUSE it.

    A feeder with no anchor key cannot be emitted: there is nothing to hash the row onto. Refusing
    it is the only honest option, and the refusal names what IS keyed on that view so the gap can
    be closed by the party that owns it.
    """
    by_view_table = {}
    for s in slots:
        by_view_table.setdefault((s["view"], s["vault_table"]), []).append(s)
    out = []
    for F in S["feeders"].values():
        cand = by_view_table.get((F["view"], anchor), []) if anchor else []
        cand = [s for s in cand if s["run"] == F["run"]] or cand
        rec = {"view": F["view"], "run": F["run"], "columns": F["columns"],
               "instances": sorted(F["instances"]), "child_key": F["child_key"],
               "anchor": anchor, "anchor_origin": anchor_origin,
               "key_slot_id": None, "key_slot_bk_column": None, "key_expression": None,
               "emitted": False}
        if cand:
            s = cand[0]
            rec.update({"key_slot_id": s["id"], "key_slot_bk_column": s["bk_column"],
                        "key_expression": s["expression"], "emitted": True,
                        "key_origin": s["origin"], "key_reject_class": s["reject_class"],
                        "key_uses_normalise": s["uses_normalise"]})
            if len(cand) > 1:
                # MORE THAN ONE registry keys this (view, hub). The FIRST is used and the others
                # are NAMED: choosing silently would assert the registries are one population,
                # which is the undetermined question this build must not answer.
                rec["alternative_key_slots"] = [c["bk_column"] for c in cand[1:]]
                K.refuse("multiple_registries_key_this_view_hub", satellite=code, view=F["view"],
                         detail="(%s, %s) is keyed by %d different business keys in the recovered "
                                "legacy SQL: %s. The first is used for this feeder and the others "
                                "are named rather than merged -- whether they denote the same "
                                "entities is UNDETERMINED and answerable only from the data."
                                % (F["view"], anchor, len(cand),
                                   [c["bk_column"] for c in cand]))
        elif anchor is None:
            pass                                 # already refused at satellite level
        else:
            others = sorted(hubs_keyed_on_view.get(F["view"], ()))
            if others:
                K.refuse("anchor_not_keyed_on_this_view_in_legacy_sql", satellite=code,
                         view=F["view"],
                         detail="%s is anchored on %s (origin %s) but no key for %s exists on "
                                "view %s: the map carries no resolved_key for the legacy half and "
                                "health_dv_dbt's emitted SQL declares a namespaced NK on this "
                                "view only for %s. Stage 6.5 moved 140 anchors and whether any is "
                                "right is UNDETERMINED. This feeder is NOT emitted."
                                % (code, anchor, anchor_origin, anchor, F["view"], others))
            else:
                K.refuse("view_has_no_recoverable_key_at_all", satellite=code, view=F["view"],
                         detail="view %s has no key slot for any hub: the legacy half of the map "
                                "carries no resolved_key and health_dv_dbt's emitted SQL declares "
                                "no namespaced NK reaching it. This feeder is NOT emitted."
                                % F["view"])
        out.append(rec)
    return out


def _fanin(writers):
    """Both scopes of an intra-run fan-in, per run.

    all_writers        every writer of this attribute from that run
    undiscriminated    writers with NO instance and NO redundant_of -- the ONLY ones max() picks
                       among arbitrarily
    tables             distinct source tables among the undiscriminated, which decides whether
                       check_collapse could ever see the group: it groups on
                       (table, satellite, attribute, instance, child_key) and therefore flags only
                       SAME-table pairs. N writers across N tables produce ZERO violations there.
    """
    byrun = collections.defaultdict(list)
    for w in writers:
        byrun[w["run"]].append(w)
    out = {}
    for run, ws in byrun.items():
        und = [w for w in ws if not w.get("discriminated")]
        out[run] = {
            "all_writers": len(ws),
            "discriminated_by_instance": sum(1 for w in ws if w.get("instance")),
            "declared_redundant_of": sum(1 for w in ws if w.get("redundant_of_declared")),
            "undiscriminated": len(und),
            "undiscriminated_tables": sorted({w["view"] for w in und}),
            "undiscriminated_is_cross_table": len({w["view"] for w in und}) > 1,
        }
    return {"fanin_by_run": out,
            "fanin_unit_note": "unit = one writer, i.e. one (map row, container) pair writing this "
                               "attribute. 'undiscriminated' = no instance AND no redundant_of; "
                               "those are the only writers max() picks among arbitrarily."}



def _fanin_census(sat):
    """The whole intra-run fan-in surface, with the definition stated on every figure."""
    # MERGE ACROSS TRACKS FIRST. The spec's build units are keyed by (satellite, track), and a
    # satellite with both a ratified and an unratified unit would otherwise contribute two groups
    # for one (satellite, attribute, run) -- which read 228/999 where the measurement taken once
    # per group reads 180/825, the figure that reproduces the counterparty exactly.
    merged = collections.defaultdict(list)
    hist_of = {}
    for (code, _track), S in sat.items():
        hist_of.setdefault(code, S["hist"] or "")
        if S["hist"]:
            hist_of[code] = S["hist"]
        for attr, p in S["payload"].items():
            for w in p["writers"]:
                merged[(code, attr, w["run"])].append(w)
    single, multi, undeclared = {}, {}, {}
    for (code, attr, run), ws in merged.items():
        und = [w for w in ws if not w.get("discriminated")]
        if len(und) < 2:
            continue
        # one writer per (view, source column): the same column read through two containers is ONE
        # writer, not two
        keyed = {(w["view"], w["source_column"]) for w in und}
        hist = hist_of.get(code)
        # THREE buckets, not two. A satellite data_7.js does not declare has NO declared history,
        # which is a THIRD state -- not a synonym for single-active. Defaulting it to "" and
        # testing for 'Multi-Active' silently classified every UNRATIFIED proposal as
        # single-active and moved the figure from 180 to 228.
        if not hist:
            tgt = undeclared
        elif "Multi-Active" in hist:
            tgt = multi
        else:
            tgt = single
        tgt[(code, attr, run)] = (len(keyed), len({v for v, _c in keyed}))
    def census(d):
        same = {k: v for k, v in d.items() if v[1] == 1}
        cross = {k: v for k, v in d.items() if v[1] > 1}
        return {"groups": len(d), "columns": sum(v[0] for v in d.values()),
                "same_table_groups": len(same),
                "same_table_columns": sum(v[0] for v in same.values()),
                "cross_table_groups": len(cross),
                "cross_table_columns": sum(v[0] for v in cross.values()),
                "worst_cross_table": [
                    {"satellite": k[0], "attribute": k[1], "run": k[2],
                     "undiscriminated_writers": v[0], "distinct_tables": v[1]}
                    for k, v in sorted(cross.items(), key=lambda kv: -kv[1][0])[:10]]}
    return {
        "definition_note": "GROUP = (satellite, attribute, source_run), MERGED ACROSS TRACKS. "
                           "WRITER = one distinct (source view, source column) pair, so the same "
                           "column read through two containers is ONE writer. UNDISCRIMINATED = "
                           "no instance AND no redundant_of. SINGLE-ACTIVE = data_7.js hist does "
                           "not contain 'Multi-Active'. A group counts only with 2+ "
                           "undiscriminated writers. THE UNIT IS THE WHOLE DIFFERENCE between "
                           "this figure and a per-build-unit one, which reads 228/999.",
        "reconciliation_note": "This build measures single-active 180 groups / 825 columns, 6 "
                               "same-table and 174 cross-table, which REPRODUCES THE MAPPING "
                               "COUNTERPARTY'S FIGURE EXACTLY. A third figure of 164/765 with 0 "
                               "same-table was relayed from a different single-active definition; "
                               "both are recorded and they are NOT reconciled, because the "
                               "definitions differ and the conclusion -- that essentially the "
                               "whole surface is CROSS-table -- is the same either way.",
        "single_active": census(single),
        "multi_active": census(multi),
        "history_undeclared_in_model": census(undeclared),
        "three_buckets_note": "THREE buckets, not two. A satellite data_7.js does not declare has "
                              "NO declared history; that is a third state and not a synonym for "
                              "single-active. Counting it as single-active moved this figure from "
                              "180 groups to 228 -- a classification that was fabricated by a "
                              "dictionary default.",
        "check_collapse_blind_spot_note": "check_collapse groups on (table, satellite, attribute, "
                                          "instance, child_key), so it can only flag writers from "
                                          "the SAME table. N writers spread across N different "
                                          "tables produce ZERO violations there. Any previously "
                                          "quoted collapse figure therefore BOUNDS THE SAME-TABLE "
                                          "SUBSET and is not a measurement of the collapse "
                                          "surface; the cross-table population is the larger one "
                                          "and was invisible to that gate on both sides.",
    }


def _refusal_sentence(code, legs, ckr):
    """Say WHY, per sub-population. The three remedies differ and so do the three sentences."""
    sub = ckr["subpopulation"]
    named = ckr["named_legs"]
    if sub == "leg_no_value":
        return ("legs %s are NAMED and NO VALUE is supplied. A leg that is named but empty is "
                "WORSE than an absent one: it reads as RESOLVED to every gate and collides at "
                "build. The leg is not emitted." % (named or legs))
    if sub == "leg_and_value":
        return ("legs %s are NAMED CORRECTLY and the value answers a DIFFERENT QUESTION. "
                "%s declares %r and the map supplies %r -- the leg naming is right, the VALUE is "
                "the wrong KIND, which is why relabelling cannot fix it. Refused, not coined."
                % (named or legs, code, " + ".join(legs), ckr["rendered_value"]))
    if sub == "value_no_leg":
        return ("a child-key VALUE is supplied with NO leg name, so there is nothing to call the "
                "column. Refused rather than named from the declared leg, which would assert a "
                "correspondence the map does not make.")
    return ("no leg name and no value: the discriminator is absent entirely. States found: %s. "
            "ABSENT and PRESENT_NULL both mean 'no discriminator' here, and which one was found "
            "is recorded because a future reader fixing a null will never look for an absent."
            % ckr["states"])


def _jsonable(o):
    if isinstance(o, set):
        return sorted(o)
    if isinstance(o, collections.Counter):
        return dict(o)
    raise TypeError(repr(o))


def main():
    assert_read_only_intact("spec-open", verbose=False)
    spec = build()
    m = spec["meta"]
    print("[spec] views %d (needing a cast %d)  key slots %d  satellites %d  loaders %d"
          % (len(spec["views"]), sum(1 for v in spec["views"] if v["needs_cast"]),
             len(spec["key_slots"]), len(spec["satellites"]), len(spec["loaders"])))
    print("[spec] loader summary: %s" % json.dumps(spec["loader_summary"]))
    feeders = [f for S in spec["satellites"] for f in S["feeders"]]
    print("[spec] satellite feeders: %d total, %d EMITTED (bound to an anchor key slot), "
          "%d REFUSED for want of a key"
          % (len(feeders), sum(1 for f in feeders if f["emitted"]),
             sum(1 for f in feeders if not f["emitted"])))
    print("[spec] anchor origin: %s"
          % json.dumps(dict(collections.Counter(S["anchor_origin"]
                                                for S in spec["satellites"]))))
    print("[spec] R8: fires on %d (satellite, attribute) pairs over %d columns, precedence %s"
          % (m["r8_pairs"], m["r8_columns"], m["r8_precedence_order"]))
    print("[spec] child-key sub-populations (unit = feeder block): %s"
          % m["child_key_subpopulations"])
    fc = m["intra_run_fanin_census"]
    for scope in ("single_active", "multi_active", "history_undeclared_in_model"):
        c = fc[scope]
        print("[spec] intra-run fan-in, %s: %d group(s) / %d column(s); SAME-table %d/%d, "
              "CROSS-table %d/%d  (unit = group of undiscriminated writers)"
              % (scope, c["groups"], c["columns"], c["same_table_groups"],
                 c["same_table_columns"], c["cross_table_groups"], c["cross_table_columns"]))
    print("[spec] UNRESOLVED: %s" % json.dumps(m["unresolved"]))
    print("[spec] wrote %s" % os.path.relpath(SPEC_PATH, PROJECT_ROOT))
    assert_read_only_intact("spec-close", verbose=False)
    return 0


if __name__ == "__main__":
    sys.exit(main())
