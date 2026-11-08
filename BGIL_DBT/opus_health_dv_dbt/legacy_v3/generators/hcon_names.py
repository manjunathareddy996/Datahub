# -*- coding: utf-8 -*-
"""THE ONLY PLACE A NAMING CONVENTION IS ENCODED for health_consolidated (BUILD_RULES.md s7.6).

Everything about how a name is rendered lives here: view -> model name, the abbreviation table,
attribute -> column, identifier quoting, the child-key leg split, the length budget and its digest,
the hub hash key form, and the hashdiff name. No other module in this build may contain a naming
rule; if one does, the next LOB inherits a convention nobody can find.

CONVENTIONS, AND WHERE EACH CAME FROM
-------------------------------------
payload columns   UPPER_SNAKE_PHYSICAL  -- RATIFIED. Counted from both originals' emitted satellite
                  SQL (profile sibling.convention_evidence: 623/57 legacy, 1819/46 v2). Both agree.
hub key           md5(upper('HUB_X|' || <bk>))  -- RATIFIED, emitted EXPLICITLY, no macro hashes.
hashdiff          <SAT>_HASHDIFF  -- RATIFIED BY THE COORDINATOR this run. The profile still records
                  RECOMMENDED_NOT_RATIFIED; the ratification is carried in keyrules.BUILDER_DECISIONS
                  with its one-line switch, because a decision taken in a message and not written
                  down is a decision nobody can overrule.
abbreviation seed read from profile.abbr_seed -- FOUR prefixes, not one. A generator assuming a
                  single source prefix drops 14 of 115 views (profile.prefix_note).
"""
import hashlib
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.abspath(os.path.join(HERE, os.pardir))
PROFILE_PATH = os.path.join(PROJECT_ROOT, "build_profile.json")

# ---------------------------------------------------------------- regexes, authored in THIS FILE
# Never through a shell heredoc (BUILD_RULES.md s1.2). Every one is probed in probe_patterns().
RX_BARE_IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
RX_NON_IDENT_RUN = re.compile(r"[^A-Za-z0-9]+")
RX_LEG_SPLIT = re.compile(r"\s+\+\s+")
RX_PLACEHOLDER = re.compile(r"^\{([A-Za-z_][A-Za-z0-9_]*)\}$")
RX_PREFIX_SEED = re.compile(r"^(BJAZ|BA_HCP|BGIL|STG)_")
RX_MODEL_SAFE = re.compile(r"^[a-z_][a-z0-9_]*$")
# prose in an identifier position: two word-ish runs separated by whitespace, or a bracket/dash
RX_PROSE_SHAPE = re.compile(r"[A-Za-z0-9]\s+[A-Za-z0-9]|[()\[\]/]|—|--")
# a satellite/ref/hub/link code possibly followed by descriptive prose
RX_VAULT_CODE = re.compile(r"^((?:SAT|REF|HUB|LNK)_[A-Z0-9_]+)")

# Snowflake's identifier limit is 255; this build's budget is deliberately tighter so a name is
# readable in a `select` list. The digest exists so truncation stays INJECTIVE (s7.5).
IDENT_BUDGET = 120
DIGEST_LEN = 6


def _load_profile():
    with open(PROFILE_PATH, encoding="utf-8") as fh:
        return json.load(fh)


_P = _load_profile()

# ---- abbreviation table, READ from the profile, never restated ------------------------------
ABBR = {}
for _pair in _P["abbr_seed"]:
    if not (isinstance(_pair, list) and len(_pair) == 2):
        raise AssertionError("profile.abbr_seed entry is not a [prefix, abbrev] pair: %r" % (_pair,))
    ABBR[_pair[0]] = _pair[1]
if not ABBR:
    raise AssertionError("profile.abbr_seed is empty; there is no abbreviation table to apply")

PREFIXES = tuple(sorted(ABBR, key=len, reverse=True))   # longest first: BA_HCP before BA


# =============================================================================== identifiers
def digest(text, n=DIGEST_LEN):
    return hashlib.sha256(text.encode("utf-8")).hexdigest()[:n]


def budget(name, budget_chars=IDENT_BUDGET):
    """Truncate to the budget CARRYING A DIGEST, so two long names never collide (s7.5).

    Returns the name unchanged when it fits. The digest is of the FULL name, so the mapping is
    injective in practice and reproducible across runs.
    """
    if len(name) <= budget_chars:
        return name
    keep = budget_chars - DIGEST_LEN - 1
    if keep < 1:
        raise AssertionError("budget %d too small to carry a digest" % budget_chars)
    return "%s_%s" % (name[:keep], digest(name))


def assert_identifier(name, what):
    """Refuse anything that is not a bare SQL identifier. This is the s3.3 gate at the source.

    Prose IS valid SQL once it is inside a function call, so only a refusal catches it.
    """
    if not isinstance(name, str) or not RX_BARE_IDENT.match(name):
        raise AssertionError("NOT A BARE IDENTIFIER for %s: %r" % (what, name))
    return name


def quote_ident(name):
    """Snowflake double-quoting. Used ONLY where a name is already a proven identifier; a name
    needing quotes to be legal is a naming defect, not something to paper over."""
    assert_identifier(name, "quote_ident")
    return '"%s"' % name


def sql_literal(text):
    """A single-quoted SQL string literal with quotes doubled. One unescaped apostrophe in a
    child-key literal has shipped before."""
    if not isinstance(text, str):
        raise AssertionError("sql_literal wants a string, got %r" % (text,))
    return "'" + text.replace("'", "''") + "'"


# =============================================================================== views
def strip_prefix(table_name):
    """Strip ONE of the FOUR declared source prefixes. Returns (stem, abbrev_or_None)."""
    m = RX_PREFIX_SEED.match(table_name)
    if m:
        pfx = m.group(1)
        return table_name[len(pfx) + 1:], ABBR[pfx]
    for pfx in PREFIXES:                      # defensive: profile seed may change
        if table_name.startswith(pfx + "_"):
            return table_name[len(pfx) + 1:], ABBR[pfx]
    return table_name, None


def view_stem(table_name):
    """The lower-case stem a model name is built from. 'BA_HCP_DT_MEM' -> 'hcp_dt_mem'."""
    stem, abbrev = strip_prefix(table_name)
    parts = [p for p in (abbrev, stem.lower()) if p]
    out = "_".join(parts)
    out = RX_NON_IDENT_RUN.sub("_", out).strip("_").lower()
    if not RX_MODEL_SAFE.match(out):
        raise AssertionError("view stem is not a safe model name: %r from %r" % (out, table_name))
    return budget(out)


def staging_model(table_name):
    return budget("stg_" + view_stem(table_name))


def stage_model(table_name):
    return budget("stage_" + view_stem(table_name))


def hub_feed_model(vault_table, table_name, slot_key):
    return budget("hf_%s__%s__%s" % (vault_table, view_stem(table_name), digest(slot_key, 10)))


def link_feed_model(vault_table, table_name, slot_key):
    return budget("%s__%s__%s" % (vault_table, view_stem(table_name), digest(slot_key, 6)))


def reject_model(vault_table, table_name, slot_key):
    return budget("rj_%s__%s__%s" % (vault_table, view_stem(table_name), digest(slot_key, 10)))


def unpivot_model(table_name, satellite, discriminator):
    return budget("unpvt_%s__%s_%s" % (view_stem(table_name), satellite.lower(),
                                       column(discriminator).lower()))


def assert_view_names_injective(table_names):
    """N views must still be N model names, for whatever N is passed. The profile asserts
    injectivity over the population it was written against; this REPROVES it for THIS renderer over
    the population ACTUALLY PASSED, because injectivity is a property of the rendering, not of the
    input -- and because a count written into this docstring goes stale the moment a contract is
    added, which is exactly what happened to the 115 it used to name."""
    seen = {}
    for t in table_names:
        n = view_stem(t)
        if n in seen and seen[n] != t:
            raise AssertionError("VIEW NAME COLLISION: %r and %r both render %r"
                                 % (seen[n], t, n))
        seen[n] = t
    return len(seen)


# =============================================================================== attributes
def column(attribute):
    """attribute -> physical column, UPPER_SNAKE_PHYSICAL (RATIFIED).

    'Pre-Existing Disease Description' -> 'PRE_EXISTING_DISEASE_DESCRIPTION'
    Refuses to render prose: the caller must have resolved the attribute to a real model attribute
    first. A space is fine (it is what snake_case is FOR); a bracket or an em-dash is not, because
    nothing in the canonical model's attribute names carries one and their presence means a
    descriptive phrase arrived where an attribute name was expected.
    """
    if not isinstance(attribute, str) or not attribute.strip():
        raise AssertionError("column() got an empty attribute: %r" % (attribute,))
    if "(" in attribute or ")" in attribute or "—" in attribute or "[" in attribute:
        raise AssertionError("PROSE IN AN ATTRIBUTE NAME, refusing to render: %r" % attribute)
    out = RX_NON_IDENT_RUN.sub("_", attribute.strip()).strip("_").upper()
    if not out:
        raise AssertionError("attribute rendered to nothing: %r" % attribute)
    if out[0].isdigit():
        out = "A_" + out
    return assert_identifier(budget(out), "column(%r)" % attribute)


def bk_column(hub, source_columns):
    """The staged business-key column name for one key slot: HUB_X_BK__COL1_COL2.

    v2's own convention, kept: HUB_ASSESSMENT_BK__SCRUTINY_NO. The suffix names the operands so a
    hub carrying several registries shows which one each slot came from -- the namespace separates
    HUBS, not registries within a hub, so the slot name is the only place the registry is visible.
    """
    assert_identifier(hub, "bk_column hub")
    cols = [assert_identifier(c, "bk operand") for c in source_columns]
    return assert_identifier(budget("%s_BK__%s" % (hub, "_".join(cols))), "bk_column")


def hash_key(vault_table_code):
    assert_identifier(vault_table_code, "hash_key")
    return vault_table_code + "_HK"


def hashdiff(satellite):
    """RATIFIED: <SAT>_HASHDIFF.

    A bare HASHDIFF collides the moment ONE model computes hashdiffs for more than one satellite,
    which is exactly what a multi-feed consolidated stage does. See keyrules.BUILDER_DECISIONS for
    the reasoning and the one-line switch.
    """
    assert_identifier(satellite, "hashdiff")
    return budget(satellite + "_HASHDIFF")


# =============================================================================== key rendering
def namespaced_bk(hub, bk_sql):
    """'HUB_X|' || (<bk>) -- the namespace that separates HUBS.

    MEASURED collision guard, not decoration: v2 emits md5(upper(HUB_ASSESSMENT_BK__SCRUTINY_NO))
    AND md5(upper(HUB_PROPOSAL_BK__SCRUTINY_NO)); the same column under two hubs collides without
    it. Legacy namespaces 1822 of 1822 declarations.
    """
    assert_identifier(hub, "namespaced_bk hub")
    return "%s || (%s)" % (sql_literal(hub + "|"), bk_sql)


def hash_expr(hub, bk_sql, namespace=True):
    """md5(upper('HUB_X|' || (<bk>))) -- EXPLICIT. No macro computes a hash in this build."""
    inner = namespaced_bk(hub, bk_sql) if namespace else "(%s)" % bk_sql
    return "md5(upper(%s))" % inner


# =============================================================================== child keys
def split_legs(declared):
    """Split a compound child-key declaration on ' + '.

    The map holds compound legs WHOLE -- 'Contact Point Type + Contact Priority Order' in ONE
    child_key string. A reader comparing that against a single declared leg scores 94 false
    disagreements on this map; the mapper's own matcher did exactly that and withdrew it.
    """
    if not isinstance(declared, str) or not declared.strip():
        return []
    return [p.strip() for p in RX_LEG_SPLIT.split(declared.strip()) if p.strip()]


def placeholder_column(value):
    """'{PARAM_REF}' -> 'PARAM_REF'; anything else -> None.

    A brace-wrapped ENGLISH PHRASE such as '{ADDEDCOVERS element}' is NOT a placeholder and must
    return None, because rendering it produces trim(addedcovers element): valid-looking SQL naming
    a column that cannot exist. The pattern requires a bare identifier INSIDE the braces, so the
    phrase form cannot pass -- this is the shape defence, not a word list.
    """
    if not isinstance(value, str):
        return None
    m = RX_PLACEHOLDER.match(value.strip())
    return m.group(1) if m else None


def looks_like_prose(value):
    """Shape test: would this token be prose if it reached an identifier position?"""
    return bool(isinstance(value, str) and RX_PROSE_SHAPE.search(value))


def vault_code(raw):
    """Pull the SAT_/REF_/HUB_/LNK_ code out of a field that may carry trailing prose.

    augmentation.new_satellite holds 20 distinct values / 131 rows where the identifier is followed
    by a description: 'SAT_COVERAGE_PREMIUM (per-coverage rated premium hanging off HUB_COVERAGE)'.
    Returns (code, had_prose). Returns (None, True) where there is no code at all -- e.g.
    'Product Configuration Parameter (name/value)', which is prose end to end.
    """
    if not isinstance(raw, str) or not raw.strip():
        return None, False
    s = raw.strip()
    m = RX_VAULT_CODE.match(s)
    if not m:
        return None, True
    return m.group(1), m.group(1) != s


# =============================================================================== probes
def probe_patterns():
    """Prove every pattern FIRES on a real corpus string and stays SILENT on a near-miss.

    check_patterns.py proves a pattern COMPILES. Only a probe proves it matches what its author
    meant (BUILD_RULES.md s1.1), and a pattern that cannot match reports a zero indistinguishable
    from a clean result.
    """
    cases = [
        ("RX_BARE_IDENT fires", RX_BARE_IDENT.match("HUB_CLAIM_BK__CLAIM_ID"), True),
        ("RX_BARE_IDENT silent on prose", RX_BARE_IDENT.match("addedcovers element"), False),
        ("RX_LEG_SPLIT fires on compound",
         len(RX_LEG_SPLIT.split("Contact Point Type + Contact Priority Order")) == 2, True),
        ("RX_LEG_SPLIT silent on single", len(RX_LEG_SPLIT.split("Bill Number")) == 1, True),
        ("RX_PLACEHOLDER fires", RX_PLACEHOLDER.match("{PARAM_REF}"), True),
        ("RX_PLACEHOLDER SILENT on brace-wrapped PHRASE",
         RX_PLACEHOLDER.match("{ADDEDCOVERS element}"), False),
        ("RX_PREFIX_SEED fires BA_HCP", RX_PREFIX_SEED.match("BA_HCP_DT_MEM"), True),
        ("RX_PREFIX_SEED fires BGIL", RX_PREFIX_SEED.match("BGIL_GMC_FINAL_INSTL_DATA"), True),
        ("RX_PREFIX_SEED silent on unprefixed", RX_PREFIX_SEED.match("HAT_POL_EMP_MAP"), False),
        ("RX_VAULT_CODE fires on code+prose",
         RX_VAULT_CODE.match("SAT_COVERAGE_PREMIUM (per-coverage rated premium)"), True),
        ("RX_VAULT_CODE silent on pure prose",
         RX_VAULT_CODE.match("Product Configuration Parameter (name/value)"), False),
        ("RX_PROSE_SHAPE fires on 'Policy Number (canonical contract key)'",
         RX_PROSE_SHAPE.search("Policy Number (canonical contract key)"), True),
        ("RX_PROSE_SHAPE silent on CLAIM_ID", RX_PROSE_SHAPE.search("CLAIM_ID"), False),
    ]
    for label, got, want in cases:
        if bool(got) != bool(want):
            raise AssertionError("PATTERN PROBE FAILED: %s (got %r, want %r)" % (label, got, want))

    # the length budget must be SHOWN to fire, or its digest branch is dead code
    long_a = "SAT_" + ("X" * 200) + "_ALPHA"
    long_b = "SAT_" + ("X" * 200) + "_BETA"
    ba, bb = budget(long_a), budget(long_b)
    if len(ba) != IDENT_BUDGET or ba == bb:
        raise AssertionError("length budget did not fire or is not injective: %r %r" % (ba, bb))

    # view naming, on real table names from the map's four prefixes
    checks = {"BJAZ_BFHL_DTLS": "bfhl_dtls", "BA_HCP_DT_MEM": "hcp_dt_mem",
              "BGIL_GMC_FINAL_INSTL_DATA": "bgil_gmc_final_instl_data",
              "STG_HEALTH_CLAIM": "stg_health_claim"}
    for raw, want in checks.items():
        got = view_stem(raw)
        if got != want:
            raise AssertionError("view_stem(%r) = %r, want %r" % (raw, got, want))

    if column("Pre-Existing Disease Description") != "PRE_EXISTING_DISEASE_DESCRIPTION":
        raise AssertionError("column() convention drifted")
    for bad in ("Policy Number (canonical contract key)",
                "SAT_CLAIM_BILL_LINE_ITEM — OCR-captured hospital bill particulars"):
        try:
            column(bad)
        except AssertionError:
            continue
        raise AssertionError("column() RENDERED PROSE: %r" % bad)

    if hash_expr("HUB_CLAIM", "nullif(trim(CLAIM_ID),'')") != \
            "md5(upper('HUB_CLAIM|' || (nullif(trim(CLAIM_ID),''))))":
        raise AssertionError("hash key form drifted from the ratified form")
    if hashdiff("SAT_POLICY_HEADER") != "SAT_POLICY_HEADER_HASHDIFF":
        raise AssertionError("hashdiff convention drifted")
    if sql_literal("O'Brien") != "'O''Brien'":
        raise AssertionError("apostrophe escaping is wrong")
    print("  hcon_names probes: %d pattern cases + budget + view + column + key + literal : PASS"
          % len(cases))
    return True


if __name__ == "__main__":
    probe_patterns()
    print("  abbreviation table (from profile.abbr_seed): %s" % ABBR)
