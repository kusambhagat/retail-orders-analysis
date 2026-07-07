CREATE DATABASE RetailOrdersDB;

USE RetailOrdersDB;

-- Product dimension table

CREATE TABLE dim_product (
ProductKey INT PRIMARY KEY,
ProductId VARCHAR(50) UNIQUE, 
Category VARCHAR(50), 
SubCategory VARCHAR(50) 
);

-- Geography dimension table 

CREATE TABLE dim_geography (
GeoKey INT PRIMARY KEY, 
City VARCHAR(50),  
State VARCHAR(50),  
Country VARCHAR(50),  
Region VARCHAR(50),  
PostalCode VARCHAR(20)
 );

-- Fact Orders Table

CREATE TABLE fact_orders(
OrderId INT PRIMARY KEY, 
OrderDate DATE, 
ShipMode VARCHAR(20), 
Segment VARCHAR(20), 
CostPrice DECIMAL(10,2),
ListPrice DECIMAL(10,2), 
Quantity INT, 
DiscountPercent DECIMAL(10,2),
GeoKey INT FOREIGN KEY REFERENCES dim_geography(GeoKey),
ProductKey INT FOREIGN KEY REFERENCES dim_product(ProductKey)
);