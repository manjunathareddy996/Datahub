"""Append-only ``README.md`` (the LOB_README) for a Health_Project.

``render_readme(existing, round_no, inputs)`` returns the full README text.
The caller writes it through ``emit.WriteGuard``.

Round sections
--------------
Each round is a block delimited by HTML comment markers::

    <!-- round:N start -->
    ## Round N
    ...
    <!-- round:N end -->

- A new round is appended after the existing text. Every earlier round is
  kept byte-for-byte except its heading line, which gains
  `` (superseded by Round N)`` the first time a later round is added.
- Re-rendering the latest round replaces that round's block in place, so a
  rebuild with the same inputs yields the same bytes (Requirement 10.2).
- Re-rendering a round older than the latest raises ``ReadmeError``:
  superseded rounds are history and are never rewritten.
- Text outside the markers (the preamble, or a hand-written README that
  predates the build) is kept as it is.

Round content (Requirements 3.8, 3.9, 4.4, 8.1, 8.4, 8.5): the rebuild
description; the Mapping_Inputs with sha256; the missing ``data_7.js`` and
schema snapshot; the Derived_Facts (hubs, links, satellite parent and child
key with origin, source locations, column types with origin, untyped columns,
legacy stems); the ``_HIST`` result; model objects not fed; risks R1 to R7
with their status; the accepted known risks (tables without watermark
evidence, and when ``record_source_overlap`` is given, the satellites shared
with the Template_Project); and "Documented gaps", rendered from
``plan.gaps``, the same list the gap file is written from.

Every list is sorted, and nothing depends on time or file-system order.
Project-specific wording comes from ``RoundInputs``; the defaults are the
settled design text.

This module is project-agnostic and is copied byte-for-byte into the sibling
Health_Project (Requirement 10.3).
"""
from __future__ import annotations

import re
from collections import Counter
from collections.abc import Iterable, Mapping
from dataclasses import dataclass, field
from typing import Any, Optional

from .model import GAP_REASONS, DerivedFact, Gap, ModelError, Plan

README_REL = "README.md"

__all__ = [
    "README_REL",
    "ReadmeError",
    "Risk",
    "DEFAULT_RISKS",
    "DEFAULT_DESCRIPTION",
    "DEFAULT_MISSING_INPUTS",
    "RoundInputs",
    "render_round",
    "render_readme",
    "round_numbers",
    "start_marker",
    "end_marker",
]


class ReadmeError(ModelError):
    """The README cannot be rendered or the existing text is inconsistent."""


@dataclass(frozen=True)
class Risk:
    id: str
    risk: str
    handling: str
    status: str


DEFAULT_RISKS: tuple[Risk, ...] = (
    Risk("R1",
         "MAXIMUS: inc_job_updated_at is not confirmed on any MAXIMUS health "
         "source; both MAXIMUS siblings use rec_refresh_at.",
         "WATERMARK_COLUMN = inc_job_updated_at is the default for every "
         "stg1. WATERMARK_OVERRIDES (empty) allows a per-table switch later.",
         "Decided: use inc_job_updated_at wherever possible; no overrides "
         "populated now. Run-time failures are recorded, not fixed by "
         "changing constants."),
    Risk("R2",
         "OPUS: DELTA3 tables in the catalogue without INC_JOB_UPDATED_AT, "
         "and tables with no catalogue at all.",
         "Keep the column in every stg1, with no substitute column. List the "
         "tables in watermark_risks and in this README.",
         "Accepted: the user handles those failures later."),
    Risk("R3",
         "Record-source group overlap: the group filter "
         "RECORD_SOURCE LIKE '<GROUP>_%' can also match rows another project "
         "writes to a shared satellite.",
         "Build with the configured RECORD_SOURCE_PREFIX and "
         "RECORD_SOURCE_GROUP. Shared satellites stay in the build: no "
         "exclusions, no stitch restrictions, no macro changes.",
         "Accepted as a known risk; constants stay as they are."),
    Risk("R4",
         "Raw database and schema are taken from siblings, not from any "
         "health artifact.",
         "Vars with sibling values, recorded as Derived_Facts.",
         "Accepted (confirmed at first dbt run)."),
    Risk("R5",
         "openpyxl missing.",
         "Installed with pip (user approved); prereqs.require stops with an "
         "install message if an import fails at build time.",
         "Decided: install approved."),
    Risk("R6",
         "Payload naming switches from the legacy UPPER_SNAKE to the "
         "template form.",
         "The Builder fails on any collision within one satellite and names "
         "both attributes.",
         "Accepted."),
    Risk("R7",
         "Only a few model links have mapped key rows.",
         "Unbuilt links are listed as model objects not fed; satellites on "
         "them become missing_grain_key gaps.",
         "Accepted."),
)

DEFAULT_DESCRIPTION = (
    "The bespoke generator build was archived to legacy_v3/ and replaced by "
    "an AutomateDV build that follows the conventions of the "
    "Template_Project ({template}). Every file under models/ is generated by "
    "generators/run_build.py from the Mapping_Inputs listed below; generated "
    "files are never edited by hand."
)

DEFAULT_MISSING_INPUTS: tuple[tuple[str, str], ...] = (
    ("data_7.js",
     "Not available. Hubs, links, satellite parents and child keys are "
     "Derived_Facts recovered from the Spec_JSON (and, as a fallback, the "
     "sibling Health_Project's extract)."),
    ("Source schema snapshot",
     "Not available. Column types are Derived_Facts from the tables index "
     "or the legacy staging SQL; columns with neither are cast as trimmed "
     "varchar and listed as untyped."),
)


def _pairs(value: Any, what: str) -> tuple[tuple[str, str], ...]:
    items = value.items() if isinstance(value, Mapping) else value
    out = []
    for item in items or ():
        a, b = item
        if not isinstance(a, str) or not isinstance(b, str):
            raise ReadmeError(f"RoundInputs.{what}: expected str pairs")
        out.append((a, b))
    return tuple(sorted(set(out)))


@dataclass(frozen=True)
class RoundInputs:
    """Everything one round section is rendered from."""
    project: str
    input_digests: tuple[tuple[str, str], ...]   # (relative path, sha256)
    plan: Plan
    shared_satellites: tuple[str, ...] = ()
    risks: tuple[Risk, ...] = DEFAULT_RISKS
    description: str = DEFAULT_DESCRIPTION
    missing_inputs: tuple[tuple[str, str], ...] = DEFAULT_MISSING_INPUTS
    watermark_column: str = "inc_job_updated_at"
    watermark_overrides: tuple[tuple[str, str], ...] = ()
    record_source_overlap: Optional[str] = None   # R3 note; set for OPUS
    template_project: str = "opus_partner_dv_dbt"
    extra_facts: tuple[DerivedFact, ...] = field(default=())

    def __post_init__(self) -> None:
        if not self.project:
            raise ReadmeError("RoundInputs.project is empty")
        if not isinstance(self.plan, Plan):
            raise ReadmeError("RoundInputs.plan must be a Plan")
        set_ = object.__setattr__
        set_(self, "input_digests", _pairs(self.input_digests,
                                           "input_digests"))
        set_(self, "watermark_overrides",
             _pairs(self.watermark_overrides, "watermark_overrides"))
        set_(self, "shared_satellites",
             tuple(sorted(set(self.shared_satellites))))
        set_(self, "risks", tuple(sorted(self.risks, key=_risk_key)))
        set_(self, "missing_inputs", tuple(self.missing_inputs))
        set_(self, "extra_facts", tuple(self.extra_facts))


def _risk_key(r: Risk) -> tuple:
    m = re.fullmatch(r"R(\d+)", r.id)
    return (0, int(m.group(1)), "") if m else (1, 0, r.id)


# --------------------------------------------------------------------------
# Markdown helpers
# --------------------------------------------------------------------------

def _cell(value: Any) -> str:
    if value is None:
        return ""
    text = str(value)
    text = text.replace("\r\n", "\n").replace("\r", "\n")
    text = text.replace("\\", "\\\\").replace("|", "\\|")
    text = text.replace("\n", "<br>").replace("<!--", "&lt;!--")
    return text


def _table(header: Iterable[str], rows: Iterable[Iterable[Any]],
           empty: str = "None.") -> str:
    head = list(header)
    body = [list(r) for r in rows]
    if not body:
        return empty
    lines = ["| " + " | ".join(_cell(h) for h in head) + " |",
             "|" + "|".join("---" for _ in head) + "|"]
    lines += ["| " + " | ".join(_cell(c) for c in r) + " |" for r in body]
    return "\n".join(lines)


def _childkey_text(value: Optional[str]) -> str:
    if value is None:
        return "(field absent)"
    if value == "":
        return "(single-active)"
    return value


# --------------------------------------------------------------------------
# Round section
# --------------------------------------------------------------------------

def start_marker(round_no: int) -> str:
    return f"<!-- round:{round_no} start -->"


def end_marker(round_no: int) -> str:
    return f"<!-- round:{round_no} end -->"


def _heading(round_no: int) -> str:
    return f"## Round {round_no}"


_HANDLED = ("hub", "link", "satellite_parent", "satellite_childkey",
            "source_location", "column_type", "untyped_column", "legacy_stem")


def _derived_facts(inputs: RoundInputs) -> str:
    facts = sorted(set(inputs.plan.derived_facts) | set(inputs.extra_facts),
                   key=DerivedFact.sort_key)
    by_cat: dict[str, list[DerivedFact]] = {}
    for f in facts:
        by_cat.setdefault(f.category, []).append(f)
    stg1 = sorted((a for a in inputs.plan.artifacts if a.kind == "stg1"),
                  key=lambda a: (str(a.data.get("table", "")), a.path))
    out = ["### Derived_Facts",
           "Every fact below was recovered from the Mapping_Inputs or legacy "
           "SQL. None is verified against `data_7.js` or a schema snapshot."]

    counts = Counter(f.category for f in facts)
    out.append(_table(("Category", "Facts"),
                      sorted(counts.items())))

    for cat, title in (("hub", "Hubs"), ("link", "Links")):
        rows = [(f.subject, f.origin, f.source) for f in by_cat.get(cat, ())]
        out += [f"#### {title} ({len(rows)})",
                _table((title[:-1], "Origin", "Source"), rows)]

    sats: dict[str, dict[str, DerivedFact]] = {}
    for cat in ("satellite_parent", "satellite_childkey"):
        for f in by_cat.get(cat, ()):
            sats.setdefault(f.subject, {})[cat] = f
    sat_rows = []
    for subject in sorted(sats):
        p = sats[subject].get("satellite_parent")
        c = sats[subject].get("satellite_childkey")
        sources = sorted({x.source for x in (p, c) if x is not None})
        sat_rows.append((
            subject,
            p.value if p else "", p.origin if p else "",
            _childkey_text(c.value) if c else "", c.origin if c else "",
            ", ".join(s for s in sources if s)))
    out += [f"#### Satellite parent and child key ({len(sat_rows)})",
            _table(("Satellite", "Parent", "Parent origin", "Child key",
                    "Child-key origin", "Source"), sat_rows)]

    rows = [(f.subject, f.value, f.origin, f.source)
            for f in by_cat.get("source_location", ())]
    out += [f"#### Source locations ({len(rows)})",
            _table(("Subject", "Value", "Origin", "Source"), rows)]

    type_rows = []
    for a in stg1:
        cols = a.data.get("columns", ())
        n = Counter(c.get("type_origin") for c in cols)
        type_rows.append((a.data.get("table", ""), a.data.get("stem", ""),
                          a.name, n["index"], n["legacy"], n["untyped"],
                          a.data.get("watermark", "")))
    out += [f"#### Column types by table ({len(type_rows)})",
            "Counts of columns by type origin (index = tables index, "
            "legacy = legacy staging SQL, untyped = neither). The watermark "
            "column is cast as timestamp_ntz.",
            _table(("Table", "Stem", "Stg1 model", "index", "legacy",
                    "untyped", "Watermark"), type_rows)]
    rows = [(f.subject, f.value, f.origin, f.source)
            for f in by_cat.get("column_type", ())]
    if rows:
        out += [f"#### Column type facts ({len(rows)})",
                _table(("Column", "Type", "Origin", "Source"), rows)]

    untyped = set()
    for a in stg1:
        for c in a.data.get("columns", ()):
            if c.get("type_origin") == "untyped":
                untyped.add((str(a.data.get("table", "")), str(c.get("name")),
                             ""))
    for f in by_cat.get("untyped_column", ()):
        table, _, column = f.subject.partition(".")
        untyped.add((table, column, f.source))
    merged: dict[tuple[str, str], str] = {}
    for table, column, source in sorted(untyped):
        key = (table, column)
        merged[key] = merged.get(key) or source
    rows = [(t, c, "nullif(trim(...), '')", s)
            for (t, c), s in sorted(merged.items())]
    out += [f"#### Untyped columns ({len(rows)})",
            "No type in the tables index or the legacy staging SQL; cast as "
            "trimmed varchar.",
            _table(("Table", "Column", "Cast", "Source"), rows)]

    rows = [(f.subject, f.value, f.origin, f.source)
            for f in by_cat.get("legacy_stem", ())]
    out += [f"#### Legacy stems ({len(rows)})",
            _table(("Table", "Stem", "Origin", "Source"), rows,
                   empty="None recorded.")]

    rows = [(f.category, f.subject, f.value, f.origin, f.source)
            for f in facts if f.category not in _HANDLED]
    if rows:
        out += [f"#### Other derived facts ({len(rows)})",
                _table(("Category", "Subject", "Value", "Origin", "Source"),
                       rows)]
    return "\n\n".join(out)


def _known_risks(inputs: RoundInputs) -> str:
    plan = inputs.plan
    out = ["### Accepted known risks",
           "#### Tables without watermark evidence",
           f"Every stg1 selects `{inputs.watermark_column}` unless the table "
           "has a WATERMARK_OVERRIDES entry. The tables below have no "
           "catalogue evidence of their watermark column, so their stg1 "
           "models can fail at `dbt run`. That failure is accepted and "
           "recorded; the constants are not changed in response.",
           f"{len(plan.watermark_risks)} tables.",
           _table(("Table", "Evidence", "Source"),
                  [(r.table, r.evidence, r.source)
                   for r in plan.watermark_risks]),
           "WATERMARK_OVERRIDES entries:",
           _table(("Table", "Watermark column"), inputs.watermark_overrides,
                  empty="None. To switch one table later, add "
                        "`\"<TABLE>\": \"<column>\"` to WATERMARK_OVERRIDES "
                        "in project_config.py and rebuild.")]
    if inputs.record_source_overlap is not None:
        out += ["#### Satellites shared with the Template_Project",
                inputs.record_source_overlap,
                f"{len(inputs.shared_satellites)} shared satellites.",
                _table(("Satellite",),
                       [(s,) for s in inputs.shared_satellites],
                       empty="None identified in this round.")]
    return "\n\n".join(out)


def _gaps(gaps: tuple[Gap, ...]) -> str:
    gaps = tuple(sorted(gaps, key=Gap.sort_key))
    counts = Counter(g.reason for g in gaps)
    return "\n\n".join([
        "### Documented gaps",
        "Rendered from the same list as build_artifacts/health_gaps.json. "
        "A blank source column marks a table- or satellite-level gap.",
        _table(("Reason", "Gaps"),
               [(r, counts[r]) for r in GAP_REASONS] + [("total", len(gaps))]),
        _table(("Track", "Source table", "Source column", "Target", "Reason",
                "Detail", "Rows"),
               [(g.track, g.source_table, g.source_column, g.target, g.reason,
                 g.detail, ", ".join(g.row_ids)) for g in gaps]),
    ])


def render_round(round_no: int, inputs: RoundInputs) -> str:
    """Return one round block, markers included, ending with ``\\n``."""
    _check_round(round_no)
    plan = inputs.plan
    parts = [
        start_marker(round_no),
        _heading(round_no),
        "### Rebuild",
        inputs.description.replace("{template}", inputs.template_project)
                          .replace("{project}", inputs.project),
        "### Mapping_Inputs",
        _table(("Input", "sha256"), inputs.input_digests),
        "### Missing inputs",
        _table(("Input", "Status"), inputs.missing_inputs),
        _derived_facts(inputs),
        "### `_HIST` tables",
        f"{len(plan.hist_skips)} `_HIST` tables skipped.",
        _table(("Skipped _HIST table", "Current table built"),
               plan.hist_skips, empty=""),
        "### Model objects not fed",
        f"{len(plan.not_fed)} model objects have no feed in the "
        "Mapping_Inputs and are not built.",
        _table(("Model object",), [(o,) for o in plan.not_fed], empty=""),
        "### Risks and decisions",
        _table(("ID", "Risk or decision", "Design handling", "Status"),
               [(r.id, r.risk, r.handling, r.status) for r in inputs.risks]),
        _known_risks(inputs),
        _gaps(plan.gaps),
        end_marker(round_no),
    ]
    return "\n\n".join(p for p in parts if p) + "\n"


# --------------------------------------------------------------------------
# Append-only assembly
# --------------------------------------------------------------------------

_BLOCK = re.compile(
    r"<!-- round:(\d+) start -->.*?<!-- round:\1 end -->(?:\r?\n)?", re.S)


def _check_round(round_no: Any) -> None:
    if isinstance(round_no, bool) or not isinstance(round_no, int) \
            or round_no < 1:
        raise ReadmeError(f"round number must be an int >= 1: {round_no!r}")


def _blocks(text: str) -> list[re.Match]:
    blocks = list(_BLOCK.finditer(text))
    numbers = [int(m.group(1)) for m in blocks]
    if numbers != sorted(set(numbers)):
        raise ReadmeError(f"README round blocks out of order or repeated: "
                          f"{numbers}")
    return blocks


def round_numbers(text: str) -> list[int]:
    """Round numbers present in README ``text``, in file order."""
    return [int(m.group(1)) for m in _blocks(text)]


def _supersede(block: str, old: int, new: int) -> str:
    heading = re.compile(rf"^## Round {old}(?P<tail>[^\r\n]*)$", re.M)
    m = heading.search(block)
    if m is None:
        raise ReadmeError(f"README Round {old} block has no heading")
    if "(superseded by Round" in m.group("tail"):
        return block
    return (block[:m.end()] + f" (superseded by Round {new})"
            + block[m.end():])


def _preamble(project: str) -> str:
    return (f"# {project}\n\n"
            "Health LOB Data Vault 2.0 dbt project. This README is "
            "append-only: each build round adds a section, and earlier "
            "rounds are only marked superseded.\n")


def render_readme(existing: Optional[str], round_no: int,
                  inputs: RoundInputs) -> str:
    """Return the README text with ``round_no`` rendered from ``inputs``.

    ``existing`` is the current README text, or ``None`` if there is none.
    """
    _check_round(round_no)
    section = render_round(round_no, inputs)
    if not existing:
        return _preamble(inputs.project) + "\n" + section
    blocks = _blocks(existing)
    numbers = [int(m.group(1)) for m in blocks]
    latest = max(numbers) if numbers else 0
    if round_no in numbers:
        if round_no != latest:
            raise ReadmeError(
                f"Round {round_no} is superseded by Round {latest}; "
                f"superseded rounds are not rewritten")
        m = blocks[numbers.index(round_no)]
        return existing[:m.start()] + section + existing[m.end():]
    if round_no < latest:
        raise ReadmeError(
            f"Round {round_no} is older than the latest Round {latest}")
    pieces, pos = [], 0
    for m in blocks:
        pieces.append(existing[pos:m.start()])
        pieces.append(_supersede(m.group(0), int(m.group(1)), round_no))
        pos = m.end()
    pieces.append(existing[pos:])
    text = "".join(pieces)
    if not text.endswith("\n"):
        text += "\n"
    return text + "\n" + section
