create or replace view "Eeeee-c".Logistic as (
with time_stamp as(
select 
	os.order_id,
	os.order_status,
	os.order_purchase_timestamp,
	os.order_approved_at,
	os.order_delivered_carrier_date,
	os.order_delivered_customer_date,
	os.order_estimated_delivery_date,
	row_number() over(
		partition by os.order_id
		order by os.order_purchase_timestamp) as "rn_number"
from "Eeeee-c".order_status os 
join "Eeeee-c".sell_inf as si
	on os.order_id = si.order_id 
where os.order_status in ('delivered','shipped')),
----
grouping_a as(
select
	ts.order_id,
	ts.order_status,
	ts.order_purchase_timestamp,
	----
	extract(epoch from
		(to_timestamp(order_approved_at, 'YYYY-MM-DD H24:MI')
		- to_timestamp(order_purchase_timestamp, 'YYYY-MM-DD H24:MI')))/86400 as "purchase-approved",
	ts.order_approved_at,
	----
	extract(epoch from
		(to_timestamp(order_delivered_carrier_date, 'YYYY-MM-DD H24:MI')
		- to_timestamp(order_approved_at, 'YYYY-MM-DD H24:MI')))/86400 as "approved-carrier",
	ts.order_delivered_carrier_date,
	----
	case
		when ts.order_status = 'shipped' then null
		else extract(epoch from
		(to_timestamp(order_delivered_customer_date, 'YYYY-MM-DD H24:MI')
		- to_timestamp(order_delivered_carrier_date, 'YYYY-MM-DD H24:MI')))/86400 end as "carrier-customer",
	ts.order_delivered_customer_date,
	----
	case
		when ts.order_status = 'shipped' then null
		else extract(epoch from
		(to_timestamp(order_estimated_delivery_date, 'YYYY-MM-DD H24:MI')
		- to_timestamp(order_delivered_customer_date, 'YYYY-MM-DD H24:MI')))/86400 end as "customer-estimated",
	ts.order_estimated_delivery_date,
	----
	case
		when ts.order_status = 'shipped' then null
		else extract(epoch from
		(to_timestamp(order_delivered_customer_date, 'YYYY-MM-DD H24:MI')
		- to_timestamp(order_purchase_timestamp, 'YYYY-MM-DD H24:MI')))/86400 end as "lead",
	ts.rn_number
from time_stamp as ts)
----
select 
	ga.order_id as "Order ID",
	ss."Seller ID",
	ss."City",
	ss."State",
	to_timestamp(ga.order_purchase_timestamp, 'YYYY-MM-DD H24:MI') as "Purchase time",
	ga."purchase-approved" as "Purchase|Approved",
	ga.order_approved_at as "Approved",
	ga."approved-carrier" as "Approved|Carrier",
	ga.order_delivered_carrier_date as "Carrier time",
	ga."carrier-customer" as "Carrier|Customer",
	ga.order_delivered_customer_date as "Customer time",
	ga."customer-estimated" as "Customer|Estimated",
	ga.order_estimated_delivery_date as "Estimated time",
	ga."lead" as "Lead time",
	case
		when ga."customer-estimated" >= 0 then 'On time'
		else 'Delayed'
	end as "Delivery on time"
from grouping_a as ga
join "Eeeee-c".suport_ceo as ss
	on ga.order_id = ss."Order ID"
where rn_number = 1
	and ga."approved-carrier" >= 0
	and ga."carrier-customer" > -1000 );
