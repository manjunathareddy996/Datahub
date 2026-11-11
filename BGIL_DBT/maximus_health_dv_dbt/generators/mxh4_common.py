# -*- coding: utf-8 -*-
"""Shared plumbing for the Maximus Health v4 generators: pinned inputs, the shred graph,
naming, the refusal register, writing. Every per-project fact lives in build_profile.json."""
import collections
import hashlib
import io
import json
import os
import re
import sys

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.abspath(os.path.join(HERE, os.pardir))
WORKSPACE = os.path.abspath(os.path.join(PROJECT, os.pardir))
DEV = os.path.abspath(os.path.join(WORKSPACE, os.pardir))
MODELS = os.path.join(PROJECT, "models")
REPORTS = os.path.join(PROJECT, "build_artifacts", "reports")
PROFILE_PATH = os.path.join(PROJECT, "build_profile.json")
LOB = "maximus_health"
STAGING_PREFIX = "stg_mxh__"

STD = os.path.join(MODELS, "automate_dv", "standard")
AUG = os.path.join(MODELS, "automate_dv", "augmented")
DIRS = {
    "staging": os.path.join(MODELS, "staging", LOB),
    "stitched": os.path.join(STD, "stitched"),
    "std_staging": os.path.join(STD, "staging"),
    "hubs": os.path.join(STD, "hubs"),
    "links": os.path.join(STD, "links"),
    "satellites": os.path.join(STD, "satellites"),
    "references": os.path.join(STD, "references"),
    "aug_staging": os.path.join(AUG, "staging"),
    "aug_satellites": os.path.join(AUG, "satellites"),
}
MAP = "SourceMapping_Skill/Maximum Health Mapping V3/outputs/04_column_map.pre_r1fix1.json"
INDEX = "SourceMapping_Skill/Maximum Health Mapping V3/outputs/00_tables_index.json"
DOCS = ["SourceMapping_Skill/Maximum Health Mapping V3/outputs/KEY_FUNCTIONS.pre_r1fix4.md",
        "SourceMapping_Skill/Maximum Health Mapping V3/outputs/BUILD_INSTRUCTIONS_HEALTH_V3.pre_r1fix2.md"]


def profile():
    return json.load(io.open(PROFILE_PATH, encoding="utf-8"))


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def pinned(rel):
    pins = profile()["inputs_pinned"]["files"]
    p = os.path.join(DEV, *rel.split("/"))
    got = md5(p)
    if got != pins[rel]:
        raise SystemExit("PINNED INPUT MOVED: %s is md5 %s, pinned %s. This build reads only the "
                         "mapping v3 was built from; refusing." % (rel, got, pins[rel]))
    return p


def jload(p):
    return json.load(io.open(p, encoding="utf-8"))


_CACHE = {}


def map_rows():
    if "rows" not in _CACHE:
        for d in DOCS:
            pinned(d)
        _CACHE["rows"] = jload(pinned(MAP))["columns"]
    return _CACHE["rows"]


def tables():
    """table -> {'columns': [names], 'parent': parent table or None}"""
    if "ti" not in _CACHE:
        ti = jload(pinned(INDEX))
        _CACHE["ti"] = {t["table_name"]: {
            "columns": [c["name"] for c in t["columns"]],
            "parent": (t.get("shred") or {}).get("parent_table_candidate")} for t in ti["tables"]}
    return _CACHE["ti"]


def ancestors(table):
    """[parent, grandparent, ..., root] from the shred graph."""
    T = tables()
    out, t, seen = [], table, set()
    while T.get(t, {}).get("parent"):
        t = T[t]["parent"]
        if t in seen:
            raise AssertionError("cycle in the shred graph at %s" % t)
        seen.add(t)
        out.append(t)
    return out


def model():
    if "d7" not in _CACHE:
        txt = io.open(pinned("Health_DBTModel/data_7.js"), encoding="utf-8").read()
        _CACHE["d7"] = json.loads(txt[txt.index("{"):].rstrip().rstrip(";"))
    return _CACHE["d7"]


# --------------------------------------------------------------------------------- naming

ABBR = [("maxi_hlth_", ""), ("_vw_data", ""), ("multiset_attribute_attributes", "msa"),
        ("_pivot_vw", "_pv"), ("attributes", "attrs"), ("attribute", "attr"),
        ("member_details", "memd"), ("details", "dtls"), ("authorization", "auth"),
        ("information", "info"), ("questionnaire", "qnr"), ("_claim_detail", "_cd")]


def table_slug(table):
    s = table.lower()
    for a, b in ABBR:
        s = s.replace(a, b)
    s = re.sub(r"_+", "_", s).strip("_")
    if len(s) > 60:
        s = s[:51] + "_" + hashlib.md5(table.encode()).hexdigest()[:8]
    return s


def staging_model(table):
    return STAGING_PREFIX + table_slug(table)


def assert_slugs_injective(names):
    seen = {}
    for t in names:
        s = table_slug(t)
        if s in seen and seen[s] != t:
            raise AssertionError("staging name collision: %s and %s -> %s" % (seen[s], t, s))
        seen[s] = t


def upper_snake(s):
    s = re.sub(r"[^A-Za-z0-9]+", "_", s or "").strip("_").upper()
    if not s:
        raise ValueError("empty name")
    if s[0].isdigit():
        s = "N_" + s
    if s in SNOWFLAKE_RESERVED:
        s = s + "_VALUE"
    return s


def short(code):
    for p in ("HUB_", "LNK_", "SAT_"):
        if code.startswith(p):
            return code[len(p):]
    raise ValueError(code)


def hkey(code):
    return short(code) + "_HKEY"


def bk_col(hub):
    return short(hub) + "_BK"


def source_alias(col):
    """Staging alias of a source column: lower-case, and a reserved word (a real column here is
    named FROM) gets a _col suffix, because `as from` / `t0.from` do not parse. Every reference
    to the column -- in staging, views and stages -- goes through this one function."""
    a = col.lower()
    if a[:1].isdigit():
        return "c_" + a          # a column named 64VB_STATUS cannot be an unquoted identifier
    return a + "_col" if col.upper() in SNOWFLAKE_RESERVED else a


SNOWFLAKE_RESERVED = set("""ACCOUNT ALL ALTER AND ANY AS BETWEEN BY CASE CAST CHECK COLUMN CONNECT
CONNECTION CONSTRAINT CREATE CROSS CURRENT CURRENT_DATE CURRENT_TIME CURRENT_TIMESTAMP CURRENT_USER
DATABASE DELETE DISTINCT DROP ELSE EXISTS FALSE FOLLOWING FOR FROM FULL GRANT GROUP GSCLUSTER
HAVING ILIKE IN INCREMENT INNER INSERT INTERSECT INTO IS ISSUE JOIN LATERAL LEFT LIKE LOCALTIME
LOCALTIMESTAMP MINUS NATURAL NOT NULL OF ON OR ORDER ORGANIZATION QUALIFY REGEXP REVOKE RIGHT RLIKE
ROW ROWS SAMPLE SCHEMA SELECT SET SOME START TABLE TABLESAMPLE THEN TO TRIGGER TRUE TRY_CAST UNION
UNIQUE UPDATE USING VALUES VIEW WHEN WHENEVER WHERE WITH""".split())


class Register(object):
    def __init__(self):
        self.items = []

    def refuse(self, kind, subject, why, whose_call, **extra):
        e = {"kind": kind, "subject": subject, "why": why, "whose_call": whose_call}
        e.update(extra)
        self.items.append(e)

    def summary(self):
        return {"count": len(self.items),
                "by_kind": dict(sorted(collections.Counter(i["kind"] for i in self.items).items())),
                "by_whose_call": dict(sorted(collections.Counter(i["whose_call"]
                                                                 for i in self.items).items()))}


def write_json(name, obj):
    os.makedirs(REPORTS, exist_ok=True)
    io.open(os.path.join(REPORTS, name), "w", encoding="utf-8", newline="\n").write(
        json.dumps(obj, indent=1, ensure_ascii=False) + "\n")


def read_json(name):
    return jload(os.path.join(REPORTS, name))


def write_model(dir_key, name, text):
    d = DIRS[dir_key]
    os.makedirs(d, exist_ok=True)
    p = os.path.join(d, name + ".sql")
    if os.path.exists(p):
        raise AssertionError("model written twice: %s" % p)
    io.open(p, "w", encoding="utf-8", newline="\n").write(text.rstrip("\n") + "\n")
    return p


def write_text(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, "w", encoding="utf-8", newline="\n").write(text.rstrip("\n") + "\n")


def wipe_models():
    for root, _d, files in os.walk(MODELS):
        for f in files:
            if f.endswith(".sql") or f.endswith(".yml"):
                os.remove(os.path.join(root, f))
    for root, _d, files in os.walk(MODELS):
        if any(f.endswith(".sql") for f in files):
            raise AssertionError("wipe left models behind in %s" % root)
