{{ config(materialized='view') }}

WITH deduped AS (
    SELECT
        event_id,
        order_id,
        customer_id,
        UPPER(TRIM(payment_channel)) AS payment_channel,
        UPPER(TRIM(order_status)) AS order_status,
        gross_amount,
        event_ts,
        updated_at,
        ingested_at,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY updated_at DESC, ingested_at DESC
        ) AS row_num
    FROM {{ source('raw', 'order_events_raw') }}
    WHERE order_id IS NOT NULL
      AND gross_amount >= 0
)

SELECT
    event_id,
    order_id,
    customer_id,
    payment_channel,
    order_status,
    gross_amount,
    event_ts,
    updated_at
FROM deduped
WHERE row_num = 1