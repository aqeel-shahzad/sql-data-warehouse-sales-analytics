/*
===============================================================================
Script Name: 01_create_database.sql
Purpose: Create the SQL Server database and schemas for the data warehouse project.

This script:
1. Creates the DataWarehouse database
2. Creates the Bronze, Silver and Gold schemas
3. Sets up the layered architecture used throughout the project

Layers:
- Bronze: Raw source data loaded from CSV files
- Silver: Cleaned and standardised data
- Gold: Business-ready views for analytics and reporting
===============================================================================
*/

USE master;
GO

-- Drop and recreate the database if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create the Data Warehouse database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create schemas for each data warehouse layer
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO