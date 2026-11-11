"""Property 17: Staging edit is a minimal one-line insertion.

For any staging text without the column and with a parseable select list, the edited text
is the original with exactly one line inserted; deleting it restores the original bytes
(LF or CRLF); the line is the template with the anchor's indentation.

**Validates: Requirements 6.3, 7.1, 7.3, 7.4**
"""
import sys
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from add_inc_job_updated_at import PLAIN_EXPR, STATUS_CHANGED, edit_stg  # noqa: E402

col_names = st.text(alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ_", min_size=1, max_size=12).filter(
    lambda c: c != "INC_JOB_UPDATED_AT")
indents = st.sampled_from(["", " ", "  ", "    ", "\t", "        ", "\t\t"])
aliases = st.sampled_from(["lower", "same", "x_"])


@st.composite
def stg_texts(draw):
    nl = draw(st.sampled_from(["\n", "\r\n"]))
    cols = draw(st.lists(col_names, min_size=1, max_size=8, unique=True))
    indent = draw(indents)
    final_nl = draw(st.booleans())
    bom = draw(st.sampled_from(["", "\ufeff"]))
    items = []
    for i, c in enumerate(cols):
        a = draw(aliases)
        alias = {"lower": c.lower(), "same": c.lower(), "x_": "x_" + c.lower()}[a]
        items.append(f'{indent}"{c}"::varchar as {alias}' + ("," if i < len(cols) - 1 else ""))
    # BOM, if any, is the first character of the file.
    lines = ([bom + "{{ config(materialized='view') }}", "", "select"]
             + items + ["from {{ source('raw', 'T1') }}"])
    return nl.join(lines) + (nl if final_nl else "")


@settings(max_examples=200, deadline=None)
@given(stg_texts())
def test_edit_is_minimal_one_line_insertion(text):
    out, res = edit_stg(text)
    assert res.status == STATUS_CHANGED

    orig = text.encode("utf-8")
    new = out.encode("utf-8")
    old_lines = text.splitlines(keepends=True)
    new_lines = out.splitlines(keepends=True)
    assert len(new_lines) == len(old_lines) + 1

    i = res.anchor_line
    # Removing the inserted line restores the original bytes exactly.
    restored = "".join(new_lines[:i] + new_lines[i + 1:])
    assert restored.encode("utf-8") == orig
    assert len(new) > len(orig)

    # Inserted line = anchor indentation + template + file newline style.
    nl = "\r\n" if "\r\n" in text else "\n"
    anchor = old_lines[i]
    indent = anchor[: len(anchor) - len(anchor.lstrip())]
    assert new_lines[i] == indent + PLAIN_EXPR + nl
    # The anchor line itself (and every other line) is unchanged, including the last item.
    assert new_lines[i + 1] == anchor
