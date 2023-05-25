-- 1. Definiți un declanșator care să permită ștergerea informațiilor din tabelul dept_*** decât dacă
-- utilizatorul este SCOTT.

CREATE OR REPLACE TRIGGER ex1_lcm
    BEFORE DELETE
    ON dept_lcm
    FOR EACH ROW
    WHEN (USER != 'SCOTT')
BEGIN
    RAISE_APPLICATION_ERROR(-20001, 'Doar utilizatorul SCOTT poate sterge din tabelul "dept_lcm"');
END;

-- 2. Creați un declanșator prin care să nu se permită mărirea comisionului astfel încât să depășească
-- 50% din valoarea salariului.

CREATE OR REPLACE TRIGGER ex2_lcm
    BEFORE UPDATE OF commission_pct
    ON emp_lcm
    FOR EACH ROW
BEGIN
    IF :new.commission_pct > 0.5 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Comisionul nu poate depasi 50% din valoarea salariului');
    END IF;
END;
update emp_lcm SET commission_pct = 0.9 WHERE employee_id = 110;


-- 3. a. Introduceți în tabelul info_dept_*** coloana numar care va reprezenta pentru fiecare
-- departament numărul de angajați care lucrează în departamentul respectiv. Populați cu date
-- această coloană pe baza informațiilor din schemă.

ALTER TABLE info_dept_lcm
    ADD numar NUMBER;

UPDATE info_dept_lcm i
SET numar = (SELECT COUNT(*) FROM info_emp_lcm e WHERE e.id_dept = i.id);

SELECT *
FROM info_dept_lcm;


-- b. Definiți un declanșator care va actualiza automat această coloană în funcție de actualizările
-- realizate asupra tabelului info_emp_***
SELECT * FROM info_dept_lcm;

CREATE OR REPLACE TRIGGER ex3_lcm
    AFTER UPDATE OR INSERT OR DELETE
    ON info_emp_lcm
BEGIN
    UPDATE info_dept_lcm i SET numar = (SELECT COUNT(*) FROM info_emp_lcm e WHERE e.id_dept = i.id);
END;

UPDATE info_emp_lcm SET id_dept = 100 WHERE id_dept = 50 and rownum <= 3;
SELECT * FROM info_dept_lcm;


-- 4. Definiți un declanșator cu ajutorul căruia să se implementeze restricția conform căreia într-un
-- departament nu pot lucra mai mult de 45 persoane (se vor utiliza doar tabelele emp_*** și
-- dept_*** fără a modifica structura acestora).
create or replace function emp_number_lcm(v_department_id dept_lcm.department_id%type) return number IS
    v_employees_count NUMBER;
begin
    SELECT count(*) into v_employees_count FROM emp_lcm WHERE department_id = v_department_id;
    return v_employees_count;
END;

CREATE OR REPLACE TRIGGER ex4_lcm
    BEFORE UPDATE OR INSERT
    ON emp_lcm
    FOR EACH ROW
DECLARE
    v_employees_count NUMBER;
BEGIN
    v_employees_count := emp_number_lcm(:NEW.department_id);
    IF v_employees_count >= 45 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Departamentul nu poate avea mai mult de 45 de angajati');
    END IF;
END;
UPDATE emp_lcm SET department_id = 50;

-- 5. a. Pe baza informațiilor din schemă creați și populați cu date următoarele două tabele:
-- - emp_test_*** (employee_id – cheie primară, last_name, first_name, department_id);
-- - dept_test_*** (department_id – cheie primară, department_name).

CREATE TABLE emp_test_lcm AS
SELECT employee_id, last_name, first_name, department_id
FROM emp_lcm;

CREATE TABLE dept_test_lcm AS
SELECT department_id, department_name
FROM dept_lcm;


-- b. Definiți un declanșator care va determina ștergeri și modificări în cascadă:
-- - ștergerea angajaților din tabelul emp_test_*** dacă este eliminat departamentul acestora din tabelul dept_test_***;
-- - modificarea codului de departament al angajaților din tabelul emp_test_*** dacă departamentul respectiv este modificat în tabelul dept_test_***.

CREATE OR REPLACE TRIGGER ex5_lcm
    AFTER UPDATE OR DELETE
    ON dept_test_lcm
    FOR EACH ROW
BEGIN
    IF DELETING THEN
        DELETE FROM emp_test_lcm e WHERE e.department_id = :old.department_id;
    ELSIF UPDATING THEN
        UPDATE emp_test_lcm e SET e.department_id = :new.department_id WHERE e.department_id = :old.department_id;
    END IF;
END;

-- Testați și rezolvați problema în următoarele situații:
-- - nu este definită constrângere de cheie externă între cele două tabele;
-- FUNCTIONEAZA PRIMA VARIANTA

-- - este definită constrângerea de cheie externă între cele două tabele;
-- TREBUIE FOLOSIT BEFORE IN LOC DE AFTER UPDATE OR DELETE

-- - este definită constrângerea de cheie externă între cele două tabele cu opțiunea ON DELETE CASCADE;
-- ATUNCI NU MAI ESTE NEVOIE DE TRIGGER

-- - este definită constrângerea de cheie externă între cele două tabele cu opțiunea ON DELETE SET NULL.
-- TREBUIE PASTRAT AFTER UPDATE OR DELETE


-- 6. a. Creați un tabel cu următoarele coloane:
-- - user_id (SYS.LOGIN_USER);
-- - nume_bd (SYS.DATABASE_NAME);
-- - erori (DBMS_UTILITY.FORMAT_ERROR_STACK);
-- - data.

CREATE TABLE errors_lcm
(
    user_id VARCHAR2(30),
    nume_bd VARCHAR2(30),
    erori   VARCHAR2(4000),
    data    DATE DEFAULT SYSDATE
);

-- b. Definiți un declanșator sistem (la nivel de bază de date) care să introducă date în acest tabel
-- referitoare la erorile apărute.

CREATE OR REPLACE TRIGGER ex6_lcm
    AFTER SUSPEND ON SCHEMA
BEGIN
    INSERT INTO errors_lcm (user_id, nume_bd, erori) VALUES (sys.LOGIN_USER, sys.DATABASE_NAME, dbms_utility.FORMAT_ERROR_STACK);
END;
