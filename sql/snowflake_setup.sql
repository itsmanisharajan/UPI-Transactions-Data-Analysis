
------------------------------------------------------------
-- 1. STORAGE INTEGRATION
------------------------------------------------------------

USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE STORAGE INTEGRATION UPI_S3_STORAGE_INTEGRATION
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = 'S3'
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN =
        'arn:aws:iam::<AWS_ACCOUNT_ID>:role/SnowflakeS3UPIReadRole'
    STORAGE_ALLOWED_LOCATIONS =
        ('s3://manisha-upi-transactions-data/');


DESC INTEGRATION UPI_S3_STORAGE_INTEGRATION;


------------------------------------------------------------
-- 2. DATABASE AND SCHEMA
------------------------------------------------------------

CREATE OR REPLACE DATABASE UPI_TRANSACTIONS_DB;

USE DATABASE UPI_TRANSACTIONS_DB;

CREATE OR REPLACE SCHEMA RAW_DATA;

USE SCHEMA RAW_DATA;


------------------------------------------------------------
-- 3. RAW TABLE
------------------------------------------------------------

CREATE OR REPLACE TABLE UPI_TRANSACTIONS (
    TransactionID VARCHAR(50),
    TransactionDate DATE,
    Amount NUMBER(12,2),
    BankNameSent VARCHAR(100),
    BankNameReceived VARCHAR(100),
    RemainingBalance NUMBER(12,2),
    City VARCHAR(100),
    Gender VARCHAR(20),
    TransactionType VARCHAR(50),
    Status VARCHAR(50),
    TransactionTime TIME,
    DeviceType VARCHAR(50),
    PaymentMethod VARCHAR(50),
    MerchantName VARCHAR(100),
    Purpose VARCHAR(100),
    CustomerAge INTEGER,
    PaymentMode VARCHAR(50),
    Currency VARCHAR(10),
    CustomerAccountNumber NUMBER(15,0),
    MerchantAccountNumber NUMBER(15,0)
);


------------------------------------------------------------
-- 4. EXTERNAL STAGE
------------------------------------------------------------

CREATE OR REPLACE STAGE UPI_S3_STAGE
    URL = 's3://manisha-upi-transactions-data/'
    STORAGE_INTEGRATION = UPI_S3_STORAGE_INTEGRATION;


LIST @UPI_S3_STAGE;


------------------------------------------------------------
-- 5. LOAD CSV FROM S3 INTO THE RAW TABLE
------------------------------------------------------------
-- The CSV contains dates such as 30/06/2024.
-- DATE_FORMAT explicitly tells Snowflake to interpret them
-- as DD/MM/YYYY.

COPY INTO UPI_TRANSACTIONS
FROM @UPI_S3_STAGE
FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    DATE_FORMAT = 'DD/MM/YYYY'
)
ON_ERROR = 'ABORT_STATEMENT';


------------------------------------------------------------
-- 6. VALIDATE THE RAW LOAD
------------------------------------------------------------

SELECT COUNT(*) AS ROW_COUNT
FROM UPI_TRANSACTIONS;

SELECT *
FROM UPI_TRANSACTIONS
LIMIT 10;

SELECT
    MIN(TransactionDate) AS MIN_TRANSACTION_DATE,
    MAX(TransactionDate) AS MAX_TRANSACTION_DATE
FROM UPI_TRANSACTIONS;


------------------------------------------------------------
-- 7. CREATE ANALYTICS TABLE
------------------------------------------------------------
-- TransactionTime is converted to VARCHAR in the analytics layer
-- so Power BI can consume the column without the TIME parsing issue
-- encountered during the connector load.

CREATE OR REPLACE TABLE UPI_TRANSACTIONS_ANALYTICS AS
SELECT
    TRANSACTIONID,
    TRANSACTIONDATE,
    AMOUNT,
    BANKNAMESENT,
    BANKNAMERECEIVED,
    REMAININGBALANCE,
    CITY,
    GENDER,
    TRANSACTIONTYPE,
    STATUS,
    CAST(TRANSACTIONTIME AS VARCHAR) AS TRANSACTIONTIME,
    DEVICETYPE,
    PAYMENTMETHOD,
    MERCHANTNAME,
    PURPOSE,
    CUSTOMERAGE,
    PAYMENTMODE,
    CURRENCY,
    CUSTOMERACCOUNTNUMBER,
    MERCHANTACCOUNTNUMBER
FROM UPI_TRANSACTIONS;


------------------------------------------------------------
-- 8. VALIDATE THE ANALYTICS TABLE
------------------------------------------------------------

SELECT COUNT(*) AS ROW_COUNT
FROM UPI_TRANSACTIONS_ANALYTICS;

SELECT *
FROM UPI_TRANSACTIONS_ANALYTICS
LIMIT 10;


------------------------------------------------------------
-- 9. OPTIONAL: CHECK TABLES AND STAGE
------------------------------------------------------------

SHOW TABLES IN SCHEMA UPI_TRANSACTIONS_DB.RAW_DATA;

SHOW STAGES IN DATABASE UPI_TRANSACTIONS_DB;


------------------------------------------------------------
-- PROJECT OBJECTS
------------------------------------------------------------
-- S3 Bucket:
--   manisha-upi-transactions-data
--
-- IAM Role:
--   SnowflakeS3UPIReadRole
--
-- Storage Integration:
--   UPI_S3_STORAGE_INTEGRATION
--
-- Database:
--   UPI_TRANSACTIONS_DB
--
-- Schema:
--   RAW_DATA
--
-- Stage:
--   UPI_S3_STAGE
--
-- Raw Table:
--   UPI_TRANSACTIONS
--
-- Analytics Table:
--   UPI_TRANSACTIONS_ANALYTICS
--
-- Power BI connects directly to:
--   UPI_TRANSACTIONS_DB.RAW_DATA.UPI_TRANSACTIONS_ANALYTICS
