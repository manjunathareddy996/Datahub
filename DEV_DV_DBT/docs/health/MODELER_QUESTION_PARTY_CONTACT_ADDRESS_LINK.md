# Question for the modeler — `SAT_PARTY_CONTACT_ADDRESS_LINK` parentage

Follow-up to Phase 6b / M4 (`SAT_PARTY_ADDRESS_USAGE` removed, canonical route =
`LNK_PARTY_LOCATION` + `SAT_PARTY_CONTACT_ADDRESS_LINK` + `SAT_COMMON_ADDRESS`).

**In `data_v5.js`, `SAT_PARTY_CONTACT_ADDRESS_LINK`'s parent is `HUB_PARTY`.** Is that
correct, or should it be `LNK_PARTY_LOCATION`?

As currently keyed on `HUB_PARTY` (childkey `Address Usage Type + Sequence`), the satellite
has no attribute that identifies *which* location a given usage row refers to — it carries
usage metadata (verified indicator, ownership type, years at address, proof type, etc.) but
no `Location Reference`. That's fine when a party has exactly one address, but breaks for a
party with more than one at genuinely different locations — a real case in Health source
data (e.g. `BJAZ_BANDHAN_MEDI_CLAM`'s permanent vs. mailing address blocks are different
physical addresses). With `HUB_PARTY` as parent, there's no stored key anywhere that ties
the "mailing" usage row to Location B specifically rather than Location A — `LNK_PARTY_LOCATION`
returns an unordered set of a party's locations, and the satellite returns an unordered set
of usage labels, with nothing connecting a given label to a given location.

If the satellite were instead parented on **`LNK_PARTY_LOCATION`** (keyed on the link's own
hash, which already encodes `party_hkey + location_hkey`, plus the same
`Address Usage Type + Sequence` child key), each usage row would resolve to a specific
location automatically — no separate location-reference attribute needed. That's also the
standard Data Vault pattern for a satellite describing context *about a relationship*, and
would match how this model already parents `SAT_LNK_ROLE_AGENT` /
`SAT_LNK_POLICY_PARTY_ROLE` on their links rather than on a member hub.

One more data point either way: the satellite's own name ends in `_LINK`, but this model's
convention for link-parented satellites elsewhere is a `SAT_LNK_` *prefix*
(`SAT_LNK_ROLE_AGENT`, `SAT_LNK_POLICY_PARTY_ROLE`), not a `_LINK` suffix — so the naming
doesn't clearly confirm either reading, which is part of why this needs a direct answer
rather than an assumption on our side.

**Please confirm:** should `SAT_PARTY_CONTACT_ADDRESS_LINK`'s parent be `LNK_PARTY_LOCATION`
instead of `HUB_PARTY`? If `HUB_PARTY` is intentional, how is a specific usage type meant to
resolve to a specific location when a party has more than one address? Blocks the M4 build
for any party with multiple addresses until resolved.
