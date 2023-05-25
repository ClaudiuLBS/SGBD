-- 1. Pentru fiecare job (titlu – care va fi afișat o singură dată) obțineți lista angajaților (nume și
-- salariu) care lucrează în prezent pe jobul respectiv. Tratați cazul în care nu există angajați care
-- să lucreze în prezent pe un anumit job. Rezolvați problema folosind:

-- a. cursoare clasice
DECLARE
    TYPE angajati IS TABLE OF employees%ROWTYPE;
    CURSOR c_jobs IS SELECT job_id, job_title FROM jobs;
    v_employees angajati := angajati();
    v_job_id jobs.job_id%TYPE;
    v_job_title jobs.job_title%TYPE;
BEGIN
    dbms_output.ENABLE();
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO v_job_id, v_job_title;
        EXIT WHEN c_jobs%NOTFOUND;
        SELECT * BULK COLLECT INTO v_employees FROM employees WHERE job_id = v_job_id;
        IF v_employees.count = 0 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' nu are niciun angajat');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are urmatorii angajati: ');
            FOR i IN v_employees.first..v_employees.last LOOP
                dbms_output.PUT(v_employees(i).first_name || ' ' || v_employees(i).last_name || '; ');
            END LOOP;
            dbms_output.PUT_LINE('');
        END IF;
    END LOOP;
    CLOSE c_jobs;
END;

-- b. ciclu cursoare
DECLARE
    TYPE angajati IS TABLE OF employees%ROWTYPE;
    CURSOR c_jobs IS SELECT job_id, job_title FROM jobs;
    v_employees angajati := angajati();
BEGIN
    dbms_output.ENABLE();
    FOR v_job IN c_jobs LOOP
        SELECT * BULK COLLECT INTO v_employees FROM employees WHERE job_id = v_job.job_id;
        IF v_employees.count = 0 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job.job_title || ' nu are niciun angajat');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job.job_title || ' are urmatorii angajati: ');
            FOR i IN v_employees.first..v_employees.last LOOP
                dbms_output.PUT(v_employees(i).first_name || ' ' || v_employees(i).last_name || '; ');
            END LOOP;
            dbms_output.PUT_LINE('');
        END IF;
    END LOOP;
END;

-- c. ciclu cursoare cu subcereri
BEGIN
    dbms_output.ENABLE();
    FOR v_job IN (SELECT j.job_id, j.job_title, count(e.employee_id) as employees_count FROM jobs j LEFT JOIN employees e ON j.job_id = e.job_id GROUP BY j.job_id, j.job_title) LOOP
        IF v_job.employees_count = 0 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job.job_title || ' nu are niciun angajat');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job.job_title || ' are urmatorii angajati: ');
            FOR employee IN (SELECT * FROM employees WHERE job_id = v_job.job_id) LOOP
                dbms_output.PUT(employee.first_name || ' ' || employee.last_name || '; ');
            END LOOP;
            dbms_output.PUT_LINE('');
        END IF;
    END LOOP;
END;

-- d. expresii cursor
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS
        SELECT
            j.job_id,
            j.job_title,
            count(e.employee_id) as employees_count,
            CURSOR (SELECT * FROM employees e WHERE e.job_id = j.job_id)
        FROM jobs j
        LEFT JOIN employees e ON j.job_id = e.job_id
        GROUP BY j.job_id, j.job_title;
    c_employees refcursor;
    v_job_id jobs.job_id%TYPE;
    v_job_title jobs.job_title%TYPE;
    v_employee employees%rowtype;
    v_employees_count NUMBER;
BEGIN
    dbms_output.ENABLE();
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO v_job_id, v_job_title, v_employees_count, c_employees;
        EXIT WHEN c_jobs%NOTFOUND;
        IF v_employees_count = 0 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' nu are niciun angajat');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are urmatorii angajati: ');
            LOOP
                FETCH c_employees INTO v_employee;
                EXIT WHEN c_employees%NOTFOUND;
                dbms_output.PUT(v_employee.first_name || ' ' || v_employee.last_name || '; ');
            END LOOP;
            dbms_output.PUT_LINE('');
        END IF;
    END LOOP;
    CLOSE c_jobs;
END;

-- 2. Modificați exercițiul anterior astfel încât să obțineți și următoarele informații:
--      - un număr de ordine pentru fiecare angajat care va fi resetat pentru fiecare job
--      - pentru fiecare job
--          - numărul de angajați
--          - valoarea lunară a veniturilor angajaților
--          - valoarea medie a veniturilor angajaților
--      - indiferent job
--          - numărul total de angajați
--          - valoarea totală lunară a veniturilor angajaților
--          - valoarea medie a veniturilor angajaților

-- d. expresii cursor
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS
        SELECT
            j.job_id,
            j.job_title,
            count(e.employee_id) as employees_count,
            CURSOR (SELECT * FROM employees e WHERE e.job_id = j.job_id),
            (SELECT sum(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as total_salary,
            (SELECT avg(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as mean_salary
        FROM jobs j
        LEFT JOIN employees e ON j.job_id = e.job_id
        GROUP BY j.job_id, j.job_title;
    c_employees refcursor;
    v_job_id jobs.job_id%TYPE;
    v_job_title jobs.job_title%TYPE;
    v_employee employees%rowtype;
    v_employees_count NUMBER;
    total_salary NUMBER;
    mean_salary NUMBER;
    ord_num NUMBER;
BEGIN
    dbms_output.ENABLE();
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO v_job_id, v_job_title, v_employees_count, c_employees, total_salary, mean_salary;
        EXIT WHEN c_jobs%NOTFOUND;
        IF v_employees_count = 0 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' nu are niciun angajat');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are urmatorii ' || v_employees_count || ' angajati: ');
            ord_num := 0;
            LOOP
                FETCH c_employees INTO v_employee;
                EXIT WHEN c_employees%NOTFOUND;
                dbms_output.PUT(ord_num || '. ' || v_employee.first_name || ' ' || v_employee.last_name || '; ');
                ord_num := ord_num + 1;
            END LOOP;
            dbms_output.NEW_LINE();
            dbms_output.PUT_LINE('Venit total angajati: ' || total_salary || ' si mediu: ' || mean_salary);
            dbms_output.PUT_LINE('_____________________________________________________________________________');
        END IF;
    END LOOP;
    CLOSE c_jobs;
    SELECT count(employee_id), sum(salary + nvl(commission_pct * salary, 0)), avg(salary + nvl(commission_pct * salary, 0)) INTO ord_num, total_salary, mean_salary FROM employees;
    dbms_output.PUT_LINE('In total sunt ' || ord_num || ' angajati, cu venit total de ' || total_salary || ' si mediu de ' || mean_salary);
END;

-- 3. Modificați exercițiul anterior astfel încât să obțineți suma totală alocată lunar pentru plata
-- salariilor și a comisioanelor tuturor angajaților, iar pentru fiecare angajat cât la sută din această
-- sumă câștigă lunar.
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS
        SELECT
            j.job_id,
            j.job_title,
            count(e.employee_id) as employees_count,
            CURSOR (SELECT * FROM employees e WHERE e.job_id = j.job_id),
            (SELECT sum(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as total_salary,
            (SELECT avg(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as mean_salary
        FROM jobs j
        LEFT JOIN employees e ON j.job_id = e.job_id
        GROUP BY j.job_id, j.job_title;
    c_employees refcursor;
    v_job_id jobs.job_id%TYPE;
    v_job_title jobs.job_title%TYPE;
    v_employee employees%rowtype;
    v_employees_count NUMBER;
    total_salary NUMBER;
    mean_salary NUMBER;
    ord_num NUMBER;
    global_total_income NUMBER;
    global_total_salary NUMBER;
    global_avg_income NUMBER;
    global_employees_count NUMBER;
BEGIN
    SELECT count(employee_id), sum(salary + nvl(commission_pct * salary, 0)), avg(salary + nvl(commission_pct * salary, 0)), sum(salary)
    INTO global_employees_count, global_total_income, global_avg_income, global_total_salary
    FROM employees;
    dbms_output.ENABLE();
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO v_job_id, v_job_title, v_employees_count, c_employees, total_salary, mean_salary;
        EXIT WHEN c_jobs%NOTFOUND;
        IF v_employees_count = 0 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' nu are niciun angajat');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are urmatorii ' || v_employees_count || ' angajati: ');
            ord_num := 0;
            LOOP
                FETCH c_employees INTO v_employee;
                EXIT WHEN c_employees%NOTFOUND;
                dbms_output.PUT_LINE(ord_num || '. ' || v_employee.first_name || ' ' || v_employee.last_name || ' castiga ' || to_char(round((v_employee.salary + nvl(v_employee.commission_pct * v_employee.salary, 0)) * 100 / global_total_income, 2)) || '% din suma totala');
                ord_num := ord_num + 1;
            END LOOP;
            dbms_output.NEW_LINE();
            dbms_output.PUT_LINE('Venit total angajati: ' || total_salary || ' si mediu: ' || mean_salary);
            dbms_output.PUT_LINE('_____________________________________________________________________________');
        END IF;
    END LOOP;
    CLOSE c_jobs;
    dbms_output.PUT_LINE('In total sunt ' || global_employees_count || ' angajati, cu venit total de ' || global_total_income || ' si mediu de ' || global_avg_income);
    dbms_output.PUT_LINE('Pentru salarii se aloca in total ' || global_total_salary || ' pentru salarii si ' || to_char(global_total_income - global_total_salary) || ' pentru comisioane');
END;

-- 4. Modificați exercițiul anterior astfel încât să obțineți pentru fiecare job primii 5 angajați care
-- câștigă cel mai mare salariu lunar. Specificați dacă pentru un job sunt mai puțin de 5 angajați.
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS
        SELECT
            j.job_id,
            j.job_title,
            count(e.employee_id) as employees_count,
            CURSOR (SELECT * FROM employees e WHERE e.job_id = j.job_id ORDER BY salary DESC),
            (SELECT sum(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as total_salary,
            (SELECT avg(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as mean_salary
        FROM jobs j
        LEFT JOIN employees e ON j.job_id = e.job_id
        GROUP BY j.job_id, j.job_title;
    c_employees refcursor;
    v_job_id jobs.job_id%TYPE;
    v_job_title jobs.job_title%TYPE;
    v_employee employees%rowtype;
    v_employees_count NUMBER;
    total_salary NUMBER;
    mean_salary NUMBER;
    ord_num NUMBER;
    global_total_income NUMBER;
    global_total_salary NUMBER;
    global_avg_income NUMBER;
    global_employees_count NUMBER;
BEGIN
    SELECT count(employee_id), sum(salary + nvl(commission_pct * salary, 0)), avg(salary + nvl(commission_pct * salary, 0)), sum(salary)
    INTO global_employees_count, global_total_income, global_avg_income, global_total_salary
    FROM employees;
    dbms_output.ENABLE();
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO v_job_id, v_job_title, v_employees_count, c_employees, total_salary, mean_salary;
        EXIT WHEN c_jobs%NOTFOUND;
        IF v_employees_count < 5 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are sub 5 angajati');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are urmatorii ' || v_employees_count || ' angajati: ');
            ord_num := 1;
            LOOP
                FETCH c_employees INTO v_employee;
                EXIT WHEN c_employees%NOTFOUND;
                EXIT WHEN ord_num > 5;
                dbms_output.PUT_LINE(ord_num || '. ' || v_employee.first_name || ' ' || v_employee.last_name || ' castiga ' || to_char(round((v_employee.salary + nvl(v_employee.commission_pct * v_employee.salary, 0)) * 100 / global_total_income, 2)) || '% din suma totala');
                ord_num := ord_num + 1;
            END LOOP;
            dbms_output.NEW_LINE();
            dbms_output.PUT_LINE('Venit total angajati: ' || total_salary || ' si mediu: ' || to_char(round(mean_salary, 2)));
        END IF;
        dbms_output.PUT_LINE('_____________________________________________________________________________');
    END LOOP;
    CLOSE c_jobs;
    dbms_output.PUT_LINE('In total sunt ' || global_employees_count || ' angajati, cu venit total de ' || global_total_income || ' si mediu de ' || global_avg_income);
    dbms_output.PUT_LINE('Pentru salarii se aloca in total ' || global_total_salary || ' pentru salarii si ' || to_char(global_total_income - global_total_salary) || ' pentru comisioane');
END;

-- 5. Modificați exercițiul anterior astfel încât să obțineți pentru fiecare job top 5 angajați. Dacă
-- există mai mulți angajați care respectă criteriul de selecție care au același salariu, atunci aceștia
-- vor ocupa aceeași poziție în top 5
DECLARE
    TYPE refcursor IS REF CURSOR;
    CURSOR c_jobs IS
        SELECT
            j.job_id,
            j.job_title,
            count(e.employee_id) as employees_count,
            CURSOR (SELECT * FROM employees e WHERE e.job_id = j.job_id ORDER BY salary DESC),
            (SELECT sum(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as total_salary,
            (SELECT avg(salary + nvl(commission_pct * salary, 0)) FROM employees e WHERE e.job_id = j.job_id) as mean_salary
        FROM jobs j
        LEFT JOIN employees e ON j.job_id = e.job_id
        GROUP BY j.job_id, j.job_title;
    c_employees refcursor;
    v_job_id jobs.job_id%TYPE;
    v_job_title jobs.job_title%TYPE;
    v_employee employees%rowtype;
    v_employees_count NUMBER;
    total_salary NUMBER;
    mean_salary NUMBER;
    ord_num NUMBER;
    global_total_income NUMBER;
    global_total_salary NUMBER;
    global_avg_income NUMBER;
    global_employees_count NUMBER;
    last_salary NUMBER;
BEGIN
    SELECT count(employee_id), sum(salary + nvl(commission_pct * salary, 0)), avg(salary + nvl(commission_pct * salary, 0)), sum(salary)
    INTO global_employees_count, global_total_income, global_avg_income, global_total_salary
    FROM employees;
    dbms_output.ENABLE();
    OPEN c_jobs;
    LOOP
        FETCH c_jobs INTO v_job_id, v_job_title, v_employees_count, c_employees, total_salary, mean_salary;
        EXIT WHEN c_jobs%NOTFOUND;
        IF v_employees_count < 5 THEN
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are sub 5 angajati');
        ELSE
            dbms_output.PUT_LINE('Jobul ' || v_job_title || ' are urmatorii ' || v_employees_count || ' angajati: ');
            ord_num := 0;
            last_salary := 9999999999;
            LOOP
                FETCH c_employees INTO v_employee;
                EXIT WHEN c_employees%NOTFOUND;
                EXIT WHEN ord_num >= 5;
                IF v_employee.salary < last_salary THEN ord_num := ord_num + 1;
                END IF;
                dbms_output.PUT_LINE(ord_num || '. ' || v_employee.first_name || ' ' || v_employee.last_name || ' castiga ' || to_char(round((v_employee.salary + nvl(v_employee.commission_pct * v_employee.salary, 0)) * 100 / global_total_income, 2)) || '% din suma totala');
                last_salary := v_employee.salary;
            END LOOP;
            dbms_output.NEW_LINE();
            dbms_output.PUT_LINE('Venit total angajati: ' || total_salary || ' si mediu: ' || to_char(round(mean_salary, 2)));
        END IF;
        dbms_output.PUT_LINE('_____________________________________________________________________________');
    END LOOP;
    CLOSE c_jobs;
    dbms_output.PUT_LINE('In total sunt ' || global_employees_count || ' angajati, cu venit total de ' || global_total_income || ' si mediu de ' || to_char(round(global_avg_income, 2)));
    dbms_output.PUT_LINE('Pentru salarii se aloca in total ' || global_total_salary || ' pentru salarii si ' || to_char(global_total_income - global_total_salary) || ' pentru comisioane');
END;
-- La jobul programmer topul se opreste la 4 pt ca sunt 5 angajati, dintre care 2 sunt pe locul 3.

