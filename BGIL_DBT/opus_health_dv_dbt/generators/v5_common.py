# -*- coding: utf-8 -*-
"""Shared plumbing for the v5 generators: pinned inputs, naming, the refusal register, writing.

Mechanism lives here and in the other generators; every per-project fact lives in
build_profile.json. Nothing in this file names a satellite, a table or a count.
"""
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

STAGING_DIR = os.path.join(MODELS, "staging", "health")
STD = os.path.join(MODELS, "automate_dv", "standard")
AUG = os.path.join(MODELS, "automate_dv", "augmented")
DIRS = {
    "staging": STAGING_DIR,
    "stitched": os.path.join(STD, "stitched"),
    "std_staging": os.path.join(STD, "staging"),
    "hubs": os.path.join(STD, "hubs"),
    "links": os.path.join(STD, "links"),
    "satellites": os.path.join(STD, "satellites"),
    "references": os.path.join(STD, "references"),
    "aug_staging": os.path.join(AUG, "staging"),
    "aug_satellites": os.path.join(AUG, "satellites"),
}

LEGACY_RUN = "opus_health_legacy_v4"


def profile():
    return json.load(io.open(PROFILE_PATH, encoding="utf-8"))


def md5(path):
    h = hashlib.md5()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def pinned(rel):
    """Return the absolute path of a pinned input after asserting its md5. Refuse on mismatch."""
    pins = profile()["inputs_pinned"]["files"]
    p = os.path.join(DEV, *rel.split("/"))
    got = md5(p)
    if got != pins[rel]:
        raise SystemExit("PINNED INPUT MOVED: %s is md5 %s, pinned %s. The build reads only the "
                         "inputs the previous build used; refusing rather than reading a different "
                         "map." % (rel, got, pins[rel]))
    return p


def jload(p):
    return json.load(io.open(p, encoding="utf-8"))


_CACHE = {}


def map_rows():
    """Every map row from both pinned contracts, with source_run present on all of them."""
    if "rows" not in _CACHE:
        prof = profile()
        rows = []
        m1 = jload(pinned("SourceMapping_Skill/Health Consolidated/outputs/04_column_map.json"))
        rows.extend(m1["columns"])
        m3 = jload(pinned("SourceMapping_Skill/OPUS Health Delta 3/outputs/04_column_map.json"))
        lab = prof["inputs_pinned"]["delta3_run_label"]
        for r in m3["columns"]:
            if r.get("source_run"):
                raise SystemExit("delta 3 row already carries source_run; the stamping rule no "
                                 "longer holds and must be re-derived")
            r = dict(r)
            r["source_run"] = lab
            rows.append(r)
        pinned("SourceMapping_Skill/OPUS Health Delta 3/outputs/08_handoff_facts.json")
        _CACHE["rows"] = rows
    return _CACHE["rows"]


def tables_index_d3():
    if "ti" not in _CACHE:
        ti = jload(pinned("SourceMapping_Skill/OPUS Health Delta 3/outputs/00_tables_index.json"))
        _CACHE["ti"] = {t["table_name"]: [c["name"] for c in t["columns"]] for t in ti["tables"]}
    return _CACHE["ti"]


def model():
    if "d7" not in _CACHE:
        txt = io.open(pinned("Health_DBTModel/data_7.js"), encoding="utf-8").read()
        _CACHE["d7"] = json.loads(txt[txt.index("{"):].rstrip().rstrip(";"))
    return _CACHE["d7"]


# --------------------------------------------------------------------------------- naming

def upper_snake(s):
    s = re.sub(r"[^A-Za-z0-9]+", "_", s or "").strip("_").upper()
    if not s:
        raise ValueError("empty name")
    if s[0].isdigit():
        s = "N_" + s
    if s in SNOWFLAKE_RESERVED:
        s = s + "_VALUE"
    return s


def lower_snake(s):
    return upper_snake(s).lower()


def short(code):
    """HUB_PARTY -> PARTY, LNK_POLICY_PARTY -> POLICY_PARTY, SAT_X -> X."""
    for p in ("HUB_", "LNK_", "SAT_"):
        if code.startswith(p):
            return code[len(p):]
    raise ValueError(code)


def hkey(code):
    return short(code) + "_HKEY"


def bk_col(hub, leg_no=1):
    return short(hub) + "_BK" + ("" if leg_no == 1 else "_%d" % leg_no)


def source_alias(col):
    """Staging alias of a source column. Lower-case; anything else is refused upstream."""
    return col.lower()


SNOWFLAKE_RESERVED = set("""ACCOUNT ALL ALTER AND ANY AS BETWEEN BY CASE CAST CHECK COLUMN CONNECT
CONNECTION CONSTRAINT CREATE CROSS CURRENT CURRENT_DATE CURRENT_TIME CURRENT_TIMESTAMP CURRENT_USER
DATABASE DELETE DISTINCT DROP ELSE EXISTS FALSE FOLLOWING FOR FROM FULL GRANT GROUP GSCLUSTER
HAVING ILIKE IN INCREMENT INNER INSERT INTERSECT INTO IS ISSUE JOIN LATERAL LEFT LIKE LOCALTIME
LOCALTIMESTAMP MINUS NATURAL NOT NULL OF ON OR ORDER ORGANIZATION QUALIFY REGEXP REVOKE RIGHT RLIKE
ROW ROWS SAMPLE SCHEMA SELECT SET SOME START TABLE TABLESAMPLE THEN TO TRIGGER TRUE TRY_CAST UNION
UNIQUE UPDATE USING VALUES VIEW WHEN WHENEVER WHERE WITH""".split())


# ------------------------------------------------------------------------- refusal register

class Register(object):
    """Everything REFUSED rather than defaulted, each with whose call it is."""

    def __init__(self):
        self.items = []

    def refuse(self, kind, subject, why, whose_call, **extra):
        e = {"kind": kind, "subject": subject, "why": why, "whose_call": whose_call}
        e.update(extra)
        self.items.append(e)

    def summary(self):
        return {
            "count": len(self.items),
            "by_kind": dict(sorted(collections.Counter(i["kind"] for i in self.items).items())),
            "by_whose_call": dict(sorted(collections.Counter(i["whose_call"]
                                                             for i in self.items).items())),
        }


# --------------------------------------------------------------------------------- writing

def write_json(name, obj):
    os.makedirs(REPORTS, exist_ok=True)
    io.open(os.path.join(REPORTS, name), "w", encoding="utf-8", newline="\n").write(
        json.dumps(obj, indent=1, ensure_ascii=False, sort_keys=False) + "\n")


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
    """Delete every generated .sql (and the sources yml) so a build always starts from empty.
    Files, not directories: OneDrive holds directory handles open."""
    for root, _d, files in os.walk(MODELS):
        for f in files:
            if f.endswith(".sql") or f.endswith(".yml"):
                os.remove(os.path.join(root, f))
    for root, _d, files in os.walk(MODELS):
        left = [f for f in files if f.endswith(".sql")]
        if left:
            raise AssertionError("wipe left models behind in %s" % root)
