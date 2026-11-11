# -*- coding: utf-8 -*-
"""Write every model, in partner_dv_dbt / travel_dv_dbt's layout, from feeds.json + stitch_plan.json.

  models/staging/maximus_health/stg_mxh__<table>      1:1 casts: every feeding, walk and descend table
  models/automate_dv/standard/stitched/stitch_<v>     THE CENTRAL VIEWS. Spine walks are joins, so they
                                                      live here: each branch reads its table as t0 and
                                                      LEFT JOINs up (and across) the shred graph to
                                                      resolve its keys. Plain SQL, no hashing.
  models/automate_dv/standard/staging/stg2_<v>        automate_dv.stage(): every hub + link key on the view
  models/automate_dv/standard/staging/stg2_<sat>      automate_dv.stage(): one satellite, read off its view
  models/automate_dv/standard/{hubs,links,satellites} hub() / link() / sat() / ma_sat()
  models/automate_dv/augmented/{staging,satellites}   the augmentation track, same mechanics

Inside a view every satellite attribute is merged across the view's feeding tables on that
satellite's own key with FIRST_VALUE ... IGNORE NULLS (a keyed join that cannot fan out), and each
link pair comes from one source row that carries both legs. One stage per satellite because
automate_dv.sat() takes no filter: that stage NULLs the key wherever the satellite has no payload.
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mxh4_common as C  # noqa: E402
import mxh4_spine as S  # noqa: E402

LDTS = "'!CURRENT_TIMESTAMP()'"
ROLE_LINK = "LNK_PARTY_ROLE"


def q1(s):
    return "'" + s.replace("'", "''") + "'"


def q2(s):
    if '"' in s or "\\" in s:
        raise AssertionError("expression cannot be carried in YAML: %r" % s)
    return '"' + s + '"'


def jinja_safe(s):
    for tok in ("{{", "}}", "{%", "%}", "{#", "#}"):
        if tok in s:
            raise AssertionError("jinja delimiter in generated YAML: %r" % s[:200])


def ck_col(leg):
    return C.upper_snake(leg) + "_CK"


def view_col(sat, name):
    return C.short(sat) + "__" + name


def link_flag(lnk):
    return "__LNK_" + C.short(lnk)


def link_nk(lnk, hubs, cond):
    return "case when %s then '%s|' || %s end" % (cond, lnk, " || '|' || ".join(C.bk_col(h) for h in sorted(hubs)))


STAGE_TAIL = """{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}"""


def stage_model(header, source, hashed, derived):
    body = ["source_model: %s" % q1(source), "hashed_columns:"]
    for col, v in hashed:
        if isinstance(v, dict):
            body += ["  %s:" % col, "    is_hashdiff: true", "    columns:"]
            body += ["      - %s" % q1(c) for c in v["hashdiff"]]
        else:
            body.append("  %s: %s" % (col, q1(v)))
    body.append("derived_columns:")
    body += ["  %s: %s" % (k, v) for k, v in derived]
    jinja_safe("\n".join(body))
    return "\n".join([header, "{{ config(materialized='view') }}", "", "{%- set yaml_metadata -%}"]
                     + body + [STAGE_TAIL])


def vault_model(header, macro, meta, args):
    lines = [header, "{{ config(materialized='incremental') }}", "", "{%- set yaml_metadata -%}"]
    for k, v in meta:
        if isinstance(v, list):
            lines.append("%s:" % k)
            lines += ["  - %s" % q1(x) for x in v]
        else:
            lines.append("%s: %s" % (k, q1(v)))
    lines += ["{%- endset -%}", "", "{% set metadata_dict = fromyaml(yaml_metadata) %}", ""]
    pad = " " * len("{{ automate_dv.%s(" % macro)
    call = (",\n" + pad).join("%s=metadata_dict['%s']" % (a, a) for a in args)
    lines.append("{{ automate_dv.%s(%s) }}" % (macro, call))
    return "\n".join(lines)


def bkkey(leg):
    return (leg["expr"], leg["verdict"], leg["dv"])


def main():
    prof = C.profile()
    policy = prof["normalise_policy"]
    F = C.read_json("feeds.json")
    P = C.read_json("stitch_plan.json")
    specs = F["sat_specs"]
    T = C.tables()
    d7links = {l["code"]: l["hubs"] for l in C.model()["links"]}
    feeds_by = collections.defaultdict(list)
    for f in F["feeds"]:
        feeds_by[(f["sat"], f["table"])].append(f)
    reg = C.Register()
    C.wipe_models()
    manifest = {"views": {}, "stages": {}, "vault": {}, "staging": {}}
    staged = set()
    hub_sources, link_sources, link_fks = (collections.defaultdict(list), collections.defaultdict(list), {})

    for v in P["views"]:
        vname, smodel, gmodel = v["name"], v["stitch_model"], v["stage_model"]
        sats_here = v["satellites"]
        pairs_by_table = collections.defaultdict(list)
        for c in v["link_pairs"]:
            pairs_by_table[c["table"]].append(c)
        branches = []
        for ti, t in enumerate(v["tables"]):
            groups = collections.OrderedDict()
            for s in sats_here:
                for f in feeds_by.get((s, t), []):
                    bk = tuple(sorted((C.bk_col(h), bkkey(l)) for h, l in f["legs"].items()))
                    lits = tuple(sorted((s, leg, x["value"]) for leg, x in f["cdk"].items()
                                        if x and x["backing"] == "literal"))
                    ccdk = tuple(sorted((s, leg, x["value"], x["backing"]) for leg, x in f["cdk"].items()
                                        if x and x["backing"] != "literal"))
                    groups.setdefault((bk, lits, ccdk), []).append(f)
            mine = []
            for (bk, lits, ccdk), fs in groups.items():
                cmap = {(s, l): (x, b) for s, l, x, b in ccdk}
                if not lits:
                    for b in mine:
                        if (not b["lits"] and all(b["bk"].get(k, e) == e for k, e in bk)
                                and all(b["ccdk"].get(k2, x) == x for k2, x in cmap.items())):
                            b["bk"].update(dict(bk))
                            b["ccdk"].update(cmap)
                            b["feeds"].extend(fs)
                            break
                    else:
                        mine.append({"bk": dict(bk), "lits": lits, "ccdk": cmap, "feeds": list(fs), "flags": set()})
                else:
                    mine.append({"bk": dict(bk), "lits": lits, "ccdk": cmap, "feeds": list(fs), "flags": set()})
            for c in pairs_by_table.get(t, []):
                want = {C.bk_col(h): bkkey(l) for h, l in c["legs"].items()}
                for b in mine:
                    if not b["lits"] and all(b["bk"].get(k, e) == e for k, e in want.items()):
                        b["bk"].update(want)
                        b["flags"].add(c["link"])
                        break
                else:
                    mine.append({"bk": want, "lits": (), "ccdk": {}, "feeds": [], "flags": {c["link"]}})
            for b in mine:
                for f in b["feeds"]:
                    if specs[f["sat"]]["kind"] == "link":
                        b["flags"].add(specs[f["sat"]]["parent"])
                b["table"], b["prec"] = t, ti
            branches.extend(mine)

        bk_cols = sorted({k for b in branches for k in b["bk"]})
        has_role = any(specs[s]["kind"] == "role" for s in sats_here)
        links_here = sorted({l for b in branches for l in b["flags"]})
        flag_cols = [link_flag(l) for l in links_here]
        sat_cols = collections.OrderedDict()
        for s in sats_here:
            sp = specs[s]
            cks = [view_col(s, ck_col(l)) for l in sp["cdk_legs"]]
            pays = sorted({f["payload"] for tt in v["tables"] for f in feeds_by.get((s, tt), [])})
            sat_cols[s] = {"cdk": cks, "payload": [view_col(s, p) for p in pays], "payload_names": pays,
                           "cdk_names": [ck_col(l) for l in sp["cdk_legs"]],
                           "part": [C.bk_col(h) for h in sp["pk_hubs"]] + cks}
        all_cols = bk_cols + (["ROLE_TYPE_CODE"] if has_role else []) + flag_cols
        for s, sc in sat_cols.items():
            all_cols += sc["cdk"] + sc["payload"]
        if len(set(all_cols)) != len(all_cols):
            raise AssertionError("view column names collide in %s" % vname)

        selects, walk_tables = [], set()
        for bi, b in enumerate(branches):
            rd = S.Renderer(b["table"], policy)
            ex = {}
            for k, (e, verdict, dv) in b["bk"].items():
                ex[k] = S.bk_sql(rd.render(e), verdict, dv)
            for l in b["flags"]:
                ex[link_flag(l)] = "1"
            per = collections.defaultdict(list)
            for f in sorted(b["feeds"], key=lambda x: (x["sat"], x["payload"], x["column"])):
                per[view_col(f["sat"], f["payload"])].append(rd.column(f["column"]))
                for leg, x in f["cdk"].items():
                    if not x:
                        continue
                    colname = view_col(f["sat"], ck_col(leg))
                    rendered = S.render_ck_value(x["value"], x["backing"], rd, f["key_text"])
                    ex.setdefault(colname, rendered)
                    if specs[f["sat"]]["kind"] == "role":
                        ex["ROLE_TYPE_CODE"] = S.sql_lit(x["value"])
            for colname, srcs in per.items():
                srcs = sorted(set(srcs))
                ex[colname] = srcs[0] if len(srcs) == 1 else "coalesce(%s)" % ", ".join(srcs)
            # In a UNION ALL the first select names and types every column; later selects match
            # by POSITION. So branch 0 writes every column typed and aliased, and later branches
            # write a bare `null` for each column they do not carry, runs of them on one line.
            # Null-padding every branch in full put a central view at 3.9 MB, past Snowflake's
            # 1 MB statement limit; this keeps the same columns at a fraction of the size.
            sel, run = [], []
            for c in all_cols:
                if c in ex:
                    if run:
                        sel.append("        " + ", ".join(run))
                        run = []
                    sel.append("        %s as %s" % (ex[c], c))
                elif bi == 0:
                    sel.append("        cast(null as %s) as %s" % ("number" if c.startswith("__LNK_")
                                                                   else "varchar", c))
                else:
                    run.append("null")
                    if len(run) == 24:
                        sel.append("        " + ", ".join(run))
                        run = []
            if run:
                sel.append("        " + ", ".join(run))
            sel += ["        %d as __PREC" % b["prec"], "        hash(t0.*) as __RID"]
            keyed = sorted(ex[k] for k in b["bk"])
            cond = keyed[0] if len(keyed) == 1 else "coalesce(%s)" % ", ".join(keyed)
            joins = [j for _a, j in rd.joins.values()]
            staged |= rd.tables
            walk_tables |= rd.walk_tables
            lit_note = (" | child-key literal(s): %s" % ", ".join("%s.%s=%s" % (C.short(s), l, x)
                                                                for s, l, x in b["lits"])) if b["lits"] else ""
            selects.append("    -- branch %d: %s%s\n    select\n%s\n    from {{ ref('%s') }} t0%s\n    where (%s) is not null"
                           % (bi, b["table"], lit_note, ",\n".join(sel), C.staging_model(b["table"]),
                              "".join("\n    " + j for j in joins), cond))
        final = ["    %s" % c for c in bk_cols + (["ROLE_TYPE_CODE"] if has_role else []) + flag_cols]
        for s, sc in sat_cols.items():
            final += ["    %s" % c for c in sc["cdk"]]
            part = ", ".join(sc["part"])
            final += ["    first_value(%s) ignore nulls over (partition by %s order by __PREC, __RID rows "
                      "between unbounded preceding and unbounded following) as %s" % (c, part, c)
                      for c in sc["payload"]]
        wt = sorted(walk_tables - set(v["tables"]))
        header = ["-- CENTRAL VIEW %s -- the layer the governing central-view rule is about." % vname,
                  "-- Feeding tables (rule 1 counts these):"] + ["--   %s" % t for t in v["tables"]] + \
                 ["-- Walk tables, joined only to resolve spine keys (not counted):"] + \
                 ["--   %s" % t for t in wt] + \
                 ["-- Satellites fed WHOLE from this view (rule 2):"] + ["--   %s" % s for s in sats_here] + \
                 ["-- Links whose legs come from one source row on this view (rule 6):"] + \
                 ["--   %s" % l for l in links_here] + \
                 (["-- OVER the table limit by rule 3: one satellite on this view needs every feeding table."]
                  if v["over_limit"] else []) + \
                 ["-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream."]
        sql = "\n".join(header) + "\n{{ config(materialized='view') }}\n\nwith merged as (\n\n" + \
              "\n\n    union all\n\n".join(selects) + "\n\n)\n\nselect\n" + ",\n".join(final) + "\nfrom merged"
        C.write_model("stitched", smodel, sql)
        manifest["views"][smodel] = {"columns": all_cols, "tables": v["tables"], "walk_tables": wt,
                                     "branches": len(branches)}

        hashed, derived = [], []
        for hs in sorted({c[:-3] for c in bk_cols}):
            hashed.append((hs + "_HKEY", hs + "_NK"))
            derived += [(hs + "_BK", q1(hs + "_BK")), (hs + "_NK", q2("'HUB_%s|' || %s_BK" % (hs, hs)))]
            hub_sources["HUB_" + hs].append(gmodel)
        for l in links_here:
            ls = C.short(l)
            hashed.append((ls + "_HKEY", ls + "_NK"))
            derived.append((ls + "_NK", q2(link_nk(l, d7links[l], "%s = 1" % link_flag(l)))))
            link_sources[l].append(gmodel)
            link_fks[l] = [C.short(h) + "_HKEY" for h in sorted(d7links[l])]
        if has_role:
            hashed.append(("PARTY_ROLE_HKEY", "PARTY_ROLE_NK"))
            derived.append(("PARTY_ROLE_NK", q2("case when ROLE_TYPE_CODE is not null then '%s|' || "
                                               "PARTY_BK || '|' || ROLE_TYPE_CODE end" % ROLE_LINK)))
            link_sources[ROLE_LINK].append(gmodel)
            link_fks[ROLE_LINK] = ["PARTY_HKEY"]
        derived += [("LOAD_DATETIME", LDTS), ("RECORD_SOURCE", q1("!" + smodel))]
        C.write_model("std_staging", gmodel, stage_model(
            "-- automate_dv.stage() over central view %s: every hub key and link key the view\n"
            "-- carries. Hubs and links read THIS model -- they come from the view (rules 5, 6)." % smodel,
            smodel, hashed, derived))
        manifest["stages"][gmodel] = {"source": smodel}

        for s in sats_here:
            sp, sc = specs[s], sat_cols[s]
            aug = bool(sp.get("augmented"))
            sname = "stg2_" + C.short(s).lower()
            present = ("coalesce(%s) is not null" % ", ".join(sc["payload"])) if len(sc["payload"]) > 1 \
                else "%s is not null" % sc["payload"][0]
            pk = sp["pk_col"]
            nk = pk[:-len("_HKEY")] + "_NK"
            nk_expr = link_nk(sp["parent"], sp["pk_hubs"], present) if sp["kind"] == "link" else \
                "case when %s then '%s|' || %s end" % (present, sp["pk_hubs"][0], C.bk_col(sp["pk_hubs"][0]))
            hd = sc["payload_names"] + (sc["cdk_names"] if sp["ma"] else [])
            derived = [(nk, q2(nk_expr))] + [(n, q1(c)) for n, c in zip(sc["cdk_names"], sc["cdk"])] + \
                      [(n, q1(c)) for n, c in zip(sc["payload_names"], sc["payload"])] + \
                      [("LOAD_DATETIME", LDTS), ("RECORD_SOURCE", q1("!" + smodel))]
            C.write_model("aug_staging" if aug else "std_staging", sname, stage_model(
                "-- automate_dv.stage() for %s, read off central view %s.\n-- The key is NULL wherever "
                "this satellite has no payload: sat() takes no filter, and it skips a NULL key."
                % (s, smodel), smodel, [(pk, nk), ("HASHDIFF", {"hashdiff": hd})], derived))
            manifest["stages"][sname] = {"source": smodel}
            meta = [("source_model", sname), ("src_pk", pk)] + ([("src_cdk", sc["cdk_names"])] if sp["ma"] else []) + \
                   [("src_payload", sc["payload_names"]), ("src_hashdiff", "HASHDIFF"),
                    ("src_ldts", "LOAD_DATETIME"), ("src_source", "RECORD_SOURCE")]
            macro = "ma_sat" if sp["ma"] else "sat"
            args = ["src_pk"] + (["src_cdk"] if sp["ma"] else []) + \
                   ["src_payload", "src_hashdiff", "src_ldts", "src_source", "source_model"]
            mname = "sat_" + C.short(s).lower()
            C.write_model("aug_satellites" if aug else "satellites", mname, vault_model(
                "-- %s %s() for %s (parent %s, history %s), fed whole from central view %s." % (
                    "AUGMENTED track (not mapper-ratified)" if aug else "Standard", macro, s, sp["parent"],
                    sp["hist"], smodel), macro, meta, args))
            manifest["vault"][mname] = {"macro": macro, "sources": [sname]}

    for hub, srcs in sorted(hub_sources.items()):
        hs = C.short(hub)
        C.write_model("hubs", "hub_" + hs.lower(), vault_model(
            "-- hub() for %s, unioned over every central view that carries its key." % hub, "hub",
            [("source_model", sorted(srcs)), ("src_pk", hs + "_HKEY"), ("src_nk", hs + "_BK"),
             ("src_ldts", "LOAD_DATETIME"), ("src_source", "RECORD_SOURCE")],
            ["src_pk", "src_nk", "src_ldts", "src_source", "source_model"]))
        manifest["vault"]["hub_" + hs.lower()] = {"macro": "hub", "sources": sorted(srcs)}
    for l, srcs in sorted(link_sources.items()):
        ls = C.short(l)
        C.write_model("links", "lnk_" + ls.lower(), vault_model(
            "-- link() for %s. Every row's legs come from one source row on one central view." % l, "link",
            [("source_model", sorted(srcs)), ("src_pk", ls + "_HKEY"), ("src_fk", link_fks[l]),
             ("src_ldts", "LOAD_DATETIME"), ("src_source", "RECORD_SOURCE")],
            ["src_pk", "src_fk", "src_ldts", "src_source", "source_model"]))
        manifest["vault"]["lnk_" + ls.lower()] = {"macro": "link", "sources": sorted(srcs)}

    # ---- staging (layer 1): every table any branch reads, feeding or walk
    C.assert_slugs_injective(staged)
    filters = prof.get("row_filters", {})
    for t in sorted(staged):
        cols = []
        for c in T[t]["columns"]:
            if re.match(r"^[A-Za-z0-9_]+$", c):
                cols.append(c)
            else:
                reg.refuse("source_column_name_not_an_identifier", "%s.%s" % (t, c),
                           "cannot be aliased safely in staging; not carried", "source owner")
        body = ",\n".join("        nullif(trim(to_varchar(\"%s\")), '') as %s" % (c, C.source_alias(c))
                          for c in cols)
        where = ("\n    where %s" % filters[t]) if t in filters else ""
        C.write_model("staging", C.staging_model(t), (
            "-- Staging for source view %s. Every column trimmed varchar, including the shred keys\n"
            "-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.\n"
            "with source as (\n\n    select\n%s\n    from {{ source('maximus_raw', '%s') }}%s\n\n)\n\n"
            "select * from source") % (t, body, t, where))
        manifest["staging"][C.staging_model(t)] = t
    src = ["version: 2", "", "sources:", "  - name: maximus_raw", "    description: >",
           "      Maximus Health shredded EAV views (UWR and CLM) landed in Snowflake as-is.",
           "      Database/schema are vars -- point them at where ingestion lands them.",
           "    database: \"{{ var('maximus_raw_database', 'RAW') }}\"",
           "    schema: \"{{ var('maximus_raw_schema', 'MAXIMUS_HEALTH') }}\"", "    tables:"]
    src += ["      - name: %s" % t for t in sorted(staged)]
    C.write_text(os.path.join(C.DIRS["staging"], "_maximus_health__sources.yml"), "\n".join(src))

    os.makedirs(C.DIRS["references"], exist_ok=True)
    write_project_files(prof)
    C.write_json("manifest.json", manifest)
    C.write_json("register_emit.json", reg.items)
    print("  emitted: %d staging, %d views, %d stages, %d hubs, %d links, %d satellites" % (
        len(manifest["staging"]), len(manifest["views"]), len(manifest["stages"]),
        sum(1 for x in manifest["vault"].values() if x["macro"] == "hub"),
        sum(1 for x in manifest["vault"].values() if x["macro"] == "link"),
        sum(1 for x in manifest["vault"].values() if x["macro"] in ("sat", "ma_sat"))))


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
  maximus_raw_database: RAW
  maximus_raw_schema: MAXIMUS_HEALTH

models:
  %s:
    staging:
      maximus_health:
        +materialized: view
        +schema: stg_maximus_health
    automate_dv:
      standard:
        +schema: std_automate_dv_maximus_health
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
        +schema: aug_automate_dv_maximus_health
        staging:
          +materialized: view
        satellites:
          +materialized: incremental""" % (name, name, name))
    C.write_text(os.path.join(C.PROJECT, "packages.yml"), "packages:\n" + "\n".join(
        "  - package: %s\n    version: [%s]" % (p["package"], ", ".join('"%s"' % x for x in p["version"]))
        for p in prof["macro_library"]["packages"]))


if __name__ == "__main__":
    main()
