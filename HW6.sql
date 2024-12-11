-- to avoid MySQL safety checks
set SQL_SAFE_UPDATES=0;
set FOREIGN_KEY_CHECKS=0;

create database HW6; -- a database to store the accounts table in for processing

-- This procedure declares variables and then initializes the columns to be made when generating the account records. Delimiters are used for 
-- including semicolons.
DELIMITER $$
Drop procedure if exists generate_accounts $$
Create procedure generate_accounts()
BEGIN
	 DECLARE i INT DEFAULT 1;
     DECLARE branch_name VARCHAR(50);
     DECLARE account_type VARCHAR(50);
	CREATE TABLE if not exists accounts (
	account_num CHAR(6) PRIMARY KEY,    -- 5-digit account number (e.g., 00001, 00002, ...)
	branch_name VARCHAR(50),            -- Branch name (e.g., Brighton, Downtown, etc.)
	balance DECIMAL(10, 2),             -- Account balance, with two decimal places (e.g., 1000.50)
	account_type VARCHAR(50)            -- Type of the account (e.g., Savings, Checking)
	);
    WHILE i <= 50000 DO                 -- while loop to generate the amount of records needed to conduct the timing experiment
    INSERT INTO accounts (account_num, branch_name, balance, account_type)
    VALUES (
      LPAD(i, 6, '0'),
      CONCAT('Branch_', MOD(i, 20) + 1), -- 20 unique branch names
      ROUND(RAND() * 20000, 2), -- Random balance between 0.00 and 20,000.00
      CASE MOD(i, 2) 
        WHEN 0 THEN 'Savings' 
        ELSE 'Checking' 
      END
    );
    SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;
-- statement to invoke the procedure 
call generate_accounts();
-- This procedure measures the amount of time needed to execute a query. It declares start times, end times and average times as values to be calculated
-- Then, it uses keywords like Set, Prepare, and Execute for MySQL to process the given statement. Finally, it calculates the start and end
-- time in microseconds, and calculates the average (by dividing the total by 10, since that is how many times the function ran).
Delimiter $$
Drop Procedure if exists measure_time $$
Create Procedure measure_time(IN query_str TEXT)
Begin
	Declare start_time double;
    Declare end_time double;
    Declare total_time double default 0;
    Declare average_time Double;
    Declare i int default 1;
    Set @query_str = query_str;
    
    Prepare stmt from @query_str;
	while i <= 10 do                                       -- while loop to execute the query 10 times
		SET start_time = UNIX_TIMESTAMP(NOW(6)) * 1000000;
		Execute stmt;
		SET end_time = UNIX_TIMESTAMP(NOW(6)) * 1000000;
		SET total_time = total_time + (end_time - start_time);
        SET i = i + 1;
	End while;
    
    Set average_time = total_time / 10;
    
    select average_time as average_execution_time_microseconds;
    
    Deallocate prepare stmt;
End $$
Delimiter ;

-- creating and dropping indices based on the columns to examine during each point and range query
CREATE INDEX idx_branch_name ON accounts (balance);
Drop INDEX idx_branch_name ON accounts;
CREATE INDEX idx_branch_account_type ON accounts (branch_name, account_type);
Drop INDEX idx_branch_account_type ON accounts;

-- calling the procedure which measures the time a query takes to execute. Query strings are passed in as parameters.

-- Point Query 1:
call measure_time("SELECT * FROM accounts WHERE branch_name = 'Downtown' AND balance = 50000");
   
-- Point query 2:
call measure_time("SELECT * FROM accounts WHERE branch_name = 'Branch_12' AND account_type = 'Checking'"); 

-- Range Query 1:
call measure_time("SELECT account_num from accounts where balance > 9000");

-- Range Query 2:
call measure_time("SELECT * from accounts where balance > 8000 and balance < 25000");
