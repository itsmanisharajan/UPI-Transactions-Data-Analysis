
# UPI Transactions Data Analysis

An end-to-end UPI transaction analytics project built using **AWS S3, Snowflake, SQL, and Power BI**. The project demonstrates data ingestion, cloud-based storage, SQL processing, and interactive business analysis through Power BI.

## Project Overview

This project analyzes UPI transaction data to identify transaction trends, payment patterns, customer behavior, bank-wise activity, and other business insights.

The data is stored in **Amazon S3**, loaded into **Snowflake** using a secure storage integration and external stage, processed using SQL, and connected directly to **Power BI** for interactive analysis and visualization.

## Data Flow

```text
UPI Transaction Dataset
        ↓
CSV File
        ↓
Amazon S3
        ↓
AWS IAM Role
        ↓
Snowflake Storage Integration
        ↓
Snowflake External Stage
        ↓
Raw Snowflake Table
        ↓
Analytics Table
        ↓
Power BI
        ↓
Interactive Dashboard
```

## Technologies Used

- **Amazon S3** — cloud storage for transaction data
- **AWS IAM** — secure access management for the S3 bucket
- **Snowflake** — cloud data warehouse for storing and processing data
- **SQL** — database creation, table creation, data loading, and analysis
- **Power BI** — interactive dashboards and data visualization
- **Power Query (M)** — data connection and transformation

## AWS S3

The transaction dataset is stored as a CSV file in Amazon S3.

**File:**

```text
UPI_Transactions_Data.csv
```

**S3 Bucket:**

```text
manisha-upi-transactions-data
```

AWS IAM is used to provide controlled access between Snowflake and the S3 bucket.

## Snowflake

### Database Structure

```text
UPI_TRANSACTIONS_DB
└── RAW_DATA
    ├── UPI_TRANSACTIONS
    └── UPI_TRANSACTIONS_ANALYTICS
```

### Raw Table

`UPI_TRANSACTIONS`

Stores the transaction data loaded from the S3 stage.

### Analytics Table

`UPI_TRANSACTIONS_ANALYTICS`

Contains the transaction data used by Power BI for analysis and reporting.

### Snowflake Objects

```text
Storage Integration : UPI_S3_STORAGE_INTEGRATION
External Stage      : UPI_S3_STAGE
Database            : UPI_TRANSACTIONS_DB
Schema              : RAW_DATA
Raw Table           : UPI_TRANSACTIONS
Analytics Table     : UPI_TRANSACTIONS_ANALYTICS
```

## Data Loading

The CSV file is loaded from Amazon S3 into Snowflake using an external stage and the `COPY INTO` command.

The dataset contains dates in `DD/MM/YYYY` format, so the date format is explicitly specified during ingestion.

```sql
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
```

The analytics table is created from the raw table using SQL:

```sql
CREATE TABLE UPI_TRANSACTIONS_ANALYTICS AS
SELECT *
FROM UPI_TRANSACTIONS;
```

## Power BI

Power BI connects directly to the Snowflake table:

```text
UPI_TRANSACTIONS_ANALYTICS
```

The dashboard provides interactive analysis of UPI transactions across different business dimensions.

### Analysis Covered

- Monthly transaction trends
- Transaction amount analysis
- Remaining balance analysis
- City-wise transaction activity
- Bank-wise transaction analysis
- Payment method analysis
- Device-wise transactions
- Gender and customer demographics
- Transaction type and status
- Merchant analysis
- Transaction purpose analysis

Interactive slicers and visualizations allow users to explore the transaction data dynamically.

## Key Learning Outcomes

- Built an end-to-end **AWS S3 → Snowflake → Power BI** pipeline
- Configured AWS IAM-based access for Snowflake
- Created Snowflake databases, schemas, tables, storage integrations, and external stages
- Loaded CSV data from Amazon S3 into Snowflake using SQL
- Handled date-format compatibility during data ingestion
- Created an analytics layer in Snowflake
- Connected Power BI directly to Snowflake
- Built an interactive dashboard for transaction analysis

## Repository Structure

```text
UPI-Transactions-Data-Analysis/
│
├── powerbi/
│   └── UPI_Transactions_Snowflake.pbix
│
├── sql/
│   └── snowflake_setup.sql
│
├── images/
│   └── dashboard.png
│
└── README.md
```

## Dashboard Preview

![UPI Transactions Dashboard](images/dashboard.png)

## Author

**Manisha Rajan**

Data Analyst | Excel • SQL • Python • Power BI

