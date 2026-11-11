"""One-shot converter for the Health stitched models (task 7.1: data models and parser).

This module currently provides the data models and `parse(text)`, which reads one
original `stitch_vNN_*.sql` (a `union all` of `-- branch N: TABLE` selects followed by
a final select with `first_value ... ignore nulls over (partition by ...)`).

It does not write any model file. Run it as a smoke test over the originals:

    python scripts/convert_stitches.py [--stitches-dir DIR] [--report PATH]

An unparsable stitch gets an entry in the report, is skipped, and the exit code is 1.
`generators/` is neither edited nor imported.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DEFAULT_DIR = PROJECT_ROOT / "models" / "raw_vault" / "standard" / "stitched"
DEFAULT_REPORT = Path(__file__).resolve().parent / "conversion_report.json"


# --------------------------------------------------------------------------- data models
@dataclass
class KeyPart:
    expr: str                  # SQL expression of the part (raw, not coalesced)
    tgt: str                   # Key_Part_Column name, lower case (policy_bk, ..._ck)
    nullable: bool             # True -> wrapped in coalesce(expr, '~') inside the key
    literal: str | None = None  # set for a literal child key


@dataclass
class KeySpec:
    unique_key: str            # filled by the classifier (task 7.2); '' after parse
    parts: list[KeyPart]       # fixed order
    separator: str = "|"


@dataclass
class Branch:
    index: int                 # "-- branch N"
    table: str                 # BJAZ_ENROLL_SCR_DTLS
    model: str                 # stg_health__bjaz_enroll_scr_dtls
    keys: dict[str, str]       # non-null key column -> expression (e.g. POLICY_BK)
    where: str                 # original filter, verbatim ('' when absent)
    prec: int                  # __PREC literal
    columns: dict[str, str]    # payload column -> source expression (non-null only)
    ck_literal: str | None = None   # first literal child key, or None
    ck_data_driven: bool = False    # any data-driven child key
    # extras beyond the design sketch (needed by the classifier / link detection)
    ck_columns: dict[str, str] = field(default_factory=dict)  # CK column -> expression (non-null)
    links: list[str] = field(default_factory=list)            # non-null __LNK_* markers


@dataclass
class SatSpec:
    sat: str                   # SAT prefix as in the column names, e.g. POLICY_CLASSIFICATION
    klass: str                 # '' after parse; 'A' | 'B' | 'C' | 'LINK' | 'HUB' after classify
    key: KeySpec
    payload: list[str]         # payload columns (prefixed, upper case), original order
    branches: list[Branch]     # branches that fill any payload or CK column of this satellite
    partition: list[str] = field(default_factory=list)   # partition-by columns of its windows
    ck_columns: list[str] = field(default_factory=list)  # partition columns that are child keys
    fallback: bool = False     # True -> Fallback_Stitch (set by classify; last resort)


@dataclass
class Finding:
    file: str
    branch: int | None
    construct: str
    fallback: bool = False     # True -> kept as Fallback_Stitch


@dataclass
class ParsedStitch:
    file: str
    header: list[str]                  # header comment lines, verbatim
    fed_sats: list[str]                # satellites listed under "Satellites fed WHOLE"
    fed_links: list[str]               # links listed under "Links whose legs ..."
    columns: list[str]                 # final select output columns, in order
    key_columns: list[str]             # *_BK columns
    link_markers: list[str]            # __LNK_* columns
    branches: list[Branch]
    sats: list[SatSpec]
    partitions: dict[str, list[str]]   # payload column -> partition-by columns
    final_select: str                  # final select text, verbatim


class ParseError(Exception):
    def __init__(self, construct: str, branch: int | None = None):
        super().__init__(construct)
        self.construct = construct
        self.branch = branch


# --------------------------------------------------------------------------- helpers
_NULL_RE = re.compile(r"^(?:cast\s*\(\s*null\s+as\s+[\w ]+(?:\([\d, ]*\))?\s*\)|null)$", re.I)
_ALIAS_RE = re.compile(r"^(?P<expr>.*\S)\s+as\s+(?P<alias>\w+)$", re.I | re.S)
_BRANCH_RE = re.compile(r"--\s*branch\s+(\d+)\s*:\s*(\S+)")
_REF_RE = re.compile(r"\bfrom\s+\{\{\s*ref\(\s*'([^']+)'\s*\)\s*\}\}(.*)$", re.I | re.S)
_FIRST_VALUE_RE = re.compile(
    r"^first_value\s*\(\s*(?P<col>\w+)\s*\)\s+ignore\s+nulls\s+over\s*\(\s*partition\s+by\s+"
    r"(?P<part>.*?)\s+order\s+by\b.*\)\s+as\s+(?P<alias>\w+)$",
    re.I | re.S,
)
_LITERAL_RE = re.compile(r"^'(?:[^']|'')*'$")


def is_null_expr(expr: str) -> bool:
    return bool(_NULL_RE.match(expr.strip()))


def split_top_level(text: str, sep: str = ",") -> list[str]:
    """Split on `sep` outside parentheses and single-quoted strings."""
    parts, depth, cur, i, n = [], 0, [], 0, len(text)
    while i < n:
        ch = text[i]
        if ch == "'":
            j = i + 1
            while j < n:
                if text[j] == "'":
                    if j + 1 < n and text[j + 1] == "'":
                        j += 2
                        continue
                    break
                j += 1
            cur.append(text[i : j + 1])
            i = j + 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        if ch == sep and depth == 0:
            parts.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
        i += 1
    tail = "".join(cur).strip()
    if tail:
        parts.append(tail)
    return parts


def _strip_line_comments(text: str) -> str:
    """Drop whole-line `--` comments (inline `--` is not used in the originals)."""
    return "\n".join(l for l in text.splitlines() if not l.lstrip().startswith("--"))


def _split_alias(item: str, ctx: str, branch: int | None) -> tuple[str, str]:
    m = _ALIAS_RE.match(item.strip())
    if not m:
        raise ParseError(f"select item without alias in {ctx}: {item[:80]!r}", branch)
    return m.group("expr").strip(), m.group("alias")


def _header_and_lists(text: str) -> tuple[list[str], list[str], list[str]]:
    header: list[str] = []
    for line in text.splitlines():
        if line.lstrip().startswith("--"):
            header.append(line.rstrip())
        elif line.strip() == "":
            continue
        else:
            break
    sats: list[str] = []
    links: list[str] = []
    cur: list[str] | None = None
    for line in header:
        body = line.lstrip()[2:]
        s = body.strip()
        if re.match(r"^Satellites fed", s, re.I):
            cur = sats
        elif re.match(r"^Links whose legs", s, re.I):
            cur = links
        elif body.startswith("   ") and cur is not None and re.match(r"^[A-Z][A-Z0-9_]*$", s):
            cur.append(s)
        else:
            cur = None
    return header, sats, links


def _find_sections(text: str) -> tuple[str, str]:
    """Return (merged CTE body, final select text)."""
    m = re.search(r"with\s+merged\s+as\s*\(", text, re.I)
    if not m:
        raise ParseError("missing 'with merged as (' CTE")
    close = re.search(r"^\)[ \t]*\r?\n\s*select\b", text[m.end():], re.I | re.M)
    if not close:
        raise ParseError("missing closing ')' of merged CTE before final select")
    body = text[m.end() : m.end() + close.start()]
    final = text[m.end() + close.start() + 1 :].lstrip()
    return body, final


def _parse_final(final: str) -> tuple[list[str], dict[str, list[str]]]:
    m = re.match(r"select\b(?P<items>.*?)\bfrom\s+merged\b", final, re.I | re.S)
    if not m:
        raise ParseError("final select does not end with 'from merged'")
    columns: list[str] = []
    partitions: dict[str, list[str]] = {}
    for item in split_top_level(_strip_line_comments(m.group("items"))):
        fv = _FIRST_VALUE_RE.match(item)
        if fv:
            if fv.group("col").upper() != fv.group("alias").upper():
                raise ParseError(f"first_value column/alias mismatch: {item[:80]!r}")
            alias = fv.group("alias").upper()
            partitions[alias] = [p.strip().upper() for p in split_top_level(fv.group("part"))]
            columns.append(alias)
        elif re.fullmatch(r"\w+", item):
            columns.append(item.upper())
        else:
            raise ParseError(f"unsupported final select item: {item[:80]!r}")
    if not columns:
        raise ParseError("empty final select")
    return columns, partitions


def _parse_branch(chunk: str, ck_cols: set[str]) -> Branch:
    bm = _BRANCH_RE.search(chunk)
    if not bm:
        raise ParseError("chunk without '-- branch N: TABLE' comment")
    idx, table = int(bm.group(1)), bm.group(2)
    rest = chunk[bm.end():]
    sm = re.search(r"\bselect\b", rest, re.I)
    if not sm:
        raise ParseError("branch without select", idx)
    after = rest[sm.end():]
    fm = _REF_RE.search(after)
    # the `from` must be the first top-level `from {{ ref(...) }}` after the item list
    if not fm:
        raise ParseError("branch without 'from {{ ref(...) }}'", idx)
    items_text = _strip_line_comments(after[: fm.start()])
    model, tail = fm.group(1), fm.group(2).strip()
    where = ""
    if tail:
        wm = re.match(r"where\b(.*)$", tail, re.I | re.S)
        if not wm:
            raise ParseError(f"unsupported clause after from: {tail[:60]!r}", idx)
        where = wm.group(1).strip()

    keys: dict[str, str] = {}
    columns: dict[str, str] = {}
    ck_columns: dict[str, str] = {}
    links: list[str] = []
    prec: int | None = None
    for item in split_top_level(items_text):
        expr, alias = _split_alias(item, f"branch {idx}", idx)
        a = alias.upper()
        if a == "__PREC":
            if not re.fullmatch(r"\d+", expr):
                raise ParseError(f"__PREC is not an integer literal: {expr!r}", idx)
            prec = int(expr)
        elif a == "__RID":
            continue
        elif a.startswith("__LNK_"):
            if not is_null_expr(expr):
                links.append(a)
        elif "__" not in a:   # key column: *_BK, or an unprefixed key such as ROLE_TYPE_CODE
            if not is_null_expr(expr):
                keys[a] = expr
        elif a in ck_cols:
            if not is_null_expr(expr):
                ck_columns[a] = expr
        else:
            if not is_null_expr(expr):
                columns[a] = expr
    if prec is None:
        raise ParseError("branch without __PREC", idx)
    lits = [e for e in ck_columns.values() if _LITERAL_RE.match(e)]
    return Branch(
        index=idx, table=table, model=model, keys=keys, where=where, prec=prec,
        columns=columns,
        ck_literal=lits[0][1:-1].replace("''", "'") if lits else None,
        ck_data_driven=any(not _LITERAL_RE.match(e) for e in ck_columns.values()),
        ck_columns=ck_columns, links=links,
    )


# --------------------------------------------------------------------------- parse
def parse(text: str, file: str = "") -> ParsedStitch:
    """Parse one original stitch. Raises ParseError when the shape is not recognised."""
    text = text.replace("\r\n", "\n")
    header, fed_sats, fed_links = _header_and_lists(text)
    body, final = _find_sections(text)
    columns, partitions = _parse_final(final)

    # satellite prefix -> partition columns; child keys = partition columns that are not *_BK
    sat_part: dict[str, list[str]] = {}
    sat_payload: dict[str, list[str]] = {}
    for col, part in partitions.items():
        if "__" not in col:
            raise ParseError(f"windowed column without satellite prefix: {col}")
        prefix = col.split("__", 1)[0]
        if prefix in sat_part and sat_part[prefix] != part:
            raise ParseError(f"satellite {prefix} has differing partition clauses")
        sat_part[prefix] = part
        sat_payload.setdefault(prefix, []).append(col)
    ck_cols = {p for part in sat_part.values() for p in part if "__" in p}

    chunks = [c for c in re.split(r"\n\s*union\s+all\s*\n", body, flags=re.I) if c.strip()]
    branches = [_parse_branch(c, ck_cols) for c in chunks]
    if not branches:
        raise ParseError("no branches found")
    idxs = [b.index for b in branches]
    if idxs != list(range(len(idxs))):
        raise ParseError(f"branch numbering is not 0..N-1: {idxs}")

    sats: list[SatSpec] = []
    for prefix, payload in sat_payload.items():
        part = sat_part[prefix]
        cks = [p for p in part if p in ck_cols]
        fills = [
            b for b in branches
            if any(c in b.columns for c in payload) or any(c in b.ck_columns for c in cks)
        ]
        parts = [KeyPart(expr=p, tgt=p.lower(), nullable=p in ck_cols) for p in part]
        sats.append(SatSpec(
            sat=prefix, klass="", key=KeySpec(unique_key="", parts=parts), payload=payload,
            branches=fills, partition=part, ck_columns=cks,
        ))

    return ParsedStitch(
        file=file, header=header, fed_sats=fed_sats, fed_links=fed_links, columns=columns,
        key_columns=[c for c in columns if "__" not in c],
        link_markers=[c for c in columns if c.startswith("__LNK_")],
        branches=branches, sats=sats, partitions=partitions, final_select=final.rstrip(),
    )


# --------------------------------------------------------------------------- classification (task 7.2)
SEPARATOR = "|"
SENTINEL = "~"
SEPARATOR_CANDIDATES = ["|", "^", "#", "@", "$", "`"]
DEFAULT_LINKS_DIR = PROJECT_ROOT / "models" / "raw_vault" / "standard" / "links"
_IDENT_RE = re.compile(r"^\w+$")
_UNSUPPORTED_RE = re.compile(
    r"\bover\s*\(|\b(?:count|sum|min|max|avg|listagg|row_number|rank|dense_rank|lag|lead)\s*\(", re.I
)

CLASS_A, CLASS_B, CLASS_C, CLASS_LINK, CLASS_HUB = "A", "B", "C", "LINK", "HUB"


@dataclass
class LinkSpec:
    link: str                      # LNK_POLICY_COVERAGE
    legs: list[str]                # key columns, fixed order (POLICY_BK, ...)
    optional: list[str]            # legs that are absent in at least one branch (coalesced)
    branches: list[Branch]
    key: KeySpec                   # unique_key '<link sans lnk_>_lk'
    klass: str = CLASS_LINK
    inferred: bool = False         # True when built from key columns without a __LNK_ marker
    fallback: bool = False


@dataclass
class HubSpec:
    key_column: str                # POLICY_BK
    branches: list[Branch]
    key: KeySpec                   # unique_key = lower-case key column
    klass: str = CLASS_HUB


@dataclass
class Plan:
    file: str
    sats: list[SatSpec]
    links: list[LinkSpec]
    hubs: list[HubSpec]
    findings: list[Finding]
    separators: dict[str, str] = field(default_factory=dict)   # name -> non-default separator

    def counts(self) -> dict:
        sats = [s for s in self.sats if not s.fallback]
        return {
            "A": sum(1 for s in sats if s.klass == CLASS_A),
            "B": sum(1 for s in sats if s.klass == CLASS_B),
            "B_parts": sum(len(literal_tuples(s)) for s in sats if s.klass == CLASS_B),
            "C": sum(1 for s in sats if s.klass == CLASS_C),
            "LINK": sum(1 for x in self.links if not x.fallback),
            "HUB": len(self.hubs),
            "FALLBACK": sum(1 for s in self.sats if s.fallback) + sum(1 for x in self.links if x.fallback),
        }


def _is_literal(expr: str) -> bool:
    return bool(_LITERAL_RE.match(expr.strip()))


def _unquote(lit: str) -> str:
    return lit.strip()[1:-1].replace("''", "'")


def _quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def _norm(expr: str) -> str:
    """Normalise a key part: stg1 columns (identifiers) are already trimmed varchar."""
    e = expr.strip()
    if _IDENT_RE.match(e) or _is_literal(e):
        return e
    return f"trim(to_varchar({e}))"


def render_key_column(parts: list[KeyPart], sep: str = SEPARATOR) -> str:
    """The single renderer of every composite / link key expression.

    Fixed part order and separator; a nullable part is `coalesce(<expr>, '~')`; a literal is a
    quoted, unwrapped string (same string as the wrapped form); other parts are plain, so a NULL
    required part makes the whole key NULL and the macro drops the row.
    """
    if not parts:
        raise ValueError("no key parts")
    if "'" in sep or not sep:
        raise ValueError(f"invalid separator {sep!r}")
    pieces = []
    for p in parts:
        if p.literal is not None:
            pieces.append(_quote(p.literal))
        elif p.nullable:
            pieces.append(f"coalesce({_norm(p.expr)}, '{SENTINEL}')")
        else:
            pieces.append(_norm(p.expr))
    return f" || '{sep}' || ".join(pieces)


def key_part_columns(parts: list[KeyPart]) -> list[dict]:
    """Key_Part_Columns: the raw (non-coalesced) key parts as `{src, tgt}` payload columns."""
    return [
        {"src": _quote(p.literal) if p.literal is not None else p.expr.strip(), "tgt": p.tgt}
        for p in parts
    ]


def key_shape(parts: list[KeyPart], sep: str = SEPARATOR) -> tuple:
    """Expression-independent template of a key; equal for every branch of one satellite."""
    return (sep, tuple((p.tgt, p.nullable) for p in parts))


def _bk_parts(sat: SatSpec) -> list[str]:
    return [p for p in sat.partition if p not in sat.ck_columns]


def literal_tuples(sat: SatSpec) -> list[tuple[str, ...]]:
    """Distinct literal child-key tuples of a class B satellite, in first-seen order."""
    seen: dict[tuple[str, ...], None] = {}
    for b in sat.branches:
        if all(c in b.ck_columns and _is_literal(b.ck_columns[c]) for c in sat.ck_columns):
            seen.setdefault(tuple(_unquote(b.ck_columns[c]) for c in sat.ck_columns), None)
    return list(seen)


def classify_sat(sat: SatSpec) -> str:
    """A: one hub key; B: hub key + literal child keys only; C: composite or data-driven keys."""
    if len(_bk_parts(sat)) >= 2:
        return CLASS_C
    if not sat.ck_columns:
        return CLASS_A
    for b in sat.branches:
        for c in sat.ck_columns:
            if c not in b.ck_columns or not _is_literal(b.ck_columns[c]):
                return CLASS_C
    return CLASS_B


def sat_unique_key(sat: SatSpec) -> str:
    if sat.klass in (CLASS_A, CLASS_B):
        return _bk_parts(sat)[0].lower()
    return f"{sat.sat.lower()}_pk"


def branch_key_parts(sat: SatSpec, b: Branch) -> list[KeyPart] | None:
    """Key parts of one branch for a class C satellite; None when a business key part is missing."""
    parts: list[KeyPart] = []
    for p in sat.partition:
        if p in sat.ck_columns:
            e = b.ck_columns.get(p)
            if e is None:
                parts.append(KeyPart(expr="cast(null as varchar)", tgt=p.lower(), nullable=True))
            elif _is_literal(e):
                parts.append(KeyPart(expr=e, tgt=p.lower(), nullable=True, literal=_unquote(e)))
            else:
                parts.append(KeyPart(expr=e, tgt=p.lower(), nullable=True))
        else:
            e = b.keys.get(p)
            if e is None:
                return None
            parts.append(KeyPart(expr=e, tgt=p.lower(), nullable=False))
    return parts


def branch_key_column(sat: SatSpec, b: Branch) -> str | None:
    """key_column for a branch of a satellite (verbatim for A and B, composite for C)."""
    if sat.klass in (CLASS_A, CLASS_B):
        return b.keys.get(_bk_parts(sat)[0])
    parts = branch_key_parts(sat, b)
    return None if parts is None else render_key_column(parts, sat.key.separator)


def _pick_separator(values: list[str] | None) -> str | None:
    """First candidate separator absent from every observed value; None if all collide."""
    for cand in SEPARATOR_CANDIDATES:
        if not values or all(cand not in v for v in values):
            return cand
    return None


def _apply_profile(name: str, key: KeySpec, profile: dict | None, plan_sep: dict, findings: list[Finding],
                   file: str) -> bool:
    """Value-profile hook: switch the separator for the whole satellite; False if impossible."""
    values = [str(v) for v in (profile or {}).get(name, [])]
    if not values:
        return True
    sep = _pick_separator(values)
    if sep is None:
        findings.append(Finding(file, None, f"{name}: every candidate separator occurs in the data",
                                fallback=True))
        return False
    if sep != SEPARATOR:
        key.separator = sep
        plan_sep[name] = sep
    if SENTINEL in values:
        findings.append(Finding(file, None, f"{name}: real value equals the '~' NULL sentinel"))
    return True


def load_link_defs(links_dir: Path | None = DEFAULT_LINKS_DIR) -> dict[str, list[str]]:
    """LNK_X -> leg key columns (X_HKEY in `src_fk` becomes X_BK), read from the link models."""
    defs: dict[str, list[str]] = {}
    if not links_dir or not Path(links_dir).is_dir():
        return defs
    for f in sorted(Path(links_dir).glob("lnk_*.sql")):
        m = re.search(r"src_fk:\s*\n((?:\s*-\s*'[^']+'\s*\n)+)", f.read_text(encoding="utf-8").replace("\r\n", "\n"))
        if m:
            defs[f.stem.upper()] = [
                re.sub(r"_HKEY$", "_BK", x.upper()) for x in re.findall(r"'([^']+)'", m.group(1))
            ]
    return defs


def _guess_legs(link: str, key_cols: list[str]) -> list[str]:
    """Fallback when the link model is unknown: key columns whose entity occurs in the link name."""
    name = link[4:] if link.startswith("LNK_") else link
    alias = {"DISTRIBUTION_CHANNEL": "CHANNEL", "FINANCIAL_TRANSACTION": "FINTXN"}
    out = []
    for k in sorted(key_cols):
        ent = k[:-3] if k.endswith("_BK") else k
        if ent in name or alias.get(ent, "\0") in name:
            out.append(k)
    return out


def _unsupported(expr: str) -> bool:
    return bool(_UNSUPPORTED_RE.search(re.sub(r"'(?:[^']|'')*'", "''", expr)))


def _classify_links(p: ParsedStitch, defs: dict[str, list[str]], profile, plan_sep, findings):
    groups: dict[str, tuple[list[str], list[Branch], bool]] = {}
    unmarked: list[Branch] = []   # multi-BK branches without link marker: keys go to hubs/satellites
    for b in p.branches:
        for m in b.links:
            link = "LNK_" + m[len("__LNK_"):]
            legs = defs.get(link)
            if not legs:
                legs = _guess_legs(link, list(b.keys))
                if link not in groups:
                    findings.append(Finding(p.file, b.index, f"{link}: link model unknown, legs guessed"))
            groups.setdefault(link, (legs, [], False))[1].append(b)
        non_bk = sorted(k for k in b.keys if not k.endswith("_BK"))
        if not b.links and non_bk and any(k.endswith("_BK") for k in b.keys):
            # key row with a non-BK key part (e.g. PARTY_BK + ROLE_TYPE_CODE): a link row without marker
            bks = sorted(k for k in b.keys if k.endswith("_BK"))
            ent = [k[:-3] for k in bks] + [re.sub(r"(_TYPE)?_CODE$", "", k) for k in non_bk]
            groups.setdefault("LNK_" + "_".join(ent), (bks + non_bk, [], True))[1].append(b)
        elif not b.links:
            n_bk = [k for k in b.keys if k.endswith("_BK")]
            if len(n_bk) >= 2:
                unmarked.append(b)
    out: list[LinkSpec] = []
    for link, (legs, branches, inferred) in groups.items():
        if not legs:
            findings.append(Finding(p.file, branches[0].index, f"{link}: cannot determine link legs", fallback=True))
            out.append(LinkSpec(link, [], [], branches, KeySpec(link[4:].lower() + "_lk", []), fallback=True,
                                inferred=inferred))
            continue
        present = [x for x in legs if any(x in b.keys for b in branches)]
        if not present:
            findings.append(Finding(p.file, branches[0].index, f"{link}: no branch carries a leg", fallback=True))
            out.append(LinkSpec(link, legs, [], branches, KeySpec(link[4:].lower() + "_lk", []), fallback=True,
                                inferred=inferred))
            continue
        optional = [x for x in present if any(x not in b.keys for b in branches)]
        ks = KeySpec(unique_key=link[4:].lower() + "_lk",
                     parts=[KeyPart(expr=x, tgt=x.lower(), nullable=x in optional) for x in present])
        spec = LinkSpec(link, present, optional, branches, ks, inferred=inferred)
        if any(_unsupported(e) for b in branches for x in present if (e := b.keys.get(x))):
            findings.append(Finding(p.file, branches[0].index, f"{link}: key expression uses window/aggregate",
                                    fallback=True))
            spec.fallback = True
        elif not _apply_profile(link, ks, profile, plan_sep, findings, p.file):
            spec.fallback = True
        out.append(spec)
    return out, unmarked


def link_branch_parts(link: LinkSpec, b: Branch) -> list[KeyPart]:
    return [
        KeyPart(expr=b.keys.get(x, "cast(null as varchar)"), tgt=x.lower(), nullable=x in link.optional)
        for x in link.legs
    ]


def link_key_column(link: LinkSpec, b: Branch) -> str:
    return render_key_column(link_branch_parts(link, b), link.key.separator)


def classify(obj, *, link_defs: dict[str, list[str]] | None = None, profile: dict | None = None):
    """classify(SatSpec) -> class letter ('A' | 'B' | 'C'); also sets klass and unique_key.

    classify(ParsedStitch) -> Plan with classified satellites, link groups, hub-only keys and
    Findings. `profile` maps a satellite/link name to observed key values (separator hook).
    """
    if isinstance(obj, SatSpec):
        obj.klass = classify_sat(obj)
        obj.key.unique_key = sat_unique_key(obj)
        return obj.klass
    p: ParsedStitch = obj
    defs = load_link_defs() if link_defs is None else link_defs
    findings: list[Finding] = []
    plan_sep: dict[str, str] = {}
    for s in p.sats:
        classify(s)
        bad = False
        for b in s.branches:
            exprs = [b.keys.get(k) for k in _bk_parts(s)] + [b.ck_columns.get(c) for c in s.ck_columns]
            if any(e and _unsupported(e) for e in exprs):
                findings.append(Finding(p.file, b.index, f"{s.sat}: key expression uses window/aggregate",
                                        fallback=True))
                bad = True
        if s.klass == CLASS_C and not bad:
            for b in s.branches:
                if all(k in b.keys for k in _bk_parts(s)):
                    continue
                if any(k in b.keys for k in _bk_parts(s)):
                    findings.append(Finding(p.file, b.index,
                                            f"{s.sat}: branch lacks part of the composite business key",
                                            fallback=True))
                    bad = True
        if not bad and s.klass == CLASS_C:
            bad = not _apply_profile(s.sat, s.key, profile, plan_sep, findings, p.file)
        s.fallback = bad
    links, unmarked = _classify_links(p, defs, profile, plan_sep, findings)

    covered: dict[int, set[str]] = {b.index: set() for b in p.branches}
    for s in p.sats:
        for b in s.branches:
            covered[b.index].update(k for k in _bk_parts(s) if k in b.keys)
    for lk in links:
        for b in lk.branches:
            covered[b.index].update(x for x in lk.legs if x in b.keys)
    hubs: dict[str, list[Branch]] = {}
    for b in p.branches:
        for k in b.keys:
            if k.endswith("_BK") and k not in covered[b.index]:
                hubs.setdefault(k, []).append(b)
    for b in unmarked:
        loose = [k for k in b.keys if k.endswith("_BK") and k not in covered[b.index]]
        if len(loose) >= 2:
            findings.append(Finding(p.file, b.index,
                                    "keys " + ", ".join(sorted(loose)) + " in one row without link marker: "
                                    "emitted per hub, not as link legs"))
    hub_specs = [
        HubSpec(k, bs, KeySpec(k.lower(), [KeyPart(expr=k, tgt=k.lower(), nullable=False)]))
        for k, bs in sorted(hubs.items())
    ]
    return Plan(file=p.file, sats=p.sats, links=links, hubs=hub_specs, findings=findings, separators=plan_sep)


# --------------------------------------------------------------------------- renderers (task 7.3)
# O5 decision (documented): target_sat of a link part is the link model name (`lnk_<x>`) and of a
# hub-only part the hub model name (`hub_<x>`), lower case, as the design says. The macro only uses it
# for `adapter.get_relation(...)` and, when the relation exists, `MAX(DBT_RUN_TS) ... RECORD_SOURCE LIKE
# 'OPUS_%'`. A relation that does not exist yields the 1900-01-01 sentinel (full reload). Whether the
# link/hub tables expose DBT_RUN_TS is left to the Compile_Check.
LDTS_COLUMN = "inc_job_updated_at"
SOURCE_SYSTEM = "OPUS"


@dataclass
class PartModel:
    name: str                       # model name, e.g. stitch_aug_policy_classification
    kind: str                       # 'A' | 'B' | 'C' | 'LINK' | 'HUB' | 'FALLBACK'
    text: str                       # file content
    unique_key: str = ""
    target_sat: str = ""
    output_columns: list[str] = field(default_factory=list)
    provides: dict[str, str] = field(default_factory=dict)    # original UPPER column -> part column
    constants: dict[str, str] = field(default_factory=dict)   # original UPPER column -> SQL literal
    owner: str = ""                 # satellite / link / hub the part belongs to


def _pystr(s: str) -> str:
    """Jinja/Python string literal for a SQL fragment (single line)."""
    s = re.sub(r"\s*\n\s*", " ", s.strip())
    if "'" not in s:
        return "'" + s + "'"
    if '"' not in s and "\\" not in s:
        return '"' + s + '"'
    return "'" + s.replace("\\", "\\\\").replace("'", "\\'") + "'"


def _slug(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")


def _split_and(where: str) -> list[str]:
    """Split a filter on top-level `and` (outside parentheses and quotes)."""
    out, depth, cur, i, n = [], 0, [], 0, len(where)
    while i < n:
        ch = where[i]
        if ch == "'":
            j = i + 1
            while j < n and not (where[j] == "'" and (j + 1 >= n or where[j + 1] != "'")):
                j += 2 if where[j] == "'" else 1
            cur.append(where[i : j + 1])
            i = j + 1
            continue
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        m = re.match(r"\s+and\s+", where[i:], re.I) if depth == 0 else None
        if m:
            out.append("".join(cur).strip())
            cur = []
            i += m.end()
            continue
        cur.append(ch)
        i += 1
    out.append("".join(cur).strip())
    return [x for x in out if x]


def _extra_where(b: Branch) -> str:
    """Conjuncts of the branch filter that are not plain `<expr> is not null` key checks."""
    if not b.where:
        return ""
    extra = []
    for c in _split_and(b.where):
        if not re.search(r"\bis\s+not\s+null\s*$", c, re.I):
            extra.append(c)
    return " and ".join(extra)


def _guard(b: Branch, key: str) -> str:
    """Fold a non-key branch filter into the key so the macro drops the row (original semantics)."""
    extra = _extra_where(b)
    return f"case when {extra} then {key} end" if extra else key


def _source_tag(b: Branch) -> str:
    return f"{SOURCE_SYSTEM}_" + re.sub(r"[^A-Za-z0-9]+", "_", b.table).upper()


def _render_call(header: list[str], sources: list[dict], output_columns: list[str],
                 coalesce_rules: dict[str, list[str]], unique_key: str, target_sat: str) -> str:
    deps: list[str] = []
    for s in sources:
        if s["model"] not in deps:
            deps.append(s["model"])
    lines = ["{{ config(materialized='view') }}"]
    lines += header
    lines += [f"-- depends_on: {{{{ ref('{m}') }}}}" for m in deps]
    lines.append("")
    lines.append("{%- set sources = [")
    for si, s in enumerate(sources):
        lines.append("    {")
        lines.append(f"      'model': {_pystr(s['model'])},")
        lines.append(f"      'alias': {_pystr(s['alias'])},")
        lines.append(f"      'key_column': {_pystr(s['key_column'])},")
        lines.append(f"      'ldts_column': {_pystr(LDTS_COLUMN)},")
        lines.append(f"      'source_tag': {_pystr(s['source_tag'])},")
        lines.append("      'columns': [")
        for ci, c in enumerate(s["columns"]):
            comma = "," if ci < len(s["columns"]) - 1 else ""
            lines.append(f"        {{'src': {_pystr(c['src'])}, 'tgt': {_pystr(c['tgt'])}}}{comma}")
        lines.append("      ]")
        lines.append("    }" + ("," if si < len(sources) - 1 else ""))
    lines.append("] -%}")
    lines.append("{%- set output_columns = [")
    for i, c in enumerate(output_columns):
        lines.append(f"    {_pystr(c)}" + ("," if i < len(output_columns) - 1 else ""))
    lines.append("] -%}")
    lines.append("{%- set coalesce_rules = {")
    for i, c in enumerate(output_columns):
        al = ", ".join(_pystr(a) for a in coalesce_rules[c])
        lines.append(f"    {_pystr(c)}: [{al}]" + ("," if i < len(output_columns) - 1 else ""))
    lines.append("} %}")
    lines.append("")
    lines += [
        "{{ stitch_incremental(",
        "    sources=sources,",
        "    output_columns=output_columns,",
        "    coalesce_rules=coalesce_rules,",
        f"    unique_key={_pystr(unique_key)},",
        f"    target_sat={_pystr(target_sat)}",
        ") }}",
    ]
    return "\n".join(lines) + "\n"


def _assemble(header: list[str], items: list[tuple[Branch, str, list[dict]]], unique_key: str,
              target_sat: str, extra_out: list[str] | None = None) -> tuple[str, list[str]]:
    """items: (branch, key_column, columns). Returns (text, output_columns)."""
    items = sorted(items, key=lambda it: it[0].index)
    sources = []
    for n, (b, key, cols) in enumerate(items):
        sources.append({"model": b.model, "alias": f"t{n}", "key_column": key,
                        "source_tag": _source_tag(b), "columns": cols, "_branch": b})
    # output columns: first appearance order across sources
    out: list[str] = []
    for s in sources:
        for c in s["columns"]:
            if c["tgt"] not in out:
                out.append(c["tgt"])
    if extra_out:
        out = [c for c in extra_out if c in out] + [c for c in out if c not in extra_out]
    rules: dict[str, list[str]] = {}
    for c in out:
        have = [s for s in sources if any(x["tgt"] == c for x in s["columns"])]
        have.sort(key=lambda s: (s["_branch"].prec, s["_branch"].index))
        rules[c] = [s["alias"] for s in have]
    text = _render_call(header, sources, out, rules, unique_key, target_sat)
    return text, out


def _part_header(p: ParsedStitch, feeds: str) -> list[str]:
    stem = Path(p.file).stem if p.file else "the original stitch"
    return [f"-- This part feeds {feeds} only. Original precedence comments are kept below (from {stem})."] + list(p.header)


def _payload_cols(sat: SatSpec, b: Branch) -> list[dict]:
    return [{"src": b.columns[c], "tgt": c.lower()} for c in sat.payload if c in b.columns]


_STITCH_NO_RE = re.compile(r"^stitch_v(\d\d)_")


def link_part_name(link: str, file: str) -> str:
    """Link part name, suffixed with the two-digit stitch number so links shared by stitches never collide."""
    m = _STITCH_NO_RE.match(Path(file).name)
    return f"stitch_lk_{link[4:].lower()}" + (f"__v{m.group(1)}" if m else "")


def render_part(p: ParsedStitch, spec, literal: tuple[str, ...] | None = None) -> PartModel | None:
    """Render one macro part: a SatSpec (class A, B with `literal`, or C), LinkSpec or HubSpec.

    Returns None when no branch contributes a non-null key (nothing to build).
    """
    if isinstance(spec, SatSpec):
        sat = spec
        target = "sat_" + sat.sat.lower()
        header = _part_header(p, "SAT_" + sat.sat)
        items: list[tuple[Branch, str, list[dict]]] = []
        provides: dict[str, str] = {}
        if sat.klass in (CLASS_A, CLASS_B):
            bk = _bk_parts(sat)[0]
            ukey = bk.lower()
            for b in sat.branches:
                if bk not in b.keys:
                    continue
                cols = _payload_cols(sat, b)
                if sat.klass == CLASS_B:
                    if literal is None:
                        raise ValueError("class B part needs its literal tuple")
                    lits = tuple(_unquote(b.ck_columns[c]) for c in sat.ck_columns
                                 if c in b.ck_columns and _is_literal(b.ck_columns[c]))
                    if lits != tuple(literal):
                        continue
                    cols = cols + [{"src": _quote(v), "tgt": c.lower()} for c, v in zip(sat.ck_columns, literal)]
                items.append((b, _guard(b, b.keys[bk]), cols))
            provides[bk] = ukey
            name = f"stitch_{sat.sat.lower()}"
            if sat.klass == CLASS_B:
                name += "__" + _slug("_".join(literal))
                for c in sat.ck_columns:
                    provides[c] = c.lower()
        else:   # class C
            ukey = sat.key.unique_key
            name = f"stitch_{sat.sat.lower()}"
            for b in sat.branches:
                parts = branch_key_parts(sat, b)
                if parts is None:
                    continue
                cols = key_part_columns(parts) + _payload_cols(sat, b)
                items.append((b, _guard(b, render_key_column(parts, sat.key.separator)), cols))
            for part in sat.partition:
                provides[part] = part.lower()
        if not items:
            return None
        text, out = _assemble(header, items, ukey, target)
        for c in sat.payload:
            if c.lower() in out:
                provides[c] = c.lower()
        if sat.klass in (CLASS_A, CLASS_B):
            provides = {k: v for k, v in provides.items() if v == ukey or v in out}
        else:
            provides = {k: v for k, v in provides.items() if v in out}
        return PartModel(name, sat.klass, text, ukey, target, out, provides, {}, sat.sat)

    if isinstance(spec, LinkSpec):
        link = spec
        target = link.link.lower()
        header = _part_header(p, link.link)
        items = []
        for b in link.branches:
            parts = link_branch_parts(link, b)
            if not any(x in b.keys for x in link.legs):
                continue
            items.append((b, _guard(b, link_key_column(link, b)), key_part_columns(parts)))
        if not items:
            return None
        text, out = _assemble(header, items, link.key.unique_key, target)
        marker = "__LNK_" + link.link[4:]
        consts = {marker: "1"} if marker in p.link_markers else {}
        return PartModel(link_part_name(link.link, p.file), CLASS_LINK, text, link.key.unique_key, target,
                         out, {x: x.lower() for x in link.legs}, consts, link.link)

    if isinstance(spec, HubSpec):
        hub = spec
        base = hub.key_column[:-3] if hub.key_column.endswith("_BK") else hub.key_column
        target = "hub_" + base.lower()
        header = _part_header(p, "HUB_" + base)
        val = hub.key_column.lower() + "_kv"   # macro needs one payload column to order by
        items = [(b, _guard(b, b.keys[hub.key_column]), [{"src": b.keys[hub.key_column], "tgt": val}])
                 for b in hub.branches if hub.key_column in b.keys]
        if not items:
            return None
        text, out = _assemble(header, items, hub.key.unique_key, target)
        return PartModel(f"stitch_hk_{base.lower()}", CLASS_HUB, text, hub.key.unique_key, target, out,
                         {hub.key_column: hub.key.unique_key}, {}, hub.key_column)
    raise TypeError(f"unsupported spec {type(spec)!r}")


def render_parts(p: ParsedStitch, plan: Plan) -> list[PartModel]:
    """All macro parts of one stitch (fallback satellites and links excluded)."""
    out: list[PartModel] = []
    for s in plan.sats:
        if s.fallback:
            continue
        if s.klass == CLASS_B:
            for lit in literal_tuples(s):
                m = render_part(p, s, lit)
                if m:
                    out.append(m)
        else:
            m = render_part(p, s)
            if m:
                out.append(m)
    for lk in plan.links:
        if not lk.fallback:
            m = render_part(p, lk)
            if m:
                out.append(m)
    for h in plan.hubs:
        m = render_part(p, h)
        if m:
            out.append(m)
    return out


def fallback_name(file: str) -> str:
    stem = Path(file).stem
    return "stitch_fb_" + stem[len("stitch_"):] if stem.startswith("stitch_") else "stitch_fb_" + stem


def fallback_stitch(text: str, file: str) -> PartModel:
    """Fallback_Stitch: the verbatim original SQL under the helper name (no pruning, no edits)."""
    return PartModel(fallback_name(file), "FALLBACK", text)


def fallback_provides(p: ParsedStitch, plan: Plan) -> tuple[list[str], list[str]]:
    """Original columns a Fallback_Stitch must supply: its satellites' payload, child keys and keys,
    plus the legs and markers of fallback links."""
    cols: list[str] = []
    for s in plan.sats:
        if s.fallback:
            cols += list(s.partition) + list(s.payload)
    for lk in plan.links:
        if lk.fallback:
            cols += list(lk.legs) + ["__LNK_" + lk.link[4:]]
    seen: list[str] = []
    for c in cols:
        if c in p.columns and c not in seen:
            seen.append(c)
    return seen, []


def render_view(p: ParsedStitch, parts: list[PartModel], fallback: PartModel | None = None,
                fallback_cols: list[str] | None = None, original_text: str | None = None) -> str:
    """Consumer view: original name/header/columns, `union all` of the parts, null padding.

    Column contract: same names, order and (varchar) type as the original final select. The
    `__LNK_*` markers are integers in the original and are padded with `cast(null as int)`.
    If every satellite and link fell back (no parts), the original text is returned unchanged.
    """
    if not parts and fallback is not None and original_text is not None:
        return original_text
    members = list(parts)
    refs = [m.name for m in members] + ([fallback.name] if fallback else [])
    lines = ["{{ config(materialized='view') }}"]
    lines += list(p.header)
    lines.append("-- Consumer view over parts: " + ", ".join(refs))
    lines.append("")
    blocks = []
    for m in members + ([fallback] if fallback else []):
        sel = []
        for col in p.columns:
            if m.kind == "FALLBACK":
                src = col if col in (fallback_cols or []) else None
            else:
                src = m.provides.get(col)
            if src is not None:
                sel.append(f"    {src} as {col}")
            elif col in m.constants:
                sel.append(f"    {m.constants[col]} as {col}")
            elif col.startswith("__LNK_"):
                sel.append(f"    cast(null as int) as {col}")
            else:
                sel.append(f"    cast(null as varchar) as {col}")
        blocks.append("select\n" + ",\n".join(sel) + f"\nfrom {{{{ ref('{m.name}') }}}}")
    if not blocks:
        raise ValueError("consumer view without parts")
    return "\n".join(lines) + "\n" + "\n\nunion all\n\n".join(blocks) + "\n"


# --------------------------------------------------------------------------- smoke / CLI
def stats(p: ParsedStitch) -> dict:
    link_leg = sum(1 for b in p.branches if len(b.keys) >= 2)
    literal = sum(1 for b in p.branches for e in b.ck_columns.values() if _LITERAL_RE.match(e))
    driven = sum(1 for b in p.branches for e in b.ck_columns.values() if not _LITERAL_RE.match(e))
    return {
        "branches": len(p.branches),
        "satellites": len(p.sats),
        "link_leg_branches": link_leg,
        "literal_child_keys": literal,
        "data_driven_child_keys": driven,
    }


# --------------------------------------------------------------------------- CLI modes (task 7.4)
STG_DIR = PROJECT_ROOT / "models" / "staging"
RAW_VAULT_DIR = PROJECT_ROOT / "models" / "raw_vault"
_STAGE_SOURCE_RE = re.compile(r"source_model:\s*['\"]?(stitch_v\d\d_\w+)['\"]?")
_MODEL_RE = re.compile(r"'model':\s*['\"]([^'\"]+)['\"]")
_UPPER_TOKEN_RE = re.compile(r"\b[A-Z_][A-Z0-9_]*\b")
_WATERMARK_RE = re.compile(r"\bas\s+inc_job_updated_at\b", re.I)


@dataclass
class StitchResult:
    file: str
    text: str
    status: str = "ok"            # ok | error | already_converted | not_written
    error: Finding | None = None
    parsed: ParsedStitch | None = None
    plan: Plan | None = None
    parts: list[PartModel] = field(default_factory=list)
    fallback: PartModel | None = None
    fallback_cols: list[str] = field(default_factory=list)
    view: str = ""
    notes: list[str] = field(default_factory=list)   # write-time messages

    def files(self) -> dict[str, str]:
        """File name -> content of everything this stitch writes (parts, fallback, consumer view)."""
        out = {m.name + ".sql": m.text for m in self.parts}
        if self.fallback:
            out[self.fallback.name + ".sql"] = self.fallback.text
        out[self.file] = self.view
        return out

    def part_names(self) -> list[str]:
        return [m.name for m in self.parts]

    def file_count(self) -> int:
        return len(self.parts) + (1 if self.fallback else 0) + 1


def build_stitch(path: Path, link_defs: dict[str, list[str]] | None = None,
                 profile: dict | None = None) -> StitchResult:
    """Parse, classify and render one stitch fully in memory. Never touches the disk."""
    text = path.read_text(encoding="utf-8")
    r = StitchResult(file=path.name, text=text)
    if "-- Consumer view over parts:" in text:
        r.status = "already_converted"
        r.notes.append("already a consumer view; the original SQL is needed to convert it again")
        return r
    try:
        p = parse(text, path.name)
        plan = classify(p, link_defs=link_defs, profile=profile)
        parts = render_parts(p, plan)
        fb = None
        fb_cols: list[str] = []
        if any(s.fallback for s in plan.sats) or any(x.fallback for x in plan.links):
            fb = fallback_stitch(text, path.name)
            fb_cols, _ = fallback_provides(p, plan)
        view = render_view(p, parts, fb, fb_cols, text)
        r.parsed, r.plan, r.parts, r.fallback, r.fallback_cols, r.view = p, plan, parts, fb, fb_cols, view
    except ParseError as e:
        r.status, r.error = "error", Finding(path.name, e.branch, e.construct)
    except Exception as e:  # any converter bug must not leave partial output for this stitch
        r.status, r.error = "error", Finding(path.name, None, f"converter error: {type(e).__name__}: {e}")
    return r


def build_all(stitches_dir: Path, link_defs: dict[str, list[str]] | None = None,
              profile: dict | None = None) -> list[StitchResult]:
    files = sorted(Path(stitches_dir).glob("stitch_v[0-9][0-9]_*.sql"))
    return [build_stitch(f, link_defs, profile) for f in files]


def _ok(results: list[StitchResult]) -> list[StitchResult]:
    return [r for r in results if r.status == "ok"]


def _key_template(parts: list[KeyPart], sep: str) -> str:
    return render_key_column(
        [KeyPart(expr=x.tgt, tgt=x.tgt, nullable=x.nullable, literal=x.literal) for x in parts], sep)


def class_c_reason(s: SatSpec) -> tuple[int | None, str]:
    """(first triggering branch, construct) for a class C satellite."""
    bks = _bk_parts(s)
    if len(bks) >= 2:
        return (s.branches[0].index if s.branches else None,
                f"composite business key ({', '.join(bks)})")
    for b in s.branches:
        for c in s.ck_columns:
            if c not in b.ck_columns:
                return b.index, f"child key {c} absent in branch"
            if not _is_literal(b.ck_columns[c]):
                return b.index, f"data-driven child key {c}"
    return None, "composite key"


def stg_info(model: str, stg_dir: Path = STG_DIR) -> dict:
    """Does the final stg model select inc_job_updated_at, and as which type?"""
    found = next(iter(sorted(Path(stg_dir).rglob(model + ".sql"))), None) if Path(stg_dir).is_dir() else None
    if found is None:
        return {"model": model, "file_found": False, "selects": False, "type": None}
    text = _strip_line_comments(found.read_text(encoding="utf-8"))
    hit = next((l for l in text.splitlines() if _WATERMARK_RE.search(l)), None)
    if hit is None:
        return {"model": model, "file_found": True, "selects": False, "type": None}
    typ = "varchar" if "to_varchar" in hit.lower() else "timestamp_ntz"
    return {"model": model, "file_found": True, "selects": True, "type": typ}


def part_sources(m: PartModel) -> list[str]:
    seen: list[str] = []
    for x in _MODEL_RE.findall(m.text):
        if x not in seen:
            seen.append(x)
    return seen


def watermark_precheck(results: list[StitchResult], stg_dir: Path = STG_DIR) -> tuple[list[dict], list[dict]]:
    """(per-part table, parts that read a varchar inc_job_updated_at model)."""
    cache: dict[str, dict] = {}
    table: list[dict] = []
    varchar_parts: list[dict] = []
    for r in _ok(results):
        for m in r.parts:
            srcs = []
            for model in part_sources(m):
                info = cache.setdefault(model, stg_info(model, stg_dir))
                srcs.append(info)
            table.append({"stitch": r.file, "part": m.name, "sources": srcs,
                          "all_select_watermark": all(s["selects"] for s in srcs)})
            v = [s["model"] for s in srcs if s["type"] == "varchar"]
            if v:
                varchar_parts.append({"stitch": r.file, "part": m.name, "varchar_models": v})
    return table, varchar_parts


def view_provided(r: StitchResult) -> set[str]:
    cols: set[str] = set(r.fallback_cols)
    for m in r.parts:
        cols.update(m.provides)
        cols.update(m.constants)
    return cols


def consumer_map(results: list[StitchResult], raw_vault_dir: Path = RAW_VAULT_DIR) -> list[dict]:
    """For every stage model under raw_vault/**/staging reading `stitch_vNN_*`."""
    by_stem = {Path(r.file).stem: r for r in _ok(results)}
    out: list[dict] = []
    if not Path(raw_vault_dir).is_dir():
        return out
    for d in sorted(Path(raw_vault_dir).rglob("staging")):
        if not d.is_dir():
            continue
        for f in sorted(d.glob("*.sql")):
            text = f.read_text(encoding="utf-8")
            m = _STAGE_SOURCE_RE.search(text)
            if not m:
                continue
            src = m.group(1)
            entry = {"stage": f.name, "path": f.relative_to(raw_vault_dir).as_posix(), "source_model": src}
            r = by_stem.get(src)
            if r is None:
                entry.update(resolved=False, columns_used=[], columns_provided=[], missing=[],
                             satellite_prefixes=[], single_satellite=None)
                out.append(entry)
                continue
            body = _strip_line_comments(text)
            all_cols = set(r.parsed.columns)
            used = [c for c in dict.fromkeys(_UPPER_TOKEN_RE.findall(body)) if c in all_cols]
            provided = view_provided(r)
            prefixes = sorted({c.split("__", 1)[0] for c in used if "__" in c and not c.startswith("__")})
            entry.update(
                resolved=True,
                columns_used=used,
                columns_provided=[c for c in r.parsed.columns if c in provided],
                missing=[c for c in used if c not in provided],
                satellite_prefixes=prefixes,
                single_satellite=len(prefixes) <= 1,
            )
            out.append(entry)
    return out


def collisions(results: list[StitchResult], out_dir: Path | None = None) -> list[dict]:
    """Part names produced by more than one stitch, or equal to an unrelated file already in out_dir."""
    owners: dict[str, list[tuple[str, str]]] = {}
    for r in _ok(results):
        for name, text in r.files().items():
            if name == r.file:
                continue
            owners.setdefault(name, []).append((r.file, text))
    originals = {r.file for r in results}
    out = []
    for name, lst in sorted(owners.items()):
        on_disk = bool(out_dir) and (Path(out_dir) / name).exists() and name not in originals
        if len(lst) > 1 or on_disk:
            out.append({"part": name[:-4], "stitches": [s for s, _ in lst],
                        "identical_content": len({t for _, t in lst}) == 1,
                        "exists_on_disk": on_disk})
    return out


def build_report(results: list[StitchResult], out_dir: Path | None = None, stg_dir: Path = STG_DIR,
                 raw_vault_dir: Path = RAW_VAULT_DIR) -> dict:
    ok = _ok(results)
    findings: list[dict] = [asdict(r.error) for r in results if r.error]
    stitches, multi, class_c, splits, fallbacks = {}, [], [], [], []
    for r in ok:
        plan = r.plan
        findings += [asdict(x) for x in plan.findings]
        fallbacks += [asdict(x) for x in plan.findings if x.fallback]
        sats = []
        for s in plan.sats:
            sats.append({
                "sat": s.sat, "class": s.klass, "fallback": s.fallback, "unique_key": s.key.unique_key,
                "key_template": (_key_template(s.key.parts, s.key.separator) if s.klass == CLASS_C
                                 else "verbatim " + (_bk_parts(s)[0] if _bk_parts(s) else "")),
                "separator": s.key.separator,
                "branches": [b.index for b in s.branches],
            })
            if s.klass == CLASS_C:
                br, why = class_c_reason(s)
                class_c.append({"file": r.file, "satellite": s.sat, "branch": br, "construct": why})
            if s.klass == CLASS_B and not s.fallback:
                for lit in literal_tuples(s):
                    splits.append({
                        "file": r.file, "original": s.sat, "literal": list(lit),
                        "part": f"stitch_{s.sat.lower()}__" + _slug("_".join(lit)),
                    })
        links = [{"link": x.link, "legs": x.legs, "optional_legs": x.optional, "inferred": x.inferred,
                  "fallback": x.fallback, "unique_key": x.key.unique_key,
                  "key_template": _key_template(x.key.parts, x.key.separator) if x.key.parts else ""}
                 for x in plan.links]
        stitches[r.file] = {
            "satellites": sats, "links": links, "hubs": [h.key_column for h in plan.hubs],
            "counts": plan.counts(), "parts": r.part_names(),
            "fallback": r.fallback.name if r.fallback else None, "file_count": r.file_count(),
        }
        if len(plan.sats) > 1:
            multi.append({"file": r.file, "satellites": [s.sat for s in plan.sats]})
    wm, varchar_parts = watermark_precheck(results, stg_dir)
    cmap = consumer_map(results, raw_vault_dir)
    for e in cmap:
        if not e["resolved"]:
            findings.append({"file": e["path"], "branch": None, "fallback": False,
                             "construct": f"source_model {e['source_model']} has no consumer view"})
        for c in e["missing"]:
            findings.append({"file": e["path"], "branch": None, "fallback": False,
                             "construct": f"column {c} used but not provided by {e['source_model']}"})
        if e["resolved"] and not e["single_satellite"]:
            findings.append({"file": e["path"], "branch": None, "fallback": False,
                             "construct": f"uses columns of several satellites: {', '.join(e['satellite_prefixes'])}"})
    totals = {k: sum(v["counts"][k] for v in stitches.values())
              for k in ("A", "B", "B_parts", "C", "LINK", "HUB", "FALLBACK")}
    all_files = {n for r in ok for n in r.files()}
    totals.update(
        stitches_total=len(results), stitches_parsed=len(ok),
        stitches_failed=sum(1 for r in results if r.status == "error"),
        stitches_already_converted=sum(1 for r in results if r.status == "already_converted"),
        satellites=sum(len(v["satellites"]) for v in stitches.values()),
        parts=sum(len(v["parts"]) for v in stitches.values()),
        files_total=sum(v["file_count"] for v in stitches.values()),
        files_distinct=len(all_files),
        consumer_views=len(ok),
    )
    return {
        "totals": totals, "stitches": stitches, "multi_satellite": multi, "class_c": class_c,
        "fallback_stitches": fallbacks, "literal_splits": splits, "consumer_map": cmap,
        "watermark_precheck": wm, "varchar_watermark_parts": varchar_parts,
        "part_name_collisions": collisions(results, out_dir), "findings": findings,
    }


def format_plan(results: list[StitchResult], report: dict) -> str:
    rows = [("stitch", "sats", "A", "B", "C", "LINK", "HUB", "parts", "fb", "files")]
    for f, v in report["stitches"].items():
        c = v["counts"]
        rows.append((f, len(v["satellites"]), c["A"], c["B"], c["C"], c["LINK"], c["HUB"],
                     len(v["parts"]), c["FALLBACK"], v["file_count"]))
    t = report["totals"]
    rows.append(("TOTAL", t["satellites"], t["A"], t["B"], t["C"], t["LINK"], t["HUB"], t["parts"],
                 t["FALLBACK"], t["files_total"]))
    w = [max(len(str(r[i])) for r in rows) for i in range(len(rows[0]))]
    lines = ["  ".join(str(x).ljust(w[i]) if i == 0 else str(x).rjust(w[i]) for i, x in enumerate(r)) for r in rows]
    lines.insert(1, "  ".join("-" * x for x in w))
    lines.insert(-1, lines[1])
    for r in results:
        if r.status != "ok":
            msg = f"{r.error.construct} (branch {r.error.branch})" if r.error else "; ".join(r.notes)
            lines.append(f"{r.status.upper()}: {r.file}: {msg}")
    lines += [
        "",
        f"stitches: {t['stitches_total']} (parsed {t['stitches_parsed']}, failed {t['stitches_failed']})",
        f"satellites fed: {t['satellites']}  class A {t['A']}  B {t['B']}  C {t['C']}  "
        f"link {t['LINK']}  hub-only {t['HUB']}  fallback {t['FALLBACK']}",
        f"parts to create: {t['parts']}  (class B per-literal parts: {t['B_parts']})",
        f"consumer views to rewrite: {t['consumer_views']}",
        f"total files: {t['files_total']}  (distinct file names: {t['files_distinct']})",
        f"class B volume (O3): {t['B']} satellites -> {t['B_parts']} per-literal parts; "
        f"merged into class C they would be {t['B']} parts",
        f"part-name collisions across stitches: {len(report['part_name_collisions'])}",
        f"fallback stitches: {len(report['fallback_stitches'])}",
        f"parts reading a varchar inc_job_updated_at model: {len(report['varchar_watermark_parts'])}",
        f"parts with a source stg model lacking inc_job_updated_at: "
        f"{sum(1 for x in report['watermark_precheck'] if not x['all_select_watermark'])}",
        f"stage models reading stitch_vNN_*: {len(report['consumer_map'])} "
        f"(missing columns: {sum(1 for e in report['consumer_map'] if e['missing'])}, "
        f"several satellites: {sum(1 for e in report['consumer_map'] if e['resolved'] and not e['single_satellite'])})",
        f"findings: {len(report['findings'])}",
    ]
    return "\n".join(lines)


def write_all(results: list[StitchResult], out_dir: Path, force: bool = False) -> None:
    """Write parts and consumer views. All-or-nothing per stitch; never overwrites without `force`.

    A stitch that fails (conflict or I/O error) gets status 'not_written' and leaves the disk as it was.
    """
    out_dir = Path(out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)
    written: dict[str, tuple[str, str]] = {}   # file name -> (content, stitch) written in this run
    for r in results:
        if r.status != "ok":
            continue
        files = r.files()
        conflicts: list[str] = []
        for name, text in files.items():
            if name in written:
                if written[name][0] != text:
                    conflicts.append(f"{name}: part name collision with different content from {written[name][1]}")
            elif (out_dir / name).exists() and not force:
                conflicts.append(f"{name}: exists (use --force to overwrite)")
        if conflicts:
            r.status = "not_written"
            r.notes += conflicts
            continue
        backups: dict[Path, bytes | None] = {}
        done: list[Path] = []
        try:
            for name, text in files.items():
                if name in written:       # identical part already written by an earlier stitch
                    continue
                path = out_dir / name
                backups[path] = path.read_bytes() if path.exists() else None
                tmp = path.with_suffix(".sql.tmp")
                tmp.write_text(text, encoding="utf-8", newline="\n")
                tmp.replace(path)
                done.append(path)
        except Exception as e:
            for path in done:
                old = backups[path]
                if old is None:
                    path.unlink(missing_ok=True)
                else:
                    path.write_bytes(old)
            r.status = "not_written"
            r.notes.append(f"write failed, stitch rolled back: {type(e).__name__}: {e}")
            continue
        for name, text in files.items():
            written.setdefault(name, (text, r.file))


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="Convert Health stitched models to macro parts + consumer views")
    mode = ap.add_mutually_exclusive_group()
    mode.add_argument("--plan", action="store_true", help="print counts only; write no model file (default)")
    mode.add_argument("--write", action="store_true", help="write parts and consumer views")
    ap.add_argument("--force", action="store_true", help="allow --write to overwrite existing files")
    ap.add_argument("--stitches-dir", type=Path, default=DEFAULT_DIR)
    ap.add_argument("--report", type=Path, default=None, help=f"report JSON path (default {DEFAULT_REPORT.name})")
    args = ap.parse_args(argv)
    if args.force and not args.write:
        ap.error("--force only applies to --write")

    results = build_all(args.stitches_dir)
    if args.write:
        write_all(results, args.stitches_dir, force=args.force)
    report = build_report(results, args.stitches_dir)
    report["mode"] = "write" if args.write else "plan"
    report["write_results"] = [
        {"file": r.file, "status": r.status, "notes": r.notes} for r in results if r.status != "ok" or r.notes
    ] if args.write else []
    rpath = args.report or DEFAULT_REPORT
    rpath.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(format_plan(results, report))
    bad = [r for r in results if r.status in ("error", "not_written")]
    for r in bad:
        why = r.error.construct if r.error else "; ".join(r.notes)
        print(f"FAILED {r.file}: {why}", file=sys.stderr)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
