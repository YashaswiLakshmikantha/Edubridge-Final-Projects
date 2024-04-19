--  SQL Project :   E-commerce Sales Analysis

-- Step1 : Create Database and tables 



create database project; -- creating a database
show databases;   -- display all database
use project;



CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    unit_cost DECIMAL(10, 2)
);

---- Step2: Inserting Sample Data into all tables (For Demonstration)*\

INSERT INTO Customers VALUES
(1, 'John Doe', 'john@example.com', '123456789', 'New York', 'USA'),
(2, 'Jane Smith', 'jane@example.com', '987654321', 'Los Angeles', 'USA');

INSERT INTO Orders VALUES
(101, 1, '2024-01-10', 150.00),
(102, 2, '2024-02-15', 200.00);

INSERT INTO Order_Items VALUES
(1001, 101, 1, 2, 50.00),
(1002, 101, 2, 1, 100.00),
(1003, 102, 1, 3, 50.00);

INSERT INTO Products VALUES
(1, 'Product A', 'Electronics', 30.00),
(2, 'Product B', 'Clothing', 80.00);


-- to view all datas is inserted in table

select * from Customers;
select * from Products;
select * from Order_Items;
select * from Orders;

---- Task 1: Calculate Total Sales by Month:

SELECT 
    EXTRACT(YEAR FROM order_date) AS year,
    EXTRACT(MONTH FROM order_date) AS month,
    SUM(total_amount) AS total_sales
FROM Orders
GROUP BY year, month;

----- Task 2: Top Selling Products:

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 10;

----- Task 3: Customer Analysis:

------ Number of customers per country
SELECT 
    country,
    COUNT(DISTINCT customer_id) AS num_customers
FROM Customers
GROUP BY country;

--- Average order value per country
SELECT 
    c.country,
    AVG(o.total_amount) AS avg_order_value
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.country;

--- Country with the highest average order value
SELECT 
    country,
    AVG(total_amount) AS avg_order_value
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY country
ORDER BY avg_order_value DESC
LIMIT 1;


---- Task 4: Monthly Growth Rate:

SELECT 
    year,
    month,
    total_sales,
    (total_sales - LAG(total_sales, 1) OVER (ORDER BY year, month)) / LAG(total_sales, 1) OVER (ORDER BY year, month) AS growth_rate
FROM (
    SELECT 
        EXTRACT(YEAR FROM order_date) AS year,
        EXTRACT(MONTH FROM order_date) AS month,
        SUM(total_amount) AS total_sales
    FROM Orders
    GROUP BY year, month
) AS monthly_sales;


---- Task 5: Product Category Analysis:

SELECT 
    category,
    SUM(oi.quantity * p.unit_cost) AS total_sales_amount
FROM Products p
JOIN Order_Items oi ON p.product_id = oi.product_id
GROUP BY category
ORDER BY total_sales_amount DESC;


----------- Task 6 :repeat Customer rate
SELECT 
    COUNT(DISTINCT o1.customer_id) AS repeat_customers,
    COUNT(DISTINCT o2.customer_id) AS total_customers,
    COUNT(DISTINCT o1.customer_id) / COUNT(DISTINCT o2.customer_id) AS repeat_customer_rate
FROM Orders o1
JOIN Orders o2 ON o1.customer_id = o2.customer_id
WHERE o1.order_id <> o2.order_id;

------ Task 7: Customer Lifetime Value (CLV):
SELECT 
    customer_id,
    SUM(total_amount) AS total_spent,
    COUNT(DISTINCT order_id) AS num_orders,
    SUM(total_amount) / COUNT(DISTINCT order_id) AS avg_order_value,
    (SUM(total_amount) / COUNT(DISTINCT order_id)) * 12 AS annual_clv
FROM Orders
GROUP BY customer_id;

---- Task 8: Identify High-Value Customers:
SELECT 
    customer_id,
    SUM(total_amount) AS total_spent,
    COUNT(DISTINCT order_id) AS num_orders,
    (SUM(total_amount) / COUNT(DISTINCT order_id)) * 12 AS annual_clv
FROM Orders
GROUP BY customer_id
HAVING total_spent > 200; -- Adjust threshold as needed

