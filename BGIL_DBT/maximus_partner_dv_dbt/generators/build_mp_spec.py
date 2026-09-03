# -*- coding: utf-8 -*-
"""maximus_partner: 04_column_map.json -> _mp_spec.json, the one input every generator reads.

Per (view, anchor) the map states ONE key rule, and per (view, satellite) the payload and any
child key. That is a cleaner shape than travel's per-column rules, so there is no worksheet to
overlay -- the map is the whole key layer.

Satellite contracts come from partner_dv_dbt wherever it already builds the satellite: we write
ITS physical table, so grain, src_pk and src_cdk are not ours to choose.
"""
import collections
import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mp_names as N
import mp_keyrules as K

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
SRC = os.path.join(ROOT, "maximum_partner")
SIBLING = os.path.join(ROOT, "partner_dv_dbt")

# ---- the sibling's contracts -------------------------------------------------------------
SIB = {}
for f in glob.glob(os.path.join(SIBLING, "models", "automate_dv", "*", "satellites", "*.sql")):
    t = open(f, encoding="utf-8").read()
    pk = re.search(r"src_pk:\s*'([A-Z0-9_]+)'", t)
    cd = re.search(r"src_cdk:\s*\n((?:\s+-\s*'[^']+'\n)+)", t)
    SIB[os.path.basename(f)[:-4].upper()] = {
        "pk": pk.group(1) if pk else None,
        "ma": "automate_dv.ma_sat" in t,
        "cdk": re.findall(r"-\s*'([^']+)'", cd.group(1)) if cd else [],
    }
HUB_PK = {}
for f in glob.glob(os.path.join(SIBLING, "models", "automate_dv", "*", "hubs", "*.sql")):
    t = open(f, encoding="utf-8").read()
    pk = re.search(r"src_pk:\s*'([A-Z0-9_]+)'", t)
    if pk:
        HUB_PK["HUB_" + os.path.basename(f)[4:-4].upper()] = pk.group(1)

# Child keys the mapper named in prose rather than in the map, from PARTNER_PREEMPTIVE_ANSWERS.md.
#
# Build-ahead #1 (`declared_child_key_unsourced`): the model keys directors on DIN Number and the
# source carries no DIN, so the directive is "key the 11 officer/signatory rows on the officer ROLE
# token (AUTHORISED_SIGNATORY / MEDICAL_DIRECTOR / ...) with DIN null, one holder per role. When
# DIN is exposed it re-keys these rows at load -- a re-key, not a rebuild. Do not block."
#
# Every one of those 11 columns already carries its role token as `child_key_value`; only the child
# key's NAME was missing, and 'Person Role' is the satellite's own canonical attribute for it.
BUILD_AHEAD_CK = {"SAT_PARTY_ORG_DIRECTORS": "Person Role"}

# A satellite's child key is a property of the MODEL, so a satellite partner_dv_dbt does not build
# may still be built by another OPUS LOB. Consulted ONLY as a fallback, and never over partner's
# own contract. Longest cdk wins where two LOBs disagree on how many parts it has.
CROSS_LOB = {}
for other in ("health_dv_dbt", "travel_dv_dbt", "motor_dv_dbt"):
    for f in glob.glob(os.path.join(ROOT, other, "models", "automate_dv", "*", "satellites",
                                    "*.sql")):
        t = open(f, encoding="utf-8").read()
        cd = re.search(r"src_cdk:\s*\n((?:\s+-\s*'[^']+'\n)+)", t)
        if not cd:
            continue
        s_ = os.path.basename(f)[:-4].upper()
        got = re.findall(r"-\s*'([^']+)'", cd.group(1))
        if len(got) > len(CROSS_LOB.get(s_, [])):
            CROSS_LOB[s_] = got

cols = json.load(open(os.path.join(SRC, "04_column_map.json"), encoding="utf-8"))["columns"]

spec = collections.defaultdict(lambda: {"keys": {}, "sats": {}, "all_cols": set(), "addr": {},
                                        "model": None})
for c in cols:
    spec[c["table_name"]]["all_cols"].add(c["column_name"])
for t, v in spec.items():
    v["model"] = N.model_name(t)

n_pay = collections.Counter()
CANDIDATES = collections.defaultdict(list)   # (view, anchor) -> [(tier, rule), ...]
for c in cols:
    t = c.get("target") or {}
    tbl = c["table_name"]
    v = spec[tbl]
    anchor = t.get("anchor")
    if not anchor:
        continue

    # ---- candidate key rules for this (view, anchor). COLLECT them all and choose after the
    # loop: the rule is stated on whichever column the mapper happened to annotate, so taking the
    # first column's value and locking it in left 6 of 22 keys looking unstated when the map
    # states every one of them.
    if t.get("key_derivation"):
        CANDIDATES[(tbl, anchor)].append((t.get("key_tier"), t["key_derivation"]))
    v["keys"].setdefault(anchor, {"tier": None, "rule": None})

    if t.get("kind") != "satellite_attribute" or not t.get("satellite"):
        continue
    if c.get("outcome") != "mapped":
        continue

    s = t["satellite"]
    e = SIB.get(s.upper())
    base = re.sub(r"^(HUB|LNK)_", "", anchor)
    rec = v["sats"].setdefault(s, {
        "anchor": anchor,
        # a satellite partner_dv_dbt already builds keeps ITS contract
        "src_pk": (e["pk"] if e and e["pk"] else HUB_PK.get(anchor, f"{base}_HKEY")),
        "ma": bool(e and e["ma"]),
        "cdk": list(e["cdk"]) if e else [],
        "payload": collections.defaultdict(list),
    })
    attr = t.get("attribute")
    if not attr:
        continue
    rec["payload"][attr].append({
        "col": c["column_name"],
        "child_key_value": t.get("child_key_value"),
        "instance": t.get("instance"),
        "redundant_of": t.get("redundant_of"),
    })
    n_pay["mapped payload columns"] += 1

    # the address family, for the tier-4 content hash
    if s.upper() == "SAT_COMMON_ADDRESS":
        v["addr"][N.attr_col(attr)] = c["column_name"]

# ---- resolve each (view, anchor) key: the first candidate that is a HUB rule, not a child-key
# ruling. A child-key ruling says nothing about how the hub is keyed -- letting one through is what
# cost travel a whole round.
for (tbl, anchor), cands in CANDIDATES.items():
    hub = [(ti, r) for ti, r in cands if not K.is_child_key_tier(ti, r)]
    if hub:
        spec[tbl]["keys"][anchor] = {"tier": hub[0][0], "rule": hub[0][1]}

# ---- grain: the map states a child key per (view, satellite) via child_key_value / instance
DERIVED = collections.Counter()
NO_CK = []
for tbl, v in spec.items():
    for s, r in v["sats"].items():
        vals = [x for lst in r["payload"].values() for x in lst
                if (x.get("child_key_value") or x.get("instance"))]

        # The SIBLING'S CONTRACT IS ABSOLUTE for a satellite it already builds -- we write its
        # physical table, so its grain is not ours to change. Deriving a grain here anyway made
        # four of partner's single-active satellites multi-active, which the alignment gate caught.
        if s.upper() in SIB:
            r["ma"] = SIB[s.upper()]["ma"]
            r["cdk"] = list(SIB[s.upper()]["cdk"])
            DERIVED["sibling contract"] += 1
            continue

        if vals:
            # the mapper names the discriminator in the (view, anchor) rule text
            rule = (v["keys"].get(r["anchor"]) or {}).get("rule") or ""
            m = (re.search(r"so ([A-Z][A-Za-z ]+?) =", rule)
                 or re.search(r"named_discriminator:\s*([A-Z_]+)", rule)
                 or re.search(r"child key\s*=\s*([^:)]+)", rule, re.I))
            if not m:
                # The map gives instance VALUES but names no discriminator. A satellite's child key
                # is a property of the MODEL, not of one LOB, so another OPUS build that already
                # carries this satellite is the authoritative source -- health writes
                # SAT_LNK_PARTY_ROLE_CORE on ROLE_CODE + ROLE_SEQUENCE, motor writes
                # SAT_PARTY_DIGITAL_IDENTITY on ACTIVE_SEQUENCE_NUMBER. Rendered in PARTNER's
                # convention, since that is whose table we would write.
                if s.upper() in BUILD_AHEAD_CK:
                    r["cdk"] = N.cdk_cols(BUILD_AHEAD_CK[s.upper()])
                    r["ma"] = True
                    DERIVED["child key from the mapper's build-ahead directive"] += 1
                    continue
                other = CROSS_LOB.get(s.upper())
                if other:
                    r["cdk"] = [N.attr_col(re.sub(r"_CK$", "", c)) for c in other]
                    r["ma"] = True
                    DERIVED["child key from another OPUS build"] += 1
                    continue
                # Naming it after the satellite would INVENT a child key -- that produced
                # PARTYIDENTIFICATION, a column no one asked for. Reported instead.
                NO_CK.append((tbl, s))
                DERIVED["multi-active but no discriminator NAMED (reported)"] += 1
                continue
            r["cdk"] = N.cdk_cols(m.group(1).strip())
            r["ma"] = True
            DERIVED["from the map's discriminator"] += 1
        else:
            DERIVED["single-active"] += 1

out = {t: {"model": v["model"], "keys": v["keys"], "all_cols": sorted(v["all_cols"]),
           "addr": v["addr"],
           "sats": {s: {"anchor": r["anchor"], "src_pk": r["src_pk"], "ma": r["ma"],
                        "cdk": r["cdk"], "payload": {a: l for a, l in r["payload"].items()}}
                    for s, r in v["sats"].items()}}
       for t, v in spec.items()}
json.dump(out, open(os.path.join(SRC, "_mp_spec.json"), "w", encoding="utf-8"), indent=1)

print(f"views                    : {len(out)}")
print(f"(view, satellite) pairs  : {sum(len(v['sats']) for v in out.values())}")
print(f"satellites               : {len({s for v in out.values() for s in v['sats']})}"
      f"  (in partner_dv_dbt: {len({s for v in out.values() for s in v['sats']} & set(SIB))})")
print(f"(view, anchor) keys      : {sum(len(v['keys']) for v in out.values())}")
print(f"payload columns          : {n_pay['mapped payload columns']}")
print(f"grain                    : {dict(DERIVED)}")
for tbl, s_ in NO_CK:
    print(f"  !! {N.model_name(tbl)[:24]:26s} {s_:36s} multi-active but the map names no child key")
