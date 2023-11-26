CREATE DATABASE hrproject;

USE hrproject;

SELECT * FROM hr LIMIT 10;
-- Data type
DESCRIBE hr;

-- RENAME COLUMN
ALTER TABLE hr 
CHANGE COLUMN  ï»¿id id varchar(20) NULL; 

SELECT birthdate FROM hr LIMIT 10;

-- DEACTIVATING SAFE UPDATE MODE
SET sql_safe_updates = 0;
-- FORMATING DATA COLUMN
UPDATE hr 
SET birthdate = CASE WHEN birthdate LIKE '%/%' THEN date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
					WHEN birthdate LIKE '%-%' THEN date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
                    ELSE NULL
                    END;

-- CHANGE THE DATA TYPE
ALTER TABLE hr
MODIFY COLUMN birthdate date;

SELECT hire_date FROM hr LIMIT 10;
UPDATE hr 
SET hire_date = CASE WHEN hire_date LIKE '%/%' THEN date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
					WHEN hire_date LIKE '%-%' THEN date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
                    ELSE NULL
                    END;

-- CHANGE THE DATA TYPE
ALTER TABLE hr
MODIFY COLUMN hire_date date;

-- TERM DATE
SELECT termdate FROM hr LIMIT 20;


UPDATE hr 
SET termdate = date( str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
				WHERE termdate IS NOT NULL AND termdate != '';
                
UPDATE hr
SET termdate = null 
WHERE termdate = '';

ALTER TABLE hr 
MODIFY COLUMN termdate Date;

-- Add age column

ALTER TABLE hr 
ADD COLUMN age int;

UPDATE hr
SET age = timestampdiff(YEAR, birthdate, CURDATE());

-- Checking the birthdate column
SELECT min(age) AS yougest, max(age) AS oldest
FROM hr;

SELECT min(birthdate) AS yougest, max(birthdate) AS oldest
FROM hr;

SELECT COUNT(*) AS age_count
FROM hr
WHERE age < 18;

-- 1. What is the gender breakdown of employees in the company?
SELECT gender, COUNT(*) AS gender_count
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
SELECT race, COUNT(*) AS race_count
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY race
ORDER BY race_count DESC;

-- 3. What is the age distribution of employees in the company?
SELECT min(age) AS yougest, max(age) AS oldest
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL;
SELECT 
	CASE 
		WHEN age >= 18 AND age <= 24 THEN '18 -24'
        WHEN age >= 25 AND age <= 34 THEN '25 - 34'
        WHEN age >= 35 AND age <= 44 THEN '35 - 44'
		WHEN age >= 45 AND age <= 54 THEN '45 - 54'
		WHEN age >= 55 AND age <= 64 THEN '55 - 64'
        ELSE '65+' 
        END AS age_group, COUNT(*) AS age_count
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY age_group
ORDER BY age_group;


SELECT 
	CASE 
		WHEN age >= 18 AND age <= 24 THEN '18 -24'
        WHEN age >= 25 AND age <= 34 THEN '25 - 34'
        WHEN age >= 35 AND age <= 44 THEN '35 - 44'
		WHEN age >= 45 AND age <= 54 THEN '45 - 54'
		WHEN age >= 55 AND age <= 64 THEN '55 - 64'
        ELSE '65+' 
        END AS age_group, gender, COUNT(*) AS age_count
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;

-- 4. How many employees work at headquarters versus remote locations?
SELECT location, COUNT(*) AS location_count
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?
SELECT 
	ROUND(AVG(datediff(termdate, hire_date))/360, 0) AS employment_length
FROM hr
WHERE termdate <= CURDATE() AND age >= 18;

-- 6. How does the gender distribution vary across departments and job titles?
SELECT 
		COUNT(*) AS gender_count, 
        department, gender
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY department, gender
ORDER BY department;

-- 7.What is the distribution of job titles across the company?
SELECT 
		COUNT(*) AS jobtitle_count, 
        jobtitle
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY jobtitle
ORDER BY jobtitle;

-- 8. Which department has the highest turnover rate?
SELECT max(termdate) AS max_termdate, min(termdate) AS minimum_termdate
FROM hr;

-- Solution to question 8 starts here

SELECT department, total_count, terminated_count, ROUND((terminated_count/total_count)*100, 0) AS termination_rate
FROM(
		SELECT department, COUNT(*) AS total_count,
				SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1
					ELSE 0 END) AS terminated_count
		FROM hr
		WHERE age >= 18
		GROUP BY department) AS subquery
ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by state?
SELECT location_state, COUNT(*) AS location_state_count
FROM hr
WHERE age >= 18 AND termdate IS NOT NULL
GROUP BY location_state
ORDER BY location_state_count DESC;

-- 10. How has the company's employee count changed over time based on hire and term dates?
		
SELECT year, hire_count, terminated_count, 
			hire_count - terminated_count AS net_change,
            ROUND(((hire_count - terminated_count)/hire_count)*100, 0) AS perc_net_change
FROM (
        SELECT year(hire_date) AS year, COUNT(*) hire_count,
					SUM(CASE WHEN termdate IS NOT NULL AND termdate <= CURDATE() THEN 1
							ELSE 0 END) AS terminated_count
		FROM hr
		WHERE age >= 18
		GROUP BY year) AS subquery
ORDER BY year ASC;

-- 11. What is the tenure distribution for each department?
SELECT department,
	ROUND(AVG(datediff(termdate, hire_date))/360, 0) AS employment_length
FROM hr
WHERE termdate <= CURDATE() AND termdate IS NOT NULL AND age >= 18
GROUP BY department;

