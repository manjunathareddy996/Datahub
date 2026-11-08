"""Unit tests for dvgen.readme (Requirements 3.8, 3.9, 4.4, 8.1, 8.4, 8.5)."""
from __future__ import annotations

import pytest

from dvgen.emit import WriteGuard
from dvgen.model import (
    GAP_REASONS,
    Artifact,
    DerivedFact,
    Gap,
    Plan,
    WatermarkRisk,
)
from dvgen.readme import (
    DEFAULT_RISKS,
    README_REL,
    ReadmeError,
    RoundInputs,
    end_marker,
    render_readme,
    render_round,
    round_numbers,
    start_marker,
)


def _stg1(table, cols):
    stem = table.lower()
    return Artifact(
        kind="stg1", path=f"models/staging/health/stg_health__{stem}.sql",
        name=f"stg_health__{stem}",
        data={"table": table, "stem": stem, "source": "src",
              "watermark": "inc_job_updated_at",
              "watermark_evidence": "catalogue_yes",
              "columns": [{"name": n, "kind": k, "type_origin": o,
                           "is_key": False} for n, k, o in cols]})


def _plan(gaps=(), **kw):
    return Plan(
        artifacts=(
            _stg1("T_ONE", [("A", "number", "index"),
                            ("B", "text", "untyped")]),
            _stg1("T_TWO", [("C", "timestamp", "legacy")]),
        ),
        gaps=tuple(gaps),
        derived_facts=(
            DerivedFact("hub", "HUB_CLAIM", None, "own_spec", "spec.json"),
            DerivedFact("link", "LNK_CLAIM_PARTY", None, "own_spec",
                        "spec.json"),
            DerivedFact("satellite_parent", "SAT_NOTE (standard)",
                        "HUB_CLAIM", "sibling_model", "sib/spec.json"),
            DerivedFact("satellite_childkey", "SAT_NOTE (standard)", "",
                        "own_spec", "spec.json"),
            DerivedFact("source_location", "raw_database", "OPUS_RAW",
                        "sibling_model", "sib/dbt_project.yml"),
            DerivedFact("legacy_stem", "BJAZ_CLM_AUTHR", "clm_authr",
                        "own_spec", "spec.json"),
        ),
        watermark_risks=(WatermarkRisk("T_TWO", "catalogue_no", "idx.json"),),
        **kw)


_GAPS = (
    Gap("standard", "T_ONE", "B", "SAT_NOTE.Note | text", "missing_parent",
        "café\nline two", ("m#1", "m#2")),
    Gap("augmented", "T_TWO", None, "SAT_X", "missing_childkey_field", "d",
        ()),
)


def _inputs(gaps=_GAPS, **kw):
    kw.setdefault("hist_skips", (("T_ONE_HIST", "T_ONE"),))
    kw.setdefault("not_fed", ("LNK_UNFED",))
    extra = {k: kw.pop(k) for k in list(kw)
             if k not in ("hist_skips", "not_fed")}
    return RoundInputs(
        project="opus_health_dv_dbt",
        input_digests=(("inputs/b.json", "bb" * 32),
                       ("inputs/a.json", "aa" * 32)),
        plan=_plan(gaps, **kw), **extra)


def test_round1_contains_required_sections():
    text = render_readme(None, 1, _inputs(
        record_source_overlap="LIKE 'OPUS_%' also matches OPUS_PARTNER_ rows.",
        shared_satellites=("SAT_B", "SAT_A")))
    assert text.startswith("# opus_health_dv_dbt\n")
    for heading in ("## Round 1", "### Rebuild", "### Mapping_Inputs",
                    "### Missing inputs", "### Derived_Facts", "#### Hubs (1)",
                    "#### Links (1)",
                    "#### Satellite parent and child key (1)",
                    "#### Source locations (1)", "#### Column types by table (2)",
                    "#### Untyped columns (1)", "#### Legacy stems (1)",
                    "### `_HIST` tables", "### Model objects not fed",
                    "### Risks and decisions", "### Accepted known risks",
                    "#### Tables without watermark evidence",
                    "#### Satellites shared with the Template_Project",
                    "### Documented gaps"):
        assert f"\n{heading}\n" in text, heading
    assert "| inputs/a.json | " + "aa" * 32 + " |" in text
    assert text.index("inputs/a.json") < text.index("inputs/b.json")
    assert "data_7.js" in text and "Source schema snapshot" in text
    assert "| SAT_NOTE (standard) | HUB_CLAIM | sibling_model | " \
           "(single-active) | own_spec |" in text
    assert "| T_ONE | B | nullif(trim(...), '') |" in text
    assert "| T_ONE | t_one | stg_health__t_one | 1 | 0 | 1 |" in text
    assert "1 `_HIST` tables skipped." in text
    assert "| T_ONE_HIST | T_ONE |" in text
    assert "| LNK_UNFED |" in text
    for risk in DEFAULT_RISKS:
        assert f"| {risk.id} | " in text
    assert "| T_TWO | catalogue_no | idx.json |" in text
    assert "LIKE 'OPUS_%'" in text
    assert text.index("| SAT_A |") < text.index("| SAT_B |")
    assert text.endswith(end_marker(1) + "\n")


def test_documented_gaps_agree_with_gap_list_and_escape_cells():
    text = render_round(1, _inputs())
    gaps_part = text[text.index("### Documented gaps"):]
    # Sorted by Gap.sort_key: augmented before standard.
    assert gaps_part.index("| augmented | T_TWO |  | SAT_X | "
                           "missing_childkey_field | d |  |") \
        < gaps_part.index("| standard | T_ONE | B | SAT_NOTE.Note \\| text "
                          "| missing_parent | café<br>line two | m#1, m#2 |")
    for reason in GAP_REASONS:
        assert f"| {reason} | " in gaps_part
    assert "| total | 2 |" in gaps_part


def test_no_hist_and_no_overlap_section_by_default():
    text = render_round(1, _inputs(gaps=(), hist_skips=(), not_fed=()))
    assert "0 `_HIST` tables skipped." in text
    assert "Satellites shared with the Template_Project" not in text
    assert "| total | 0 |" in text


def test_rerender_same_round_is_byte_identical():
    first = render_readme(None, 1, _inputs())
    assert render_readme(first, 1, _inputs()) == first


def test_new_round_appends_and_marks_previous_superseded():
    r1 = render_readme(None, 1, _inputs())
    r2 = render_readme(r1, 2, _inputs(gaps=()))
    assert round_numbers(r2) == [1, 2]
    expected_r1 = r1.replace("## Round 1\n",
                             "## Round 1 (superseded by Round 2)\n", 1)
    assert r2.startswith(expected_r1)
    assert r2.count(start_marker(2)) == 1
    # Re-running Round 2 replaces it; Round 1 keeps its single marker.
    again = render_readme(r2, 2, _inputs(gaps=()))
    assert again == r2
    r3 = render_readme(r2, 3, _inputs())
    assert "## Round 1 (superseded by Round 2)\n" in r3
    assert "## Round 2 (superseded by Round 3)\n" in r3
    assert "## Round 3\n" in r3


def test_superseded_round_is_not_rewritten():
    r2 = render_readme(render_readme(None, 1, _inputs()), 2, _inputs())
    with pytest.raises(ReadmeError):
        render_readme(r2, 1, _inputs())


def test_hand_written_text_is_kept():
    existing = "# Old notes\n\nkept as is"
    text = render_readme(existing, 1, _inputs())
    assert text.startswith(existing + "\n\n" + start_marker(1))


@pytest.mark.parametrize("bad", [0, -1, True, "1"])
def test_bad_round_number(bad):
    with pytest.raises(ReadmeError):
        render_round(bad, _inputs())


def test_written_through_write_guard(tmp_path):
    text = render_readme(None, 1, _inputs())
    WriteGuard(tmp_path).write(README_REL, text)
    assert (tmp_path / README_REL).read_text(encoding="utf-8") == text
