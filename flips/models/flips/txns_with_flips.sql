{{ config(
    materialized='table',
    post_hook="COPY {{ this }} TO '{{ var('modelled_data') }}output.parquet' (FORMAT PARQUET)"
) }}

with cte1 as (
select
	unique_id,
	price_paid,
	cast(deed_date as date) as deed_date,
	postcode,
	property_type,
	new_build,
	estate_type,
	saon,
	paon,
	street,
	locality,
	town,
	district,
	county,
	transaction_category,
  concat(paon,' ', street, ' ', postcode) as street_address
from read_csv({{ source('source_prop_data', 'source_prop_data') }}, auto_detect=True)
)
,cte2 as (

  select street_address, count(*) as cnt, case when count(*) > 1 then 'Y' else 'N' end as flipped
  from cte1
  group by all
)
, cte3 as (
  -- select a.street_address, price_paid, postcode, deed_date, town, district, b.cnt as cnt 
  select 
  	a.street_address, 
	a.price_paid, 
	a.postcode, 
	a.deed_date, 
	a.town, 
	a.paon, 
	a.street, 
	b.cnt, 
	b.flipped, 
  	price_paid - lag(price_paid) over (partition by a.street_address order by deed_date asc) as price_difference,
  	lag(price_paid) over (partition by a.street_address order by deed_date asc) as previous_price_paid,
    lag(deed_date) over (partition by a.street_address order by deed_date asc) as previous_deed_date
  from cte1 a
inner join cte2 b on a.street_address=b.street_address
)

select *,
deed_date - previous_deed_date as date_difference,
case when previous_deed_date = deed_date then 'unreliable' else 'na' end as reliability
from cte3