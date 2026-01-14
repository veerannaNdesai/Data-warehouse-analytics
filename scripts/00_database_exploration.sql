
use Datawarehouse;


--Exploring the tables and their structures


select 
table_catalog,
table_type,
table_name,
table_schema
from INFORMATION_SCHEMA.TABLES;

SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    IS_NULLABLE, 
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';


