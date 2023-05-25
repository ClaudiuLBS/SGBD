-- 1. Creați tabelul info_lcm cu următoarele coloane:
--      - utilizator (numele utilizatorului care a inițiat o comandă)
--      - data (data și timpul la care utilizatorul a inițiat comanda)
--      - comanda (comanda care a fost inițiată de utilizatorul respectiv)
--      - nr_linii (numărul de linii selectate/modificate de comandă)
--      - eroare (un mesaj pentru excepții).

CREATE TABLE info_lcm
(
    utilizator VARCHAR2(255),
    data       DATE,
    comanda    VARCHAR2(2047),
    nr_linii   NUMBER,
    eroare     VARCHAR2(2047)
);

-- 2. Modificați funcția definită la exercițiul 2, respectiv procedura definită la exercițiul 4 astfel încât
-- să determine inserarea în tabelul info_*** a informațiile corespunzătoare fiecărui caz
-- determinat de valoarea dată pentru parametru.
CREATE OR REPLACE PROCEDURE insert_info_lcm(
    v_comanda info_lcm.COMANDA%TYPE,
    v_nr_linii info_lcm.NR_LINII%TYPE,
    v_eroare info_lcm.EROARE%TYPE
) AS
BEGIN
    INSERT INTO info_lcm (utilizator, data, comanda, nr_linii, eroare)
    VALUES (USER, SYSDATE, v_comanda, v_nr_linii, v_eroare);
EXCEPTION
    WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
END insert_info_lcm;

--  f2
CREATE OR REPLACE FUNCTION f2_lcm(v_nume employees.LAST_NAME%TYPE DEFAULT 'Bell') RETURN NUMBER IS
    salariu employees.SALARY%TYPE;
BEGIN
    SELECT salary
    INTO salariu
    FROM employees
    WHERE last_name = v_nume;
    insert_info_lcm('f2_lcm(' || v_nume || ')', 1, NULL);
    RETURN salariu;
EXCEPTION
    WHEN no_data_found THEN
        insert_info_lcm('f2_lcm(' || v_nume || ')', 0, 'Nu exista angajati cu numele dat');
        RETURN NULL;
    WHEN too_many_rows THEN
        insert_info_lcm('f2_lcm(' || v_nume || ')', 0, 'Exista mai multi angajati cu numele dat');
        RETURN NULL;
    WHEN OTHERS THEN
        insert_info_lcm('f2_lcm(' || v_nume || ')', 0, SQLERRM);
        RETURN NULL;
END f2_lcm;
SELECT f2_lcm from dual;

-- p4
CREATE OR REPLACE PROCEDURE p4_lcm(v_nume employees.LAST_NAME%TYPE) IS
    salariu employees.SALARY%TYPE;
BEGIN
    SELECT salary
    INTO salariu
    FROM employees
    WHERE last_name = v_nume;
    dbms_output.put_line('Salariul este ' || salariu);
    insert_info_lcm('p4_lcm(' || v_nume || ')', 1, NULL);
EXCEPTION
    WHEN no_data_found THEN
        insert_info_lcm('p4_lcm(' || v_nume || ')', 0, 'Nu exista angajati cu numele dat');
    WHEN too_many_rows THEN
        insert_info_lcm('p4_lcm(' || v_nume || ')', 0, 'Exista mai multi angajati cu numele dat');
    WHEN OTHERS THEN
        insert_info_lcm('p4_lcm(' || v_nume || ')', 0, SQLERRM);
END p4_lcm;
BEGIN
    p4_lcm('Bell');
END;

-- 3. Definiți o funcție stocată care determină numărul de angajați care au avut cel puțin 2 joburi
-- diferite și care în prezent lucrează într-un oraș dat ca parametru. Tratați cazul în care orașul dat
-- ca parametru nu există, respectiv cazul în care în orașul dat nu lucrează niciun angajat. Inserați
-- în tabelul info_*** informațiile corespunzătoare fiecărui caz determinat de valoarea dată pentru
-- parametru.

CREATE OR REPLACE FUNCTION ex3_lcm(v_city locations.CITY%TYPE DEFAULT 'Seattle') RETURN NUMBER IS
    employees_count NUMBER;
    v_cities        NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO employees_count
    FROM employees e
             JOIN departments d ON e.department_id = d.department_id
             JOIN locations l ON d.location_id = l.location_id
    WHERE (SELECT COUNT(*) FROM job_history j WHERE j.employee_id = e.employee_id) >= 1
      AND LOWER(l.city) = LOWER(v_city);

    SELECT COUNT(*)
    INTO v_cities
    FROM locations
    WHERE LOWER(city) = LOWER(v_city);

    IF v_cities = 0 THEN
        insert_info_lcm('ex3_lcm(' || v_city || ')', 0, 'Nu exista orasul "' || v_city || '"');
        RETURN NULL;
    ELSIF employees_count = 0 THEN
        insert_info_lcm('ex3_lcm(' || v_city || ')', 0, 'Nu exista niciun angajat in orasul "' || v_city || '"');
        RETURN NULL;
    ELSE
        insert_info_lcm('ex3_lcm(' || v_city || ')', 0, NULL);
        RETURN employees_count;
    END IF;
END ex3_lcm;

SELECT ex3_lcm FROM dual;

-- 4. Definiți o procedură stocată care mărește cu 10% salariile tuturor angajaților conduși direct sau
-- indirect de către un manager al cărui cod este dat ca parametru. Tratați cazul în care nu există
-- niciun manager cu codul dat. Inserați în tabelul info_*** informațiile corespunzătoare fiecărui
-- caz determinat de valoarea dată pentru parametru.
CREATE OR REPLACE PROCEDURE ex4_help_lcm(
    v_manager_id employees.MANAGER_ID%TYPE,
    rows_modified IN OUT NUMBER,
    record_command BOOLEAN DEFAULT TRUE) IS
BEGIN
    IF NOT record_command THEN
        -- nu actualizam salariul managerului principal
        UPDATE employees SET salary = salary + salary * 0.10 WHERE employee_id = v_manager_id;
        rows_modified := rows_modified + 1;
    END IF;

    FOR i IN (SELECT employee_id FROM employees WHERE manager_id = v_manager_id)
        LOOP
            -- apelam recursiv functia pt toti angajatii subordonati
            ex4_help_lcm(i.employee_id, rows_modified, FALSE);
        END LOOP;

    IF record_command THEN
        -- se va apela doar pt primul manager
        IF rows_modified > 0 THEN
            insert_info_lcm('ex4_lcm(' || v_manager_id || ')', rows_modified, NULL);
        ELSE
            insert_info_lcm('ex4_lcm(' || v_manager_id || ')', 0, 'Nu exista managerul cu id-ul ' || v_manager_id);
        END IF;
    END IF;
END ex4_help_lcm;
SELECT * FROM info_lcm;


CREATE OR REPLACE PROCEDURE ex4_lcm(v_manager_id employees.MANAGER_ID%TYPE) IS
    rows_modified NUMBER := 0;
BEGIN
    -- functie suplimentara pentru a nu fi nevoie sa pasam de fiecare data parametrul rows_modified (care ar trebui sa fie 0 la inceput)
    ex4_help_lcm(v_manager_id, rows_modified, TRUE);
END ex4_lcm;
BEGIN
    ex4_lcm(100);
END;

-- 5. Definiți un subprogram care obține pentru fiecare nume de departament ziua din săptămână în
-- care au fost angajate cele mai multe persoane, lista cu numele acestora, vechimea și venitul lor
-- lunar. Afișați mesaje corespunzătoare următoarelor cazuri:
-- - într-un departament nu lucrează niciun angajat;
-- - într-o zi din săptămână nu a fost nimeni angajat.
-- Observații:
-- a. Numele departamentului și ziua apar o singură dată în rezultat.
-- b. Rezolvați problema în două variante, după cum se ține cont sau nu de istoricul joburilor
-- angajaților.

-- VAR1
CREATE OR REPLACE PROCEDURE ex5_lcm IS
    week_day       VARCHAR2(20);
    v_nr_employees NUMBER;
BEGIN
    FOR d IN (SELECT * FROM departments)
        LOOP
            dbms_output.put('In departmentul ' || d.department_name || ' ');
            SELECT COUNT(*) INTO v_nr_employees FROM employees WHERE department_id = d.department_id;

            IF v_nr_employees = 0 THEN
                dbms_output.put_line('nu exista angajati');
                CONTINUE;
            END IF;

            SELECT hire_week_day
            INTO week_day
            FROM (SELECT TO_CHAR(e.hire_date, 'DAY') AS hire_week_day, COUNT(*)
                  FROM employees e
                  WHERE e.department_id = d.department_id
                  GROUP BY TO_CHAR(e.hire_date, 'DAY')
                  ORDER BY COUNT(*) DESC)
            WHERE rownum = 1;
            dbms_output.put_line('s-au angajat cele mai multe presoane in ziua de ' || week_day);
            FOR e IN (
                SELECT *
                FROM employees
                WHERE department_id = d.department_id AND TO_CHAR(hire_date, 'DAY') = week_day
            ) LOOP
                dbms_output.put(e.first_name || ' ' || e.last_name || ', ');
                dbms_output.put('venit lunar ' || TO_CHAR(e.salary + NVL(e.salary * e.commission_pct, 0)) || ', ');
                dbms_output.put_line('vechime: ' || to_char(round((trunc(sysdate) - e.hire_date) / 365, 0)) || ' ani');
            END LOOP;
            dbms_output.PUT_LINE('__________________________________________________________________');
        END LOOP;
END ex5_lcm;

BEGIN
    ex5_lcm;
END;

-- VAR2
CREATE VIEW all_employees AS
SELECT
    nvl(e.employee_id, j.employee_id) as id,
    nvl(e.first_name, (SELECT e2.first_name FROM employees e2 WHERE e2.employee_id = j.employee_id)) as first_name,
    nvl(e.last_name, (SELECT e2.last_name FROM employees e2 WHERE e2.employee_id = j.employee_id)) as last_name,
    nvl(e.salary, 0) as salary,
    nvl(e.commission_pct, 0) as commission_pct,
    nvl(e.hire_date, j.start_date) as hire_date,
    nvl(j.end_date, trunc(sysdate)) as end_date,
    nvl(e.department_id, j.department_id) as department_id
FROM employees e
FULL JOIN job_history j ON j.employee_id = -1;

CREATE OR REPLACE PROCEDURE ex5_1_lcm IS
    week_day       VARCHAR2(20);
    v_nr_employees NUMBER;
BEGIN

    FOR d IN (SELECT * FROM departments)
        LOOP
            dbms_output.put('In departmentul ' || d.department_name || ' ');
            SELECT COUNT(*) INTO v_nr_employees FROM all_employees e WHERE e.department_id = d.department_id;

            IF v_nr_employees = 0 THEN
                dbms_output.put_line('nu exista angajati');
                CONTINUE;
            END IF;

            SELECT hire_week_day
            INTO week_day
            FROM (SELECT TO_CHAR(e.hire_date, 'DAY') AS hire_week_day, COUNT(*)
                  FROM all_employees e
                  WHERE e.department_id = d.department_id
                  GROUP BY TO_CHAR(e.hire_date, 'DAY')
                  ORDER BY COUNT(*) DESC)
            WHERE rownum = 1;
            dbms_output.put_line('s-au angajat cele mai multe presoane in ziua de ' || week_day);
            FOR e IN (
                SELECT *
                FROM all_employees
                WHERE department_id = d.department_id AND TO_CHAR(hire_date, 'DAY') = week_day
            ) LOOP
                dbms_output.put(e.first_name || ' ' || e.last_name || ', ');
                dbms_output.put('venit lunar ' || TO_CHAR(e.salary + NVL(e.salary * e.commission_pct, 0)) || ', ');
                dbms_output.put_line('vechime: ' || to_char(round((trunc(e.end_date) - e.hire_date) / 365, 0)) || ' ani');
            END LOOP;
            dbms_output.PUT_LINE('__________________________________________________________________');
        END LOOP;
END ex5_1_lcm;
BEGIN
    ex5_1_lcm;
END;

-- 6. Modificați exercițiul anterior astfel încât lista cu numele angajaților să apară într-un clasament
-- creat în funcție de vechimea acestora în departament. Specificați numărul poziției din
-- clasament și apoi lista angajaților care ocupă acel loc. Dacă doi angajați au aceeași vechime,
-- atunci aceștia ocupă aceeași poziție în clasament.

CREATE OR REPLACE PROCEDURE ex6_lcm IS
    week_day VARCHAR2(20);
    v_nr_employees NUMBER;
    v_vechime NUMBER;
    ord_num NUMBER;
BEGIN
    FOR d IN (SELECT * FROM departments)
        LOOP
            dbms_output.put('In departmentul ' || d.department_name || ' ');
            SELECT COUNT(*) INTO v_nr_employees FROM all_employees e WHERE e.department_id = d.department_id;

            IF v_nr_employees = 0 THEN
                dbms_output.put_line('nu exista angajati');
                CONTINUE;
            END IF;

            SELECT hire_week_day
            INTO week_day
            FROM (SELECT TO_CHAR(e.hire_date, 'DAY') AS hire_week_day, COUNT(*)
                  FROM all_employees e
                  WHERE e.department_id = d.department_id
                  GROUP BY TO_CHAR(e.hire_date, 'DAY')
                  ORDER BY COUNT(*) DESC)
            WHERE rownum = 1;
            dbms_output.put_line('s-au angajat cele mai multe presoane in ziua de ' || week_day);
            ord_num := 0;
            v_vechime := 999;
            FOR e IN (
                SELECT *
                FROM all_employees
                WHERE department_id = d.department_id AND TO_CHAR(hire_date, 'DAY') = week_day
                ORDER BY round((trunc(end_date) - hire_date) / 365, 0) DESC
            ) LOOP
                IF round((trunc(e.end_date) - e.hire_date) / 365, 0) < v_vechime THEN
                    ord_num := ord_num + 1;
                    dbms_output.PUT_LINE(ord_num || '.');
                END IF;
                dbms_output.put(e.first_name || ' ' || e.last_name || ', ');
                dbms_output.put('venit lunar ' || TO_CHAR(e.salary + NVL(e.salary * e.commission_pct, 0)) || ', ');
                dbms_output.put_line('vechime: ' || to_char(round((trunc(e.end_date) - e.hire_date) / 365, 0)) || ' ani');
                v_vechime := round((trunc(e.end_date) - e.hire_date) / 365, 0);
            END LOOP;
            dbms_output.PUT_LINE('__________________________________________________________________');
        END LOOP;
END ex6_lcm;

BEGIN
    ex6_lcm;
END;