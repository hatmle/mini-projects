# Extract Transform Load (ETL)
- perform simple ETL from different databases to a data warehouse 
- perform some data aggregation for business intelligence

# Steps
- Extract data from mysql, sql-server and firebird 
- Transform the data
- Load them into sql-server (data warehouse)

# Requirement:
- Install sql-server, mysql and firebird
- mysql-connector-python: connecting to mysql
- pyodbc: connecting to sql-server
- fdb: connecting to firebird

# Files:
|__main.py <br>
|__db_credentials.py <br>
|__variables.py <br>
|__sql_queries.py <br>
|__etl.py <br>

# Details:
1. Setup Database Credentials and Variables
- variables.py (Setup a variable to store the data warehouse database name)
- db_credentials.py (Setup all your source databases and target database connection strings and credentials)

2. SQL Queries
- sql_queries.py 
    * store all your sql queries for extracting from source databases and loading into your target database (data warehouse)
    * use different syntax for each data platform by separate the queries according to the database type

3. Extract Transform Load
- etl.py
    * etl_process() is the method to establish database source connection according to the database platform
    * etl() run the extract query, store the sql data in the variable data, and insert it into target database which is your data warehouse

4. Putting it All Together
- main.py

5. Run it
- Open python terminal
- Go to this directory
- Type 'python main.py'
