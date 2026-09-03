# -*- coding: utf-8 -*-
"""THE single home for maximus_partner key derivation.

On maximus_health the stage and unpivot layers each carried their own copy of these rules and the
unpivot's fallback keyed 931 of 1,639 branches on the document, collapsing every address and party
of a document onto one hub row. One module, imported by every layer.

WHAT IS DIFFERENT ABOUT PARTNER
-------------------------------
This source is a PARTY shred: the root document IS the party (`partyDetail.partyCode`). So
`FOREIGN_KEY` on any sub-view is the party's own root key, and keying HUB_PARTY on it is correct --
not the wrong-hub collapse the guardrail bans. That guardrail is about keying a SUB-hub on another
entity's root; here HUB_PARTY *is* the root. Every other anchor still has to name its own key.
"""
import re

# The shred root. For partner this is the party itself -- see the module docstring.
ROOT_ANCHORS = {"HUB_PARTY"}

# Present on the views but absent from the column map, which lists business columns only. Their
# absence from the map can never be read as absence from the view.
SPINE_COLS = {"foreign_key", "key_hash", "parent_key_hash"}

# Canonical address attributes in a FIXED order, rendered in partner's own (squashed) convention.
# Coupled to mp_names.attr_col: when that rendering changes these move with it. On maximus_health
# that coupling was missed and the address content hash silently matched nothing, dropping
# SAT_COMMON_ADDRESS from two views.
ADDRESS_PARTS = ["DOORNUMBER", "BUILDINGNAME", "ADDRESSLINE1", "ADDRESSLINE2", "ADDRESSLINE3",
                 "STREETNAME", "LANDMARK", "LOCALITY", "POSTOFFICENAME", "CITY", "DISTRICT",
                 "STATENAME", "POSTALCODE", "COUNTRYNAME"]

# A link's key is DERIVED from its legs -- the map keys the legs (hubs) and never the link itself.
# Ratified on travel (R3 item C7, mapper-confirmed). Order is load-bearing: it is part of the key.
LINK_LEGS = {
    "LNK_PARTY_LOCATION":     ["HUB_PARTY", "HUB_LOCATION"],
    "LNK_PARTY_RELATIONSHIP": ["HUB_PARTY", "HUB_PARTY"],
    "LNK_PARTY_ROLE":         ["HUB_PARTY"],
}

# Anchors the map keys only with a child-key ruling, decided on ratified precedent rather than
# another round. HUB_PAYMENT_INSTRUMENT is travel R2-B verbatim: a payment MODE with no distinct
# instrument key lands at the root grain, NAMESPACED -- the namespace is what stops it deriving the
# same business key as the party root it shares a document with.
NAMESPACED_ROOT = {"HUB_PAYMENT_INSTRUMENT"}

# A link whose two legs are the SAME hub needs two distinct key columns. The map writes both in
# one rule: "HUB_PARTY leg 1 (root/subject party): <rule> || HUB_PARTY leg 2 (related party):
# <rule>". Parsed here rather than collapsed, because one column cannot serve both legs -- aliasing
# the second onto the first would file every relationship as self-referential.
#
# partner_dv_dbt does not build this link, and no same-hub two-leg link exists anywhere in the
# repo, so there is no sibling hash to match and the leg NAMES are ours: the mapper's own role
# words. Same footing as travel's four links (R3 item C7).
_LEG = re.compile(r"(HUB_[A-Z_]+) leg (\d+) \(([^)]*)\):\s*(.*?)(?=\s*\|\|\s*HUB_|$)", re.S)


def link_legs_from_rule(rule):
    """[(leg_column_base, tier, rule_text)] for a link whose rule spells out each leg."""
    out = []
    for hub, _n, role, txt in _LEG.findall(rule or ""):
        base = re.sub(r"^HUB_", "", hub)
        r = role.lower()
        if "related" in r:
            col = "RELATED_" + base
        elif "root" in r or "subject" in r:
            col = base
        else:
            col = re.sub(r"[^A-Z0-9]+", "_", role.upper()).strip("_") + "_" + base
        tier = ("tier1_business_code" if "tier1" in txt else
                "tier2_foreign_key" if "tier2" in txt else None)
        out.append((col, tier, txt))
    return out


_COL = re.compile(r"\b([A-Z][A-Z0-9_]{2,})\b")

UNRESOLVED = []      # (view, anchor, tier, why) -- reported, never guessed


def _named_column(text, cols):
    """First UPPER_SNAKE token in the rule text that is genuinely a column on this view.

    Exact match only. The mapper writes shorthand, and picking a near-miss would be editing the
    mapping -- those get reported instead.
    """
    from mp_names import ident
    for tok in _COL.findall(text or ""):
        if tok.lower() in cols:
            return ident(tok)
    return None


def address_hash(available):
    """Ordered content hash over whichever address parts this source actually carries.

    `available` maps canonical attribute -> the view's own source column. Every layer must produce
    the SAME expression for the same address: on health, hashing aliases in one layer and raw
    columns in the other gave one address two hub keys.
    """
    from mp_names import ident
    parts = [ident(available[p]) for p in ADDRESS_PARTS if p in available]
    if not parts:
        return None
    return ("md5(concat_ws('|', " +
            ", ".join(f"upper(trim(to_varchar({p})))" for p in parts) + "))")


def is_child_key_tier(tier, rule=""):
    """True when the stated rule describes the SATELLITE's discriminator, not the hub's key.

    Partner states these as `column_as_instance:` / `named_discriminator:` with no tier. Letting
    one leak into the hub-key ladder is what left HUB_POLICY unresolved on three health views and
    cost travel a whole round.
    """
    t = (tier or "").strip()
    r = (rule or "").strip().lower()
    return (bool(re.match(r"^[1-4] \(", t)) or "child key" in t.lower()
            or r.startswith(("column_as_instance", "named_discriminator")))


def key_expr(anchor, tier, rule, cols, view, address=()):
    """Hub/link business-key expression for one (view, anchor), from its stated tier.

    Rule 1: a hub key is a business code, never a hash -- the sole ratified exception being
    HUB_LOCATION's address content hash.
    """
    t = (tier or "").lower()
    txt = rule or ""

    if "tier4" in t or "content_hash" in t:
        h = address_hash(address)
        if h:
            return h
        UNRESOLVED.append((view, anchor, tier, "tier4 content hash but the view carries no "
                                               "address part"))
        return None

    if "tier2" in t or "foreign_key" in t:
        if anchor in ROOT_ANCHORS or anchor.startswith("LNK_"):
            # HUB_PARTY is this shred's root, and a LINK's own root leg on FOREIGN_KEY is
            # legitimate (mapper-confirmed on travel R3).
            return "foreign_key"
        UNRESOLVED.append((view, anchor, tier, "tier2 FOREIGN_KEY on a NON-root anchor -- that is "
                                               "the wrong-hub collapse, not a key"))
        return None

    if "tier1" in t or "business_code" in t:
        c = _named_column(txt, cols)
        if c:
            return c
        UNRESOLVED.append((view, anchor, tier,
                           "tier1 but no column named in the rule is on the view"))
        return None

    # No tier stated. For the shred root that is still resolvable -- every sub-view of a party
    # shred carries the party's FOREIGN_KEY -- and for anything else it is reported.
    if anchor in ROOT_ANCHORS:
        return "foreign_key"
    if anchor in NAMESPACED_ROOT:
        return "'" + anchor + "|' || foreign_key"
    UNRESOLVED.append((view, anchor, tier, "no hub-key tier stated for a non-root anchor"))
    return None
