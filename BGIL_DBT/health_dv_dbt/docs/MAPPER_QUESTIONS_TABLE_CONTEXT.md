# Questions for the Health mapping owner — source-table business context

Separate from `MAPPER_QUESTIONS.md` (hub/link key gaps) and `MAPPER_NOTE_V5_FOLLOWUP.md`
(subject-attribution corrections). This round is about a different kind of gap: some source
table *names* carry business meaning (a bancassurance partner, a government scheme, a
distribution channel) that isn't captured in any column on that table — so today it only
exists as a human-readable table name, invisible to anyone querying the model. Found by
scanning all 129 Health table names for tokens that don't match generic insurance
vocabulary (`DTLS`, `MST`, `CLM`, `POL`, etc.), then checking whether each candidate table
already has a column that could plausibly carry the same meaning as data.

One thing already checked and **not** a gap: the `BA_HCP_PROD_8428/8432/8433/8439_*_LOADER`
tables' embedded product codes (GPG/ECP/FHC/CLH) — already correctly tagged `KEY:HUB_PRODUCT`
in the mapping. No question needed there.

---

## A. Genuine gaps — table has no column that could carry this context at all

For each: is this table's business context a **fixed fact true of every row** (i.e. worth
capturing as a literal, table-level attribute — same mechanism as an Instance/Child label),
and if so, which hub/satellite should hold it?

1. **`BJAZ_WS_FAMILY_DTLS_BANDHAN`** — table name suggests Bandhan Bank bancassurance
   channel. Zero columns on this table resemble a channel/partner/intermediary code.
2. **`BA_HDFC_LEAD`** — table name suggests HDFC Bank channel. Same: no channel-shaped
   column present.
3. **`BJAZ_KBL_LEAD_PROCESSING`** — `KBL` unclear to me (possibly a bank code) — no
   channel-shaped column present either way.
4. **`BJAZ_PMJAY_PRMBOOK_DTLS`** — `PMJAY` reads as a government health scheme
   (Ayushman Bharat / PM-JAY), which is a *different kind* of fact than a bank channel —
   possibly belongs on `HUB_PRODUCT` as a scheme identifier rather than
   `HUB_DISTRIBUTION_CHANNEL`. No column captures this on the table either way. Which hub
   should this attach to, if any?

## B. Possibly already captured — has a plausible carrier column, but I can't confirm the actual values without a data query

These tables *do* have a `PARTNER_ID`/`IMD_CODE`/`PRODUCT_CODE`-shaped column that might
already hold this same context as data on every row. Lower priority than section A — only
worth a mapper's time if a quick data check shows these columns are NOT reliably populated
with the expected value:

5. `BJAZ_BANDHAN_MEDI_CLAM` (has `IMD_CODE`, `PARTNER_ID`, `PARTNER_TYPE`, `PRODUCT_CODE`,
   `SUBIMD_CODE`, `LG_CODE`)
6. `BJAZ_HDFC_FLEXIPA`, `BJAZ_HDFC_SEC_FHPP`, `BJAZ_HDFC_SURK_SHOP` (each has `IMD_CODE`,
   `PARTNER_ID`, `PRODUCT_CODE`)
7. `BJAZ_PNB_GPA_DATA` (has `IMD_CODE`, `PARTNER_ID`, `PRODUCT_CODE`)
8. `BJAZ_SUPER_SURAKSHA_DTLS` — likely a product name ("Super Suraksha"), not a channel
   (has `IMD_CODE`, `PARTNER_ID`, `PARTNER_TYPE`, `PRODUCT_CODE`, `SUBIMD_CODE`)
9. `BJAZ_GC_GROUP_GUARD_DTLS` — likely a product name ("Group Guard") (has `LG_CODE`,
   `PARTNER_ID`, `PARTNER_TYPE`, `PLAN_ID`, `PRODUCT_CODE`)
10. `BJAZ_STARPKG_FF_DTLS` — likely a product name ("Star Package") (only `PARTNER_ID` —
    thinner signal than the others in this section)

## C. Different question entirely — source-system/platform, not channel or product

11. **`BGIL_GMC_FINAL_INSTL_DATA`, `NG_HCM_INWARD_DETAILS`, `STG_HCF_MEMBER_DTLS`,
    `T_PREM_DATA_COM`** — these 4 use naming prefixes distinct from the dominant `BJAZ_`/
    `BA_HCP_` pattern across the rest of Health. Does that reflect a genuinely different
    source system or ingestion pipeline, and if so, does the model need a way to represent
    "which platform this row came from" as a business fact (separate from `record_source`,
    which is lineage metadata, not a queryable attribute)?

## D. Not investigated — `BJAZ_REMEDINET_CLAIM_DETAILS`

Already correctly mapped for its actual content (party/claim entities feed
`SAT_PARTY_IDENTITY`/`HUB_CLAIM`). The only unresolved piece is "which claims network this
data flowed through" as a fact in its own right — flagging for awareness, not asking a
question, since it's genuinely unclear whether this is worth modeling at all versus staying
as pure lineage. Mapper's call whether this needs anything.
