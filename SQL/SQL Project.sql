#---Question 1 -----------------
SELECT product_class_code, product_id, product_desc, product_price,
CASE
	WHEN product_class_code = '2050' THEN PRODUCT_PRICE+2000
	WHEN product_class_code = '2051' THEN PRODUCT_PRICE+500
    WHEN product_class_code = '2052' THEN PRODUCT_PRICE+600
    ELSE PRODUCT_PRICE
END AS 'New_Price'
from Product order by product_class_code desc;

#-- Question 2 --

select pRODUCT_class.product_class_desc, product_id, product_desc, product_quantity_avail,
CASE 
	WHEN product_class_desc='Electronics' OR product_class_desc='Computer' 
    THEN 
		(CASE
			WHEN product_quantity_avail <=10 THEN 'LOW STOCK'
			WHEN product_quantity_avail BETWEEN 11 and 30  THEN 'IN STOCK'
			WHEN product_quantity_avail >=31  THEN 'IN STOCK'
			ELSE 'ENOUGH STOCK'
		END)
    WHEN PRODUCT_CLASS_DESC IN ('Stationery','Clothes')
	THEN 
		(CASE 
			WHEN (PRODUCT_QUANTITY_AVAIL <=20) THEN 'LOW STOCK' 
			WHEN (PRODUCT_QUANTITY_AVAIL BETWEEN 21 and 80) THEN 'IN STOCK' 
			WHEN (PRODUCT_QUANTITY_AVAIL >=81) THEN 'ENOUGH STOCK' 
			WHEN (PRODUCT_QUANTITY_AVAIL=0) THEN 'OUT OF STOCK' 
		END)
	ELSE 
			(CASE 
			WHEN (PRODUCT_QUANTITY_AVAIL <=15) THEN 'LOW STOCK' 
			WHEN (PRODUCT_QUANTITY_AVAIL BETWEEN 16 and 50) THEN 'IN STOCK' 
			WHEN (PRODUCT_QUANTITY_AVAIL >=51) THEN 'ENOUGH STOCK' 
			WHEN (PRODUCT_QUANTITY_AVAIL=0) THEN 'OUT OF STOCK' 
			END)
END INVENTORY_STATUS    
from product_class JOIN PRODUCT ON product_class.PRODUCT_CLASS_CODE=PRODUCT.PRODUCT_CLASS_CODE;

#-- Question 3 --
SELECT COUNTRY, COUNT(CITY) AS CITY_VALUE FROM ADDRESS WHERE COUNTRY !='USA' AND COUNTRY != 'MALAYSIA' group by COUNTRY HAVING CITY_VALUE > 1 ORDER BY CITY desc;

#-- Question 4 --
Select  a.customer_id,
		concat(a.customer_fname,' ', a.customer_lname) as customer_name,
        b.city,
        b.pincode,
        c.order_id,
        f.product_class_desc,
        e.product_desc,
        d.product_quantity*e.product_price as subtotal 
from online_customer a 
	Join 
		address b 
        on a.address_id=b.address_id 
	join 
		order_header c 
        on a.customer_id=c.customer_id
	join 
		order_items d 
        on c.order_id=d.order_id
	JOIN 
		product e 
		on d.product_id = e.product_id
	JOIN 
		product_class f
		on e.PRODUCT_CLASS_CODE = f.PRODUCT_CLASS_CODE
where pincode not like '%0%' and c.ORDER_STATUS='Shipped' order by customer_name, c.order_date,subtotal;

#-- Question 5 --

SELECT * FROM 
(SELECT a.PRODUCT_ID, b.PRODUCT_DESC,SUM(a.product_quantity) AS TOTAL_QUANTITY 
FROM ORDER_ITEMS a 
JOIN 
	PRODUCT b 
    ON a.product_id=b.product_id 
    GROUP BY 1,2) new_table
ORDER BY total_quantity DESC LIMIT 1;

#-- Question 6 --
SELECT
	a.CUSTOMER_ID,
	a.CUSTOMER_FNAME,
	a.CUSTOMER_EMAIL,
	c.ORDER_ID,
	e.PRODUCT_DESC,
	d.PRODUCT_QUANTITY,
	(d.PRODUCT_QUANTITY*e.PRODUCT_PRICE) AS SUBTOTAL
FROM
	ONLINE_CUSTOMER AS a 
left JOIN 
    ORDER_HEADER AS c
    ON a.CUSTOMER_ID = c.CUSTOMER_ID
left JOIN 
	ORDER_ITEMS AS d
	ON c.ORDER_ID = d.ORDER_ID
left JOIN 
	PRODUCT AS e
	ON d.PRODUCT_ID = e.PRODUCT_ID;

#-- Question 7 --
select CARTON_ID,(len*width*height) AS CARTON_VOLUME FROM carton having carton_volume > ((SELECT SUM((a.PRODUCT_QUANTITY*b.len*b.width*b.height)) as TOTAL_VOLUME
FROM order_items AS a JOIN product AS b ON a.product_id=b.product_id where ORDER_ID=10006)) order by carton_volume limit 1;

#-- Question 8 --
SELECT a.CUSTOMER_ID, concat(a.customer_fname,' ', a.customer_lname) as customer_name,b.ORDER_ID,SUM(c.PRODUCT_QUANTITY) as PRODUCT_QUANTITY
FROM online_customer as a JOIN order_header as b on a.CUSTOMER_ID=b.CUSTOMER_ID JOIN order_items as c ON b.order_id=c.order_id
where b.order_status='Shipped' and b.order_id IN (SELECT ORDER_ID FROM order_items GROUP BY ORDER_ID HAVING SUM(PRODUCT_QUANTITY)>10) and b.payment_mode in ('Credit Card','Net Banking') 
GROUP BY ORDER_ID ; 
  

#-- Question 9 --
SELECT a.ORDER_ID, b.CUSTOMER_ID,  concat(b.customer_fname,' ', b.customer_lname) as customer_name,SUM(c.PRODUCT_QUANTITY) AS TOTAL_QUANTITY_OF_PRODUCTS
from order_header as a JOIN online_customer as b
on a.customer_id=b.customer_id 
LEFT JOIN order_items as c on a.order_id=c.order_id 
where a.ORDER_ID>10030 and a.order_status='Shipped' and B.customer_fname like 'A%' GROUP BY a.ORDER_ID;

#-- Question 10 --
Select c.PRODUCT_CLASS_DESC,sum(PRODUCT_QUANTITY) as TOTAL_QUANTITY ,sum(b.PRODUCT_PRICE*a.PRODUCT_QUANTITY) as TOTAL_VALUE
FROM order_items as a JOIN product as b on a.product_id = b.product_id 
JOIN product_class as c ON b.PRODUCT_CLASS_CODE = c.PRODUCT_CLASS_CODE 
JOIN order_header as d ON a.ORDER_ID=d.ORDER_ID
JOIN online_customer as e ON d.CUSTOMER_ID=e.CUSTOMER_ID
JOIN address as f ON e.ADDRESS_ID=f.ADDRESS_ID
WHERE COUNTRY NOT IN ('India','USA')
GROUP BY PRODUCT_CLASS_DESC
ORDER BY Total_Quantity DESC
LIMIT 1;