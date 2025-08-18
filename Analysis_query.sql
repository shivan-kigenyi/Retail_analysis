--Creating Tables for our data
SELECT * 
FROM
	products;
	
CREATE TABLE IF NOT EXISTS customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    join_date DATE
);
	
CREATE TABLE IF NOT EXISTS sales (
    sale_id SERIAL PRIMARY KEY,
    product_id INT REFERENCES products(product_id),
    customer_id INT REFERENCES customers(customer_id),
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

SELECT *
FROM 
	sales;

--Inserting sample data into our database
INSERT INTO products (product_name, category, price) VALUES
('Laptop Pro 15', 'Electronics', 1200.00),
('Laptop Air 13', 'Electronics', 900.00),
('Wireless Mouse', 'Accessories', 25.00),
('Mechanical Keyboard', 'Accessories', 75.00),
('Smartphone X', 'Electronics', 800.00),
('Smartphone Y', 'Electronics', 650.00),
('Noise Cancelling Headphones', 'Accessories', 150.00),
('Office Chair', 'Furniture', 220.00),
('Standing Desk', 'Furniture', 500.00),
('LED Monitor 27"', 'Electronics', 300.00);

SELECT *
FROM products;

--insert sample customers
INSERT INTO customers (first_name, last_name, email, join_date) VALUES
('John', 'Doe', 'john.doe@email.com', '2024-01-15'),
('Jane', 'Smith', 'jane.smith@email.com', '2024-02-10'),
('Mike', 'Brown', 'mike.brown@email.com', '2024-03-05'),
('Emily', 'Davis', 'emily.davis@email.com', '2024-04-12'),
('Chris', 'Wilson', 'chris.wilson@email.com', '2024-05-09'),
('Sarah', 'Taylor', 'sarah.taylor@email.com', '2024-06-18'),
('David', 'Martinez', 'david.martinez@email.com', '2024-07-01'),
('Laura', 'Garcia', 'laura.garcia@email.com', '2024-08-23'),
('Robert', 'Anderson', 'robert.anderson@email.com', '2024-09-30'),
('Olivia', 'Thomas', 'olivia.thomas@email.com', '2024-10-15');

SELECT *
FROM customers;

-- insert sample sales
INSERT INTO sales (product_id, customer_id, quantity, sale_date) VALUES
(1, 1, 1, '2024-05-20'),
(2, 2, 1, '2024-06-11'),
(3, 3, 2, '2024-07-02'),
(4, 4, 1, '2024-07-15'),
(5, 5, 1, '2024-08-05'),
(6, 6, 2, '2024-08-19'),
(7, 7, 1, '2024-09-01'),
(8, 8, 1, '2024-09-12'),
(9, 9, 1, '2024-09-25'),
(10, 10, 2, '2024-10-05'),
(3, 1, 3, '2024-10-12'),
(5, 4, 1, '2024-10-20'),
(1, 7, 1, '2024-11-01'),
(6, 5, 1, '2024-11-09'),
(2, 8, 2, '2024-11-15');

SELECT *
FROM sales;

--Calculating total sales revenue
SELECT 
	SUM(p.price * s.quantity) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id;


--Calculating sales by product (Most popular)
SELECT 
	p.product_name,
	SUM(s.quantity) AS total_qty_sold,
	SUM(p.price * s.quantity) as total_revenue
FROM 
	sales s
JOIN 
	products p ON s.product_id = p.product_id
GROUP BY
	p.product_name
ORDER BY total_revenue DESC;


-- sales by customer (top spenders)
SELECT 
	c.first_name || ' ' || c.last_name AS customer_name,
	SUM(p.price * s.quantity) AS total_spent,
	COUNT(s.sale_id) AS purchases
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY customer_name
ORDER BY total_spent DESC;

--Monthly sales trends
SELECT
	TO_CHAR(s.sale_date, 'YYYY-MM') AS month,
	SUM(p.price * s.quantity) AS monthly_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY month 
ORDER BY month;

--Best selling category
SELECT 
	p.category,
	SUM(s.quantity) AS total_units_sold,
	SUM(p.price * s.quantity) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;


--Customer who bought more than 1 type of product
SELECT
	c.customer_id,
	c.first_name || ' ' || c.last_name AS customer_name,
	COUNT(DISTINCT s.product_id) AS different_products_bought
FROM sales s
JOIN customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, customer_name
HAVING COUNT(DISTINCT s.product_id)>1
ORDER BY different_products_bought DESC;

--Creating a dashboard
WITH 
monthly_sales AS (
    SELECT 
        TO_CHAR(s.sale_date, 'YYYY-MM') AS month,
        SUM(p.price * s.quantity) AS monthly_revenue
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
),
total_revenue_cte AS (
    SELECT SUM(monthly_revenue) AS total_revenue
    FROM monthly_sales
),
best_product AS (
    SELECT 
        p.product_name,
        SUM(p.price * s.quantity) AS total_revenue
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    GROUP BY p.product_name
    ORDER BY total_revenue DESC
    LIMIT 1
),
top_customer AS (
    SELECT 
        c.first_name || ' ' || c.last_name AS customer_name,
        SUM(p.price * s.quantity) AS total_spent
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN customers c ON s.customer_id = c.customer_id
    GROUP BY customer_name
    ORDER BY total_spent DESC
    LIMIT 1
)
SELECT 
    tr.total_revenue,
    bp.product_name AS best_selling_product,
    bp.total_revenue AS best_product_revenue,
    tc.customer_name AS top_customer_name,
    tc.total_spent AS top_customer_spent
FROM total_revenue_cte tr
CROSS JOIN best_product bp
CROSS JOIN top_customer tc;

