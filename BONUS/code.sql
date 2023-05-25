-- Ex1: Folosind cel putin un tablou (imbricat/indexat) afisati joburile pe care au lucrat in trecut angajatii care au lucrat intr-un departament care se termina in "ing".
DECLARE
    TYPE T_JOBS_TABLE IS TABLE OF jobs.JOB_TITLE%TYPE;
    v_jobs_table T_JOBS_TABLE;
BEGIN
--  salvez joburile care respecta conditia intr-un tabel
    SELECT DISTINCT j.job_title BULK COLLECT
    INTO v_jobs_table
    FROM job_history jh
             JOIN jobs j ON j.job_id = jh.job_id
    WHERE (SELECT d.department_name FROM departments d WHERE d.department_id = jh.department_id) LIKE '%ing';

-- le afisez
    FOR i IN v_jobs_table.first..v_jobs_table.last
        LOOP
            dbms_output.put_line(v_jobs_table(i));
        END LOOP;
END ;

-- Ex2: Folosind cel putin un vector afisati numele departamentelor si top 3 angajati al caror salariu este
-- mai mare decat media salariilor din acel departament.

DECLARE
    TYPE T_EMP_TABLE IS VARRAY(3) OF VARCHAR2(255);
    v_top_emp    T_EMP_TABLE := t_emp_table();
    v_avg_salary NUMBER;
BEGIN
    FOR dept IN (SELECT * FROM departments)
        LOOP
--          calculez salariul mediu
            SELECT AVG(salary) INTO v_avg_salary FROM employees WHERE department_id = dept.department_id;

--          salvez in vector numele primilor 3 angajati cu salariul mai mare decat media din departament
            SELECT first_name || ' ' || last_name BULK COLLECT
            INTO v_top_emp
            FROM (SELECT *
                  FROM employees
                  WHERE department_id = dept.department_id
                    AND salary > v_avg_salary
                  ORDER BY salary)
            WHERE rownum <= 3;

            dbms_output.put_line(dept.department_name);
--          daca am gasit angajati, ii afisez
            IF v_top_emp.count > 0 THEN
                FOR i IN v_top_emp.first..v_top_emp.last
                    LOOP
                        dbms_output.put_line('    - ' || v_top_emp(i));
                    END LOOP;
                dbms_output.new_line();
--          daca nu, afisez 'NOBODY'
            ELSE
                dbms_output.put_line('    - NOBODY');
            END IF;
        END LOOP;
END;

-- Ex3: Folosind cel putin trei cursoare afisati pentru fiecare locatie lista de departamente in care lucreaza angajatii
-- al caror nume de familie contine litera "t". Pentru ficare departament se vor afisa si toti angajatii din acel
-- departament impreuna cu salariile lor.
BEGIN
--  parcurg fiecare locatie
    FOR loc IN (SELECT * FROM locations)
        LOOP
            dbms_output.put_line(loc.city);
--          parcurg si afisez departamentele din locatie unde lucreaza persoane cu numele de familie ce contine litera "t"
            FOR dept IN (SELECT *
                         FROM departments d
                         WHERE d.location_id = loc.location_id
                           AND (SELECT COUNT(*)
                                FROM employees e
                                WHERE e.department_id = d.department_id
                                  AND LOWER(e.last_name) LIKE '%t%') > 0)
                LOOP
                    dbms_output.PUT_LINE('  - ' || dept.department_name);
--                  afisez angajatii din departament care au "t" in numele de familie
                    FOR emp IN (SELECT * FROM employees e WHERE e.department_id = dept.department_id AND LOWER(e.last_name) LIKE '%t%')
                        LOOP
                            dbms_output.put_line('    - ' || emp.first_name || ' ' || emp.last_name);
                        END LOOP;
                END LOOP;
        END LOOP;
END;
