"""Property test for ``dvgen.emit.WriteGuard``.

Feature: health-lob-dv-dbt-build, Property 22: Writes stay inside the project

For any relative path, including ones with ``..`` segments, absolute paths,
or drive letters, the write guard writes only when the resolved path is
inside the project root, and raises ``OutsideProject`` otherwise.

The project root is nested in a fresh folder under ``tmp_path`` so a write
that escapes the root but stays inside ``tmp_path`` is caught by comparing
snapshots of the enclosing folder. A write that escapes ``tmp_path`` itself
is stopped by the conftest audit hook (``OutsideTmpWrite``), which also
fails the test.

**Validates: Requirements 10.3**
"""
from __future__ import annotations

import hashlib
import os
import tempfile
from pathlib import Path

from hypothesis import HealthCheck, example, given, settings
from hypothesis import strategies as st

from dvgen.emit import OutsideProject, WriteGuard

ROOT_NAME = "proj"

# Path segments. "proj" lets "../proj/x" climb out and back in; "proj_x"
# and "projx" share the root's name as a prefix, so a guard that compares
# strings without a separator would wrongly accept them.
_SEGMENT = st.sampled_from(
    ["..", "..", ".", "a", "b", "sub", ROOT_NAME, ROOT_NAME + "_x", ROOT_NAME + "x", "PROJ"]
)
_SEP = st.sampled_from(["/", "\\"])

# Prefixes. "<root>" / "<outer>" are replaced by the real absolute paths of
# the project root and its parent at test time; "<drive>" by the root's own
# drive letter. The rest are fixed absolute roots and foreign drive letters.
_PREFIX = st.sampled_from(
    [
        "", "", "", "",          # plain relative paths are the common case
        "/", "\\",               # root of the current drive
        # UNC prefixes ("//host/share") are left out: resolving them makes
        # Windows try to reach a network host.
        "<root>", "<root_upper>", "<outer>",
        "<drive>", "<drive>/", "<drive>\\",
        "C:", "C:/", "C:\\", "Z:", "Z:\\", "z:/",
    ]
)


@st.composite
def _raw_path(draw) -> tuple[str, list[str], str, bool]:
    prefix = draw(_PREFIX)
    segments = draw(st.lists(_SEGMENT, max_size=6))
    seps = [draw(_SEP) for _ in segments]
    trailing = draw(st.booleans())
    return prefix, segments, "".join(seps), trailing


def _build(prefix: str, segments: list[str], seps: str, trailing: bool,
           root: Path, outer: Path) -> str:
    drive = os.path.splitdrive(str(root))[0]
    concrete = {
        "<root>": str(root),
        "<root_upper>": str(root).upper(),
        "<outer>": str(outer),
        "<drive>": drive,
        "<drive>/": drive + "/",
        "<drive>\\": drive + "\\",
    }.get(prefix, prefix)
    raw = concrete
    for seg, sep in zip(segments, seps):
        # An absolute prefix such as "<root>" needs a separator before the
        # first segment; "C:" and "" deliberately do not get one.
        if raw and not raw.endswith(("/", "\\", ":")):
            raw += sep
        raw += seg
    if trailing and segments:
        raw += seps[-1]
    return raw


def _expected_target(raw: str, root: Path) -> str | None:
    """Independent oracle: the normalised target, or None when refused."""
    if not raw:
        return None
    target = os.path.normcase(os.path.abspath(os.path.join(str(root), raw)))
    root_norm = os.path.normcase(str(root))
    if target.startswith(root_norm + os.sep) and target != root_norm:
        return target
    return None


def _snapshot(base: Path) -> dict[str, str | None]:
    """{relative path: sha256 for files, None for folders} under ``base``."""
    out: dict[str, str | None] = {}
    for dirpath, dirs, files in os.walk(base):
        for d in dirs:
            out[os.path.relpath(os.path.join(dirpath, d), base)] = None
        for f in files:
            full = os.path.join(dirpath, f)
            with open(full, "rb") as fh:
                out[os.path.relpath(full, base)] = hashlib.sha256(fh.read()).hexdigest()
    return out


@settings(max_examples=300, deadline=None,
          suppress_health_check=[HealthCheck.function_scoped_fixture, HealthCheck.too_slow])
@given(spec=_raw_path(), text=st.text(alphabet="ab\r\n", max_size=12))
@example(spec=("", [], "", False), text="x")                                  # empty path
@example(spec=("", ["."], "/", False), text="x")                              # the root itself
@example(spec=("", ["a", ".."], "\\\\", False), text="x")                     # back to the root
@example(spec=("", ["..", ROOT_NAME + "_x", "a"], "///", False), text="x")    # sibling prefix
@example(spec=("", ["..", ROOT_NAME, "a"], "/\\/", False), text="x")          # out and back in
@example(spec=("<root>", ["a"], "\\", False), text="x")                       # absolute, inside
@example(spec=("<outer>", ["a"], "/", False), text="x")                       # absolute, outside
@example(spec=("<drive>", ["a"], "/", False), text="x")                       # drive-relative
@example(spec=("Z:\\", ["a"], "\\", False), text="x")                         # other drive
def test_writes_stay_inside_the_project(tmp_path, spec, text):
    """Feature: health-lob-dv-dbt-build, Property 22: Writes stay inside the project"""
    outer = Path(tempfile.mkdtemp(dir=tmp_path)).resolve()
    root = outer / ROOT_NAME
    root.mkdir()
    raw = _build(*spec, root=root, outer=outer)
    expected = _expected_target(raw, root)
    guard = WriteGuard(root)
    before = _snapshot(outer)

    try:
        digest = guard.write(raw, text)
    except OutsideProject as exc:
        assert expected is None, f"refused an inside path {raw!r} -> {expected!r}"
        assert exc.rel_path == raw
        # Nothing at all changed next to or inside the project root.
        assert _snapshot(outer) == before
        assert guard.written == {}
        return

    assert expected is not None, f"wrote outside the project root: {raw!r}"
    data = text.replace("\r\n", "\n").replace("\r", "\n").encode("utf-8")
    assert digest == hashlib.sha256(data).hexdigest()
    with open(expected, "rb") as fh:
        assert fh.read() == data

    # Every new or changed entry lies under the project root.
    after = _snapshot(outer)
    changed = {p for p in after if before.get(p, "<missing>") != after[p]}
    assert changed, raw
    for p in changed:
        assert os.path.normcase(p).startswith(os.path.normcase(ROOT_NAME) + os.sep), p
    rel = Path(os.path.relpath(expected, os.path.normcase(str(root)))).as_posix()
    assert [os.path.normcase(p) for p in guard.written] == [os.path.normcase(rel)]
