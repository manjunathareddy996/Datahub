"""Property 6: Key parts survive the composite key.

**Validates: Requirements 4.9, 4.12**
"""
import re
import sys
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import convert_stitches as c  # noqa: E402

SEPS = c.SEPARATOR_CANDIDATES
_COALESCE = re.compile(r"^coalesce\((\w+), '~'\)$")
_LITERAL = re.compile(r"^'((?:[^']|'')*)'$")


def evaluate_key(expr: str, sep: str, row: dict):
    """Reference evaluator of the rendered composite key (SQL `||` NULL semantics)."""
    out = []
    for piece in expr.split(f" || '{sep}' || "):
        m = _COALESCE.match(piece)
        if m:
            v = row.get(m.group(1))
            out.append("~" if v is None else v)
            continue
        m = _LITERAL.match(piece)
        if m:
            out.append(m.group(1).replace("''", "'"))
            continue
        v = row.get(piece)
        if v is None:
            return None  # NULL part makes the whole key NULL
        out.append(v)
    return sep.join(out)


def evaluate_columns(cols: list[dict], row: dict) -> dict:
    res = {}
    for col in cols:
        m = _LITERAL.match(col["src"])
        res[col["tgt"]] = m.group(1).replace("''", "'") if m else row.get(col["src"])
    return res


def clean(sep):
    return st.text(alphabet=st.characters(blacklist_categories=("Cs",), blacklist_characters=sep + "'"),
                   min_size=1, max_size=12).filter(lambda s: s != "~" and s == s.strip())


@st.composite
def scenario(draw):
    sep = draw(st.sampled_from(SEPS))
    n_bk = draw(st.integers(1, 3))
    n_ck = draw(st.integers(0, 2))
    parts, row, expected = [], {}, {}
    for i in range(n_bk):
        name = f"bk{i}"
        parts.append(c.KeyPart(expr=f"src_bk{i}", tgt=name, nullable=False))
        row[f"src_bk{i}"] = draw(clean(sep))
        expected[name] = row[f"src_bk{i}"]
    for i in range(n_ck):
        name = f"ck{i}"
        kind = draw(st.sampled_from(["col", "literal"]))
        if kind == "literal":
            lit = draw(clean(sep))
            parts.append(c.KeyPart(expr=c._quote(lit), tgt=name, nullable=True, literal=lit))
            expected[name] = lit
        else:
            val = draw(st.one_of(st.none(), clean(sep)))
            parts.append(c.KeyPart(expr=f"src_ck{i}", tgt=name, nullable=True))
            row[f"src_ck{i}"] = val
            expected[name] = val
    return sep, parts, row, expected


@settings(max_examples=200, deadline=None)
@given(scenario())
def test_key_parts_survive_composite_key(s):
    sep, parts, row, expected = s
    key = evaluate_key(c.render_key_column(parts, sep), sep, row)
    pieces = key.split(sep)
    assert len(pieces) == len(parts)
    for part, piece in zip(parts, pieces):
        want = expected[part.tgt]
        assert piece == ("~" if want is None else want)

    got = evaluate_columns(c.key_part_columns(parts), row)
    assert got == expected


@settings(max_examples=100, deadline=None)
@given(st.sampled_from(SEPS), st.lists(clean("|^#@$`"), min_size=2, max_size=5), st.data())
def test_link_legs_recoverable(sep, values, data):
    """Every leg of a link key is recoverable from the key and its leg columns."""
    optional = [data.draw(st.booleans()) for _ in values]
    parts = [c.KeyPart(expr=f"leg{i}", tgt=f"leg{i}_bk", nullable=o) for i, o in enumerate(optional)]
    row = {f"leg{i}": (None if (o and data.draw(st.booleans())) else v)
           for i, (v, o) in enumerate(zip(values, optional))}
    key = evaluate_key(c.render_key_column(parts, sep), sep, row)
    legs = evaluate_columns(c.key_part_columns(parts), row)
    for i, piece in enumerate(key.split(sep)):
        leg = row[f"leg{i}"]
        assert piece == ("~" if leg is None else leg)
        assert legs[f"leg{i}_bk"] == leg
