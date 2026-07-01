create or replace view suport_ceo as (
with First_geo as(
select 
	ci.customer_id as "Customer ID",
	os.order_id as "Order ID",
	lower(ci.customer_city) as "City",
	upper(ci.customer_state) as "State"
from customers_inf as ci
join order_status os 
	on ci.customer_id = os.customer_id)
select
	fg."Customer ID",
	fg."Order ID",
	si.seller_id as "Seller ID",
	fg."City",
	fg."State"
from First_geo as fg
join sell_inf si
	on fg."Order ID" = si.order_id);
