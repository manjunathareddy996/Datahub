# -*- coding: utf-8 -*-
"""HUB FEEDS, HUBS, LINKS, SATELLITES -- the ratified vault. health_consolidated.

THE LOADER STRUCTURE
--------------------
ONE LOADER PER VAULT TABLE. For each of the 62 tables both originals emit, the ONE loader takes
BOTH runs as SEPARATE feeds tagged by RECORD_SOURCE; for the 140 legacy-only and 45 v2-only tables
the loader has a single feed. A loader is built because it HAS A FEED, not because it is in a
sibling's file list (s6.1); a declared table the settled map supplies no column for is DECLARED in
the unresolved register, never emitted as an empty model.

THE BESPOKE LAYER (s6.5, declared in profile.bespoke_layers)
------------------------------------------------------------
`dual_feed_satellite_loader`. No standard s6 layer expresses two INDEPENDENT writers of the SAME
attribute on one satellite row: the standard satellite layer unions feeders that are disjoint by
construction, which is exactly the assumption two runs break. Where both runs write one attribute a
DECLARED SOURCE PRECEDENCE decides, named per attribute in the satellite header. Never a key
change, never RECORD_SOURCE in a key -- either would silently alter grain.

Reads build_artifacts/hcon_spec.json. Never the map.
"""
import collections
import json
import os
import sys

import hcon_keyrules as K
import hcon_names as N
from hcon_writeguard import PROJECT_ROOT, guarded_open, guarded_makedirs

SPEC_PATH = os.path.join(PROJECT_ROOT, "build_artifacts", "hcon_spec.json")
VAULT_DIR = "vault"                 # builder decision BD4; see its one-line switch
MODELS = os.path.join(PROJECT_ROOT, "models")
DIRS = {k: os.path.join(MODELS, VAULT_DIR, k)
        for k in ("hub_feeds", "hubs", "links", "satellites", "refs")}

# ------------------------------------------------- the cross-run carve-out (BD6, overruled twice)
# BD6 said v2-first precedence everywhere, silently. The mapping counterparty overruled the SILENCE
# -- not the precedence. Its first form named 6 zero-overlap hubs and asked for both values to be
# emitted; both halves of that were then withdrawn:
#
#   * "emit both" is WRONG on a single-active attribute -- two writers into one row per key is
#     load-order-dependent and strictly worse than a deterministic precedence. Precedence STAYS.
#   * the OVERLAP COUNT cannot see the hazard AT ANY THRESHOLD. HUB_PARTY's overlap of 3 is
#     IMD_CODE, PART_ID and RM_CODE, ALL INTERMEDIARY-SIDE; on the member/customer population the
#     overlap is ZERO (legacy CLIENT_ID, CUSTOMER_ID, MEMBER_ID, MEMBER_IDENTIFIER, MEMBER_NO
#     against v2 CUST_ID, INSURED_CARD_NO, PATIENT_ID_CARD, PH_ID, PP_ID -- nothing shared). The
#     count is also unstable: collapsing underscores moves it 3 -> 5, because HOSID/HOS_ID and
#     SUB_IMD_CODE/SUBIMD_CODE are one registry under two spellings, and HUB_PARTY is the ONLY
#     object where normalisation moves it.
#
# So the scope is every shared object written by MORE THAN ONE run, chosen on ASYMMETRY: a
# declared conflict is RECOVERABLE, a wrong merge is NOT after load. "More than one", never
# "exactly two": this selector was once `== 2` and a third contract made it DROP the thirteen
# objects fed by all three runs -- the ones with the most cross-run exposure of all.
#
# The carve-out is HEADER-ONLY. It changes no SQL. It NAMES the subordinate writer and its
# registry, so the loss is countable rather than implicit.
# The population this carve-out is KNOWN to cover, from health_consolidated_dv_dbt's own
# BUILD_STATUS.json cross_run_carve_out. A run added to the build can only ever ADD objects written
# by more than one run, never remove one, so a set smaller than this is a selector defect and not a
# finding about the map. Asserted below, because the emptiness guard alone could not see the `== 2`
# selector drop 13 of these 15 when a third contract arrived.
CARVE_OUT_FLOOR = ("HUB_ASSESSMENT", "HUB_CASE", "HUB_CLAIM", "HUB_COVERAGE",
                   "HUB_DISTRIBUTION_CHANNEL", "HUB_DOCUMENT", "HUB_LOCATION", "HUB_ORG_UNIT",
                   "HUB_PARTY", "HUB_POLICY", "HUB_PRODUCT", "HUB_PROPOSAL", "HUB_QUOTE",
                   "HUB_RISK_OBJECT", "LNK_PARTY_ROLE")


def cross_run_shared_objects(spec):
    """Shared-62 hubs and links whose feeds come from MORE THAN ONE run.

    DERIVED, never retyped, and never counted to a fixed number of runs. The test is `>= 2`: with
    `== 2` an object fed by all three runs falls out, which is backwards -- it has MORE cross-run
    exposure, not less.

    LNK_POLICY_PARTY is IN as of the third contract: the settled map supplies only v2 feeds for it,
    so the two-run build had no cross-run precedence to annotate on it, and delta 3 supplies the
    second run that creates one.
    """
    runs = {L["name"]: L["runs_with_feeds"] for L in spec["loaders"]}
    out = {L["code"] for L in spec["loaders"]
           if L["set"] == "shared" and L["kind"] in ("hub", "link")
           and len(runs.get(L["name"], [])) >= 2}
    if not out:
        raise AssertionError("the cross-run shared-object set is empty; the carve-out would "
                             "silently apply to nothing")
    lost = sorted(set(CARVE_OUT_FLOOR) - out)
    if lost:
        raise AssertionError(
            "THE CARVE-OUT SHRANK: %d object(s) carried by health_consolidated_dv_dbt are absent "
            "here: %s. Adding a run cannot remove an object written by more than one run, so this "
            "is a SELECTOR defect, not a finding about the map. The carve-out is the "
            "mapper-ratified declaration that NAMES the subordinate writer in the satellite "
            "header; dropping an object drops that declaration silently."
            % (len(lost), lost))
    return out


CARVE_OUT_NOTE = [
    "   CROSS-RUN RECONCILIATION, DECLARED (carve-out ratified by the mapping counterparty):",
    "   this satellite's anchor is one of the shared objects written by BOTH runs, whose two",
    "   identifier registries are UNRECONCILED. The declared source precedence below is a VALUE",
    "   CHOICE APPLIED TO ROWS THAT MAY REPRESENT TWO UNRECONCILED POPULATIONS -- two writers may",
    "   be describing one entity, or two different parties colliding in one key space, and which",
    "   it is cannot be settled from the map, the model or the SQL.",
    "   WHY THE SCOPE IS EVERY SHARED OBJECT AND NOT A LOW-OVERLAP SUBSET: a hub-level",
    "   business-key-column overlap cannot see the hazard at any threshold. HUB_PARTY's overlap",
    "   of three is IMD_CODE, PART_ID and RM_CODE, all intermediary-side; on the member/customer",
    "   population the overlap is ZERO. The figure is unstable too -- collapsing underscores moves",
    "   it from three to five.",
    "   WHY DECLARE RATHER THAN REFUSE: the choice is made on ASYMMETRY. A DECLARED CONFLICT IS",
    "   RECOVERABLE; A WRONG MERGE IS NOT, AFTER LOAD. That is the justification, not a",
    "   preference.",
    "   The subordinate writer and its registry are NAMED below so the loss is COUNTABLE.",
    "   A load-time assertion in models/assertions/ counts the hash keys actually written by both",
    "   runs. Until it runs, whether the precedence EVER fires is UNKNOWN, not zero.",
]

NAMESPACE_NOTE = [
    "   KEY FORM: md5(upper('%s|' || <business key>)), emitted EXPLICITLY -- no macro computes a",
    "   hash in this build. The namespace is a MEASURED collision guard: opus_health_v2 emits",
    "   md5(upper(HUB_ASSESSMENT_BK__SCRUTINY_NO)) AND md5(upper(HUB_PROPOSAL_BK__SCRUTINY_NO)),",
    "   the same column under two hubs, which collide without it; legacy namespaces 1822 of 1822.",
    "   CRITICAL PRECISION: the namespace separates HUBS, NOT REGISTRIES WITHIN A HUB.",
    "   'HUB_POLICY|' prefixes POLICY_REF and POLICY_NO identically, so it does nothing to keep",
    "   two identifier populations inside one hub apart.",
]

REGISTRY_NOTE = [
    "   REGISTRY RECONCILIATION, UNRESOLVED: unifying the hash form does NOT establish that the",
    "   two runs' identifier spaces denote the same entities. 6 of the 14 shared hubs have ZERO",
    "   business-key-column overlap between the runs. This hub is ONE KEY SPACE over the",
    "   registries enumerated below; a false merge is unrecoverable after load.",
]


def _registries(slots):
    by = collections.defaultdict(set)
    for s in slots:
        by[s["run"]].add(s["bk_column"])
    return {run: sorted(cols) for run, cols in sorted(by.items())}


def _caveat_lines(table):
    c = K.carried_forward_caveat(table)
    if not c:
        return []
    out = ["   CARRIED FORWARD VERBATIM from the original build (s9.8). Reproduced byte-for-byte;",
           "   a paraphrase of a reconciliation risk is a different risk:"]
    for line in c.splitlines():
        out.append("   | " + line.rstrip())
    return out


# ------------------------------------------------------------------ hub feeds and hubs
def render_hub_feed(slot, model_name):
    hk = N.hash_key(slot["vault_table"])
    lines = ["{{ config(materialized='view') }}",
             "/* GENERATED by gen_hcon_vault.py -- models are generated.",
             "   source view : %s   (run: %s)" % (slot["view"], slot["run"]),
             "   target      : %s" % slot["vault_table"],
             "   key slot    : %s" % slot["bk_column"],
             "   key origin  : %s" % slot["origin"],
             "   key tier    : %s" % slot["tier"],
             "   reject class: %s" % (slot["reject_class"] or "(none declared)"),
             "   operands    : %s" % ", ".join(slot["source_columns"])]
    lines += [l % slot["vault_table"] if "%s" in l else l for l in NAMESPACE_NOTE]
    if slot["degenerate_value"] is not None:
        lines += ["   DEGENERATE SENTINEL %r: the WHERE below IS the declared reject predicate."
                  % slot["degenerate_value"],
                  "   A row failing it is diverted to the reject log, never silently dropped."]
    if slot["uses_normalise"]:
        lines.append("   normalise() is UNDEFINED anywhere; carried over verbatim, never "
                     "introduced. UNRESOLVED.")
    lines.append("*/")
    lines += ["", "select",
              "    %s as %s" % (N.hash_expr(slot["vault_table"], slot["bk_column"]), hk),
              "    , %s as %s" % (slot["bk_column"], slot["bk_column"]),
              "    , '%s' as RECORD_SOURCE" % slot["view"],
              "    , '%s' as SOURCE_RUN" % slot["run"],
              "    , current_timestamp() as LOAD_DATETIME",
              "from {{ ref('%s') }}" % N.stage_model(slot["view"]),
              "where (%s) is not null" % slot["expression"]]
    if slot["degenerate_value"] is not None:
        lines.append("  and (%s) <> %s" % (slot["bk_column"],
                                           N.sql_literal(str(slot["degenerate_value"]))))
    return "\n".join(lines) + "\n"


def render_hub(table, slots, feed_models, kind):
    code = table.upper()
    hk = N.hash_key(code)
    runs = sorted({s["run"] for s in slots})
    regs = _registries(slots)
    lines = ["{{ config(materialized='incremental', unique_key='%s') }}" % hk,
             "/* GENERATED by gen_hcon_vault.py -- models are generated.",
             "   %s : %d feed(s) over %d source view(s), %d run(s): %s"
             % (code, len(feed_models), len({s["view"] for s in slots}), len(runs),
                ", ".join(runs)),
             "   LOADER SHAPE: ONE loader for this vault table; each run is a SEPARATE feed",
             "   tagged by RECORD_SOURCE and SOURCE_RUN. RECORD_SOURCE is NEVER in the key."]
    lines += [l % code if "%s" in l else l for l in NAMESPACE_NOTE]
    lines += REGISTRY_NOTE
    for run, cols in regs.items():
        lines.append("     %-24s %d registry/registries: %s" % (run, len(cols), ", ".join(cols)))
    if len(runs) == 1:
        lines.append("   SINGLE-FEED: the settled map supplies columns from ONE run only for this")
        lines.append("   table. Where both originals emit a file of this name, 'shared' is a")
        lines.append("   property of the two FILE SETS, not of the map.")
    lines += _caveat_lines(table)
    lines.append("*/")
    sel = [hk, "BUSINESS_KEY", "RECORD_SOURCE", "SOURCE_RUN", "LOAD_DATETIME"]
    parts = []
    for fm, s in feed_models:
        parts.append("    select %s, %s as BUSINESS_KEY, RECORD_SOURCE, SOURCE_RUN, LOAD_DATETIME\n"
                     "    from {{ ref('%s') }}" % (hk, s["bk_column"], fm))
    lines += ["", "with feeds as (", "\n    union all\n".join(parts), ")", "", "select",
              "    %s," % hk, "    BUSINESS_KEY,",
              "    min(RECORD_SOURCE) as RECORD_SOURCE,",
              "    min(SOURCE_RUN) as SOURCE_RUN,",
              "    min(LOAD_DATETIME) as LOAD_DATETIME",
              "from feeds", "where %s is not null" % hk,
              "group by %s, BUSINESS_KEY" % hk]
    return "\n".join(lines) + "\n"


# ------------------------------------------------------------------ links
def link_legs(slot):
    """The legs of one link slot, and where they came from.

    Returns (legs_dict, origin) or (None, reason) when the legs cannot be established without
    inventing one.
    """
    legs = slot["legs"] or {}
    if legs:
        return legs, "map.resolved_key.legs"
    declared = (K.MODEL_LINKS.get(slot["vault_table"]) or {}).get("hubs") or []
    if len(declared) == 1:
        # data_7.js declares exactly one hub for this link. The recovered business key is that
        # leg's operand. This reproduces the ONE-LEG LINK defect as declared, deliberately.
        return {declared[0]: slot["expression"]}, "data_7.js.links[].hubs"
    if not declared:
        return None, ("data_7.js declares no hubs for %s and the recovered legacy SQL names no "
                      "leg, so there is no leg to build" % slot["vault_table"])
    return None, ("data_7.js declares %d legs for %s (%s) and the recovered legacy SQL supplies "
                  "ONE business key (%s). One key cannot be distributed across %d legs without "
                  "inventing %d of them."
                  % (len(declared), slot["vault_table"], ", ".join(declared),
                     ", ".join(slot["source_columns"]), len(declared), len(declared) - 1))


def render_link_feed(slot, model_name):
    code = slot["vault_table"]
    hk = N.hash_key(code)
    legs, origin = link_legs(slot)
    if legs is None:
        K.refuse("link_legs_not_establishable", satellite=code, view=slot["view"],
                 detail=origin + " REFUSED, not guessed (s5.6).")
        return None
    legcols = []
    for hub in sorted(legs):
        if not legs[hub] or not str(legs[hub]).strip():
            raise AssertionError("EMPTY LINK LEG for %s on %s (s1.6 -- fatal)" % (hub, slot["id"]))
        legcols.append((hub, N.bk_column(hub, slot["source_columns"])))
    lines = ["{{ config(materialized='view') }}",
             "/* GENERATED by gen_hcon_vault.py -- models are generated.",
             "   source view : %s   (run: %s)" % (slot["view"], slot["run"]),
             "   target link : %s" % code,
             "   legs        : %s" % ", ".join("%s <- %s" % (h, c) for h, c in legcols),
             "   leg origin  : %s" % origin,
             "   Each leg is hashed to its OWN hub key with that HUB's namespace, and the link",
             "   key is hashed over the legs, NULL-SAFE PER OPERAND (s5.3): coalescing the",
             "   finished composite would let one missing leg annihilate the whole key."]
    if len(legcols) == 1:
        lines += [
            "   ONE-LEG LINK -- a KNOWN DEFECT CLASS, not a surprise. A one-leg link hash key",
            "   over a non-blank operand is BYTE-EQUAL to the hub key on the same row, so the",
            "   link carries no information the hub does not. Built AS DECLARED (s5.7); settling",
            "   it needs a discriminator leg in the link key, which is a MAP change.",
        ]
    lines.append("*/")
    legops = [c for _h, c in legcols]
    lines += ["", "select",
              "    %s as %s" % (N.hash_expr(code, K.null_safe_concat(legops)), hk)]
    for hub, col in legcols:
        lines.append("    , %s as %s" % (N.hash_expr(hub, col), N.hash_key(hub)))
        lines.append("    , %s as %s" % (col, col))
    lines += ["    , '%s' as RECORD_SOURCE" % slot["view"],
              "    , '%s' as SOURCE_RUN" % slot["run"],
              "    , current_timestamp() as LOAD_DATETIME",
              "from {{ ref('%s') }}" % N.stage_model(slot["view"]),
              "where " + " and ".join("(%s) is not null" % c for c in legops)]
    return "\n".join(lines) + "\n"


def render_link(table, slots, feed_models):
    code = table.upper()
    hk = N.hash_key(code)
    hubs = sorted({h for _fm, s in feed_models for h in (link_legs(s)[0] or {})})
    runs = sorted({s["run"] for _fm, s in feed_models})
    lines = ["{{ config(materialized='incremental', unique_key='%s') }}" % hk,
             "/* GENERATED by gen_hcon_vault.py -- models are generated.",
             "   %s : assembled from %d per-source link feed(s) over %d view(s), %d run(s): %s"
             % (code, len(feed_models), len({s["view"] for _f, s in feed_models}), len(runs),
                ", ".join(runs)),
             "   Legs: %s" % ", ".join(N.hash_key(h) for h in hubs)]
    lines += _caveat_lines(table)
    lines.append("*/")
    cols = [hk] + [N.hash_key(h) for h in hubs] + ["RECORD_SOURCE", "SOURCE_RUN", "LOAD_DATETIME"]
    parts = ["    select %s\n    from {{ ref('%s') }}" % (", ".join(cols), fm)
             for fm, _s in feed_models]
    lines += ["", "with feeds as (", "\n    union all\n".join(parts), ")", "", "select",
              "    " + ",\n    ".join([hk] + [N.hash_key(h) for h in hubs]) + ",",
              "    min(RECORD_SOURCE) as RECORD_SOURCE,",
              "    min(SOURCE_RUN) as SOURCE_RUN,",
              "    min(LOAD_DATETIME) as LOAD_DATETIME",
              "from feeds", "where %s is not null" % hk,
              "group by " + ", ".join([hk] + [N.hash_key(h) for h in hubs])]
    return "\n".join(lines) + "\n"


# ------------------------------------------------------------------ satellites
CARVED = set()          # filled by main() from the spec; the carve-out's scope
REGISTRY_OF = {}        # (view, vault_table) -> staged business-key column, for naming registries


def render_satellite(S, generator_label="gen_hcon_vault.py"):
    code = S["code"]
    anchor = S["anchor"]
    if not anchor:
        # No block declares an anchor and data_7.js declares no parent. Already refused in the
        # spec with that reason; there is no hub to hash a row onto, so nothing is emitted.
        return None
    hk = N.hash_key(anchor)
    feeders = [f for f in S["feeders"] if f["emitted"]]
    if not feeders:
        return None
    if not S["payload"]:
        return None
    # PAYLOAD IS NULL-PADDED TO THE SATELLITE, not to the feeder group (s6 rule 7): every feeder
    # selects every payload column of the satellite, casting null where it has no source.
    payload = [p for p in S["payload"]]
    paycols = [p["column"] for p in payload]
    legs = []
    for f in feeders:
        ck = f.get("child_key")
        if ck:
            for c in ck["components"]:
                if c["leg"] not in [l["leg"] for l in legs]:
                    legs.append(c)
    legcols = [N.column(l["leg"]) for l in legs]
    # no payload attribute may share a name with a child-key leg (s5.4) -- already enforced in the
    # spec, re-asserted here because the rule is cheap and the failure is silent
    clash = sorted(set(paycols) & set(legcols))
    if clash:
        raise AssertionError("payload/child-key leg name collision on %s: %s (s5.4)"
                             % (code, clash))

    runs = sorted({f["run"] for f in feeders})
    prec = [p for p in payload if p.get("precedence")]
    lines = ["{{ config(materialized='incremental') }}",
             "/* GENERATED by %s -- models are generated." % generator_label,
             "   %s" % code]
    if S["track"] == "unratified":
        lines += [
            "   *** UNRATIFIED. This payload is a BUILD-SIDE PROPOSAL from the map's",
            "   augmentation blocks and has NOT been ratified by the modeller. Attributes here",
            "   are not declared on this satellite in data_7.js. Do not treat it as part of the",
            "   ratified vault. ***",
        ]
    lines += [
        "   anchor      : %s   (kind: %s, origin: %s)" % (anchor, S["anchor_kind"],
                                                          S["anchor_origin"]),
        "   track       : %s" % S["track"],
        "   history     : %s" % (S["hist"] or "(not declared in data_7.js)"),
        "   feeders     : %d emitted of %d (one per source view AND run)"
        % (len(feeders), len(S["feeders"])),
        "   runs        : %d -- %s" % (len(runs), ", ".join(runs)),
        "   payload     : %d attribute(s), NULL-PADDED TO THE SATELLITE" % len(payload),
        "   grain       : ONE ROW PER %s" % ", ".join([N.hash_key(anchor)]
                                                      + [N.column(l["leg"]) for l in legs]),
        "   hashdiff    : %s (builder decision BD1), GUARDED against an all-null input (s5.5):"
        % N.hashdiff(code),
        "                 without the guard every all-null row hashes to ONE value and the",
        "                 satellite collapses to one row, which looks like change detection.",
    ]
    if len(runs) == 2:
        lines += [
            "   BESPOKE LAYER dual_feed_satellite_loader (s6.5): BOTH runs write this satellite.",
            "   The standard satellite layer unions feeders that are disjoint by construction,",
            "   which is the assumption two independent writers break.",
        ]
    if anchor in CARVED:
        lines += CARVE_OUT_NOTE
        both = [p for p in payload if len({w["run"] for w in p["writers"]}) > 1]
        for p in both:
            order = p.get("precedence") or []
            winner = order[0] if order else "(none)"
            losers = order[1:] if len(order) > 1 else []
            for lose in losers:
                regs = sorted({REGISTRY_OF.get((f["view"], anchor), "(unknown registry)")
                               for f in feeders if f["run"] == lose})
                nw = sum(1 for w in p["writers"] if w["run"] == lose)
                lines.append("     SUBORDINATE WRITER on %s: run %s, %d writer(s), registry/ies "
                             "%s -- its value is DISCARDED wherever %s also writes the same key"
                             % (p["column"], lose, nw, ", ".join(regs) or "(none staged)",
                                winner))
    if prec:
        lines.append("   DECLARED SOURCE PRECEDENCE -- %d attribute(s) are written by BOTH runs."
                     % len(prec))
        lines.append("   Never a key change and never RECORD_SOURCE in a key: either would")
        lines.append("   silently alter grain. Precedence is a VALUE choice, reversible by reload:")
        for p in prec:
            lines.append("     %-44s %s" % (p["column"], " > ".join(p["precedence"])))
    fanin = []
    for p in payload:
        for run, fr in sorted((p.get("fanin_by_run") or {}).items()):
            if fr["all_writers"] > 1:
                fanin.append((p["column"], run, fr))
    arbitrary = [x for x in fanin if x[2]["undiscriminated"] > 1]
    if fanin:
        lines.append("   INTRA-RUN FAN-IN, %d attribute/run pair(s) with more than one writer, of"
                     % len(fanin))
        lines.append("   which %d are genuinely ARBITRARY. WITHIN one run several source views"
                     % len(arbitrary))
        lines.append("   write the same attribute and the map declares NO precedence among them,")
        lines.append("   so max() picks arbitrarily -- BUT ONLY AMONG UNDISCRIMINATED WRITERS. A")
        lines.append("   writer carrying a resolved `instance` or a declared `redundant_of` is")
        lines.append("   SEPARATED, not competing: a nominee's name and a policyholder's name on")
        lines.append("   one satellite are DIFFERENT ROWS. BOTH SCOPES are quoted below because a")
        lines.append("   bare writer count overstates the arbitrariness -- on PARTY_FULL_NAME it")
        lines.append("   overstates it nearly fivefold.")
        lines.append("   DECLARED, NOT RESOLVED: choosing among same-run writers would invent an")
        lines.append("   authority the map does not provide. NO CROSS-RUN DECISION REACHES THIS.")
        for col, run, fr in sorted(fanin):
            lines.append("     %-38s %-22s %d writer(s), of which %d UNDISCRIMINATED "
                         "(%d separated by a resolved instance, %d by redundant_of)%s"
                         % (col, run, fr["all_writers"], fr["undiscriminated"],
                            fr["discriminated_by_instance"], fr["declared_redundant_of"],
                            "  [CROSS-TABLE: check_collapse groups on (table, satellite, "
                            "attribute, instance, child_key) and CANNOT see this]"
                            if fr["undiscriminated_is_cross_table"] else
                            "  [same-table]" if fr["undiscriminated"] > 1 else ""))
        if arbitrary:
            lines.append("   A load-time assertion in models/assertions/ counts the DISTINCT")
            lines.append("   values the undiscriminated writers actually supply per key. Until it")
            lines.append("   runs, whether they ever disagree is UNKNOWN, not zero.")
    if S["declared_legs"]:
        lines.append("   child key declared by data_7.js: %r" % S["model_childkey"])
        if legs:
            lines.append("   legs BUILT: %s" % ", ".join("%s (%s)" % (l["leg"], l["kind"])
                                                         for l in legs))
        for leg in S["declared_legs"]:
            if leg in K.PROFILE["renumbering_ordinals"]:
                lines.append("   UNSTABLE LEG %r is a RENUMBERING ORDINAL: it changes when a "
                             "sibling" % leg)
                lines.append("   row is added or removed, so it is NOT hub-grade. A source "
                             "renumbering rewrites")
                lines.append("   history on this satellite. Built as declared, never synthesised.")
    for r in S["refusals"]:
        lines.append("   REFUSED, DECLARED, NOT GUESSED -- view %s (%s), sub-population %s:"
                     % (r["view"], r["run"], r["subpopulation"]))
        for chunk in _wrap(r["detail"], 86):
            lines.append("     " + chunk)
        lines.append("     discriminator states found: %s" % r["states"])
    if S["refusals"] and S["declared_legs"]:
        lines += [
            "   CONSEQUENCE, stated because it is not recoverable after load: rows differing ONLY",
            "   in a refused leg COLLAPSE onto one hash key. The collapse is DECLARED and",
            "   countable here rather than hidden behind a fabricated discriminator.",
            "   check_collapse SKIPS a multi-active target whose child key is unresolved, so its",
            "   silence on this satellite is NOT a clean bill. Legacy collapse totals are",
            "   NOT_MEASURABLE, never zero.",
        ]
    lines += _caveat_lines(code.lower())
    lines.append("*/")

    parts = []
    for f in feeders:
        have = {c["column"]: c for c in f["columns"]}
        sel = ["        %s as %s" % (N.hash_expr(anchor, f["key_slot_bk_column"]), hk)]
        for l in legs:
            lc = N.column(l["leg"])
            src = None
            ck = f.get("child_key")
            if ck:
                for c in ck["components"]:
                    if c["leg"] == l["leg"]:
                        src = c
            if src is None:
                sel.append("        , cast(null as varchar) as %s" % lc)
            elif src["kind"] == "column":
                sel.append("        , coalesce(nullif(trim(%s), ''), '') as %s"
                           % (src["column"], lc))
            else:
                sel.append("        , %s as %s" % (N.sql_literal(src["literal"]), lc))
        for p in payload:
            c = have.get(p["column"])
            if c is None:
                # NULL-PADDED TO THE SATELLITE -- this feeder has no source for this attribute
                sel.append("        , cast(null as varchar) as %s" % p["column"])
            else:
                sel.append("        , %s as %s" % (c["source_column"], p["column"]))
        sel.append("        , '%s' as RECORD_SOURCE" % f["view"])
        sel.append("        , '%s' as SOURCE_RUN" % f["run"])
        sel.append("        , current_timestamp() as LOAD_DATETIME")
        where = "    where (%s) is not null" % f["key_expression"]
        parts.append("    select\n" + "\n".join(sel) + "\n    from {{ ref('%s') }}\n%s"
                     % (N.stage_model(f["view"]), where))

    # ---- THE BESPOKE DUAL-FEED LOADER (s6.5): one row per hub key + resolved legs, with the
    # declared source precedence APPLIED, not merely described.
    # DETERMINISTIC DECLARED PRECEDENCE, restored: the "emit both" variant was withdrawn because
    # two writers into one row per key is load-order-dependent and strictly worse than this.
    grain = [hk] + legcols
    res = []
    for p in payload:
        order = p.get("precedence") or [r for r in K.R8_PRECEDENCE
                                        if r in {w["run"] for w in p["writers"]}]
        if len(order) <= 1:
            run = order[0] if order else sorted({w["run"] for w in p["writers"]})[0]
            res.append("        max(case when SOURCE_RUN = %s then %s end) as %s"
                       % (N.sql_literal(run), p["column"], p["column"]))
        else:
            branches = ["max(case when SOURCE_RUN = %s then %s end)"
                        % (N.sql_literal(r), p["column"]) for r in order]
            res.append("        coalesce(%s) as %s" % (",\n                 ".join(branches),
                                                      p["column"]))
    lines += ["", "with feeders as (", "\n    union all\n".join(parts), "),", "",
              "resolved as (",
              "    select",
              "        " + ",\n        ".join(grain) + ("," if res else ""),
              ",\n".join(res) + ("," if res else ""),
              "        min(RECORD_SOURCE) as RECORD_SOURCE,",
              "        min(SOURCE_RUN) as SOURCE_RUN,",
              "        min(LOAD_DATETIME) as LOAD_DATETIME",
              "    from feeders",
              "    group by " + ", ".join(grain),
              "),", "", "hashed as (",
              "    select", "        *,",
              "        " + K.guarded_hashdiff(code, legcols + paycols).replace("\n", "\n        "),
              "    from resolved", ")", "", "select * from hashed",
              "where %s is not null" % hk,
              "  and %s is not null" % N.hashdiff(code)]
    return "\n".join(lines) + "\n"


def _wrap(text, width):
    words, line, out = str(text).split(), "", []
    for w in words:
        if len(line) + len(w) + 1 > width:
            out.append(line)
            line = w
        else:
            line = (line + " " + w).strip()
    if line:
        out.append(line)
    return out


def main():
    with open(SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    for d in DIRS.values():
        guarded_makedirs(d)

    slots_by_table = collections.defaultdict(list)
    for s in spec["key_slots"]:
        slots_by_table[s["vault_table"]].append(s)
    global CARVED
    CARVED = cross_run_shared_objects(spec)
    for s in spec["key_slots"]:
        REGISTRY_OF[(s["view"], s["vault_table"])] = s["bk_column"]

    loaders = {L["name"]: L for L in spec["loaders"]}
    counts = collections.Counter()

    # ---- hub feeds and hub loaders. REF_ tables are deliberately EXCLUDED here.
    #
    # A reference table gets ONE model, written by the satellite pass below, which hashes its own
    # key from the stage and carries the payload -- the shape opus_health_v2 already emits. Writing
    # a hub-style key loader for it as well put TWO different models on one filename, the second
    # overwrote the first, and the orphaned feed was only visible because feed consumption is
    # asserted in both directions.
    skipped_ref_loaders = []
    for table, slots in sorted(slots_by_table.items()):
        kind = ("link" if table.startswith("LNK_") else
                "ref" if table.startswith("REF_") else "hub")
        if kind == "link":
            continue
        if kind == "ref":
            skipped_ref_loaders.append(table)
            continue
        feeds = []
        for s in sorted(slots, key=lambda x: (x["view"], x["bk_column"])):
            fm = N.hub_feed_model(table.lower(), s["view"], s["id"])
            with guarded_open(os.path.join(DIRS["hub_feeds"], fm + ".sql")) as fh:
                fh.write(render_hub_feed(s, fm))
            feeds.append((fm, s))
            counts["hub_feed"] += 1
        with guarded_open(os.path.join(DIRS["hubs"], table.lower() + ".sql")) as fh:
            fh.write(render_hub(table.lower(), slots, feeds, kind))
        counts[kind] += 1

    # ---- link feeds and loaders
    for table, slots in sorted(slots_by_table.items()):
        if not table.startswith("LNK_"):
            continue
        feeds = []
        for s in sorted(slots, key=lambda x: (x["view"], x["bk_column"])):
            fm = N.link_feed_model(table.lower(), s["view"], s["id"])
            sql = render_link_feed(s, fm)
            if sql is None:
                counts["link_feed_refused"] += 1
                print("  REFUSED link feed %-38s %s" % (fm, link_legs(s)[1]))
                continue
            with guarded_open(os.path.join(DIRS["links"], fm + ".sql")) as fh:
                fh.write(sql)
            feeds.append((fm, s))
            counts["link_feed"] += 1
        if not feeds:
            print("  NOT BUILT link %-44s no per-source feed could establish its legs"
                  % table)
            counts["link_not_built"] += 1
            continue
        with guarded_open(os.path.join(DIRS["links"], table.lower() + ".sql")) as fh:
            fh.write(render_link(table.lower(), slots, feeds))
        counts["link"] += 1

    # ---- satellites: the RATIFIED and REFERENCE tracks only (augmented has its own generator)
    skipped = []
    for S in spec["satellites"]:
        if S["track"] == "unratified":
            continue
        sql = render_satellite(S)
        if sql is None:
            why = ("no anchor: no block declares one and data_7.js declares no parent"
                   if not S["anchor"] else
                   "no payload attribute survived" if not S["payload"] else
                   "every one of its %d feeder(s) lacks an anchor key slot, so no row of it can "
                   "reach %s" % (len(S["feeders"]), S["anchor"]))
            skipped.append((S, why))
            continue
        outdir = DIRS["refs"] if S["track"] == "reference" else DIRS["satellites"]
        with guarded_open(os.path.join(outdir, S["code"].lower() + ".sql")) as fh:
            fh.write(sql)
        counts["satellite" if S["track"] == "ratified" else "reference_sat"] += 1

    carved_sats = sorted({S["code"] for S in spec["satellites"]
                          if (S["anchor"] or "") in CARVED and S["payload"]})
    carved_both = sorted({S["code"] for S in spec["satellites"]
                          if (S["anchor"] or "") in CARVED
                          and any(len({w["run"] for w in p["writers"]}) > 1
                                  for p in S["payload"])})
    print("[vault] %s" % json.dumps(dict(counts)))
    print("  CROSS-RUN CARVE-OUT (ratified by the mapping counterparty) over %d shared object(s) "
          "written by MORE THAN ONE run: %s" % (len(CARVED), sorted(CARVED)))
    print("  DERIVED, not retyped: shared-62 hubs and links with feeds from two or more runs. "
          "lnk_policy_party is in the shared 62 and was EXCLUDED while the settled map's v2 feeds "
          "were its only ones; delta 3 adds a second run, so it is now IN.")
    print("  -> %d satellite unit(s) anchored there carry the declaration; %d of them have at "
          "least one attribute written by BOTH runs, where the subordinate writer and its "
          "registry are NAMED in the header" % (len(carved_sats), len(carved_both)))
    print("  -> the precedence MECHANISM is unchanged and deterministic (v2 > legacy > delta3, "
          "BD6 then BD6b). 'Emit both' was withdrawn: two writers into one row per key is "
          "load-order-dependent and strictly worse.")
    for S, why in skipped:
        print("  NOT BUILT %-42s %s. Declared in the unresolved register; this is NOT a source "
              "gap and NOT a clean build." % (S["code"] + " [" + S["track"] + "]", why))
    byreason = collections.Counter(w.split(":")[0].split(",")[0] for _S, w in skipped)
    print("[vault] ratified/reference satellites NOT BUILT: %d -- %s"
          % (len(skipped), dict(byreason)))
    ls = spec["loader_summary"]
    print("[vault] loader plan: %d declared vault tables = %d buildable + %d with NO feed in the "
          "settled map (declared, not emitted as empty models)"
          % (ls["declared_total"], ls["buildable"], ls["not_buildable_no_feed"]))
    print("[vault] shared set: %d dual-feed, %d single-feed %s"
          % (ls["shared_dual_feed"], ls["shared_single_feed"], ls["shared_single_feed_names"]))
    print("[vault] carried-forward caveats emitted verbatim into: %s"
          % spec["carried_forward_caveat_tables"])
    return 0


if __name__ == "__main__":
    sys.exit(main())
