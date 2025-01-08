DECLARE
    v_max_dept_id NUMBER;
    v_new_dept_name departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id) INTO v_max_dept_id FROM departments;
    INSERT INTO departments (department_id, department_name)
    VALUES (v_max_dept_id + 10, v_new_dept_name);
    DBMS_OUTPUT.PUT_LINE('Dodano nowy departament o numerze: ' || (v_max_dept_id + 10));
END;

DECLARE
    v_max_dept_id NUMBER;
BEGIN
    SELECT MAX(department_id) INTO v_max_dept_id FROM departments;
    UPDATE departments
    SET location_id = 3000
    WHERE department_id = v_max_dept_id;
    DBMS_OUTPUT.PUT_LINE('Zaktualizowano location_id na 3000 dla departamentu: ' || v_max_dept_id);
END;

BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE nowa (value VARCHAR2(10))';
    FOR i IN 1..10 LOOP
        IF i NOT IN (4, 6) THEN
            INSERT INTO nowa (value) VALUES (TO_CHAR(i));
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Dodano liczby od 1 do 10 bez 4 i 6');
END;

DECLARE
    v_country countries%ROWTYPE;
BEGIN
    SELECT * INTO v_country FROM countries WHERE country_id = 'CA';
    DBMS_OUTPUT.PUT_LINE('Kraj: ' || v_country.country_name || ', Region ID: ' || v_country.region_id);
END;

DECLARE
    CURSOR c_emps IS
        SELECT salary, last_name FROM employees WHERE department_id = 50;
    v_salary employees.salary%TYPE;
    v_last_name employees.last_name%TYPE;
BEGIN
    OPEN c_emps;
    LOOP
        FETCH c_emps INTO v_salary, v_last_name;
        EXIT WHEN c_emps%NOTFOUND;
        IF v_salary > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(v_last_name || ': nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(v_last_name || ': dać podwyżkę');
        END IF;
    END LOOP;
    CLOSE c_emps;
END;

DECLARE
    CURSOR c_filtered_emps(p_min_salary NUMBER, p_max_salary NUMBER, p_name_part VARCHAR2) IS
        SELECT salary, first_name, last_name
        FROM employees
        WHERE salary BETWEEN p_min_salary AND p_max_salary
          AND LOWER(first_name) LIKE '%' || LOWER(p_name_part) || '%';
    v_salary employees.salary%TYPE;
    v_first_name employees.first_name%TYPE;
    v_last_name employees.last_name%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pracownicy z widełkami 1000-5000 i częścią imienia "a":');
    OPEN c_filtered_emps(1000, 5000, 'a');
    LOOP
        FETCH c_filtered_emps INTO v_salary, v_first_name, v_last_name;
        EXIT WHEN c_filtered_emps%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ' - ' || v_salary);
    END LOOP;
    CLOSE c_filtered_emps;
    DBMS_OUTPUT.PUT_LINE('Pracownicy z widełkami 5000-20000 i częścią imienia "u":');
    OPEN c_filtered_emps(5000, 20000, 'u');
    LOOP
        FETCH c_filtered_emps INTO v_salary, v_first_name, v_last_name;
        EXIT WHEN c_filtered_emps%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_first_name || ' ' || v_last_name || ' - ' || v_salary);
    END LOOP;
    CLOSE c_filtered_emps;
END;

CREATE OR REPLACE PROCEDURE add_job(p_job_id VARCHAR2, p_job_title VARCHAR2) AS
BEGIN
    INSERT INTO jobs (job_id, job_title) VALUES (p_job_id, p_job_title);
    DBMS_OUTPUT.PUT_LINE('Dodano stanowisko: ' || p_job_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE update_job_title(p_job_id VARCHAR2, p_new_title VARCHAR2) AS
    v_rows_updated NUMBER;
BEGIN
    UPDATE jobs
    SET job_title = p_new_title
    WHERE job_id = p_job_id;
    v_rows_updated := SQL%ROWCOUNT;
    IF v_rows_updated = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nie zaktualizowano żadnych wierszy.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Zaktualizowano stanowisko: ' || p_job_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE delete_job(p_job_id VARCHAR2) AS
    v_rows_deleted NUMBER;
BEGIN
    DELETE FROM jobs WHERE job_id = p_job_id;
    v_rows_deleted := SQL%ROWCOUNT;
    IF v_rows_deleted = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Nie usunięto żadnych wierszy.');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Usunięto stanowisko: ' || p_job_id);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Błąd: ' || SQLERRM);
END;

CREATE OR REPLACE PROCEDURE get_salary_and_name(p_employee_id NUMBER, p_salary OUT NUMBER, p_last_name OUT VARCHAR2) AS
BEGIN
    SELECT salary, last_name INTO p_salary, p_last_name FROM employees WHERE employee_id = p_employee_id;
END;

CREATE OR REPLACE PROCEDURE add_employee(
    p_first_name VARCHAR2 DEFAULT 'John',
    p_last_name VARCHAR2 DEFAULT 'Doe',
    p_email VARCHAR2 DEFAULT 'john.doe@example.com',
    p_hire_date DATE DEFAULT SYSDATE,
    p_job_id VARCHAR2 DEFAULT 'IT_PROG',
    p_salary NUMBER DEFAULT 1000
) AS
    v_new_id NUMBER;
BEGIN
    SELECT employees_seq.NEXTVAL INTO v_new_id FROM DUAL;
    IF p_salary > 20000 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Wynagrodzenie przekracza limit 20,000.');
    END IF;
    INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
    VALUES (v_new_id, p_first_name, p_last_name, p_email, p_hire_date, p_job_id, p_salary);
    DBMS_OUTPUT.PUT_LINE('Dodano pracownika o ID: ' || v_new_id);
END;
