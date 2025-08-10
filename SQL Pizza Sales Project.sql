#Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
    
    
#Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
;    


#Identify the highest-priced pizza.

SELECT 
    name, pizza_id, price
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
ORDER BY price DESC
LIMIT 1
;



#Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS 'No. of pizzas'
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
LIMIT 1
;



#List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(orders_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5
;



#Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS quantity
FROM
    pizzas
        JOIN
    pizza_types ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC
;




#Determine the distribution of orders by hour of the day.

SELECT hour(order_time) AS Hour , COUNT(order_id) AS order_count FROM orders
GROUP BY hour(order_time) ;




#Join relevant tables to find the category-wise distribution of pizzas.

SELECT category , count(category) FROM pizza_types
GROUP BY category;




#Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0) AS avg_orders
FROM 
(SELECT orders.order_date , SUM(orders_details.quantity) AS quantity
FROM orders JOIN orders_details
ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS order_quanity;



# Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name AS Name,
    SUM(orders_details.quantity * pizzas.price) AS revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY Name
ORDER BY revenue DESC
LIMIT 3;




# Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category AS Category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price))
                FROM
                    orders_details
                        JOIN
                    pizzas ON orders_details.pizza_id = pizzas.pizza_id) * 100,
            2) AS Revenue
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY Category
ORDER BY Revenue
;





# Analyze the cumulative revenue generated over time.


SELECT order_date , ROUND(SUM(revenue) over(order by order_date),2) AS cum_revenue
FROM
(SELECT orders.order_date , SUM(orders_details.quantity*pizzas.price) AS revenue
FROM orders_details JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders ON orders.order_id = orders_details.order_id
GROUP BY orders.order_date) AS sales;




# Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT * 
FROM 
(SELECT category , name , revenue , rank() over(partition by category order by revenue desc) AS rn
FROM
(select pizza_types.category  , pizza_types.name , ROUND(SUM(orders_details.quantity*pizzas.price)) AS revenue
FROM orders_details JOIN pizzas ON orders_details.pizza_id = pizzas.pizza_id
JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP BY pizza_types.category , pizza_types.name) AS A) AS B
where rn<=3
;




