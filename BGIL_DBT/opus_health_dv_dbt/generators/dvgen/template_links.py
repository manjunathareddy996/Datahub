"""Hub order of the Template_Project's links (design "Link stage and link").

The planner orders the hub keys of a link the way the Template_Project's
link model lists its ``src_fk`` columns, when the template has that link;
otherwise it uses sorted hub codes. This module reads that order from the
template's link models, for example
``opus_partner_dv_dbt/models/raw_vault/standard/links/lnk_claim_party.sql``::

    src_pk: 'CLAIM_PARTY_HKEY'
    src_fk:
      - 'PARTY_HKEY'
      - 'CLAIM_HKEY'

gives ``{"LNK_CLAIM_PARTY": ("HUB_PARTY", "HUB_CLAIM")}``.

``project_config.py`` calls ``template_link_hub_order(<template links dir>)``
and stores the result as ``TEMPLATE_LINK_HUB_ORDER``; the planner reads that
attribute with ``getattr`` (default ``{}``). The mapping is a data table
(link code -> ordered hub codes), so the planner itself never reads files.

Functions are pure except ``template_link_hub_order``, which only reads.
This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project.
"""
from __future__ import annotations

import re
from pathlib import Path
from typing import Optional

__all__ = [
    "TemplateLinkError",
    "parse_link_model",
    "template_link_hub_order",
]

_HKEY_SUFFIX = "_HKEY"
_KEY_LINE = re.compile(r"^\s*(src_pk|src_fk)\s*:\s*(.*?)\s*$")
_ITEM_LINE = re.compile(r"^\s*-\s*['\"]?([A-Za-z0-9_]+)['\"]?\s*$")
_SCALAR = re.compile(r"^['\"]?([A-Za-z0-9_]+)['\"]?$")
_OTHER_KEY = re.compile(r"^\s*[A-Za-z_][A-Za-z0-9_]*\s*:")


class TemplateLinkError(ValueError):
    """A template link model does not have the expected src_pk/src_fk."""


def _code(hkey: str, prefix: str, where: str) -> str:
    upper = hkey.upper()
    if not upper.endswith(_HKEY_SUFFIX) or len(upper) == len(_HKEY_SUFFIX):
        raise TemplateLinkError(f"{where}: {hkey!r} is not a *_HKEY column")
    return prefix + upper[:-len(_HKEY_SUFFIX)]


def parse_link_model(text: str, where: str = "link model"
                     ) -> Optional[tuple[str, tuple[str, ...]]]:
    """``(link code, ordered hub codes)`` from one link model's yaml block.

    Returns ``None`` when the text has no ``src_pk`` (not a link model).
    Raises ``TemplateLinkError`` when ``src_fk`` is missing, empty or lists a
    hub twice.
    """
    pk: Optional[str] = None
    fks: list[str] = []
    in_fk = False
    seen_fk = False
    for line in text.splitlines():
        m = _KEY_LINE.match(line)
        if m:
            key, rest = m.groups()
            in_fk = False
            if key == "src_pk":
                s = _SCALAR.match(rest)
                if not s:
                    raise TemplateLinkError(f"{where}: unreadable src_pk {rest!r}")
                pk = s.group(1)
            else:
                seen_fk = True
                if rest:
                    s = _SCALAR.match(rest)
                    if not s:
                        raise TemplateLinkError(
                            f"{where}: unreadable src_fk {rest!r}")
                    fks.append(s.group(1))
                else:
                    in_fk = True
            continue
        if in_fk:
            item = _ITEM_LINE.match(line)
            if item:
                fks.append(item.group(1))
                continue
            if _OTHER_KEY.match(line) or line.strip().startswith("{%"):
                in_fk = False
    if pk is None:
        return None
    if not seen_fk or not fks:
        raise TemplateLinkError(f"{where}: src_pk {pk} without src_fk")
    link = _code(pk, "LNK_", where)
    hubs = tuple(_code(fk, "HUB_", where) for fk in fks)
    if len(set(hubs)) != len(hubs):
        raise TemplateLinkError(f"{where}: src_fk lists a hub twice: {hubs}")
    return link, hubs


def template_link_hub_order(links_dir: Path | str) -> dict[str, tuple[str, ...]]:
    """``{LNK_code: ordered hub codes}`` for every ``*.sql`` in ``links_dir``.

    Files are read in sorted name order. Two files for one link code must
    agree on the order. A missing folder gives ``{}``.
    """
    folder = Path(links_dir)
    if not folder.is_dir():
        return {}
    out: dict[str, tuple[str, ...]] = {}
    for path in sorted(folder.glob("*.sql"), key=lambda p: p.name):
        parsed = parse_link_model(path.read_text(encoding="utf-8"), path.name)
        if parsed is None:
            continue
        link, hubs = parsed
        if link in out and out[link] != hubs:
            raise TemplateLinkError(
                f"{path.name}: {link} hub order {hubs} differs from {out[link]}")
        out[link] = hubs
    return dict(sorted(out.items()))
