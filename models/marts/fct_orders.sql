{{
    config(
        materialized='incremental',
        unique_key='order_id',
        incremental_strategy='merge',
        on_schema_change='append_new_columns'
    )
}}

SELECT
    o.order_id,
    o.customer_id,
    o.payment_channel,
    o.order_status,
    o.gross_amount,
    COALESCE(c.fee_rate, 0) AS applied_fee_rate,
    ROUND(o.gross_amount * (1 - COALESCE(c.fee_rate, 0)), 2) AS net_settlement_amount,
    o.event_ts,
    o.updated_at,
    CURRENT_TIMESTAMP() AS dbt_updated_at
FROM {{ ref('stg_order_events') }} o
LEFT JOIN {{ ref('dim_payment_channels') }} c
    ON o.payment_channel = c.payment_channel

{% if is_incremental() %}
WHERE o.updated_at >= (
    SELECT DATEADD(day, -3, COALESCE(MAX(updated_at), '1970-01-01'::TIMESTAMP_NTZ))
    FROM {{ this }}
)
{% endif %}