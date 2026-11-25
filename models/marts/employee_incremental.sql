{{
  config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
  )
}}

select
    id,
    name,
    department,
    city,
    salary,
    current_timestamp() as dbt_loaded_at
from {{ ref('stg_employee') }}

{% if is_incremental() %}
  -- on later runs, only pick up employees not already in the target table
  where id > (select coalesce(max(id), 0) from {{ this }})
{% endif %}
