# -*- coding: utf-8 -*-
"""The ONLY place a naming convention is encoded for Maximus Health V3 (BUILD_RULES.md s7.6).

Everything here is derived from build_profile.json:
  * the source prefix                      -> profile["prefix"]            (MAXI_HLTH_)
  * the abbreviation vocabulary            -> profile["abbr_seed"]         (47 pairs)
  * the payload alias convention           -> profile["sibling"]["payload_convention_token"]
  * the identifier budget                  -> profile["name_injectivity_proof"]
                                              ["identifier_budget_chars"] (63)

NOTHING here restates a fact the profile owns, and no abbreviation pair is typed
by hand.  s2: a generator written from a remembered field name is the defect this
stage exists to prevent.

WHY THE BUDGET IS CHECKED SEPARATELY FROM INJECTIVITY (s7.5, and the profile's own
naming_note): a first abbreviation vocabulary of 24 pairs on this LOB was injective
at 85/85 and still produced a 75-char name, over Snowflake's 63-char identifier
budget.  Injective-but-over-budget looks like a pass on the injectivity test alone,
so both properties are asserted, and a name that must be truncated CARRIES A DIGEST
of the full name so truncation can never silently merge two names.
"""
import hashlib
import json
import os
import re

# ---------------------------------------------------------------- profile intake

_HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(_HERE)
PROFILE_PATH = os.path.join(PROJECT, "build_profile.json")

# Every profile key this module is allowed to read. Reading anything else is a
# programming error here, not a profile defect.
_PROFILE_KEYS_USED = (
    "prefix", "abbr_seed", "sibling", "name_injectivity_proof", "lob",
)


def load_profile(path=PROFILE_PATH):
    """Read the profile, refusing to run without it (s2)."""
    if not os.path.isfile(path):
        raise AssertionError(
            "build_profile.json is ABSENT at %s. Stage 1 refuses to run without it: a "
            "generator written from a remembered field name is the defect s2 exists to "
            "prevent." % path)
    with open(path, encoding="utf-8") as fh:
        prof = json.load(fh)
    residue = prof.get("parse_residue")
    if residue != 0:
        raise AssertionError(
            "profile parse_residue is %r, not 0. A grammar that does not fully parse will "
            "not fully build, and the gap will look like a source gap. Stage 1 stops here."
            % (residue,))
    return prof


PROFILE = load_profile()

PREFIX = PROFILE["prefix"]
LOB = PROFILE["lob"]
IDENT_BUDGET = PROFILE["name_injectivity_proof"]["identifier_budget_chars"]
PAYLOAD_CONVENTION = PROFILE["sibling"]["payload_convention_token"]
PAYLOAD_CONVENTION_STATUS = PROFILE["sibling"]["payload_convention_status"]

# The abbreviation table, longest key first so that MAXI_HLTH_CLM_VW_DATA is
# consumed before CLAIM and ATTRIBUTES before ATTRIBUTE.  Applied as substring
# replacement, which is what reproduces the profile's own worked example
# 'stg_clm_cd_clm_payment_clm_payment_detail_attr_pv'.
ABBR = sorted(((a, b) for a, b in PROFILE["abbr_seed"]), key=lambda p: -len(p[0]))

if PAYLOAD_CONVENTION != "UPPER_SNAKE_PHYSICAL":
    raise AssertionError(
        "unrecognised payload convention token %r from the profile. This module encodes "
        "UPPER_SNAKE_PHYSICAL only; a new token is a convention decision, not a default. "
        "s2.2: raise on an unrecognised profile value rather than skipping it."
        % (PAYLOAD_CONVENTION,))

# --------------------------------------------------------------- length budget

DIGEST_LEN = 6


def _digest(text):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:DIGEST_LEN]


def fit(name, budget=None):
    """Return a name inside the identifier budget, carrying a digest if truncated (s7.5).

    Truncation without a digest is how two distinct long names become one short
    name, which is an injectivity failure that the injectivity test cannot see
    because it is introduced AFTER the vocabulary has been applied.
    """
    budget = IDENT_BUDGET if budget is None else budget
    if len(name) <= budget:
        return name
    keep = budget - (DIGEST_LEN + 1)
    if keep < 1:
        raise AssertionError("budget %d too small to carry a digest" % budget)
    return name[:keep] + "_" + _digest(name)


TRUNCATED = {}      # short -> full, for every name this module had to shorten


def _fit_recorded(name, budget=None):
    out = fit(name, budget)
    if out != name:
        TRUNCATED[out] = name
    return out


# ------------------------------------------------------- view -> model basename

def abbreviate(view):
    """Apply the profile's abbreviation vocabulary to a source view name."""
    s = view.upper()
    for long, short in ABBR:
        s = s.replace(long, short)
    s = re.sub(r"_+", "_", s).strip("_")
    return s.lower()


_LAYER_PREFIXES = {
    "staging": "stg",
    "hopview": "hop",
    "resolver": "res",
    "unpivot": "upv",
    "stage": "stage",
    "reject": "rej",
    "hub_feed": "hubf",
    "link_feed": "lnkf",
    "sat_feed": "satf",
    "augmented": "aug",
    "quarantine": "qtn",
    "refdecode": "refg",
}


def layer_prefixes():
    """The whole set, so a caller can sweep it rather than name one (s1.5)."""
    return dict(_LAYER_PREFIXES)


def _layered(layer, stem):
    if layer not in _LAYER_PREFIXES:
        raise AssertionError(
            "unrecognised layer %r. Handle the SET, never one member (s1.5); known: %s"
            % (layer, sorted(_LAYER_PREFIXES)))
    return _fit_recorded("%s_%s" % (_LAYER_PREFIXES[layer], stem))


def staging_name(view):
    return _layered("staging", abbreviate(view))


def hopview_name(view):
    return _layered("hopview", abbreviate(view))


def resolver_name(view):
    return _layered("resolver", abbreviate(view))


def unpivot_name(view):
    return _layered("unpivot", abbreviate(view))


def stage_name(view):
    return _layered("stage", abbreviate(view))


def reject_name(view):
    return _layered("reject", abbreviate(view))


# --------------------------------------------------------- vault object naming

def _model_stem(code):
    """HUB_CLAIM -> claim ; SAT_CLAIM_NOTE -> claim_note ; LNK_X -> x."""
    s = code.upper()
    for pre in ("HUB_", "SAT_", "LNK_", "REF_"):
        if s.startswith(pre):
            s = s[len(pre):]
            break
    return s.lower()


def hub_name(hub):
    return _fit_recorded("hub_" + _model_stem(hub))


def link_name(link):
    return _fit_recorded("lnk_" + _model_stem(link))


def sat_name(sat):
    return _fit_recorded("sat_" + _model_stem(sat))


def ref_name(ref):
    return _fit_recorded("ref_" + _model_stem(ref))


def hub_feed_name(hub, view, ordinal):
    """A feeder is (view, DECLARED ANCHOR EXPRESSION) -- never (view) alone.

    The ordinal is the index of the DECLARED anchor expression within that
    (hub, view) pair.  On the sibling a view-only feeder key forced a fallback
    that picked an arbitrary key slot from another hub: one satellite emitted the
    sub-intermediary's name on the relationship manager's key, five parties
    collapsed onto one key, four names were dropped, and it compiled cleanly.
    The ordinal is what keeps two namespaces on one view distinct instead of
    making one of them unreachable.
    """
    if not isinstance(ordinal, int) or ordinal < 0:
        raise AssertionError("hub feed ordinal must be a non-negative int, got %r" % (ordinal,))
    return _fit_recorded("hubf_%s_%s_k%d" % (_model_stem(hub), abbreviate(view), ordinal))


def link_feed_name(link, view, ordinal):
    return _fit_recorded("lnkf_%s_%s_k%d" % (_model_stem(link), abbreviate(view), ordinal))


def sat_feed_name(sat, view, ordinal):
    return _fit_recorded("satf_%s_%s_k%d" % (_model_stem(sat), abbreviate(view), ordinal))


def augmented_name(sat):
    return _fit_recorded("aug_" + _model_stem(sat))


def quarantine_name(sat):
    return _fit_recorded("qtn_" + _model_stem(sat))


def refdecode_name(sat):
    return _fit_recorded("refg_" + _model_stem(sat))


# ------------------------------------------------------- attribute -> column

_NON_WORD = re.compile(r"[^A-Za-z0-9]+")


def attribute_column(attr):
    """Render a model attribute name as a PHYSICAL column (UPPER_SNAKE_PHYSICAL).

    Measured on the sibling at 4,544 of 4,551 non-type aliases, with ZERO alias
    containing whitespace, so the convention is a physical upper-snake name and
    NOT a quoted business name.  'Co-Pay Applied' -> CO_PAY_APPLIED.

    s3.3 / the gates-verify-form note: prose is valid SQL.  An attribute name is
    business prose and MUST NOT reach SQL in identifier position unchanged -- a
    space in an alias is the shape check_prose_shape fires on.
    """
    if not isinstance(attr, str) or not attr.strip():
        raise AssertionError("attribute name must be a non-empty string, got %r" % (attr,))
    s = _NON_WORD.sub("_", attr.strip()).strip("_").upper()
    s = re.sub(r"_+", "_", s)
    if not s:
        raise AssertionError("attribute %r rendered to an empty column name" % (attr,))
    if re.match(r"^[0-9]", s):
        s = "C_" + s
    return _fit_recorded(s, IDENT_BUDGET)


def childkey_column(leg):
    """A declared child-key leg name -> its physical column.

    Same renderer as a payload attribute ON PURPOSE: s5.4 forbids a payload
    attribute from sharing a name with a child-key leg, and that collision is
    only detectable if both sides render through one function.
    """
    return attribute_column(leg)


def split_declared_childkey(childkey):
    """data_7.js spells a compound child key 'A + B'.  Split it into legs.

    The model is the authority for the DECLARED legs (the map's target.key_name is
    the HUB key name and is null on all 1,888 satellite rows).  Splitting on '+'
    is the model's own spelling, verified against the profile's census:
    109 single-leg / 23 two-leg / 1 four-leg over 133 keyed satellites.
    """
    if not childkey or not str(childkey).strip():
        return []
    return [p.strip() for p in str(childkey).split("+") if p.strip()]


# --------------------------------------------------------------- quoting

_BARE_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_$]*$")


def quote_ident(name):
    """Quote only when a bare identifier would not survive Snowflake unquoted.

    Snowflake folds an unquoted identifier to upper case, so an UPPER_SNAKE
    physical name needs no quoting -- and quoting it would be worse, because a
    quoted identifier is case-SENSITIVE and would stop matching the same name
    written bare elsewhere in the build.
    """
    if not isinstance(name, str) or not name:
        raise AssertionError("identifier must be a non-empty string, got %r" % (name,))
    if _BARE_IDENT.match(name) and name == name.upper():
        return name
    return '"' + name.replace('"', '""') + '"'


def is_physical_identifier(name):
    """True when `name` can stand unquoted in identifier position."""
    return bool(_BARE_IDENT.match(name or "")) and name == (name or "").upper()


# --------------------------------------------------------------- self-test

def selftest(views, extra_names=()):
    """Prove injectivity AND the length budget over every name actually emitted.

    An injective 24-pair vocabulary that produced a 75-char name is a FAIL, not a
    pass, so both are reported and both must hold.
    """
    out = {"views": len(views), "checks": []}

    short = {}
    collisions = []
    for v in sorted(views):
        s = abbreviate(v)
        short.setdefault(s, []).append(v)
    for s, vs in short.items():
        if len(vs) > 1:
            collisions.append((s, vs))
    out["checks"].append({
        "check": "abbreviation vocabulary is injective over the source views",
        "result": "pass" if not collisions else "fail",
        "detail": "%d views -> %d distinct abbreviations; %d collision(s)"
                  % (len(views), len(short), len(collisions)),
        "collisions": collisions[:5],
    })

    # Every name this module can mint for a view, swept across the layer set.
    minted = []
    for v in views:
        minted += [staging_name(v), hopview_name(v), resolver_name(v),
                   unpivot_name(v), stage_name(v), reject_name(v)]
    minted += list(extra_names)
    over = [n for n in minted if len(n) > IDENT_BUDGET]
    out["checks"].append({
        "check": "every emitted name is inside the %d-char identifier budget" % IDENT_BUDGET,
        "result": "pass" if not over else "fail",
        "detail": "%d names checked, longest %d chars (%s), %d over budget"
                  % (len(minted), max(len(n) for n in minted) if minted else 0,
                     max(minted, key=len) if minted else "-", len(over)),
        "over": over[:5],
    })

    dup = {}
    for n in minted:
        dup[n] = dup.get(n, 0) + 1
    clashes = sorted(n for n, k in dup.items() if k > 1)
    out["checks"].append({
        "check": "emitted model names are unique across every layer",
        "result": "pass" if not clashes else "fail",
        "detail": "%d names, %d distinct, %d clash(es)"
                  % (len(minted), len(dup), len(clashes)),
        "clashes": clashes[:5],
    })

    # Truncation must carry a digest, and must still be injective AFTER truncation.
    bad_trunc = [s for s, full in TRUNCATED.items() if not re.search(r"_[0-9a-f]{%d}$" % DIGEST_LEN, s)]
    out["checks"].append({
        "check": "every truncated name carries a digest of the full name (s7.5)",
        "result": "pass" if not bad_trunc else "fail",
        "detail": "%d name(s) needed truncation; %d lack a digest"
                  % (len(TRUNCATED), len(bad_trunc)),
    })

    # A planted probe: two long names differing only past the budget must NOT merge.
    a = "x" * 80 + "_alpha"
    b = "x" * 80 + "_beta"
    out["checks"].append({
        "check": "truncation probe: two names differing only past the budget stay distinct",
        "result": "pass" if fit(a) != fit(b) else "fail",
        "detail": "fit(a)=%s fit(b)=%s" % (fit(a), fit(b)),
    })

    # A planted probe on the attribute renderer: prose must not survive as prose.
    probe = attribute_column("Co-Pay Applied")
    ok = probe == "CO_PAY_APPLIED" and " " not in probe
    out["checks"].append({
        "check": "attribute renderer removes whitespace and punctuation from prose",
        "result": "pass" if ok else "fail",
        "detail": "'Co-Pay Applied' -> %s" % probe,
    })

    out["passed"] = all(c["result"] == "pass" for c in out["checks"])
    return out


if __name__ == "__main__":
    import sys
    bundle = PROFILE["bundle_root"]
    with open(os.path.join(bundle, "00_tables_index.json"), encoding="utf-8") as fh:
        tabs = json.load(fh)["tables"]
    mp = json.load(open(os.path.join(bundle, "04_column_map.json"), encoding="utf-8"))
    views = sorted({c["table_name"] for c in mp["columns"]})
    rep = selftest(views, extra_names=[])
    print(json.dumps(rep, indent=1))
    print("longest abbreviation:", max((abbreviate(v) for v in views), key=len))
    sys.exit(0 if rep["passed"] else 1)
