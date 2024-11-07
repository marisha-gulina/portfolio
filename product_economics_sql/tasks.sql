'''
ЗАДАЧА 1. 
Рассчитаем для каждого дня следующие показатели:
• Выручку, полученную в этот день.
• Суммарную выручку на текущий день.
• Прирост выручки, полученной в этот день, относительно значения выручки за предыдущий день. 
''' 
  
SELECT date,
       sum(price) as revenue,
       sum(sum(price)) OVER(ORDER BY date) as total_revenue,
       round(100 * (sum(price) - lag(sum(price), 1) OVER (ORDER BY date)) / lag(sum(price), 1) OVER (ORDER BY date)::decimal, 2) as revenue_change
FROM (SELECT order_id,
             creation_time::date as date,
             unnest(product_ids) as product_id
      FROM orders) t_product
  LEFT JOIN products using (product_id)
WHERE  order_id not in (SELECT order_id
                        FROM user_actions
                        WHERE action = 'cancel_order')
GROUP BY date
ORDER BY date


'''
ЗАДАЧА 2. 
Рассчитаем для каждого дня следующие метрики:
• Выручку на пользователя (ARPU) за текущий день.
• Выручку на платящего пользователя (ARPPU) за текущий день.
• Выручку с заказа, или средний чек (AOV) за текущий день.
''' 
with t_revenue as (SELECT date,
                          sum(price) as revenue
                   FROM (SELECT order_id,
                                creation_time::date as date,
                                unnest(product_ids) as product_id
                         FROM orders) t
                      LEFT JOIN products using (product_id)
                   WHERE order_id not in (SELECT order_id
                                          FROM user_actions
                                          WHERE action = 'cancel_order')
                   GROUP BY date
                   ORDER BY date), 
  
     t_users as (SELECT time :: date as date, count(distinct user_id) as users
                 FROM user_actions
                 GROUP BY date), 
  
     t_paying_users as (SELECT time :: date as date, count(distinct user_id) as paying_users
                        FROM user_actions
                        WHERE order_id not in (SELECT order_id
                                               FROM user_actions
                                               WHERE action = 'cancel_order')
                        GROUP BY date), 
  
     t_orders as (SELECT time::date as date, count(order_id)::int as orders
                             FROM user_actions
                             WHERE order_id not in (SELECT order_id
                                                    FROM user_actions
                                                    WHERE action = 'cancel_order')
                             GROUP BY date)
SELECT date,
       round(revenue/users, 2) as arpu,
       round(revenue/paying_users, 2) as arppu,
       round(revenue/orders, 2) as aov
FROM   t_revenue
    LEFT JOIN t_users using (date)
    LEFT JOIN t_paying_users using (date)
    LEFT JOIN t_orders using (date)
ORDER BY date


'''
ЗАДАЧА 3. 
Рассчитаем для каждого дня следующие показатели:
• Накопленную выручку на пользователя (Running ARPU).
• Накопленную выручку на платящего пользователя (Running ARPPU).
• Накопленную выручку с заказа, или средний чек (Running AOV).
''' 
with t_revenue as (SELECT date, sum(price) as revenue, count (distinct order_id) as orders
                   FROM (SELECT order_id, creation_time :: date as date, unnest(product_ids) as product_id
                         FROM   orders) t
                       LEFT JOIN products using (product_id)
                   WHERE order_id not in (SELECT order_id
                                          FROM user_actions
                                          WHERE action = 'cancel_order')
                   GROUP BY date
                   ORDER BY date), 
  
  t_users as (SELECT date,
                     sum (new_users) OVER (ORDER BY date) as running_users,
                     sum (paying_users) OVER (ORDER BY date) as running_paying_users
              FROM (SELECT date, count(user_id) as new_users
                    FROM (SELECT user_id, min(time :: date) as date
                          FROM user_actions
                          GROUP BY user_id) t_user
                    GROUP BY date) t_new_users
                  LEFT JOIN (SELECT date, count (distinct user_id) as paying_users
                             FROM (SELECT user_id, min(time)::date as date
                                   FROM user_actions
                                   WHERE order_id not in (SELECT order_id
                                                          FROM user_actions
                                                          WHERE action = 'cancel_order')
                                   GROUP BY user_id) t1
                              GROUP BY date) t_paying_users using(date))
SELECT date,
       round (sum (revenue) OVER (ORDER BY date) :: decimal / running_users, 2) as running_arpu,
       round (sum (revenue) OVER (ORDER BY date) :: decimal / running_paying_users, 2) as running_arppu,
       round (sum (revenue) OVER (ORDER BY date) :: decimal / sum (orders) OVER (ORDER BY date rows unbounded preceding), 2) as running_aov
FROM   t_revenue
    LEFT JOIN t_users using (date)
ORDER BY date;


'''
ЗАДАЧА 4. 
Рассчитаем для каждого товара следующие показатели:
• Суммарную выручку, полученную от продажи этого товара за весь период.
• Долю выручки от продажи этого товара в общей выручке, полученной за весь период.
''' 

SELECT product_name,
       sum (revenue) as revenue,
       sum (share_in_revenue) as share_in_revenue
FROM (SELECT case when round (100*revenue::decimal/sum (revenue) OVER (), 2) < 0.5 then 'ДРУГОЕ'
             else name end as product_name,
             revenue,
             round (100*revenue::decimal/sum (revenue) OVER (), 2) as share_in_revenue
        FROM (SELECT name,
                       sum(price) as revenue
              FROM (SELECT date, order_id, product_id, name, price
                    FROM (SELECT date(creation_time) as date, order_id, unnest(product_ids) as product_id
                          FROM orders
                          WHERE order_id not in (SELECT order_id
                                                 FROM user_actions
                                                 WHERE action = 'cancel_order')) as t_order
                       LEFT JOIN products using (product_id)) as t_products
              GROUP BY name) as t_products_revenue) as t_products_revenue_share
GROUP BY product_name
ORDER BY revenue desc;
