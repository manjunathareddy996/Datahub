# -*- coding: utf-8 -*-
"""gen_mt_project.py -- dbt_project.yml and packages.yml, generated.

They are generated rather than hand-written for the same reason the models are: the schema block
must list every layer directory the generators actually write, and a hand-maintained copy goes
stale the first time a layer is added. The layer list comes from mt_names.LAYER_DIRS, so it
cannot disagree with where the models land.
"""
import os
import sys

import mt_names as N

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

INCREMENTAL = {"hubs", "links", "satellites"}


def project_yml():
    rel = {}
    for key, path in N.LAYER_DIRS.items():
        rel[key] = os.path.relpath(path, N.MODELS).replace("\\", "/")
    std = sorted({rel[k].split("/")[-1] for k in
                  ("resolver", "unpivot", "stage", "hubfeed", "hub", "link", "satfeed",
                   "satellite", "audit")})
    aug = sorted({rel[k].split("/")[-1] for k in ("aug_stage", "aug_satfeed", "aug_sat")})
    out = [
        "name: 'maximus_travel_dv'",
        "version: '1.0.0'",
        "config-version: 2",
        "",
        "profile: 'maximus_travel_dv'",
        "",
        'model-paths: ["models"]',
        'macro-paths: ["macros"]',
        'test-paths: ["tests"]',
        "",
        "clean-targets:",
        '  - "target"',
        '  - "dbt_packages"',
        "",
        "vars:",
        "  mt_raw_database: RAW",
        "  mt_raw_schema: MAXIMUS_TRAVEL",
        "",
        "# SHARED VAULT TABLES",
        "# -------------------",
        "# This project is Maximus Travel. The OPUS build travel_dv_dbt writes the SAME physical",
        "# hub / link / satellite tables. Hubs, links and satellites are incremental, so each",
        "# project appends only its own rows and they stay distinguishable by hub key and",
        "# RECORD_SOURCE.",
        "#",
        "# maximus_travel_dv_dbt is SUPERSEDED. Its mapping is ignored entirely and the generators",
        "# refuse to read it (mt_names.READ_NEVER).",
        "#",
        "# The staging schema is this project's own: the intermediate views carry the mt infix so",
        "# they cannot materialise over the sibling's views of the same source.",
        "#",
        "# on_schema_change: append_new_columns is REQUIRED, not cosmetic -- this build declares",
        "# payload columns the sibling does not, and dbt's default ('ignore') would silently drop",
        "# them on insert. That is a dead data path created by configuration.",
        "#",
        "# NEVER run --full-refresh against a shared vault table from either project: it rebuilds",
        "# from that project's sources only and discards the other's rows.",
        "",
        "models:",
        "  maximus_travel_dv:",
        "    staging:",
        "      %s:" % rel["cast"].split("/")[-1],
        "        +materialized: view",
        "        +schema: stg_maximus_travel",
        "    automate_dv:",
        "      standard:",
        "        +schema: std_automate_dv          # shared with travel_dv_dbt",
    ]
    for d in std:
        out.append("        %s:" % d)
        if d in INCREMENTAL:
            out.append("          +materialized: incremental")
            out.append("          +on_schema_change: append_new_columns")
        else:
            out.append("          +materialized: view")
    out.append("      augmented:")
    out.append("        +schema: aug_automate_dv          # shared with travel_dv_dbt")
    for d in aug:
        out.append("        %s:" % d)
        if d == "satellites":
            out.append("          +materialized: incremental")
            out.append("          +on_schema_change: append_new_columns")
        else:
            out.append("          +materialized: view")
    return "\n".join(out)


PACKAGES = """\
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.1.0", "<2.0.0"]
  - package: Datavault-UK/automate_dv
    version: [">=0.11.0", "<0.12.0"]
"""


def main():
    p1 = os.path.join(N.PROJECT, "dbt_project.yml")
    p2 = os.path.join(N.PROJECT, "packages.yml")
    N.write_model(p1, project_yml())
    N.write_model(p2, PACKAGES)
    print("gen_mt_project -> %s, %s" % (os.path.basename(p1), os.path.basename(p2)))
    print("  the schema block is derived from mt_names.LAYER_DIRS, so it cannot disagree with")
    print("  where the generators actually write.")


if __name__ == "__main__":
    main()
