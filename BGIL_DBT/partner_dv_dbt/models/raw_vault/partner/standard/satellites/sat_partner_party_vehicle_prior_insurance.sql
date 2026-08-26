{{
    config(
        materialized='incremental',
        incremental_strategy='merge',
        unique_key=['PARTY_HKEY', 'HASHDIFF']
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_VEHICLE_PRIOR_INSURANCE (HUB_PARTY grain) -- union of 8 table(s).
-- Custom SQL with VARCHAR casts to handle dirty source data.

WITH source_data AS (
    SELECT
        a.PARTY_HKEY,
        a.HASHDIFF,
        a.CONTINUITYINDICATOR::VARCHAR AS CONTINUITYINDICATOR,
        a.PREVIOUSEXPIRYDATE::VARCHAR AS PREVIOUSEXPIRYDATE,
        a.PREVIOUSINSURERNAME::VARCHAR AS PREVIOUSINSURERNAME,
        a.PREVIOUSPOLICYNUMBER::VARCHAR AS PREVIOUSPOLICYNUMBER,
        a.PREVIOUSSUMINSURED::VARCHAR AS PREVIOUSSUMINSURED,
        a.LOAD_DATETIME,
        a.RECORD_SOURCE
    FROM {{ ref('stg2_std_union__party_vehicle_prior_insurance') }} AS a
    WHERE a.PARTY_HKEY IS NOT NULL
),

{% if is_incremental() -%}
latest_records AS (
    SELECT
        current_records.PARTY_HKEY,
        current_records.HASHDIFF,
        current_records.LOAD_DATETIME
    FROM {{ this }} AS current_records
    JOIN (
        SELECT DISTINCT source_data.PARTY_HKEY
        FROM source_data
    ) AS source_records
        ON source_records.PARTY_HKEY = current_records.PARTY_HKEY
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY current_records.PARTY_HKEY
        ORDER BY current_records.LOAD_DATETIME DESC
    ) = 1
),
{%- endif %}

unique_source_records AS (
    SELECT
        sd.PARTY_HKEY,
        sd.HASHDIFF,
        sd.CONTINUITYINDICATOR,
        sd.PREVIOUSEXPIRYDATE,
        sd.PREVIOUSINSURERNAME,
        sd.PREVIOUSPOLICYNUMBER,
        sd.PREVIOUSSUMINSURED,
        sd.LOAD_DATETIME,
        sd.RECORD_SOURCE
    FROM source_data AS sd
    {% if is_incremental() -%}
    LEFT OUTER JOIN latest_records AS lr
        ON sd.PARTY_HKEY = lr.PARTY_HKEY
    {%- endif %}
    QUALIFY sd.HASHDIFF !=
        LAG(sd.HASHDIFF, 1,
            {% if is_incremental() -%}
            COALESCE(lr.HASHDIFF, CAST('FFFFFFFF' AS BINARY(16)))
            {%- else -%}
            CAST('FFFFFFFF' AS BINARY(16))
            {%- endif %}
        ) OVER (
            PARTITION BY sd.PARTY_HKEY
            ORDER BY sd.LOAD_DATETIME ASC
        )
),

records_to_insert AS (
    SELECT
        usr.PARTY_HKEY,
        usr.HASHDIFF,
        usr.CONTINUITYINDICATOR,
        usr.PREVIOUSEXPIRYDATE,
        usr.PREVIOUSINSURERNAME,
        usr.PREVIOUSPOLICYNUMBER,
        usr.PREVIOUSSUMINSURED,
        usr.LOAD_DATETIME,
        usr.RECORD_SOURCE
    FROM unique_source_records AS usr
)

SELECT * FROM records_to_insert
