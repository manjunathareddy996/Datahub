# Builder handback — Maximus Travel

**Bundle:** `../SourceMapping_Skill/maximus travel mapping v2/outputs/`, read-only (`BUILD_RULES.md` §9).
**Map:** `04_column_map.json`, sha256 `bdb1f3fe…224e`. Verified unmoved before stage 1 and again after
stage 2 — see `build_artifacts/reports/stage2_report.json` `map_sha256_before` / `map_sha256_after`.
**Profile:** `build_profile.json` rev 5.

## Headline

Every number in this document is a path into `build_artifacts/BUILD_STATUS.json` or into a named
report, taken by reference and never retyped (`BUILD_RULES.md` §1.9, §11.7).

**This build is not done.** `.done` is `false`. Of the `BUILD_RULES.md` §10 clauses at `.clauses`,
three read `fail`: clause 1, clause 9 and clause 10. The rest read `pass`. That is the status —
not "substantially complete".

* **Clause 1** fails on `check_vault_alignment` check 1. Most of its findings are a defect in the
  shared gate, not in this build. See *For `vault_tools`* below and `.clauses.1.detail`.
* **Clause 9** fails on measurement, and the number is not zero. See *For the MODELLER* and
  `.clauses.9`.
* **Clause 10** fails for want of this document (`.clauses.10.evidence`). Writing it closes it.
  Clauses 1 and 9 are unaffected by it and remain open.

The model tree itself is verified: `.self_checks_failed` is the count of failed self-checks and
`.status` is the verifier's verdict over them.

## Does anything here block?

**Yes — one thing, and it is not addressed to the mapper.**

1. **MODELLER, before any load:** clause 9. A renumbering ordinal is carrying a child key, and
   collapse-trap legs reach an emitted `src_cdk`. Item **D1** below.

Everything else in this document is a warn or an information item. Nothing else here blocks a
load, a re-run, or the mapper's next re-issue. The `vault_tools` item **V1** is a blocker against
*the gate*, not against this build: no model changes when it is fixed.

## What was built

Counts in this section are paths into `build_artifacts/BUILD_STATUS.json`, taken from there by reference.

| layer | models |
|---|---|
| `staging/maximus_travel` (layer-1 casts + walk-only casts) | `.counts.by_layer` |
| `automate_dv/standard/resolvers` | `.counts.by_layer` |
| `automate_dv/standard/unpivot` | `.counts.by_layer` |
| `automate_dv/standard/staging` (wide stage) | `.counts.by_layer` |
| `automate_dv/standard/hubfeed` and `.../hubs` | `.counts.by_layer` |
| `automate_dv/standard/links` | `.counts.by_layer` |
| `automate_dv/standard/satfeed` and `.../satellites` | `.counts.by_layer` |
| `automate_dv/standard/audit` | `.counts.by_layer` |
| `automate_dv/augmented/staging`, `.../satfeed`, `.../satellites` | `.counts.by_layer` |
| **total** | `.counts.models` |

Satellites: `.counts.satellites_built` in total, of which `.counts.satellites_targeted_built` are
canonical satellites the map targets; `.counts.satellites_targeted_unbuilt` are targeted and not
built, each with a recorded reason in `vault_tools/accepted_uncovered.txt` and in
`build_artifacts/mt_spec.json`.

Coverage: `.counts.coverage_reached` of `.counts.coverage_total`, with `.counts.exemptions`
sanctioned exemptions split by class at `.coverage.by_class`. Reproducibility is proved by deletion
over `.counts.files_in_the_reproducibility_set` files; the digests and the combining method are in
`build_artifacts/reproducibility.json`.

---

## For `vault_tools` — this is mine, not the mapper's, and it changes what a green gate means

Every count named here is a path into `build_artifacts/BUILD_STATUS.json` or into
`build_artifacts/reports/stage2_report.json`, taken from there by reference.

### V1 — `check_vault_alignment` check 1 compares against `src_payload` alone (blocker, against the gate)

**The question:** should check 1 test membership of `src_payload` **union** `src_cdk`, rather than
`src_payload` alone?

**What the build does meanwhile:** clause 1 stays red, and the affected columns stay in
`accepted_uncovered.txt` as class `carried_as_cdk` (`.coverage.by_class.carried_as_cdk`).

The canonical rendering **is** present in the model for all but one of check 1's findings — as the
satellite's `src_cdk`. Corroborated four ways, none of them the argument stage 1 used:

* every one of them is an `automate_dv.ma_sat`, which materialises `src_cdk` into the target table;
* every one has a live, non-cast-null feeder aliasing the column;
* the map itself declares each as a `child_key_components` leg;
* **the sibling itself** writes `IDENTIFICATION_TYPE_CODE` as `src_cdk` on
  `SAT_PARTY_IDENTIFICATION`.

Settled by injection rather than argued: adding the column to `src_payload` on a scratch copy of
`models/` **drops check 1 by one and simultaneously creates a `BUILD_RULES.md` §5.4 payload /
child-key clash** where there was none. *The gate as written asks for a defect.* Detail at
`.clauses.1.detail` and in the stage-2 self-check on this diagnosis.

**Say this plainly:** until check 1 compares the union, most of this project's coverage exemptions
(`.coverage.by_class.carried_as_cdk` of `.counts.exemptions`) are papering over a **gate** defect
rather than a **mapping** gap. An exemption that hides a gate bug is worse than a red check: the red
check argues for itself, the exemption argues for silence. The fix was **not** made here — a shared
gate is not edited while builds are reading it.

### V2 — coverage check 6 is blind to the augmentation container (warn)

**The question:** should the augmentation track be in check 6's denominator, or explicitly out of
scope by declaration?

**What the build does meanwhile:** `.counts.augmentation_rows_invisible_to_coverage` map rows carry
`augmentation.proposed_attribute` and none populates `target.attribute`, so none is counted **and**
none is exempted. Second LOB to raise this; promotion trigger on the third.

### V3 — the shared `accepted_uncovered.txt` has no per-project integrity guard (warn)

**The question:** will `vault_tools` take a per-project section digest?

**What the build does meanwhile:** `gen_mt_exemptions.py` deliberately does not write the shared
file; it writes `build_artifacts/accepted_uncovered.mt.txt` and `selfcheck_mt.py` asserts the
shared file carries those lines. See the limit **X1** below for what this build therefore cannot
certify.

### V4 — the shared exemption file cannot tell a dead exemption from a live one (warn)

Measured against `build_artifacts/BUILD_STATUS.json` and this build's own emitted models, by reference.

`vault_tools/accepted_uncovered.txt` is shared by three projects. `.counts.exemptions` of its entries
belong to this build, and every one of them was resolved against this project's emitted satellites:

* **none is stale** — no exempted column is present in this build's built payload;
* `.coverage.by_class.satellite_not_built` of them name a satellite that is **not present in the
  emitted models**. Those are the ones worth a look: an exemption for a satellite that does not
  exist is indistinguishable from one that is doing work;
* the rest are live — the column is genuinely absent, and the line is suppressing a real gap.

**`maximus_health_v2_dv_dbt`'s entries were NOT EXAMINED.** That project's models were being
regenerated while this handback was written, so any read of its tree would have been torn and a
number taken from it would have been worthless. **Not-examined is a third outcome and must not be
read as either clean or stale** (`BUILD_RULES.md` §1.8). An earlier draft of this document carried a
staleness claim about that project; it was a **file-wide** count spanning three projects, relayed as
one project's, it does not reproduce on the project where it can be tested, and it is **withdrawn**.

**The property stands on its own, with no count behind it at all:** a dead exemption is
indistinguishable from a live one, and it silently pre-authorises a silence nobody chose
(`BUILD_RULES.md` §1.19 — a probe has a lifetime). That is why the shared file deserves a periodic
check, and it is the same reason item **V3** asks for a per-project section digest.

### V5 — `check_patterns.py` reads the first argument of `.search()` / `.match()` as a pattern (warn)

That is right for a pattern and wrong for a **subject**. It reported two probe subjects in
`mt_names.py` as uncompilable regexes. This build restructured its probes rather than weaken a
shared gate, so the gate passes here — but the blind spot is real and will fire on any project that
probes a pattern with a literal subject.

### V6 — promotion candidate: prose detection in emitted models (info)

`BUILD_RULES.md` §3 asks for it and no shared gate implements it. Travel and health each assert it
privately; this verification implemented it a **third** time, ad hoc. Three independent
implementations is the promotion trigger. It belongs in `check_patterns.py` or a new shared check.

---

## For the MODELLER

Counts here are paths into `build_artifacts/BUILD_STATUS.json`, taken from there by reference.

### D1 — clause 9: a renumbering ordinal is carrying a child key (BLOCKING before any load)

**The question:** `SAT_AUG_POLICY_DOCUMENT_DISPATCH.src_cdk` is `DISPATCH_SERIAL_NUMBER`, defined
from `SERIAL_NO` on `uwr_pol_disp`. `BUILD_RULES.md` §5.2 — an ordinal is never a discriminator, and
a child-key leg needs hub-grade stability. **If `SERIAL_NO` renumbers, what identifies one dispatch
line?** The underlying fact question is routed to the source owner as **S6**; the re-key decision is
yours.

**What the build does meanwhile:** built **as mapped** (`BUILD_RULES.md` §5.7) and made loud — the
satellite model and the stage that defines the column both carry the warning in their header. The
build does not re-key a satellite and did not substitute the `POD_NUMBER` candidate the mapper named.
A dispatch line inserted or removed renumbers the rest and re-attaches their history, exactly as a
renumbered hub key would.

Alongside it, `.counts.collapse_trap_pairs_reaching_a_child_key` collapse-trap (satellite, leg) pairs
reach an emitted `src_cdk`; they are named in `.clauses.9.detail`. All were built as mapped and
routed. Being correctly routed does not make the clause pass: the clause says zero and
`.counts.ordinal_child_keys_by_backing` plus that figure is not zero.

Detection was by **backing**, never by name shape: each `src_cdk` column was resolved through the
feeder to its stage expression before being judged, and the detector is proved to fire on a real
ordinal backing and stay silent on an ordinal-**shaped** non-ordinal. A further set of child-key
columns are ordinal-shaped but backed by something else and are listed, not counted, at
`.ordinal_child_keys.ordinal_shaped_but_not_source_backed`.

**Systemic, not a slip.** The mapper's own independent finding is that this class appears in **five
of six maps**. Treat it as a modelling-convention question for the estate, not as a per-map defect.

### D2 — `SAT_PARTY_BANKING` grain divergence against the OPUS sibling

**The question:** is `SAT_PARTY_BANKING` multi-active on `Account Number Masked`, as this map
declares, or single-active on `PARTY_HKEY`, as the sibling builds it?

**What the build does meanwhile:** built under the **sibling's** contract (`BUILD_RULES.md` §7.2) and
reported. Detail and affected row count at `.sibling.grain_divergences`. If the map is right, the
satellite keeps one row per party where it should keep one per account.

### D3 — two content-hash canonicalisations, on disjoint hubs

**The question:** should a hand-typed nominee name collapse **internal** whitespace, so that
`AB  CD` and `AB CD` are one party?

**What the build does meanwhile:** both forms are emitted exactly as mapped and are **not** unified
(BD8). `md5(normalise(...))` on `HUB_LOCATION` and `LNK_PARTY_LOCATION`; `md5(upper(trim(...)))` on
`HUB_PARTY`, `LNK_PARTY_ROLE` and `HUB_ORG_UNIT`. Zero hubs carry both — verified, not assumed. The
split per hub is at `.content_hash_canonicalisations.by_hub`. Unifying them would re-key a hub on the
builder's authority, on a hub OPUS also writes.

### D4 — `SAT_COVERAGE_SUBLIMIT_SCHEDULE` catalogue-grain, proposed and not applied

The mapper proposed it and explicitly did not apply it because it changes grain. The build did not
apply it either. It needs your ruling; nothing downstream of it moves until you give one.

---

## For the SOURCE owner

Counts here are paths into `build_artifacts/BUILD_STATUS.json`, taken from there by reference.

### S1 — the `FOREIGN_KEY` round-trip is still unproven

**The question:** does the FK round-trip hold one-to-one against real data?

**What the build does meanwhile:** BD1 emits one join on the document handle. `.grammar.fk_hops`
spine occurrences depend on it. `00_tables_index.json` still carries `sample_data_available=false`,
so nothing in this run can settle it. `audit_mt_fk_roundtrip` falsifies it **before any load** —
`max_business_numbers_per_handle > 1` is the falsifier. If the round-trip does not hold, the keys
built on it are **wrong**, not empty. One line to overrule: `set FK_HOP_MODE = 'parent_chain' in
mt_keyrules.py`.

### S2 — is `POL_RISK_ID` globally unique?

**What the build does meanwhile:** the qualified `<root>#POL_RISK_ID` form is built, as instructed.
If the answer is yes, the qualifier drops across every affected row in one pass, because it is
isolated in one function. Every key on that hub changes when it does.

### S3 — is a PNR-trip the same risk object as a `POL_RISK_ID`-risk?

**What the build does meanwhile:** both namespaces are built and **two populations** are expected in
`HUB_RISK_OBJECT`. `.namespaces_by_hub.HUB_RISK_OBJECT` carries the split and
`audit_mt_riskobject_namespaces` counts it at run time. Confirmed still open at
`.profile_crosschecks.hub_risk_object_open`.

### S4 — is `TRIP_NO` a global trip identifier or a per-policy ordinal?

**What the build does meanwhile:** it is built as the fallback operand of the `TRIP:` keys. If it is
an ordinal, every policy's first trip keys to the same hub row and the hub merges unrelated trips.

### S5 — is `BILL_NO` a document identifier or a per-parent ordinal?

**What the build does meanwhile:** built as mapped as a child-key leg. If it renumbers, the child
keys backed by it are unstable — the §5.2 failure again, one satellite over.

### S6 — is `SERIAL_NO` stable per dispatch line?

**What the build does meanwhile:** built as mapped. This is the fact behind blocking item **D1**; the
decision that follows from the answer is the modeller's.

### S7 — `HUB_FINANCIAL_TRANSACTION` rows with no transaction identifier on the view

**The question:** is there a transaction identifier on these views that the map has not reached, or
is this a genuine source gap?

**What the build does meanwhile:** `.unbuilt_by_routing.source` items are **not built**, each with
its reason. The key was not invented (`BUILD_RULES.md` §5.6).

### S8 — several hubs carry more than one single-operand **bare** key

**The question:** is that one code system reached by several column names — which is what a canonical
hub is for — or several systems that must not merge?

**What the build does meanwhile:** built as mapped; **nothing was merged**, because merging is the
unrecoverable direction. Reported as a census, not as a verdict, in
`build_artifacts/reports/stage1_report.json`. The mapper separately flags `HUB_ORG_UNIT`, where a
branch code equal to a location code keys one hub row.

---

## For the MAPPER

Kept deliberately short. Both bundles have been frozen for hours; these are the items where a build
decision is genuinely waiting on you, not a list of everything the build noticed. Counts are paths
into `build_artifacts/BUILD_STATUS.json`, taken from there by reference.

### M1 — child-key leg sets that disagree within one satellite

**The question:** within one satellite the child key must be **one** leg set. Several views supply a
subset of the satellite's declared set. Which set is right — and for the views that supply none, is
the leg reachable at all?

**What the build does meanwhile:** those rows are **not built**. They are the bulk of
`.unbuilt_by_routing.mapper`, each named with its satellite, its view and the two leg sets, in
`build_artifacts/reports/stage1_report.json`. The build does not invent a leg.

### M2 — `SAT_CLAIM_EVIDENCE.'Media Reference'` carries `leg_backing='unresolved'`

**The question:** what backs this leg, or should the satellite be withdrawn?

**What the build does meanwhile:** refused before anything reads its `value`, and reported unbuilt.
Its `value` is an already-quoted English sentence: the synthesis rule that is correct for the other
expression-less legs would have written that sentence into a child key and **past every gate**,
because a quoted string is valid SQL.

### M3 — two satellites whose child key is composed only of no-operand literal legs

`SAT_CLAIM_EVIDENCE` (`Evidence Type`) and `SAT_PARTY_DIGITAL_IDENTITY` (`Active Sequence Number`).

**The question:** what discriminates the rows on these satellites?

**What the build does meanwhile:** both are **refused and unbuilt** — a child key of constant legs
collapses every instance onto one row. Note the narrower reading applied here: legs that render to
one value only because one view carries them were **built** with a warning, not refused, because they
are backed by a real source column and discriminate per row at load time.

### M4 — augmentation attributes bound to the **dominant** instance

**The question:** these attributes name an anchor and no instance, and their anchor has several key
slots on their view. Which instance do they belong to?

**What the build does meanwhile:** bound to the instance the map itself uses for most rows on that
view (BD11), with the vote recorded per binding in
`build_artifacts/mt_spec.json` `census.anchor_bound_by_assumption`. Dropping them would be a
silence coverage cannot see (`BUILD_RULES.md` §8.1). **One answer settles all of them**, and the rows
are augmentation-track and per-column reversible. To overrule: `set ANCHOR_AMBIGUOUS = 'unbuilt' in
mt_keyrules.py`.

### M5 — attributes that are the child key and nothing else

**The question:** for the columns exempted as `carried_as_cdk` (`.coverage.by_class.carried_as_cdk`),
is your ruling "this attribute IS the child key and nothing else", or do you want a distinct payload
name for it?

**What the build does meanwhile:** the value is in the vault, as `src_cdk`. Putting the same name in
both places would violate `BUILD_RULES.md` §5.4. **Read this together with V1** — these exemptions
exist because of a gate-scope defect, not because the data is missing, so this ask is about naming,
not about coverage.

### M6 — link legs that disagree with their hub's key

**The question:** three named cases, all unchanged across re-issues:

* `HUB_CLAIM` on `..._CLAIM_RESERVE` — the hub key walks `FOREIGN_KEY` and the leg walks
  `PARENT_KEY_HASH`. The leg rides the unproven round-trip (**S1**) and the hub does not.
* `HUB_PARTY` — the orphan leg `'EMP:' || BAGIC_RM_ECODE`. No `HUB_PARTY` key anywhere in the map is
  built from that column; the `EMP:` hub keys come from `BAGIC_EMPLOYEE_CODE` on a different view.
* `HUB_POLICY` on four party-relation views — legs use a walk no `HUB_POLICY` key form uses.

**What the build does meanwhile:** built **as mapped** (BD12). Substituting the hub's expression for
the leg's is the build correcting the mapping. The cost is **silent** — a disagreeing leg produces an
empty join, not an error, and reads downstream as sparse source data — so
`audit_mt_link_leg_divergence` counts legs reaching no hub row, per link per hub per feeder. The
leg named `ROLE` is *not* a hub at all and is correctly not chased as a defect. To overrule:
`set LINK_LEG_SOURCE = 'hub_key' in mt_keyrules.py`.

### M7 — `HUB_ORG_UNIT`'s shared unprefixed namespace

**The question:** `BRANCH_CODE`, `LOCATION_CODE` and `STORED_COMPANY_CODE` share one unprefixed
`HUB_ORG_UNIT` namespace. Should they?

**What the build does meanwhile:** built as mapped; nothing merged on the builder's authority.
Byte-identical on the rev-3 baseline and on the current map, so this is not a re-issue regression.

---

## For STAGE 3 / the build owner — the HASHDIFF residual

Counts here are paths into `build_artifacts/BUILD_STATUS.json`, taken from there by reference.

BD7 (`BD7-HASHDIFF-FOLLOWS-THE-SIBLING`) is **narrowed, not retired**, and the scope previously
quoted was wrong in this build's favour.

| what | path |
|---|---|
| satellites this build writes / the sibling writes | `.sibling.shared_surface.satellites_here` / `.satellites_in_the_sibling` |
| satellites **both** write, by name | `.counts.shared_satellites_with_the_sibling` |
| hashdiff **column name** disagreements | `.counts.hashdiff_name_disagreements` |
| hashdiff **input list** disagreements | `.counts.hashdiff_input_list_disagreements` |
| per-satellite detail | `.sibling.shared_surface.hashdiff_input_list_detail` |
| what "input list" means here | `.sibling.shared_surface.input_list_definition` |

**Retired on the name.** Every satellite on both sides carries a bare `HASHDIFF`; the name
disagreement count is zero, and so are the `src_pk`, grain and `src_cdk` disagreements across the
shared set. That is what BD7 bought.

**Not retired on the contents.** The hashdiff **input list** — `src_payload` union `src_cdk`, the
columns each project's stage actually hashes — differs on all but one of the shared satellites; the
one that agrees is `SAT_POLICY_CLASSIFICATION`. A row written by one project and read by the other
still compares as **changed**, so change detection thrashes on a shared table.

**Same name, different contents is the worse of the two failures, because the agreeing name is
exactly what hides it** from every check that compares names — including the one that just reported a
clean zero above it.

**Scope correction, stated because it matters more than the number:** the shared surface figure
quoted for most of this engagement counted only the OPUS-named `SAT_AUG_*` set and left out the
whole standard track. The measured surface is several times larger. Re-derived this run per satellite
**from the sibling build**, not from the decision record. Reconciling the input lists re-grains a
shared table and is a **modeller** decision; this build does not take it. To overrule the convention
itself: `set HASHDIFF_POLICY = 'maximus_house' in mt_names.py`.

---

## Answers keyed to the bundle's own open items

Every KNOWN OPEN item in `BUILD_INSTRUCTIONS_TRAVEL_V2.rev5.md` gets an answer here or an explicit
**not addressed** (`BUILD_RULES.md` §11.2). Numbers are paths into
`build_artifacts/BUILD_STATUS.json`, taken from there by reference.

| bundle item | answer |
|---|---|
| **§1** gate status | **Record correction.** The gate is at eight warns, not seven; the two machine artifacts say eight and the two prose artifacts say seven. The extra one is `resolved_key_sound` on `HUB_DOCUMENT`. State it as a **pre-existing collapse now visible**, not a regression: the two instances differed by one space, which changes no SQL value, so they had always collapsed onto one hub row. The fix removed the whitespace that was hiding it from a string-comparing gate. The sentence claiming the warns are byte-identical to the baseline is no longer true. |
| **§2.1** empty string is not NULL | **Confirmed, and proved rather than asserted.** Key rejection is by **shape**: a `CASE` over `coalesce(<guarded operands>) is not null`, then `nullif(trim(key),'')` — never by comparing a key to a constant. Independently evaluated: every live key expression evaluates to NULL on an all-blank row, and the evaluator is proved able to return non-NULL. `.key_rejection` reports zero statically computable degenerate constants, and zero is reported as zero. The per-operand `coalesce` idiom inside a content hash was copied through **verbatim**; no rewrite rule exists anywhere in the generator chain. |
| **§2.2** FK round-trip, unproven | **Cannot be validated here** — no sample data in this run. Built under BD1 and falsified before load by `audit_mt_fk_roundtrip`. Routed to source as **S1**. **Record correction:** the row figure the covering documents use for this population reproduces as no population in this map — see `.profile_crosschecks.do_not_quote`. Quote `.grammar.fk_hops` (spine-FK slots) and say which you mean. |
| **§2.3** a link leg must equal its hub's key | **Built as mapped, divergence measured** (BD12). See **M6** for the named disagreements and **X2** for the population on which this property is *unverifiable*. |
| **§2.4** `HUB_RISK_OBJECT` qualified form | **Built qualified, as instructed.** The `#` qualifier is isolated in one function, so a source answer drops it across every affected row in one pass. Routed to source as **S2**. |
| **§3(a)** `HUB_FINANCIAL_TRANSACTION` currency columns, no derivable key | **Not built**, key not invented (§5.6), exempted with the reason. Routed to source as **S7**. |
| **§3(b)** endorsement type with no reachable endorsement number | **Not built.** It arrives here as a child-key leg-set mismatch on `SAT_POLICY_ENDORSEMENT`; see **M1**. Accepted as a declared source gap. |
| **§3(c)** `SAT_COVERAGE_SUBLIMIT_SCHEDULE` catalogue grain, proposed not applied | **Not applied by the build either.** Routed to the modeller as **D4**. The build does not change a grain the mapper deliberately left unchanged. |
| **§3(d)** same class, needs values to confirm | **Cannot be settled here** — no sample data anywhere in this run. Routed to source with the specific fact questions **S4** and **S5**, which are the two instances of this class that reach a built child key. |
| **§3(e)** `HUB_RISK_OBJECT` two namespaces | **Built both; expect two populations.** Confirmed still open at `.profile_crosschecks.hub_risk_object_open`. Routed to source as **S3**. |
| **§3(f)** cross-table duplicate groups on byte-identical keys | **NOT ADDRESSED.** This build did not measure duplicate groups and makes no claim about them. It is not in any artifact this build wrote. If it matters before load, say so and it can be measured from the map in one pass. |
| **§3(g)** spine-spelling normalisation, left orthogonal | **Neutralised by construction, not by normalisation.** Key-slot identity is the **rendered** key, not the expression string, so two spellings of one walk are one slot. That defect was live in this build once and is named in *Mine to own*. The separate question of whether a walk resolves to the view's own base node or its parent is BD3 and is **still open**; overruling it is `set PIVOT_PARENT = 'grandparent' in mt_keyrules.py`. |
| **§4** monetary grain decision (`SAT_FINTXN_*` vs Maximus homes) | **No disagreement from the build.** Built as mapped, Maximus homes kept. This is a modeller reconciliation, not a build call, and the build does not move an attribute between satellites on its own authority. |
| **§4** OPUS quote branch is minimal | **Verified independently against the sibling build**, not taken from a document: no `sat_quote_rating` model exists anywhere in `travel_dv_dbt`. This build matches the as-built natural key form, **parentheses included**. **Record correction:** `KEY_FUNCTIONS.md` §10 still names `SAT_QUOTE_RATING` under "as-built key contracts this build must not break", and still renders the natural key **without** the parentheses. The other two documents were corrected; that one was not edited at all. |
| **§5** the late defect — is a PNR-trip the same risk object? | **Flagged, not guessed — same as the mapper.** Built as two namespaces, counted at run time. Routed to source as **S3**. The twin-view attribute-name disagreement on `ARRIVAL_COUNTRY` is carried, not adjudicated. |
| **§6** augmentation, all build-side | **Built.** The augmented track is **larger** than the mapped track — see `.counts.by_layer`. Proposals with a declared `multi_active` and no child key in either form are built **single-active** (BD6); each is listed with its proposed child-key name. Overrule with `set MA_WITHOUT_CDK = 'unbuilt' in mt_keyrules.py`. |
| **§6** `SAT_POLICY_DOCUMENT_DISPATCH` — do not collapse | **Not collapsed.** Built as its own satellite at dispatch-line grain. It is also the satellite carrying the blocking ordinal — see **D1**. |
| **§7.1** validate the FK round-trip | Routed to source as **S1**, with the population restated because the quoted one is not reproducible. |
| **§7.2** confirm you will reject null-resolving keys | **Confirmed** — see §2.1 above. Nothing falls through to a bare operand or mints a prefix with an empty suffix. |
| **§7.3** tell us if you disagree with the monetary grain decision | **No disagreement** — see §4 above. |
| **§7.4** anything in §3 or §5 you can settle from data you have | **Settled:** §1's warn count, §4's quote-branch claim, and the §3(g) spelling question (by slot identity). **Not settleable here:** everything that needs sample data — this run has none, and the build reports `not_run` rather than a pass, the same way the mapper did. |

---

## Reported, not guessed

Nothing in this list was guessed. Each is built as the map says, or not built, and reported. Every
quantity is a path into `build_artifacts/BUILD_STATUS.json`, taken from there by reference.

| n | what | whose call |
|---|---|---|
| `.unbuilt_by_routing.mapper` | rows not built: leg-set mismatch, §5.4 name clash, no resolved key on the view, constant-only child key, unresolved sentinel, refused build directive | mapper |
| `.unbuilt_by_routing.source` | rows not built: no identifier for the hub exists on the view | source |
| **`.unbuilt`** | **total unbuilt — reconciles exactly to the two rows above** | — |
| `.coverage.by_class.carried_as_cdk` | mapped columns in the vault as `src_cdk`, not `src_payload` | mapper (naming) / `vault_tools` (**V1**) |
| `.coverage.by_class.satellite_not_built` | mapped columns on a satellite this build refused | mapper |
| `.coverage.by_class.build_directive_refused` | `SAT_RISK_PERSON_INSURED.AGE_AT_ENTRY` | mapper |
| **`.counts.exemptions`** | **total sanctioned exemptions — reconciles exactly to the three rows above, and `.coverage.unexplained` is zero** | — |
| `.counts.collapse_trap_pairs_reaching_a_child_key` | collapse-trap legs reaching an emitted `src_cdk` | modeller |
| `.counts.ordinal_child_keys_by_backing` | child keys backed by a renumbering ordinal | modeller (**D1**) |
| `.ordinal_child_keys.ordinal_shaped_but_not_source_backed` | ordinal-**shaped** child keys backed by something else — reported, not counted as ordinals | mapper |
| `.link_leg_census.uncorroborated_by_an_on_view_hub_key` | legs not also used as a standalone hub key on their own view | mapper |
| `.counts.link_legs_naming_no_hub` of `.counts.link_legs` | legs the map does not bind to a hub — see the limit **X2** | mapper |
| `.sibling.grain_divergences` | grain divergence against the sibling | modeller (**D2**) |
| `.counts.hashdiff_input_list_disagreements` of `.counts.shared_satellites_with_the_sibling` | shared satellites whose hashdiff input list differs | build owner / modeller |
| `.content_hash_canonicalisations.forms` | the two canonicalisations, emitted as written | modeller (**D3**) |
| `.counts.augmentation_rows_invisible_to_coverage` | augmentation rows in neither the coverage denominator nor the exemption file | `vault_tools` (**V2**) |
| `.grammar.fk_hops` | spine slots depending on the FK round-trip | source (**S1**) |
| `.key_rejection.keys_with_a_statically_computable_degenerate_constant` | a **measured** zero, with the mechanism stated beside it | build |

---

## Two things this build cannot certify — limits, not omissions (§11.8)

Provenance for this section: `build_artifacts/reports/stage2_report.json` and
`build_artifacts/BUILD_STATUS.json`, by reference.

### X1 — that no other project's lines in the shared `accepted_uncovered.txt` were touched

There is **no VCS on this estate and no baseline to diff against**, so this cannot be certified by
anyone here, including me. What **can** be said, and was measured:

* this build's generator **cannot** write that file — it writes its own copy under
  `build_artifacts/` and `selfcheck_mt.py` only asserts;
* every line this project owns is present in the shared file and matches the generated copy exactly,
  with none missing and none extra (`.self_checks`, clause 3);
* the file is structurally intact file-wide — no malformed lines.

That is the whole claim. "No other project's lines were touched" is **not** part of it. A per-project
section digest in `vault_tools` would make it checkable — item **V3**.

### X2 — the leg-equals-hub-key property is unverifiable on most link legs

The population is `.counts.link_legs_naming_no_hub` of `.counts.link_legs` — the legs the map does
**not** name for a hub. On those, the leg and the hub key come from the **same** renderer and agree by
construction, so `audit_mt_link_leg_divergence` cannot see a mis-bound leg there. It is verifiable
only on the named legs. The limit itself is written out at `.link_leg_census.coverage_limit` and the
full four-way binding census at `.link_leg_census.by_binding`.

**Two earlier figures published for this were wrong, both understating it**, which is why the
population is stated here and not only the number:

* the first counted only legs that were **both** positional **and** uncorroborated — a subset of a
  subset, understating the limit by an order of magnitude, in the same sentence as a claim that more
  than half the link surface is unverified. The two halves contradicted each other and a reader
  quotes the smaller number;
* the second, from a re-derivation in verification, counted fewer named legs than the build's own
  balanced-paren splitter finds, and is **withdrawn**. The splitter that parses the whole map with
  zero residue is the one to believe. The reconciliation of all three published figures is at
  `.link_leg_census.reconciliation`.

---

## Correcting the record

A stated risk that cannot happen is a defect (`BUILD_RULES.md` §11.8) and is worth the same
seriousness as an understated one — it gets the whole entry discounted, and the real exposure
underneath goes with it. Sources: `build_artifacts/BUILD_STATUS.json` and the stage reports, by
reference.

| what was stated | what is true | the real residual |
|---|---|---|
| `check_vault_alignment` check 1 fails, therefore this build has uncovered canonical attributes | All but one of its findings are a **gate-scope defect**; the value is in the vault as `src_cdk`, proved by injection | **One** finding is real: `SAT_RISK_PERSON_INSURED.AGE_AT_ENTRY` — see the row below |
| `AGE_AT_ENTRY` is part of the same gate artifact | **No — it is a genuine refusal.** Single-active `sat()`, absent from `src_cdk`, no live feeder, and the map declares an executable derivation (`floor`, `months_between`) that is **unratified** in `KEY_FUNCTIONS.md` | Refusing it is the **correct** outcome for that build directive. Emitted raw it would put a raw date of birth into an age column: wrong data, not missing data, passing every gate. It needs a ratified function or a mapper ruling, not a build guess |
| a sibling project's exemption lines are almost all stale | **Withdrawn.** The figure was a **file-wide** count spanning three projects, relayed as one project's. It does not reproduce where it can be tested: **none** of this build's exemptions is stale | `maximus_health_v2_dv_dbt` was **not examined** — its tree was mid-regeneration — so its state is **unknown**, neither clean nor stale. The property that a dead exemption is indistinguishable from a live one stands without any count behind it. See **V4** |
| the shared-vault HASHDIFF surface is the OPUS-named `SAT_AUG_*` set | The shared surface is several times larger — `.counts.shared_satellites_with_the_sibling` | The **input lists** disagree on all but one. Narrowed, not retired |
| the leg-binding coverage limit is small | It is the majority of the link surface — **X2** | Unverifiable by construction on that population; verifiable only on the named legs |
| the gate is at seven warns | Eight. The machine artifacts have said eight since the `HUB_DOCUMENT` fix | The extra warn is a **pre-existing collapse now visible**, not a regression — but it is open, and two documents still say seven |
| `SAT_QUOTE_RATING` is an as-built OPUS contract | It does not exist in `travel_dv_dbt`. Verified by filename glob over the whole sibling build | A builder reading `KEY_FUNCTIONS.md` §10 would try to match a satellite that is not there, and would render the natural key without its parentheses |
| the FK round-trip population, as quoted in two covering documents | Reproduces as **no** population in this map — see `.profile_crosschecks.do_not_quote`. Unchanged since rev 4, so it has survived four re-issues | The risk is the same shape whichever denominator is right. Quote `.grammar.fk_hops` and say which you mean |
| `04_column_map.pre_legfix.json` is a snapshot of a leg fix | It is **byte-identical** to the live map | The leg fix it is named for changed nothing; every leg disagreement in **M6** is measurably still present |

---

## Mine to own

`BUILD_RULES.md` §11.6. The lesson belongs in `BUILD_RULES.md` with its enforcing check; the incident
belongs in a row. Detail for every row is in `build_artifacts/reports/stage1_report.json` and
`build_artifacts/reports/stage2_report.json`, by reference.

### Defects this build introduced and only partly repaired

| defect | rule | the check that catches it | status |
|---|---|---|---|
| `reproducibility.json` is listed in `prove_mt_reproducibility.CHAIN_OUTPUT_FILES` but `run_all.sh` **never writes it**. Following §9.3 with that list as the definition of "what the chain rewrites" **deletes it permanently**. I did exactly that | §9.3 | the prover now asserts `build_artifacts/reports/` survived; nothing yet asserts that every `CHAIN_OUTPUT_FILES` entry has a writer **in the chain** | **Partly repaired.** The artifact was restored by re-running the prover. The list is still wrong: either drop the entry or state that the prover must be re-run |
| `project` and `generated` are in `selfcheck_mt.STAGE1_OWNED_KEYS`, so they are excluded from preservation — **but stage 1 never writes them**. Net effect: the chain **deletes** two fields the §10 output schema requires | §10 | the preservation self-check compares preserved counts, not required keys | **STILL OPEN.** Re-added by hand; **they will vanish again on the next `run_all.sh`** until `STAGE1_OWNED_KEYS` is corrected or stage 1 writes them. The warning is recorded in `.schema_warning` in the file itself. A `BUILD_STATUS.json` with no project name and no generation date is exactly the "stale verdict reads as current" hazard |

### A count in this build's own code that disagrees with the code

| defect | rule | the check that catches it |
|---|---|---|
| The rev-5 profile key split in `mt_names.PROFILE_KEY_DISPOSITION` is **transposed** in its own code comment: the comment names one consumed/acknowledged split and the dispositions enumerate the other. The machine fact and the enumerated keys are in `build_artifacts/reports/stage2_report.json`; the comment is prose beside them | §1.9 | none — `check_prose_counts.py` scans `generators/README.md` and `BUILDER_ASKS_*.md`, **not** comments inside generator modules. This is §1.9 violated **inside the module that enforces §2.2** |

### A convention claim that was right for the wrong reason

`mt_names.detect_payload_convention` classifies each sibling payload column as
`UPPER_SNAKE` / `business_name_with_spaces` / `other`. **There is no `squashed` class, and a squashed
name fullmatches the `UPPER_SNAKE` pattern.** Proved by rendering the same canonical attributes
squashed: the detector still returns `UPPER_SNAKE`. So the unanimous "all of them" result was a
**shape census, not a convention test** — and distinguishing those two conventions is the very thing
`check_vault_alignment`'s docstring exists for, because health renders squashed and travel renders
`UPPER_SNAKE`.

**The answer is still right**, re-derived properly against canonical renderings rather than shapes:
of `.counts.sibling_payload_columns` sibling payload column occurrences, the ones on satellites that
exist in `data_7.js` all match the `UPPER_SNAKE` canonical rendering, none matches squashed-only, and
`.counts.sibling_payload_columns_disambiguating_the_convention` carry disambiguating evidence. The
remainder sit on `SAT_AUG_*` satellites **absent from `data_7.js`**, so no canonical rendering exists
to compare and they can **only** be shape-tested. The per-class figures are in
`build_artifacts/reports/stage2_report.json`. Fix: score against canonical renderings, as the shared
gate already does. Rule: §1.10 — a check that gives the right answer for the wrong reason has not
been shown to work.

### Artifacts lost to a deletion step running before the thing that needed them (§9.7)

Three, on this estate, in this engagement:

| artifact | how |
|---|---|
| `build_artifacts/reports/stage0_report.json` | my first reproducibility script followed §9.3 by backing the reports up and then deleting `build_artifacts`; on a second invocation **its own cleanup of the backup directory ran before the copy**, so the backup was emptied and the originals were then deleted |
| `build_artifacts/reports/stage0_reentry_report.json` | same run, same cause |
| `build_artifacts/reproducibility.json` | the `CHAIN_OUTPUT_FILES` defect above — deleted as "something the chain rewrites" by a chain that does not write it |

The first two are **not recoverable by me**. The project lives under OneDrive, so they should be in
the cloud recycle bin under
`Documents/dev/Health_DBTModel/maximus_travel_dv_dbt/build_artifacts/reports`; otherwise re-run
stage 0, which regenerates them. The build itself does not depend on them. The third was restored by
re-running the prover. **No mapper artifact and no bundle file was touched** — the read-only
assertion over the whole input set passes on every run, and the map digest is unmoved.

The rule is §9.7 and the shape is the same all three times: a deletion step ordered before the thing
that needed the deleted item. The repaired prover now deletes only what the chain rewrites and
asserts `build_artifacts/reports/` survived, and that assertion passes on the run that produced this
handback.

### A false alarm raised and withdrawn before it reached this document

A substring scan found archived `keynorm.previous_expression` values present **verbatim** in the
shipped spec, in live `key_slots[].expression` and `link_slots[].expression` — apparently superseded
key history reaching live key slots, which would be the single worst defect available on this LOB.

Re-derived before reporting: every one is a **substring of a live map expression**. The containing
spec strings are hundreds of characters long against archived fragments of a few dozen. The spec's
copy is explained by live content, not by inheritance. **My substring test cannot distinguish the
two** (§1.10); the poisoning instrument in `generators/probe_mt_keynorm.py` can, and its zero
stands. **Alarm withdrawn.** It is written down here because a withdrawn alarm that is never recorded
gets raised again by the next reader.

### A negative control that failed because a shell heredoc ate a backslash

The control-byte probe's **positive** case fired, and so did the **negative control** — which should
be impossible. Cause: I authored the probe through a shell heredoc, **the heredoc ate the backslash,
and a word-boundary escape became a literal control byte**. That is §1.2, reproduced live, by the
verifier, in the same session as the rule — and the same byte class the estate already carries as a
standing debt item on another project's generator.

Re-authored with the probe bytes **constructed** rather than typed through a shell. It now fires on
the planted byte and stays silent on the clean line, and the live scan over
`.counts.control_byte_files` is a judged zero. Rule §1.2; the enforcing check is
`vault_tools/check_patterns.py` plus the independent scan recorded in `.self_checks`.

### Gate gaps found, owned, and not fixed here

`vault_tools` items **V1**, **V2**, **V3**, **V5** above are gate gaps this build found. None was
fixed here: a shared gate is not edited while builds are reading it. **V1 is the one to act on
first** — it makes clause 1 unpassable for any Maximus project that carries a canonical attribute as
a child key.

---

## Carried debt (`BUILD_RULES.md` §12) — what ran here and what did not

The per-item results, with `ran_locally` on each, are in
`build_artifacts/reports/stage2_report.json` `.carried_debt`, taken from there by reference. Most
items ran against this build. These are the ones that did **not**, each with its reason:

| debt item | why it was not run here |
|---|---|
| Six existing projects not re-swept under the corrected check 7 | An estate-wide re-sweep is a decision, not a chore, and is out of scope for verifying one build. Their figures remain **lower bounds** |
| Three-way HASHDIFF on Health V2 | Different LOB; nothing in this build bears on it |
| First check-7 sweep, six projects | Historical estate figures; this build re-measured only itself |
| `ref()`-chain fix, no-regression comparison | Estate-wide comparison; out of scope for one build |
| `property PLACEHOLDER_CK` carries a literal control byte | Another project's generator; not touched |
| `BUILDER_VALIDATOR.md` is stale | A mapper-facing document; not a builder-side edit |

Two results worth naming from the half that **did** run: the dead-data-path check no longer condemns
the augmented track wholesale — that track carries the payload-attribute count once reported as
entirely dead and now reports `.counts.dead_data_paths`, with a real dead path injected **into** that
track moving the count and being **named**. And `check_prose_counts.py` on this project returns
**PASS**, not **NOT RUN** — §1.8 and §1.9 make those different outcomes, and this LOB has taken the
generated-provenance remediation the ledger asks for.

---

## Builder decisions — one line each to overrule (§11.5)

Every decision below was taken by the build, not by the mapper, and each was recorded **with its
cost** at the moment it was taken. They live in `BUILDER_DECISIONS` in `generators/mt_keyrules.py`;
the identifiers are listed at `.builder_decisions` in `build_artifacts/BUILD_STATUS.json`, by
reference, and the cost of each is in the generated table in `generators/README.md`.

| id | to overrule |
|---|---|
| `BD1-FK-HOP-IS-ONE-JOIN` | `set FK_HOP_MODE = 'parent_chain' in mt_keyrules.py` |
| `BD2-FK-INTERVENING-CASTS-PROVISIONED` | `set CAST_COVERAGE = 'joined_only' in mt_keyrules.py` |
| `BD3-PIVOT-PARENT-IS-THE-BASE-NODE` | `set PIVOT_PARENT = 'grandparent' in mt_keyrules.py` |
| `BD4-LNK-LEG-CORROBORATION-IS-REPORTED-NOT-FATAL` | `set LNK_LEG_UNCORROBORATED = 'fatal' in mt_keyrules.py` |
| `BD5-ROLE-CODE-IS-A-DEGENERATE-LINK-LEG` | `set LINK_DEGENERATE_LEG = 'drop' in mt_keyrules.py` |
| `BD6-MULTI-ACTIVE-WITHOUT-A-DISCRIMINATOR-IS-SINGLE-ACTIVE` | `set MA_WITHOUT_CDK = 'unbuilt' in mt_keyrules.py` |
| `BD7-HASHDIFF-FOLLOWS-THE-SIBLING` | `set HASHDIFF_POLICY = 'maximus_house' in mt_names.py` |
| `BD8-TWO-CONTENT-HASH-CANONICALISATIONS-EMITTED-AS-WRITTEN` | `set CONTENT_HASH_UNIFY = True in mt_keyrules.py` |
| `BD9-DEGENERATE-KEYS-REJECTED-BY-SHAPE-NEVER-BY-CONSTANT` | `set DEGENERATE_OUTER_NULLIF = False in mt_keyrules.py` |
| `BD10-PURE-LITERAL-KEY-IS-CONSTANT-BY-CONSTRUCTION` | `set ACCEPT_CONSTANT_KEY = False in mt_keyrules.py` |
| `BD11-ANCHOR-ONLY-ROWS-BIND-TO-THE-MAP-S-OWN-KEY` | `set ANCHOR_AMBIGUOUS = 'unbuilt' in mt_keyrules.py` |
| `BD12-LINK-LEG-BUILT-AS-MAPPED-DIVERGENCE-MEASURED` | `set LINK_LEG_SOURCE = 'hub_key' in mt_keyrules.py` |
| `BD13-HUB-DOCUMENT-TWO-KEY-FORMS-BUILT-AS-MAPPED` | `set HUB_DOCUMENT_PREFIX = 'bare' in mt_keyrules.py` |

**Models are generated, never hand-edited.** Any of the above is one line plus `sh run_all.sh`. The
generators are the durable artifact; re-running them is cheap. Nothing here should be read as "the
map is settled" — a further re-issue has already been announced, and this build is against rev 5 and
the map digest recorded at `.input_digest`.
