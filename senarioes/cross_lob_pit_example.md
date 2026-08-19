# Cross-LOB PIT Example

Two LOBs, same satellite name (`sat_party_contact`), same hub (`HUB_PARTY`), overlapping + different columns.

---

## Source Satellites

### Health LOB: `sat_party_contact` (Health)
Columns: `MOBILE_NUMBER`, `EMAIL_ADDRESS`, `LANDLINE_NUMBER`

```
PARTY_HK  LOAD_DATETIME        MOBILE_NUMBER  EMAIL_ADDRESS   LANDLINE_NUMBER  RECORD_SOURCE
ABC       2026-01-01 09:00     7010170101     ash@gmail.com   022-555          HEALTH_MEMBER
ABC       2026-03-01 09:00     8010180101     ash@gmail.com   022-555          HEALTH_MEMBER
```

### Partner LOB: `sat_party_contact` (Partner)
Columns: `MOBILE_NUMBER`, `EMAIL_ADDRESS`, `FAX_NUMBER`

```
PARTY_HK  LOAD_DATETIME        MOBILE_NUMBER  EMAIL_ADDRESS      FAX_NUMBER  RECORD_SOURCE
ABC       2026-01-01 10:00     7010170101     ashraf@corp.com    022-999     PARTNER_INTERMEDIARY
ABC       2026-02-01 10:00     7010170101     ashraf@newcorp.com 022-999     PARTNER_INTERMEDIARY
```

Note: `MOBILE_NUMBER` and `EMAIL_ADDRESS` exist in BOTH. `LANDLINE_NUMBER` only in Health. `FAX_NUMBER` only in Partner. Values for overlapping columns may DIFFER (email does).

---

## Step 1: as_of_date

Union all LOAD_DATETIMEs from both satellites:

```
AS_OF_DATE
2026-01-01 09:00   ← Health
2026-01-01 10:00   ← Partner
2026-02-01 10:00   ← Partner (email changed)
2026-03-01 09:00   ← Health (mobile changed)
```

---

## Step 2: PIT table

One pointer per LOB satellite, resolved independently:

```
PARTY_HK  AS_OF_DATE           HEALTH_CONTACT_LDTS  PARTNER_CONTACT_LDTS
ABC       2026-01-01 09:00     2026-01-01 09:00     NULL
ABC       2026-01-01 10:00     2026-01-01 09:00     2026-01-01 10:00
ABC       2026-02-01 10:00     2026-01-01 09:00     2026-02-01 10:00
ABC       2026-03-01 09:00     2026-03-01 09:00     2026-02-01 10:00
```

Each pointer parked until its OWN satellite changes.

---

## Step 3: Mart (join back + resolve overlapping columns)

Join each pointer to its satellite, then COALESCE overlapping columns with explicit LOB priority:

```sql
select
    p.PARTY_HK,
    p.AS_OF_DATE as EFFECTIVE_FROM,
    lead(p.AS_OF_DATE) over (partition by p.PARTY_HK order by p.AS_OF_DATE) as EFFECTIVE_TO,

    -- Overlapping columns: pick winner (Health wins for mobile, Partner wins for email)
    coalesce(h.MOBILE_NUMBER, ptr.MOBILE_NUMBER)   as MOBILE_NUMBER,
    coalesce(ptr.EMAIL_ADDRESS, h.EMAIL_ADDRESS)   as EMAIL_ADDRESS,

    -- Non-overlapping: just take from owning LOB
    h.LANDLINE_NUMBER,
    ptr.FAX_NUMBER

from pit_party_contact p
left join sat_party_contact_health h
    on p.PARTY_HK = h.PARTY_HK and p.HEALTH_CONTACT_LDTS = h.LOAD_DATETIME
left join sat_party_contact_partner ptr
    on p.PARTY_HK = ptr.PARTY_HK and p.PARTNER_CONTACT_LDTS = ptr.LOAD_DATETIME
```

---

## Result

```
PARTY_HK  EFFECTIVE_FROM       EFFECTIVE_TO         MOBILE      EMAIL              LANDLINE  FAX
ABC       2026-01-01 09:00     2026-01-01 10:00     7010170101  ash@gmail.com      022-555   NULL
ABC       2026-01-01 10:00     2026-02-01 10:00     7010170101  ashraf@corp.com    022-555   022-999
ABC       2026-02-01 10:00     2026-03-01 09:00     7010170101  ashraf@newcorp.com 022-555   022-999
ABC       2026-03-01 09:00     NULL                 8010180101  ashraf@newcorp.com 022-555   022-999
```

Row-by-row:
- Row 1: Only Health loaded so far. Partner NULL → Health values used for everything.
- Row 2: Both loaded. Mobile from Health (priority). Email from Partner (priority). Each LOB's unique columns show their own.
- Row 3: Partner email changed. Health unchanged (pointer parked). Mobile still from Health.
- Row 4: Health mobile changed. Partner unchanged (pointer parked). Email still from Partner.

No phantom combinations — each LOB moves independently.

---

## Overlapping Column Conflict Resolution

| Column | Exists in | Priority rule | Reason |
|--------|-----------|---------------|--------|
| MOBILE_NUMBER | Both | Health wins | Member system is source-of-truth for personal mobile |
| EMAIL_ADDRESS | Both | Partner wins | Corporate/intermediary email more current |
| LANDLINE_NUMBER | Health only | N/A | No conflict |
| FAX_NUMBER | Partner only | N/A | No conflict |

Priority decision is a **business call**, made ONCE in the mart query, applied at READ time. Both LOB satellites retain their original values untouched — reversible anytime.

---

## Key Rules

1. Both LOBs MUST hash the same business key the same way (`'HUB_PARTY|' || <same_id>`)
2. Keep satellites separate per LOB — don't merge physically
3. `as_of_date` unions from ALL participating satellites
4. PIT has one pointer column per LOB satellite
5. COALESCE priority for overlapping columns = business decision in the mart, not in the vault
