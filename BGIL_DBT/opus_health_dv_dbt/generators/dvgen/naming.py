"""Naming conventions shared by every renderer (design "naming.py", Q10).

All functions are pure. Model names and hash-key names depend only on vault
codes and table stems, never on the project, so both Health_Projects emit the
same hub, link and satellite names and the same ``src_pk`` (Requirement 5.9).
Only ``record_source`` and ``source_tag`` take the project's
Record_Source_Prefix, and the prefix is passed in by the caller.

Conventions, as read from the Template_Project:

- ``HUB_LOCATION`` -> ``LOCATION_HKEY``; ``LNK_POLICY_PARTY`` -> ``POLICY_PARTY_HKEY``
- ``hub_<name>``, ``lnk_<name>``, ``sat_<name>``, ``sat_aug_<name>``, ``ref_<name>``
- ``stg2_hub_<stem>__<hub>``, ``stg2_link_<stem>__<link>``,
  ``stg2_sat_<stem>__<sat>[__<branch>]``, ``stg2_aug_<stem>__<sat>[__<branch>]``
- payload "Alternate Email Address" -> ``ALTERNATEEMAILADDRESS``
- ``RECORD_SOURCE`` ``'!' + prefix + TABLE``; stitch ``source_tag`` ``prefix + TABLE``

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project.
"""

from __future__ import annotations

import re
from collections.abc import Mapping

__all__ = [
    "NamingError",
    "hkey",
    "hub_model",
    "link_model",
    "sat_model",
    "ref_model",
    "stg1_model",
    "stg2_model",
    "bridge_model",
    "stitch_model",
    "payload_column",
    "ck_column",
    "record_source",
    "source_tag",
    "watermark_for",
]


class NamingError(ValueError):
    """An input cannot be turned into a valid name."""


# Upper-case vault-code prefixes that hkey() strips.
_HKEY_PREFIXES = ("HUB_", "LNK_")

# Prefixes stripped to get a bare lower-case name. Longest first, so that a
# satellite model name such as "sat_aug_location" reduces to "location".
_NAME_PREFIXES = ("sat_aug_", "hub_", "lnk_", "sat_", "ref_")

_NON_ALNUM = re.compile(r"[^A-Za-z0-9]")

_STG2_KINDS = ("hub", "link", "sat", "aug")
_SAT_TRACK_PREFIX = {"standard": "sat_", "augmented": "sat_aug_"}


def _require(value: str, what: str) -> str:
    if not isinstance(value, str) or not value.strip():
        raise NamingError(f"{what} is empty")
    return value.strip()


def _bare(code: str, what: str = "vault code") -> str:
    """Lower-case name without its HUB_/LNK_/SAT_/REF_ (or sat_aug_) prefix.

    Accepts a vault code (``SAT_CLAIM_NOTE``), a model name (``sat_claim_note``)
    or an already-bare name (``claim_note``).
    """
    name = _require(code, what).lower()
    for prefix in _NAME_PREFIXES:
        if name.startswith(prefix):
            name = name[len(prefix):]
            break
    if not name:
        raise NamingError(f"{what} {code!r} has no name after its prefix")
    return name


def hkey(code: str) -> str:
    """Hash-key column of a hub or link: ``HUB_CLAIM`` -> ``CLAIM_HKEY``."""
    upper = _require(code, "vault code").upper()
    for prefix in _HKEY_PREFIXES:
        if upper.startswith(prefix) and len(upper) > len(prefix):
            return f"{upper[len(prefix):]}_HKEY"
    raise NamingError(f"hkey() needs a HUB_ or LNK_ code, got {code!r}")


def hub_model(code: str) -> str:
    """``HUB_CLAIM`` -> ``hub_claim``."""
    return f"hub_{_bare(code)}"


def link_model(code: str) -> str:
    """``LNK_CLAIM_POLICY`` -> ``lnk_claim_policy``."""
    return f"lnk_{_bare(code)}"


def sat_model(code: str, track: str) -> str:
    """``sat_<name>`` on the standard track, ``sat_aug_<name>`` on the augmented one.

    Reference-track satellites are named with ``ref_model``.
    """
    try:
        prefix = _SAT_TRACK_PREFIX[track]
    except KeyError:
        raise NamingError(
            f"sat_model() track must be 'standard' or 'augmented', got {track!r}"
        ) from None
    return f"{prefix}{_bare(code)}"


def ref_model(code: str) -> str:
    """``REF_BANK_BRANCH_IFSC`` -> ``ref_bank_branch_ifsc``."""
    return f"ref_{_bare(code)}"


def stg1_model(stem: str) -> str:
    """Per-source-table staging model: ``stg_health__<stem>``."""
    return f"stg_health__{_require(stem, 'stem').lower()}"


def stg2_model(kind: str, stem: str, target: str, branch: str | None = None) -> str:
    """Stage model name.

    ``kind`` is ``hub``, ``link``, ``sat`` or ``aug`` (augmented satellite):
    ``stg2_<kind>_<stem>__<target>[__<branch>]``. A branch is only allowed on
    satellite stages.
    """
    if kind not in _STG2_KINDS:
        raise NamingError(f"stg2_model() kind must be one of {_STG2_KINDS}, got {kind!r}")
    name = f"stg2_{kind}_{_require(stem, 'stem').lower()}__{_bare(target, 'target')}"
    if branch is not None:
        if kind in ("hub", "link"):
            raise NamingError(f"stg2_model() branch is not allowed for kind {kind!r}")
        name += f"__{_require(branch, 'branch').lower()}"
    return name


def bridge_model(stem: str, hub: str) -> str:
    """``bridge_<stem>__<hub>``, e.g. ``bridge_claim_note__claim``."""
    return f"bridge_{_require(stem, 'stem').lower()}__{_bare(hub, 'hub')}"


def stitch_model(sat: str) -> str:
    """``stitch_<sat name>``: ``SAT_COMMON_ADDRESS`` -> ``stitch_common_address``."""
    return f"stitch_{_bare(sat, 'satellite')}"


def payload_column(attribute: str) -> str:
    """Attribute text with non-alphanumerics removed, upper-cased.

    "Alternate Email Address" -> ``ALTERNATEEMAILADDRESS``.
    """
    if not isinstance(attribute, str):
        raise NamingError(f"attribute must be a string, got {attribute!r}")
    name = _NON_ALNUM.sub("", attribute).upper()
    if not name:
        raise NamingError(f"attribute {attribute!r} has no alphanumeric characters")
    return name


def ck_column(childkey_part: str) -> str:
    """Child-key column name, same rule as ``payload_column``."""
    return payload_column(childkey_part)


def record_source(prefix: str, table: str) -> str:
    """Stage ``RECORD_SOURCE`` literal: ``'!' + prefix + TABLE``."""
    return f"!{source_tag(prefix, table)}"


def source_tag(prefix: str, table: str) -> str:
    """Stitch ``source_tag``: ``prefix + TABLE``."""
    return f"{_require(prefix, 'prefix')}{_require(table, 'table').upper()}"


def watermark_for(table: str, default: str, overrides: Mapping[str, str]) -> str:
    """The table's watermark column: its override if listed, else ``default``.

    ``overrides`` is keyed by upper-case table name. This is the only place the
    Builder resolves a table's watermark (stg1 select, ``LOAD_DATETIME``,
    stitch ``ldts_column``, reference ``LOAD_DATETIME``).
    """
    return overrides.get(_require(table, "table").upper(), default)
