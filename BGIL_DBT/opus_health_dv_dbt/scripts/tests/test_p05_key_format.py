"""Property 5: Composite keys use one normalised format in every branch.

**Validates: Requirements 4.9, 4.10, 4.11, 4.12**
"""
import re
import sys
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import convert_stitches as c  # noqa: E402

SETTINGS = settings(max_examples=200, deadline=None)

IDENT = st.from_regex(r"[a-z][a-z0-9_]{0,10}", fullmatch=True).filter(lambda s: s not in {"null", "as"})
COMPLEX = st.builds(lambda i: f"nullif(trim({i}),'')", IDENT)
LIT_TEXT = st.text(alphabet=st.sampled_from(list("ABCxyz019 _-'")), min_size=0, max_size=8)
SEPS = st.sampled_from(c.SEPARATOR_CANDIDATES)

BK_COLS = ["PARTY_BK", "POLICY_BK", "CLAIM_BK"]
CK_COLS = ["S__KIND_CK", "S__TYPE_CK"]


def mk_branch(i, keys, cks):
    return c.Branch(index=i, table=f"T{i}", model=f"stg_health__t{i}", keys=keys, where="", prec=1000 + i,
                    columns={}, ck_columns=cks)


@st.composite
def sat_with_branches(draw):
    n_bk = draw(st.integers(1, 3))
    n_ck = draw(st.integers(0, 2))
    if n_bk == 1 and n_ck == 0:
        n_ck = 1  # class C needs a composite or child key
    bks, cks = BK_COLS[:n_bk], CK_COLS[:n_ck]
    sat = c.SatSpec(sat="S", klass=c.CLASS_C, key=c.KeySpec("s_pk", [], draw(SEPS)), payload=["S__V"],
                    branches=[], partition=bks + cks, ck_columns=cks)
    for i in range(draw(st.integers(1, 5))):
        keys = {k: draw(st.one_of(IDENT, COMPLEX)) for k in bks}
        ck = {}
        for k in cks:
            kind = draw(st.sampled_from(["lit", "data", "missing"]))
            if kind == "lit":
                ck[k] = c._quote(draw(LIT_TEXT))
            elif kind == "data":
                ck[k] = draw(st.one_of(IDENT, COMPLEX))
        sat.branches.append(mk_branch(i, keys, ck))
    return sat


def split_key(key, sep):
    return key.split(f" || '{sep}' || ")


def template(key, sep):
    """Replace the branch-specific expressions with placeholders."""
    out = []
    for piece in split_key(key, sep):
        if piece.startswith("coalesce(") and piece.endswith(f", '{c.SENTINEL}')"):
            out.append("COALESCE(E)")
        elif re.fullmatch(r"'(?:[^']|'')*'", piece):
            out.append("LIT")
        else:
            out.append("E")
    return out


@SETTINGS
@given(sat_with_branches())
def test_class_c_branches_share_one_template(sat):
    sep = sat.key.separator
    keys = [c.branch_key_column(sat, b) for b in sat.branches]
    shapes = {c.key_shape(c.branch_key_parts(sat, b), sep) for b in sat.branches}
    assert len(shapes) == 1
    for b, key in zip(sat.branches, keys):
        parts = c.branch_key_parts(sat, b)
        pieces = split_key(key, sep)
        assert len(pieces) == len(parts)                      # fixed part order / count
        for part, piece, name in zip(parts, pieces, sat.partition):
            assert part.tgt == name.lower()                   # fixed order
            if part.literal is not None:
                assert piece == c._quote(part.literal)        # quoted, unwrapped
                assert not piece.startswith("coalesce(")
            elif part.nullable:
                assert piece == f"coalesce({c._norm(part.expr)}, '{c.SENTINEL}')"
            else:
                assert piece == c._norm(part.expr)            # required leg plain
                assert not piece.startswith("coalesce(")
            if part.literal is None and not c._IDENT_RE.match(part.expr.strip()):
                assert c._norm(part.expr) == f"trim(to_varchar({part.expr.strip()}))"
    # placeholders: literal vs data-driven only differ at nullable positions
    for k in keys:
        assert len(template(k, sep)) == len(sat.partition)


@SETTINGS
@given(st.lists(st.tuples(st.one_of(IDENT, COMPLEX), st.booleans(), st.one_of(st.none(), LIT_TEXT)),
                min_size=1, max_size=5), SEPS)
def test_render_key_column_part_rules(spec, sep):
    parts = []
    for i, (expr, nullable, lit) in enumerate(spec):
        if lit is not None:
            parts.append(c.KeyPart(c._quote(lit), f"p{i}", True, literal=lit))
        else:
            parts.append(c.KeyPart(expr, f"p{i}", nullable))
    key = c.render_key_column(parts, sep)
    pieces = key.split(f" || '{sep}' || ")
    assert len(pieces) == len(parts)
    for p, piece in zip(parts, pieces):
        if p.literal is not None:
            assert piece == c._quote(p.literal)
        elif p.nullable:
            assert piece.startswith("coalesce(") and piece.endswith(f", '{c.SENTINEL}')")
        else:
            assert "coalesce" not in piece


@SETTINGS
@given(LIT_TEXT, IDENT, SEPS)
def test_literal_and_data_driven_branches_have_same_shape(lit, expr, sep):
    """A literal and a data-driven child key give the same template and position."""
    sat = c.SatSpec(sat="S", klass=c.CLASS_C, key=c.KeySpec("s_pk", [], sep), payload=[], branches=[
        mk_branch(0, {"POLICY_BK": "pn"}, {"S__KIND_CK": c._quote(lit)}),
        mk_branch(1, {"POLICY_BK": "pn"}, {"S__KIND_CK": expr}),
        mk_branch(2, {"POLICY_BK": "pn"}, {}),  # NULL child key
    ], partition=["POLICY_BK", "S__KIND_CK"], ck_columns=["S__KIND_CK"])
    k0, k1, k2 = (c.branch_key_column(sat, b) for b in sat.branches)
    assert k0 == f"pn || '{sep}' || {c._quote(lit)}"
    assert k1 == f"pn || '{sep}' || coalesce({expr}, '~')"
    assert k2 == f"pn || '{sep}' || coalesce({c._norm('cast(null as varchar)')}, '~')"
    assert len({c.key_shape(c.branch_key_parts(sat, b), sep) for b in sat.branches}) == 1


@st.composite
def link_with_branches(draw):
    n = draw(st.integers(2, 4))
    legs = BK_COLS[:3][:n] if n <= 3 else BK_COLS
    legs = draw(st.permutations(legs))
    optional = [x for x in legs if draw(st.booleans())]
    sep = draw(SEPS)
    lk = c.LinkSpec(link="LNK_X", legs=list(legs), optional=optional, branches=[],
                    key=c.KeySpec("x_lk", [], sep))
    for i in range(draw(st.integers(1, 5))):
        keys = {}
        for x in legs:
            if x not in optional or draw(st.booleans()):
                keys[x] = draw(st.one_of(IDENT, COMPLEX))
        lk.branches.append(mk_branch(i, keys, {}))
    return lk


@SETTINGS
@given(link_with_branches())
def test_link_keys_share_one_template(lk):
    sep = lk.key.separator
    shapes = {c.key_shape(c.link_branch_parts(lk, b), sep) for b in lk.branches}
    assert len(shapes) == 1
    for b in lk.branches:
        pieces = split_key(c.link_key_column(lk, b), sep)
        assert len(pieces) == len(lk.legs)
        for leg, piece in zip(lk.legs, pieces):
            if leg in lk.optional:
                assert piece.startswith("coalesce(") and piece.endswith(", '~')")
            else:
                assert not piece.startswith("coalesce(")
                assert piece == c._norm(b.keys[leg])
    assert len({tuple(template(c.link_key_column(lk, b), sep)) for b in lk.branches}) == 1
