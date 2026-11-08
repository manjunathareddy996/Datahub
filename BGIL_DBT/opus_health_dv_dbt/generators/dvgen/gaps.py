"""Gap classification and the gap file ``build_artifacts/health_gaps.json``.

Classification (design, "Gap classification"):

| Situation                                              | Reason                         |
|--------------------------------------------------------|--------------------------------|
| Satellite parent empty after fallback                  | missing_parent                 |
| Child-key field absent on the satellite record         | missing_childkey_field         |
| Parent's key absent on the table and no bridge         | missing_grain_key              |
| Augmentation row whose table has no key slot for hub   | no_verified_augmentation_key   |
| Ambiguous anchor, refused or unresolved child-key leg, |                                |
| payload colliding with a child-key leg, do_not_build   |                                |
| or refused row, distinct values on a single-active     |                                |
| satellite, prose-only home                             | unresolved_mapping             |

Prior unresolved kinds carried by a Spec_JSON (``MappingRow.spec_unresolved``
or the spec's ``unresolved[]`` list) map through ``PRIOR_KIND_REASONS``.
A kind that is not in that table raises ``UnknownPriorKind``; it is never
mapped by guesswork. A kind mapped to ``None`` is known and is not a gap
(for example ``loader_has_no_feed_in_the_map``: no mapping row exists, the
README lists the object as "model object, not fed").

The gap file has schema ``health_gaps/v1``. Gaps are sorted by
(track, source_table, source_column, target, reason) via ``Gap.sort_key``;
watermark risks by ``WatermarkRisk.sort_key``. ``dump_gaps`` returns the
text; the caller writes it through ``emit.WriteGuard`` (or calls
``write_gaps`` with a guard).

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project (Requirement 10.3).

Requirements 8.2, 8.3.
"""
from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Optional

from .model import (
    GAP_REASONS,
    Gap,
    ModelError,
    WatermarkRisk,
    dumps,
    from_jsonable,
)

GAPS_SCHEMA = "health_gaps/v1"
GAPS_REL = "build_artifacts/health_gaps.json"

UNRESOLVED_MAPPING = "unresolved_mapping"
MISSING_GRAIN_KEY = "missing_grain_key"
MISSING_PARENT = "missing_parent"
MISSING_CHILDKEY_FIELD = "missing_childkey_field"
NO_VERIFIED_AUGMENTATION_KEY = "no_verified_augmentation_key"



class GapError(ModelError):
    """The gap file or a classification input is invalid."""


# Guard: the names above must be exactly the closed set in model.py.
if (UNRESOLVED_MAPPING, MISSING_GRAIN_KEY, MISSING_PARENT,
        MISSING_CHILDKEY_FIELD, NO_VERIFIED_AUGMENTATION_KEY) != GAP_REASONS:
    raise GapError("gaps.py reason names differ from model.GAP_REASONS")


class UnknownPriorKind(GapError):
    """A Spec_JSON prior-unresolved kind is not in the classification table."""

    def __init__(self, kind: object):
        self.kind = kind
        super().__init__(
            f"unknown prior unresolved kind {kind!r}; add it to "
            f"dvgen.gaps.PRIOR_KIND_REASONS with a reason from {GAP_REASONS} "
            f"(or None if it is not a gap)")


# --------------------------------------------------------------------------
# Classification
# --------------------------------------------------------------------------

# Planner situations (design table rows) -> reason.
SITUATION_REASONS: dict[str, str] = {
    "parent_empty": MISSING_PARENT,
    "childkey_field_absent": MISSING_CHILDKEY_FIELD,
    "no_grain_key": MISSING_GRAIN_KEY,
    "augmentation_no_key_slot": NO_VERIFIED_AUGMENTATION_KEY,
    "ambiguous_anchor": UNRESOLVED_MAPPING,
    "child_key_leg_refused": UNRESOLVED_MAPPING,
    "child_key_leg_unresolved": UNRESOLVED_MAPPING,
    "payload_collides_with_child_key_leg": UNRESOLVED_MAPPING,
    "do_not_build": UNRESOLVED_MAPPING,
    "refused_row": UNRESOLVED_MAPPING,
    "distinct_values_single_active": UNRESOLVED_MAPPING,
    "prose_only_home": UNRESOLVED_MAPPING,
}

# Prior unresolved kinds found in the Spec_JSONs -> reason (None = not a gap).
# hcon_spec.json ``unresolved[].kind`` values:
_HCON_PRIOR_KINDS: dict[str, Optional[str]] = {
    "anchor_not_keyed_on_this_view_in_legacy_sql": MISSING_GRAIN_KEY,
    "legacy_key_not_recoverable": MISSING_GRAIN_KEY,
    "view_has_no_recoverable_key_at_all": MISSING_GRAIN_KEY,
    "satellite_has_no_anchor": MISSING_PARENT,
    "multiple_registries_key_this_view_hub": UNRESOLVED_MAPPING,
    "child_key_leg_refused": UNRESOLVED_MAPPING,
    "payload_collides_with_child_key_leg": UNRESOLVED_MAPPING,
    "satellite_home_is_pure_prose": UNRESOLVED_MAPPING,
    "loader_has_no_feed_in_the_map": None,
}
# mxh3_spec.json ``unresolved[].kind`` values, plus the two row-level
# markers the adapter sets from ``blocks[].refuse_row`` and ``do_not_build``:
_MXH3_PRIOR_KINDS: dict[str, Optional[str]] = {
    "anchor_has_no_declared_expression_on_this_view": MISSING_GRAIN_KEY,
    "spine_display_rung_with_no_declared_walk": MISSING_GRAIN_KEY,
    "anchor_does_not_resolve_uniquely": UNRESOLVED_MAPPING,
    "child_key_leg_does_not_resolve_on_its_own_view": UNRESOLVED_MAPPING,
    "s54_payload_attribute_is_also_a_child_key_leg": UNRESOLVED_MAPPING,
    "refuse_row": UNRESOLVED_MAPPING,
    "do_not_build": UNRESOLVED_MAPPING,
}

PRIOR_KIND_REASONS: dict[str, Optional[str]] = {
    **_HCON_PRIOR_KINDS, **_MXH3_PRIOR_KINDS}

for _table in (SITUATION_REASONS, PRIOR_KIND_REASONS):
    for _k, _r in _table.items():
        if _r is not None and _r not in GAP_REASONS:
            raise GapError(f"classification table maps {_k!r} to {_r!r}")


def classify(situation: str) -> str:
    """Reason for a planner situation; raises ``GapError`` if unknown."""
    try:
        return SITUATION_REASONS[situation]
    except KeyError:
        raise GapError(
            f"unknown gap situation {situation!r}; known: "
            f"{sorted(SITUATION_REASONS)}") from None


def reason_for_prior_kind(kind: str) -> Optional[str]:
    """Reason for a Spec_JSON prior-unresolved kind.

    Returns ``None`` for a known kind that is not a gap. Raises
    ``UnknownPriorKind`` for any kind not in ``PRIOR_KIND_REASONS``.
    """
    if not isinstance(kind, str) or kind not in PRIOR_KIND_REASONS:
        raise UnknownPriorKind(kind)
    return PRIOR_KIND_REASONS[kind]


def gap_from_prior(kind: str, *, track: str, source_table: str,
                   source_column: Optional[str], target: str, detail: str,
                   row_ids: Iterable[str] = ()) -> Optional[Gap]:
    """Build the Gap for a prior-unresolved kind, or ``None`` if not a gap.

    The detail text is prefixed with the prior kind so the gap file says
    which Spec_JSON finding produced it.
    """
    reason = reason_for_prior_kind(kind)
    if reason is None:
        return None
    text = f"{kind}: {detail}" if detail else kind
    return Gap(track=track, source_table=source_table,
               source_column=source_column, target=target, reason=reason,
               detail=text, row_ids=tuple(row_ids))


# --------------------------------------------------------------------------
# Gap file
# --------------------------------------------------------------------------

@dataclass(frozen=True)
class GapFile:
    project: str
    gaps: tuple[Gap, ...]
    watermark_risks: tuple[WatermarkRisk, ...]


def _sorted_gaps(gaps: Iterable[Gap]) -> list[Gap]:
    return sorted(gaps, key=Gap.sort_key)


def _sorted_risks(risks: Iterable[WatermarkRisk]) -> list[WatermarkRisk]:
    return sorted(set(risks), key=WatermarkRisk.sort_key)


def dump_gaps(project: str, gaps: Iterable[Gap],
              watermark_risks: Iterable[WatermarkRisk] = ()) -> str:
    """Return the deterministic ``health_gaps.json`` text."""
    if not project:
        raise GapError("dump_gaps: project is empty")
    gap_list = _sorted_gaps(gaps)
    for g in gap_list:
        if not isinstance(g, Gap):
            raise GapError(f"dump_gaps: not a Gap: {g!r}")
    return dumps({
        "schema": GAPS_SCHEMA,
        "project": project,
        "reasons": list(GAP_REASONS),
        "gaps": gap_list,
        "watermark_risks": _sorted_risks(watermark_risks),
    })


def write_gaps(guard, project: str, gaps: Iterable[Gap],
               watermark_risks: Iterable[WatermarkRisk] = (),
               rel_path: str = GAPS_REL) -> str:
    """Write the gap file through an ``emit.WriteGuard``; return its sha256."""
    return guard.write(rel_path, dump_gaps(project, gaps, watermark_risks))


def parse_gaps(text: str) -> GapFile:
    """Parse ``health_gaps.json`` text, checking schema and reason set."""
    try:
        body = json.loads(text)
    except json.JSONDecodeError as exc:
        raise GapError(f"health_gaps.json is not valid JSON: {exc}") from None
    if not isinstance(body, dict):
        raise GapError("health_gaps.json: top level must be an object")
    expected = {"schema", "project", "reasons", "gaps", "watermark_risks"}
    if set(body) != expected:
        raise GapError(
            f"health_gaps.json: keys {sorted(body)}, expected "
            f"{sorted(expected)}")
    if body["schema"] != GAPS_SCHEMA:
        raise GapError(
            f"health_gaps.json: schema {body['schema']!r}, expected "
            f"{GAPS_SCHEMA!r}")
    if body["reasons"] != list(GAP_REASONS):
        raise GapError(
            f"health_gaps.json: reasons {body['reasons']!r}, expected "
            f"{list(GAP_REASONS)!r}")
    project = body["project"]
    if not isinstance(project, str) or not project:
        raise GapError("health_gaps.json: project must be a non-empty string")
    gaps = from_jsonable(tuple[Gap, ...], body["gaps"], "$.gaps")
    risks = from_jsonable(tuple[WatermarkRisk, ...], body["watermark_risks"],
                          "$.watermark_risks")
    return GapFile(project=project,
                   gaps=tuple(_sorted_gaps(gaps)),
                   watermark_risks=tuple(_sorted_risks(risks)))


def load_gaps(path) -> GapFile:
    """Read ``build_artifacts/health_gaps.json`` from ``path``."""
    return parse_gaps(Path(path).read_text(encoding="utf-8"))
