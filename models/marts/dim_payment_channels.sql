{{ config(materialized='table') }}

SELECT
    payment_channel,
    channel_category,
    settlement_sla_hours,
    fee_pct,
    ROUND(fee_pct / 100.0, 4) AS fee_rate,
    CURRENT_TIMESTAMP() AS refreshed_at
FROM {{ source('raw', 'payment_channels_raw') }}