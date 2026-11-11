# -*- coding: utf-8 -*-
"""Write every model, in partner_dv_dbt / travel_dv_dbt's layout, from feeds.json + stitch_plan.json.

  models/staging/health/stg_health__<table>          1:1 casts, one per table a view reads
  models/automate_dv/standard/stitched/stitch_<v>    THE CENTRAL VIEWS (plain SQL, no hashing)
  models/automate_dv/standard/staging/stg2_<v>       automate_dv.stage(): every hub + link key
  models/automate_dv/standard/staging/stg2_<sat>     automate_dv.stage(): one satellite's pk,
                                                     payload and HASHDIFF, read off its view
  models/automate_dv/standard/{hubs,links,satellites} automate_dv.hub() / link() / sat() / ma_sat()
  models/automate_dv/augmented/{staging,satellites}  the augmentation track, same mechanics

How a central view merges its tables (the 'join'): each table contributes one or more branches,
each projecting the hub business keys its rows carry and the satellite attributes it feeds. The
branches are stacked, and every satellite attribute is then merged ACROSS tables on that
satellite's own key with FIRST_VALUE ... IGNORE NULLS in declared source precedence. That is a
keyed join of the tables' attributes that cannot fan out: a multi-way FULL OUTER JOIN multiplies
rows whenever two tables each hold several rows for one key, and collapsing it to one row per key
would throw away the very key pairs the links are built from. Here each link pair comes from one
source row, which carries both legs.

Why one stage per satellite (and not one per view): automate_dv.sat() takes no filter. A view
holds keys of tables that do not feed every satellite on it, and a sat() over a view-wide stage
would load an all-NULL row for each of them. The per-satellite stage NULLs the key wherever that
satellite has no payload, which is the filter sat() lacks.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import v5_common as C  # noqa: E402

LDTS = "'!CURRENT_TIMESTAMP()'"
ROLE_LINK = "LNK_PARTY_ROLE"


def q1(s):
    """YAML single-quoted scalar."""
    return "'" + s.replace("'", "''") + "'"


def q2(s):
    """YAML double-quoted scalar for a SQL expression (which carries single quotes)."""
    if '"' in s or "\\" in s:
        raise AssertionError("expression cannot be carried in YAML: %r" % s)
    return '"' + s + '"'


def jinja_safe(s):
    for tok in ("{{", "}}", "{%", "%}", "{#", "#}"):
        if tok in s:
            raise AssertionError("jinja delimiter in generated YAML: %r" % s)
    return s


def sql_lit(v):
    return "'" + v.replace("'", "''") + "'"


def ck_col(leg):
    return C.upper_snake(leg) + "_CK"


def view_col(sat, name):
    return C.short(sat) + "__" + name


def link_flag(lnk):
    return "__LNK_" + C.short(lnk)


def link_nk(lnk, hubs, cond):
    parts = " || '|' || ".join(C.bk_col(h) for h in sorted(hubs))
    return "case when %s then '%s|' || %s end" % (cond, lnk, parts)


STAGE_TAIL = """{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}"""


def stage_model(header, source, hashed, derived):
    """hashed: [(col, nk)] or [(col, {'hashdiff': [cols]})]; derived: [(col, value_yaml)]."""
    body = ["source_model: %s" % q1(source), "hashed_columns:"]
    for col, v in hashed:
        if isinstance(v, dict):
            body.append("  %s:" % col)
            body.append("    is_hashdiff: true")
            body.append("    columns:")
            body.extend("      - %s" % q1(c) for c in v["hashdiff"])
        else:
            body.append("  %s: %s" % (col, q1(v)))
    body.append("derived_columns:")
    body.extend("  %s: %s" % (k, v) for k, v in derived)
    # Only the YAML body is checked: the config() call and the set/endset tags around it are
    # meant to be Jinja, and a delimiter INSIDE the body would be rendered rather than parsed.
    jinja_safe("\n".join(body))
    return "\n".join([header, "{{ config(materialized='view') }}", "", "{%- set yaml_metadata -%}"]
                     + body + [STAGE_TAIL])


def vault_model(header, macro, meta, args):
    lines = [header, "{{ config(materialized='incremental') }}", "", "{%- set yaml_metadata -%}"]
    for k, v in meta:
        if isinstance(v, list):
            lines.append("%s:" % k)
            lines.extend("  - %s" % q1(x) for x in v)
        else:
            lines.append("%s: %s" % (k, q1(v)))
    lines += ["{%- endset -%}", "", "{% set metadata_dict = fromyaml(yaml_metadata) %}", ""]
    pad = " " * (len("{{ automate_dv.%s(" % macro))
    call = ",\n".join(("%s=metadata_dict['%s']" % (a, a)) for a in args)
    call = call.replace("\n", "\n" + pad)
    lines.append("{{ automate_dv.%s(%s) }}" % (macro, call))
    return "\n".join(lines)


def main():
    prof = C.profile()
    rank = prof["source_precedence"]["run_rank"]
    F = C.read_json("feeds.json")
    P = C.read_json("stitch_plan.json")
    specs, runs = F["sat_specs"], F["table_runs"]
    feeds_by = collections.defaultdict(list)
    for f in F["feeds"]:
        feeds_by[(f["sat"], f["table"])].append(f)
    reg = C.Register()
    C.wipe_models()

    manifest = {"views": {}, "stages": {}, "vault": {}, "staging": {}}

    # ------------------------------------------------------------------ staging (layer 1)
    staged = sorted({t for v in P["views"] for t in v["tables"]})
    filters = prof.get("row_filters", {})
    for t in staged:
        cols = [c for c in F["table_columns"][t] if c.replace("_", "").replace("$", "").isalnum()
                and (c[0].isalpha() or c[0] == "_")]
        body = ",\n".join('        nullif(trim(to_varchar("%s")), \'\') as %s' % (c, C.source_alias(c))
                          for c in cols)
        where = ("\n    where %s" % filters[t]) if t in filters else ""
        C.write_model("staging", "stg_health__" + t.lower(), (
            "-- Staging for source table %s (run %s). Every column is trimmed varchar: the pinned\n"
            "-- inputs carry no datatype catalogue for this half, so no type is inferred.\n"
            "with source as (\n\n    select\n%s\n    from {{ source('health_raw', '%s') }}%s\n\n)\n\n"
            "select * from source") % (t, runs[t], body, t, where))
        manifest["staging"]["stg_health__" + t.lower()] = [C.source_alias(c) for c in cols]
    src_yml = ["version: 2", "", "sources:", "  - name: health_raw",
               "    description: >",
               "      Health source tables (legacy v4, OPUS v2 and delta 3 runs) landed in Snowflake",
               "      as-is. Database/schema are vars -- point them at where ingestion lands them.",
               "    database: \"{{ var('health_raw_database', 'RAW') }}\"",
               "    schema: \"{{ var('health_raw_schema', 'HEALTH') }}\"", "    tables:"]
    src_yml += ["      - name: %s" % t for t in staged]
    C.write_text(os.path.join(C.DIRS["staging"], "_health__sources.yml"), "\n".join(src_yml))

    hub_sources = collections.defaultdict(list)
    link_sources = collections.defaultdict(list)
    link_fks = {}

    for v in P["views"]:
        vname, smodel, gmodel = v["name"], v["stitch_model"], v["stage_model"]
        sats_here = v["satellites"]
        pairs_by_table = collections.defaultdict(list)
        for c in v["link_pairs"]:
            pairs_by_table[c["table"]].append(c)

        # ---- branches
        branches = []
        for ti, t in enumerate(v["tables"]):
            prec = rank[runs[t]] * 1000 + ti
            groups = collections.OrderedDict()
            for s in sats_here:
                for f in feeds_by.get((s, t), []):
                    bk = tuple(sorted((C.bk_col(h), e) for h, e in f["legs"].items()))
                    lits = tuple(sorted((s, leg, val[1]) for leg, val in f["cdk"].items()
                                        if val and val[0] == "lit"))
                    # a child key read from a column is part of the branch's identity too: two
                    # feeds of one satellite whose leg comes from DIFFERENT columns are two
                    # child-key instances, and must not share a row
                    ccdk = tuple(sorted((s, leg, val[1]) for leg, val in f["cdk"].items()
                                        if val and val[0] == "col"))
                    groups.setdefault((bk, lits, ccdk), []).append(f)
            mine = []
            for (bk, lits, ccdk), fs in groups.items():
                if not lits:
                    for b in mine:
                        if (not b["lits"] and all(b["bk"].get(k, e) == e for k, e in bk)
                                and all(b["ccdk"].get((s, l), a) == a for s, l, a in ccdk)):
                            b["bk"].update(dict(bk))
                            b["ccdk"].update({(s, l): a for s, l, a in ccdk})
                            b["feeds"].extend(fs)
                            break
                    else:
                        mine.append({"bk": dict(bk), "lits": lits, "feeds": list(fs), "flags": set(),
                                     "ccdk": {(s, l): a for s, l, a in ccdk}})
                else:
                    mine.append({"bk": dict(bk), "lits": lits, "feeds": list(fs), "flags": set(),
                                 "ccdk": {(s, l): a for s, l, a in ccdk}})
            for c in pairs_by_table.get(t, []):
                want = {C.bk_col(h): e for h, e in c["legs"].items()}
                for b in mine:
                    if not b["lits"] and all(b["bk"].get(k, e) == e for k, e in want.items()):
                        b["bk"].update(want)
                        b["flags"].add(c["link"])
                        break
                else:
                    mine.append({"bk": want, "lits": (), "feeds": [], "flags": {c["link"]},
                                 "ccdk": {}})
            for b in mine:
                for f in b["feeds"]:
                    if specs[f["sat"]]["kind"] == "link":
                        b["flags"].add(specs[f["sat"]]["parent"])
                b["table"], b["prec"] = t, prec
            branches.extend(mine)

        # ---- view columns
        bk_cols = sorted({k for b in branches for k in b["bk"]})
        has_role = any(specs[s]["kind"] == "role" for s in sats_here)
        links_here = sorted({l for b in branches for l in b["flags"]})
        flag_cols = [link_flag(l) for l in links_here]
        sat_cols = collections.OrderedDict()
        for s in sats_here:
            sp = specs[s]
            cks = [view_col(s, ck_col(l)) for l in sp["cdk_legs"]]
            pays = sorted({f["payload"] for tt in v["tables"] for f in feeds_by.get((s, tt), [])})
            sat_cols[s] = {"cdk": cks, "payload": [view_col(s, p) for p in pays],
                           "payload_names": pays, "cdk_names": [ck_col(l) for l in sp["cdk_legs"]],
                           "part": [C.bk_col(h) for h in sp["pk_hubs"]] + cks}
        all_cols = bk_cols + (["ROLE_TYPE_CODE"] if has_role else []) + flag_cols
        for s, sc in sat_cols.items():
            all_cols += sc["cdk"] + sc["payload"]
        if len(set(all_cols)) != len(all_cols):
            raise AssertionError("view column names collide in %s" % vname)

        ctes = []
        for bi, b in enumerate(branches):
            ex = {}
            for k, e in b["bk"].items():
                ex[k] = e
            for l in b["flags"]:
                ex[link_flag(l)] = "1"
            per = collections.defaultdict(list)
            for f in sorted(b["feeds"], key=lambda x: (x["sat"], x["payload"], x["column"])):
                per[view_col(f["sat"], f["payload"])].append(f["column"])
                for leg, val in f["cdk"].items():
                    if not val:
                        continue
                    colname = view_col(f["sat"], ck_col(leg))
                    rendered = val[1] if val[0] == "col" else sql_lit(val[1])
                    if colname in ex and ex[colname] != rendered:
                        reg.refuse("child_key_conflict_in_branch", "%s on %s" % (f["sat"], b["table"]),
                                   "two feeds in one branch give leg %s different values; the "
                                   "first is kept" % leg, "mapper", satellite=f["sat"])
                        continue
                    ex[colname] = rendered
                    if specs[f["sat"]]["kind"] == "role" and val[0] == "lit":
                        ex["ROLE_TYPE_CODE"] = sql_lit(val[1])
            for colname, srcs in per.items():
                srcs = sorted(set(srcs))
                ex[colname] = srcs[0] if len(srcs) == 1 else "coalesce(%s)" % ", ".join(srcs)
            sel = []
            for c in all_cols:
                if c in ex:
                    sel.append("        %s as %s" % (ex[c], c))
                elif c.startswith("__LNK_"):
                    sel.append("        cast(null as number) as %s" % c)
                else:
                    sel.append("        cast(null as varchar) as %s" % c)
            sel.append("        %d as __PREC" % b["prec"])
            sel.append("        hash(*) as __RID")
            keyed = sorted(b["bk"].values())
            cond = keyed[0] if len(keyed) == 1 else "coalesce(%s)" % ", ".join(keyed)
            ctes.append("    -- branch %d: %s%s\n    select\n%s\n    from {{ ref('stg_health__%s') }}\n"
                        "    where (%s) is not null" % (
                            bi, b["table"], (" | child-key literal(s): %s" % ", ".join(
                                "%s.%s=%s" % (C.short(s), l, x) for s, l, x in b["lits"]))
                            if b["lits"] else "", ",\n".join(sel), b["table"].lower(), cond))
        final = []
        for c in bk_cols + (["ROLE_TYPE_CODE"] if has_role else []) + flag_cols:
            final.append("    %s" % c)
        for s, sc in sat_cols.items():
            final.extend("    %s" % c for c in sc["cdk"])
            part = ", ".join(sc["part"])
            for c in sc["payload"]:
                final.append("    first_value(%s) ignore nulls over (partition by %s order by __PREC, "
                             "__RID rows between unbounded preceding and unbounded following) as %s"
                             % (c, part, c))
        header = [
            "-- CENTRAL VIEW %s -- the layer the governing central-view rule is about." % vname,
            "-- Tables merged, in source precedence (v2, then legacy, then delta 3):",
        ] + ["--   %s (%s)" % (t, runs[t]) for t in v["tables"]] + [
            "-- Satellites fed WHOLE from this view (rule 2):",
        ] + ["--   %s" % s for s in sats_here] + [
            "-- Links whose legs come from one source row on this view (rule 6):",
        ] + ["--   %s" % l for l in links_here] + ([
            "-- OVER the table limit by rule 3: one satellite on this view needs every table above."]
            if v["over_limit"] else []) + [
            "-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.",
        ]
        # Branches are stacked directly in the union: one select per branch, separated by
        # `union all`, so every select's alias list stands on its own.
        sql = "\n".join(header) + "\n{{ config(materialized='view') }}\n\nwith merged as (\n\n" + \
              "\n\n    union all\n\n".join(ctes) + "\n\n)\n\nselect\n" + ",\n".join(final) + \
              "\nfrom merged"
        C.write_model("stitched", smodel, sql)
        manifest["views"][smodel] = {"columns": all_cols, "tables": v["tables"],
                                     "branches": len(branches)}

        # ---- view-level stage: every hub key and link key on the view
        hashed, derived = [], []
        hubs_here = sorted({c[:-3] for c in bk_cols if c.endswith("_BK")})
        for hs in hubs_here:
            hub = "HUB_" + hs
            hashed.append((hs + "_HKEY", hs + "_NK"))
            derived.append((hs + "_BK", q1(hs + "_BK")))
            derived.append((hs + "_NK", q2("'%s|' || %s_BK" % (hub, hs))))
            hub_sources[hub].append(gmodel)
        for l in links_here:
            ls = C.short(l)
            hubs = sorted(specs_link_hubs(l))
            hashed.append((ls + "_HKEY", ls + "_NK"))
            derived.append((ls + "_NK", q2(link_nk(l, hubs, "%s = 1" % link_flag(l)))))
            link_sources[l].append(gmodel)
            link_fks[l] = [C.short(h) + "_HKEY" for h in hubs]
        if has_role:
            hashed.append(("PARTY_ROLE_HKEY", "PARTY_ROLE_NK"))
            derived.append(("PARTY_ROLE_NK", q2("case when ROLE_TYPE_CODE is not null then "
                                               "'%s|' || PARTY_BK || '|' || ROLE_TYPE_CODE end"
                                               % ROLE_LINK)))
            link_sources[ROLE_LINK].append(gmodel)
            link_fks[ROLE_LINK] = ["PARTY_HKEY"]
        derived += [("LOAD_DATETIME", LDTS), ("RECORD_SOURCE", q1("!" + smodel))]
        C.write_model("std_staging", gmodel, stage_model(
            "-- automate_dv.stage() over central view %s: every hub key and link key the view\n"
            "-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6)."
            % smodel, smodel, hashed, derived))
        manifest["stages"][gmodel] = {"source": smodel, "dir": "std_staging",
                                      "columns": [c for c, _ in hashed] + [c for c, _ in derived]}

        # ---- per-satellite stages and satellites
        for s in sats_here:
            sp, sc = specs[s], sat_cols[s]
            aug = bool(sp.get("augmented"))
            sname = "stg2_" + C.short(s).lower()
            present = "coalesce(%s) is not null" % ", ".join(sc["payload"]) if len(sc["payload"]) > 1 \
                else "%s is not null" % sc["payload"][0]
            pk = sp["pk_col"]
            nk = pk[:-len("_HKEY")] + "_NK"
            if sp["kind"] == "link":
                nk_expr = link_nk(sp["parent"], sp["pk_hubs"], present)
            else:
                h = sp["pk_hubs"][0]
                nk_expr = "case when %s then '%s|' || %s end" % (present, h, C.bk_col(h))
            hd = sc["payload_names"] + (sc["cdk_names"] if sp["ma"] else [])
            derived = [(nk, q2(nk_expr))]
            derived += [(n, q1(c)) for n, c in zip(sc["cdk_names"], sc["cdk"])]
            derived += [(n, q1(c)) for n, c in zip(sc["payload_names"], sc["payload"])]
            derived += [("LOAD_DATETIME", LDTS), ("RECORD_SOURCE", q1("!" + smodel))]
            hashed = [(pk, nk), ("HASHDIFF", {"hashdiff": hd})]
            C.write_model("aug_staging" if aug else "std_staging", sname, stage_model(
                "-- automate_dv.stage() for %s, read off central view %s.\n"
                "-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes\n"
                "-- no filter, and a NULL key is the one row it is guaranteed to skip." % (s, smodel),
                smodel, hashed, derived))
            manifest["stages"][sname] = {"source": smodel, "dir": "aug_staging" if aug else "std_staging",
                                         "columns": [c for c, _ in hashed] + [c for c, _ in derived]}
            meta = [("source_model", sname), ("src_pk", pk)]
            if sp["ma"]:
                meta.append(("src_cdk", sc["cdk_names"]))
            meta += [("src_payload", sc["payload_names"]), ("src_hashdiff", "HASHDIFF"),
                     ("src_ldts", "LOAD_DATETIME"), ("src_source", "RECORD_SOURCE")]
            macro = "ma_sat" if sp["ma"] else "sat"
            args = ["src_pk"] + (["src_cdk"] if sp["ma"] else []) + [
                "src_payload", "src_hashdiff", "src_ldts", "src_source", "source_model"]
            mname = "sat_" + C.short(s).lower()
            C.write_model("aug_satellites" if aug else "satellites", mname, vault_model(
                "-- %s %s() for %s (parent %s, history %s), fed whole from central view %s." % (
                    "AUGMENTED track (not mapper-ratified)" if aug else "Standard", macro, s,
                    sp["parent"], sp["hist"], smodel), macro, meta, args))
            manifest["vault"][mname] = {"macro": macro, "sources": [sname], "pk": pk,
                                        "payload": sc["payload_names"],
                                        "cdk": sc["cdk_names"] if sp["ma"] else [],
                                        "dir": "aug_satellites" if aug else "satellites"}

    for hub, srcs in sorted(hub_sources.items()):
        hs = C.short(hub)
        mname = "hub_" + hs.lower()
        C.write_model("hubs", mname, vault_model(
            "-- hub() for %s, unioned over every central view that carries its key." % hub, "hub",
            [("source_model", sorted(srcs)), ("src_pk", hs + "_HKEY"), ("src_nk", hs + "_BK"),
             ("src_ldts", "LOAD_DATETIME"), ("src_source", "RECORD_SOURCE")],
            ["src_pk", "src_nk", "src_ldts", "src_source", "source_model"]))
        manifest["vault"][mname] = {"macro": "hub", "sources": sorted(srcs), "pk": hs + "_HKEY",
                                    "nk": hs + "_BK", "dir": "hubs"}
    for l, srcs in sorted(link_sources.items()):
        ls = C.short(l)
        mname = "lnk_" + ls.lower()
        C.write_model("links", mname, vault_model(
            "-- link() for %s. Every row's legs come from one source row on one central view." % l,
            "link", [("source_model", sorted(srcs)), ("src_pk", ls + "_HKEY"), ("src_fk", link_fks[l]),
                     ("src_ldts", "LOAD_DATETIME"), ("src_source", "RECORD_SOURCE")],
            ["src_pk", "src_fk", "src_ldts", "src_source", "source_model"]))
        manifest["vault"][mname] = {"macro": "link", "sources": sorted(srcs), "pk": ls + "_HKEY",
                                    "fk": link_fks[l], "dir": "links"}

    os.makedirs(C.DIRS["references"], exist_ok=True)
    os.makedirs(os.path.join(C.PROJECT, "macros"), exist_ok=True)
    write_project_files(prof)
    C.write_json("manifest.json", manifest)
    C.write_json("register_emit.json", reg.items)
    n = sum(len(fs) for _r, _d, fs in os.walk(C.MODELS) for _ in [0]) if False else None
    print("  emitted: %d staging, %d views, %d stages, %d hubs, %d links, %d satellites" % (
        len(manifest["staging"]), len(manifest["views"]), len(manifest["stages"]),
        sum(1 for x in manifest["vault"].values() if x["macro"] == "hub"),
        sum(1 for x in manifest["vault"].values() if x["macro"] == "link"),
        sum(1 for x in manifest["vault"].values() if x["macro"] in ("sat", "ma_sat"))))


_LINK_HUBS = {}


def specs_link_hubs(lnk):
    if not _LINK_HUBS:
        for l in C.model()["links"]:
            _LINK_HUBS[l["code"]] = l["hubs"]
    return _LINK_HUBS[lnk]


def write_project_files(prof):
    name = prof["dbt_project_name"]
    C.write_text(os.path.join(C.PROJECT, "dbt_project.yml"), """name: '%s'
version: '1.0.0'
config-version: 2

profile: '%s'

model-paths: ["models"]
macro-paths: ["macros"]

clean-targets:
  - "target"
  - "dbt_packages"

vars:
  health_raw_database: RAW
  health_raw_schema: HEALTH

models:
  %s:
    staging:
      health:
        +materialized: view
        +schema: stg_health
    automate_dv:
      standard:
        +schema: std_automate_dv_health
        stitched:
          +materialized: view
        staging:
          +materialized: view
        hubs:
          +materialized: incremental
        links:
          +materialized: incremental
        satellites:
          +materialized: incremental
        references:
          +materialized: view
      augmented:
        +schema: aug_automate_dv_health
        staging:
          +materialized: view
        satellites:
          +materialized: incremental""" % (name, name, name))
    pk = prof["macro_library"]["packages"]
    C.write_text(os.path.join(C.PROJECT, "packages.yml"), "packages:\n" + "\n".join(
        "  - package: %s\n    version: [%s]" % (p["package"], ", ".join('"%s"' % x for x in p["version"]))
        for p in pk))


if __name__ == "__main__":
    main()
