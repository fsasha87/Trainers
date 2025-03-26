--1\ DDL: Create TABLE companies(id identity(1,1), comp_name) => ...ALTER COLUMN..varchar(20) => ..ADD col2... => DROP COLUMN 

use [250303]
CREATE TABLE companies (
	id int identity(1,1) primary key
	, company_name varchar (30)
)
ALTER TABLE companies ALTER COLUMN company_name varchar(20) NOT NULL;
ALTER TABLE companies ADD somecol text;
ALTER TABLE companies DROP COLUMN somecol; 

INSERT iNTO companies VALUES ('Best company');
INSERT iNTO companies VALUES ('Best company2');
INSERT iNTO companies VALUES ('Best company3');
INSERT iNTO companies VALUES ('Best company4');


--2\ DDL/DML: Create TABLE users(id, user_name, age, birthday date, comp_id, added detetime default getdate()) => 
--=> ADD CONSTRAINT...CHECK (age>18) => ADD...FK => INsert INTO...VALUES('1989-07-07'...) => Update t1 set... 
--=> Delete FROM t1... => TRUNCATE table =>...=> DROP table
CREATE TABLE users (
	id int identity(1,1) primary key
	, user_name varchar(30)
	, age int
	, birthday date
	, company_id int
	, added datetime DEFAULT GETDATE()
	);

ALTER TABLE users ADD CONSTRAINT con2 FOREIGN KEY (company_id) REFERENCES companies (id);
ALTER TABLE users ADD CONSTRAINT con1 CHECK (age > 18);

INSERT INTO users (user_name, age, birthday, company_id) VALUES ('Vasia', 25, '1989-07-05', 1)
INSERT INTO users (user_name, age, birthday, company_id) VALUES ('PaVasia', 55, '1989-07-07', 1)
INSERT INTO users (user_name, age, birthday, company_id) VALUES ('AvsPaVasia', 55, '1989-07-31', 2)
INSERT INTO users (user_name, age, birthday, company_id) VALUES ('AvsPaVasia', 19, '1989-07-31', 2)

UPDATE users SET age=26 where id=1;
DELETE FROM users WHERE id=1;
TRUNCATE table users;
DROP TABLE USERS;


--3\ JOIN => Left/Right/Full join => CROSS JOIN => SELECT * FROM t1,t2 WHEREE id=id
SELECT * FROM users AS u
LEFT JOIN companies C
ON u.company_id = C.id

SELECT * FROM users AS u
CROSS JOIN companies C

SELECT * FROM users, companies
WHERE users.company_id = companies.id


--4\ SUBQUERY(SELECT/FROM): SELECT c1, (Select c2 FROM t2 where id=id) => SELECT s.* FROM (SELECT ...) AS s
SELECT user_name, age, (SELECT company_name FROM companies WHERE users.company_id = companies.id) AS company FROM users
SELECT s.* FROM (SELECT user_name, age FROM users WHERE company_id = 1) AS s;


--5\ SUBQUERY(WHERE): WHERE age =/>/IN/>ALL/>ANY (SELECT AVG/MIN...)/ WHERE EXISTS (SELECT * FROM t2 WHERE id=id)
SELECT * FROM users
WHERE age > (SELECT AVG(age) FROM users)

SELECT * FROM users
WHERE age NOT IN (SELECT MAX(age) FROM users)

SELECT * FROM users
WHERE age < ALL (SELECT MIN(age) FROM users WHERE company_id = 1)

SELECT * FROM users
WHERE age > ANY (SELECT MIN(age) FROM users WHERE company_id = 1)

SELECT * FROM users
WHERE EXISTS (SELECT * FROM companies
WHERE users.company_id = companies.id)

SELECT * FROM companies
WHERE NOT EXISTS (SELECT * FROM users
WHERE users.company_id = companies.id)


--6\ TRY/CATCH: BEGIN TRY INSERT...(NULL)...BEGIN CATCH SELECT ERROR_NUMBER()/ERROR_LINE()/ERROR_MESSAGE()
BEGIN TRY
	INSERT iNTO companies VALUES (NULL);
    PRINT 'Данные успешно добавлены!'
END TRY
BEGIN CATCH
    --PRINT 'Error ' + CONVERT(VARCHAR, ERROR_NUMBER()) + ':' + ERROR_MESSAGE()
	SELECT ERROR_NUMBER() AS ErrorNumber
	, ERROR_STATE() AS ErrorState
	, ERROR_SEVERITY() AS ErrorSeverity
	, ERROR_PROCEDURE() AS ErrorProcedure
	, ERROR_LINE() AS ErrorLine
	, ERROR_MESSAGE() AS ErrorMessage;
END CATCH

--7\ TRIGGER: tr1 ON t1 AFTER INSERT AS UPDATE t1 SET c1 =... WHERE id...FROM inserted 
CREATE TRIGGER tr_insert
ON companies
AFTER INSERT
AS
UPDATE companies
SET company_name = (SELECT company_name FROM inserted) + '_N/A'
WHERE Id = (SELECT Id FROM inserted)
INSERT iNTO companies VALUES ('Best company8');
SELECT * FROM companies;


--8\ TRANSACTION: BEGIN TRANSACTION BEGIN TRY UPDATE...; COMMIT; ...CATCH ROLLBACK;...
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
BEGIN TRY
	UPDATE companies
	SET company_name = 'Best company11'
	WHERE id = 1;
	COMMIT;
END TRY
BEGIN CATCH
	ROLLBACK;
	PRINT 'My transaction failure: ' + ERROR_MESSAGE();
END CATCH;
 