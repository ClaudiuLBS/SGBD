CREATE SEQUENCE sec_lcm
    START WITH 207
    INCREMENT BY 1
    MAXVALUE 999999999999;

CREATE OR REPLACE PACKAGE package_lcm AS

    FUNCTION find_manager(v_first_name emp_lcm.FIRST_NAME%TYPE, v_last_name emp_lcm.LAST_NAME%TYPE)
        RETURN emp_lcm.EMPLOYEE_ID%TYPE;

    FUNCTION find_department(v_department_name dept_lcm.DEPARTMENT_NAME%TYPE)
        RETURN dept_lcm.DEPARTMENT_ID%TYPE;

    FUNCTION find_job(v_job_title jobs.JOB_TITLE%TYPE)
        RETURN jobs.JOB_ID%TYPE;

    PROCEDURE add_employee(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE,
        telefon emp_lcm.PHONE_NUMBER%TYPE,
        v_email emp_lcm.EMAIL%TYPE,
        nume_manager emp_lcm.LAST_NAME%TYPE,
        prenume_manager emp_lcm.FIRST_NAME%TYPE,
        nume_departament dept_lcm.DEPARTMENT_NAME%TYPE,
        nume_job jobs.JOB_TITLE%TYPE
    );

    PROCEDURE move_employee(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE,
        nume_departament dept_lcm.DEPARTMENT_NAME%TYPE,
        nume_job jobs.JOB_TITLE%TYPE,
        nume_manager emp_lcm.LAST_NAME%TYPE,
        prenume_manager emp_lcm.FIRST_NAME%TYPE
    );

    FUNCTION find_subalterns(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE,
        first_step BOOLEAN := TRUE
    ) RETURN NUMBER;

    PROCEDURE promote_employee(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE
    );

    PROCEDURE update_salary(
        nume emp_lcm.LAST_NAME%TYPE,
        salariu emp_lcm.SALARY%TYPE
    );

    CURSOR get_employees_of_job(v_job_id emp_lcm.JOB_ID%TYPE)
        RETURN EMP_LCM%ROWTYPE;

    CURSOR get_all_jobs RETURN JOBS%ROWTYPE;

    PROCEDURE employees_info;
END package_lcm;


CREATE OR REPLACE PACKAGE BODY package_lcm AS

    CURSOR get_employees_of_job(v_job_id emp_lcm.JOB_ID%TYPE)
        RETURN EMP_LCM%ROWTYPE IS
        SELECT *
        FROM emp_lcm
        WHERE job_id = v_job_id;

    CURSOR get_all_jobs
        RETURN JOBS%ROWTYPE IS
        SELECT *
        FROM jobs;

    FUNCTION find_manager(
        v_first_name emp_lcm.FIRST_NAME%TYPE,
        v_last_name emp_lcm.LAST_NAME%TYPE
    ) RETURN emp_lcm.EMPLOYEE_ID%TYPE IS
        v_manager_id emp_lcm.EMPLOYEE_ID%TYPE;
    BEGIN
        SELECT employee_id
        INTO v_manager_id
        FROM emp_lcm
        WHERE LOWER(first_name) = LOWER(v_first_name)
          AND LOWER(last_name) = LOWER(v_last_name);
        RETURN v_manager_id;

    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nu exista managerul cu numele dat');
        WHEN too_many_rows THEN
            RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi manageri cu numele dat');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, SQLERRM);
    END find_manager;

    FUNCTION find_department(
        v_department_name dept_lcm.DEPARTMENT_NAME%TYPE
    ) RETURN dept_lcm.DEPARTMENT_ID%TYPE IS
        v_department_id dept_lcm.DEPARTMENT_ID%TYPE;
    BEGIN
        SELECT department_id
        INTO v_department_id
        FROM dept_lcm
        WHERE LOWER(department_name) = LOWER(v_department_name);
        RETURN v_department_id;

    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Nu exista departamentul cu numele dat');
        WHEN too_many_rows THEN
            RAISE_APPLICATION_ERROR(-20004, 'Exista mai multe departamente cu numele dat');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20005, SQLERRM);
    END find_department;

    FUNCTION find_job(
        v_job_title jobs.JOB_TITLE%TYPE
    ) RETURN jobs.JOB_ID%TYPE IS
        v_job_id jobs.JOB_ID%TYPE;
    BEGIN
        SELECT job_id
        INTO v_job_id
        FROM jobs
        WHERE LOWER(job_title) = LOWER(v_job_title);
        RETURN v_job_id;
    EXCEPTION
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20006, 'Nu exista jobul cu numele dat');
        WHEN too_many_rows THEN
            RAISE_APPLICATION_ERROR(-20007, 'Exista mai multe joburi cu numele dat');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20008, SQLERRM);
    END find_job;

    PROCEDURE add_employee(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE,
        telefon emp_lcm.PHONE_NUMBER%TYPE,
        v_email emp_lcm.EMAIL%TYPE,
        nume_manager emp_lcm.LAST_NAME%TYPE,
        prenume_manager emp_lcm.FIRST_NAME%TYPE,
        nume_departament dept_lcm.DEPARTMENT_NAME%TYPE,
        nume_job jobs.JOB_TITLE%TYPE
    ) IS
        v_salary emp_lcm.SALARY%TYPE;
    BEGIN
        SELECT MIN(salary) INTO v_salary FROM emp_lcm WHERE department_id = find_department(nume_departament);

        INSERT INTO emp_lcm (employee_id, first_name, last_name, email, phone_number, hire_date, job_id, salary,
                             commission_pct, manager_id, department_id)
        VALUES (sec_lcm.nextval, prenume, nume, v_email, telefon, TRUNC(SYSDATE), find_job(nume_job), v_salary, 0,
                find_manager(prenume_manager, nume_manager), find_department(nume_departament));
        COMMIT;
    END add_employee;

    PROCEDURE move_employee(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE,
        nume_departament dept_lcm.DEPARTMENT_NAME%TYPE,
        nume_job jobs.JOB_TITLE%TYPE,
        nume_manager emp_lcm.LAST_NAME%TYPE,
        prenume_manager emp_lcm.FIRST_NAME%TYPE
    ) IS
        v_salary         emp_lcm.SALARY%TYPE;
        v_id             emp_lcm.EMPLOYEE_ID%TYPE;
        v_current_salary emp_lcm.SALARY%TYPE;
        v_employees      NUMBER;
        v_manager_id     emp_lcm.EMPLOYEE_ID%TYPE;
        v_commission     emp_lcm.COMMISSION_PCT%TYPE;
    BEGIN
        SELECT MIN(salary), MIN(commission_pct)
        INTO v_salary, v_commission
        FROM emp_lcm
        WHERE department_id = find_department(nume_departament)
          AND job_id = find_job(nume_job);

        SELECT COUNT(*)
        INTO v_employees
        FROM emp_lcm
        WHERE LOWER(last_name) = LOWER(nume)
          AND LOWER(first_name) = LOWER(prenume);

        IF v_employees = 0 THEN
            RAISE_APPLICATION_ERROR(-20009, 'Nu exista anagajatul cu numele specificat.');
        ELSIF v_employees > 1 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Exista ma multi anagajati cu numele specificat.');
        END IF;

        SELECT employee_id, salary
        INTO v_id, v_current_salary
        FROM emp_lcm
        WHERE LOWER(last_name) = LOWER(nume)
          AND LOWER(first_name) = LOWER(prenume);

        IF nvl(v_salary, 0) < v_current_salary THEN
            v_salary := v_current_salary;
        END IF;

        v_manager_id := find_manager(prenume_manager, nume_manager);

        INSERT INTO job_history_lcm(employee_id, start_date, end_date, job_id, department_id)
        SELECT employee_id, hire_date, TRUNC(SYSDATE), job_id, department_id
        FROM emp_lcm
        WHERE employee_id = v_id;

        UPDATE emp_lcm
        SET department_id  = find_department(nume_departament),
            job_id         = find_job(nume_job),
            salary         = v_salary,
            manager_id     = v_manager_id,
            hire_date      = TRUNC(SYSDATE),
            commission_pct = v_commission
        WHERE employee_id = v_id;
        COMMIT;
    END move_employee;

    FUNCTION find_subalterns(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE,
        first_step BOOLEAN := TRUE
    ) RETURN NUMBER IS
        subalterns NUMBER := 1;
    BEGIN
        -- nu il numaram pe managerul dat ca parametru initial ca si subaltern al sau
        IF first_step THEN
            subalterns := 0;
        END IF;

        FOR e IN (SELECT * FROM emp_lcm WHERE manager_id = find_manager(prenume, nume))
            LOOP
                subalterns := subalterns + find_subalterns(e.last_name, e.first_name, FALSE);
            END LOOP;
        RETURN subalterns;
    END find_subalterns;

    PROCEDURE promote_employee(
        nume emp_lcm.LAST_NAME%TYPE,
        prenume emp_lcm.FIRST_NAME%TYPE
    ) IS
        v_id             emp_lcm.EMPLOYEE_ID%TYPE;
        v_new_manager_id emp_lcm.EMPLOYEE_ID%TYPE;
    BEGIN
        v_id := find_manager(prenume, nume);

--      el va fi managerul tuturor subalternilor fostului manager
        UPDATE emp_lcm e1
        SET e1.manager_id = v_id
        WHERE e1.employee_id != v_id
          AND e1.manager_id = (SELECT e2.manager_id FROM emp_lcm e2 WHERE e2.employee_id = v_id);

--      noul lui manager va fi managerul vechiului manager
        SELECT e1.manager_id
        INTO v_new_manager_id
        FROM emp_lcm e1
        WHERE e1.employee_id = (SELECT e2.manager_id FROM emp_lcm e2 WHERE e2.employee_id = v_id);

        UPDATE emp_lcm e
        SET e.manager_id = v_new_manager_id
        WHERE e.employee_id = v_id;

    END promote_employee;

    PROCEDURE update_salary(
        nume emp_lcm.LAST_NAME%TYPE,
        salariu emp_lcm.SALARY%TYPE
    ) IS
        employees_count NUMBER;
        v_min_salary    jobs.MIN_SALARY%TYPE;
        v_max_salary    jobs.MAX_SALARY%TYPE;
    BEGIN
        SELECT COUNT(*) INTO employees_count FROM emp_lcm WHERE last_name = nume;
        IF employees_count = 0 THEN
            dbms_output.put_line('Nu exista angajati cu numele ' || nume);
            RETURN;
        ELSIF employees_count > 1 THEN
            dbms_output.put_line('Exista mai multi angajati cu numele ' || nume || ':');
            FOR e IN (SELECT * FROM emp_lcm WHERE last_name = nume)
                LOOP
                    dbms_output.put_line(e.first_name || ' ' || e.last_name || ';');
                END LOOP;
            RETURN;
        END IF;

        SELECT min_salary, max_salary
        INTO v_min_salary, v_max_salary
        FROM jobs
        WHERE job_id = (SELECT job_id FROM emp_lcm WHERE last_name = nume);

        IF salariu < v_min_salary OR salariu > v_max_salary THEN
            dbms_output.put_line('Salariul trebuie sa apartina intervalului ' || v_min_salary || ' - ' || v_max_salary);
        ELSE
            UPDATE emp_lcm SET salary = salariu WHERE last_name = nume;
            dbms_output.put_line('Salariul a fost actualizat cu succes.');
        END IF;

    END update_salary;

    PROCEDURE employees_info IS
        previous_jobs_count NUMBER;
    BEGIN
        dbms_output.PUT_LINE('_______________________________________________________________');
        FOR j IN get_all_jobs
            LOOP
                dbms_output.put_line(j.job_title || ': ');
                FOR e IN get_employees_of_job(j.job_id)
                    LOOP
                        SELECT COUNT(*)
                        INTO previous_jobs_count
                        FROM job_history_lcm
                        WHERE employee_id = e.employee_id
                          AND job_id = e.job_id;

                        IF previous_jobs_count = 0 then
                            dbms_output.PUT_LINE('  - ' || e.first_name || ' ' || e.last_name || ': lucreaza pentru prima data aici.');
                        ELSE
                            dbms_output.PUT_LINE('  - ' || e.first_name || ' ' || e.last_name || ': a mai lucrat aici.');
                        END IF;
                    END LOOP;
                dbms_output.PUT_LINE('_______________________________________________________________');
            END LOOP;
    END employees_info;
END package_lcm;


BEGIN
-- package_lcm.add_employee('Lăbuș','Claudiu','0755701422','clau_123@yahoo.com','Fay','Pat','Marketing','Programmer');
-- package_lcm.move_employee('Lăbuș','Claudiu','IT','Stock Clerk','lorentz','Diana');
-- dbms_output.PUT_LINE(package_lcm.find_subalterns('Lorentz', 'Diana'));
-- package_lcm.promote_employee('Hunold', 'Alexander');
-- package_lcm.update_salary('Hunold', 1000);
    package_lcm.employees_info;
END;


