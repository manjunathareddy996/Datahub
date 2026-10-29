{% macro location_address_key(line1=none, line2=none, city=none, state=none, pincode=none) %}
{#-
    REFERENCE ONLY -- not invoked by any model. Prototype-only (AutomateDV evaluation, see
    docs/prototype_automate_dv/README.md).

    Documents the canonical composite-text-key rule for a HUB_LOCATION business key when a
    source table only carries free-text address fields and no location/pin code. Every
    stg2_*_location.sql / stg2_ba_hcp_pp_mem_dtls.sql-style model inlines this SAME
    normalisation (trim/upper/coalesce, pipe-delimited, NULL-if-all-empty) by hand inside
    its stage() derived_columns YAML rather than calling this macro -- embedding a Jinja
    macro call inside a fromyaml()-parsed string is fragile (the macro's own quotes/parens
    can break YAML parsing).

    IMPORTANT, not yet true of every caller: this only actually guarantees "same address ->
    same hash" for tables using the SAME number of address fields in the SAME order (e.g.
    the 5-field permanent/mailing case in stg2_bjaz_bandhan_medi_clam_address.sql). Tables
    with only 1 mapped field (BA_HCP_PP_MEM_DTLS's DC_ADDRESS, BJAZ_TPA_CLAIM_DETAILS_WS's
    PAYEE_ADDRESS) are inlined as a bare single-column key, NOT padded to this macro's
    fixed 5-slot pipe shape -- there's no case in this prototype's scope where that would
    cause two tables' rows to wrongly fail to match (they're different address domains:
    diagnostic-centre vs. payee vs. member vs. permanent/mailing), but it means those
    tables' keys are consistent WITHIN themselves, not literally identical in shape to this
    macro's output. If a future table needs to genuinely dedupe against one of these on the
    same field set, use this macro's full 5-slot shape, not the short form.

    Known limitation, accepted for the prototype: this is a literal-text match, not an
    address-resolution engine. "12 MG Road" and "12, M.G. Road" will hash to two different
    locations. Trim/upper is the only normalisation applied.
-#}
{%- set parts = [line1, line2, city, state, pincode] -%}
nullif(
    {%- for p in parts %}
    upper(trim(coalesce({{ p if p else "cast(null as varchar)" }}, ''))){% if not loop.last %} || '|' ||{% endif %}
    {%- endfor %},
'||||')
{% endmacro %}
