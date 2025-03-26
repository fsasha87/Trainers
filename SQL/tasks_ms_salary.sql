--9\ SELECT(Salaries_table): SELECT TOP 5 * {PL:LIMIT 5} => DISTINCT => ORDER BY => WHERE (=,<>, [NOT] LIKE('x',_,%), [NOT] IN, BETWEEN, IS [NOT] NULL)
SELECT TOP 10 * from salaries;
SELECT DISTINCT job_title FROM salaries;

SELECT TOP 10 * from salaries
ORDER BY salary_in_usd desc;

SELECT * FROM salaries
WHERE job_title LIKE 'Data%' AND work_year = 2024

SELECT * FROM salaries
WHERE salary_in_usd between 400000 AND 750000
ORDER BY salary_in_usd;

SELECT * FROM salaries
WHERE job_title NOT IN ('Data Analyst', 'Data Engineer')


--10\ STRING: title+CAST(year) => select LEN(x)/upper()/reverse/concat/substring/replace
SELECT * FROM salaries;
SELECT TOP 10 CAST(work_year AS varchar)+' '+job_title FROM salaries

SELECT LEN('Apple')  -- 5
SELECT UPPER('Apple')   -- APPLE
SELECT REVERSE('123456789') -- 987654321
SELECT CONCAT('Tom', ' ', 'Smith')  -- Tom Smith
SELECT SUBSTRING('Galaxy S8 Plus', 8, 2)    -- S8
SELECT REPLACE('Galaxy S8 Plus', 'S8 Plus', 'Note 8')   -- Galaxy Note 8


--11\ DATE: select GETDATE()/GETUTCDATE()/MONTH(GETDATE())/isdate/dateadd/datediff
SELECT GETDATE()
SELECT GETUTCDATE()	
SELECT MONTH(GETDATE())  --3
SELECT DATENAME(month, GETDATE()) --March
SELECT DATEADD(month, 2, '2017-7-28')
SELECT DATEDIFF(month, '2017-7-28', '2018-9-28') 
SELECT ISDATE('2017-07-28')     -- 1


--12\ CASE/IFF: CASE WHEN c1 < 100 THEN 'A' ELSE 'B' END => --SELECT*,IIF(c1<100,'A','B')...
SELECT
	job_title
	, salary_in_usd
    , CASE 
        WHEN salary_in_usd <= 50000 THEN 'A'
        WHEN salary_in_usd <= 100000 THEN 'B'
        ELSE 'C' 
    END AS salary_cat
FROM salaries

SELECT
	job_title
	, salary_in_usd
    , IIF (salary_in_usd<50000, 'Not much', 'Normal') AS size
FROM salaries


--13\ AGGREGATE: MIN, SUM, Count(*), ROUND(AVG(),1), x*40 as UAH => WHERE/ Group by c1,c2 /Having /Order By
SELECT 
	job_title, 
	experience_level, 
	MIN(salary_in_usd) AS minsalary, 
	COUNT(job_title) as qty, 
	SUM(salary_in_usd) as total,
	ROUND(AVG(salary_in_usd), 1) AS avgsalary,
	ROUND(AVG(salary_in_usd) * 40, 1) AS salary_in_UAH
FROM salaries
WHERE work_year = 2024
GROUP BY job_title, experience_level
HAVING COUNT(*) > 2
ORDER BY job_title;


--14\ UNION: emp_res UNION/UNION ALL/INTERSECT/EXCEPT{MINUS} comp_location; UNION 'min/max' as header. MIN/MAX(salary) as value
SELECT employee_residence FROM salaries
EXCEPT
SELECT company_location FROM salaries
ORDER BY 1

SELECT 'Min salary' as header 
, MIN(salary_in_usd) as value1
from salaries
UNION
SELECT 'Max salary' as header 
, MAX(salary_in_usd) as value1
from salaries


--15\ CTE(1query)/VIEW: WITH cte1 AS (SELECT *...) -> SELECT * FROM cte1 => CREATE VIEW v1 AS SELECT *... -> SELECT * FROM v1
USE salaries_db;
WITH cte1 AS (
SELECT TOP 10 * FROM salaries
)
SELECT job_title, salary_in_usd FROM cte1
WHERE salary_in_USD > 90000


CREATE VIEW v1 AS 
SELECT TOP 10 * FROM salaries;

SELECT job_title, salary_in_usd FROM v1
WHERE salary_in_USD > 90000


--16\ WINDOW: MIN/COUNT/AVG/SUM(c1) OVER (partition by c2) => SUM(c1)OVER(...order by c2)
--=> SELECT*,ROW_NUMBER()/RANK()/DENSE_RANK() OVER(PARTITION BY c2 ORDER BY c1) FROM...
--=> select *, LAG/LEAD(s2, 1)/FIRST_VALUE(s2) OVER(Par..by s1 order by s2) FROM...
SELECT
	job_title
	, salary_in_usd
	, MIN(salary_in_usd) OVER (PARTITION by job_title) AS min_salary
	, COUNT(salary_in_usd) OVER (PARTITION by job_title) AS count_jobs
	, AVG(salary_in_usd) OVER (PARTITION by job_title) AS avg_salary
	, SUM(salary_in_usd) OVER (PARTITION by job_title) AS sum_salary
	, SUM(salary_in_usd) OVER (PARTITION by job_title ORDER BY salary_in_usd) AS sum_salary
from salaries


SELECT
	job_title
	, salary_in_usd
	, ROW_NUMBER() 	OVER(PARTITION BY job_title ORDER BY salary_in_usd DESC) AS invoice_nmb
	, RANK() 		OVER(PARTITION BY job_title ORDER BY salary_in_usd DESC) AS invoice_rank
	, DENSE_RANK() 	OVER(PARTITION BY job_title ORDER BY salary_in_usd DESC) AS invoice_rank
FROM salaries


SELECT
	job_title, 
	salary_in_usd,
	LAG(salary_in_usd, 1) OVER (Partition By job_title ORDER BY salary_in_usd) as Lag_salary,
	LEAD(salary_in_usd, 1) OVER (Partition By job_title ORDER BY salary_in_usd) as lead_salary,
	FIRST_VALUE(salary_in_usd) OVER (Partition By job_title ORDER BY salary_in_usd) as first_salary
FROM salaries


--17\ VARIABLE: DECLARE @a int; SET @a=(SELECT MAX(salary)...)/SELECT @a=MAX(salary)...; select @a; PRINT 'Max='+STR(@a)/CONVERT(char, @a)/CAST(@a as char);
Declare @maxsalary int;
SET @maxsalary = (SELECT MAX(salary_in_usd) FROM salaries);
--SELECT @maxsalary = (SELECT MAX(salary_in_usd) FROM salaries);
SELECT @maxsalary = MAX(salary_in_usd) FROM salaries;
SELECT @maxsalary;
PRINT @maxsalary
PRINT 'Max salary: ' + CONVERT(char, @maxsalary);
PRINT 'Max salary: ' + STR(@maxsalary);
PRINT 'Max salary: ' + CAST(@maxsalary as varchar);


--18\ DYNAMIC SQL: DECLARE @SQL varchar(100), @a; SET @a=...; SET @SQL='SELECT... WHERE a='''+@a''''; EXEC (@SQL)
DECLARE @SQL2 NVARCHAR(1000), @job2 NVARCHAR(50);
SET @job2 = 'Data Analyst';
PRINT @job2
SET @SQL2 = 'SELECT TOP 5 * FROM salaries WHERE job_title = ''' + @job2 + '''';
PRINT @SQL2; -- Проверяем сформированный SQL
--EXEC sp_executesql @SQL2;
EXEC (@SQL2);
--2сп: SET @SQL2 = 'SELECT TOP 5 * FROM salaries WHERE job_title = @jobTitle';
--EXEC sp_executesql @SQL2, N'@jobTitle VARCHAR(50)', @job2;


--19\ IF: ...select @min=MIN(salary)...; IF @min>100 PRINT 'good' ELSE ...
DECLARE @minsalary int;
select @minsalary=MIN(salary_in_usd) FROM salaries;
IF @minsalary > 50000
PRINT 'Good'
ELSE 
PRINT 'Bad'


--20\ WHILE: ...WHILE @num<10 PRINT @num IF @num=7 BREAK/CONTINUE PRINT 'ITER END';
DECLARE @number INT
SET @number = 1 
WHILE @number < 10
    BEGIN
        PRINT CONVERT(NVARCHAR, @number)
        SET @number = @number + 1
        IF @number = 7
            BREAK;
--        IF @number = 4
--            CONTINUE;
--        PRINT 'Конец итерации'
    END;


--21\ TABLE VARIABLE(batch): DECLARE @t1 TABLE (c1 int, ...) => INSERT INTO @t1... => SELECT
DECLARE @ABrends TABLE (ProductId INT,  ProductName NVARCHAR(20))
INSERT INTO @ABrends
VALUES(1, 'iPhone 8'),
(2, 'Samsumg Galaxy S8')
SELECT * FROM @ABrends


--22\ TEMPTABLE(session): #local/##global(outside script): CREATE TABLE #t1(c1 int, ...) => INSERT INTO #t1... => SELECT... => SELECT * INTO #t2 FROM t3 
CREATE TABLE #ABrends (ProductId INT,  ProductName NVARCHAR(20))
INSERT INTO #ABrends
VALUES(1, 'iPhone 8'),
(2, 'Samsumg Galaxy S8')
SELECT * FROM #ABrends

CREATE TABLE ##ABrends1 (ProductId INT,  ProductName NVARCHAR(20))
INSERT INTO ##ABrends1
VALUES(1, 'iPhone 8'),
(2, 'Samsumg Galaxy S8')
SELECT * FROM ##ABrends1


--23\ PROCEDURE: CREATE PROC ps2 AS BEGIN SELECT... END; EXEC ps2
USE salaries_db;
GO
CREATE PROC PS2 AS
BEGIN
	SELECT TOP 10 job_title, salary_in_usd
	FROM salaries;
END;
EXEC PS2;


--24\ PROCEDURE: CREATE PROC pr1 @year int, AS ...where c1=@year => exec pr1 2023
CREATE PROC pr4
    @job NVARCHAR(20),
    @year INT
AS
	SELECT *
	FROM salaries
	WHERe job_title = @job AND work_year = @year;

EXEC pr4 'Data Analyst', 2023


--25\ PROCEDURE: CREATE PROC pr5 @a INT OUTPUT AS SELECT...; DECLARE @a INT; EXEC pr5 @a OUTPUT; PRINT ...@aUSE salaries_db;
CREATE PROCEDURE pr5
    @minSalary INT OUTPUT
AS
SELECT @minSalary = MIN(salary_in_usd)
FROM salaries

DECLARE @minSalary INT;
EXEC pr5 @minSalary OUTPUT;
PRINT 'Min salary' + CONVERT(VARCHAR, @minSalary)


--26\ INDEX: CREATE INDEX ind ON T1(c1)
CREATE INDEX index1 ON dbo.salaries (salary_in_usd);


--27\ UDF(scalar): create function f1 (@salary) RETURNS varchar(10) AS BEGIN DECLARE @c; IF @salary<100 SET @c='Low'... RETURN @c => SELECT *, f1...
use salaries_db
CREATE FUNCTION dbo.GetSalaryCategory (@salary DECIMAL(10,2))
RETURNS VARCHAR(10)
AS
BEGIN
    DECLARE @category VARCHAR(10);
    
    IF @salary < 50000 
        SET @category = 'Low';
    ELSE IF @salary BETWEEN 50000 AND 100000 
        SET @category = 'Medium';
    ELSE 
        SET @category = 'High';

    RETURN @category;
END;

SELECT job_title, salary_in_usd, dbo.GetSalaryCategory(salary_in_usd) AS salary_category
FROM salaries;


--28\ UDF(table): ...f2 (@this) RETURNS TABLE AS RETURN (select ... where salary > @this); => select * from f2; 
CREATE FUNCTION dbo.GetSalariesAbove(@min_salary DECIMAL(10,2))
RETURNS TABLE
AS
RETURN 
(
    SELECT job_title, salary_in_usd
    FROM salaries
    WHERE salary_in_usd > @min_salary
);

SELECT * FROM dbo.GetSalariesAbove(500000);