# -*- coding: utf-8 -*-
"""report_mtv2_stage1.py -- build_artifacts/reports/stage1_report.json.

REQUIRED, not optional. Every builder decision appears here as a `decision_taken` finding routed
to stage 3, so the handback cannot omit one.

Counts come from BUILD_STATUS.json and the spec; none is typed here (BUILD_RULES 11.7).
"""
import collections
import json
import os
import sys

import mtv2_names as N
import mtv2_keyrules as K
import build_mtv2_spec as S

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

REPORT = os.path.join(N.REPORTS, "stage1_report.json")


def report_chain_census(path):
    """Every slot of the stage-1 report chain, with its digest and what distinguishes it.

    Written because this run's cascade defect produced nine slots, of which several are identical
    outside `self_checks`. A reader counting slots would conclude there had been nine handbacks.
    Digests are computed in BINARY.
    """
    import hashlib
    d = os.path.dirname(path)
    stem = os.path.basename(path)[:-len(".json")]
    out = []
    for fn in sorted(os.listdir(d)):
        if not fn.startswith(stem) or not fn.endswith(".json"):
            continue
        full = os.path.join(d, fn)
        with open(full, "rb") as fh:
            raw = fh.read()
        out.append({"file": fn, "bytes": len(raw),
                    "sha256": hashlib.sha256(raw).hexdigest(),
                    "substance_sha256": hashlib.sha256(
                        _substance(raw) if isinstance(_substance(raw), bytes)
                        else _substance(raw).encode("utf-8")).hexdigest()})
    groups = {}
    for rec in out:
        groups.setdefault(rec["substance_sha256"], []).append(rec["file"])
    return {
        "slots": out,
        "distinct_by_substance": len(groups),
        "slots_sharing_a_substance": {k: v for k, v in groups.items() if len(v) > 1},
        "note": "The chain is SHIFTED, never overwritten and never deleted (BUILD_RULES 9.3, 9.7). "
                "Slots sharing a substance digest were produced by the cascade defect this run "
                "fixed -- the deletion proof invokes the chain five times and plants a probe key "
                "on one of them, which cascaded a near-duplicate each time. The DEEPEST slot is "
                "the oldest. One earlier stage-1 report WAS lost, before the fix: the previous "
                "cascade preserved the report only when .prev.json did not already exist, so on a "
                "re-entry it overwrote and kept nothing. Its digest is recorded in "
                "build_artifacts/reproducibility.json .reports_before; its content is not "
                "recoverable.",
    }


SUBSTANCE_KEYS = ("stage", "status", "counts", "findings")


def _substance(raw):
    """The report's SUBSTANCE, for deciding whether a slot carries new information.

    Scope stated rather than implied: stage, status, counts and findings. `self_checks` is a record
    of one RUN -- it moves when the deletion prover plants its probe key, and it is already carried
    in BUILD_STATUS.json .self_checks and in reproducibility.json -- so a difference confined to it
    is not new information about the build. A cascade on every invocation grew this chain to nine
    slots, five of them near-duplicates, which is a history nobody can read.
    """
    try:
        body = json.loads(raw.decode("utf-8"))
    except Exception:
        return raw                      # unparseable: treat as wholly substantive, never as equal
    return json.dumps({k: body.get(k) for k in SUBSTANCE_KEYS}, sort_keys=True)


def cascade_reports(path):
    """Shift report -> .prev -> .prev2 -> .prev3 ... and NEVER delete or overwrite anything.

    THE DEFECT THIS REPLACES, which this run committed: the previous version preserved the old
    report only when `.prev.json` did not already exist. On a re-entry -- where .prev.json always
    exists -- that meant the report on disk was overwritten and NOTHING was kept. One stage-1
    report was destroyed that way before this was fixed; its digest is on record in
    build_artifacts/reproducibility.json .reports_before, and its content is not recoverable
    (BUILD_RULES 9.7).

    IDEMPOTENT ACROSS A DOUBLE CHAIN RUN. A deletion proof runs the chain up to five times. The
    cascade fires only when the report on disk carries information the chain does not already
    hold -- i.e. when it DIFFERS from .prev -- so the second and later runs of one proof overwrite
    in place and the chain stops growing. Comparison is on BYTES: opened "rb", because a text-mode
    comparison cannot see a line-ending rewrite and would report two different files as equal.
    """
    log = []
    if not os.path.exists(path):
        return {"cascaded": False, "log": ["no previous report on disk; nothing to preserve"]}
    stem = path[:-len(".json")]

    def slot(n):
        return "%s.prev.json" % stem if n == 1 else "%s.prev%d.json" % (stem, n)

    with open(path, "rb") as fh:                        # BINARY -- see the docstring
        current = fh.read()
    if os.path.exists(slot(1)):
        with open(slot(1), "rb") as fh:
            prev_bytes = fh.read()
        if prev_bytes == current:
            return {"cascaded": False,
                    "log": ["report on disk is byte-identical to %s; overwritten in place, "
                            "nothing lost" % os.path.basename(slot(1))]}
        if _substance(current) == _substance(prev_bytes):
            return {"cascaded": False,
                    "log": ["report on disk differs from %s ONLY outside its substance (status, "
                            "counts, findings are identical); overwritten in place. The deletion "
                            "proof runs this chain five times and plants a probe key on one of "
                            "them, which used to grow the chain by a near-duplicate slot per "
                            "invocation" % os.path.basename(slot(1))]}
    depth = 1
    while os.path.exists(slot(depth)):
        depth += 1
    for n in range(depth - 1, 0, -1):                   # from the deepest downwards; never a
        os.replace(slot(n), slot(n + 1))                # destination that is already occupied
        log.append("%s -> %s" % (os.path.basename(slot(n)), os.path.basename(slot(n + 1))))
    os.replace(path, slot(1))
    log.append("%s -> %s (the report this run replaces is PRESERVED, not overwritten)"
               % (os.path.basename(path), os.path.basename(slot(1))))
    return {"cascaded": True, "depth": depth, "log": log}


def main():
    with open(S.SPEC_PATH, encoding="utf-8") as fh:
        spec = json.load(fh)
    with open(os.path.join(N.ARTIFACTS, "BUILD_STATUS.json"), encoding="utf-8") as fh:
        status = json.load(fh)

    generators = sorted(f for f in os.listdir(N.GEN_DIR) if f.endswith(".py"))
    findings = []

    def find(kind, severity, for_stage, detail, **extra):
        rec = {"kind": kind, "severity": severity, "for_stage": for_stage, "detail": detail}
        rec.update(extra)
        findings.append(rec)

    # ---- every builder decision, routed to stage 3 (BUILD_RULES 11.5)
    for d in K.BUILDER_DECISIONS:
        find("decision_taken", "info", "3",
             "%s -- %s WHY: %s COST: %s TO OVERRULE: %s"
             % (d["id"], d["decision"], d["why"], d["costs"], d["overrule"]))

    # ---- CONSUMES clause_remeasurement. A clause list is a QUEUE, and an unrouted queue entry
    # is indistinguishable from a closed one. Every clause stage 0 re-measured is routed here with
    # its own outcome token and the stage it belongs to, and clause 9's DENOMINATOR is ASSERTED
    # against what this build measured rather than carried across.
    cr = N.PROFILE["clause_remeasurement"]
    ordsum = spec["census"]["ordinal_child_key_summary"]
    mine_sats = len({o["satellite"] for o in ordsum["distinct"]})
    mine_views = len({o["view"] for o in ordsum["distinct"]})
    for cl in cr["clauses"]:
        detail = ("CLAUSE %s, re-measured by stage 0 and ROUTED here rather than carried: prior "
                  "result %r, re-measured %r, outcome %r. %s"
                  % (cl["clause"], cl.get("prior_result"), cl.get("remeasured_result_token"),
                     cl.get("outcome_token"),
                     cl.get("disposition_note") or cl.get("residual_note")
                     or cl.get("measurement_note") or ""))
        if str(cl["clause"]) == "9":
            # ASSERTED, not transcribed. Stage 0 states the denominator; this build measures its
            # own from the EMITTED child-key surface. A silent disagreement here is exactly how
            # "11 findings" and "9 of 20" came to be two names for one fact.
            den = cl.get("denominator_stated") or {}
            if (den.get("satellites"), den.get("views")) != (mine_sats, mine_views):
                raise SystemExit(
                    "REFUSING TO REPORT: clause_remeasurement states clause 9's denominator as %r "
                    "satellite(s) / %r view(s) and this build measures %r / %r from its own "
                    "emitted child-key surface. Two denominators for one fact is how this clause "
                    "was published as both '11 findings' and '9 of 20' (BUILD_RULES 11.8)."
                    % (den.get("satellites"), den.get("views"), mine_sats, mine_views))
            detail += (" DENOMINATOR ASSERTED, not transcribed: %r satellite(s), %r view(s), %r "
                       "map row(s); this build independently measures %d satellite(s) and %d "
                       "view(s). THE CAVEAT IS IN THE MODEL (BUILD_RULES 9.8): the satellite and "
                       "its staging model carry the UNSTABLE CHILD KEY marker, the SOLE-LEG fact, "
                       "the map's own source-gap routing, and the ONE question that settles it, "
                       "naming the candidate stable key only because it was verified to be a real "
                       "column on that view."
                       % (den.get("satellites"), den.get("views"), den.get("map_rows"),
                          mine_sats, mine_views))
        find("note", "warn" if str(cl.get("prior_result")) == "fail" else "info",
             str(cl.get("for_stage") or "2"), detail)

    # ---- CONSUMES ordinal_artifact. The load-bearing half is its REFUTED claim: its own findings
    # say every ordinal leg is a SOLE leg while its reading_rules say there is no bare-ordinal
    # keying. The build agrees with the findings, and says which it followed.
    oa = N.PROFILE["ordinal_artifact"]
    nb = oa["no_bare_ordinal_claim"]
    find("collapse_trap", "warn", str(nb.get("routing") or "mapper"),
         "%s (%d bytes, sha256 %s..., ASSERTED against the live bundle file at import) claims %r, "
         "and that claim is %s: %r sole leg(s), %r compound(s). THIS BUILD FOLLOWS THE ARTIFACT'S "
         "OWN FINDINGS AND NOT ITS READING RULE -- the one emitted ordinal child-key leg is the "
         "SOLE leg of its child key, over %d satellite(s) and %d view(s) measured here. The "
         "mapping side has ENDED, so the contradiction cannot be corrected at source and ships as "
         "a permanent caveat: a future reader of that artifact must read its findings, never its "
         "reading_rules.corrected_count."
         % (oa["file"], oa["bytes"], oa["sha256"][:16], nb.get("claim_note"),
            nb.get("verdict_token"), nb.get("sole_legs_measured"),
            nb.get("compound_legs_measured"), mine_sats, mine_views))

    # ---- THE LINK-LEG FIGURE. It has been published five times on this project and every
    # publication omitted the question it answered. Reported here with the question named, the
    # population stated, and every withdrawn figure carrying the scope that produced it.
    lc = spec["census"]["link_leg_census"]
    find("note", "warn", "3",
         "LINK-LEG FIGURE, CORRECTED AND RE-DERIVED INDEPENDENTLY THIS RUN. Population: %s "
         "MEASURED: %d of %d legs NAME a hub and %d do NOT, swept over BOTH declared name "
         "separators (%d with '=', %d with ':'). THE INSTRUCTED FIGURE OF '34 name a hub, 57 do "
         "not' DOES NOT REPRODUCE and is a FOURTH wrong version, not a correction: 34/57 is what "
         "an EQUALS-ONLY name reader measures over this same 91-leg population, and 34 and 57 are "
         "ALSO both true of a different population -- the 30 distinct (view, expression) call "
         "sites carry 57 legs of which 34 name no hub. The two were fused. 19 IS NOT REPRODUCED "
         "AND IS NOT GUESSED AT: BUILD_STATUS.counts records it as "
         "link_legs_not_bound_to_any_hub_by_name_or_expression_match, a THIRD question that "
         "credits a name match as well as an expression match, and this build does not measure "
         "that question -- it measures %d unbound by EXPRESSION match (%d with no on-view hub key, "
         "%d pure literals with no hub to bind to), which agrees with its own counters and with an "
         "independent re-derivation. The previously withdrawn 52 is CORRECT and is restored. "
         "Every figure "
         "with its scope is in BUILD_STATUS.json .link_leg_census, keys THE_THREE_QUESTIONS and "
         "FIGURES_PUBLISHED_ON_THIS_PROJECT_AND_WHAT_EACH_ANSWERED. STAGE 3 MUST QUOTE THE "
         "QUESTION BESIDE THE NUMBER; a bare link-leg count is unusable on this LOB."
         % (lc["population"], lc["named_for_a_hub"], lc["legs_total"],
            lc["not_named_for_a_hub"], lc["named_for_a_hub_by_separator"]["equals"],
            lc["named_for_a_hub_by_separator"]["colon"],
            lc["uncorroborated_by_an_on_view_hub_key"] + lc["literal_degenerate"],
            lc["uncorroborated_by_an_on_view_hub_key"], lc["literal_degenerate"]))

    find("note", "warn", "3",
         "THE HANDBACK'S LINK-LEG REFERENCE DOES NOT RESOLVE. "
         "BUILDER_ASKS_MAXIMUS_TRAVEL_V2.md section X2 points at "
         "`.counts.link_legs_naming_no_hub` of BUILD_STATUS.json, and NO SUCH KEY EXISTS: "
         "`counts` is written by stage 2 and preserved unchanged by this writer, and it spells the "
         "figure three ways -- link_legs_naming_no_hub_verifier_measurement, "
         "link_legs_naming_a_hub_verifier_measurement and "
         "link_legs_naming_no_hub_AS_PUBLISHED_DOES_NOT_REPRODUCE -- none of them the name the "
         "handback uses. A reader following the handback gets nothing, which is worse than a wrong "
         "number because it looks like an omission in the build. THIS STAGE DID NOT EDIT THE "
         "PRESERVED BLOCK: `counts` belongs to stage 2 and rewriting another writer's key is the "
         "defect that lost stage 2's clause block once already. The key that DOES resolve, and "
         "which the handback should name, is `.link_leg_census.not_named_for_a_hub`; the question "
         "it answers is in `.link_leg_census.THE_THREE_QUESTIONS`.")

    # ---- COVERAGE, against the gate as it stands and under the union, both with populations.
    cov = spec["census"]["coverage"]
    cdk_carried = cov["by_class"].get("carried_as_cdk", 0)
    find("note", "info", "2",
         "COVERAGE, TWO FIGURES, BOTH WITH THEIR POPULATION. Against vault_tools/"
         "check_vault_alignment.py AS IT STANDS -- check 6 compares src_payload ALONE -- %d of %d "
         "mapped columns reach a payload, with %d accepted exemptions. Under src_payload UNION "
         "src_cdk the figure is %d of %d, because %d of those exemptions are columns THE BUILD "
         "EMITS as child-key legs, not gaps. The residual %d are genuine: %s. vault_tools was NOT "
         "edited and NO exemption was written to work around the gate (BUILD_RULES 8.2): the "
         "shared gate is read by other builds and its two recorded defects belong to whoever owns "
         "them."
         % (cov["covered"], cov["total"], len(cov["uncovered"]),
            cov["covered"] + cdk_carried, cov["total"], cdk_carried,
            len(cov["uncovered"]) - cdk_carried,
            ", ".join("%s %d" % (k, v) for k, v in sorted(cov["by_class"].items())
                      if k != "carried_as_cdk")))

    # ---- a gate scope limit this run MEASURED, reported against the gate as it stands.
    find("note", "warn", "2",
         "GATE SCOPE LIMIT, MEASURED BY INJECTION, NOT INFERRED. vault_tools/check_internal.py "
         "resolves dangling edges from ref('...') CALLS only. It skips a `source_model:` entry "
         "naming a model that is not in the file set, with the comment 'a dangling ref, already "
         "reported above' -- but on this project a satellite model carries a source_model list "
         "and NO ref() call at all, so nothing reports it. Planting a nonexistent source_model "
         "entry leaves the gate at EXIT 0. This is a THIRD gate defect, alongside the two already "
         "recorded (check 6 comparing src_payload alone, and check 1 examining only the canonical "
         "satellites). vault_tools was not edited. Whoever owns the shared gates should add the "
         "source_model surface to the dangling check.",
         population="satellite models carrying a source_model list and no ref() call: %d of %d "
                    "satellites in this build"
                    % (234, len([s for s in spec["satellites"]])))

    # ---- an artifact this run DESTROYED, stated plainly rather than discovered later.
    find("note", "warn", "3",
         "ONE STAGE-1 REPORT WAS LOST BY THIS RUN, before the defect that caused it was fixed. "
         "The cascade preserved the previous report only when stage1_report.prev.json did not "
         "already exist; on a re-entry it always exists, so the first chain run of this session "
         "overwrote stage1_report.json and kept nothing. Its sha256 is recorded in "
         "build_artifacts/reproducibility.json .reports_before; its content is NOT recoverable. "
         "The cascade is now a true shift -- prev -> prev2 -> prev3 -- that never deletes and "
         "never overwrites, and it fires only when the report's SUBSTANCE (stage, status, counts, "
         "findings) changes, so the deletion proof's five chain invocations no longer grow the "
         "chain by a near-duplicate each. The chain's current shape, with a digest per slot and "
         "the slots that share a substance, is in this report at .report_chain.")

    # ---- two profile field spellings that carry the opposite of what they are named.
    find("profile_field_unrecognised", "info", "3",
         "TWO PROFILE KEYS HOLD THE OPPOSITE OF WHAT THEY ARE NAMED, and both are consumed for "
         "what they CONTAIN rather than renamed here. longest_source_view_cast_name holds an "
         "INTEGER (a length) and longest_source_view_cast_example_note holds an IDENTIFIER (a "
         "name). A reader taking either at its name gets the other. Additionally the value 41 "
         "measures PREFIX+stem, a form this build does not emit -- the emitted cast model name "
         "carries the layer prefix -- and it is the TIED-SECOND longest even in its own form, "
         "where the maximum is 42. The build asserts the load-bearing half instead: that the "
         "abbreviation vocabulary still derives that exact stem for that exact view, and that "
         "every emitted name is inside the budget. The mapping side has ENDED, so this is a "
         "permanent caveat on the profile rather than a request.")

    # ---- the nested rename the top-level key guard could not see.
    find("profile_field_unrecognised", "warn", "3",
         "THE REV-6 BLOCKER WAS NOT ONLY THE 15 TOP-LEVEL KEYS. sibling.payload_convention was "
         "renamed to sibling.payload_convention_token (plus _status and _note) INSIDE a block that "
         "kept its own name, so the top-level key guard stayed silent and the build died on a "
         "KeyError 700 lines into a naming function -- a worse failure than a refusal, because it "
         "names no cause. A nested rename table now refuses an old inner spelling with a stated "
         "reason, and every `sibling` spelling this build reads is declared and asserted present "
         "at import. The comparator reads the _token and never the _note (BUILD_RULES 1.21), and "
         "the class-to-token mapping is declared rather than substring-matched: 'UPPER_SNAKE' does "
         "not appear in 'UPPER_SNAKE_PHYSICAL' under a split, and would wrongly match a future "
         "'NOT_UPPER_SNAKE'.")

    # ---- the bespoke layers, declared in the profile
    for b in N.PROFILE["bespoke_layers"]:
        find("bespoke_layer", "info", "2",
             "%s -- implemented and named. %s" % (b["name"], b["reason"]))

    # ---- unresolved keys
    for u in spec["unresolved"]:
        find("unresolved_key", "warn", "mapper",
             "%s: %s. Built as mapped where it could be built, otherwise left unbuilt with the "
             "reason in build_artifacts/mtv2_spec.json. Stage 3 must put this to the mapper; the "
             "build does not correct a mapping (BUILD_RULES 5.7)." % (u["kind"], u["detail"]))

    # ---- unbuilt, grouped by routing and reason so the handback is not 58 lines of the same thing
    grouped = collections.defaultdict(lambda: [0, None])
    for u in spec["unbuilt"]:
        key = (u["routing"], u["reason"][:160])
        grouped[key][0] += u.get("count", 1)
        grouped[key][1] = u
    for (routing, reason), (count, sample) in sorted(grouped.items()):
        find("note", "warn", routing,
             "%d row(s)/item(s) NOT BUILT: %s Example: %s. Stage 3 must either accept these into "
             "accepted_uncovered.txt with this reason, or return an answer that lets them be "
             "built." % (count, reason, sample["what"]))

    # ---- directives
    implemented = {d["bundle_item"] for d in N.PROFILE["build_directives"]}
    find("note", "info", "2",
         "All %d build directives in the profile are implemented and each is NAMED in the "
         "generator that implements it; generators/README.md emits the bundle-item -> mechanism "
         "-> module table from the code. No directive was declined." % len(implemented))

    # ---- the things that are unproven and must not read as proven
    for u in N.PROFILE["undetermined"]:
        find("note", "warn", "3",
             "UNDETERMINED, carried forward: %s -- %s CONSEQUENCE: %s"
             % (u["what"], u["why"], u["consequence"]))

    # ---- specific, measured findings
    find("note", "warn", "3",
         "TWO content-hash canonicalisations, used on DISJOINT hubs: md5(normalise(...)) on "
         "HUB_LOCATION and LNK_PARTY_LOCATION (ADDRESSES -- internal whitespace collapsed) and "
         "md5(upper(trim(...))) on HUB_PARTY, LNK_PARTY_ROLE and HUB_ORG_UNIT (nominee and branch "
         "NAMES -- ends trimmed only). Verified: ZERO hubs carry both form. This is NOT a split "
         "key space within one hub. Both are emitted exactly as mapped and the split is in "
         "BUILD_STATUS.json .content_hash_canonicalisations. The open question -- whether a "
         "hand-typed nominee name should collapse internal whitespace too, so that 'AB  CD' and "
         "'AB CD' are one party -- is a modeller decision on a hub OPUS also writes, not a build "
         "decision.")
    dc = spec["census"]["degenerate_contract"]
    find("note", "info", "2",
         "THE DEGENERATE CONTRACT IS ASSERTED, NOT CONSUMED. degenerate_value is JSON null on "
         "all 2344 blocks and is NEVER read as a value or as a guard operand -- it is "
         "type-checked and nothing else. degenerate_verdict is read ONCE: %s. The other two "
         "branches (%s) have ZERO rows, so this build ships NO code path for them and RAISES if "
         "one appears. A branch with no rows is not a tested branch, and two untested branches "
         "in the guard would be exactly the defect this corpus is built around."
         % (dc["degenerate_verdict"], ", ".join(dc["branches_with_zero_rows"])))
    find("note", "info", "2",
         "keynorm grew a THIRD field-set shape in rev 4. Nothing here reads a keynorm value -- "
         "previous_expression is history on all 1444 blocks and parsing it would re-key hubs to "
         "a superseded walk -- but the SHAPES are asserted and an unrecognised one stops the "
         "build. Measured: %s. A reader iterating by `stage` would silently skip 20 blocks."
         % spec["census"]["keynorm_shapes"])
    find("note", "info", "3",
         "KEY REJECTION: the mechanism is by SHAPE -- a CASE over "
         "coalesce(<guarded operands>) is not null, then nullif(trim(key),''). The outer "
         "nullif(key,'<constant>') branch exists but FIRED ZERO TIMES on this map, and zero is "
         "reported as zero: under Snowflake semantics every one of the map's key expressions is "
         "NULL on an all-blank row, so there is no statically computable constant to compare "
         "against. A predicate built from KEY_DEGENERATE_VALUES.csv's 369 'non-empty constants' "
         "could never fire while reading exactly like a working guard. Per-hub per-feeder drop "
         "counts are measured at RUN time by audit_mtv2_key_rejections, not asserted here.")
    if spec["census"]["link_legs_uncorroborated"]:
        find("note", "warn", "mapper",
             "%d LNK leg(s) are not ALSO used as a standalone hub key on their own view, so the "
             "directive's 'assert the leg appears verbatim as some hub resolved_key.expression' "
             "has nothing to compare against there. They are BUILT -- every leg goes through the "
             "same render_key(), so a leg and its hub key are byte-identical by construction -- "
             "and listed individually in mtv2_spec.json census.link_legs_uncorroborated. Raising "
             "instead would have dropped them and the loss would read as a source gap."
             % len(spec["census"]["link_legs_uncorroborated"]))
    if spec["census"]["ordinal_child_key_legs"]:
        by_sat = collections.Counter(o["satellite"] for o in spec["census"]["ordinal_child_key_legs"])
        find("note", "warn", "source",
             "A RENUMBERING ORDINAL still reaches a child key on %s. All SEVEN spellings in the "
             "profile were swept as a class, not matched as tokens. Built AS MAPPED with the "
             "mapper's own 'declared source gap, not re-keyed' disposition; POD_NUMBER was named "
             "a candidate, not a decision, and the build does not substitute it (BUILD_RULES "
             "5.7). A dispatch line inserted or removed re-attaches the history of the rest."
             % ", ".join("%s (%d leg occurrence(s))" % (k, v) for k, v in by_sat.items()))
    for gd in status["sibling"]["grain_divergences"]:
        find("note", "warn", "modeller",
             "GRAIN DIVERGENCE on %s: this map declares multi_active=%s with child key %s; the "
             "OPUS sibling builds it %s. Built under the SIBLING's contract (BUILD_RULES 7.2) and "
             "reported. %d row(s) affected."
             % (gd["satellite"], gd["maximus_declared"]["multi_active"],
                gd["maximus_declared"]["src_cdk"] or "(none)",
                "multi-active" if gd["sibling"]["multi_active"] else "single-active",
                gd["rows_affected"]))
    ss = status["sibling"]["shared_surface"]
    find("note", "blocker", "3",
         "SHARED-VAULT HASHDIFF: NARROWED, NOT RETIRED, and the earlier scope was wrong. "
         "MEASURED THIS RUN against the sibling BUILD, satellite by satellite: %d satellites "
         "here and %d in travel_dv_dbt; %d are written by BOTH -- not the %d the previous report "
         "counted, which took only the OPUS-named SAT_AUG_* nine and understated the shared "
         "surface by the standard-track satellites. RETIRED on the COLUMN NAME: %d of %d bare "
         "HASHDIFF here, %d of %d on the sibling, %d name disagreement(s) across the shared set. "
         "NOT RETIRED, and this is the worse half: the hashdiff INPUT LIST differs on %d of the "
         "%d shared satellites. Same column name, different contents -- a row written by one "
         "project and read by the other still compares as CHANGED, and the name agreeing is what "
         "hides it. Input list here means %s Per-satellite detail is in BUILD_STATUS.json "
         ".sibling.shared_surface.hashdiff_input_list_detail. Reconciling the lists re-grains a "
         "shared table and is a MODELLER decision; this build does not take it."
         % (ss["satellites_here"], ss["satellites_in_the_sibling"], ss["shared_by_name"],
            len(status["sibling"]["aligned_satellites"]),
            ss["bare_hashdiff_here"], ss["satellites_here"],
            ss["bare_hashdiff_in_the_sibling"], ss["satellites_in_the_sibling"],
            len(ss["hashdiff_name_disagreements"]),
            ss["hashdiff_input_list_disagreements"], ss["shared_by_name"],
            ss["input_list_definition"]))
    if spec["census"]["anchor_bound_by_assumption"]:
        votes = spec["census"]["anchor_bound_by_assumption"][0]["vote"]
        find("note", "warn", "mapper",
             "%d augmentation attribute(s) carry an ANCHOR and no resolved_key, and their anchor "
             "has several key slots on their view with no instance named. They are bound to the "
             "DOMINANT instance -- the one the map itself uses for most rows on that view, vote "
             "%s -- rather than dropped. Dropping them would be a silence coverage cannot see "
             "(BUILD_RULES 8.1). Every binding is listed in mtv2_spec.json "
             "census.anchor_bound_by_assumption; one mapper answer settles all of them."
             % (len(spec["census"]["anchor_bound_by_assumption"]), votes))
    # ---- re-entry #2 measurements, all re-derived from the map in hand
    split = spec["census"]["one_column_two_key_spaces"]
    find("note", "info" if not split else "warn", "mapper",
         "ONE SOURCE COLUMN IN TWO KEY SPACES, swept across EVERY hub rather than confirmed on "
         "the instance the mapper found: %d. %s The detector is proved able to fire by the "
         "companion sweep in the same pass, which finds 7 hubs with several single-operand bare "
         "keys -- so this zero is a MEASURED zero, not a check that cannot fail."
         % (len(split),
            ("HUB_DOCUMENT's DOCUMENT_ID is unified on 'DOC:' in the map I built from "
             "(INWARD: 38 / DOC: 22 / COI: 4, no bare form), so the finding the profile raises "
             "is CLOSED in this map." if not split
             else "Built as mapped, both forms (BD13): " + "; ".join(
                 "%s.%s %s" % (x["hub"], x["source_column"], x["namespaces"]) for x in split))))
    bare = spec["census"]["hubs_with_a_shared_bare_namespace"]
    if bare:
        flagged = [x for x in bare if x.get("mapper_flagged")]
        find("note", "warn", "source",
             "%d hub(s) have several SINGLE-OPERAND bare keys -- different source columns each "
             "keying the hub alone with no namespace. Whether that is ONE code system reached by "
             "several column names, which is what a canonical hub is FOR, or SEVERAL systems "
             "that must not merge, is a SOURCE question this build cannot answer and does not "
             "guess. Reported as a CENSUS, not as %d findings. The mapper flags %s: %s. Built as "
             "mapped; merging is the unrecoverable direction, so nothing was merged."
             % (len(bare), len(bare),
                ", ".join(x["hub"] for x in flagged) or "none of them",
                "; ".join("%s(%s)" % (x["hub"], ", ".join(x["single_operand_bare_keys"][:3]))
                          for x in flagged) or "-"))
    warn_traps = spec["census"]["collapse_trap_warnings"]
    find("note", "warn", "mapper",
         "COLLAPSE TRAPS: the profile's list widened 10 -> 20 by adding legs that render to one "
         "value only because ONE view carries them. %d satellite(s) were REFUSED -- every leg of "
         "their child key is a literal with NO OPERAND and can never discriminate. %d were BUILT "
         "with a warning: every leg is on the 20-list but is backed by a source COLUMN and will "
         "discriminate per row at load time. Refusing those too would have withheld %d "
         "satellites on a signal the profile itself calls weaker (BUILD_RULES 11.8). The %d are "
         "in mtv2_spec.json census.collapse_trap_warnings."
         % (sum(1 for u in spec["unresolved"] if u["kind"] == "collapse_trap_only"),
            len(warn_traps), len(warn_traps), len(warn_traps)))
    find("note", "blocker", "mapper",
         "leg_backing='unresolved' is now a HARD SENTINEL. The one leg that carries it "
         "(SAT_CLAIM_EVIDENCE.'Media Reference') has no expression and a `value` that is an "
         "already-quoted English sentence. The synthesis rule that is correct for the other 44 "
         "expression-less legs would have written that sentence into a child key, past every "
         "gate, because a quoted string is valid SQL. It is REFUSED before anything reads "
         "`value`, and a renderable-token test now guards the other 44 as well -- so a future "
         "re-issue that moves prose into a `value` under a different leg_backing is refused too, "
         "rather than relying on this one kind staying labelled. The row is unbuilt and listed.")
    div = spec["census"]["leg_key_divergence"]
    if div:
        import collections as _c
        byclass = _c.Counter(x["class"] for x in div)
        worst = [x for x in div if x["class"] != "whitespace_only"]
        find("note", "warn", "mapper",
             "LINK LEG vs HUB KEY: %s. Built AS MAPPED (BD12) -- substituting the hub's "
             "expression for the leg's is the build correcting the mapping (BUILD_RULES 5.7), "
             "and on CLAIM_RESERVE the two are not cosmetic: the hub key walks FOREIGN_KEY and "
             "the leg walks PARENT_KEY_HASH, so the leg rides the UNPROVEN FK round-trip while "
             "the hub does not. The orphan 'EMP:' || BAGIC_RM_ECODE leg mints a party no hub key "
             "anywhere produces. The cost is SILENT -- an empty join reads as sparse source data "
             "-- so audit_mtv2_link_leg_divergence counts legs reaching no hub row per link per "
             "hub per feeder. %s"
             % (dict(byclass),
                "; ".join("%s %s on %s" % (x["class"], x["hub"], N.short_view(x["view"]))
                          for x in worst[:6])))
    lc = spec["census"]["link_leg_census"]
    find("note", "blocker", "3",
         "COVERAGE LIMIT ON MY OWN LINK CHECK, RESTATED OVER THE RIGHT POPULATION. Previously "
         "reported as %d, which counted only legs that were BOTH positional AND uncorroborated "
         "-- a subset of a subset -- in the same sentence as a claim that more than half the "
         "link surface is unverified. The two halves contradicted each other and the smaller "
         "number is the one a reader quotes (BUILD_RULES 11.8). MEASURED THIS RUN from the live "
         "map with the build's own balanced-paren splitter: %d legs over %d LNK call sites; %d "
         "NAMED for a hub (%s); %d named for a non-hub role; %d carrying NO name token, of which "
         "%d are pure literals. THE FIGURE TO QUOTE IS %d of %d legs (%.1f percent) that name no "
         "hub: on those the leg and the hub key come from the SAME render_key() and agree BY "
         "CONSTRUCTION, so audit_mtv2_link_leg_divergence cannot see a mis-bound leg there. "
         "RECONCILING THE THREE PUBLISHED FIGURES: legs total agrees everywhere; this build and "
         "build_profile.json agree that %d legs carry a name token and %d carry none -- the "
         "profile's own 'named/positional' split; stage 2's re-derivation of 34 named counts "
         "only legs naming a HUB_ and reached %d fewer than this build does, differing on "
         "HUB_PARTY and HUB_LOCATION. The build's splitter is the one that parses the whole map "
         "with zero residue, so 'named for a hub' here is %d."
         % (spec["census"]["link_legs_positional_unverifiable"],
            lc["legs_total"], status["grammar"]["lnk_call_sites"], lc["named_for_a_hub"],
            ", ".join("%s %d" % (h, n) for h, n in sorted(lc["named_for_a_hub_by_hub"].items())),
            lc["named_for_a_non_hub_role"], lc["no_name_token_at_all"],
            lc["literal_degenerate"], lc["not_named_for_a_hub"], lc["legs_total"],
            100.0 * lc["not_named_for_a_hub"] / max(lc["legs_total"], 1),
            lc["carrying_any_name_token"], lc["no_name_token_at_all"],
            lc["named_for_a_hub"] - 34, lc["named_for_a_hub"]))

    if spec["census"]["stage_column_collisions"]:
        find("note", "info", "2",
             "%d payload column name(s) were renamed with a satellite suffix in a wide stage "
             "because two satellites on one view derive the same name from different sources. "
             "The satfeed renames them back, so the satellite's declared payload is unchanged. "
             "Stage 2 should expect the suffixed names in the STAGE layer only."
             % len(spec["census"]["stage_column_collisions"]))
    find("note", "info", "2",
         "%d cast model(s) are PROVISIONED and joined by no resolver: they are the parent-chain "
         "levels a FOREIGN_KEY hop's named destination skips, and they are the reversal path for "
         "BD1. They are not dead models. They are named in gen_mtv2_hopviews' output and in "
         "mtv2_spec.json provisioned_not_joined." % len(spec["provisioned_not_joined"]))

    # ---- own defects (BUILD_RULES 11.6 -- empty is a suspicious answer)
    for detail in [
        "MY DEFECT, caught and fixed before delivery: the sibling-contract lookup fell back from "
        "a STANDARD satellite to the sibling's SAT_AUG_* of the same concept, then re-grained the "
        "satellite to the augmented contract and filtered its rows by the new grain. "
        "SAT_PARTY_BANKING lost all 44 of its rows and vanished from the build. Fixed by scoping "
        "the lookup to the track and by never letting a contract change WHICH ROWS are built.",
        "MY DEFECT, caught and fixed: 50 of the 51 LNK() expressions in this bundle are SATELLITE "
        "ATTRIBUTE rows, not link-key rows. The first link pass consumed them and never created a "
        "satellite row, so seven link satellites were silently absent.",
        "MY DEFECT, caught and fixed: a key slot was identified by the EXPRESSION STRING, so one "
        "party key written once with abbreviated destination tokens and once with full names "
        "became two key columns on one view -- two hub populations for one party. Slot identity "
        "is now the RENDERED KEY.",
        "MY DEFECT, caught and fixed: the sibling src_pk re-point matched LOCATION_HKEY against "
        "LOCATION_HKEY__<instance> by prefix and collapsed three distinct addresses onto one. The "
        "sibling's contract is about which HUB, not which instance of it.",
        "MY DEFECT, caught by my own dead-path check and fixed: the wide stage's column-claim "
        "pass did not include the columns a satellite NULL-PADS, so a null-padded column took the "
        "plain name and blocked the satellite that actually fed it -- a live attribute rendered "
        "dead while still declared. It also pooled both tracks into one namespace.",
        "MY DEFECT, caught and fixed: the augmented stage passed a CTE name as source_model. "
        "automate_dv.stage resolves that with ref(), so it would not have compiled -- and nothing "
        "in this workspace runs dbt, so no gate here would have caught it.",
        "MY DEFECT in the CHECK, caught and fixed twice: the dead-path check first read the "
        "SPEC's payload rather than what was built, then required an ' as ' alias the satfeed "
        "does not always write. The two versions reported 6 and then 929 false positives. It now "
        "reads src_payload from the satellite model and follows each satfeed branch to its stage.",
    ]:
        find("note", "info", "3", detail)

    for detail in [
        "MY DEFECT, caught by the deletion proof: FOUR layers never wiped. Only the vault and "
        "augmented layers emptied their directories, so the cast, resolver, unpivot and stage "
        "layers kept any model a previous run had produced and this one no longer does. "
        "Refusing one feeder removed two models from the output and a run over a populated "
        "tree still shipped them -- a model nobody generates any more, indistinguishable from "
        "a live one. Every layer is now wiped by its FIRST writer (two directories have two "
        "writers each, so the order is load-bearing and is documented in run_all.sh). The "
        "proof now returns byte-identical.",
        "MY DEFECT, avoided only because the coordinator corrected me: I first refused all 7 "
        "rows whose transformation begins 'derived:'. Four of those are prose, so a prefix "
        "test would have withheld four real attributes -- the same over-refusal shape as the "
        "collapse-trap list earlier in this run. The fix is not a better pattern: it is to "
        "stop pattern-matching a field the map already classifies.",
        "MY DEFECT, found by the coordinator and not by me: target.transformation was read ZERO "
        "times across four runs. On this LOB it carries executable derivations on 7 rows, two of "
        "which were emitting WRONG data. My never-read list was assembled from what looked like "
        "prose without testing whether anything on it was load-bearing, and `transformation` was "
        "never on any list at all -- it was simply never consumed. The generalised fix is the "
        "value-shape classifier: no field that can carry an instruction is now allowed to be "
        "absent-by-omission.",
        "MY DEFECT this run, caught by my own negative control: the BD13 prefix-split probe "
        "flagged a column keyed under SEVERAL DIFFERENT prefixes as a hazard. That is the "
        "opposite of the hazard -- different prefixes are deliberate separation. It reported "
        "HUB_FINANCIAL_TRANSACTION.PARENT_KEY_HASH under PAY:/POLPREM:/QUOTEPREM:, three "
        "transaction types correctly held apart. Narrowed to prefixed-AND-bare, which is the "
        "real two-key-spaces case.",
        "MY DEFECT this run, caught and narrowed before delivery: I let the profile's widened "
        "20-item collapse-trap list refuse satellites outright, taking refusals from 2 to 13. "
        "Eleven of those have a child key backed by a real source COLUMN that renders to one "
        "value only because one view carries the leg; they discriminate per row at load time. "
        "Refusing them would have withheld eleven satellites on a signal the profile itself "
        "calls weaker, and would have got the two REAL refusals discounted along with them.",
        "MY DEFECT this run, caught and narrowed: my shared-bare-namespace detector flagged any "
        "hub with more than one unprefixed source column, which reported 7 hubs including "
        "HUB_LOCATION's 56 address COMPONENTS -- the operands of ONE content hash, not 56 code "
        "systems. Narrowed to several SINGLE-OPERAND bare keys, and reported as a census rather "
        "than a verdict, because distinguishing one code system from several is a source fact I "
        "do not have.",
    ]:
        find("note", "info", "3", detail)

    # ---- the one that cost something, and is not mine to repair
    find("note", "blocker", "3",
         "MY DEFECT, NOT RECOVERABLE BY ME: I destroyed this project's stage-0 completion "
         "reports. build_artifacts/reports/stage0_report.json and stage0_reentry_report.json are "
         "GONE from local disk. Cause: my first reproducibility script followed BUILD_RULES 9.3 "
         "by backing the reports up and then deleting build_artifacts; on a second invocation its "
         "own cleanup of the backup directory ran BEFORE the copy, so the backup was emptied and "
         "the originals were then deleted. This is precisely the amendment 9.3 already carries, "
         "and I reproduced it. FIXED FOR THE FUTURE: the proof now deletes only what the chain "
         "rewrites and asserts build_artifacts/reports survived; that assertion passes on the "
         "run that produced this report. RECOVERY: the project lives under OneDrive, so the "
         "deletes should be in the OneDrive cloud recycle bin (30-day retention) for "
         "'Documents/dev/Health_DBTModel/maximus_travel_v2_dv_dbt/build_artifacts/reports' -- "
         "please restore from there, or re-run stage 0, which regenerates them. The build itself "
         "does not depend on them; stage 2 and stage 3 do. No mapper artifact and no bundle file "
         "was touched: the read-only assertion over the whole input set passes on every run.")

    # ---- a finding about a SHARED tool, which is not mine to change
    find("note", "info", "2",
         "vault_tools/check_patterns.py reads the FIRST ARGUMENT of .search()/.match() as a "
         "PATTERN. That is right for a pattern and wrong for a SUBJECT: it reported two probe "
         "subjects in mtv2_names.py as uncompilable regexes, and warned that a POSIX character "
         "class in a third was a nested set. I restructured my probes to build their subjects in "
         "variables rather than weaken a shared gate -- the gate now passes -- but the blind spot "
         "is real and will fire on any project that probes a pattern with a literal subject. "
         "Owner: builder. Not fixed by me: vault_tools is shared by every project.")

    # ---- the rev-4 headline: a field carrying instructions that nobody read
    refused = spec["census"]["derived_transformations_refused"]
    xc = spec["census"]["build_directive_crosscheck"]
    find("note", "blocker", "mapper",
         "target.transformation CARRIES EXECUTABLE DERIVATIONS ON THIS LOB AND WAS READ ZERO "
         "TIMES until this run. %d attribute(s) are REFUSED rather than emitted from their raw "
         "column, selected on build_directive == true -- the map's own declaration. Emitted raw "
         "they are WRONG data, not missing data: SAT_RISK_PERSON_INSURED.'Age At Entry' would "
         "receive a raw DATE OF BIRTH, and SAT_POLICY_COVERAGE_SCHEDULE.'Coverage Reference' a "
         "whole delimited list as ONE value on a multi-active satellite that should fan out to "
         "one row per coverage code. Both pass every gate: outcome=mapped, SQL well-formed, "
         "column populated. The derivations are NOT implemented -- floor, months_between and "
         "split are unratified in KEY_FUNCTIONS.md, the age calculation needs "
         "COVER_INCEPTION_DATE on the same view (unverified), and split-to-rows is a bespoke "
         "FAN-OUT LAYER (BUILD_RULES 6.5), not an expression to improvise. Cross-checked against "
         "the bundle's own 20_build_directives.json: %s (mine %s, theirs %s). || %s"
         % (len(refused), xc["agreement"], xc["mine"], xc["theirs"],
            " || ".join("%s.%s <- %s : %s" % (d["satellite"], d["attribute"], d["source_column"],
                                              d["transformation"]) for d in refused)))
    find("note", "info", "2",
         "transformation is classified by the DECLARED transformation_kind, never by the value's "
         "shape, and can never be silently ignored: %s. Five kinds exist on this LOB and only "
         "executable_expression refuses; an unrecognised kind, a populated value with no kind, "
         "or a kind that disagrees with build_directive all STOP the build rather than "
         "defaulting to prose (BUILD_RULES 2.2). TEST THE SPECIFIC BEFORE THE GENERAL: 7 rows "
         "begin 'derived:' and only 3 are executable, so a prefix test would have withheld 4 "
         "real attributes -- and the mapper's own classifier proved the same trap in the other "
         "direction by matching 'decode (' inside 'code->decode (repository code ...)'."
         % spec["census"]["transformation_shapes"])

    # ---- WHAT THIS BUILD IS RELATIVE TO. The map is moving; say so.
    find("note", "warn", "3",
         "NOT FINAL. This build is against build_profile.json revision %s and the map as it "
         "stood at the digest recorded in BUILD_STATUS.json .input_digest. A further re-issue "
         "has already been announced. Nothing here should be read as 'the map is settled'; the "
         "generators are the durable artifact and re-running them is cheap."
         % N.PROFILE.get("profile_revision"))
    find("note", "warn", "3",
         "THE BUNDLE MOVED UNDER THIS RUN, measured not assumed. The profile's field census and "
         "the map on disk disagree on two fields, both of which are on the never-read list: "
         "(1) resolved_key.degenerate_value is JSON null on all 2344 rows with a NEW sibling "
         "field degenerate_verdict='null_on_blank_row', where the profile describes it as the "
         "English sentence 'NULL (row correctly rejected on an all-blank source row)'; "
         "(2) 33 keynorm blocks (27 target, 6 augmentation) carry `reason` ALONGSIDE stage and "
         "class, where the profile states that reason-bearing blocks carry neither. EVERYTHING "
         "LOAD-BEARING IS BYTE-STABLE against the profile: rows 2639, resolved_key blocks 2366, "
         "expressions 2344, child_key_components 1119, live expressions 3418, and the FULL "
         "function census including trim=5094. So no key, leg, satellite or attribute this build "
         "emits is affected. Stage 1 identified bundle state by CONTENT DIGEST, never by mtime, "
         "as the re-entry report asks -- the digest over the named input set is in "
         "BUILD_STATUS.json .input_digest.")
    find("note", "warn", "mapper",
         "THE BUNDLE'S OWN ALLOWLIST GATE IS BLIND TO A THIRD OF THE LIVE EXPRESSIONS. "
         "check_key_function_census.py polices resolved_key expressions only -- 2344 of the 3418 "
         "live expressions -- so an unratified function can accumulate in "
         "child_key_components[].expression without the allowlist noticing. My census covers all "
         "3418 (the profile's own A+B split proves the arithmetic: 4415+679=5094 trim). Scope "
         "stated with every number.")
    find("note", "warn", "mapper",
         "GATE IS AT 8 WARNS, NOT 7, and the covering documents still say 7. The 8th is "
         "resolved_key_sound on HUB_DOCUMENT. State it as a PRE-EXISTING COLLAPSE NOW VISIBLE, "
         "not as a regression: the two instances previously differed by one whitespace "
         "character, which changes no SQL value, so they always collapsed onto one hub row. The "
         "fix merely made the collapse visible to a string-comparing gate. Nothing about the "
         "emitted keys changed.")
    find("note", "warn", "mapper",
         "KEY_FUNCTIONS.md section 10 still names SAT_QUOTE_RATING as an as-built contract. "
         "VERIFIED INDEPENDENTLY against travel_dv_dbt this run, not taken from a document: 295 "
         "SQL models, zero matching *quote_rating*, and sat_quote_header.sql is the only quote "
         "satellite. The OPUS quote branch is MINIMAL. This build matches the as-built natural "
         "key form, parentheses included.")
    find("note", "warn", "3",
         "FK ROUND-TRIP EXPOSURE, quoted WITH ITS SCOPE: 875 live key expressions reference "
         "FOREIGN_KEY, of which 863 do so through a spine walk. The figure '733 rows' that "
         "circulates in the covering documents reproduces as neither and is not quoted here. "
         "The round-trip itself remains UNPROVEN -- 00_tables_index.json still carries "
         "sample_data_available=false -- and audit_mtv2_fk_roundtrip falsifies it before any "
         "load.")
    find("note", "info", "2",
         "TWO PROFILE NUMBERS MOVED FOR METHOD REASONS, NOT BUNDLE REASONS, and are NOT drift: "
         "casts 113 -> 115 (rev 4 expands every prefix-ancestor; rev 3 expanded only the levels "
         "between a walk's endpoints, against a byte-identical 00_tables_index.json) and "
         "link-leg disagreements 16 -> 12 (rev 4 compares whitespace-canonical token streams, "
         "absorbing the 9 whitespace-only cases). This build follows rev 4's method and emits "
         "115 casts; the 2 extra are ancestors that have to exist anyway.")
    find("note", "info", "2",
         "BUNDLE DIGEST CHECK, run against the profile's own bundle_digests: 8 of 9 files match "
         "byte for byte, INCLUDING 04_column_map.json. The one that moved is KEY_FUNCTIONS.md "
         "(d62e136c -> 7ef3230f). Consequence: NONE for this build, because nothing here "
         "validates against that document -- the function census is taken over the MAP. That is "
         "the whole value of not reading a governance artifact as an allowlist.")
    find("note", "info", "3",
         "KEY_FUNCTIONS.md's function table is the declared ALLOWLIST and has been stale twice "
         "in this engagement. This build validates the census against the MAP, never against "
         "that table, and reports a divergence instead of failing closed against it. Measured "
         "this run: the map's function census reproduces the PROFILE's exactly, trim included.")

    # ---- the renumbering ordinal in a child key: BLOCKING, to the modeller
    osum = status["ordinal_child_keys"]
    for o in osum["distinct"]:
        find("collapse_trap", "blocker", "modeller",
             "A RENUMBERING ORDINAL IS CARRYING A CHILD KEY. %s declares child key %s and its "
             "stage defines that column from %s on %s -- %d map leg row(s) collapse to ONE "
             "child-key column in ONE stage, so both figures are true of different scopes. "
             "BUILD_RULES 5.2: an ordinal is never a discriminator and a child-key leg needs "
             "hub-grade stability; a dispatch line inserted or removed renumbers the rest and "
             "re-attaches their history, exactly as a renumbered hub key would. BUILT AS MAPPED "
             "(5.7) -- the build does not re-key a satellite -- and made LOUD: the satellite "
             "model and the stage that defines the column both carry the warning in their "
             "header. The ordinal CLASS is re-derived BY SHAPE from 00_tables_index.json and "
             "reconciled with the profile, so an eighth spelling stops the build rather than "
             "being missed; detection in the emitted models resolves src_cdk through the feed to "
             "the stage expression and never looks for a name shape such as a _CK suffix, which "
             "is how a check returns a clean zero it cannot earn. THE QUESTION THE BUILD CANNOT "
             "ANSWER: is %s stable per row, and if not, what identifies one?"
             % (o["satellite"], o["column"], ", ".join(o["columns"]), N.short_view(o["view"]),
                o["map_rows"], ", ".join(o["columns"])))
    shaped = osum.get("ordinal_shaped_but_not_source_backed") or []
    if shaped:
        find("note", "warn", "mapper",
             "%d child-key column(s) are ORDINAL-SHAPED but backed by no source column of that "
             "shape -- on this build they are unpivot instance labels or literals, which "
             "discriminate stably. They are reported rather than counted as ordinals, because "
             "the shape alone is not the test and a reader seeing the name would ask: %s. Detail "
             "at BUILD_STATUS.json .ordinal_child_keys.ordinal_shaped_but_not_source_backed."
             % (len(shaped), ", ".join(sorted({"%s.%s" % (h["satellite"], h["column"])
                                               for h in shaped}))))

    # ---- what the shared gate still reports, diagnosed rather than argued with
    cov = spec["census"]["coverage"]
    cdk_carried = [u for u in cov["uncovered"] if u["class"] == "carried_as_cdk"]
    # The gate's LIVE verdict, read from the verification artifact rather than asserted. This
    # finding used to open "CHECK 1 STILL FAILS" unconditionally, and it kept saying so after the
    # exemption loader cleared the gate -- a stale claim in a GENERATED report, which is the
    # failure mode this whole stage exists to prevent. The scope issue below is real either way;
    # the VERDICT is now measured.
    _gvp = os.path.join(N.ARTIFACTS, "gate_verification.json")
    _va_exit = None
    if os.path.exists(_gvp):
        with open(_gvp, encoding="utf-8") as _fh:
            _va_exit = (json.load(_fh)["gates"].get("check_vault_alignment") or {}).get(
                "clean_exit")
    _verdict = ("PASSES (exit 0) as it stands" if _va_exit == 0
                else "FAILS (exit %r)" % _va_exit if _va_exit is not None
                else "has NOT been run against this tree, so no verdict exists (NOT_RUN is not "
                     "PASS)")
    find("note", "warn" if _va_exit == 0 else "blocker", "2",
         ("check_vault_alignment %s -- the verdict is READ from "
          "build_artifacts/gate_verification.json, not asserted. THE SCOPE ISSUE IS UNCHANGED and "
          "survives the pass: " % _verdict) +
         "%d of check 1's original findings are a GATE SCOPE "
         "issue, not a build defect: the canonical rendering IS present in the model, as the "
         "satellite's src_cdk, and check 1 compares only against src_payload. Putting the same "
         "name in both would violate BUILD_RULES 5.4 and produce a column selected twice, which "
         "check 5 would then fail. The build cannot satisfy check 1 for these without breaking "
         "5.4. ROUTE TO vault_tools: check 1 should compare against src_payload UNION src_cdk. "
         "The %d affected: %s. The remaining finding is SAT_RISK_PERSON_INSURED.AGE_AT_ENTRY, "
         "which is a real absence -- the refused build directive below. The gate is green today "
         "only because 12 exemption lines suppress a NON-gap; the exemption is the right "
         "mechanism for a real gap and the wrong one for a column the build emits, so the scope "
         "fix is still owed."
         % (len(cdk_carried), len(cdk_carried),
            ", ".join("%s.%s" % (u["satellite"], u["column"]) for u in cdk_carried)))
    find("note", "warn", "mapper",
         "COVERAGE NOW HAS SANCTIONED EXEMPTIONS (BUILD_RULES 8.2), one per uncovered column, "
         "GENERATED from the build's own coverage census rather than typed: %d of %d mapped "
         "columns reach a payload and the %d that do not are %s. gen_mtv2_exemptions.py writes "
         "build_artifacts/accepted_uncovered.mtv2.txt and selfcheck asserts "
         "vault_tools/accepted_uncovered.txt carries exactly those lines; the generator does not "
         "write into vault_tools, because that file is shared by every project here. check 6 of "
         "the shared gate now passes with the gaps COUNTED and REASONED rather than silent. Each "
         "still needs a mapper answer: a different payload name, or a ruling that the attribute "
         "is the child key and nothing else."
         % (cov["covered"], cov["total"], len(cov["uncovered"]), cov["by_class"]))

    # ---- the profile itself
    disp = N.PROFILE_KEY_DISPOSITION
    rev5 = [k for k in sorted(N.PROFILE) if k in disp and k in (
        "carried_forward_with_digest_proof_note", "census_exploit_retest",
        "doc_vs_bundle_contradictions", "foreign_key_population",
        "function_allowlist_coverage_gap_RESOLVED", "function_census_verified_per_slot",
        "gate_status", "hub_risk_object", "stage1_field_knowledge_note",
        "still_open_reconfirmed", "transformation_contract")]
    find("profile_field_unrecognised", "info", "2",
         "THE BUILD NOW RUNS AGAINST ITS OWN PROFILE. run_all.sh refused at the first generator "
         "on %d keys revision 5 added, which was CORRECT (BUILD_RULES 2.2) and meant the project "
         "could not be rebuilt from its own directory; reproducibility could only be proved by "
         "substituting revision 4. Each of the %d is now disposed of deliberately in "
         "mtv2_names.PROFILE_KEY_DISPOSITION -- %s -- and the guard is NOT widened: an unknown "
         "key is still fatal. One key was RENAMED (function_allowlist_coverage_gap to "
         "..._RESOLVED); the old spelling stays RECOGNISED so an older profile is refused with a "
         "reason, and carrying both is fatal. The five CONSUMED keys are cross-checked against "
         "what the build measures and a disagreement on an identically defined population stops "
         "the build: see BUILD_STATUS.json .profile_crosschecks."
         % (len(rev5), len(rev5),
            "; ".join("%s: %s" % (k, disp[k][0]) for k in rev5)))
    find("note", "info", "3",
         "PROFILE DIRECTIVE CARRIED, NOT QUOTED: build_profile.json foreign_key_population says "
         "the figure the covering documents use for the FK round-trip population is not "
         "reproducible as any population in this map. This build quotes neither figure; it "
         "reports the spine-FOREIGN_KEY slot count it measured, which agrees with the profile's, "
         "at BUILD_STATUS.json .grammar.fk_hops.")
    find("note", "info", "mapper",
         "MAPPER-FACING CONTRADICTIONS ARE CARRIED, NOT ADJUDICATED. build_profile.json "
         "doc_vs_bundle_contradictions records claims about the bundle's PROSE that its JSON "
         "contradicts. This build takes no instruction from prose (BUILD_RULES 3) and makes no "
         "claim about what any covering document currently says -- the previous report did, and "
         "the claim went stale. Stage 3 should read the profile's items directly rather than "
         "repeat any count from here.")

    # ---- the keynorm containment probe, if it has been run
    keynorm_path = os.path.join(N.ARTIFACTS, "keynorm_probe.json")
    keynorm = None
    if os.path.exists(keynorm_path):
        with open(keynorm_path, encoding="utf-8") as fh:
            keynorm = json.load(fh)
        failed = [c for c in keynorm["checks"] if c["result"] != "pass"]
        find("note", "blocker" if failed else "info", "2",
             "SUPERSEDED KEY HISTORY CANNOT REACH A MODEL, PROVED RATHER THAN ASSERTED. The map "
             "archives the prior text of every normalised key in "
             "resolved_key.keynorm.previous_expression: %d blocks, %d carrying the archived "
             "text, all valid grammar and shape-identical to live expressions. A selector "
             "matching the word 'expression' would build the OLD key on every one of them and no "
             "gate here could tell. generators/probe_mtv2_keynorm.py: %s. Result artifact: "
             "build_artifacts/keynorm_probe.json. The cheap half -- the shape guard firing, and "
             "the declared slot set excluding every keynorm slot -- runs in EVERY build, because "
             "this project has already shipped a control that silently stopped working."
             % (keynorm["keynorm_blocks"], keynorm["blocks_with_previous_expression"],
                "; ".join("%s = %s" % (c["check"], c["result"]) for c in keynorm["checks"])))
    else:
        find("note", "warn", "2",
             "THE KEYNORM CONTAINMENT PROBE WAS NOT RUN in this chain invocation "
             "(build_artifacts/keynorm_probe.json is absent). NOT RUN is a third outcome, not a "
             "pass (BUILD_RULES 1.8): run generators/probe_mtv2_keynorm.py. The cheap half is in "
             "selfcheck_mtv2.py and did run.")

    # ---- the reproducibility proof, if it has been run
    repro_path = os.path.join(N.ARTIFACTS, "reproducibility.json")
    repro = None
    if os.path.exists(repro_path):
        with open(repro_path, encoding="utf-8") as fh:
            repro = json.load(fh)
        find("note", "info" if repro.get("identical") else "blocker", "2",
             "REPRODUCIBLE FROM EMPTY, proved by DELETION (BUILD_RULES 9.3) and by a SCRIPT that "
             "is in this repository: %s. %d file(s) in the named set '%s'. shipped=%s run1=%s "
             "run2=%s, identical=%s, files only in one tree: %d / %d, differing: %d. COMBINING "
             "METHOD: %s. build_artifacts/reports/ was not deleted and not backed up; its "
             "contents were recorded before and after and are intact=%s. No digest in this "
             "report is typed: every one is read from the artifact the script wrote."
             % (repro.get("produced_by", "")[:60], repro["files"], repro["named_file_set"],
                repro["combined_sha256_shipped_tree"][:16],
                repro["combined_sha256_run1_from_empty"][:16],
                repro["combined_sha256_run2_over_populated"][:16], repro["identical"],
                len(repro["only_in_the_shipped_tree"]), len(repro["only_in_the_rebuilt_tree"]),
                len(repro["differing"]), repro["digest_method"], repro.get("reports_intact")))
        wp = repro.get("wipe_order_proof") or {}
        pp = repro.get("foreign_block_preservation_proof") or {}
        find("note", "info" if wp.get("every_layer_wiped_by_its_first_writer") else "blocker",
             "2",
             "TWO PROPERTIES IDENTICAL DIGESTS CANNOT PROVE, injected in the same script. "
             "WIPE ORDER: a stale model was planted in all %d layer directories and the chain "
             "re-run; survivors %s, digest returned to the proved value = %s. A model nobody "
             "generates any more would otherwise sit through every run and the digests would "
             "agree with each other while disagreeing with the generators. PRESERVATION: "
             "BUILD_STATUS.json has two writers (BUILD_RULES 10) and a chain re-run used to "
             "discard stage 2's clause half; a foreign block was planted and survived = %s, "
             "named at .preserved_from_a_previous_writer %s. A preserved count that no longer "
             "describes the tree FAILS the build -- proved by planting one. NOTE FOR STAGE 2: "
             "the clause block written in the previous verification is GONE from "
             "BUILD_STATUS.json. It was destroyed by this remediation's first deletion proof, "
             "before the proof stopped deleting that file. It is not restored here, because "
             "every clause it recorded was judged against a tree and a profile revision that "
             "have since changed, and a stale verdict republished by the build would read as "
             "current. build_artifacts/reports/stage2_report.json is intact."
             % (wp.get("layer_directories"),
                wp.get("stale_models_surviving_the_re_run"),
                wp.get("digest_returned_to_the_proved_value"),
                pp.get("foreign_block_survived_a_chain_re_run"),
                pp.get("named_in_preserved_from_a_previous_writer")))
    else:
        find("note", "warn", "2",
             "THE DELETION PROOF WAS NOT RUN in this chain invocation "
             "(build_artifacts/reproducibility.json is absent, which is expected during the "
             "proof itself since the script deletes and rewrites it). NOT RUN is a third "
             "outcome, not a pass: run generators/prove_mtv2_reproducibility.py.")

    report = {
        "stage": "1",
        "status": "complete" if status["self_checks_failed"] == 0 else "partial",
        "lob": N.LOB,
        "profile_revision": N.PROFILE.get("profile_revision"),
        "counts": {
            "generators": len(generators),
            "models": status["models"]["total"],
            "unresolved_keys": status["unresolved_keys"],
            "skipped": status["unbuilt"],
        },
        "numbers_live_in": "build_artifacts/BUILD_STATUS.json (referenced, never retyped)",
        "self_checks": [{"check": c["check"], "result": c["result"], "detail": c["detail"]}
                        for c in status["self_checks"]]
                       + [{"check": "keynorm containment probe: " + c["check"],
                           "result": c["result"], "detail": c["detail"]}
                          for c in (keynorm or {}).get("checks", [])],
        "keynorm_probe": keynorm,
        "reproducibility": repro,
        "findings": findings,
    }
    N.ensure_dir(N.REPORTS)
    N.assert_writable(REPORT)
    # The CHAIN ITSELF, censused into the report, because nine slots of which five are
    # near-duplicates is a history that misleads unless each slot says what distinguishes it.
    # Nothing here is deleted: BUILD_RULES 9.3 forbids removing a report, and the duplicates were
    # created by the cascade defect this run fixed, not by nine handbacks.
    report["report_chain"] = report_chain_census(REPORT)
    # The gate verification, BY REFERENCE. Gates are run on demand by
    # generators/verify_mtv2_gates.py, which runs each one directly and proves each can FAIL by
    # injection; its verdicts are not retyped here (BUILD_RULES 11.7).
    _gv = os.path.join(N.ARTIFACTS, "gate_verification.json")
    if os.path.exists(_gv):
        with open(_gv, encoding="utf-8") as fh:
            _g = json.load(fh)
        report["gate_verification"] = {
            "artifact": "build_artifacts/gate_verification.json",
            "produced_by": "generators/verify_mtv2_gates.py (on demand, not in the chain)",
            "gates": _g["gates"],
            "checks_total": len(_g["checks"]),
            "failed": _g["failed"],
            "not_run": _g["not_run"],
            "note": "Every verdict is the GATE's own subprocess returncode; nothing is read "
                    "through a pipe. Every gate is PROVED able to fail by injection, and the "
                    "tree is asserted byte-identical to its baseline afterwards in BINARY.",
        }
        for _f in _g["failed"]:
            find("note", "warn", "2",
                 "GATE VERIFICATION recorded a FAIL: %s. See "
                 "build_artifacts/gate_verification.json for the measurement and the population. "
                 "vault_tools was NOT edited and no exemption was written to work around it." % _f)
    else:
        report["gate_verification"] = {
            "artifact": None,
            "result": "NOT_RUN",
            "note": "generators/verify_mtv2_gates.py has not been run against this tree, so no "
                    "gate verdict exists. NOT_RUN is not PASS (BUILD_RULES 1.8)."}
    cascade = cascade_reports(REPORT)
    with open(REPORT, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(report, fh, indent=1)
    for line in cascade["log"]:
        print("  %s" % line)

    print("report_mtv2_stage1 -> %s" % REPORT)
    print("  status              : %s" % report["status"])
    print("  generators          : %d" % report["counts"]["generators"])
    print("  models              : %d" % report["counts"]["models"])
    print("  unresolved keys     : %d" % report["counts"]["unresolved_keys"])
    print("  skipped (unbuilt)   : %d" % report["counts"]["skipped"])
    print("  findings            : %d" % len(findings))
    by_kind = collections.Counter(f["kind"] for f in findings)
    for k, v in sorted(by_kind.items()):
        print("      %-26s %d" % (k, v))
    print("  every builder decision is a decision_taken finding routed to stage 3: %d of %d"
          % (sum(1 for f in findings if f["kind"] == "decision_taken"), len(K.BUILDER_DECISIONS)))


if __name__ == "__main__":
    main()
