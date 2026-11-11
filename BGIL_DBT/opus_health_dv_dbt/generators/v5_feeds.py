# -*- coding: utf-8 -*-
"""The logical model: every map row becomes a FEED or a registered REFUSAL.

A feed is one source column landing on one satellite attribute, with the business-key legs that
key it (expressions on the same table), and its child-key values when the satellite is
multi-active. Satellite specs (pk, child-key legs, history) are read from data_7.js -- the MODEL
governs grain, never the map.

Writes build_artifacts/reports/feeds.json. Nothing here knows about views or SQL layout.
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v5_common as C  # noqa: E402
import v5_keys as K

ROLE_LINK = "LNK_PARTY_ROLE"
ROLE_PREFIX = "SAT_LNK_ROLE_"
SYSTEM_COLS = {"HASHDIFF", "LOAD_DATETIME", "RECORD_SOURCE"}


def table_columns(rows):
    cols = collections.defaultdict(set)
    run = {}
    for r in rows:
        cols[r["table_name"]].add(r["column_name"])
        run.setdefault(r["table_name"], r["source_run"])
    for t, cs in C.tables_index_d3().items():
        cols[t] |= set(cs)
    for t, cs in K.legacy_staged_columns().items():
        if run.get(t) == C.LEGACY_RUN:
            cols[t] |= cs
    return cols


def sat_specs(d7, reg):
    links = {l["code"]: l for l in d7["links"]}
    specs = {}
    for s in d7["sats"]:
        code, parent = s["code"], s["parent"]
        legs_decl = [x.strip() for x in (s.get("childkey") or "").split("+") if x.strip()]
        ma = "multi" in (s.get("hist") or "").lower()
        spec = {"code": code, "parent": parent, "hist": s.get("hist"), "ma": ma,
                "cdk_legs": legs_decl if ma else [], "role": None,
                "attrs": [a["n"] for a in s.get("attrs", [])]}
        if parent == ROLE_LINK:
            if not code.startswith(ROLE_PREFIX):
                spec["unbuildable"] = "parented on the one-hub role link but not a role satellite"
            spec.update(kind="role", pk_hubs=["HUB_PARTY"], pk_col="PARTY_HKEY", ma=True,
                        cdk_legs=["Role Type"], role=code[len(ROLE_PREFIX):])
        elif parent.startswith("LNK_"):
            hubs = links[parent]["hubs"]
            spec.update(kind="link", pk_hubs=sorted(hubs), pk_col=C.hkey(parent))
            if len(set(hubs)) < len(hubs) or len(hubs) < 2:
                spec["unbuildable"] = ("parent link %s repeats a hub or has one hub, so its legs "
                                       "cannot be told apart by hub key" % parent)
        else:
            spec.update(kind="hub", pk_hubs=[parent], pk_col=C.hkey(parent))
        if ma and not spec["cdk_legs"]:
            spec["ma"] = False
            reg.refuse("multi_active_without_declared_child_key", code,
                       "data_7.js marks it %s but declares no child key; built single-active "
                       "rather than inventing a discriminator" % s.get("hist"), "modeller")
        specs[code] = spec
    return specs


def ck_col(leg):
    return C.upper_snake(leg) + "_CK"


def parse_cdk(target, spec, cols_lower):
    """{leg: ('col', alias) | ('lit', value) | None}. Structured components first, then the
    'Leg = {COL}' / 'Leg = VALUE' rendering. Bare labels name no leg and resolve nothing."""
    legs = spec["cdk_legs"]
    want = {l.lower(): l for l in legs}
    got = {l: None for l in legs}
    pairs = []
    for c in target.get("child_key_components") or []:
        if isinstance(c, dict) and c.get("name") is not None:
            pairs.append((str(c["name"]), str(c.get("value") if c.get("value") is not None else "")))
    if not pairs:
        v = target.get("child_key_value") or ""
        for m in re.finditer(r"([A-Za-z][^=;]*?)\s*=\s*(\{[A-Za-z0-9_]+\}|[^;]+)", v):
            pairs.append((m.group(1).strip(), m.group(2).strip()))
    for name, val in pairs:
        leg = want.get(name.strip().lower())
        if not leg or not val:
            continue
        m = re.match(r"^\{([A-Za-z0-9_]+)\}$", val)
        if m:
            a = C.source_alias(m.group(1))
            got[leg] = ("col", a) if a in cols_lower else None
        elif not any(ch in val for ch in "{}\"\\'"):
            got[leg] = ("lit", val)
    return got


def main():
    reg = C.Register()
    rows = C.map_rows()
    d7 = C.model()
    specs = sat_specs(d7, reg)
    links = {l["code"]: l for l in d7["links"]}
    cols = table_columns(rows)
    cols_lower = {t: {C.source_alias(c) for c in cs} for t, cs in cols.items()}
    bad_cols = {t: sorted(c for c in cs if not re.match(r"^[A-Za-z_][A-Za-z0-9_$]*$", c))
                for t, cs in cols.items()}
    for t, bc in bad_cols.items():
        for c in bc:
            reg.refuse("source_column_name_not_an_identifier", "%s.%s" % (t, c),
                       "cannot be aliased safely in staging; not carried", "source owner")
    run_of = {}
    for r in rows:
        run_of.setdefault(r["table_name"], r["source_run"])

    LF = K.legacy_forms()
    legacy_hubkey = collections.defaultdict(set)
    for r in rows:
        t = r.get("target") or {}
        if (r["source_run"] == C.LEGACY_RUN and r["outcome"] == "mapped"
                and t.get("kind") == "hub_key" and (t.get("anchor") or "").startswith("HUB_")):
            legacy_hubkey[(r["table_name"], t["anchor"])].add(C.source_alias(r["column_name"]))

    def legacy_leg(table, sat, hub, instance):
        forms = {(e, tag) for h, e, tag in LF["ts"].get((table, sat), set()) if h == hub}
        exprs = {e for e, _t in forms}
        if len(exprs) == 1:
            return next(iter(exprs)), "health_dv_dbt (table, satellite)", None
        if len(exprs) > 1:
            if instance:
                hit = {e for e, tag in forms if tag and instance.lower().replace("-", "_") in tag}
                if len(hit) == 1:
                    return next(iter(hit)), "health_dv_dbt (table, satellite, instance)", None
            return None, None, "%d distinct key forms for %s on %s in health_dv_dbt and nothing " \
                               "on the row chooses between them" % (len(exprs), hub, table)
        th = LF["th"].get((table, hub), set())
        if len(th) == 1:
            return next(iter(th)), "health_dv_dbt (table, hub)", None
        if len(th) > 1:
            return None, None, "%d distinct key forms for %s on %s in health_dv_dbt" % (
                len(th), hub, table)
        hk = legacy_hubkey.get((table, hub), set())
        if len(hk) == 1:
            return next(iter(hk)), "map hub_key row", None
        if len(hk) > 1:
            return None, None, "%d hub_key rows name different columns for %s on %s" % (
                len(hk), hub, table)
        return None, None, "no key form for %s on %s in the map or in health_dv_dbt" % (hub, table)

    def resolve_legs(r, target, spec, sat_for_legacy):
        """{hub: expr} for every pk hub of the satellite, or (None, why, whose)."""
        table = r["table_name"]
        need = spec["pk_hubs"]
        if r["source_run"] == C.LEGACY_RUN:
            legs, prov = {}, set()
            for h in need:
                e, p, why = legacy_leg(table, sat_for_legacy, h, target.get("instance"))
                if why:
                    return None, why, "mapper"
                legs[h] = e
                prov.add(p)
            return (legs, sorted(prov)), None, None
        rk = target.get("resolved_key") if isinstance(target.get("resolved_key"), dict) else None
        if not rk:
            return None, "no resolved_key on a %s row" % r["source_run"], "mapper"
        e = rk.get("expression") or ""
        if spec["kind"] == "hub":
            if rk.get("hub") != need[0]:
                return None, "resolved_key keys %s but the satellite's parent is %s" % (
                    rk.get("hub"), need[0]), "mapper"
            return ({need[0]: e}, ["map resolved_key"]), None, None
        legs = K.parse_lnk(e)
        if legs is None and rk.get("legs"):
            raw = rk["legs"]
            legs = {}
            for item in (raw if isinstance(raw, list) else [raw]):
                if isinstance(item, dict):
                    legs.update(item)
        if legs is None and len(need) == 1 and rk.get("hub") == need[0]:
            legs = {need[0]: e}
        if not legs or not set(need) <= set(legs):
            return None, "resolved_key does not give every leg of %s (%s)" % (
                spec["parent"], ", ".join(need)), "mapper"
        return ({h: legs[h] for h in need}, ["map resolved_key legs"]), None, None

    feeds, dropped = [], collections.Counter()
    for r in rows:
        t = r.get("target") if isinstance(r.get("target"), dict) else {}
        a = r.get("augmentation") if isinstance(r.get("augmentation"), dict) else None
        table, col = r["table_name"], r["column_name"]
        subj = "%s.%s" % (table, col)
        if col in bad_cols.get(table, []):
            continue
        if r["outcome"] == "mapped" and t.get("kind") == "satellite_attribute" and t.get("satellite"):
            track, sat = "standard", t["satellite"]
            spec = specs.get(sat)
            if spec is None:
                reg.refuse("satellite_not_in_model", subj, "%s is not in data_7.js" % sat, "mapper")
                continue
            if t.get("redundant_of"):
                dropped["redundant_of"] += 1
                continue
            attr_names = {x.lower(): x for x in spec["attrs"]}
            attr = attr_names.get((t.get("attribute") or "").strip().lower())
            if not attr:
                reg.refuse("attribute_not_in_model", subj, "%r is not an attribute of %s in "
                           "data_7.js" % (t.get("attribute"), sat), "mapper")
                continue
            legacy_sat = sat
        elif r["outcome"] == "augmentation_needed" and a:
            track = "augmented"
            home = re.match(r"^\s*(SAT_[A-Z0-9_]+)", a.get("best_home_satellite") or "")
            new = re.match(r"^\s*(SAT_[A-Z0-9_]+)", a.get("new_satellite") or "")
            base = home.group(1) if home else (new.group(1) if new else None)
            if not base:
                reg.refuse("augmentation_without_target_name", subj,
                           "neither best_home_satellite nor new_satellite names a satellite",
                           "mapper")
                continue
            sat = "SAT_AUG_" + C.short(base)
            anchor = a.get("anchor") if (a.get("anchor") or "").startswith(("HUB_", "LNK_")) else None
            if not anchor and home and home.group(1) in specs:
                anchor = specs[home.group(1)]["parent"]
            if not anchor and (t.get("anchor") or "").startswith(("HUB_", "LNK_")):
                anchor = t["anchor"]
            if not anchor:
                reg.refuse("augmentation_without_anchor", subj, "no anchor field and no home "
                           "satellite to read one from", "mapper")
                continue
            if anchor == ROLE_LINK or (anchor.startswith("LNK_") and (
                    len(set(links[anchor]["hubs"])) < len(links[anchor]["hubs"]))):
                reg.refuse("augmentation_on_unbuildable_link", subj,
                           "anchored on %s, whose legs cannot be told apart" % anchor, "mapper")
                continue
            if not a.get("proposed_attribute"):
                reg.refuse("augmentation_without_attribute", subj, "no proposed_attribute",
                           "mapper")
                continue
            attr = a["proposed_attribute"]
            if sat not in specs:
                kind = "link" if anchor.startswith("LNK_") else "hub"
                hubs = sorted(links[anchor]["hubs"]) if kind == "link" else [anchor]
                specs[sat] = {"code": sat, "parent": anchor, "hist": "SCD2", "ma": False,
                              "cdk_legs": [], "role": None, "attrs": [], "kind": kind,
                              "pk_hubs": hubs, "pk_col": C.hkey(anchor), "augmented": True}
            spec = specs[sat]
            if spec["parent"] != anchor:
                reg.refuse("augmentation_anchor_conflict", subj, "%s is anchored on %s by an "
                           "earlier row; this row says %s" % (sat, spec["parent"], anchor), "mapper")
                continue
            comps = a.get("child_key_components") or []
            for c in comps:
                if isinstance(c, dict) and c.get("name") and c["name"] not in spec["cdk_legs"]:
                    spec["cdk_legs"].append(c["name"])
                    spec["ma"] = True
            t = dict(t)
            t["child_key_components"] = comps
            t["child_key_value"] = a.get("child_key_value")
            if r["source_run"] != C.LEGACY_RUN and not isinstance(t.get("resolved_key"), dict):
                t["resolved_key"] = a.get("resolved_key")
            legacy_sat = home.group(1) if home else sat
        else:
            continue
        if spec.get("unbuildable"):
            reg.refuse("satellite_unbuildable", subj, spec["unbuildable"], "modeller", satellite=sat)
            continue
        got, why, whose = resolve_legs(r, t, spec, legacy_sat)
        if why:
            reg.refuse("key_unresolved", subj, why, whose, satellite=sat, run=r["source_run"])
            continue
        legs, prov = got
        bad = None
        for h, e in legs.items():
            b = K.check_expr(e, cols_lower[table])
            if b:
                bad = "%s leg: %s" % (h, b)
                break
        if bad:
            reg.refuse("key_not_emittable", subj, bad,
                       "mapper" if "normalise" not in bad else "source owner",
                       satellite=sat, run=r["source_run"])
            continue
        alias = C.source_alias(col)
        if alias not in cols_lower[table]:
            reg.refuse("column_not_on_table", subj, "not in the table's column list", "mapper")
            continue
        cdk = {}
        if spec["kind"] == "role":
            cdk = {"Role Type": ("lit", spec["role"])}
        elif spec["ma"]:
            cdk = parse_cdk(t, spec, cols_lower[table])
            unresolved = [l for l, v in cdk.items() if v is None]
            if unresolved:
                reg.refuse("child_key_unresolved", subj,
                           "no resolvable value for leg(s) %s; landed with a NULL child key and "
                           "the unresolved grain DECLARED rather than a discriminator invented"
                           % ", ".join(unresolved), "mapper", satellite=sat, landed=True)
        feeds.append({"track": track, "sat": sat, "table": table, "run": r["source_run"],
                      "column": alias, "attribute": attr,
                      "legs": {h: K.norm(e) for h, e in sorted(legs.items())},
                      "key_provenance": prov,
                      "cdk": {l: (list(v) if v else None) for l, v in sorted(cdk.items())}})

    # payload names, per satellite, injective
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
    cands = []
    for (table, lnk), legs in sorted(LF["tl"].items()):
        if run_of.get(table) != C.LEGACY_RUN or table not in cols_lower:
            continue
        L = links.get(lnk)
        if not L or len(set(L["hubs"])) != len(L["hubs"]) or set(L["hubs"]) != set(legs):
            continue
        if any(K.check_expr(e, cols_lower[table]) for e in legs.values()):
            continue
        cands.append({"link": lnk, "table": table, "legs": {h: K.norm(e) for h, e in
                                                          sorted(legs.items())},
                      "evidence": "health_dv_dbt stg2_link model for this (table, link)"})
    slot = collections.defaultdict(set)
    for r in rows:
        if r["source_run"] == C.LEGACY_RUN:
            continue
        t = r.get("target") if isinstance(r.get("target"), dict) else {}
        rk = t.get("resolved_key") if isinstance(t.get("resolved_key"), dict) else None
        if rk and (rk.get("hub") or "").startswith("HUB_") and not rk.get("instance") and rk.get("expression"):
            slot[(r["table_name"], rk["hub"])].add(K.norm(rk["expression"]))
    by_table = collections.defaultdict(dict)
    for (table, hub), es in slot.items():
        if len(es) == 1 and not K.check_expr(next(iter(es)), cols_lower[table]):
            by_table[table][hub] = next(iter(es))
    for table in sorted(by_table):
        hubs = by_table[table]
        for L in d7["links"]:
            hs = L["hubs"]
            if len(hs) < 2 or len(set(hs)) != len(hs) or not set(hs) <= set(hubs):
                continue
            if hubsets[frozenset(hs)] > 1:
                reg.refuse("link_hub_set_ambiguous", "%s on %s" % (L["code"], table),
                           "more than one model link joins exactly these hubs, so key "
                           "co-occurrence cannot say which association this row is", "modeller")
                continue
            cands.append({"link": L["code"], "table": table,
                          "legs": {h: hubs[h] for h in sorted(hs)},
                          "evidence": "every leg's key resolves once, instance-free, on this table "
                                      "in the map"})

    used = {f["sat"] for f in feeds}
    out_specs = {s: specs[s] for s in sorted(used)}
    C.write_json("feeds.json", {
        "feeds": feeds, "sat_specs": out_specs, "link_candidates": cands,
        "table_columns": {t: sorted(cs) for t, cs in sorted(cols.items())},
        "table_runs": run_of, "dropped_by_rule": dict(dropped),
        "legacy_forms_files_read": LF["files_read"],
    })
    C.write_json("register_feeds.json", reg.items)
    print("  feeds: %d (standard %d, augmented %d) over %d satellites; %d link candidates; "
          "%d register entries" % (len(feeds), sum(f["track"] == "standard" for f in feeds),
                                   sum(f["track"] == "augmented" for f in feeds), len(used),
                                   len(cands), len(reg.items)))
    print("  register by kind:", reg.summary()["by_kind"])


if __name__ == "__main__":
    main()
