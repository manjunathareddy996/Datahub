#!/usr/bin/env sh
# The documented run order for Maximus Travel V2. Anything that changes it changes
# generators/README.md too, which is GENERATED from this file's companion module.
#
# The ordering is not cosmetic:
#   * build_mtv2_spec must run first -- every downstream generator reads the SPEC, never the map;
#   * gen_mtv2_vault WIPES hubfeed/ hubs/ links/ satfeed/ satellites/ audit/ before writing, so it
#     must run AFTER the stage and unpivot layers (BUILD_RULES 6.3);
#   * gen_mtv2_augmented WIPES models/automate_dv/augmented, so gen_mtv2_align -- the declared
#     bespoke shim that writes the OPUS-named SAT_AUG_* -- must run AFTER it. Running the shim
#     first writes the models and then has them deleted, leaving a build that reports satellites
#     it does not have;
#   * EVERY layer directory is wiped by its FIRST writer, so a re-run cannot inherit a model
#     nobody generates any more. Two directories have two writers: the cast layer is wiped by
#     gen_mtv2_staging (not hopviews) and the stage layer by gen_mtv2_unpivot (not stage).
#     Moving either generator earlier deletes the other's output;
#   * gen_mtv2_exemptions reads the SPEC's coverage census and must run before selfcheck, which
#     asserts that vault_tools/accepted_uncovered.txt carries exactly the lines it generated;
#   * selfcheck runs before the README and the report so a failure stops the run rather than being
#     written up as a success.
#
# NOT IN THE CHAIN, run on demand, each writing its own artifact:
#   python3 probe_mtv2_keynorm.py            -> build_artifacts/keynorm_probe.json
#       proves superseded key history cannot reach a model: it rebuilds the whole spec from a
#       scratch map whose 1444 archived previous_expression values are poisoned. Too slow for
#       every build; its cheap half runs in selfcheck_mtv2.py every time.
#   python3 verify_mtv2_gates.py             -> build_artifacts/gate_verification.json
#       runs all five shared gates DIRECTLY -- each verdict is that gate's own exit status, never
#       a pipe's -- and proves each one can FAIL by injection, restoring the tree via the chain
#       and asserting the BINARY tree digest afterwards. Not in the chain: it rebuilds the tree
#       several times and must not run inside the build it verifies.
#   python3 prove_mtv2_reproducibility.py    -> build_artifacts/reproducibility.json
#       the deletion proof. It DELETES this chain's outputs and runs the chain twice, so it is
#       never part of the chain itself.
set -e
cd "$(dirname "$0")"

python3 mtv2_names.py
python3 mtv2_keyrules.py
python3 gen_mtv2_project.py
python3 build_mtv2_spec.py
python3 gen_mtv2_staging.py
python3 gen_mtv2_hopviews.py
python3 gen_mtv2_resolvers.py
python3 gen_mtv2_unpivot.py
python3 gen_mtv2_stage.py
python3 gen_mtv2_vault.py
python3 gen_mtv2_augmented.py
python3 gen_mtv2_align.py
python3 gen_mtv2_exemptions.py
python3 selfcheck_mtv2.py
python3 gen_mtv2_readme.py
python3 report_mtv2_stage1.py
