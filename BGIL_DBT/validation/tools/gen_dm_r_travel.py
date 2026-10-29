#!/usr/bin/env python3
"""
Travel LOB equivalent of gen_dm_r.py.

Points at opus_travel_dv_dbt + maximus_travel_dv_dbt and writes under
BGIL_DBT/validation/travel/DM-R/. Reuses the partner gen_dm_r helpers.

Link feeds: Maximus Travel writes lnkfeed_mt_<link> views (same shape
as the maximus_partner hubfeed pattern -- union-all over stg2 wrappers
with a trailing `where <FK_BK> is not null`). OPUS Travel has no links.

Row filters scope link-side rows to the project's RECORD_SOURCE value set
(parsed via gen_dm_a_travel's resolver), not a bare prefix, to avoid
overlap with the partner build in the shared vault.

    python3 BGIL_DBT/validation/tools/gen_dm_r_travel.py
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k_travel as K  # noqa: E402
import gen_dm_a_travel as AT  # noqa: E402
import gen_dm_a as A  # noqa: E402
import gen_dm_r as R  # noqa: E402
import gen_dm_k as PK  # noqa: E402

VALIDATION = K.VALIDATION
PROJECTS = AT.PROJECTS
GHOST = K.GHOST_HKEY


# ---------------------------------------------------------------------------
# Point partner's gen_dm_r at the travel projects; override its hubfeed/
# lnkfeed parser so it understands the mt shape via A.resolve (patched by
# gen_dm_a_travel to handle satfeed_/hubfeed_/lnkfeed_).
# ---------------------------------------------------------------------------
def link_feed_arms_travel(md, feed):
    """Parse a lnkfeed_mt_* (or OPUS style) feed into [(label, Arm)]."""
    try:
        sql = PK.read(PK.find_model(md, feed))
    except SystemExit as e:
        raise RuntimeError(f"missing feed {feed}: {e}")
    try:
        PK.yaml_block(sql)
        return [(f"{feed} <- {a.label}", a) for a in AT.resolve_travel(md, feed)]
    except ValueError:
        pass
    out = []
    body = A.strip_sql_comments(sql)
    for part in re.split(r"\bunion\s+all\b", body, flags=re.I):
        if "ref(" not in part:
            continue
        w = re.search(r"\}\}\s*where\b(.*)$", part, re.S | re.I)
        if w:
            # strip the trailing `where ... is not null` -- parse_wrapper
            # cannot handle it (it rejects wrappers with where/qualify).
            part = part[:w.start()] + "}}"
        try:
            ref, rename = A.parse_wrapper(part)
        except Exception:
            continue
        try:
            arms = AT.resolve_travel(md, ref)
        except (RuntimeError, SystemExit, Exception):
            continue
        for a in arms:
            wa = a.wrap(rename)
            if w:
                try:
                    cond = A.subst(A.lower_idents(w.group(1).strip()), wa.lookup)
                    wa.where = f"({wa.where}) and ({cond})" if wa.where else cond
                except Exception:
                    pass
            out.append((f"{feed} <- {ref}", wa))
    return out


R.link_feed_arms = link_feed_arms_travel
# Point A's resolve at the travel one so R.build_links picks it up too.
A.resolve = AT.resolve_travel
A.PROJECTS = PROJECTS


def build_links_travel():
    links = []
    for project, md in PROJECTS:
        link_dir = md / "raw_vault" / "standard" / "links"
        if not link_dir.exists():
            continue
        for path in sorted(link_dir.glob("link_*.sql")):
            try:
                ln = R.Link(project, md, path)
            except Exception as e:
                print(f"  SKIP link {path.name}: {e}")
                continue
            for src in ln.sources:
                try:
                    if PK.is_disabled(PK.read(PK.find_model(md, src))):
                        ln.skipped.append(f"{src}: disabled placeholder")
                        continue
                except SystemExit as e:
                    ln.skipped.append(f"{src}: {e}")
                    continue
                try:
                    arms = link_feed_arms_travel(md, src)
                except Exception as e:
                    ln.skipped.append(f"{src}: resolver error ({e})")
                    continue
                for label, arm in arms:
                    exprs = [arm.lookup.get(c) for c in [ln.pk] + ln.fks + [ln.ldts]]
                    if any(e is None for e in exprs):
                        ln.skipped.append(
                            f"{label}: FK/PK/LDTS column(s) not traceable "
                            f"({[(c, arm.lookup.get(c)) for c in [ln.pk] + ln.fks + [ln.ldts]]})")
                        continue
                    ln.feeds.append((label, arm))
                    for fk in ln.fks:
                        if fk not in ln.fk_hub:
                            m = re.search(r"'(HUB_[A-Z_]+)\|'", arm.lookup.get(fk) or "")
                            # Travel: FK alias name indicates hub target too
                            # (e.g. CLAIM_HKEY -> HUB_CLAIM; PARTY_HKEY -> HUB_PARTY).
                            ln.fk_hub[fk] = (m.group(1) if m else
                                             "HUB_" + re.sub(r"(^RELATED_)|(_HKEY$)", "", fk))
            links.append(ln)
    return links


# ---------------------------------------------------------------------------
# Row scope override: travel RECORD_SOURCE value set per project rather
# than startswith('<project>_'). We get the set from the link's feeds.
# ---------------------------------------------------------------------------
def _link_rsrcs(ln):
    rs = set()
    for _label, arm in ln.feeds:
        v = arm.lookup.get("record_source")
        if v and re.fullmatch(r"'[^']*'", v):
            rs.add(v.strip("'"))
    return sorted(rs)


def _project_rsrcs(sats):
    rs = set()
    for s in sats:
        for g in s.groups.values():
            if g.rs_value:
                rs.add(g.rs_value)
    return sorted(rs)


def _scope_sql(rsrcs, alias=""):
    if not rsrcs:
        return None
    lits = ", ".join("'" + v.replace("'", "''") + "'" for v in rsrcs)
    a = f"{alias}." if alias else ""
    return f"{a}RECORD_SOURCE in ({lits})"


# Patch partner's `scope()` and R2 scope expressions.
def scope_travel(sat):
    rs = sorted({g.rs_value for g in sat.groups.values() if g.rs_value})
    if rs:
        return _scope_sql(rs)
    # OBJECT sats or stitch grouping (rare in travel): use the partner default.
    return R.scope(sat) if False else f"startswith(RECORD_SOURCE, '{sat.project}_')"


# ---------------------------------------------------------------------------
# Overrides for R1 / R2 so hub-side and link-side row scopes use the
# travel RECORD_SOURCE value set, not just the prefix.
# ---------------------------------------------------------------------------
def r1_section_travel(sat, pmap):
    sec = R.r1_section(sat, pmap)
    # Rewrite the inner scope to use travel RECORD_SOURCE value set.
    scope_old = R.scope(sat)
    scope_new = scope_travel(sat)
    if sec.get("queries"):
        label, sql = sec["queries"][0]
        sql = sql.replace(
            scope_old.replace("RECORD_SOURCE", "s.RECORD_SOURCE"),
            scope_new.replace("RECORD_SOURCE", "s.RECORD_SOURCE"))
        sec = dict(sec, queries=[(label, sql)])
    return sec


def r2_sections_travel(ln):
    rsrcs = _link_rsrcs(ln)
    sections = R.r2_sections(ln)
    if not rsrcs:
        return sections
    scope_new = _scope_sql(rsrcs, "l")
    scope_old = f"startswith(l.RECORD_SOURCE, '{ln.prefix}')"
    for sec in sections:
        if sec.get("queries"):
            new_q = []
            for label, sql in sec["queries"]:
                new_q.append((label, sql.replace(scope_old, scope_new)))
            sec["queries"] = new_q
        existing_note = sec.get("note") or ""
        sec["note"] = (existing_note
                       + f" Link rows scoped by RECORD_SOURCE value set "
                         f"({len(rsrcs)} travel feeds) rather than the shared "
                         f"'{ln.prefix}' prefix.")
    return sections


# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------
COMMON = [
    ("Owner", "LUMIQ"),
    ("Vault location", K.VAULT),
    ("Maximus Travel RAW", K.RAW_SCHEMA["maximus_travel_raw"]),
    ("Opus Travel RAW (prod)", K.RAW_SCHEMA["travel_raw"]),
    ("Opus Travel RAW (test)", K.RAW_SCHEMA["travel_test_raw"]),
    ("Shared vault", "Parents (hubs / links) are checked across ALL their rows "
                     "(a key may have been loaded by the partner build in the same "
                     "vault). Child rows (satellites / links) are scoped to this "
                     "project's TRAVEL RECORD_SOURCE value set."),
    ("Ghost record", f"Satellite rows keyed by the ghost hash {GHOST} are excluded."),
]

CHECKS = OrderedDict([
    ("DM-R1", dict(
        title="DM-R1  |  Referential Integrity \u2014 No Orphan Satellite Rows (Travel LOB)",
        subtitle="Every satellite row references a valid hub (or link) key. Pass criterion: 0 orphan rows.",
        overview=[("Check ID", "DM-R1"), ("Category", "Referential integrity"),
                  ("Sign-off criterion", "No orphan satellite rows"),
                  ("Method", "Anti-join: satellite key \u2192 parent hub / link"),
                  ("Pass criteria / tolerance", "0 orphan satellite rows")] + COMMON)),
    ("DM-R2", dict(
        title="DM-R2  |  Referential Integrity \u2014 Links Reconcile (Travel LOB)",
        subtitle="Every valid source relationship exists as a link row; no orphan links.",
        overview=[("Check ID", "DM-R2"), ("Category", "Referential integrity"),
                  ("Sign-off criterion", "Relationships / links reconcile"),
                  ("Method", "(a) RAW relationships \u2192 link; (b) link FK \u2192 hub; (c) link \u2192 RAW"),
                  ("Pass criteria / tolerance", "0 missing / orphan links")] + COMMON)),
])


def _parents_travel():
    """Like R.parents() but filters hub_*.sql / link_*.sql only (travel's
    links/ dir also contains lnkfeed_*.sql which has no yaml_metadata)."""
    out = OrderedDict()
    for _, md in PROJECTS:
        for kind, prefix in (("hubs", "hub_"), ("links", "link_")):
            d = md / "raw_vault" / "standard" / kind
            if not d.exists():
                continue
            for path in sorted(d.glob(f"{prefix}*.sql")):
                try:
                    pk = PK.yaml_block(PK.read(path))["src_pk"]
                except Exception:
                    continue
                if kind == "hubs":
                    R.HUB_PK[path.stem.upper()] = pk.upper()
                out.setdefault(pk.upper(), [])
                if path.stem.upper() not in out[pk.upper()]:
                    out[pk.upper()].append(path.stem.upper())
    return out


def main():
    template = K.TEMPLATE_DOCX.read_bytes() if K.TEMPLATE_DOCX else None
    (VALIDATION / "DM-R").mkdir(parents=True, exist_ok=True)
    pmap = _parents_travel()
    sats = AT.build_sats_travel()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    links = build_links_travel()
    for pj, md in PROJECTS:
        ps = [s for s in sats if s.project == pj]
        pl = [l for l in links if l.project == pj]
        no_parent = [s.name for s in ps if s.pk.upper() not in pmap]
        revision = [
            f"Travel LOB generated 2026-10-13 from the current {md.parent.name} "
            f"models by validation/tools/gen_dm_r_travel.py.",
            f"This file: {pj} only -- {len(ps)} satellites and {len(pl)} links "
            f"({', '.join(l.name for l in pl) or 'none'}).",
            ("Satellites with no parent hub / link: " + ", ".join(no_parent) + ".")
            if no_parent else "Every satellite key has a parent hub / link.",
            "Row filters use RECORD_SOURCE value sets parsed from each project's own "
            "feeds (not a bare prefix), because the shared vault also contains partner "
            "rows under the same MAXIMUS_ / OPUS_ prefix.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-R1":
                sections = [R.r1_summary(pj, ps, pmap)] + \
                    [r1_section_travel(s, pmap) for s in ps]
            else:
                sections = [x for l in pl for x in r2_sections_travel(l)]
                if not sections:
                    sections = [dict(project=pj, hub="No links in this project",
                                     status="NA", pass_criteria="NA",
                                     note=f"{pj} travel has 0 link models.",
                                     queries=[("SQL", f"-- {pj} travel: no links yet")])]
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})",
                         overview=meta["overview"] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            PK.write_sql(fid, pmeta, sections, revision)
            if template is not None:
                A.write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections, "
                  f"{sum(x['status'] == 'NA' for x in sections)} NA, "
                  f"{sum(x['status'] == 'Design finding' for x in sections)} findings")
    for l in links:
        print(f"  {l.project:8} {l.name:28} feeds={len(l.feeds):3} "
              f"fks={dict(l.fk_hub)} skipped={len(l.skipped)}")


if __name__ == "__main__":
    main()
