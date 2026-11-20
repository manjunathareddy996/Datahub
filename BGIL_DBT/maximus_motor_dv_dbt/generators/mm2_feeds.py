# -*- coding: utf-8 -*-
"""The logical model: every map block becomes a FEED or a registered REFUSAL.

A feed is one source column landing on one satellite attribute, with the raw key expression of
every pk leg and the raw child-key leg values; every key and child key is DRY-RENDERED against its
own table first. Grain comes from data_7.js. The Maximus Motor directives (build_profile.json ->
directives):

  empty key shell              resolved_key object with no expression -> refused (source)
  withheld_unruled             the CLAIM_APPLICANT_* rows, never ruled -> withheld (source)
  link_leg_identity            a link leg differing from every key form of its hub on that view
                               -> withheld, never emitted non-joining (mapper)
  redundant_of                 the pointing writer is withheld; its target is emitted, and every
                               group's decision is written to single_writer_decisions.json
  risk_object_interest_grain   flagged for a DUAL-GRAIN banner; keys emitted as stated
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mm2_common as C  # noqa: E402
import mm2_spine as S  # noqa: E402

ROLE_LINK = "LNK_PARTY_ROLE"
ROLE_PREFIX = "SAT_LNK_ROLE_"
SYSTEM_COLS = {"HASHDIFF", "LOAD_DATETIME", "RECORD_SOURCE"}


def ck_col(leg):
    return C.upper_snake(leg) + "_CK"


def sat_specs(d7):
    links = {l["code"]: l for l in d7["links"]}
    specs = {}
    for s in d7["sats"]:
        code, parent = s["code"], s["parent"]
        legs = [x.strip() for x in (s.get("childkey") or "").split("+") if x.strip()]
        ma = "multi" in (s.get("hist") or "").lower()
        spec = {"code": code, "parent": parent, "hist": s.get("hist"), "ma": ma and bool(legs),
                "cdk_legs": legs if ma else [], "role": None, "attrs": [a["n"] for a in s.get("attrs", [])]}
        if parent == ROLE_LINK:
            spec.update(kind="role", pk_hubs=["HUB_PARTY"], pk_col="PARTY_HKEY", ma=True,
                        cdk_legs=["Role Type"], role=code[len(ROLE_PREFIX):] if code.startswith(ROLE_PREFIX) else None)
            if not spec["role"]:
                spec["unbuildable"] = "parented on the one-hub role link but not a role satellite"
        elif parent.startswith("LNK_"):
            hubs = links[parent]["hubs"]
            spec.update(kind="link", pk_hubs=sorted(hubs), pk_col=C.hkey(parent))
            if len(set(hubs)) < len(hubs) or len(hubs) < 2:
                spec["unbuildable"] = "parent link %s repeats a hub or has one hub" % parent
        else:
            spec.update(kind="hub", pk_hubs=[parent], pk_col=C.hkey(parent))
        specs[code] = spec
    return specs


def split_ckv(v):
    out = []
    for part in S.split_top(v or "", " | ", "{(", "})"):
        if " = " in part:
            name, val = part.split(" = ", 1)
            out.append((name.strip(), val.strip()))
    return out


def lnk_legs(e, need):
    legs = S.parse_lnk(e)
    if legs is not None:
        return legs
    e = (e or "").strip()
    if not (e.startswith("LNK(") and e.endswith(")")):
        return None
    named, positional = {}, []
    for part in S.split_top(e[4:-1], ","):
        m = re.match(r"^([A-Z_][A-Z0-9_]*)\s*[=:]\s*(.+)$", part, re.S)
        if m and m.group(1).startswith("HUB_"):
            named[m.group(1)] = m.group(2).strip()
        elif m or re.match(r"^'(?:[^']|'')*'$", part.strip()):
            continue
        else:
            positional.append(part.strip())
    if positional and len(need) == 1 and len(positional) == 1 and not named:
        return {need[0]: positional[0]}
    return None if positional else (named or None)


def main():
    prof = C.profile()
    policy = prof["normalise_policy"]
    reg = C.Register()
    rows = C.map_rows()
    d7 = C.model()
    T = C.tables()
    specs = sat_specs(d7)
    links = {l["code"]: l for l in d7["links"]}
    feeds, dropped, withheld = [], collections.Counter(), []
    interest = collections.defaultdict(list)
    unruled = set(prof["directives"]["withheld_unruled"]["rows"])

    def squash(e):
        return re.sub(r"\s+", "", e or "")

    # every key form each hub takes on each view: a link leg must equal one of them
    hub_forms = collections.defaultdict(set)
    for r in rows:
        for side in ("target", "augmentation"):
            b = r.get(side) if isinstance(r.get(side), dict) else {}
            k = b.get("resolved_key") if isinstance(b.get("resolved_key"), dict) else None
            if (k and (k.get("hub") or "").startswith("HUB_") and k.get("expression")
                    and not k["expression"].startswith("LNK(")):
                hub_forms[(r["table_name"], k["hub"])].add(squash(k["expression"]))

    def dry(table, expr):
        return S.Renderer(table, policy).render(expr)

    def legs_of(rk, spec):
        need = spec["pk_hubs"]
        e = rk.get("expression") or ""
        if spec["kind"] == "hub":
            if rk.get("hub") != need[0]:
                raise S.Unresolvable("resolved_key keys %s, the satellite's parent is %s" % (rk.get("hub"), need[0]))
            return {need[0]: e}
        legs = lnk_legs(e, need)
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
        if r["outcome"] not in ("mapped", "augmentation_needed"):
            continue
        if table not in T:
            reg.refuse("table_not_in_index", subj, "table absent from 00_tables_index", "mapper")
            continue
        if r["outcome"] == "mapped" and t.get("kind") == "satellite_attribute" and t.get("satellite"):
            track, blk, sat = "standard", t, t["satellite"]
            spec = specs.get(sat)
            if spec is None:
                reg.refuse("satellite_not_in_model", subj, "%s not in data_7.js" % sat, "mapper")
                continue
            attr = {x.lower(): x for x in spec["attrs"]}.get((t.get("attribute") or "").strip().lower())
            if not attr:
                reg.refuse("attribute_not_in_model", subj, "%r not on %s" % (t.get("attribute"), sat), "mapper")
                continue
            rk = t.get("resolved_key")
        elif r["outcome"] == "augmentation_needed" and a:
            track, blk = "augmented", a
            home = a.get("best_home_satellite") if a.get("best_home_satellite") in specs else None
            tok = re.match(r"^\s*(SAT_[A-Z0-9_]+)", a.get("new_satellite") or a.get("best_home_satellite") or "")
            base = home or (tok.group(1) if tok else None)
            if not base and (a.get("best_home_satellite") or "").startswith("REF_"):
                reg.refuse("reference_target_not_built", subj, "augmentation homed on reference %s; this "
                           "build emits no reference satellites (models/.../references/ is empty, as in "
                           "partner and travel)" % a["best_home_satellite"], "modeller")
                continue
            if not base:
                reg.refuse("augmentation_without_target_name", subj, "no home or new satellite code", "mapper")
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
            rk = a.get("resolved_key") if isinstance(a.get("resolved_key"), dict) else t.get("resolved_key")
            if sat not in specs:
                kind = "link" if anchor.startswith("LNK_") else "hub"
                specs[sat] = {"code": sat, "parent": anchor, "hist": "SCD2", "ma": False, "cdk_legs": [],
                              "role": None, "attrs": [], "kind": kind,
                              "pk_hubs": sorted(links[anchor]["hubs"]) if kind == "link" else [anchor],
                              "pk_col": C.hkey(anchor), "augmented": True}
            spec = specs[sat]
            if spec["parent"] != anchor:
                reg.refuse("augmentation_anchor_conflict", subj, "%s anchored on %s earlier; this row "
                           "says %s" % (sat, spec["parent"], anchor), "mapper")
                continue
            if a.get("multi_active"):
                for leg in [x.strip() for x in (a.get("child_key") or "").split("+") if x.strip()] + \
                        [c.get("name") or c.get("leg") for c in (a.get("child_key_components") or [])
                         if c.get("name") or c.get("leg")]:
                    if leg not in spec["cdk_legs"]:
                        spec["cdk_legs"].append(leg)
                        spec["ma"] = True
        else:
            continue

        if subj in unruled:
            reg.refuse("claim_applicant_unruled", subj, prof["directives"]["withheld_unruled"]["why"],
                       "source owner", satellite=sat)
            continue
        if blk.get("redundant_of"):
            withheld.append({"table": table, "column": col, "satellite": sat, "attribute": attr,
                             "instance": blk.get("instance"), "redundant_of": blk.get("redundant_of")})
            dropped["redundant_of"] += 1
            continue
        if spec.get("unbuildable"):
            reg.refuse("satellite_unbuildable", subj, spec["unbuildable"], "modeller", satellite=sat)
            continue
        if not isinstance(rk, dict):
            reg.refuse("no_resolved_key_object_on_anchored_block", subj, "nothing to key from", "mapper",
                       satellite=sat)
            continue
        if not (rk.get("expression") or rk.get("legs")):
            reg.refuse("key_object_without_expression", subj, "resolved_key object present, every value "
                       "empty (E-7 shell); never keyed on a bare prefix", "source owner", satellite=sat)
            continue
        try:
            legs = legs_of(rk, spec)
            for e in legs.values():
                dry(table, e)
        except S.Unresolvable as ex:
            reg.refuse("key_not_emittable", subj, str(ex), "mapper", satellite=sat)
            continue
        if spec["kind"] in ("link", "role"):
            bad = [h for h, e in legs.items()
                   if hub_forms.get((table, h)) and squash(e) not in hub_forms[(table, h)]]
            if bad:
                reg.refuse("link_leg_not_equal_to_hub_key", subj, "leg(s) %s differ from every key form "
                           "of that hub on this view; a non-joining leg is an empty join, so it is "
                           "withheld rather than reconciled by choosing" % ", ".join(bad), "mapper", satellite=sat)
                continue
        if col.upper() not in {c.upper() for c in T[table]["columns"]}:
            reg.refuse("column_not_on_table", subj, "not in the index's column list", "mapper")
            continue
        leg_specs = {h: {"expr": e, "verdict": None, "dv": None} for h, e in sorted(legs.items())}
        key_text = rk.get("expression") or ""

        cdk, refused = {}, None
        if spec["kind"] == "role":
            cdk = {"Role Type": {"value": spec["role"], "backing": "literal"}}
        elif spec["ma"]:
            want = {l.lower(): l for l in spec["cdk_legs"]}
            pairs = []
            comps = [c for c in (blk.get("child_key_components") or [])
                     if isinstance(c, dict) and (c.get("name") or c.get("leg"))]
            for c in comps:
                nm = c.get("name") or c.get("leg")
                if c.get("expression"):
                    pairs.append((nm, c["expression"], "expression"))      # executable SQL
                elif c.get("value") not in (None, ""):
                    v = str(c["value"])
                    pairs.append((nm, v, "template" if v.startswith("{") else "literal"))
                else:
                    refused = "child-key leg %r offers neither an expression nor a value" % nm
                    break
            if not comps:
                pairs = [(n, v, "template" if v.startswith("{") else "literal")
                         for n, v in split_ckv(blk.get("child_key_value"))]
                # A schema named with no value assigned lands with NULL legs and the grain DECLARED
                # below (the remedy health v5 and maximus health v4 apply, and what the previous
                # Maximus Motor build did) -- it is not refused.
            if refused:
                reg.refuse("child_key_unassigned", subj, refused, "mapper", satellite=sat)
                continue
            got = {l: None for l in spec["cdk_legs"]}
            for name, val, backing in pairs:
                leg = want.get((name or "").strip().lower())
                if not leg:
                    continue
                try:
                    S.render_ck_value(val, backing, S.Renderer(table, policy), key_text)
                    got[leg] = {"value": val, "backing": backing}
                except S.Unresolvable as ex:
                    reg.refuse("child_key_leg_unresolved", subj, "%s: %s; landed NULL, grain DECLARED" % (leg, ex),
                               "mapper", satellite=sat, landed=True)
            miss = [l for l, x in got.items() if x is None]
            if miss:
                reg.refuse("child_key_leg_unresolved", subj, "no value for leg(s) %s; landed NULL, grain "
                           "DECLARED" % ", ".join(miss), "mapper", satellite=sat, landed=True)
            cdk = got
        if "keyed at interest" in (rk.get("note") or ""):
            interest[sat].append(subj)
        feeds.append({"track": track, "sat": sat, "table": table, "column": col, "attribute": attr,
                      "instance": blk.get("instance"), "legs": leg_specs, "key_text": key_text, "cdk": cdk})

    # ---- G-3: state the single writer emitted for every single-active multi-writer group
    groups = collections.defaultdict(list)
    for f in feeds:
        if not specs[f["sat"]]["ma"]:
            groups[(f["table"], f["sat"], f["attribute"], f["instance"],
                    tuple(sorted((h, l["expr"]) for h, l in f["legs"].items())))].append(f["column"])
    for w in withheld:
        for k in groups:
            if k[:4] == (w["table"], w["satellite"], w["attribute"], w["instance"]):
                w.setdefault("group_writers_emitted", sorted(set(groups[k])))
    decisions = [{"group": "%s | %s | %s | %s" % k[:4], "emitted": sorted(set(v)),
                  "withheld": sorted(w["column"] for w in withheld if (w["table"], w["satellite"], w["attribute"],
                                                                       w["instance"]) == k[:4])}
                 for k, v in sorted(groups.items(), key=lambda kv: str(kv[0])) if len(set(v)) > 1 or any(
                     (w["table"], w["satellite"], w["attribute"], w["instance"]) == k[:4] for w in withheld)]
    # A pointer is RESOLVED when its target column lands somewhere on the same table: most pointers
    # here run from an augmentation row to its already-mapped twin, which lives in the standard
    # satellite, so matching only inside the withheld row's own satellite reports a false gap.
    landed_cols = collections.defaultdict(set)
    for f in feeds:
        landed_cols[f["table"]].add(f["column"].upper())
    for w in withheld:
        target = str(w["redundant_of"]).split(".")[-1].strip().upper()
        if not w.get("group_writers_emitted") and target not in landed_cols[w["table"]]:
            reg.refuse("redundant_of_target_not_emitted", "%s.%s" % (w["table"], w["column"]),
                       "withheld as redundant_of %r, but that target lands nowhere on this table; the "
                       "value has no writer" % w["redundant_of"], "mapper", satellite=w["satellite"])

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

    # ---- link candidates: every leg the instance-free hub key on that table (leg identity)
    hubsets = collections.Counter(frozenset(l["hubs"]) for l in d7["links"])
    slot = collections.defaultdict(set)
    for r in rows:
        t = r.get("target") if isinstance(r.get("target"), dict) else {}
        rk = t.get("resolved_key") if isinstance(t.get("resolved_key"), dict) else None
        if (r["outcome"] == "mapped" and rk and (rk.get("hub") or "").startswith("HUB_") and not rk.get("instance")
                and rk.get("expression") and not rk["expression"].startswith("LNK(")):
            slot[(r["table_name"], rk["hub"])].add(rk["expression"])
    by_table = collections.defaultdict(dict)
    for (table, hub), forms in slot.items():
        if len(forms) == 1:
            e = next(iter(forms))
            try:
                dry(table, e)
                by_table[table][hub] = {"expr": e, "verdict": None, "dv": None}
            except S.Unresolvable:
                pass
    cands = []
    for table in sorted(by_table):
        hubs = by_table[table]
        for L in d7["links"]:
            hs = L["hubs"]
            if len(hs) < 2 or len(set(hs)) != len(hs) or not set(hs) <= set(hubs):
                continue
            if hubsets[frozenset(hs)] > 1:
                reg.refuse("link_hub_set_ambiguous", "%s on %s" % (L["code"], table),
                           "more than one model link joins exactly these hubs", "modeller")
                continue
            cands.append({"link": L["code"], "table": table, "legs": {h: hubs[h] for h in sorted(hs)},
                          "evidence": "each leg is the instance-free hub key on this table, so the leg is "
                                      "byte-identical to the hub key (BUILD_INSTRUCTIONS s3, link legs)"})

    used = {f["sat"] for f in feeds}
    for s, subjects in interest.items():
        if s in used:
            specs[s]["dual_grain_interest_blocks"] = sorted(set(subjects))
    C.write_json("feeds.json", {"feeds": feeds, "sat_specs": {s: specs[s] for s in sorted(used)},
                                "link_candidates": cands, "dropped_by_rule": dict(dropped)})
    C.write_json("single_writer_decisions.json", {"rule": prof["directives"]["two_writers_declared"],
                                                 "groups": decisions, "withheld": withheld})
    C.write_json("register_feeds.json", reg.items)
    print("  feeds: %d (standard %d, augmented %d) over %d satellites; %d link candidates; %d register entries"
          % (len(feeds), sum(f["track"] == "standard" for f in feeds), sum(f["track"] == "augmented" for f in feeds),
             len(used), len(cands), len(reg.items)))
    print("  register by kind:", reg.summary()["by_kind"])
    print("  writer groups stated: %d (withheld %d); dual-grain satellites: %s" % (
        len(decisions), len(withheld), sorted(s for s in used if specs[s].get("dual_grain_interest_blocks"))))


if __name__ == "__main__":
    main()
