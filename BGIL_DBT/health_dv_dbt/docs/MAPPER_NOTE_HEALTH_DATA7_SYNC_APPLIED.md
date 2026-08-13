# Follow-up note for the mapper — re: MAPPER_NOTE_HEALTH_DATA7_SYNC.md

Applied. One thing worth flagging on the "48 new tables" framing, one genuine new gap found
while reconciling the premium-head literals, and everything else confirmed/aligned.

---

## Table count — only 6 of the 129 are actually unbuilt, not 48

Diffed the new workbook's 129-table list directly against this project's 123 built staging
models. Only 6 are missing: `BJAZ_HM_CHARGE_MASTER`, `BJAZ_HM_DIAGNOSIS_MASTER`,
`BJAZ_HM_DISEASE_MASTER`, `BJAZ_HM_ICD_DISEASE_MASTER`, `BJAZ_HM_ICD_MASTER`,
`BJAZ_HM_ROOM_MASTER` — and all 6 are `needs_reanchor` in `Source→Target` with **no
target at all**, so there's nothing buildable there regardless. Not something I fixed, just
flagging that "48 new" likely counts against an older baseline than what this project
actually built from (probably an earlier draft than the `_v5` this project used) — the real
delta against the current build is much smaller than that number suggests.

## `SAT_POLICY_PREMIUM_HEAD` — literals matched to your exact wording, plus a real find

Your note said the three proposed tokens (`Base Cover`/`Surgical Cover`/`Per-Person Basis`)
were mine to finalise, but since you'd already written the exact wording you wanted, I just
matched it rather than keep my earlier guesses:

- `'Per Person Premium'` → `'Per-Person Basis'`
- `'Add-On Premium'` → `'Add-On'`
- `'Surgical Cover Base'` → `'Surgical Cover'`
- `'Base Cover'` / `'Maternity Rider'` / `'Maternity Co-Buffer'` already matched exactly, no
  change.

**While doing this I found `BJAZ_HCF_MEMBER_DTLS.FLOAT_PREMIUM` was never built at all** —
your workbook lists it (→ Net Head Premium, `[child:floater]`, instance `Floater`), and the
column is already exposed in this project's own staging model for that table, but only its
sibling `ADON_PREMIUM` (`Add-On`) had been wired into `SAT_POLICY_PREMIUM_HEAD`. Added as a
second branch off the same table (matches the `BJAZ_GRP_HLT_MATERNITY_DTLS` two-branch
pattern from the earlier cross-LOB rekey round). This wasn't part of your stated "7 rows,
10 total across 3 satellites" scope explicitly, but it lines up with your `Instance / Child`
column, so I'm treating it as in-scope rather than a coincidence.

## `SAT_FINTXN_COMMISSION` / `SAT_FIN_CHARGE_RATE` — confirmed matching

Your note says these match what was applied — confirmed, no change needed.

## Verified

Dependency-resolution + `src_pk`/`hashed_columns` sweep re-run clean after all changes: 0
dangling refs, 0 mismatches, across all 1330 `.sql` files in this project.
