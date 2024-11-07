
Цель работы

Провести анализ экономической эффективности сервиса по доставке продуктов путем написания SQL-запросов и построения дашбордов в Redash.

Ход исследования

Посчитать выручку, чтобы узнать, какой доход приносит сервис.  

Посчитать, сколько в среднем потребители готовы платить за услуги сервиса доставки (ARPU, ARPPU и AOV).

Посчитать динамический ARPU, ARPPU и AOV, чтобы проследить, как он менялся на протяжении времени с учётом поступающих данных.

Выяснить, какие товары пользуются наибольшим спросом и приносят основной доход. 

 

База данных:

user_actions - действия пользователя с заказами (user_id, order_id, action, time)

courier_actions - действия курьера с заказами (courier_id, order_id, action, time)  

orders - информация о заказе (order_id, creation_time, product_ids)

users - информация о пользователе (user_id, birth_date, sex)

couriers - информация о курьерах (courier_id, birth_date, sex)  

products - информация о продукт (product_id, name, price)  

<img src="https://github.com/marisha-gulina/portfolio/blob/main/assets/sql_task_1.png" width="1040" height="400" />

<img src="https://github.com/marisha-gulina/portfolio/blob/main/assets/sql_task_2-3.png" width="1040" height="400" />

<img src="https://github.com/marisha-gulina/portfolio/blob/main/assets/sql_task_4.png" width="1040" height="400" />