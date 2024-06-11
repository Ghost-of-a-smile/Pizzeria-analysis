# Проект: Анализ пиццерии

![Static Badge](https://img.shields.io/badge/Power%20BI-yellow?style=flat-square)
![Static Badge](https://img.shields.io/badge/SQL-MySQL%20Workbench%208.0%20CE-auto?style=flat-square&logoSize=auto&label=SQL&color=blue)
![Static Badge](https://img.shields.io/badge/Excel-darkgreen?style=flat-square&logoSize=auto)

## Задача проекта

На данной [площадке](https://www.mavenanalytics.io/data-playground) выкладывается множество датасетов, в том числе [этот](https://www.mavenanalytics.io/blog/maven-pizza-challenge). По ссылке можно ознакомиться с более подробным описанием требуемого проекта, однако если кратко:

Имеется Excel файл *["Data Model - Pizza Sales"](https://docs.google.com/spreadsheets/d/1rueHQ3gU4kQCybTGwHb0xxczX73DJUFu/edit?usp=sharing&ouid=104109469884925505076&rtpof=true&sd=true)*, с помощью которого необходимо ответить на следующие бизнес-вопросы:

        1. В какие дни и время мы чаще всего заняты?
        2. Сколько пицц мы готовим в периоды пиковой нагрузки?
        3. Какие пиццы у нас продаются лучше всего и хуже всего?
        4. Какова наша средняя стоимость заказа?
        5. Насколько хорошо мы используем наши места? (у нас 15 столов и 60 мест)

## Описание реализации проекта

### SQL diagram app

Для начала использовался [конструктор](https://app.quickdatabasediagrams.com/#/) для написания построения диаграмм будущей БД. ([Результат](https://github.com/Ghost-of-a-smile/Pizzeria-analysis/blob/main/Diagrams.png))
   
### MySQL Workbench

Затем было необходимо создать саму БД в любой СУБД, я использовал *MySQL Workbench*. Код создания таблиц по диаграммам выглядит следующим образом:
   
```SQL
-- Creating tables for futher downloading data from excel
CREATE TABLE orders(order_id  INT NOT NULL AUTO_INCREMENT,
					order_date DATE,
                    order_time TIME,
                    PRIMARY KEY(order_id));
                    
CREATE TABLE order_details(order_details_id INT NOT NULL AUTO_INCREMENT,
						   order_id INT,
                           quantity INT,
                           total_price DECIMAL(5,2),
                           PRIMARY KEY(order_details_id),
                           FOREIGN KEY(order_id) REFERENCES orders(order_id));
                           
CREATE TABLE pizza_types(pizza_id VARCHAR(50),
						 pizza_name VARCHAR(75),
                         pizza_category VARCHAR(25),
                         pizza_ingredients VARCHAR(200),
						 PRIMARY KEY(pizza_id));
                       
CREATE TABLE pizzas(pizza_details_id INT NOT NULL AUTO_INCREMENT,
					pizza_id VARCHAR(50),
					pizza_size ENUM('XXL', 'XL', 'L', 'M', 'S'),
					unit_price DECIMAL(4,2),
					PRIMARY KEY(pizza_details_id),
					FOREIGN KEY(pizza_id) REFERENCES pizza_types(pizza_id),
                    FOREIGN KEY(pizza_details_id) REFERENCES order_details(order_details_id));   
```

Далее начался процесс написания SQL-скрипта уже для получения ответов из датасета на поставленные вопросы, а также формирование запросов для дальнейшей выгрузки в инструмент визуализации. С остальной частью скрипта можно ознакомиться в самом [SQL файле](https://github.com/Ghost-of-a-smile/Pizzeria-analysis/blob/main/SQL%20script.sql) (Необходим установленный [MySQL Workbench](https://www.mysql.com/products/workbench/)) или [в обычном текстовом документе](https://github.com/Ghost-of-a-smile/Pizzeria-analysis/blob/main/SQL%20script.txt).

### Power BI

Наконец, завершающей частью проекта стало логическое связывание выгрузок из SQL и построение динамичных графиков, а также создание некоторого дизайна самого дашборда, который с легкостью наглядно бы ответил на все вопросы. Для этого я воспользовался одним из наиболее популярных и функциональных приложений *Power BI*. Итоговую работу в Power BI можно посмотреть [здесь](https://github.com/Ghost-of-a-smile/Pizzeria-analysis/blob/main/Dashboard%20of%20pizzeria%20analysis.pbix) (необходим установленный [Power BI](https://powerbi.microsoft.com/ru-ru/desktop/)) или [здесь](https://github.com/Ghost-of-a-smile/Pizzeria-analysis/blob/main/Dashboard%20presentation.mp4).
