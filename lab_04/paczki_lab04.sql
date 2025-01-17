CREATE OR REPLACE PACKAGE hr_package IS
    PROCEDURE add_job(p_job_id IN VARCHAR2, p_job_title IN VARCHAR2);
    PROCEDURE modify_job_title(p_job_id IN VARCHAR2, p_new_title IN VARCHAR2);
    PROCEDURE delete_job(p_job_id IN VARCHAR2);
    FUNCTION get_job_title(job_id IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION calculate_annual_salary(employee_id IN NUMBER) RETURN NUMBER;
END hr_package;

CREATE OR REPLACE PACKAGE BODY hr_package IS
    PROCEDURE add_job(p_job_id IN VARCHAR2, p_job_title IN VARCHAR2) IS
    BEGIN
        INSERT INTO JOBS (job_id, job_title) VALUES (p_job_id, p_job_title);
    END;

    PROCEDURE modify_job_title(p_job_id IN VARCHAR2, p_new_title IN VARCHAR2) IS
    BEGIN
        UPDATE JOBS SET job_title = p_new_title WHERE job_id = p_job_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20006, 'Nie zaktualizowano pracy');
        END IF;
    END;

    PROCEDURE delete_job(p_job_id IN VARCHAR2) IS
    BEGIN
        DELETE FROM JOBS WHERE job_id = p_job_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Nie usunieto pracy');
        END IF;
    END;

    FUNCTION get_job_title(job_id IN VARCHAR2) RETURN VARCHAR2 IS
        job_title JOBS.job_title%TYPE;
    BEGIN
        SELECT job_title INTO job_title FROM JOBS WHERE job_id = job_id;
        RETURN job_title;
    END;

    FUNCTION calculate_annual_salary(employee_id IN NUMBER) RETURN NUMBER IS
        salary EMPLOYEES.salary%TYPE;
        commission EMPLOYEES.commission_pct%TYPE;
    BEGIN
        SELECT salary, NVL(commission_pct, 0) INTO salary, commission FROM EMPLOYEES WHERE employee_id = employee_id;
        RETURN (salary * 12) + (salary * commission);
    END;
END hr_package;

CREATE OR REPLACE PACKAGE region_package IS
    PROCEDURE add_region(p_region_id IN NUMBER, p_region_name IN VARCHAR2);
    PROCEDURE update_region(p_region_id IN NUMBER, p_new_name IN VARCHAR2);
    PROCEDURE delete_region(p_region_id IN NUMBER);
    FUNCTION get_region(p_region_id IN NUMBER) RETURN REGIONS%ROWTYPE;
END region_package;

CREATE OR REPLACE PACKAGE BODY region_package IS
    PROCEDURE add_region(p_region_id IN NUMBER, p_region_name IN VARCHAR2) IS
    BEGIN
        INSERT INTO REGIONS (region_id, region_name) VALUES (p_region_id, p_region_name);
    END;

    PROCEDURE update_region(p_region_id IN NUMBER, p_new_name IN VARCHAR2) IS
    BEGIN
        UPDATE REGIONS SET region_name = p_new_name WHERE region_id = p_region_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20008, 'Nie zaktualizowano regionu');
        END IF;
    END;

    PROCEDURE delete_region(p_region_id IN NUMBER) IS
    BEGIN
        DELETE FROM REGIONS WHERE region_id = p_region_id;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20009, 'Nie usunieto regionu');
        END IF;
    END;

    FUNCTION get_region(p_region_id IN NUMBER) RETURN REGIONS%ROWTYPE IS
        region_row REGIONS%ROWTYPE;
    BEGIN
        SELECT * INTO region_row FROM REGIONS WHERE region_id = p_region_id;
        RETURN region_row;
    END;
END region_package;
