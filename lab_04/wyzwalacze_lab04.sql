CREATE TABLE archive_departments (
    id NUMBER,
    name VARCHAR2(100),
    closure_date DATE,
    last_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER archive_departments_trigger
AFTER DELETE ON DEPARTMENTS
FOR EACH ROW
BEGIN
    INSERT INTO archive_departments (id, name, closure_date, last_manager)
    VALUES (:OLD.department_id, :OLD.department_name, SYSDATE, :OLD.manager_id);
END;

CREATE TABLE salary_attempts (
    id NUMBER,
    user_name VARCHAR2(100),
    change_time DATE
);

CREATE OR REPLACE TRIGGER salary_check_trigger
BEFORE INSERT OR UPDATE ON EMPLOYEES
FOR EACH ROW
BEGIN
    IF :NEW.salary NOT BETWEEN 2000 AND 26000 THEN
        INSERT INTO salary_attempts (id, user_name, change_time)
        VALUES (:NEW.employee_id, USER, SYSDATE);
        RAISE_APPLICATION_ERROR(-20004, 'Wynagrodzenie poza zakresem');
    END IF;
END;

CREATE SEQUENCE emp_seq START WITH 1000 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER emp_auto_increment
BEFORE INSERT ON EMPLOYEES
FOR EACH ROW
BEGIN
    :NEW.employee_id := emp_seq.NEXTVAL;
END;

CREATE OR REPLACE TRIGGER prevent_job_grades_change
BEFORE INSERT OR UPDATE OR DELETE ON JOB_GRADES
BEGIN
    RAISE_APPLICATION_ERROR(-20005, 'Modyfikacja JOB_GRADES jest niedozwolona');
END;

CREATE OR REPLACE TRIGGER prevent_salary_update
BEFORE UPDATE OF min_salary, max_salary ON JOBS
FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
END;
