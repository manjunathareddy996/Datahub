# -*- coding: utf-8 -*-
"""The logical model: every map block becomes a FEED or a registered REFUSAL.

A feed is one source column landing on one satellite attribute, with the raw key expression of
every pk leg (rendered later, per branch, by mxh4_spine) and the raw child-key leg values. Every
key and child key is DRY-RENDERED here against its own table, so a walk that cannot run is
refused now rather than emitted. Satellite grain comes from data_7.js. Directives are read from
typed fields (build_directive, do_not_build, leg_backing, precondition_severity), never prose.
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mxh4_common as C  # noqa: E402
import mxh4_spine as S  # noqa: E402

ROLE_LINK = "LNK_PARTY_ROLE"
ROLE_PREFIX = "SAT_LNK_ROLE_"
SYSTEM_COLS = {"HASHDIFF", "LOAD_DATETIME", "RECORD_SOURCE"}


def ck_col(leg):
    return C.upper_snake(leg) + "_CK"


def sat_specs(d7, reg):
    links = {l["code"]: l for l in d7["links"]}
    specs = {}
    for s in d7["sats"]:
        code, parent = s["code"], s["parent"]
        legs = [x.strip() for x in (s.get("childkey") or "").split("+") if x.strip()]
        ma = "multi" in (s.get("hist") or "").lower()
        spec = {"code": code, "parent": parent, "hist": s.get("hist"), "ma": ma,
                "cdk_legs": legs if ma else [], "role": None,
                "attrs": [a["n"] for a in s.get("attrs", [])]}
        if parent == ROLE_LINK:
            spec.update(kind="role", pk_hubs=["HUB_PARTY"], pk_col="PARTY_HKEY", ma=True,
                        cdk_legs=["Role Type"], role=code[len(ROLE_PREFIX):]
                        if code.startswith(ROLE_PREFIX) else None)
            if not spec["role"]:
                spec["unbuildable"] = "parented on the one-hub role link but not a role satellite"
        elif parent.startswith("LNK_"):
            hubs = links[parent]["hubs"]
            spec.update(kind="link", pk_hubs=sorted(hubs), pk_col=C.hkey(parent))
            if len(set(hubs)) < len(hubs) or len(hubs) < 2:
                spec["unbuildable"] = "parent link %s repeats a hub or has one hub" % parent
        else:
            spec.update(kind="hub", pk_hubs=[parent], pk_col=C.hkey(parent))
        if ma and not spec["cdk_legs"]:
            spec["ma"] = False
        specs[code] = spec
    return specs


def split_ckv(v):
    """'Leg = value | Leg = value' split on ' | ' at brace depth zero; binder ' = '."""
    out = []
    for part in S.split_top(v or "", " | ", "{(", "})"):
        if " = " in part:
            name, val = part.split(" = ", 1)
            out.append((name.strip(), val.strip()))
    return out


def main():
    prof = C.profile()
    policy = prof["normalise_policy"]
    reg = C.Register()
    rows = C.map_rows()
    d7 = C.model()
    T = C.tables()
    specs = sat_specs(d7, reg)
    links = {l["code"]: l for l in d7["links"]}
    suppressed = {tuple(x) for x in prof["directives"]["suppressed_routing"]}
    feeds, dropped = [], collections.Counter()

    def dry(table, expr):
        rd = S.Renderer(table, policy)
        return rd.render(expr)

    def legs_of(rk, spec):
        """{hub: raw expr} for every pk hub, or raise Unresolvable."""
        need = spec["pk_hubs"]
        e = rk.get("expression") or ""
        if spec["kind"] in ("hub",):
            if rk.get("hub") != need[0]:
                raise S.Unresolvable("resolved_key keys %s, the satellite's parent is %s"
                                     % (rk.get("hub"), need[0]))
            return {need[0]: e}
        legs = S.parse_lnk(e)
        if legs is None and e.strip().startswith("LNK(") and e.strip().endswith(")"):
            # The map spells LNK legs three ways: 'HUB_X = expr', 'HUB_X: expr', and positional.
            # Named non-hub parts (ROLE_CODE = 'X') and pure string literals are role labels,
            # not legs. A positional operand is accepted ONLY on a one-hub link, where it can be
            # no other leg; a multi-hub link with a positional operand is refused.
            named, positional = {}, []
            for part in S.split_top(e.strip()[4:-1], ","):
                m = re.match(r"^([A-Z_][A-Z0-9_]*)\s*[=:]\s*(.+)$", part, re.S)
                if m and m.group(1).startswith("HUB_"):
                    named[m.group(1)] = m.group(2).strip()
                elif m:
                    continue
                elif re.match(r"^'(?:[^']|'')*'$", part.strip()):
                    continue
                else:
                    positional.append(part.strip())
            if positional and len(need) == 1 and len(positional) == 1 and not named:
                named = {need[0]: positional[0]}
            elif positional:
                named = {}
            legs = named or None
        if legs is None and isinstance(rk.get("legs"), dict):
            legs = dict(rk["legs"])
        if legs is None and rk.get("hub") in need and len(need) == 1:
            legs = {need[0]: e}
        if not legs or not set(need) <= set(legs):
            raise S.Unresolvable("resolved_key does not give every leg of %s" % spec["parent"])
        return {h: legs[h] for h in need}

    for r in rows:
        table, col = r["table_name"], r["column_name"]
        subj = "%s.%s" % (table, col)
        t = r.get("target") if isinstance(r.get("target"), dict) else {}
        a = r.get("augmentation") if isinstance(r.get("augmentation"), dict) else None
        if table not in T:
            reg.refuse("table_not_in_index", subj, "table absent from 00_tables_index", "mapper")
            continue
        if r["outcome"] == "mapped" and t.get("kind") == "satellite_attribute" and t.get("satellite"):
            track, blk, sat = "standard", t, t["satellite"]
            rk = t.get("resolved_key") if isinstance(t.get("resolved_key"), dict) else None
            spec = specs.get(sat)
            if spec is None:
                reg.refuse("satellite_not_in_model", subj, "%s not in data_7.js" % sat, "mapper")
                continue
            names = {x.lower(): x for x in spec["attrs"]}
            attr = names.get((t.get("attribute") or "").strip().lower())
            if not attr:
                reg.refuse("attribute_not_in_model", subj, "%r is not an attribute of %s" % (
                    t.get("attribute"), sat), "mapper")
                continue
            if (sat, attr) in suppressed:
                reg.refuse("directive_suppressed_routing", subj, "BUILD_INSTRUCTIONS s4.1: not built "
                           "on %s" % sat, "mapper", satellite=sat)
                continue
        elif r["outcome"] == "augmentation_needed" and a:
            track, blk = "augmented", a
            home = a.get("best_home_satellite") if a.get("best_home_satellite") in specs else None
            new = re.match(r"^\s*(SAT_[A-Z0-9_]+)", a.get("new_satellite") or "")
            base = home or (new.group(1) if new else None)
            if not base:
                reg.refuse("augmentation_without_target_name", subj, "no home or new satellite code",
                           "mapper")
                continue
            sat = "SAT_AUG_" + C.short(base)
            anchor = a.get("anchor")
            if not (anchor or "").startswith(("HUB_", "LNK_")):
                reg.refuse("augmentation_without_anchor", subj, "no anchor field", "mapper")
                continue
            if anchor == ROLE_LINK or (anchor.startswith("LNK_") and
                                       len(set(links[anchor]["hubs"])) < len(links[anchor]["hubs"])):
                reg.refuse("augmentation_on_unbuildable_link", subj, "anchored on %s" % anchor, "mapper")
                continue
            attr = a.get("proposed_attribute")
            if not attr:
                reg.refuse("augmentation_without_attribute", subj, "no proposed_attribute", "mapper")
                continue
            rk = a.get("resolved_key") if isinstance(a.get("resolved_key"), dict) else (
                t.get("resolved_key") if isinstance(t.get("resolved_key"), dict) else None)
            if sat not in specs:
                kind = "link" if anchor.startswith("LNK_") else "hub"
                specs[sat] = {"code": sat, "parent": anchor, "hist": "SCD2", "ma": False,
                              "cdk_legs": [], "role": None, "attrs": [], "kind": kind,
                              "pk_hubs": sorted(links[anchor]["hubs"]) if kind == "link" else [anchor],
                              "pk_col": C.hkey(anchor), "augmented": True}
            spec = specs[sat]
            if spec["parent"] != anchor:
                reg.refuse("augmentation_anchor_conflict", subj, "%s is anchored on %s by an earlier "
                           "row; this row says %s" % (sat, spec["parent"], anchor), "mapper")
                continue
            if a.get("multi_active"):
                for leg in [x.strip() for x in (a.get("child_key") or "").split("+") if x.strip()] + \
                        [c.get("leg") for c in (a.get("child_key_components") or []) if c.get("leg")]:
                    if leg not in spec["cdk_legs"]:
                        spec["cdk_legs"].append(leg)
                        spec["ma"] = True
        else:
            continue

        # ---- directives, typed fields only
        comps = blk.get("child_key_components") or []
        if blk.get("redundant_of"):
            dropped["redundant_of"] += 1
            continue
        if blk.get("do_not_build"):
            reg.refuse("do_not_build", subj, "do_not_build at block scope", "mapper", satellite=sat)
            continue
        if any(c.get("do_not_build") for c in comps):
            reg.refuse("do_not_build", subj, "do_not_build on a child-key component", "mapper",
                       satellite=sat)
            continue
        if any(c.get("leg_backing") == "surrogate" for c in comps) or blk.get("child_key_tier") == "surrogate":
            reg.refuse("surrogate_child_key_quarantined", subj, "child key is a shred surrogate; "
                       "must not be loaded as a multi-active history until a stable business key is "
                       "sourced (directive)", "source owner", satellite=sat)
            continue
        if blk.get("build_directive"):
            if blk.get("transformation_kind") == "reference_decode":
                reg.refuse("reference_decode_unavailable", subj, "code->decode into a label "
                           "attribute and no decode is available; raw would be wrong data",
                           "source owner", satellite=sat)
                continue
            raise SystemExit("UNRECOGNISED build_directive on %s (%s): the directive population "
                             "must be enumerated; refusing to proceed" % (subj, sat))
        if spec.get("unbuildable"):
            reg.refuse("satellite_unbuildable", subj, spec["unbuildable"], "modeller", satellite=sat)
            continue
        if not rk:
            reg.refuse("key_unresolved", subj, "no resolved_key", "mapper", satellite=sat)
            continue
        if rk.get("tier") == "unresolved":
            reg.refuse("key_unresolved", subj, "resolved_key tier is 'unresolved' (declared source "
                       "gap)", "source owner", satellite=sat)
            continue
        if rk.get("precondition_severity") == "hard_stop":
            reg.refuse("hard_stop_precondition_unchecked", subj, "the map requires a data check "
                       "BEFORE building this key; it has not been run", "source owner", satellite=sat)
            continue
        try:
            legs = legs_of(rk, spec)
            for h, e in legs.items():
                dry(table, e)
        except S.Unresolvable as ex:
            reg.refuse("key_not_emittable", subj, str(ex), "mapper", satellite=sat)
            continue
        single = len(legs) == 1 and not (rk.get("expression") or "").startswith("LNK(")
        leg_specs = {h: {"expr": e, "verdict": rk.get("degenerate_verdict") if single else None,
                         "dv": rk.get("degenerate_value") if single else None}
                     for h, e in sorted(legs.items())}
        if col.upper() not in {c.upper() for c in T[table]["columns"]}:
            reg.refuse("column_not_on_table", subj, "not in the index's column list", "mapper")
            continue
        key_text = " ".join([rk.get("expression") or ""] + list(legs.values()))
        cdk = {}
        if spec["kind"] == "role":
            cdk = {"Role Type": {"value": spec["role"], "backing": "literal"}}
        elif spec["ma"]:
            want = {l.lower(): l for l in spec["cdk_legs"]}
            pairs = [(c.get("leg"), c.get("value"), c.get("leg_backing")) for c in comps if c.get("leg")]
            if not pairs:
                pairs = [(n, v, "template" if "{" in v else "literal")
                         for n, v in split_ckv(blk.get("child_key_value"))]
            got = {l: None for l in spec["cdk_legs"]}
            for name, val, backing in pairs:
                leg = want.get((name or "").strip().lower())
                if not leg:
                    continue
                try:
                    S.render_ck_value(val, backing, S.Renderer(table, policy), key_text)
                    got[leg] = {"value": val, "backing": backing}
                except S.Unresolvable as ex:
                    got[leg] = None
                    reg.refuse("child_key_leg_unresolved", subj, "%s: %s; landed with a NULL leg and "
                               "the grain DECLARED" % (leg, ex), "mapper", satellite=sat, landed=True)
            missing = [l for l, v in got.items() if v is None and not any(
                i["subject"] == subj and i["kind"] == "child_key_leg_unresolved" and i["why"].startswith(l + ":")
                for i in reg.items[-5:])]
            if missing:
                reg.refuse("child_key_leg_unresolved", subj, "no value for leg(s) %s; landed with a "
                           "NULL leg and the grain DECLARED" % ", ".join(missing), "mapper",
                           satellite=sat, landed=True)
            cdk = got
        feeds.append({"track": track, "sat": sat, "table": table, "column": col,
                      "attribute": attr, "legs": leg_specs, "key_text": key_text, "cdk": cdk})

    # ---- payload names, injective per satellite
    payload = collections.defaultdict(dict)
    for f in feeds:
        spec = specs[f["sat"]]
        names = payload[f["sat"]]
        if f["attribute"] not in names:
            n = C.upper_snake(f["attribute"])
            reserved = SYSTEM_COLS | {spec["pk_col"]} | {ck_col(l) for l in spec["cdk_legs"]}
            while n in reserved or n in names.values():
                n = n + "_VALUE" if not n.endswith("_VALUE") else n + "2"
            names[f["attribute"]] = n
        f["payload"] = names[f["attribute"]]

    # ---- link candidates
    hubsets = collections.Counter(frozenset(l["hubs"]) for l in d7["links"])
    slot = collections.defaultdict(set)
    for r in rows:
        t = r.get("target") if isinstance(r.get("target"), dict) else {}
        rk = t.get("resolved_key") if isinstance(t.get("resolved_key"), dict) else None
        if (r["outcome"] == "mapped" and rk and (rk.get("hub") or "").startswith("HUB_")
                and not rk.get("instance") and rk.get("expression") and rk.get("tier") != "unresolved"
                and rk.get("precondition_severity") != "hard_stop"
                and not (rk.get("expression") or "").startswith("LNK(")):
            slot[(r["table_name"], rk["hub"])].add((rk["expression"], rk.get("degenerate_verdict"),
                                                     rk.get("degenerate_value")))
    by_table = collections.defaultdict(dict)
    for (table, hub), forms in slot.items():
        if len(forms) == 1:
            e, v, dv = next(iter(forms))
            try:
                dry(table, e)
                by_table[table][hub] = {"expr": e, "verdict": v, "dv": dv}
            except S.Unresolvable:
                pass
    cands, seen = [], set()
    for table in sorted(by_table):
        hubs = by_table[table]
        for L in d7["links"]:
            hs = L["hubs"]
            if len(hs) < 2 or len(set(hs)) != len(hs) or not set(hs) <= set(hubs):
                continue
            if hubsets[frozenset(hs)] > 1:
                reg.refuse("link_hub_set_ambiguous", "%s on %s" % (L["code"], table), "more than one "
                           "model link joins exactly these hubs", "modeller")
                continue
            c = {"link": L["code"], "table": table, "legs": {h: hubs[h] for h in sorted(hs)},
                 "evidence": "every leg's key resolves once, instance-free, on this table"}
            k = (c["link"], table, tuple(sorted((h, v["expr"]) for h, v in c["legs"].items())))
            if k not in seen:
                seen.add(k)
                cands.append(c)
    for r in rows:
        a = r.get("augmentation") if isinstance(r.get("augmentation"), dict) else {}
        rk = a.get("resolved_key") if isinstance(a.get("resolved_key"), dict) else None
        if not rk or not rk.get("link") or not isinstance(rk.get("legs"), dict):
            continue
        L = links.get(rk["link"])
        if not L or len(set(L["hubs"])) != len(L["hubs"]) or set(L["hubs"]) != set(rk["legs"]):
            continue
        try:
            for e in rk["legs"].values():
                dry(r["table_name"], e)
        except S.Unresolvable:
            continue
        c = {"link": rk["link"], "table": r["table_name"],
             "legs": {h: {"expr": e, "verdict": None, "dv": None} for h, e in sorted(rk["legs"].items())},
             "evidence": "augmentation resolved_key.legs for this link"}
        k = (c["link"], c["table"], tuple(sorted((h, v["expr"]) for h, v in c["legs"].items())))
        if k not in seen:
            seen.add(k)
            cands.append(c)

    used = {f["sat"] for f in feeds}
    C.write_json("feeds.json", {"feeds": feeds, "sat_specs": {s: specs[s] for s in sorted(used)},
                                "link_candidates": cands, "dropped_by_rule": dict(dropped)})
    C.write_json("register_feeds.json", reg.items)
    print("  feeds: %d (standard %d, augmented %d) over %d satellites; %d link candidates; %d "
          "register entries" % (len(feeds), sum(f["track"] == "standard" for f in feeds),
                                sum(f["track"] == "augmented" for f in feeds), len(used), len(cands),
                                len(reg.items)))
    print("  register by kind:", reg.summary()["by_kind"])


if __name__ == "__main__":
    main()
