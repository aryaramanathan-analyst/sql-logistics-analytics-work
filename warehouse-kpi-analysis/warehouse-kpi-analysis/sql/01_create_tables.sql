-- Warehouse Operations and KPI Analysis
--Order Fulfillment and Delivery Performance Queries
--Business requirement - A consolidated report showing how effectively warehouses fulfill customer orders or store orders depending on data
--Order Fulfillment and Delivery Performance
WITH order_summary AS (
    SELECT
    oli.order_id,
    ord.num_of_item,
    ord.planned_ship_at,
    ord.status,
	COUNT(DISTINCT oli.id) FILTER (
        WHERE oli.status <> 'Cancelled'
    ) AS total_order_qty,

    COUNT(DISTINCT oli.id) FILTER (
        WHERE oli.shipped_at IS NOT NULL
          AND oli.status <> 'Cancelled'
    ) AS total_fulfilled_qty

FROM core.order_items AS oli

INNER JOIN core.orders AS ord
    ON ord.order_id = oli.order_id

INNER JOIN core.inventory_items AS ic
    ON ic.id = oli.inventory_item_id

INNER JOIN core.distribution_centers AS dc
    ON dc.id = ic.product_distribution_center_id
GROUP BY
    oli.order_id,
    ord.num_of_item,
    ord.planned_ship_at,
    ord.status

ORDER BY
    oli.order_id
)
SELECT
    order_id,
    num_of_item,
    planned_ship_at,
	status,
	total_fulfilled_qty,
	total_order_qty,
	ROUND(((total_fulfilled_qty/nullif(total_order_qty,0))*100.0),0) as fulfilment_percentage
    -- percentage calculation
FROM order_summary;

-- Author: Arya Ramanathan
