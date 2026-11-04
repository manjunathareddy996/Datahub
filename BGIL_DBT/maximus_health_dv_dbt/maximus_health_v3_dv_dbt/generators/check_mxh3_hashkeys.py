# -*- coding: utf-8 -*-
"""IN-CHAIN invariants over the emitted models. Sibling-free, no gate required.

TWO DEFECTS FROM THE SIBLING BUILD THAT MUST NOT RECUR:

1. HASH-KEY REACHABILITY. Four sibling satellites filtered on an anchor hash key
   they never produced and could not compile. Every <X>_HK a model references must
   be PRODUCED in that model or EXPOSED by a model it ref()s -- resolved by a
   FIXPOINT over the ref graph, because exposure is transitive: a satellite reads a
   stage which reads a resolver, and automate_dv.stage()-style pass-through means
   a model emits everything its source emits.

2. PER-SOURCE -> ASSEMBLED COMPLETENESS, ASSERTED IN BOTH DIRECTIONS. The sibling
   unioned 72 hub feeds into 14 hubs and 4 per-source link feeds into ZERO links,
   because the link layer had no completeness invariant. So:
     forward : every per-source feed is consumed by exactly ONE assembled model
     backward: every assembled model consumes at least one feed, and consumes
               only feeds that exist

This runs INSIDE the build chain, not only in a proof suite.
"""
import collections
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
MODELS = os.path.join(PROJECT, "models")

REF = re.compile(r"\{\{\s*ref\(\s*'([^']+)'\s*\)\s*\}\}")
ALIAS = re.compile(r"\bas\s+([A-Za-z_][A-Za-z0-9_$]*)", re.I)
HKREF = re.compile(r"\b([A-Za-z_][A-Za-z0-9_]*_HK)\b")


def _strip(sql):
    s = re.sub(r"/\*.*?\*/", " ", sql, flags=re.S)
    s = re.sub(r"(?m)--[^\n]*", " ", s)
    return re.sub(r"'[^']*'", " ", s)


def load():
    out = {}
    for p in glob.glob(os.path.join(MODELS, "**", "*.sql"), recursive=True):
        name = os.path.basename(p)[:-4]
        with open(p, encoding="utf-8") as fh:
            out[name] = {"path": p, "sql": fh.read(),
                         "dir": os.path.relpath(os.path.dirname(p), MODELS)
                         .replace("\\", "/")}
    for n, d in out.items():
        code = _strip(d["sql"])
        d["code"] = code
        d["refs"] = sorted(set(REF.findall(d["sql"])))
        d["emits"] = {a.upper() for a in ALIAS.findall(code)}
        d["hk_emitted"] = {a for a in d["emits"] if a.endswith("_HK")}
        d["hk_referenced"] = set(HKREF.findall(code))
        d["select_star"] = bool(re.search(r"select\s+\*", code, re.I)) or \
            bool(re.search(r"\bsrc\.\*", code, re.I))
    return out


def fixpoint(models):
    """Transitively close what each model EXPOSES through its refs.

    A model that selects * (or src.*) from a ref'd model exposes that model's
    columns too. Without this transitive step every unpivot-fed satellite's
    payload looks unsourced.
    """
    exposed = {n: set(d["emits"]) for n, d in models.items()}
    for _ in range(len(models) + 1):
        changed = False
        for n, d in models.items():
            if not d["select_star"]:
                continue
            for r in d["refs"]:
                if r in exposed and not exposed[r] <= exposed[n]:
                    exposed[n] |= exposed[r]
                    changed = True
        if not changed:
            break
    return exposed


def main():
    models = load()
    if not models:
        print("  NOT RUN -- no .sql under models/. Nothing was examined; this is "
              "neither PASS nor FAIL.")
        return 2
    exposed = fixpoint(models)

    print("models examined               : %d   (population)" % len(models))
    fails = collections.defaultdict(list)

    # ---- 1. hash-key reachability by FIXPOINT
    for n, d in sorted(models.items()):
        for hk in sorted(d["hk_referenced"]):
            if hk in d["hk_emitted"]:
                continue
            if any(hk in exposed.get(r, set()) for r in d["refs"]):
                continue
            fails["1. references an <X>_HK neither produced locally nor exposed by a ref()"]\
                .append("%s -> %s" % (n, hk))

    # ---- 2. dangling refs
    for n, d in sorted(models.items()):
        for r in d["refs"]:
            if r not in models:
                fails["2. dangling ref()"].append("%s -> %s" % (n, r))

    # ---- 3. per-source -> assembled, FORWARD
    feeds = {n for n, d in models.items()
             if d["dir"] in ("vault/hub_feeds", "vault/link_feeds")}
    assembled = {n for n, d in models.items() if d["dir"] in ("vault/hubs", "vault/links")}
    consumed = collections.Counter()
    for n in assembled:
        for r in models[n]["refs"]:
            if r in feeds:
                consumed[r] += 1
    for f in sorted(feeds):
        if consumed[f] == 0:
            fails["3a. per-source feed consumed by NO assembled model"].append(f)
        elif consumed[f] > 1:
            fails["3b. per-source feed consumed by MORE THAN ONE assembled model"]\
                .append("%s x%d" % (f, consumed[f]))

    # ---- 4. per-source -> assembled, BACKWARD
    for a in sorted(assembled):
        got = [r for r in models[a]["refs"] if r in feeds]
        if not got:
            fails["4. assembled model consumes NO per-source feed"].append(a)

    # ---- 5. duplicate model names (dbt requires global uniqueness)
    seen = collections.Counter(os.path.basename(d["path"]) for d in models.values())
    for k, v in seen.items():
        if v > 1:
            fails["5. duplicate model name"].append(k)

    print("hub/link feeds                : %d" % len(feeds))
    print("assembled hubs/links          : %d" % len(assembled))
    print("feeds consumed exactly once   : %d"
          % sum(1 for f in feeds if consumed[f] == 1))

    total = 0
    for label in sorted(fails):
        rows = fails[label]
        total += len(rows)
        print("  FAIL %s: %d" % (label, len(rows)))
        for r in rows[:6]:
            print("        %s" % r)
        if len(rows) > 6:
            print("        ... and %d more" % (len(rows) - 6))
    if not total:
        print("  PASS -- every <X>_HK is produced locally or exposed by a ref() (fixpoint); "
              "every per-source feed is consumed by exactly one assembled model, in both "
              "directions; refs resolve; names unique.")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
