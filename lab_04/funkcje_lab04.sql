CREATE OR REPLACE FUNCTION get_job_title(job_id IN VARCHAR2) RETURN VARCHAR2 IS
    job_title JOBS.job_title%TYPE;
BEGIN
    SELECT job_title INTO job_title FROM JOBS WHERE job_id = job_id;
    RETURN job_title;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie znaleziono pracy');
END;

CREATE OR REPLACE FUNCTION calculate_annual_salary(employee_id IN NUMBER) RETURN NUMBER IS
    salary EMPLOYEES.salary%TYPE;
    commission EMPLOYEES.commission_pct%TYPE;
BEGIN
    SELECT salary, NVL(commission_pct, 0) INTO salary, commission FROM EMPLOYEES WHERE employee_id = employee_id;
    RETURN (salary * 12) + (salary * commission);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie znaleziono pracownika');
END;

CREATE OR REPLACE FUNCTION extract_area_code(phone_number IN VARCHAR2) RETURN VARCHAR2 IS
    area_code VARCHAR2(10);
BEGIN
    area_code := SUBSTR(phone_number, INSTR(phone_number, '(') + 1, INSTR(phone_number, ')') - INSTR(phone_number, '(') - 1);
    RETURN area_code;
END;

CREATE OR REPLACE FUNCTION capitalize_first_last(input_string IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
    RETURN INITCAP(SUBSTR(input_string, 1, 1)) || LOWER(SUBSTR(input_string, 2, LENGTH(input_string) - 2)) || UPPER(SUBSTR(input_string, -1));
END;

CREATE OR REPLACE FUNCTION pesel_to_birthdate(pesel IN VARCHAR2) RETURN DATE IS
    year_part VARCHAR2(2);
    month_part VARCHAR2(2);
    day_part VARCHAR2(2);
    year NUMBER;
    month NUMBER;
BEGIN
    year_part := SUBSTR(pesel, 1, 2);
    month_part := SUBSTR(pesel, 3, 2);
    day_part := SUBSTR(pesel, 5, 2);

    month := TO_NUMBER(month_part);
    IF month > 20 THEN
        year := 2000 + TO_NUMBER(year_part);
        month := month - 20;
    ELSE
        year := 1900 + TO_NUMBER(year_part);
    END IF;

    RETURN TO_DATE(year || '-' || month || '-' || day_part, 'YYYY-MM-DD');
END;

CREATE OR REPLACE FUNCTION get_country_statistics(country_name IN VARCHAR2) RETURN VARCHAR2 IS
    employee_count NUMBER;
    department_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO employee_count
    FROM EMPLOYEES e
    JOIN DEPARTMENTS d ON e.department_id = d.department_id
    JOIN LOCATIONS l ON d.location_id = l.location_id
    JOIN COUNTRIES c ON l.country_id = c.country_id
    WHERE c.country_name = country_name;

    SELECT COUNT(*) INTO department_count
    FROM DEPARTMENTS d
    JOIN LOCATIONS l ON d.location_id = l.location_id
    JOIN COUNTRIES c ON l.country_id = c.country_id
    WHERE c.country_name = country_name;

    RETURN 'Pracownicy: ' || employee_count || ', Departamenty: ' || department_count;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Nie znaleziono kraju');
END;
