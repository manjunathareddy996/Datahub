# -*- coding: utf-8 -*-
"""HASH-KEY REACHABILITY, inside the build chain. health_consolidated.

WHAT IT ASSERTS
---------------
Every `<X>_HK` a model REFERENCES is either PRODUCED by that model or EXPOSED by a model it
ref()s -- taken to a FIXPOINT over the ref graph, because a stage may be three refs away from the
model that computes the key.

WHY IN THE CHAIN AND NOT IN vault_tools
---------------------------------------
check_internal.py asserts that a column a model DECLARES in src_pk/src_payload is emitted by the
model it names. That is the automate_dv metadata shape. This project emits plain SQL with no
metadata block, so there is nothing for check_internal's declaration reader to read on the key
path: a dangling `HUB_PARTY_HK` would pass it silently. This file closes that hole for THIS layout.

Exit: 0 PASS · 1 FAIL · 2 NOT RUN (nothing examined) · 3 DID NOT COMPLETE.
Four outcomes, four codes: a crash exiting 1 is indistinguishable from a clean FAIL (s1.8).
"""
import collections
import glob
import os
import re
import sys

from hcon_writeguard import PROJECT_ROOT

MODELS = os.path.join(PROJECT_ROOT, "models")

# ---- patterns, authored in THIS FILE (s1.2). Probed in probe() below.
RX_REF = re.compile(r"\{\{\s*ref\(\s*['\"]([A-Za-z0-9_]+)['\"]\s*\)\s*\}\}")
RX_HK_ANY = re.compile(r"\b([A-Z][A-Z0-9_]*_HK)\b")
RX_HK_PRODUCED = re.compile(r"\bas\s+([A-Z][A-Z0-9_]*_HK)\b")
RX_COMMENT = re.compile(r"/\*.*?\*/", re.S)
RX_LINK_FEED = re.compile(r"^(lnk_[a-z0-9_]+?)__([a-z0-9_]+)__([0-9a-f]{6,})$")
RX_HUB_FEED = re.compile(r"^hf_((?:hub|ref)_[a-z0-9_]+?)__([a-z0-9_]+)__([0-9a-f]{6,})$")
RX_REJECT = re.compile(r"^rj_((?:hub|lnk|ref)_[a-z0-9_]+?)__([a-z0-9_]+)__([0-9a-f]{6,})$")
RX_LINE_COMMENT = re.compile(r"--[^\n]*")


def probe():
    """Fire on a real corpus string; stay silent on a near-miss. A pattern that cannot match
    reports a zero indistinguishable from a clean result."""
    cases = [
        (RX_REF, "from {{ ref('stage_hcp_dt_mem') }}", True),
        (RX_REF, "from stage_hcp_dt_mem", False),
        (RX_HK_ANY, "select HUB_PARTY_HK,", True),
        (RX_HK_ANY, "select HUB_PARTY_BK__PART_ID,", False),
        (RX_HK_PRODUCED, "md5(upper('HUB_PARTY|' || (X))) as HUB_PARTY_HK", True),
        (RX_HK_PRODUCED, "select HUB_PARTY_HK,", False),
        (RX_HUB_FEED, "hf_hub_party__hcp_dt_mem__7ad9424f47", True),
        (RX_HUB_FEED, "hub_party", False),
        (RX_LINK_FEED, "lnk_party_role__intermediary__ca6818", True),
        (RX_LINK_FEED, "lnk_party_role", False),
        (RX_REJECT, "rj_hub_claim__bfhl_dtls__c3dabd67b4", True),
        (RX_REJECT, "reject_log", False),
    ]
    for pat, s, want in cases:
        if bool(pat.search(s)) != want:
            raise AssertionError("pattern probe failed: %r on %r (want %r)"
                                 % (pat.pattern, s, want))
    return len(cases)


def strip_comments(text):
    return RX_LINE_COMMENT.sub(" ", RX_COMMENT.sub(" ", text))


def main():
    try:
        n = probe()
        paths = sorted(glob.glob(os.path.join(MODELS, "**", "*.sql"), recursive=True))
        if not paths:
            print("[reachability] NOT RUN -- no .sql under models/. A gate reporting PASS on an "
                  "empty population is worse than no gate.")
            return 2
        body, refs, produced, referenced = {}, {}, {}, {}
        for p in paths:
            name = os.path.basename(p)[:-4]
            with open(p, encoding="utf-8") as fh:
                raw = fh.read()
            code = strip_comments(raw)
            body[name] = code
            refs[name] = set(RX_REF.findall(code))
            produced[name] = set(RX_HK_PRODUCED.findall(code))
            referenced[name] = set(RX_HK_ANY.findall(code))

        dangling_ref = {m: sorted(r - set(body)) for m, r in refs.items() if r - set(body)}

        # FIXPOINT: a model exposes every key it produces plus every key its refs expose.
        exposed = {m: set(produced[m]) for m in body}
        for _ in range(len(body) + 1):
            changed = False
            for m in body:
                add = set()
                for r in refs[m]:
                    add |= exposed.get(r, set())
                if not add <= exposed[m]:
                    exposed[m] |= add
                    changed = True
            if not changed:
                break
        else:
            raise AssertionError("ref graph fixpoint did not converge -- there is a cycle")

        unreachable = {}
        for m in body:
            need = referenced[m] - produced[m]
            have = set()
            for r in refs[m]:
                have |= exposed.get(r, set())
            miss = sorted(need - have)
            if miss:
                unreachable[m] = miss

        # ---- FEED CONSUMPTION, BOTH DIRECTIONS
        consumers = collections.defaultdict(list)
        for m in body:
            for r in refs[m]:
                consumers[r].append(m)
        # feed_of: every per-source feed -> the table it belongs to.
        # vault_feed_of: only those feeds whose assembled consumer must be THAT table's loader.
        # A reject model is deliberately consumed by ONE reject_log, not by its table's loader --
        # every rejected key in one place -- so it is excluded from the reverse rule and held to a
        # STRONGER forward rule instead.
        feed_of, vault_feed_of, reject_feeds = {}, {}, []
        for m in body:
            for rx, is_vault in ((RX_HUB_FEED, True), (RX_LINK_FEED, True), (RX_REJECT, False)):
                mo = rx.match(m)
                if mo:
                    feed_of[m] = mo.group(1)
                    if is_vault:
                        vault_feed_of[m] = mo.group(1)
                    else:
                        reject_feeds.append(m)
                    break
        orphan_feeds, double_fed, foreign = [], [], []
        for f, table in sorted(feed_of.items()):
            cs = consumers.get(f, [])
            if len(cs) == 0:
                orphan_feeds.append(f)
            elif len(cs) > 1:
                double_fed.append((f, cs))
        for m in body:
            if m in feed_of:
                continue
            for r in refs[m]:
                if r in vault_feed_of and vault_feed_of[r] != m:
                    foreign.append((m, r))
        # and the stronger rule for reject feeds: the one consumer must be reject_log
        wrong_reject_consumer = []
        for f in reject_feeds:
            cs = consumers.get(f, [])
            if cs and cs != ["reject_log"]:
                wrong_reject_consumer.append((f, cs))

        dup = [k for k, v in collections.Counter(os.path.basename(p) for p in paths).items()
               if v > 1]
        print("[reachability] %d pattern probes passed; %d models examined" % (n, len(paths)))
        print("[reachability] hash keys produced: %d distinct; referenced: %d distinct"
              % (len({k for v in produced.values() for k in v}),
                 len({k for v in referenced.values() for k in v})))
        if dup:
            print("[reachability] FAIL duplicate model names: %s" % dup)
        for m, miss in sorted(dangling_ref.items())[:10]:
            print("[reachability] FAIL %s ref()s a model that does not exist: %s" % (m, miss))
        for m, miss in sorted(unreachable.items())[:20]:
            print("[reachability] FAIL %s references %s, produced neither locally nor by any "
                  "ref()ed model (fixpoint)" % (m, miss))
        print("[reachability] per-source feed models: %d; each must be consumed by EXACTLY ONE "
              "assembled loader" % len(feed_of))
        for f in orphan_feeds[:10]:
            print("[reachability] FAIL feed %s is consumed by NO loader -- it was overwritten or "
                  "never wired up, and nothing else can see that" % f)
        for f, cs in double_fed[:10]:
            print("[reachability] FAIL feed %s is consumed by %d loaders: %s -- its rows would "
                  "load twice" % (f, len(cs), cs))
        for m, r in foreign[:10]:
            print("[reachability] FAIL loader %s ref()s %s, which is a feed of %s -- foreign rows "
                  "under its own key" % (m, r, feed_of[r]))
        for f, cs in wrong_reject_consumer[:10]:
            print("[reachability] FAIL reject feed %s is consumed by %s, not by reject_log -- "
                  "every rejected key must land in ONE place" % (f, cs))
        bad = (len(dup) + len(dangling_ref) + len(unreachable) + len(orphan_feeds)
               + len(double_fed) + len(foreign) + len(wrong_reject_consumer))
        if bad:
            print("[reachability] RESULT FAIL -- %d duplicate name(s), %d dangling ref(s), "
                  "%d unreachable hash key(s), %d orphan feed(s), %d double-fed, %d foreign feed "
                  "reference(s), %d reject feed(s) with the wrong consumer"
                  % (len(dup), len(dangling_ref), len(unreachable), len(orphan_feeds),
                     len(double_fed), len(foreign), len(wrong_reject_consumer)))
            return 1
        print("[reachability] RESULT PASS -- every <X>_HK referenced in %d models is produced "
              "locally or exposed by a ref()ed model, at fixpoint over the ref graph; 0 dangling "
              "refs; 0 duplicate model names; all %d per-source feeds consumed by EXACTLY ONE "
              "assembled loader (%d vault feeds, each by its OWN table's loader, and %d reject "
              "feeds, each by reject_log) -- asserted in BOTH directions"
              % (len(paths), len(feed_of), len(vault_feed_of), len(reject_feeds)))
        return 0
    except Exception as exc:                       # noqa -- four outcomes need four codes
        print("[reachability] DID NOT COMPLETE: %s: %s" % (type(exc).__name__, exc))
        return 3


if __name__ == "__main__":
    sys.exit(main())
