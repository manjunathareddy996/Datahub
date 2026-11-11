"""Offline checker for the Health dbt project (no dbt, no Snowflake needed).

Scaffolding checks (task 5.1):
  - YAML validity of dbt_project.yml, profiles.yml, packages.yml
  - profile name from dbt_project.yml is present in profiles.yml
  - folders configured under `models:` in dbt_project.yml exist under models/
    (missing ones are listed for the Findings_Report)
  - macros/ and dbt_packages/ are byte-equal to the Partner project
  - .gitignore has the required entries and nothing matches dbt_packages
  - `git check-ignore` reports vendored package files as not ignored

Later tasks extend the CHECKS list with more functions of the form
    check_x(ctx) -> CheckResult

Usage:
    python scripts/check_health_project.py [--json] [--partner PATH]
Exit code: 0 when every check passes, 1 otherwise.
"""
from __future__ import annotations

import argparse
import fnmatch
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass, field
from pathlib import Path
from typing import Callable

try:
    import yaml
except ImportError:  # pragma: no cover
    yaml = None

ROOT = Path(__file__).resolve().parent.parent
DEFAULT_PARTNER = ROOT.parent / "opus_partner_dv_dbt"
REQUIRED_IGNORE = ("target/", "logs/", ".user.yml", "TESTING")
VENDORED = ("dbt_utils", "automate_dv")


@dataclass
class CheckResult:
    name: str
    ok: bool
    details: list[str] = field(default_factory=list)
    data: dict = field(default_factory=dict)


@dataclass
class Context:
    root: Path
    partner: Path


# ---------------------------------------------------------------- helpers

def load_yaml(path: Path):
    """Return (data, error). Error is None when the file parses."""
    if yaml is None:
        return None, "PyYAML is not installed"
    try:
        return yaml.safe_load(path.read_text(encoding="utf-8")), None
    except FileNotFoundError:
        return None, "file not found"
    except yaml.YAMLError as exc:
        return None, f"invalid YAML: {str(exc).splitlines()[0]}"


def configured_folders(models_cfg: dict, project: str) -> list[str]:
    """Folder paths (relative to models/) named by the project's models config."""
    tree = (models_cfg or {}).get(project) or {}
    out: list[str] = []

    def walk(node: dict, prefix: tuple[str, ...]) -> None:
        for key, val in node.items():
            if key.startswith("+") or not isinstance(val, dict):
                continue
            path = prefix + (key,)
            out.append("/".join(path))
            walk(val, path)

    walk(tree, ())
    return out


def files_under(base: Path) -> dict[str, Path]:
    return {p.relative_to(base).as_posix(): p for p in base.rglob("*") if p.is_file()}


def compare_trees(health: Path, partner: Path) -> tuple[list[str], list[str], list[str], int]:
    """Return (missing_in_health, extra_in_health, differing, compared_count)."""
    h, p = files_under(health), files_under(partner)
    missing = sorted(set(p) - set(h))
    extra = sorted(set(h) - set(p))
    differ = sorted(k for k in set(h) & set(p) if h[k].read_bytes() != p[k].read_bytes())
    return missing, extra, differ, len(set(h) & set(p))


def ignore_matches_dbt_packages(entry: str) -> bool:
    """True when a .gitignore entry would ignore a vendored dbt_packages file."""
    e = entry.strip().lstrip("/")
    if not e or e.startswith("#") or e.startswith("!"):
        return False
    if e.startswith("dbt_packages"):
        return True
    return e.rstrip("/") in ("dbt_packages", "*", "**")


# ----------------------------------------------------------------- checks

def check_yaml_valid(ctx: Context) -> CheckResult:
    details, ok = [], True
    for name in ("dbt_project.yml", "profiles.yml", "packages.yml"):
        _, err = load_yaml(ctx.root / name)
        if err:
            ok = False
            details.append(f"{name}: {err}")
    return CheckResult("yaml_valid", ok, details or ["all 3 files parse"])


def check_profile_name(ctx: Context) -> CheckResult:
    proj, e1 = load_yaml(ctx.root / "dbt_project.yml")
    profiles, e2 = load_yaml(ctx.root / "profiles.yml")
    if e1 or e2 or not isinstance(proj, dict) or not isinstance(profiles, dict):
        return CheckResult("profile_name", False, ["cannot read dbt_project.yml / profiles.yml"])
    prof = proj.get("profile")
    ok = bool(prof) and prof in profiles
    return CheckResult("profile_name", ok,
                       [f"profile '{prof}' " + ("found" if ok else "missing") + " in profiles.yml"],
                       {"profile": prof})


def check_configured_folders(ctx: Context) -> CheckResult:
    """Missing configured folders are reported as a list (Findings_Report input).

    A missing folder is a finding, not a failure: dbt tolerates it. Only an
    unreadable config fails the check.
    """
    proj, err = load_yaml(ctx.root / "dbt_project.yml")
    if err or not isinstance(proj, dict):
        return CheckResult("configured_folders", False, [f"dbt_project.yml: {err}"])
    folders = configured_folders(proj.get("models"), proj.get("name", ""))
    models = ctx.root / "models"
    missing = [f for f in folders if not (models / f).is_dir()]
    return CheckResult(
        "configured_folders", True,
        [f"{len(folders) - len(missing)}/{len(folders)} configured folders exist"]
        + [f"missing: models/{m}" for m in missing],
        {"configured": folders, "missing": missing})


def check_macros_equal(ctx: Context) -> CheckResult:
    missing, extra, differ, n = compare_trees(ctx.root / "macros", ctx.partner / "macros")
    # .gitkeep is a placeholder, not a macro
    missing = [m for m in missing if not m.endswith(".gitkeep")]
    extra = [m for m in extra if not m.endswith(".gitkeep")]
    ok = not (missing or extra or differ) and n > 0
    details = [f"{n} macro files compared"]
    details += [f"missing in Health: {m}" for m in missing]
    details += [f"not in Partner: {m}" for m in extra]
    details += [f"differs: {m}" for m in differ]
    return CheckResult("macros_equal_partner", ok, details,
                       {"missing": missing, "extra": extra, "differ": differ})


def check_packages_yml(ctx: Context) -> CheckResult:
    h, p = ctx.root / "packages.yml", ctx.partner / "packages.yml"
    ok = h.is_file() and p.is_file() and h.read_bytes() == p.read_bytes()
    details = ["packages.yml byte-equal to Partner" if ok else "packages.yml differs from Partner"]
    data, _ = load_yaml(h)
    for entry in (data or {}).get("packages", []) if isinstance(data, dict) else []:
        local = entry.get("local") if isinstance(entry, dict) else None
        if local:
            target = ctx.root / local
            exists = (target / "dbt_project.yml").is_file()
            ok = ok and exists
            details.append(f"local path {local}: " + ("ok" if exists else "missing dbt_project.yml"))
    return CheckResult("packages_yml", ok, details)


def check_vendored_packages(ctx: Context) -> CheckResult:
    ok, details, data = True, [], {}
    for pkg in VENDORED:
        hp, pp = ctx.root / "dbt_packages" / pkg, ctx.partner / "dbt_packages" / pkg
        if not hp.is_dir() or not pp.is_dir():
            ok = False
            details.append(f"{pkg}: folder missing (Health={hp.is_dir()}, Partner={pp.is_dir()})")
            continue
        missing, extra, differ, n = compare_trees(hp, pp)
        good = not (missing or extra or differ) and n > 0
        ok = ok and good
        details.append(f"{pkg}: {n} files compared, missing={len(missing)}, extra={len(extra)}, differ={len(differ)}")
        details += [f"  missing in Health: {m}" for m in missing[:10]]
        details += [f"  not in Partner: {m}" for m in extra[:10]]
        details += [f"  differs: {m}" for m in differ[:10]]
        data[pkg] = {"compared": n, "missing": len(missing), "extra": len(extra), "differ": len(differ)}
    return CheckResult("vendored_packages_equal_partner", ok, details, data)


def check_gitignore(ctx: Context) -> CheckResult:
    path = ctx.root / ".gitignore"
    if not path.is_file():
        return CheckResult("gitignore_entries", False, [".gitignore not found"])
    entries = [ln.strip() for ln in path.read_text(encoding="utf-8").splitlines()
               if ln.strip() and not ln.strip().startswith("#")]
    missing = [e for e in REQUIRED_IGNORE if e not in entries]
    bad = [e for e in entries if ignore_matches_dbt_packages(e)]
    details = [f"missing required entry: {e}" for e in missing]
    details += [f"entry would ignore dbt_packages: {e}" for e in bad]
    return CheckResult("gitignore_entries", not (missing or bad),
                       details or [f"{len(entries)} entries; required present; none match dbt_packages"],
                       {"missing": missing, "matching_dbt_packages": bad})


def check_vendored_not_ignored(ctx: Context) -> CheckResult:
    files = [p.relative_to(ctx.root).as_posix()
             for pkg in VENDORED if (ctx.root / "dbt_packages" / pkg).is_dir()
             for p in (ctx.root / "dbt_packages" / pkg).rglob("*") if p.is_file()]
    if not files:
        return CheckResult("vendored_not_git_ignored", False, ["no vendored files found"])
    try:
        proc = subprocess.run(
            ["git", "check-ignore", "--no-index", "--stdin"], cwd=ctx.root, input="\n".join(files),
            capture_output=True, text=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired) as exc:
        return CheckResult("vendored_not_git_ignored", False, [f"git unavailable: {exc}"])
    if proc.returncode not in (0, 1):
        return CheckResult("vendored_not_git_ignored", False, [f"git check-ignore failed: {proc.stderr.strip()}"])
    ignored = [ln for ln in proc.stdout.splitlines() if ln.strip()]
    return CheckResult("vendored_not_git_ignored", not ignored,
                       [f"{len(files)} vendored files checked, {len(ignored)} ignored"] + ignored[:10],
                       {"checked": len(files), "ignored": ignored})


_REF_RE = re.compile(r"""\bref\(\s*(?:['"][^'"]+['"]\s*,\s*)?['"]([^'"]+)['"]\s*(?:,[^)]*)?\)""")
_DEPENDS_RE = re.compile(r"^\s*--\s*depends_on:\s*(.*)$", re.MULTILINE)
_SOURCE_MODEL_RE = re.compile(r"source_model:\s*['\"]?([A-Za-z0-9_]+)['\"]?")
SWEEP_REPORT = "reference_sweep.json"


def check_reference_sweep(ctx: Context) -> CheckResult:
    """Every ref() and stage source_model resolves to a model file under models/.

    ref() inside `-- depends_on:` comments is counted separately (dbt renders it).
    Consumer map (scripts/conversion_report.json) supplies the stage -> stitched model
    column findings: columns used but not provided, and stages using several satellites.
    The full sweep is written to scripts/reference_sweep.json. No model file is changed.
    """
    models = ctx.root / "models"
    names = {p.stem for p in models.rglob("*.sql")}
    refs_checked = depends_checked = 0
    unresolved: list[dict] = []
    for f in sorted(models.rglob("*.sql")):
        text = f.read_text(encoding="utf-8")
        rel = f.relative_to(models).as_posix()
        dep_spans = [m.span(1) for m in _DEPENDS_RE.finditer(text)]
        for m in _REF_RE.finditer(text):
            in_dep = any(a <= m.start() < b for a, b in dep_spans)
            refs_checked += 1
            depends_checked += in_dep
            if m.group(1) not in names:
                unresolved.append({"file": rel, "ref": m.group(1), "in_depends_on_comment": in_dep})

    sm_checked = 0
    sm_unresolved: list[dict] = []
    for d in sorted(models.rglob("staging")):
        if not d.is_dir() or "raw_vault" not in d.relative_to(models).parts:
            continue
        for f in sorted(d.glob("*.sql")):
            m = _SOURCE_MODEL_RE.search(f.read_text(encoding="utf-8"))
            if not m:
                continue
            sm_checked += 1
            if m.group(1) not in names:
                sm_unresolved.append({"stage": f.name, "source_model": m.group(1)})

    missing_cols: list[dict] = []
    multi_sat: list[dict] = []
    cm_err = None
    try:
        report = json.loads((ctx.root / "scripts" / "conversion_report.json").read_text(encoding="utf-8"))
        for e in report.get("consumer_map", []):
            if not e.get("resolved"):
                continue
            for col in e.get("missing", []):
                missing_cols.append({"stage": e["stage"], "column": col, "stitched_model": e["source_model"]})
            if e.get("single_satellite") is False:
                multi_sat.append({"stage": e["stage"], "satellite_prefixes": e.get("satellite_prefixes", []),
                                  "stitched_model": e["source_model"]})
    except (OSError, ValueError) as exc:
        cm_err = f"cannot read consumer map: {exc}"

    sweep = {
        "refs_checked": refs_checked, "refs_in_depends_on_comments": depends_checked,
        "unresolved_refs": unresolved,
        "source_model_checked": sm_checked, "unresolved_source_models": sm_unresolved,
        "missing_columns": missing_cols, "multi_satellite_stages": multi_sat,
    }
    (ctx.root / "scripts" / SWEEP_REPORT).write_text(json.dumps(sweep, indent=2) + "\n", encoding="utf-8")

    ok = not (unresolved or sm_unresolved or missing_cols or multi_sat or cm_err)
    details = [f"{refs_checked} ref() checked ({depends_checked} in depends_on comments), {len(unresolved)} unresolved",
               f"{sm_checked} stage source_model checked, {len(sm_unresolved)} unresolved",
               f"consumer map: {len(missing_cols)} missing column uses, {len(multi_sat)} multi-satellite stages",
               f"report: scripts/{SWEEP_REPORT}"]
    if cm_err:
        details.append(cm_err)
    details += [f"unresolved ref: {u['ref']} in {u['file']}" for u in unresolved[:10]]
    details += [f"unresolved source_model: {u['source_model']} in {u['stage']}" for u in sm_unresolved[:10]]
    return CheckResult("reference_sweep", ok, details, {k: v for k, v in sweep.items() if not isinstance(v, list)})


# ------------------------------------------- converted + staging models (12.1)

_VIEW_RE = re.compile(r"^stitch_v\d\d_")
_FALLBACK_RE = re.compile(r"^stitch_fb_v\d\d_")
_WM_RE = re.compile(r"\bas\s+inc_job_updated_at\b", re.I)
_MACRO_ARGS = ("sources", "output_columns", "coalesce_rules", "unique_key", "target_sat")
_SOURCE_TAG_RE = re.compile(r"^OPUS_[A-Z0-9_]+$")
_JINJA_PAIRS = (("{{", "}}"), ("{%", "%}"), ("{#", "#}"))


def strip_sql_comments(text: str) -> str:
    """Drop whole-line `--` comments."""
    return "\n".join(l for l in text.splitlines() if not l.lstrip().startswith("--"))


def stitched_files(ctx: Context) -> dict[str, Path]:
    d = ctx.root / "models" / "raw_vault" / "standard" / "stitched"
    return {p.stem: p for p in sorted(d.glob("*.sql"))} if d.is_dir() else {}


def macro_parts(ctx: Context) -> dict[str, Path]:
    """Stitched models that are macro parts (not consumer views, not Fallback_Stitches)."""
    return {n: p for n, p in stitched_files(ctx).items()
            if not _VIEW_RE.match(n) and not _FALLBACK_RE.match(n)}


def check_macro_part_structure(ctx: Context) -> CheckResult:
    """Each macro part has exactly one stitch_incremental( call with the five named arguments."""
    parts = macro_parts(ctx)
    bad: list[str] = []
    for name, p in parts.items():
        code = strip_sql_comments(p.read_text(encoding="utf-8"))
        n = code.count("stitch_incremental(")
        if n != 1:
            bad.append(f"{name}: {n} stitch_incremental( calls")
            continue
        call = code[code.index("stitch_incremental("):]
        for arg in _MACRO_ARGS:
            if not re.search(rf"\b{arg}\s*=", call):
                bad.append(f"{name}: argument {arg} missing")
    return CheckResult("macro_part_structure", bool(parts) and not bad,
                       [f"{len(parts)} macro parts checked, {len(bad)} problems"] + bad[:20],
                       {"parts": len(parts), "problems": len(bad)})


def check_jinja_balanced(ctx: Context) -> CheckResult:
    files = stitched_files(ctx)
    bad: list[str] = []
    for name, p in files.items():
        text = p.read_text(encoding="utf-8")
        for o, c in _JINJA_PAIRS:
            if text.count(o) != text.count(c):
                bad.append(f"{name}: {o} x{text.count(o)} vs {c} x{text.count(c)}")
    return CheckResult("jinja_balanced", bool(files) and not bad,
                       [f"{len(files)} stitched files checked, {len(bad)} unbalanced"] + bad[:20],
                       {"files": len(files), "unbalanced": len(bad)})


def check_source_tags(ctx: Context) -> CheckResult:
    """source_tag matches ^OPUS_[A-Z0-9_]+$ and every tag of a part shares the OPUS_ prefix."""
    parts = macro_parts(ctx)
    bad: list[str] = []
    tags_total = 0
    for name, p in parts.items():
        tags = re.findall(r"'source_tag'\s*:\s*'([^']*)'", p.read_text(encoding="utf-8"))
        tags_total += len(tags)
        if not tags:
            bad.append(f"{name}: no source_tag")
        for t in tags:
            if not _SOURCE_TAG_RE.match(t):
                bad.append(f"{name}: bad source_tag {t!r}")
        if len({t.split("_", 1)[0] for t in tags}) > 1:
            bad.append(f"{name}: more than one prefix")
    return CheckResult("source_tags", bool(parts) and not bad,
                       [f"{tags_total} source_tags in {len(parts)} parts, {len(bad)} problems"] + bad[:20],
                       {"tags": tags_total, "problems": len(bad)})


def check_legacy_tokens(ctx: Context) -> CheckResult:
    """`union all` only in consumer views / Fallback_Stitches; __PREC, __RID, first_value only in Fallback_Stitches."""
    bad: list[str] = []
    files = stitched_files(ctx)
    for name, p in files.items():
        if _FALLBACK_RE.match(name):
            continue
        code = strip_sql_comments(p.read_text(encoding="utf-8"))
        if not _VIEW_RE.match(name) and re.search(r"\bunion\s+all\b", code, re.I):
            bad.append(f"{name}: union all in a macro part")
        for label, rx in (("__PREC", r"\b__PREC\b"), ("__RID", r"\b__RID\b"), ("first_value", r"\bfirst_value\b")):
            if re.search(rx, code, re.I):
                bad.append(f"{name}: {label}")
    return CheckResult("legacy_tokens", bool(files) and not bad,
                       [f"{len(files)} stitched files scanned, {len(bad)} misplaced tokens"] + bad[:20],
                       {"files": len(files), "misplaced": len(bad)})


def _view_columns(text: str) -> list[str]:
    """Output aliases of the first select of a consumer view (comments stripped)."""
    code = strip_sql_comments(text)
    m = re.search(r"^select\b(.*?)^from\b", code, re.S | re.M | re.I)
    cols: list[str] = []
    for line in (m.group(1) if m else "").splitlines():
        a = re.search(r"\bas\s+([A-Za-z_][A-Za-z0-9_]*)\s*,?\s*$", line)
        if a:
            cols.append(a.group(1).upper())
    return cols


def _original_stitch(ctx: Context, name: str) -> str | None:
    for layout in ("automate_dv", "raw_vault"):
        try:
            proc = subprocess.run(
                ["git", "show", f"HEAD:./models/{layout}/standard/stitched/{name}.sql"],
                cwd=ctx.root, capture_output=True, timeout=60)
        except (OSError, subprocess.TimeoutExpired):
            return None
        if proc.returncode == 0 and b"with merged" in proc.stdout.lower().replace(b"\r", b""):
            return proc.stdout.decode("utf-8")
    return None


def check_consumer_view_columns(ctx: Context) -> CheckResult:
    """Each consumer view stitch_vNN_* keeps the original column list and order (original from git HEAD)."""
    views = {n: p for n, p in stitched_files(ctx).items() if _VIEW_RE.match(n)}
    sys.path.insert(0, str(ctx.root / "scripts"))
    try:
        import convert_stitches as cs
    finally:
        sys.path.pop(0)
    bad: list[str] = []
    skipped: list[str] = []
    compared = 0
    for name, p in views.items():
        orig = _original_stitch(ctx, name)
        if orig is None:
            skipped.append(name)
            continue
        expected = [c.upper() for c in cs.parse(orig, name + ".sql").columns]
        actual = _view_columns(p.read_text(encoding="utf-8"))
        compared += 1
        if actual != expected:
            missing = [c for c in expected if c not in actual]
            extra = [c for c in actual if c not in expected]
            bad.append(f"{name}: missing={missing[:3]} extra={extra[:3]} "
                       f"order_equal={sorted(actual) == sorted(expected)}")
    ok = len(views) > 0 and not bad and not skipped
    return CheckResult("consumer_view_columns", ok,
                       [f"{len(views)} consumer views, {compared} compared with HEAD originals, "
                        f"{len(skipped)} without original, {len(bad)} differ"] + bad[:20]
                       + [f"no original in git HEAD: {s}" for s in skipped[:10]],
                       {"views": len(views), "compared": compared, "differ": len(bad), "skipped": len(skipped)})


def check_stg_watermark_count(ctx: Context) -> CheckResult:
    stg = sorted((ctx.root / "models").rglob("stg_health__*.sql"))
    with_col = [p for p in stg if _WM_RE.search(strip_sql_comments(p.read_text(encoding="utf-8")))]
    without = [p.stem for p in stg if p not in with_col]
    return CheckResult("stg_inc_job_updated_at_count", bool(stg) and not without,
                       [f"{len(with_col)}/{len(stg)} stg_health__* models contain 'as inc_job_updated_at'"]
                       + [f"missing: {n}" for n in without[:20]],
                       {"with": len(with_col), "total": len(stg), "missing": without})


def check_watermark_precheck(ctx: Context) -> CheckResult:
    """Every source of every macro part must select inc_job_updated_at; varchar ones are listed."""
    stg = {p.stem: p for p in (ctx.root / "models").rglob("stg_health__*.sql")}
    info: dict[str, tuple[bool, str | None]] = {}
    for n, p in stg.items():
        hit = next((l for l in strip_sql_comments(p.read_text(encoding="utf-8")).splitlines()
                    if _WM_RE.search(l)), None)
        info[n] = (hit is not None, None if hit is None else
                   ("varchar" if "to_varchar" in hit.lower() else "timestamp_ntz"))
    table: list[dict] = []
    problems: list[str] = []
    for name, p in macro_parts(ctx).items():
        models = list(dict.fromkeys(re.findall(r"'model'\s*:\s*'([^']+)'", p.read_text(encoding="utf-8"))))
        srcs = []
        for m in models:
            sel, typ = info.get(m, (False, None))
            if m not in stg:
                problems.append(f"{name}: source {m} has no stg file")
            elif not sel:
                problems.append(f"{name}: source {m} does not select inc_job_updated_at")
            srcs.append({"model": m, "selects": sel, "type": typ})
        table.append({"part": name, "sources": srcs})
    varchar = sorted({s["model"] for r in table for s in r["sources"] if s["type"] == "varchar"})
    varchar_parts = [r["part"] for r in table if any(s["type"] == "varchar" for s in r["sources"])]
    return CheckResult(
        "watermark_precheck", bool(table) and not problems,
        [f"{len(table)} parts, {sum(len(r['sources']) for r in table)} source refs, {len(problems)} problems",
         f"varchar inc_job_updated_at models read by parts: {len(varchar)}",
         f"parts reading a varchar watermark: {len(varchar_parts)}"]
        + [f"varchar model: {m}" for m in varchar] + problems[:20],
        {"parts": len(table), "varchar_models": varchar, "varchar_parts": varchar_parts,
         "problems": len(problems), "table": table})


CHECKS: list[Callable[[Context], CheckResult]] = [
    check_yaml_valid,
    check_profile_name,
    check_configured_folders,
    check_macros_equal,
    check_packages_yml,
    check_vendored_packages,
    check_gitignore,
    check_vendored_not_ignored,
    check_reference_sweep,
    check_macro_part_structure,
    check_jinja_balanced,
    check_source_tags,
    check_legacy_tokens,
    check_consumer_view_columns,
    check_stg_watermark_count,
    check_watermark_precheck,
]


def run_checks(ctx: Context, checks=None) -> list[CheckResult]:
    results = []
    for fn in checks or CHECKS:
        try:
            results.append(fn(ctx))
        except Exception as exc:  # a crashing check is a failed check
            results.append(CheckResult(fn.__name__, False, [f"crashed: {exc!r}"]))
    return results


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--json", action="store_true", help="print results as JSON")
    ap.add_argument("--partner", type=Path, default=DEFAULT_PARTNER, help="Partner project path")
    args = ap.parse_args(argv)

    results = run_checks(Context(ROOT, args.partner.resolve()))
    ok = all(r.ok for r in results)
    if args.json:
        print(json.dumps({"ok": ok, "checks": [asdict(r) for r in results]}, indent=2))
    else:
        for r in results:
            print(f"[{'PASS' if r.ok else 'FAIL'}] {r.name}")
            for d in r.details:
                print(f"       {d}")
        print("OVERALL:", "PASS" if ok else "FAIL")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
