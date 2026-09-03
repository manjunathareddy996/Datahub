# -*- coding: utf-8 -*-
"""Model and column naming for maximus_partner. ONE definition, shared by every generator.

THE PAYLOAD CONVENTION HERE IS SQUASHED, AND THAT IS NOT A TYPO.

`partner_dv_dbt` renders canonical attributes with the separators removed -- ADDRESSLINE1,
BUILDINGNAME, POSTALCODE, COMMISSIONSTRUCTURE, AGREEMENTTYPE. Every other sibling in this repo
renders UPPER_SNAKE. Measured over the satellites data_7 knows, against both renderings:

    partner_dv_dbt   squashed-only 131 · UPPER_SNAKE-only 19
    travel_dv_dbt    UPPER_SNAKE-only 102 · squashed-only 0
    health_dv_dbt    UPPER_SNAKE-only 411 · squashed-only 0
    motor_dv_dbt     UPPER_SNAKE-only 136 · squashed-only 0

We write partner_dv_dbt's physical tables, so we follow partner_dv_dbt. Carrying travel's
UPPER_SNAKE across would have opened a second column for every fact that already has one -- the
exact failure that cost 279 columns on travel and 720 on health, in the one project where the
majority convention runs the other way. `check_vault_alignment.py` DETECTS this from the sibling
rather than assuming, and it is what proves the choice.
"""
import hashlib
import re

# The partner shred's view names all share one long prefix; strip it before naming models.
_PREFIX = "BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL"
_ABBR = [
    ("_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY", "_prop_msdp"),
    ("_PARTY_PROPERTY_MULTI_SET_PROPERTY", "_prop_msp"),
    ("_PARTY_PROPERTY_SIMPLE_PROPERTY", "_prop_sp"),
    ("_ADDRESS_ADDRESS_PROPERTY", "_addr_prop"),
    ("_PARTY_ADDRESS", "_addr"),
    ("_DOCUMENT_DETAIL", "_doc"),
    ("_PARTY_RELATION", "_rel"),
    ("_RELATED_PARTY", "_relparty"),
    ("_PIVOT_VW_2_1", "_pv"), ("_PIVOT_VW", "_pv"), ("_VW_2_1", ""),
]


def model_name(table):
    s = table
    if s.startswith(_PREFIX):
        s = "pd" + s[len(_PREFIX):]
    for a, b in _ABBR:
        s = s.replace(a, b)
    return _fit(s.lower(), 44)


def _fit(name, budget):
    """Shorten to a budget WITHOUT losing uniqueness -- truncation alone is not injective."""
    if len(name) <= budget:
        return name
    return name[: budget - 7] + "_" + hashlib.md5(name.encode()).hexdigest()[:6]


def unpivot_name(model, short_sat):
    return _fit(f"unpivot_mp__{model}__{short_sat}", 70)


def stage_name(model):
    return _fit(f"stg2_mp__{model}", 70)


def up_stage_name(model, short_sat):
    return _fit("stg2_mp_up__" + unpivot_name(model, short_sat)[12:], 70)


def attr_col(a):
    """Canonical attribute -> payload column, in partner_dv_dbt's OWN convention: SQUASHED.

    See the module docstring. Do not 'fix' this to UPPER_SNAKE to match the other Maximus builds:
    the shared table is partner's, and partner writes POSTALCODE, not POSTAL_CODE.
    """
    return re.sub(r"[^A-Z0-9]", "", (a or "").upper())


def cdk_cols(name):
    """data_7 child-key NAME -> the src_cdk column list.

    '+' is data_7's COMPOSITE notation, not part of a name -- every prior build splits it.
    Rendered with attr_col because a child key IS a canonical attribute, so it follows the same
    per-sibling convention as the payload.
    """
    out = []
    for part in re.split(r"[|+]", name or ""):
        c = attr_col(part.strip())
        if c and c not in out:
            out.append(c)
    return out


def ident(col):
    """A source column as a SQL identifier.

    Partner ships `24_HR_POWER_BACKUP`; unquoted that is a syntax error, and the mapper flagged it
    in the handoff (feedback class 12). Anything that is not a legal bare identifier is emitted
    double-quoted; Snowflake folds unquoted names to upper case, hence the upper().
    """
    c = (col or "").strip()
    return c.lower() if re.fullmatch(r"[A-Za-z_][A-Za-z0-9_$]*", c) else '"' + c.upper() + '"'


def sql_str(v):
    """A string literal, apostrophes doubled."""
    return "'" + str(v).replace("'", "''") + "'"
