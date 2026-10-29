# -*- coding: utf-8 -*-
"""mt_keyrules.py -- the key grammar, the spine resolver and the ONE render_key() for
Maximus Travel.

Everything that turns a mapper expression into SQL is here. Nothing downstream parses an
expression; downstream reads the spec (build_mt_spec.py) or calls render_key().

The grammar is a PER-LOB census (BUILD_RULES 4), taken by 00-bundle-evaluator and re-proved
here. This bundle's forms, with the profile's counts:

    spine[FOREIGN_KEY -> V].COL                         863   document-handle cross
    spine[PARENT_KEY_HASH -> V1 -> ... -> Vn].COL      1527   climb (LCA cross in general)
    LNK(leg, leg) positional / LNK(HUB_X = leg) named     51
    md5(normalise(...))  content hash                    128   ADDRESSES
    md5(upper(trim(...))) content hash                    10   NAMES
    '>>' sibling cross operator                            0   ABSENT -- not implemented

'>>' has count ZERO in this bundle. It is not implemented and is not inherited from another LOB.
A form with a count of zero was never tested (BUILD_RULES 4).

Run `python3 mt_keyrules.py` to parse every live expression in the map, print the census,
prove the parser fires on all nine real forms and declines five non-expressions, and print the
parse residue.
"""
import collections
import json
import os
import re
import sys

import mt_names as N

try:
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
except Exception:
    pass

PROFILE = N.PROFILE

# ============================================================================ builder decisions
# BUILD_RULES 11.5 -- a builder decision is ONE LINE to overrule, with what it costs stated
# plainly. This list starts EMPTY on a new LOB: no other LOB's decisions are carried in.
BUILDER_DECISIONS = [
    {
        "id": "BD1-FK-HOP-IS-ONE-JOIN",
        "decision": "spine[FOREIGN_KEY -> V].COL emits ONE join on the document handle "
                    "(v.foreign_key = b.foreign_key), not a per-level climb through the parent "
                    "chain.",
        "why": "The map's own keynorm log shows the mapper COLLAPSED multi-hop PARENT_KEY_HASH "
               "climbs into this one-hop form (class 'chain_to_fkjoin'); expanding it back into "
               "a climb would undo the mapper's normalisation, which the builder does not do "
               "(BUILD_RULES 5.7).",
        "costs": "If FOREIGN_KEY is a file/batch handle rather than a document handle, the join "
                 "fans out and every key built on it is WRONG rather than empty. Open item "
                 "P6-FK-ROUNDTRIP; 863 spine occurrences depend on it and there is no sample "
                 "data in this run. The per-view diagnostic in audit_mt_fk_roundtrip falsifies "
                 "it before any load.",
        "overrule": "set FK_HOP_MODE = 'parent_chain' in mt_keyrules.py",
    },
    {
        "id": "BD2-FK-INTERVENING-CASTS-PROVISIONED",
        "decision": "The cast layer covers every view on the PARENT CHAIN between a hop's start "
                    "and its named destination, including the levels a FOREIGN_KEY hop skips and "
                    "therefore never joins under BD1.",
        "why": "BUILD_RULES 6.1 sizes the cast layer by whether a view is on a walk, and the "
               "profile sizes it the same way (97 destinations-only -> 113 expanded). "
               "Provisioning them also makes BD1 reversible without adding a model.",
        "costs": "A handful of cast models are referenced by no resolver while FK_HOP_MODE is "
                 "'document_handle'. They are counted and named in the build report so they are "
                 "not mistaken for dead models.",
        "overrule": "set CAST_COVERAGE = 'joined_only' in mt_keyrules.py",
    },
    {
        "id": "BD3-PIVOT-PARENT-IS-THE-BASE-NODE",
        "decision": "On a *_PIVOT_VW, PARENT_KEY_HASH is resolved to the view's own BASE NODE "
                    "(the index's parent_table_candidate), and every hop is then expanded through "
                    "that chain.",
        "why": "Open item SPINE-WALK-DISAGREEMENT. 00_tables_index.json is the only physical "
               "statement available -- sample_data_available is false -- and it makes the pivot's "
               "parent its base node. Expanding every hop through the chain makes the two "
               "readings agree for the 697 arrows that NAME the base node; only the first hop of "
               "the others is in question.",
        "costs": "If PARENT_KEY_HASH actually points past the base node, up to 1464 spine slots "
                 "resolve one level short and mint a second population in HUB_RISK_OBJECT / "
                 "HUB_PARTY / HUB_POLICY. audit_mt_spine_variants counts rows reached by each "
                 "variant per (view, join column) so one source answer applies in one pass.",
        "overrule": "set PIVOT_PARENT = 'grandparent' in mt_keyrules.py",
    },
    {
        "id": "BD4-LNK-LEG-CORROBORATION-IS-REPORTED-NOT-FATAL",
        "decision": "A LNK leg is rendered by the SAME render_key() as a hub key, so it is "
                    "byte-identical by construction. Where the leg's expression is ALSO used as a "
                    "standalone hub key on the same view the binding is corroborated; where it is "
                    "not, the leg is still built and the absence is REPORTED.",
        "why": "The profile's mechanism says 'assert every LNK leg string appears verbatim as "
               "some hub resolved_key.expression on that view; raise on any that does not'. "
               "Measured: 62 of 91 legs corroborate, 8 are pure role-code literals (not hub keys "
               "at all), 21 have no on-view hub key to compare against. Raising would drop 21 "
               "real link legs and the loss would read as a source gap -- the exact failure "
               "BUILD_RULES 2 documents.",
        "costs": "21 legs are built on the mapper's word alone. They are listed individually in "
                 "the build report, routed to the mapper.",
        "overrule": "set LNK_LEG_UNCORROBORATED = 'fatal' in mt_keyrules.py",
    },
    {
        "id": "BD5-ROLE-CODE-IS-A-DEGENERATE-LINK-LEG",
        "decision": "LNK_PARTY_ROLE's second leg is a role CODE ('NOMINEE', 'CUSTOMER', ...), not "
                    "a hub key -- data_7.js gives LNK_PARTY_ROLE hubs=['HUB_PARTY']. It is "
                    "carried into the link as a degenerate leg so the link grain is party x role.",
        "why": "Dropping it collapses every role a party plays onto one link row; minting a hub "
               "for it invents a hub the model does not have (BUILD_RULES 7.4).",
        "costs": "The role column in the link table is not a hash key; a consumer joining it to a "
                 "hub finds none. It IS part of the link hash, so the grain is right.",
        "overrule": "set LINK_DEGENERATE_LEG = 'drop' in mt_keyrules.py",
    },
    {
        "id": "BD6-MULTI-ACTIVE-WITHOUT-A-DISCRIMINATOR-IS-SINGLE-ACTIVE",
        "decision": "277 augmentation rows declare multi_active with no child key in either form. "
                    "They are built SINGLE-ACTIVE in the augmented track.",
        "why": "A multi-active satellite with no discriminator IS single-active; inventing a "
               "child key is model invention (BUILD_RULES 7.4). Leaving them unbuilt would lose "
               "277 of 1291 augmentation rows to a naming gap.",
        "costs": "If the rows really are multi-valued per parent, the satellite keeps only the "
                 "last-loaded row per hub key. Every one of the 277 is listed with its proposed "
                 "child-key NAME in the build report, routed to the mapper.",
        "overrule": "set MA_WITHOUT_CDK = 'unbuilt' in mt_keyrules.py",
    },
    {
        "id": "BD7-HASHDIFF-FOLLOWS-THE-SIBLING",
        "decision": "Satellites are written with a BARE HASHDIFF, matching travel_dv_dbt on both "
                    "tracks (45 of 45, counted). The wide stage still needs a unique name per "
                    "satellite, so the rename happens in the satfeed view.",
        "why": "BUILD_RULES 7.2/7.7 make the sibling's contract absolute for a satellite it "
               "already builds, and 12's shared-vault divergence is exactly what HASHDIFF_<SAT> "
               "would re-open here. 27 views feed more than one sibling-built satellite (max 11), "
               "so a bare name cannot come from the wide stage itself.",
        "costs": "One satfeed view per satellite -- a model per satellite that the Maximus house "
                 "pattern does not have. In exchange BUILD_RULES 12 does not apply to this build.",
        "overrule": "set HASHDIFF_POLICY = 'maximus_house' in mt_names.py",
    },
    {
        "id": "BD8-TWO-CONTENT-HASH-CANONICALISATIONS-EMITTED-AS-WRITTEN",
        "decision": "md5(normalise(...)) (128 rows) and md5(upper(trim(...))) (10 rows) are both "
                    "emitted exactly as mapped. They are NOT unified.",
        "why": "They are used on DISJOINT hubs for different kinds of value -- normalise on "
               "HUB_LOCATION (117) and LNK_PARTY_LOCATION (11), all addresses; upper+trim on "
               "HUB_PARTY (2) and LNK_PARTY_ROLE (6) nominee NAMES and HUB_ORG_UNIT (2) branch "
               "NAMES. Verified: zero hubs carry both forms. Unifying them would re-key a hub on "
               "the builder's authority (BUILD_RULES 5.7).",
        "costs": "For a hand-typed nominee name 'AB  CD' and 'AB CD' stay two parties under the "
                 "name form and would be one under normalise. That is a modeller call on a hub "
                 "OPUS also writes, not a build call. Reported, open item "
                 "MD5-TWO-CANONICALISATIONS.",
        "overrule": "set CONTENT_HASH_UNIFY = True in mt_keyrules.py",
    },
    {
        "id": "BD9-DEGENERATE-KEYS-REJECTED-BY-SHAPE-NEVER-BY-CONSTANT",
        "decision": "Every hub and link key is wrapped in a CASE over "
                    "'coalesce(<guarded operands>) is not null', then nullif(trim(...),''). An "
                    "outer nullif(key,'<constant>') is added ONLY where the constant is statically "
                    "computable. No predicate compares a key to a value from "
                    "KEY_DEGENERATE_VALUES.csv.",
        "why": "Under Snowflake semantics every one of the map's 2344 key expressions evaluates "
               "to NULL on an all-blank row -- including the 369 the CSV calls NON-EMPTY "
               "CONSTANT. A predicate key = 'RISK:' can never fire and would read exactly like a "
               "working guard. Third instance of that failure in this engagement.",
        "costs": "None measured. The static-constant branch fires 0 times on this map, and zero "
                 "is reported as zero -- a guard that never fires proves something about this "
                 "map, not about the build.",
        "overrule": "set DEGENERATE_OUTER_NULLIF = False in mt_keyrules.py",
    },
    {
        "id": "BD10-PURE-LITERAL-KEY-IS-CONSTANT-BY-CONSTRUCTION",
        "decision": "A key expression with no non-literal operand at all is ACCEPTED and emitted "
                    "as that literal, counted separately.",
        "why": "KEYING.md 9.5 as amended: constant by construction is not degeneration -- there "
               "is no operand that can go blank. Refusing it would drop rows for being "
               "deterministic.",
        "costs": "Every row on that view keys to one hub row. That is correct for a "
                 "single-population namespace and wrong for anything else; the count is printed "
                 "per hub so it cannot hide.",
        "overrule": "set ACCEPT_CONSTANT_KEY = False in mt_keyrules.py",
    },
    {
        "id": "BD11-ANCHOR-ONLY-ROWS-BIND-TO-THE-MAP-S-OWN-KEY",
        "decision": "190 blocks carry an ANCHOR but no resolved_key at all. They are bound to the "
                    "key slot the MAP ITSELF resolved for that anchor on the SAME VIEW -- by "
                    "instance where the row names one, by the satellite's own placement next, by "
                    "the single candidate next, and by the DOMINANT instance last.",
        "why": "Dropping them is a silence no other check can see: the attribute is never in "
               "coverage's denominator, so coverage reads complete over an attribute that was "
               "never built (BUILD_RULES 8.1). No key is invented -- every slot used was resolved "
               "by the mapper for that anchor on that view.",
        "costs": "The last rule is an assumption. On one view 101 augmentation attributes name "
                 "HUB_PARTY with no instance while the map resolves a proposer key (129 rows), a "
                 "bagic-employee key (2) and a parent-party key (1); they bind to proposer. If "
                 "that is wrong the attribute attaches to the wrong party. Every such binding is "
                 "listed with its vote in the build report, routed to the mapper, and the rows "
                 "are augmentation-track and per-column reversible.",
        "overrule": "set ANCHOR_AMBIGUOUS = 'unbuilt' in mt_keyrules.py",
    },
    {
        "id": "BD12-LINK-LEG-BUILT-AS-MAPPED-DIVERGENCE-MEASURED",
        "decision": "Where a LNK leg's expression differs from the hub key the same view "
                    "resolves for that hub, the leg is built AS MAPPED and the divergence is "
                    "counted at run time by audit_mt_link_leg_divergence.",
        "why": "The directive asks for the hub key to be emitted for the leg 'by construction'. "
               "Doing that silently substitutes one key expression for another, which is "
               "correcting the mapping (BUILD_RULES 5.7). The two that matter are not cosmetic: "
               "on CLAIM_RESERVE the hub key walks FOREIGN_KEY and the leg walks "
               "PARENT_KEY_HASH, so choosing either changes WHICH claim the link attaches to; "
               "and 'EMP:' || BAGIC_RM_ECODE is an orphan leg no hub key anywhere produces.",
        "costs": "7 value-changing legs join to nothing until the mapper rules. That failure is "
                 "silent by nature -- an empty join reads as sparse source data -- so the audit "
                 "model counts legs with no matching hub row per link per view, which makes it "
                 "visible without guessing. 9 further disagreements are whitespace-only and are "
                 "already neutralised: render_key() normalises them to the same SQL.",
        "overrule": "set LINK_LEG_SOURCE = 'hub_key' in mt_keyrules.py",
    },
    {
        "id": "BD13-HUB-DOCUMENT-TWO-KEY-FORMS-BUILT-AS-MAPPED",
        "decision": "Where one source column keys one hub both with a namespace prefix and "
                    "bare, BOTH forms are built exactly as mapped and the split is COUNTED per "
                    "hub per prefix from the map in hand -- never asserted from the profile.",
        "why": "One identifier in two key spaces is two hub rows for one document. Picking one "
               "merges populations the source has not been asked about, and merging is the "
               "unrecoverable direction by the mapper's own rule. No sample data exists to "
               "settle whether they are one population.",
        "costs": "The hub carries two rows for any identifier that appears in both forms. The "
                 "measured split per hub per prefix is in BUILD_STATUS.json .hub_key_forms; a "
                 "zero there is a measured zero, not evidence the check works. One mapper answer "
                 "collapses it.",
        "overrule": "set HUB_DOCUMENT_PREFIX = 'bare' in mt_keyrules.py",
    },
    {
        "id": "BD14-CHILD-KEY-COMPONENT-READER-ACCEPTS-EVERY-DECLARED-SPELLING",
        "decision": "The child_key_components reader accepts ALL leg-name spellings "
                    "{name, leg, component, maps_to} and ALL value spellings "
                    "{value, expression, raw, column, source_column}, in the profile-declared "
                    "order first, and refuses `role` as a name key. Two spellings for one role on "
                    "one element with DIFFERENT values is fatal.",
        "why": "CONV-CKC-SHAPES in CONVENTIONS.json is RATIFIED and says the element shape is not "
               "fixed across runs. The profile records this build's own honouring of it as NO, "
               "and stage 0 routed the choice here: widen the reader, or state in the profile "
               "that it deliberately does not. Widening is the cheaper of the two and it is the "
               "one the declaration asks for.",
        "costs": "NOTHING ON THIS MAP, and that is stated rather than implied: only name, value, "
                 "leg_backing, expression, resolved_on_view, note and one `column` occur, so "
                 "every new branch has ZERO live occurrences and is exercised only by the "
                 "reader's own divergence probe. ck_spelling_census() prints which spellings were "
                 "actually read and which were merely accepted, so the widening can never be "
                 "mistaken for evidence about this bundle. The mapping side has ENDED, so no "
                 "re-issue can ever exercise it either -- it is insurance with no remaining "
                 "policy term, and it is implemented because a reader correct only for the bytes "
                 "in front of it is the defect, not the accident.",
        "overrule": "set CK_LEG_NAME_SPELLINGS = [LEG_NAME_FIELD] (and the two sibling lists) in "
                    "mt_keyrules.py",
    },
    {
        "id": "BD15-LINK-LEG-NAME-READER-SWEEPS-BOTH-SEPARATORS",
        "decision": "A LNK leg's hub name is recognised before EITHER separator, '=' or ':'. The "
                    "census reports which separator named each leg, and every published link-leg "
                    "figure states WHICH QUESTION it answers -- names a hub, binds to a hub, or "
                    "is positional -- beside its population.",
        "why": "MEASURED over 51 LNK( occurrences and 91 legs: 39 legs name a hub, 34 of them "
               "with '=' and 5 with ':'; 52 name no hub. An EQUALS-ONLY reader measures 34 and "
               "57, which is where the figure '34 name a hub, 57 do not' comes from -- it is a "
               "reader defect, not a map fact, and the profile's own grammar_lnk_census declares "
               "9 colon-form call sites that such a reader contradicts. A separate distinct-site "
               "population (30 sites, 57 legs, 23 naming a hub) supplies the SAME two digits from "
               "a third scope, which is how they were transposed onto the 91 denominator.",
        "costs": "None to the build: the shipped parser already accepted both separators, so no "
                 "emitted SQL changes. The cost is to the REPORT -- the published figure moves "
                 "from an instructed 34/57 to a measured 39/52, and every prior figure (4, 34, "
                 "52-as-a-bare-number, 57) is listed with the scope that produced it so the next "
                 "reader can tell which question each answered (BUILD_RULES 11.8).",
        "overrule": "set LNK_LEG_NAME_SEPARATORS = ('=',) in mt_keyrules.py and re-run; the "
                    "census will report 34/57 and say so",
    },
    {
        "id": "BD16-A-PROFILE-FIGURE-IS-CROSS-CHECKED-ON-ITS-LOAD-BEARING-HALF-ONLY",
        "decision": "Where a profile figure is measured over a form this build does not emit, the "
                    "build asserts the load-bearing property and REPORTS the arithmetic rather "
                    "than asserting equality. Applied to longest_source_view_cast_name (41), to "
                    "prose_test_counts.prose_columns_covered (7), and to the collapse-trap scope "
                    "figures (18 / 9 / 20).",
        "why": "An equality assertion against a figure measured over a different population is a "
               "gate that fires on correct data, and a gate that fires on correct data gets "
               "switched off (BUILD_RULES 1.12). 41 is PREFIX+stem and not the emitted model "
               "name, and it is the tied-SECOND longest even in its own form; 7 cannot be "
               "re-derived without reading the entry keys as English, which BUILD_RULES 3 "
               "forbids; the collapse-trap figures differ by SCOPE, not by fact.",
        "costs": "Three profile figures are carried rather than checked, and each says so at the "
                 "point of use with the population beside it. What IS asserted in their place is "
                 "load-bearing: that the abbreviation vocabulary still derives the profile's "
                 "example stem, that every emitted name is inside the budget, that the prose "
                 "entry COUNT and its `kind` split reproduce, and that collapse-trap scope B is a "
                 "subset of scope A.",
        "overrule": "in mt_names._probe() and build_mt_spec.collapse_trap_scope_reconciliation"
                    "(), turn the reported comparison back into an equality check",
    },
]

# ---- the switches the decisions above name. One line each, as promised.
FK_HOP_MODE = "document_handle"          # 'document_handle' | 'parent_chain'      (BD1)
CAST_COVERAGE = "parent_chain"           # 'parent_chain' | 'joined_only'          (BD2)
PIVOT_PARENT = "base_node"               # 'base_node' | 'grandparent'             (BD3)
LNK_LEG_UNCORROBORATED = "report"        # 'report' | 'fatal'                      (BD4)
ANCHOR_AMBIGUOUS = "dominant"            # 'dominant' | 'unbuilt'                   (BD11)
LINK_LEG_SOURCE = "as_mapped"            # 'as_mapped' | 'hub_key'                  (BD12)
HUB_DOCUMENT_PREFIX = "as_mapped"        # 'as_mapped' | 'bare'                     (BD13)
LINK_DEGENERATE_LEG = "carry"            # 'carry' | 'drop'                        (BD5)
LNK_LEG_NAME_SEPARATORS = ("=", ":")     # both; an equals-only reader measures 34/57 (BD15)
MA_WITHOUT_CDK = "single_active"         # 'single_active' | 'unbuilt'             (BD6)
CONTENT_HASH_UNIFY = False               #                                         (BD8)
DEGENERATE_OUTER_NULLIF = True           #                                         (BD9)
ACCEPT_CONSTANT_KEY = True               #                                         (BD10)

# ============================================================================ unresolved ledger
# BUILD_RULES 5.6 -- unresolved keys are REPORTED, never guessed. One place, one count.
UNRESOLVED = []


def unresolved(kind, where, detail, **extra):
    rec = {"kind": kind, "where": where, "detail": detail}
    rec.update(extra)
    UNRESOLVED.append(rec)
    return rec


PARSE_STATS = collections.Counter()

# ============================================================================ the source index
_INDEX = None


def _index():
    global _INDEX
    if _INDEX is None:
        raw = json.loads(N.read_input(N.TABLES_INDEX))
        parent, cols, pivot, depth = {}, {}, {}, {}
        for t in raw["tables"]:
            name = t["table_name"]
            shred = t.get("shred") or {}
            parent[name] = shred.get("parent_table_candidate")
            cols[name] = list(t["column_names"])
            pivot[name] = bool(shred.get("is_pivot"))
            depth[name] = shred.get("shred_depth")
        _INDEX = {"parent": parent, "columns": cols, "pivot": pivot, "depth": depth}
    return _INDEX


def view_exists(view):
    return view in _index()["parent"]


def columns_of(view):
    idx = _index()
    if view not in idx["columns"]:
        raise KeyGrammarError("view %r is not in 00_tables_index.json" % view)
    return idx["columns"][view]


def is_pivot(view):
    return _index()["pivot"].get(view, False)


def parent_of(view):
    """The physical parent PARENT_KEY_HASH climbs to (BD3)."""
    p = _index()["parent"].get(view)
    if PIVOT_PARENT == "grandparent" and is_pivot(view) and p is not None:
        return _index()["parent"].get(p)
    return p


def ancestors(view):
    out, cur, seen = [], parent_of(view), {view}
    while cur is not None:
        if cur in seen:
            raise KeyGrammarError("parent chain of %r is cyclic at %r" % (view, cur))
        seen.add(cur)
        out.append(cur)
        cur = parent_of(cur)
    return out


def all_views():
    return sorted(_index()["parent"])


class KeyGrammarError(Exception):
    pass


# ============================================================================ the walk grammar
# Authored in this file, never through a shell heredoc (BUILD_RULES 1.2). Every one is fired and
# silenced in _probe().
SPINE = re.compile(
    r"spine\[\s*([A-Za-z_][A-Za-z0-9_]*)\s*((?:->\s*[A-Za-z_][A-Za-z0-9_]*\s*)+)\]"
    r"\.([A-Za-z_][A-Za-z0-9_$]*)")
ARROW = re.compile(r"->\s*([A-Za-z_][A-Za-z0-9_]*)")
CROSS_OP = re.compile(r">>")            # count 0 in this bundle; the detector still runs
WALK_TOKEN = re.compile(r"~W(\d+)~")
LNK_HEAD = re.compile(r"\A\s*LNK\s*\(")
LEG_NAME = re.compile(r"\A([A-Za-z][A-Za-z0-9_]*)\s*[:=]\s*(.+)\Z", re.S)
RESIDUE = re.compile(r"spine\[|>>|->|LNK\(")
BRACE_TEMPLATE = re.compile(r"\{[A-Za-z0-9_]+\}")
# A child-key leg `value` that may be synthesised into a quoted literal. Deliberately strict:
# letters, digits, underscore, hyphen, dot, slash and single interior spaces. An angle bracket,
# a brace or a sentence fails it, which is what refuses the one `unresolved` placeholder and
# anything shaped like it in a future re-issue.
RENDERABLE_LEG_VALUE = re.compile(r"[A-Za-z0-9_][A-Za-z0-9_./-]*(?: [A-Za-z0-9_./-]+)*")
PROSE_MARKERS = [
    "spine[", "  ->  ", "(column-as-instance)", "<COLUMN>", "TBD", "None",
    "<not on this view", "COLUMN-AS-INSTANCE",
]

JOIN_COLUMNS = {"PARENT_KEY_HASH", "FOREIGN_KEY"}

KNOWN_FUNCTIONS = {"trim", "nullif", "coalesce", "md5", "normalise", "upper", "lower",
                   "to_char", "to_varchar", "concat"}


class Walk(object):
    """One resolved hop chain from a start view to a column on a relative."""
    __slots__ = ("join_column", "start", "chain", "column", "destination", "relation", "alias")

    def __init__(self, join_column, start, chain, column, relation):
        self.join_column = join_column
        self.start = start
        self.chain = chain                      # ordered list of views actually joined
        self.column = column
        self.destination = chain[-1] if chain else start
        self.relation = relation                # 'self' | 'climb' | 'fk_join' | 'lca_cross'
        self.alias = None

    def key(self):
        return (self.join_column, self.start, tuple(self.chain), self.column)

    def __repr__(self):
        return "Walk(%s, %s -> %s . %s, %s)" % (self.join_column, N.short_view(self.start),
                                                "/".join(N.short_view(c) for c in self.chain),
                                                self.column, self.relation)


def resolve_destination(current, token, where):
    """Resolve a destination token against the START VIEW'S OWN ANCESTOR CHAIN, longest matching
    suffix wins (KEY_FUNCTIONS.md 8.2).

    Resolved GLOBALLY, PARTY_PROPERTY has two real matches and a global lookup silently binds the
    proposer branch to the member branch. 297 of this bundle's destination tokens are
    abbreviated; all 297 resolve uniquely under this scoping.
    """
    if view_exists(token):
        PARSE_STATS["dest_exact"] += 1
        return token
    chain = [current] + ancestors(current)
    cands = [v for v in chain if v == token or v.endswith("_" + token)]
    if not cands:
        # widen ONE step: the destination may be a relative reached through the lowest common
        # ancestor rather than a strict ancestor. Scope stays inside the start view's feed root.
        root = chain[-1]
        cands = [v for v in all_views()
                 if (v == token or v.endswith("_" + token))
                 and (v == root or v.startswith(root + "_"))]
        if len(cands) > 1:
            unresolved("ambiguous_destination", where,
                       "token %r matches %d views on the feed root of %s" % (token, len(cands), current),
                       token=token, candidates=cands)
            raise KeyGrammarError("destination token %r is ambiguous from %s: %s"
                                  % (token, current, cands))
        if not cands:
            unresolved("unresolved_destination", where,
                       "token %r resolves to no view on the ancestor chain of %s" % (token, current),
                       token=token)
            raise KeyGrammarError("destination token %r does not resolve from %s" % (token, current))
        PARSE_STATS["dest_cross_scoped"] += 1
        return cands[0]
    PARSE_STATS["dest_abbreviated"] += 1
    return cands[0]            # nearest on the chain == longest matching prefix


def expand_chain(start, destination, join_column, where):
    """Expand ONE hop into its real per-level chain (BUILD_RULES 4).

    A named destination may skip levels -- 787 arrows in this bundle skip 1 to 4 of them, and the
    intervening views are exactly why the cast layer is bigger than the set of named views. The
    expansion comes from the source index's parent pointer, never from the name.

    The operator is a LOWEST-COMMON-ANCESTOR cross of which the climb is the degenerate case: two
    arrows here reach a SIBLING (PREMIUM_DETAILS -> POLICY_DETAILS) and a climb-only resolver
    returns nothing for them, losing COLLECTED_PREMIUM / OUTSTANDING_PREMIUM as a phantom source
    gap.
    """
    if destination == start:
        return [], "self"
    anc = ancestors(start)
    if join_column == "FOREIGN_KEY" and FK_HOP_MODE == "document_handle":
        PARSE_STATS["fk_hops"] += 1
        if destination not in anc:
            # a SIBLING, not an ancestor: the operator is an LCA cross of which the climb
            # is the degenerate case. Two arrows here reach PREMIUM_DETAILS ->
            # POLICY_DETAILS; a climb-only resolver returns nothing for them and
            # COLLECTED_PREMIUM / OUTSTANDING_PREMIUM then read downstream as a source gap
            # that is not there.
            PARSE_STATS["cross_to_sibling"] += 1
        else:
            depth = anc.index(destination)
            if depth > 0:
                PARSE_STATS["fk_hops_over_named_levels"] += 1
                PARSE_STATS["fk_named_levels_skipped"] += depth
        return [destination], "fk_join"
    if destination in anc:
        chain, cur = [], start
        while cur != destination:
            cur = parent_of(cur)
            if cur is None:
                raise KeyGrammarError("parent chain from %s ran out before %s (%s)"
                                      % (start, destination, where))
            chain.append(cur)
        if len(chain) > 1:
            PARSE_STATS["hops_skipping_levels"] += 1
            PARSE_STATS["levels_expanded"] += len(chain) - 1
        return chain, "climb"
    # LCA cross: up to the lowest common ancestor, then down.
    up = [start] + anc
    down_all = [destination] + ancestors(destination)
    lca = next((v for v in up if v in down_all), None)
    if lca is None:
        unresolved("no_common_ancestor", where,
                   "%s and %s share no ancestor" % (start, destination))
        raise KeyGrammarError("no common ancestor between %s and %s (%s)"
                              % (start, destination, where))
    chain, cur = [], start
    while cur != lca:
        cur = parent_of(cur)
        chain.append(cur)
    descent, cur = [], destination
    while cur != lca:
        descent.append(cur)
        cur = parent_of(cur)
    chain.extend(reversed(descent))
    PARSE_STATS["lca_cross"] += 1
    if len(chain) > 1:
        PARSE_STATS["hops_skipping_levels"] += 1
        PARSE_STATS["levels_expanded"] += len(chain) - 1
    return chain, "lca_cross"


def extract_walks(expression, view, where):
    """Replace every spine[...] span with a ~Wn~ token and return the resolved walks.

    An empty replacement span is FATAL (BUILD_RULES 1.6 / 4.2): str.replace('', x, 1) does not
    raise, it PREPENDS. Every span here is taken by offset from the match, never by replace().
    """
    if CROSS_OP.search(expression):
        unresolved("cross_operator_present", where,
                   "'>>' appears in an expression; the profile's census says count 0 and this "
                   "build does not implement it")
        raise KeyGrammarError("'>>' is not implemented for this LOB (census count 0): %r"
                              % expression)
    walks, out, pos = [], [], 0
    for m in SPINE.finditer(expression):
        if m.start() == m.end():
            raise KeyGrammarError("empty spine span in %r (%s) -- fatal (BUILD_RULES 1.6)"
                                  % (expression, where))
        join_column = m.group(1)
        if join_column not in JOIN_COLUMNS:
            unresolved("unknown_join_column", where, "join column %r" % join_column)
            raise KeyGrammarError("unknown spine join column %r in %r" % (join_column, expression))
        tokens = ARROW.findall(m.group(2))
        if not tokens:
            raise KeyGrammarError("spine span with no destination in %r (%s)" % (expression, where))
        cur, full_chain, relation = view, [], "self"
        for tok in tokens:
            dest = resolve_destination(cur, tok, where)
            seg, rel = expand_chain(cur, dest, join_column, where)
            full_chain.extend(seg)
            if rel != "self":
                relation = rel if relation in ("self",) else (
                    "lca_cross" if "lca_cross" in (relation, rel) else rel)
            cur = dest
            PARSE_STATS["arrow_hops"] += 1
        walk = Walk(join_column, view, full_chain, m.group(3), relation)
        if not full_chain:
            # the chain named the start view itself: the column is ON this view.
            PARSE_STATS["walk_is_on_view"] += 1
        walks.append(walk)
        out.append(expression[pos:m.start()])
        out.append("~W%d~" % (len(walks) - 1))
        pos = m.end()
        PARSE_STATS["spine_occurrences"] += 1
    out.append(expression[pos:])
    return "".join(out), walks


# ============================================================================ the SQL parser
TOKEN = re.compile(r"""
      (?P<ws>\s+)
    | (?P<str>'(?:[^']|'')*')
    | (?P<walk>~W\d+~)
    | (?P<num>\d+(?:\.\d+)?)
    | (?P<concat>\|\|)
    | (?P<name>[A-Za-z_][A-Za-z0-9_$]*)
    | (?P<punct>[(),])
""", re.X)


def tokenize(sql):
    toks, i = [], 0
    while i < len(sql):
        m = TOKEN.match(sql, i)
        if not m:
            raise KeyGrammarError("cannot tokenize at offset %d of %r" % (i, sql))
        kind = m.lastgroup
        if kind != "ws":
            toks.append((kind, m.group(0)))
        i = m.end()
    return toks


class Parser(object):
    """Recursive descent over the restricted key grammar. Raises on anything it does not know --
    an unrecognised call silently read as a column becomes a key made of a function name."""

    def __init__(self, toks, source):
        self.toks, self.i, self.source = toks, 0, source

    def peek(self):
        return self.toks[self.i] if self.i < len(self.toks) else (None, None)

    def take(self, want=None):
        if self.i >= len(self.toks):
            raise KeyGrammarError("unexpected end of expression in %r" % self.source)
        kind, text = self.toks[self.i]
        if want and text != want:
            raise KeyGrammarError("expected %r, found %r in %r" % (want, text, self.source))
        self.i += 1
        return kind, text

    def parse(self):
        node = self.concat()
        if self.i != len(self.toks):
            raise KeyGrammarError("trailing tokens %r in %r"
                                  % (self.toks[self.i:], self.source))
        return node

    def concat(self):
        parts = [self.atom()]
        while self.peek()[0] == "concat":
            self.take()
            parts.append(self.atom())
        return parts[0] if len(parts) == 1 else ("concat", parts)

    def atom(self):
        kind, text = self.peek()
        if kind is None:
            raise KeyGrammarError("expression ends where a value was expected: %r" % self.source)
        if kind == "str":
            self.take()
            return ("lit", text[1:-1].replace("''", "'"))
        if kind == "num":
            self.take()
            return ("lit", text)
        if kind == "walk":
            self.take()
            return ("walk", int(WALK_TOKEN.match(text).group(1)))
        if kind == "punct" and text == "(":
            self.take()
            inner = self.concat()
            self.take(")")
            return ("paren", inner)
        if kind == "name":
            self.take()
            if self.peek() == ("punct", "("):
                if text.lower() not in KNOWN_FUNCTIONS:
                    raise KeyGrammarError("unrecognised function %r in %r" % (text, self.source))
                self.take("(")
                args = []
                if self.peek() != ("punct", ")"):
                    args.append(self.concat())
                    while self.peek() == ("punct", ","):
                        self.take(",")
                        args.append(self.concat())
                self.take(")")
                return ("call", text.lower(), args)
            return ("col", text)
        raise KeyGrammarError("unexpected token %r in %r" % (text, self.source))


def parse_sql(sql):
    return Parser(tokenize(sql), sql).parse()


def split_top_level(text, sep=","):
    """Split on `sep` at depth 0, string-literal aware."""
    out, depth, cur, i, in_str = [], 0, [], 0, False
    while i < len(text):
        c = text[i]
        if in_str:
            cur.append(c)
            if c == "'":
                if i + 1 < len(text) and text[i + 1] == "'":
                    cur.append(text[i + 1])
                    i += 1
                else:
                    in_str = False
        elif c == "'":
            in_str = True
            cur.append(c)
        elif c == "(":
            depth += 1
            cur.append(c)
        elif c == ")":
            depth -= 1
            cur.append(c)
        elif c == sep and depth == 0:
            out.append("".join(cur))
            cur = []
        else:
            cur.append(c)
        i += 1
    out.append("".join(cur))
    return [x.strip() for x in out]


# ============================================================================ normalise()
def normalise_sql(inner):
    """normalise(x) = collapse_internal_whitespace(upper(trim(x))), NULL in NULL out, applied to
    the WHOLE concatenation (KEY_FUNCTIONS.md 5). Defined EXACTLY ONCE for this LOB: two
    definitions mint two hub key spaces for the same address.

    The pattern is a POSIX class and not a backslash escape on purpose -- the fragment ends up
    inside a YAML double-quoted scalar, where YAML eats one layer of backslash and Snowflake eats
    another. mt_names.assert_no_backslash() makes that unrecoverable rather than silent.
    """
    return "upper(regexp_replace(trim(%s), '[[:space:]]+', ' '))" % inner


# ============================================================================ rendering
UNKNOWN = object()           # statically uncomputable, as distinct from SQL NULL (None)


def _static(node):
    """Evaluate the AST with every column and every walk NULL, under ANSI/Snowflake semantics.

    Returns a str (a computable constant), None (SQL NULL) or UNKNOWN. This is the evaluator that
    decides whether an outer nullif is even possible; it is NOT a lookup of
    KEY_DEGENERATE_VALUES.csv, whose 369 'non-empty constant' verdicts cannot be reproduced under
    any consistent semantics and whose values must never become SQL predicates.
    """
    kind = node[0]
    if kind == "lit":
        return node[1]
    if kind in ("col", "walk"):
        return None
    if kind == "paren":
        return _static(node[1])
    if kind == "concat":
        vals = [_static(p) for p in node[1]]
        if any(v is UNKNOWN for v in vals):
            return UNKNOWN
        if any(v is None for v in vals):
            return None                       # NULL || x is NULL
        return "".join(vals)
    fn, args = node[1], node[2]
    vals = [_static(a) for a in args]
    if fn == "coalesce":
        if any(v is UNKNOWN for v in vals):
            return UNKNOWN
        for v in vals:
            if v is not None:
                return v
        return None
    if fn == "nullif":
        if len(vals) != 2:
            return UNKNOWN
        a, b = vals
        if a is UNKNOWN or b is UNKNOWN:
            return UNKNOWN
        if a is None:
            return None
        return None if a == b else a
    if fn in ("trim",):
        v = vals[0]
        return v if v in (None, UNKNOWN) else v.strip()
    if fn in ("upper",):
        v = vals[0]
        return v if v in (None, UNKNOWN) else v.upper()
    if fn in ("lower",):
        v = vals[0]
        return v if v in (None, UNKNOWN) else v.lower()
    if fn in ("to_char", "to_varchar"):
        return vals[0]
    if fn in ("md5", "normalise"):
        v = vals[0]
        return None if v is None else UNKNOWN     # md5(NULL) -> NULL, explicitly
    if fn == "concat":
        if any(v is UNKNOWN for v in vals):
            return UNKNOWN
        if any(v is None for v in vals):
            return None
        return "".join(vals)
    return UNKNOWN


def _operands(node, out):
    """Every non-literal operand, in emission order. A walk and a column are both operands; a
    literal is not -- a literal cannot go blank, which is exactly why BD10 accepts a key made
    only of literals."""
    kind = node[0]
    if kind in ("col", "walk"):
        out.append(node)
    elif kind == "paren":
        _operands(node[1], out)
    elif kind == "concat":
        for p in node[1]:
            _operands(p, out)
    elif kind == "call":
        for a in node[2]:
            _operands(a, out)
    return out


def _render(node, resolve):
    kind = node[0]
    if kind == "lit":
        return "'" + node[1].replace("'", "''") + "'"
    if kind == "col":
        return resolve(("col", node[1]))
    if kind == "walk":
        return resolve(node)
    if kind == "paren":
        return "(%s)" % _render(node[1], resolve)
    if kind == "concat":
        return " || ".join(_render(p, resolve) for p in node[1])
    fn, args = node[1], node[2]
    rendered = [_render(a, resolve) for a in args]
    if fn == "normalise":
        if CONTENT_HASH_UNIFY:
            PARSE_STATS["content_hash_unified"] += 1
        return normalise_sql(rendered[0])
    return "%s(%s)" % (fn, ", ".join(rendered))


def _guarded_operand(node, resolve):
    """Every non-literal operand is guarded nullif(trim(x),''). The map already writes this on
    every operand it reaches; this is the SHAPE test that proves none was missed, and it is what
    the CASE predicate is built from."""
    return "nullif(trim(%s),'')" % _render(node, resolve)


class RenderedKey(object):
    __slots__ = ("sql", "walks", "operands", "degenerate", "shape", "columns", "constant")

    def __init__(self, sql, walks, operands, degenerate, shape, columns, constant=False):
        self.sql, self.walks, self.operands = sql, walks, operands
        self.degenerate, self.shape, self.columns, self.constant = degenerate, shape, columns, constant


def _column_resolver(view, walks, alias_of_walk):
    def resolve(node):
        if node[0] == "walk":
            w = walks[node[1]]
            if not w.chain:                      # the chain named this very view
                return N.cast_alias(w.column)
            return alias_of_walk(w)
        col = node[1]
        if col.upper() in ("KEY_HASH", "PARENT_KEY_HASH", "FOREIGN_KEY", "ROOT_HASH",
                           "RECORD_HASH", "PARENT_RECORD_HASH"):
            return col.lower()
        if col not in columns_of(view):
            raise KeyGrammarError("column %r is not on view %r" % (col, view))
        return N.cast_alias(col)
    return resolve


def content_hash_form(expression):
    """Which of this bundle's TWO content-hash canonicalisations an expression uses.

    They are used on DISJOINT hubs -- normalise on addresses, upper+trim on names -- and are
    emitted as written (BD8). Reported, never unified.
    """
    if "normalise(" in expression:
        return "normalise"
    if re.search(r"md5\(\s*upper\(\s*trim\(", expression):
        return "upper_trim"
    if "md5(" in expression:
        return "md5_other"
    return None


def assert_no_prose(sql, where):
    """BUILD_RULES 3.3 -- prose must never reach generated SQL. Prose is syntactically valid SQL
    and a well-formedness check cannot see meaning, so this is the only thing that can catch it."""
    for marker in PROSE_MARKERS:
        if marker in sql:
            raise KeyGrammarError("PROSE REACHED SQL (%s): %r contains %r" % (where, sql, marker))
    if BRACE_TEMPLATE.search(sql):
        raise KeyGrammarError("PROSE REACHED SQL (%s): %r contains an unexpanded {TEMPLATE}"
                              % (where, sql))
    N.assert_no_backslash(sql, where)
    return sql


def render_key(expression, view, where, kind="hub", alias_of_walk=None):
    """THE central mechanism. Every hub key, link leg and child-key leg in this build goes through
    here, which is what makes a link leg byte-identical to the hub key it references.

    kind='hub'|'link_leg'  -> the whole key becomes NULL when every operand is blank, and the hub
                              feed drops the row and counts the drop.
    kind='child_leg'       -> null-safety is PER OPERAND (BUILD_RULES 5.3). Coalescing the
                              finished composite maps every null-tailed key onto one sentinel and
                              merges precisely the instances the key exists to separate.
    """
    if expression is None or not str(expression).strip():
        raise KeyGrammarError("empty key expression (%s) -- an empty replacement span is fatal "
                              "(BUILD_RULES 1.6)" % where)
    raw = str(expression).strip()
    masked, walks = extract_walks(raw, view, where)
    node = parse_sql(masked)
    if alias_of_walk is None:
        def alias_of_walk(w):
            return w.alias or ("w_" + N.cast_alias(w.column))
    resolve = _column_resolver(view, walks, alias_of_walk)

    body = _render(node, resolve)
    ops = _operands(node, [])
    guarded = []
    for o in ops:
        g = _guarded_operand(o, resolve)
        if g not in guarded:
            guarded.append(g)

    static = _static(node)
    shape = content_hash_form(raw) or "concat"
    columns = sorted({o[1] for o in ops if o[0] == "col"})

    if not guarded:
        if not ACCEPT_CONSTANT_KEY:
            unresolved("constant_key_refused", where, "no non-literal operand in %r" % raw)
            raise KeyGrammarError("key expression has no non-literal operand: %r (%s)"
                                  % (raw, where))
        if static is None or static is UNKNOWN:
            raise KeyGrammarError("key expression has no operand AND no computable value: %r (%s)"
                                  % (raw, where))
        PARSE_STATS["constant_key"] += 1
        return RenderedKey(assert_no_prose(body, where), walks, [], None, "constant",
                           columns, constant=True)

    if kind == "child_leg":
        # per-operand, never on the composite
        sql = body
        for g in guarded:
            sql = sql.replace(g, "coalesce(%s,'')" % g)
        if sql == body and len(guarded) == 1 and guarded[0] not in body:
            sql = "coalesce(%s,'')" % body
        PARSE_STATS["child_leg_rendered"] += 1
        return RenderedKey(assert_no_prose(sql, where), walks, guarded, None, shape, columns)

    guard = "coalesce(%s) is not null" % ", ".join(guarded)
    sql = "nullif(trim(case when %s then %s end),'')" % (guard, body)
    degenerate = None
    if DEGENERATE_OUTER_NULLIF and isinstance(static, str) and static != "":
        degenerate = static
        sql = "nullif(%s,'%s')" % (sql, static.replace("'", "''"))
        PARSE_STATS["outer_nullif_added"] += 1
    PARSE_STATS["key_rendered"] += 1
    PARSE_STATS["shape_" + shape] += 1
    return RenderedKey(assert_no_prose(sql, where), walks, guarded, degenerate, shape, columns)


# ============================================================================ child-key legs
def leg_kind(component):
    """The component's kind, read from the profile's field name -- never a guessed spelling."""
    field = PROFILE["component_kinds_field"]           # 'leg_backing'
    kind = component.get(field)
    if kind is None:
        raise KeyGrammarError("child-key component has no %r field: %r" % (field, component))
    if kind not in PROFILE["component_kinds"]:
        raise KeyGrammarError("unrecognised component kind %r -- the profile censuses %s. Sweep "
                              "the set, never a named member (BUILD_RULES 1.5)."
                              % (kind, sorted(PROFILE["component_kinds"])))
    return kind


# The component field spellings come from the profile, not from memory (BUILD_RULES 2.4). This
# bundle spells them name / value / leg_backing / expression -- a FOURTH spelling against the
# three BUILD_RULES 2 records.
_CK_FIELDS = PROFILE["map_fields"]["target.child_key_components"]
LEG_NAME_FIELD = _CK_FIELDS["leg_name"]
LEG_RENDER_FIELD = _CK_FIELDS["render_note"]
LEG_EXPR_FIELD = _CK_FIELDS["expression"]
LEG_KIND_FIELD = _CK_FIELDS["kind"]

# CONV-CKC-SHAPES, status RATIFIED in CONVENTIONS.json: "element shape is NOT fixed across runs;
# readers must accept ALL leg_name_keys {name, leg, component, maps_to} and ALL value_keys
# {value, expression, raw, column, source_column}; `role` is NOT a name key."
#
# The shipped reader bound ONE spelling per role and accepted no alternate. Harmless on THIS map
# -- only name / value / leg_backing / expression / resolved_on_view / note and one `column`
# occur -- and a live hazard for any re-issue, which is exactly what the declaration exists to
# prevent. Stage 0 routed it here with the choice stated: widen the reader, or say in the profile
# that it does not. IT IS WIDENED. The mapping side has ENDED, so no new bundle can ever exercise
# the new branches; it is implemented anyway, because a reader that is correct only for the bytes
# in front of it is the defect and not the accident.
#
# Order is authoritative: the PROFILE-declared spelling first, then CONVENTIONS' alternates in
# its own order. Two spellings on one element carrying DIFFERENT values is FATAL, not a
# preference -- two fields stating one fact must not diverge (BUILD_RULES 2.2).
CK_LEG_NAME_SPELLINGS = [LEG_NAME_FIELD] + [s for s in ("name", "leg", "component", "maps_to")
                                            if s != LEG_NAME_FIELD]
CK_VALUE_SPELLINGS = [LEG_RENDER_FIELD] + [s for s in ("value", "raw", "column", "source_column")
                                           if s != LEG_RENDER_FIELD]
CK_EXPR_SPELLINGS = [LEG_EXPR_FIELD] + [s for s in ("expression",) if s != LEG_EXPR_FIELD]
CK_NOT_A_NAME_KEY = {"role"}          # CONVENTIONS says so explicitly; reading it would mis-name
CK_SPELLING_HITS = {}                 # spelling -> how many elements this build read it from

for _role, _spellings in (("the leg name", CK_LEG_NAME_SPELLINGS),
                          ("the rendered value", CK_VALUE_SPELLINGS),
                          ("the expression", CK_EXPR_SPELLINGS)):
    _clash = sorted(set(_spellings) & CK_NOT_A_NAME_KEY)
    if _clash:
        raise SystemExit(
            "REFUSING TO BUILD: %s would be read from %s, which CONVENTIONS.json states is NOT a "
            "name key (CONV-CKC-SHAPES)." % (_role, _clash))


def _ck_read(component, spellings, role):
    """Read ONE role from a child-key component under EVERY declared spelling.

    Fatal when two spellings for the same role are present with DIFFERENT values: that is two
    fields stating one fact, and choosing one silently is how a reader invents a child key. Two
    spellings carrying the SAME value is merely redundant, and is allowed.
    """
    present = [(s, component[s]) for s in spellings
               if s in component and component[s] is not None and str(component[s]).strip()]
    if not present:
        return None, None
    distinct = {str(v) for _s, v in present}
    if len(distinct) > 1:
        raise KeyGrammarError(
            "child-key component carries %d DIFFERENT values for %s under declared alternate "
            "spellings %s: %r. Two fields stating one fact must not diverge (BUILD_RULES 2.2, "
            "CONV-CKC-SHAPES)."
            % (len(distinct), role, [s for s, _v in present], dict(present)))
    spelling, value = present[0]
    CK_SPELLING_HITS[spelling] = CK_SPELLING_HITS.get(spelling, 0) + 1
    return value, spelling


def ck_leg_name(component):
    return _ck_read(component, CK_LEG_NAME_SPELLINGS, "the leg name")[0]


def ck_value(component):
    return _ck_read(component, CK_VALUE_SPELLINGS, "the rendered value")[0]


def ck_expression(component):
    return _ck_read(component, CK_EXPR_SPELLINGS, "the expression")[0]


def ck_spelling_census():
    """Which declared spellings this build ACTUALLY read, and which it accepts but never saw.

    A widened reader whose new branches have zero occurrences is insurance, not evidence, and
    saying so is the difference between a proved reader and a hopeful one (BUILD_RULES 9.5).
    """
    declared = sorted(set(CK_LEG_NAME_SPELLINGS + CK_VALUE_SPELLINGS + CK_EXPR_SPELLINGS))
    return {"read_from": dict(sorted(CK_SPELLING_HITS.items())),
            "declared_but_never_occurring": [s for s in declared if s not in CK_SPELLING_HITS],
            "not_a_name_key_refused": sorted(CK_NOT_A_NAME_KEY),
            "note": "CONV-CKC-SHAPES (RATIFIED) requires every alternate to be accepted. The "
                    "branches listed as never occurring are exercised only by the reader's own "
                    "divergence probe, never by a live row; read them as insurance for a "
                    "re-issue that will now never come, never as evidence about this map."}


def render_child_leg(component, view, where, alias_of_walk=None):
    """One child-key leg -> SQL.

    45 of 1119 components carry NO expression at all: a reader that treats `expression` as
    mandatory raises on 45 legitimate legs. Where it is absent the leg is a LITERAL and the
    quoted literal is synthesised from `value` -- which is the declared bespoke behaviour for the
    EAV fan-out, where the literal IS the instance name and there is no column to unpivot from.

    NOTHING here parses child_key_value prose. The rendering-only child keys fell 283 -> 2 in the
    re-issue and the 2 that remain are declared gaps; a branch that parsed them would fire on
    exactly those 2 and write prose into SQL.
    """
    kind = leg_kind(component)
    # HARD SENTINEL, checked BEFORE anything reads `value`. leg_backing='unresolved' means the
    # mapper could not resolve the leg; its `value` is a placeholder, and on the one leg that
    # carries it that placeholder is an already-quoted English sentence. The synthesis rule that
    # is correct for the other 44 expression-less legs would write that sentence into a child
    # key, past every gate, because a quoted string is valid SQL.
    if kind == "unresolved":
        unresolved("child_leg_unresolved_sentinel", where,
                   "leg %r carries leg_backing='unresolved': a placeholder, not a value. Refused "
                   "at build time and reported unbuilt; its `value` is NEVER synthesised into a "
                   "literal." % ck_leg_name(component),
                   satellite_leg=ck_leg_name(component))
        PARSE_STATS["leg_unresolved_sentinel_refused"] += 1
        return None
    expr = ck_expression(component)
    if expr is None or not str(expr).strip():
        value = ck_value(component)
        if value is None or not str(value).strip():
            unresolved("child_leg_no_expression_no_value", where,
                       "leg %r carries neither an expression nor a value"
                       % ck_leg_name(component))
            return None
        text = str(value).strip()
        inner = text[1:-1] if (len(text) > 1 and text.startswith("'")
                               and text.endswith("'")) else text
        # A `value` that is not a RENDERABLE TOKEN is a placeholder whatever its leg_backing
        # says. Testing the value rather than trusting the kind is the whole of BUILD_RULES 3.1:
        # only a bare legal token is accepted, never the header's word for it.
        if not RENDERABLE_LEG_VALUE.fullmatch(inner):
            unresolved("child_leg_value_not_renderable", where,
                       "leg %r has no expression and its value %r is not a renderable token, so "
                       "it is a placeholder. Refused, not synthesised."
                       % (ck_leg_name(component), text), value=text)
            PARSE_STATS["leg_value_not_renderable_refused"] += 1
            return None
        literal = "'" + inner.replace("'", "''") + "'"
        PARSE_STATS["leg_literal_synthesised"] += 1
        return RenderedKey(assert_no_prose(literal, where), [], [], None, "literal", [],
                           constant=True)
    try:
        return render_key(expr, view, where, kind="child_leg", alias_of_walk=alias_of_walk)
    except KeyGrammarError as exc:
        unresolved("child_leg_unrenderable", where, str(exc), expression=str(expr))
        return None


# ============================================================================ link legs
def parse_link(expression, view, where):
    """LNK(...) -> ordered legs. 25 of 51 call sites are POSITIONAL and 11 carry a single leg, so
    leg identity CANNOT be recovered from a name on those (KEY_FUNCTIONS.md 9 says they are all
    named; they are not).

    Each leg is matched by its EXPRESSION against the hub keys resolved on the same view, never
    against a hub NAME -- matching by name picks the wrong instance on a view that keys one hub
    several times (BUILD_RULES 4).
    """
    raw = str(expression).strip()
    if not LNK_HEAD.match(raw):
        raise KeyGrammarError("not a LNK expression: %r" % raw)
    open_paren = raw.index("(")
    if not raw.endswith(")"):
        raise KeyGrammarError("unbalanced LNK(...) in %r (%s)" % (raw, where))
    inner = raw[open_paren + 1:-1]
    legs = []
    for piece in split_top_level(inner, ","):
        if not piece:
            raise KeyGrammarError("empty LNK leg in %r (%s) -- fatal (BUILD_RULES 1.6)"
                                  % (raw, where))
        name, sep = None, None
        m = LEG_NAME.match(piece)
        if m and not piece.lstrip().startswith("'"):
            # WHICH SEPARATOR named this leg, counted. This map uses BOTH -- 34 legs named with
            # '=' and 5 with ':' -- and the profile's own grammar_lnk_census declares both forms
            # (23 '=' call sites and 9 ':' call sites). A reader that accepts only '=' silently
            # drops those 5 and reports "34 of 91 legs name a hub" where the answer over the whole
            # grammar is 39. The set is swept and every member counted, never one named
            # (BUILD_RULES 1.5).
            sep = ":" if m.group(0)[len(m.group(1)):].lstrip()[:1] == ":" else "="
            if sep in LNK_LEG_NAME_SEPARATORS:
                PARSE_STATS["lnk_leg_named_with_" + ("colon" if sep == ":" else "equals")] += 1
                name, piece = m.group(1), m.group(2).strip()
            else:
                # The switch BD15 names, honoured rather than described. Narrowing it to ('=',)
                # reproduces the 34/57 figure and the census then SAYS which separators it swept.
                PARSE_STATS["lnk_leg_name_separator_not_swept"] += 1
                sep = None
        legs.append({"declared_hub": name, "expression": piece, "name_separator": sep})
    if not legs:
        raise KeyGrammarError("LNK with no legs in %r (%s)" % (raw, where))
    PARSE_STATS["lnk_call_sites"] += 1
    PARSE_STATS["lnk_legs"] += len(legs)
    PARSE_STATS["lnk_named_legs"] += sum(1 for l in legs if l["declared_hub"])
    return legs


def normalise_for_match(sql):
    """Whitespace-insensitive OUTSIDE string literals. Two renderings of one key that differ only
    in a space after a comma are the SAME key, and treating them as different would report 45
    false divergences."""
    out, in_str, i = [], False, 0
    while i < len(sql):
        c = sql[i]
        if in_str:
            out.append(c)
            if c == "'":
                if i + 1 < len(sql) and sql[i + 1] == "'":
                    out.append(sql[i + 1])
                    i += 1
                else:
                    in_str = False
        elif c == "'":
            in_str = True
            out.append(c)
        elif not c.isspace():
            out.append(c)
        i += 1
    return "".join(out)


def is_pure_literal(expression):
    return bool(re.fullmatch(r"'(?:[^']|'')*'", str(expression).strip()))


# ============================================================================ ordinals
# BUILD_RULES 5.2 -- check EVERY spelling of an excluded column. This bundle has SEVEN; the
# previous profile found six. The class is swept, the tokens are not named one at a time.
# The set is re-derived BY SHAPE from the 00_tables_index.json column population and then
# RECONCILED with the profile's list. A check that looks for a NAME SHAPE this build happens to
# use is the defect stage 2 recorded against its own first ordinal check: it looked for a child
# key spelled *_CK, a spelling this build does not use, so it could not fire. Shape first, names
# never.
ORDINAL_HEAD = {"SERIAL", "SRL", "SR", "SEQ", "SEQUENCE"}
ORDINAL_TAIL = {"NO", "NUM", "NUMBER"}


def is_ordinal_shaped(name):
    """True where `name` is a per-parent RENUMBERING ORDINAL by its shape alone.

    Shape: a final segment SEQ/SEQUENCE, or a final NO/NUM/NUMBER whose preceding segment is one
    of SERIAL/SRL/SR/SEQ/SEQUENCE. BILL_NO and TRIP_NO are therefore NOT ordinals by shape --
    which is the same verdict the profile reaches by MEANING, and that agreement is asserted
    below rather than assumed.
    """
    segs = str(name).upper().replace("-", "_").split("_")
    if not segs or not segs[-1]:
        return False
    if segs[-1] in ("SEQ", "SEQUENCE"):
        return True
    return len(segs) >= 2 and segs[-1] in ORDINAL_TAIL and segs[-2] in ORDINAL_HEAD


def ordinal_spellings_in_the_source():
    """Every distinct source column in the index whose SHAPE is a renumbering ordinal."""
    out = set()
    for v in all_views():
        for c in columns_of(v):
            if is_ordinal_shaped(c):
                out.add(str(c).upper())
    return out


RENUMBERING_ORDINALS = ordinal_spellings_in_the_source()
_DECLARED_ORDINALS = {str(_e).split(" ")[0].strip().upper()
                      for _e in PROFILE["renumbering_ordinals"]}
if RENUMBERING_ORDINALS != _DECLARED_ORDINALS:
    raise SystemExit(
        "REFUSING TO BUILD: the renumbering-ordinal CLASS re-derived by shape from "
        "00_tables_index.json does not match build_profile.json.\n"
        "  only in the source : %s\n  only in the profile: %s\n"
        "An ordinal spelling nobody swept reaches a key exactly as SERIAL_NO does "
        "(BUILD_RULES 5.2, 1.5)."
        % (sorted(RENUMBERING_ORDINALS - _DECLARED_ORDINALS),
           sorted(_DECLARED_ORDINALS - RENUMBERING_ORDINALS)))
for _declined in PROFILE["ordinal_shaped_names_not_classified_as_ordinals"]:
    if is_ordinal_shaped(_declined):
        raise SystemExit(
            "REFUSING TO BUILD: %r is declined as an ordinal by the profile on MEANING, but this "
            "build's SHAPE rule classifies it as one. Two rules disagreeing about what "
            "discriminates a row is a mapper question, not a builder default (BUILD_RULES 5.2)."
            % _declined)
# The rev-3 profile splits this census in two: ZERO ordinals now reach a resolved_key
# expression, and SERIAL_NO reaches 11 CHILD-KEY LEGS. Both spellings are consumed; reading only
# the first would report the ordinal hazard as closed when it is not.
ORDINALS_REACHING_A_KEY = dict(PROFILE["renumbering_ordinals_reaching_a_key"])
ORDINALS_REACHING_A_CHILD_KEY_LEG = dict(
    PROFILE["renumbering_ordinals_reaching_a_child_key_leg"])


def ordinal_legs(columns):
    """Which of `columns` are renumbering ordinals under ANY of the seven spellings."""
    return sorted(c for c in columns if c.upper() in RENUMBERING_ORDINALS)


# ============================================================================ collapse traps
COLLAPSE_TRAPS = set(PROFILE["collapse_traps"])


def is_collapse_trap(satellite, leg_name):
    return "%s.%s" % (satellite, leg_name) in COLLAPSE_TRAPS


COLLAPSE_TRAP_WARNINGS = []


def assert_not_only_traps(satellite, leg_names, where, constant_legs=None):
    """BUILD_RULES 5.1/5.2 and 10 clause 9: no child key may be composed of legs that cannot
    discriminate.

    The profile's trap list is 20 (satellite, leg) pairs that render to ONE value across the map.
    Those are NOT one population. A leg rendered `'GH_TYPE_OF_USER'` is a literal with no operand
    and can never discriminate anything. A leg rendered `nullif(trim(SUBLIMIT_NAME),'')` renders
    to one EXPRESSION because one view carries it, and will discriminate per row the moment data
    arrives -- the profile calls that "a weaker signal" itself.

    Refusing on both took the refusals from 2 to 13 and would have withheld 11 satellites whose
    child key is a real column. So: REFUSE only where every leg is a literal constant with no
    operand; WARN, and build, where the leg is column-backed (BUILD_RULES 11.8).
    """
    if not leg_names:
        return
    constant_legs = constant_legs or {}
    traps = [n for n in leg_names if is_collapse_trap(satellite, n)]
    if not traps or len(traps) != len(leg_names):
        return
    no_operand = [n for n in traps if constant_legs.get(n)]
    if len(no_operand) == len(leg_names):
        unresolved("collapse_trap_only", where,
                   "%s child key is composed ONLY of literal legs with no operand (%s): it "
                   "cannot discriminate anything and would collapse every instance onto one row"
                   % (satellite, traps), satellite=satellite, legs=traps)
        raise KeyGrammarError("%s: child key composed only of no-operand constant legs %s (%s)"
                              % (satellite, traps, where))
    COLLAPSE_TRAP_WARNINGS.append({
        "satellite": satellite, "legs": traps,
        "class": "column_backed_currently_single_valued",
        "why": "every leg of this child key is on the profile's 20-trap list, but each is backed "
               "by a source COLUMN and renders to one value only because one view carries the "
               "leg. BUILT: the leg discriminates per row at load time. Reported so the weaker "
               "signal is visible without withholding the satellite."})
    PARSE_STATS["collapse_trap_warned_not_refused"] += 1


# ============================================================================ self-proof
def _probe():
    """BUILD_RULES 1.1 -- every pattern proved to FIRE on a constructed probe and to stay SILENT
    on a known-good input, BEFORE any zero from it is trusted."""
    checks = []

    _pattern_names = set(N.compiled_patterns(sys.modules[__name__]))

    def ck(name, ok, detail):
        covered = next((p for p in sorted(_pattern_names, key=len, reverse=True) if p in name),
                       None)
        checks.append({"check": name, "result": "pass" if ok else "fail", "detail": detail,
                       "pattern": covered})

    e = ("coalesce(nullif(trim(CLAIMNO),''), nullif(trim(spine[FOREIGN_KEY -> "
         "NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS].CLAIMNO),''))")
    m = SPINE.search(e)
    ck("SPINE fires and declines",
       bool(m) and m.group(1) == "FOREIGN_KEY" and m.group(3) == "CLAIMNO"
       and not SPINE.search("coalesce(nullif(trim(CLAIMNO),''), nullif(trim(FOREIGN_KEY),''))"),
       "recovers (FOREIGN_KEY, CLAIMNO) from a real expression; returns None on a spine-free one")
    ck("CROSS_OP fires and declines",
       bool(CROSS_OP.search("A >> B")) and not CROSS_OP.search("A > B"),
       "fires on '>>', silent on '>' -- the census says count 0, so the detector must be able "
       "to fail")
    ck("BRACE_TEMPLATE fires and declines",
       bool(BRACE_TEMPLATE.search("'{POL_RISK_ID}#RISK_LOAD_TYPE'"))
       and not BRACE_TEMPLATE.search("nullif(trim(POL_RISK_ID),'')"),
       "fires on a {TEMPLATE} literal, silent on real SQL")
    ck("RESIDUE fires and declines",
       bool(RESIDUE.search("spine[A -> B].C")) and not RESIDUE.search("nullif(trim(X),'')"),
       "the residue detector can fail")
    ck("LEG_NAME fires and declines",
       bool(LEG_NAME.match("HUB_PARTY = nullif(trim(X),'')"))
       and not LEG_NAME.match("nullif(trim(X),'')"),
       "recovers a named LNK leg; declines a positional one")
    ck("WALK_TOKEN", bool(WALK_TOKEN.match("~W12~")) and not WALK_TOKEN.match("W12"),
       "matches the sentinel, declines a bare name")
    ck("RENDERABLE_LEG_VALUE fires and declines",
       bool(RENDERABLE_LEG_VALUE.fullmatch("AADHAAR_ENROLMENT"))
       and bool(RENDERABLE_LEG_VALUE.fullmatch("BANK DETAILS SUPPORTING DOCUMENT"))
       and not RENDERABLE_LEG_VALUE.fullmatch(
           "<not on this view - no media / document identifier on this view>"),
       "accepts a real leg value and a spaced code; REFUSES the one unresolved leg's "
       "placeholder sentence")

    # The ordinal SHAPE rule, proved on REAL rows of 00_tables_index.json -- never on a
    # hand-typed example, which proves only that the author can type the pattern back.
    _all_cols = sorted({c.upper() for v in all_views() for c in columns_of(v)})
    _fire = [c for c in _all_cols if is_ordinal_shaped(c)]
    _silent = [c for c in _all_cols if not is_ordinal_shaped(c)]
    ck("ordinal SHAPE rule fires on real source columns",
       len(_fire) == len(RENUMBERING_ORDINALS) and bool(_fire),
       "fires on %d of the %d distinct source columns in the index (%s); silent on the other "
       "%d, including the look-alikes %s" % (
           len(_fire), len(_all_cols), ", ".join(_fire), len(_silent),
           ", ".join(c for c in ("BILL_NO", "TRIP_NO") if c in _silent)))
    ck("the ordinal class agrees with the profile, re-derived not read",
       set(_fire) == _DECLARED_ORDINALS,
       "shape over the index and build_profile.json name the SAME %d spelling(s); a disagreement "
       "stops the build" % len(_DECLARED_ORDINALS))

    # parser: nine positive forms
    positives = [
        "nullif(trim(POLICY_NUMBER),'')",
        "coalesce(nullif(trim(CLAIMNO),''), nullif(trim(FOREIGN_KEY),''))",
        "'RISK:' || nullif(trim(POL_RISK_ID),'')",
        "md5(normalise(nullif(trim(coalesce(nullif(trim(ADDR1),''),'') || '#' || "
        "coalesce(nullif(trim(CITY_CODE),''),'')), '#')))",
        "'NOMINEE:' || md5(upper(trim(nullif(trim(NOMINEE_NAME),''))))",
        "nullif(trim(~W0~),'')",
        "'1'",
        "coalesce(nullif(trim(A),''),'') || '|' || coalesce(nullif(trim(B),''),'')",
        "nullif(coalesce(nullif(trim(A),''),'') || '|' || coalesce(nullif(trim(B),''),''), '|')",
    ]
    parsed = 0
    for p in positives:
        try:
            parse_sql(p)
            parsed += 1
        except KeyGrammarError:
            pass
    ck("parser fires on all 9 real forms", parsed == 9, "%d of 9 parsed" % parsed)

    negatives = [
        "this is a sentence about the claim number",
        "nullif(trim(X),''",
        "A >> B",
        "{POL_RISK_ID}#COVER_CODE",
        "",
        "unknown_function(X)",
    ]
    declined = 0
    for n in negatives:
        try:
            parse_sql(n)
        except (KeyGrammarError, Exception):
            declined += 1
    ck("parser declines all 6 non-expressions", declined == 6, "%d of 6 declined" % declined)

    # the static evaluator, which is what BD9 rests on
    cases = [
        ("'RISK:' || nullif(trim(POL_RISK_ID),'')", None),
        ("'RISK:' || coalesce(nullif(trim(A),''),'')", "RISK:"),
        ("'1'", "1"),
        ("nullif(coalesce(nullif(trim(A),''),'') || '#' || coalesce(nullif(trim(B),''),''), '#')",
         None),
    ]
    okc = 0
    for expr, want in cases:
        got = _static(parse_sql(expr))
        okc += (got == want)
    ck("static evaluator: NULL||x is NULL, coalesce-to-empty concatenates, an applied nullif "
       "fires", okc == len(cases), "%d of %d cases" % (okc, len(cases)))

    # assert_no_prose must fire
    fired = False
    try:
        assert_no_prose("'(COLUMN-AS-INSTANCE) -> SGST'", "probe")
    except KeyGrammarError:
        fired = True
    silent = assert_no_prose("nullif(trim(policy_number),'')", "probe") is not None
    ck("assert_no_prose fires and stays silent", fired and silent,
       "raises on a mapper-notation literal; passes real SQL")

    # ---- the four patterns that had no probe. Subjects are taken from the LIVE MAP wherever the
    # corpus carries one, never typed (BUILD_RULES 1.13).
    _live = None
    for _row in json.loads(N.read_input(N.MAP_PATH))[N.MAP_ROW_CONTAINER]:
        for _blk in ("target", "augmentation"):
            _b = _row.get(_blk)
            if not isinstance(_b, dict):
                continue
            _ex = (_b.get("resolved_key") or {}).get("expression")
            if isinstance(_ex, str) and "->" in _ex:
                _live = _ex
                break
        if _live:
            break
    ck("ARROW fires and declines",
       bool(_live) and bool(ARROW.search(_live))
       and not ARROW.search("coalesce(nullif(trim(CLAIMNO),''),'')"),
       "fires on a real corpus expression carrying a spine arrow (%s...); silent on an "
       "arrow-free real expression" % (str(_live)[:56]))

    _lnk = None
    for _row in json.loads(N.read_input(N.MAP_PATH))[N.MAP_ROW_CONTAINER]:
        for _blk in ("target", "augmentation"):
            _b = _row.get(_blk)
            if not isinstance(_b, dict):
                continue
            _ex = (_b.get("resolved_key") or {}).get("expression")
            if isinstance(_ex, str) and LNK_HEAD.match(_ex):
                _lnk = _ex
                break
        if _lnk:
            break
    ck("LNK_HEAD fires and declines",
       bool(_lnk) and not LNK_HEAD.match("nullif(trim(LNK_CODE),'')"),
       "fires on a real LNK( call site from the map; silent on an expression whose first "
       "identifier merely BEGINS with LNK -- which is the whole point of anchoring it")

    ck("WALK_TOKEN fires and declines",
       bool(WALK_TOKEN.search("nullif(trim(~W0~.PARTY_CODE),'')"))
       and not WALK_TOKEN.search("nullif(trim(W0_PARTY_CODE),''"),
       "fires on the internal walk placeholder; silent on the EMITTED alias W0_ -- the two are "
       "deliberately different strings, and a pattern matching both would rewrite emitted SQL")

    _toks = [m.lastgroup for m in TOKEN.finditer("md5(nullif(trim(A),'') || '|' || 1.5)")]
    ck("TOKEN fires and declines",
       set(_toks) >= {"name", "punct", "str", "concat", "num"} and None not in _toks,
       "the lexer classifies every part of a real key fragment -- %s -- and leaves no span "
       "unclassified; an unclassified span is how a fragment silently loses a guard"
       % sorted(set(_toks)))

    _n = N.assert_pattern_coverage(sys.modules[__name__],
                                   [c["pattern"] for c in checks if c.get("pattern")],
                                   "mt_keyrules.py")
    checks.append({"check": "pattern coverage is TOTAL in mt_keyrules.py", "result": "pass",
                   "detail": "%d module-level pattern(s), every one probed for a fire AND a "
                             "silence, and every compiled pattern asserted free of control bytes "
                             "(BUILD_RULES 1.1, 1.2)." % _n, "pattern": None})
    return checks


def census():
    """Parse every live expression in the map and report. Parse residue must be ZERO and the
    count printed (BUILD_RULES 4.1 / 10 clause 6)."""
    raw = json.loads(N.read_input(N.MAP_PATH))
    rows = raw[N.MAP_ROW_CONTAINER]
    mf = PROFILE["map_fields"]
    stats = collections.Counter()
    failures, residue = [], []
    for i, row in enumerate(rows):
        view = row[mf["row"]["table"]]
        for blk in ("target", "augmentation"):
            body = row.get(blk)
            if not body:
                continue
            rk = body.get("resolved_key") or {}
            candidates = []
            if rk.get(mf["target.resolved_key"]["expression"]):
                candidates.append(("%s.resolved_key" % blk,
                                   rk[mf["target.resolved_key"]["expression"]]))
            for j, comp in enumerate(body.get("child_key_components") or []):
                if comp.get(LEG_EXPR_FIELD):
                    candidates.append(("%s.child_key_components[%d]" % (blk, j),
                                       comp[LEG_EXPR_FIELD]))
            for where, expr in candidates:
                stats["expressions"] += 1
                w = "row %d %s %s" % (i, view, where)
                try:
                    if LNK_HEAD.match(str(expr)):
                        legs = parse_link(expr, view, w)
                        for leg in legs:
                            masked, _ = extract_walks(leg["expression"], view, w)
                            parse_sql(masked)
                            if RESIDUE.search(masked):
                                residue.append((w, masked))
                        stats["lnk"] += 1
                    else:
                        masked, _ = extract_walks(str(expr), view, w)
                        parse_sql(masked)
                        if RESIDUE.search(masked):
                            residue.append((w, masked))
                except Exception as exc:
                    failures.append((w, str(expr)[:160], str(exc)))
    return stats, failures, residue


def main():
    print("mt_keyrules.py -- Maximus Travel key grammar")
    fails = 0
    for c in _probe():
        print("  [%s] %s -- %s" % (c["result"].upper(), c["check"], c["detail"]))
        fails += c["result"] == "fail"
    if fails:
        raise SystemExit("mt_keyrules.py: %d self-check(s) FAILED" % fails)

    stats, failures, residue = census()
    print("\n  live expressions parsed : %d" % stats["expressions"])
    print("  LNK call sites          : %d" % stats["lnk"])
    print("  parse failures          : %d" % len(failures))
    print("  PARSE RESIDUE           : %d" % len(residue))
    for w, e, x in failures[:10]:
        print("      FAIL %s : %s\n           %s" % (w, e, x))
    for w, e in residue[:10]:
        print("      RESIDUE %s : %s" % (w, e))
    print("\n  grammar counters:")
    for k in sorted(PARSE_STATS):
        print("    %-28s %d" % (k, PARSE_STATS[k]))
    print("\n  unresolved (reported, never guessed): %d" % len(UNRESOLVED))
    for u in UNRESOLVED[:10]:
        print("    %s | %s" % (u["kind"], u["detail"][:120]))
    print("\n  builder decisions on record: %d" % len(BUILDER_DECISIONS))
    for d in BUILDER_DECISIONS:
        print("    %-38s overrule: %s" % (d["id"], d["overrule"]))
    if failures or residue:
        raise SystemExit("mt_keyrules.py: grammar did not fully parse")


if __name__ == "__main__":
    main()
