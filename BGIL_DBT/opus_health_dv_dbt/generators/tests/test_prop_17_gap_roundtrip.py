"""Property test for the gap file (``dvgen.gaps``) and the README gap table.

Feature: health-lob-dv-dbt-build, Property 17: Gap file round trip and README agreement

For any list of gaps, writing the gap file and reading it back yields the
same list (sorted by ``Gap.sort_key``), whatever order the gaps were given
in, and the README "Documented gaps" section lists exactly those gaps, one
row each, with source table, source column, target and reason, and the same
per-reason counts. Text fields include unicode, quotes, pipes, backslashes,
newlines and HTML-comment openers.

**Validates: Requirements 8.1, 8.2**
"""
from __future__ import annotations

import re
from collections import Counter

from hypothesis import given, settings
from hypothesis import strategies as st

from dvgen.gaps import GAPS_SCHEMA, dump_gaps, parse_gaps
from dvgen.model import GAP_REASONS, Gap, Plan, WatermarkRisk
from dvgen.readme import RoundInputs, end_marker, render_round

PROJECT = "opus_health_dv_dbt"

# Hand-picked fragments that stress JSON and Markdown escaping.
_TRICKY = st.sampled_from([
    "café", "naïve façade", "日本語のテキスト", "Ελληνικά", "emoji 🚑💊",
    "a | b", "||", "\\", "\\|", "back\\slash", '"double"', "'single'",
    "`tick`", "line one\nline two", "\r\n", "\r", "\n\n", "\t",
    "<!-- comment -->", "<br>", "&lt;!--", "&amp;", "# heading", "---",
    "*bold* _it_", "[link](x)", "{jinja}", "{{ ref('x') }}", "%s %d",
    "", " ", "  padded  ", "\u00a0nbsp", "zero\u200bwidth",
])
# Any unicode except lone surrogates (the gap file is written as UTF-8).
_ANY = st.text(alphabet=st.characters(exclude_categories=("Cs",)),
               max_size=20)
_TEXT = st.lists(st.one_of(_TRICKY, _ANY), max_size=4).map("".join)

_GAP = st.builds(
    Gap,
    track=st.sampled_from(["standard", "augmented", "hcon", "mxh3"]),
    source_table=_TEXT,
    source_column=st.one_of(st.none(), _TEXT),
    target=_TEXT,
    reason=st.sampled_from(GAP_REASONS),
    detail=_TEXT,
    row_ids=st.lists(_TEXT, max_size=3).map(tuple),
)
_RISK = st.builds(
    WatermarkRisk,
    table=_TEXT,
    evidence=st.sampled_from(["catalogue_no", "unknown"]),
    source=_TEXT,
)
# Duplicates are kept: the gap file and README list every gap given.
_GAPS = st.lists(_GAP, max_size=8).flatmap(
    lambda gs: st.lists(st.sampled_from(gs), max_size=3).map(
        lambda extra: gs + extra) if gs else st.just(gs))


# --------------------------------------------------------------------------
# README helpers (an independent statement of the cell format)
# --------------------------------------------------------------------------

_GAP_HEADER = ("| Track | Source table | Source column | Target | Reason | "
               "Detail | Rows |")
_COUNT_HEADER = "| Reason | Gaps |"
_CELL_PART = re.compile(r"(?:\\.|[^|\\])*")


def _expected_cell(value) -> str:
    """Cell text the README must show for ``value``."""
    if value is None:
        return ""
    text = str(value).replace("\r\n", "\n").replace("\r", "\n")
    text = text.replace("\\", "\\\\").replace("|", "\\|")
    return text.replace("\n", "<br>").replace("<!--", "&lt;!--")


def _split_row(line: str) -> list[str]:
    """Split a table row on unescaped pipes, dropping the padding spaces."""
    assert line.startswith("| ") and line.endswith(" |"), line
    inner = line[1:-1]
    parts, pos = [], 0
    while True:
        m = _CELL_PART.match(inner, pos)
        parts.append(m.group(0))
        pos = m.end()
        if pos >= len(inner):
            break
        assert inner[pos] == "|", line
        pos += 1
    cells = []
    for p in parts:
        assert p.startswith(" ") and p.endswith(" ") and len(p) >= 2, line
        cells.append(p[1:-1])
    return cells


def _table_rows(lines: list[str], header: str) -> list[list[str]]:
    starts = [i for i, ln in enumerate(lines) if ln == header]
    assert len(starts) == 1, f"{header!r} found {len(starts)} times"
    i = starts[0] + 1
    assert lines[i].startswith("|---"), lines[i]
    rows = []
    for ln in lines[i + 1:]:
        if not ln.startswith("|"):
            break
        rows.append(_split_row(ln))
    return rows


def _gap_section(gaps: list[Gap]) -> list[str]:
    plan = Plan(artifacts=(), gaps=tuple(gaps), derived_facts=(),
                watermark_risks=())
    text = render_round(1, RoundInputs(project=PROJECT, input_digests=(),
                                       plan=plan))
    lines = text.split("\n")
    heads = [i for i, ln in enumerate(lines) if ln == "### Documented gaps"]
    assert len(heads) == 1, heads
    stop = lines.index(end_marker(1))
    assert stop > heads[0]
    return lines[heads[0]:stop]


# --------------------------------------------------------------------------
# Properties
# --------------------------------------------------------------------------

@settings(max_examples=150, deadline=None)
@given(gaps=_GAPS, risks=st.lists(_RISK, max_size=4), seed=st.randoms())
def test_gap_file_round_trip_is_exact_and_order_independent(gaps, risks,
                                                            seed):
    text = dump_gaps(PROJECT, gaps, risks)
    # The file is written as UTF-8; the bytes must decode to the same text.
    text = text.encode("utf-8").decode("utf-8")
    parsed = parse_gaps(text)

    assert parsed.project == PROJECT
    assert list(parsed.gaps) == sorted(gaps, key=Gap.sort_key)
    assert list(parsed.watermark_risks) == sorted(
        set(risks), key=WatermarkRisk.sort_key)
    assert f'"schema": "{GAPS_SCHEMA}"' in text

    # Input order does not change the file.
    shuffled = list(gaps)
    seed.shuffle(shuffled)
    shuffled_risks = list(risks)
    seed.shuffle(shuffled_risks)
    assert dump_gaps(PROJECT, shuffled, shuffled_risks) == text
    # Dumping what was parsed reproduces the same bytes.
    assert dump_gaps(parsed.project, parsed.gaps,
                     parsed.watermark_risks) == text


@settings(max_examples=150, deadline=None)
@given(gaps=_GAPS, seed=st.randoms())
def test_readme_gap_table_lists_the_gap_file_gaps(gaps, seed):
    shuffled = list(gaps)
    seed.shuffle(shuffled)
    # The README is rendered from the list that was read back from the file.
    from_file = list(parse_gaps(dump_gaps(PROJECT, shuffled)).gaps)
    section = _gap_section(from_file)

    # One row per gap, same multiset, same order as the gap file.
    rows = _table_rows(section, _GAP_HEADER) if gaps else []
    expected = [[_expected_cell(v) for v in (
        g.track, g.source_table, g.source_column, g.target, g.reason,
        g.detail, ", ".join(g.row_ids))] for g in from_file]
    assert rows == expected
    assert Counter(map(tuple, rows)) == Counter(
        tuple(r) for r in [[_expected_cell(v) for v in (
            g.track, g.source_table, g.source_column, g.target, g.reason,
            g.detail, ", ".join(g.row_ids))] for g in gaps])
    if not gaps:
        assert _GAP_HEADER not in section

    # Per-reason counts and total agree with the gap file.
    counts = {r[0]: r[1] for r in _table_rows(section, _COUNT_HEADER)}
    file_counts = Counter(g.reason for g in from_file)
    assert counts == {**{r: str(file_counts[r]) for r in GAP_REASONS},
                      "total": str(len(from_file))}
    # Rendering is independent of input order too.
    assert _gap_section(shuffled) == section
