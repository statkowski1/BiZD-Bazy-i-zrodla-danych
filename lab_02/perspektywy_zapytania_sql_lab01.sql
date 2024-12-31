CREATE VIEW View_Wynagrodzenia AS
SELECT last_name, salary AS wynagrodzenie
FROM EMPLOYEES
WHERE department_id IN (20, 50) AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;

CREATE VIEW View_Zatrudnienie AS
SELECT hire_date, last_name, <column_name>
FROM EMPLOYEES
WHERE manager_id IS NOT NULL AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY <column_name>;

CREATE VIEW View_ImionaNazwiskaZarobki AS
SELECT first_name || ' ' || last_name AS full_name, salary, phone_number
FROM EMPLOYEES
WHERE SUBSTR(last_name, 3, 1) = 'e' AND first_name LIKE '%<user_input>%'
ORDER BY full_name DESC, phone_number ASC;

CREATE VIEW View_MiesiaceDodatki AS
SELECT first_name, last_name,
       ROUND(MONTHS_BETWEEN(SYSDATE, hire_date), 0) AS liczba_miesiecy,
       CASE
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) < 150 THEN salary * 0.10
           WHEN MONTHS_BETWEEN(SYSDATE, hire_date) BETWEEN 150 AND 200 THEN salary * 0.20
           ELSE salary * 0.30
       END AS wysokosc_dodatku
FROM EMPLOYEES
ORDER BY liczba_miesiecy;

CREATE VIEW View_DepartmentSalaries AS
SELECT department_id, SUM(salary) AS suma_zarobkow, ROUND(AVG(salary), 0) AS srednia_zarobkow
FROM EMPLOYEES
GROUP BY department_id
HAVING MIN(salary) > 5000;

CREATE VIEW View_PracownicyToronto AS
SELECT e.last_name, e.department_id, d.department_name, e.job_id
FROM EMPLOYEES e
JOIN DEPARTMENTS d ON e.department_id = d.department_id
JOIN LOCATIONS l ON d.location_id = l.location_id
WHERE l.city = 'Toronto';

CREATE VIEW View_JenniferColleagues AS
SELECT e1.first_name AS Jennifer_first_name, e1.last_name AS Jennifer_last_name, 
       e2.first_name AS colleague_first_name, e2.last_name AS colleague_last_name
FROM EMPLOYEES e1
JOIN EMPLOYEES e2 ON e1.department_id = e2.department_id
WHERE e1.first_name = 'Jennifer' AND e1.employee_id <> e2.employee_id;

CREATE VIEW View_DepartmentsWithoutEmployees AS
SELECT department_name
FROM DEPARTMENTS d
LEFT JOIN EMPLOYEES e ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;

CREATE TABLE JOB_GRADES AS
SELECT * FROM HR.JOB_GRADES;

CREATE VIEW View_EmployeeGrades AS
SELECT e.first_name, e.last_name, e.job_id, d.department_name, e.salary, jg.grade_level
FROM EMPLOYEES e
JOIN DEPARTMENTS d ON e.department_id = d.department_id
JOIN JOB_GRADES jg ON e.salary BETWEEN jg.lowest_salary AND jg.highest_salary;

CREATE VIEW View_AboveAverageSalary AS
SELECT first_name, last_name, salary
FROM EMPLOYEES
WHERE salary > (SELECT AVG(salary) FROM EMPLOYEES)
ORDER BY salary DESC;

CREATE VIEW View_ColleaguesWithU AS
SELECT e1.employee_id, e1.first_name, e1.last_name
FROM EMPLOYEES e1
JOIN EMPLOYEES e2 ON e1.department_id = e2.department_id
WHERE e2.last_name LIKE '%u%';
