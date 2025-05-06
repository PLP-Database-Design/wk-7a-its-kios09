-- Question 1: Achieving 1NF (First Normal Form) 🛠️
-- Task: Transform the ProductDetail table into 1NF
-- Each row will represent a single product for an order

-- Create a normalized table that stores one product per order
CREATE TABLE ProductDetail_1NF (
    OrderID INT,
    CustomerName VARCHAR(100),
    Product VARCHAR(100)
);

-- Insert data into the 1NF table by splitting products into separate rows
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT 
    OrderID, 
    CustomerName, 
    TRIM(product) AS Product
FROM (
    SELECT 
        OrderID, 
        CustomerName, 
        SUBSTRING_INDEX(SUBSTRING_INDEX(Products, ',', n.n), ',', -1) AS product
    FROM 
        ProductDetail 
    CROSS JOIN 
        (SELECT 1 AS n UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5) n
    WHERE 
        n.n <= (LENGTH(Products) - LENGTH(REPLACE(Products, ',', '')) + 1)
) AS product_list;

-- Question 2: Achieving 2NF (Second Normal Form) 🧩
-- Task: Transform the OrderDetails table into 2NF by removing partial dependencies

-- Step 1: Create a Customers table to store CustomerName and CustomerID (to eliminate partial dependency)
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerName VARCHAR(100)
);

-- Step 2: Insert data into the Customers table
INSERT INTO Customers (CustomerName)
SELECT DISTINCT CustomerName FROM OrderDetails;

-- Step 3: Create an Orders table to store OrderID and CustomerID
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Step 4: Insert data into the Orders table
INSERT INTO Orders (OrderID, CustomerID)
SELECT DISTINCT OrderID, c.CustomerID
FROM OrderDetails o
JOIN Customers c ON o.CustomerName = c.CustomerName;

-- Step 5: Create an OrderItems table to store OrderID, Product, and Quantity
CREATE TABLE OrderItems (
    OrderID INT,
    Product VARCHAR(100),
    Quantity INT,
    PRIMARY KEY (OrderID, Product),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Step 6: Insert data into the OrderItems table
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity FROM OrderDetails;
