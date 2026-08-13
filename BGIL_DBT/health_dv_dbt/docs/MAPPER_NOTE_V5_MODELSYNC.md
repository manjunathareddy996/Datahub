# Mapper note — mapping synced to `data_v5` (modeler Phase 6b)

Picked up the modeler's decisions (`MODELER_DECISIONS_HEALTH.md`) and the new model (`data_v5.js`).
Diffed v4→v5: exactly **two structural changes** — `+SAT_LNK_POLICY_PARTY_ROLE`,
`−SAT_PARTY_ADDRESS_USAGE`. The mapping is updated and re-validated **against `data_v5`**:
**0 invalid targets, 0 collapse violations.** (Prior workbook backed up as
`..._v5_backup_pre_v5model.xlsx`.)

## What changed in the mapping

### M4 — `SAT_PARTY_ADDRESS_USAGE` removed → 14 columns re-routed (required)
Those 14 columns pointed at the now-deleted satellite. Re-routed to the **canonical normalized path**
the modeler ratified: address lines → **`SAT_COMMON_ADDRESS`** (parent `HUB_LOCATION`), with an
**`address_usage`** label (`proposer` / `member` / `payee` / `diagnostic-centre`, from the column) that
the party↔location tie carries via `LNK_PARTY_LOCATION` + `SAT_PARTY_CONTACT_ADDRESS_LINK`.
- Tables affected: `BJAZ_BANDHAN_MEDI_CLAM` (proposer + member address blocks), `BJAZ_TPA_CLAIM_DETAILS_WS`
  (`PAYEE_ADDRESS`), `BA_HCP_PP_MEM_DTLS` (`DC_ADDRESS`), `BJAZ_HAT_ID_MEM_DETLS`.
- The 5 apparent same-attribute collisions (proposer vs member address on one table) are **distinct
  `HUB_LOCATION` rows**, not a collapse — `SAT_COMMON_ADDRESS` dedupes by address content, so two
  address columns legitimately mint two location rows. Gate confirms clean.
- Build action: these now load like any other address on the normalized route; the `address_usage`
  label drives the `SAT_PARTY_CONTACT_ADDRESS_LINK` usage row.

### M2 — `SAT_LNK_POLICY_PARTY_ROLE` added → **no re-target needed** (important)
Heads-up on a discrepancy: the modeler's note says "your 24 held columns map straight into this," but in
the **current v5 mapping those 24 are already mapped**, not held — they were homed by the earlier
consolidation + subject-attribution passes:
- Nominee/assignee **relationship** columns (`NOMINEE_RELATION`, `NOMINEE_RLTN`, `ASSIGNEE_RELATION`) →
  `SAT_LNK_ROLE_NOMINEE_BENEFICIARY.Relationship To Insured` (correct — that's the nominee's relationship).
- RM/agent **codes** (`PD_IMD_RM_E_CODE`, `PD_BAGIC_RM_E_CODE`, `BAGIC_RM_E_CODE`, `BAGIC_E_CODE`) →
  `SAT_LNK_ROLE_EMPLOYEE.Employee Code` (correct — the employee's own identity).

So the new satellite is **additive, not a re-map**: it's the home for the **policy-scoped role
dimension** — the fact that *on this policy* the party plays main-agent / sub-agent / RM-type /
nominee / beneficiary. In DV unit-of-work terms, those same rows should **also** contribute a
`SAT_LNK_POLICY_PARTY_ROLE` row with `Party Role Type` = the column's role label (imd-relationship-
manager, insurer-relationship-manager, nominee, assignee, …) at grain "Party Role Type + Role Sequence".
Nothing in the workbook needs re-pointing; **build the new satellite off the existing party-role
columns**. (If the build still has these as "held" from the pre-subject-attribution state, refresh from
the current v5 mapping — they're homed now.)

### No mapping change (confirmations / ref-seeds)
- **M1 coverage unpivot** — unchanged: still the `POLICY_REF ‖ benefit-code` unpivot; `REF_COVERAGE_CODE`
  master exists, modeler seeds the benefit-code vocabulary, you build the `LATERAL FLATTEN`. Six coverage
  satellites stay gaps until then.
- **M6** `REF_RELATIONSHIP_TYPE` — master exists; modeler seeds the code list. No mapping change.
- **M3 / M5 / M7 / M8** — all confirmations (literal `role_type_ck` OK; proposer via self-join on the
  member set; RI/treaty links out-of-scope; composite `HUB_RISK_OBJECT` key ratified). No mapping change.
  For **M8**, keep the party↔risk link populated so "same person under two policies" stays joinable at
  the party level (the modeler's one requirement) — that's already how the risk-object rows resolve.

### Incidental fix
`BJAZ_HM_EXCLUSION_MASTER.EXCLUSION_ID` was pointing at a non-existent `SAT_PRODUCT_EXCLUSION_CATALOGUE`
attribute; re-pointed to `REF:REF_EXCLUSION` (the exclusion master key), consistent with §M6 / the
already-built `REF_EXCLUSION`.

## Net state (vs `data_v5`)

| | v5 (this build) |
|---|---|
| Source columns | 3,103 |
| Mapped | 2,345 |
| Invalid targets vs data_v5 | **0** |
| Collapse violations | **0** |
| M4 re-routes | 14 |
| M2 | additive satellite — no re-map; build from existing party-role columns |

## Your next actions
1. Switch the build's model reference to **`data_v5.js`**.
2. Pick up the **14 re-routed address columns** (now `SAT_COMMON_ADDRESS` + `address_usage`).
3. **Build `SAT_LNK_POLICY_PARTY_ROLE`** and populate `Party Role Type` from the existing party-role
   columns (nominee/assignee/RM) — additive, no re-map.
4. `HUB_COVERAGE` unpivot + `REF_RELATIONSHIP_TYPE` seed remain pending the modeler's ref-data (M1, M6).
