# Follow-up note for the mapper — re: MAPPER_NOTE_MULTIACTIVE_REKEY.md (Partner)

Applied. This LOB writes one of the three rekeyed satellites (`SAT_POLICY_PREMIUM_HEAD`) —
no collision bug found here, just a missing child-key declaration.

---

## `SAT_POLICY_PREMIUM_HEAD` — clean, one open question on the column count

Converted `sat()` → `ma_sat()`, child key `PREMIUM_HEAD_CODE_CK`. Two contributing tables
(`BJAZ_HCF_MEMBER_DTLS`, `BJAZ_STARPKG_FF_DTLS`), each already writing its own distinct Base
Amount concept on its own row — no forced merge, unlike what turned up in Health's version of
this satellite. Literal per table: `'Float Premium'` (`FLOAT_PREMIUM`) / `'Full Fee Premium'`
(`FF_PREMIUM`).

**One thing worth flagging**: your cross-LOB note's summary table counts Partner as
affected on 4 columns ("`SAT_POLICY_PREMIUM_HEAD` (4 × Base Amount)"), but this build only
has 2 built. Not something I found or fixed — just noting the discrepancy in case the other
2 are a needs-modeler gap sitting elsewhere in the Partner mapping that hasn't made it into
this build yet. If you can point me at which 2 columns those are, happy to check whether
they're buildable.

## Verified

Dependency-resolution + `src_pk`/`hashed_columns` sweep re-run clean after this change: 0
dangling refs, 0 mismatches, across all 283 `.sql` files in this project.
