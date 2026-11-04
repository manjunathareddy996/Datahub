# -*- coding: utf-8 -*-
"""Bundle intake for Maximus Health V3 -- ROUND 2. Every file selected BY DIGEST.

WHY THIS MODULE EXISTS SEPARATELY FROM THE PROFILE
build_profile.json was written against the ROUND-1 map (md5 fce40feb..., 7,323,498 b).
That map was superseded mid-build and is now 04_column_map.pre_r1fix1.json -- a
NON-INPUT. The round-2 map is pinned here EXPLICITLY, with both algorithms and the
byte count, because the profile's own digest table is stale and a build that
silently relaxed its digest assertion would have disabled the one guard that
caught the supersession.

THE RE-ISSUE IS PURELY ADDITIVE, AND THAT IS ASSERTED HERE, NOT ASSUMED.
assert_additive() re-derives the proof from the two files on disk:
    strip(round2, "directive_kind") == round1     ->  True
UNIT = the whole JSON object; POPULATION = the entire map file; MATCHER = canonical
json.dumps(sort_keys=True) equality. The round-1 file is read for THIS PROOF ONLY
and never as a build input; the proof is what licenses adopting one new field
instead of re-deriving the profile.

PRIOR REVISIONS ARE NEVER AN INPUT. 04_column_map.pre_crossrunenc.json is
7,142,978 bytes -- byte-identical in SIZE to the delivered V2 map -- so a path slip
onto it is completely silent and only a digest can see it.
"""
import hashlib
import json
import os
import re

# ---------------------------------------------------------------- the pin

BUNDLE_ROOT = (r"C:\Users\kamaljeet.singh\OneDrive - Crisp Analytics Private Limited"
               r"\Documents\dev\SourceMapping_Skill\Maximum Health Mapping V3\outputs")

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
REPO = os.path.dirname(PROJECT)

# Round-2, verified on disk in BOTH algorithms before and after every run.
ROUND2 = {
    "04_column_map.json": {
        "bytes": 7325889,
        "md5": "f3f1fd8284b4aac8f10ef216e3dcf87d",
        "sha256": "8dfe93f59a3cbc757df3ff46ab7ea83e5157aa45e44d8696882a8d7ce85d944d",
    },
    # Unchanged by the re-issue, so the round-1 declared digests still hold.
    "00_tables_index.json": {
        "bytes": 3170812,
        "md5": "0a138c93e9bfd8731412e6a9cef09cb9",
        "sha256": "85de48c5c15a62d745a3bda2792b708559031b848a289bf045bc19812caba171",
    },
    # Re-issued. The coordinator supplied MD5 prefixes; both algorithms recomputed here.
    "09_validator_findings.json": {
        "bytes": 81830,
        "md5": "f768825645e297f1c9e640c907fd1c63",
        "sha256": "439dcde8f1325276416ea4ce373dc8faf6e482a7b1bb69117ead1cd22c0f08b6",
        "md5_prefix_declared": "f768825645",
        "digest_provenance_note": "The coordinator supplied a 10-hex MD5 PREFIX. Both full algorithms were RECOMPUTED from the bytes on disk and the prefix was checked against the measurement -- a digest is never reconstructed from a prefix.",
    },
}

# data_7.js -- the canonical model, unchanged by the re-issue.
MODEL_DIGEST = {
    "bytes": 761990,
    "md5": "082b92d7650cf4e192b6e9bb931cdc7e",
    "sha256": "f77379da67f732393d06eb5d505734b82d8f9d40fb9a8287626cad865b157978",
}

ROUND1_MAP_SUPERSEDED = {
    "file": "04_column_map.pre_r1fix1.json",
    "bytes": 7323498,
    "md5": "fce40feba2b9326690b8f862d780f06e",
    "status_token": "NON_INPUT_PROOF_ONLY",
}

PATH_SLIP_HAZARD = {
    "file": "04_column_map.pre_crossrunenc.json",
    "bytes": 7142978,
    "note": "byte-identical in SIZE to the delivered V2 map; a path slip is SILENT",
}

_CACHE = {}


def _digests(path):
    with open(path, "rb") as fh:
        raw = fh.read()
    return ({"bytes": len(raw),
             "md5": hashlib.md5(raw).hexdigest(),
             "sha256": hashlib.sha256(raw).hexdigest()}, raw)


def verify(name):
    """Verify one pinned bundle file and return (digests, raw bytes)."""
    want = ROUND2.get(name)
    if want is None:
        raise AssertionError(
            "%s is not pinned in ROUND2; refusing to read a bundle file blind. Select by "
            "DIGEST, never by filename." % name)
    path = os.path.join(BUNDLE_ROOT, name)
    if not os.path.isfile(path):
        raise AssertionError("pinned bundle file is ABSENT: %s" % path)
    got, raw = _digests(path)
    algs = ("bytes", "md5") if want.get("verify_token") == "MD5_ONLY" \
        else ("bytes", "md5", "sha256")
    for k in algs:
        if got[k] != want[k]:
            raise AssertionError(
                "DIGEST MISMATCH on %s: %s is %r, pinned %r.\n"
                "The map is selected by DIGEST, never by filename: %s is %d bytes, "
                "byte-identical in SIZE to the delivered V2 map, so a path slip is silent. "
                "STOP."
                % (name, k, got[k], want[k], PATH_SLIP_HAZARD["file"],
                   PATH_SLIP_HAZARD["bytes"]))
    return got, raw


def verify_all():
    """Verify every pinned input. Called before AND after the build."""
    out = {}
    for name in sorted(ROUND2):
        got, _ = verify(name)
        out[name] = got
    out["data_7.js"] = model_digest()
    return out


def model_path():
    p = os.path.join(REPO, "data_7.js")
    if not os.path.isfile(p):
        raise AssertionError("data_7.js not found at %s" % p)
    return p


def model_digest():
    got, _ = _digests(model_path())
    for k in ("bytes", "md5", "sha256"):
        if got[k] != MODEL_DIGEST[k]:
            raise AssertionError("DIGEST MISMATCH on data_7.js: %s is %r, pinned %r"
                                 % (k, got[k], MODEL_DIGEST[k]))
    return got


def column_map():
    if "map" not in _CACHE:
        _, raw = verify("04_column_map.json")
        _CACHE["map"] = json.loads(raw.decode("utf-8"))
    return _CACHE["map"]


def tables_index():
    if "idx" not in _CACHE:
        _, raw = verify("00_tables_index.json")
        _CACHE["idx"] = json.loads(raw.decode("utf-8"))
    return _CACHE["idx"]


def validator_findings():
    if "vf" not in _CACHE:
        _, raw = verify("09_validator_findings.json")
        _CACHE["vf"] = json.loads(raw.decode("utf-8"))
    return _CACHE["vf"]


def model():
    """data_7.js -- 'window.MODEL={...}'. Parsed, never regex-scraped for facts."""
    if "model" not in _CACHE:
        model_digest()
        txt = open(model_path(), encoding="utf-8").read().strip()
        txt = re.sub(r"^window\.MODEL\s*=\s*", "", txt).rstrip().rstrip(";")
        _CACHE["model"] = json.loads(txt)
    return _CACHE["model"]


# ---------------------------------------------------- the additivity proof

def _strip_field(obj, field):
    if isinstance(obj, dict):
        return {k: _strip_field(v, field) for k, v in obj.items() if k != field}
    if isinstance(obj, list):
        return [_strip_field(x, field) for x in obj]
    return obj


def assert_additive(field="directive_kind"):
    """Re-derive the re-issue proof rather than relaying it.

    The round-1 map is opened HERE AND NOWHERE ELSE, purely to discharge this
    proof. If the proof fails, the re-issue is NOT purely additive and the whole
    profile must be re-derived by stage 0 rather than patched here.
    """
    r1 = os.path.join(BUNDLE_ROOT, ROUND1_MAP_SUPERSEDED["file"])
    if not os.path.isfile(r1):
        return {"proof": "NOT_RUN", "reason": "round-1 snapshot absent from the bundle",
                "field": field}
    got, raw1 = _digests(r1)
    if got["md5"] != ROUND1_MAP_SUPERSEDED["md5"]:
        raise AssertionError(
            "the round-1 snapshot %s does not carry the digest it is supposed to (md5 %s != %s), "
            "so it cannot discharge the additivity proof"
            % (ROUND1_MAP_SUPERSEDED["file"], got["md5"], ROUND1_MAP_SUPERSEDED["md5"]))
    old = json.loads(raw1.decode("utf-8"))
    new = column_map()
    identical = (json.dumps(_strip_field(new, field), sort_keys=True)
                 == json.dumps(old, sort_keys=True))
    if not identical:
        raise AssertionError(
            "ADDITIVITY PROOF FAILED: strip(round2, %r) != round1. The re-issue changed more "
            "than one field, so adopting a single field is NOT sufficient and stage 0 must "
            "re-derive the profile. Stage 1 refuses to guess which other field moved." % field)
    return {
        "proof": "PASS",
        "statement": "strip(round2, '%s') == round1" % field,
        "unit": "the whole JSON object",
        "population": "the entire map file",
        "matcher": "canonical json.dumps(sort_keys=True) string equality",
        "round1_file": ROUND1_MAP_SUPERSEDED["file"],
        "round1_md5": ROUND1_MAP_SUPERSEDED["md5"],
        "round2_md5": ROUND2["04_column_map.json"]["md5"],
        "round1_status": "NON_INPUT -- read for this proof only, never as a build input",
    }


def prior_revisions():
    """Every .pre_* snapshot on disk, enumerated FROM DISK and excluded by name.

    MATCHER: filename contains '.pre_'. Stated because the count has moved three
    times during this engagement (the brief said six, then seven, then eight).
    """
    out = []
    for f in sorted(os.listdir(BUNDLE_ROOT)):
        if ".pre_" in f:
            got, _ = _digests(os.path.join(BUNDLE_ROOT, f))
            out.append({"file": f, "bytes": got["bytes"], "md5": got["md5"],
                        "size_identical_to_v2_map": got["bytes"] == 7142978})
    return out


if __name__ == "__main__":
    print(json.dumps({"verified": verify_all(),
                      "additivity": assert_additive(),
                      "prior_revisions_matcher": "filename contains '.pre_'",
                      "prior_revisions_count": len(prior_revisions()),
                      "prior_revisions": prior_revisions()}, indent=1))
