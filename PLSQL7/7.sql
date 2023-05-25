-- 1. Să se creeze un bloc PL/SQL care afişează radicalul unei variabile introduse de la tastatură. Să
-- se trateze cazul în care valoarea variabilei este negativă. Gestiunea erorii se va realiza prin definirea
-- unei excepţii de către utilizator, respectiv prin captarea erorii interne a sistemului. Codul şi mesajul
-- erorii vor fi introduse în tabelul error_***(cod, mesaj).

DECLARE
    v_nr NUMBER := &v_nr;
    exceptie EXCEPTION;
BEGIN
    IF v_nr < 0 THEN
        RAISE exceptie;
    END IF;
    dbms_output.put_line(SQRT(v_nr));
EXCEPTION
    WHEN exceptie THEN
        INSERT INTO error_lcm(err_code, err_msg) VALUES (-20001, 'Numarul este negativ');
END;


-- 2. Să se creeze un bloc PL/SQL prin care să se afişeze numele salariatului (din tabelul emp_***)
-- care câştigă un anumit salariu. Valoarea salariului se introduce de la tastatură. Se va testa programul
-- pentru următoarele valori: 500, 3000 şi 5000.
--  Dacă interogarea nu întoarce nicio linie, atunci să se trateze excepţia şi să se afişeze mesajul “nu
-- exista salariati care sa castige acest salariu ”. Dacă interogarea întoarce o singură linie, atunci să se
-- afişeze numele salariatului. Dacă interogarea întoarce mai multe linii, atunci să se afişeze mesajul
-- “exista mai mulţi salariati care castiga acest salariu”.

DECLARE
    v_salariu emp_lcm.SALARY%TYPE := &v_salariu;
    v_nume    emp_lcm.LAST_NAME%TYPE;
BEGIN
    SELECT first_name || last_name INTO v_nume FROM emp_lcm WHERE salary = v_salariu;
    dbms_output.put_line(v_nume || ' castiga ' || v_salariu);
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('Nimeni nu castiga fix ' || v_salariu);
    WHEN too_many_rows THEN
        dbms_output.put_line('Prea multi angajati castiga ' || v_salariu);
END;


-- 3. Să se creeze un bloc PL/SQL care tratează eroarea apărută în cazul în care se modifică codul unui
-- departament în care lucrează angajaţi

CREATE OR REPLACE TRIGGER ex3_lcm_exceptions
    BEFORE UPDATE OF department_id
    ON dept_lcm
    FOR EACH ROW
DECLARE
    v_employees_count NUMBER;
    exceptie EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_employees_count FROM emp_lcm e WHERE e.department_id = :old.department_id;
    IF v_employees_count > 0 THEN
        RAISE exceptie;
    END IF;
EXCEPTION
    WHEN exceptie THEN
        RAISE_APPLICATION_ERROR(-20002, 'In departamentul respectiv lucreaza angajati, deci nu se poate modifica codul.');
END;


-- 4. Să se creeze un bloc PL/SQL prin care se afişează numele departamentului 10 dacă numărul său
-- de angajaţi este într-un interval dat de la tastatură. Să se trateze cazul în care departamentul nu
-- îndeplineşte această condiţie.

DECLARE
    left_margin      NUMBER := &left_margin;
    right_margin     NUMBER := &right_margin;
    employees_count  NUMBER;
    nume_departament dept_lcm.DEPARTMENT_NAME%TYPE;
    exceptie EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO employees_count FROM emp_lcm WHERE department_id = 10;
    SELECT department_name INTO nume_departament FROM dept_lcm WHERE department_id = 10;
    IF employees_count NOT BETWEEN left_margin AND right_margin THEN
        RAISE exceptie;
    END IF;
    dbms_output.put_line('Numele departamentului este ' || nume_departament);
EXCEPTION
    WHEN exceptie THEN
        dbms_output.put_line('Departamentul 10 nu are un nr de angajati cuprins intre ' || left_margin || ' si ' || right_margin);
END;


-- 5. Să se modifice numele unui departament al cărui cod este dat de la tastatură. Să se trateze cazul
-- în care nu există acel departament. Tratarea excepţie se va face în secţiunea executabilă.




-- 6. Să se creeze un bloc PL/SQL care afişează numele departamentului ce se află într-o anumită
-- locaţie şi numele departamentului ce are un anumit cod (se vor folosi două comenzi SELECT). Să
-- se trateze excepţia NO_DATA_FOUND şi să se afişeze care dintre comenzi a determinat eroarea.
-- Să se rezolve problema în două moduri

-- v1
DECLARE
    v_location_id     locations.LOCATION_ID%TYPE  := &v_location_id;
    v_department_id   dept_lcm.DEPARTMENT_ID%TYPE := &v_department_id;
    v_department_name_by_location dept_lcm.DEPARTMENT_NAME%TYPE;
    v_department_name_by_id dept_lcm.DEPARTMENT_NAME%TYPE;
BEGIN
    SELECT department_name INTO v_department_name_by_location FROM dept_lcm WHERE location_id = v_location_id;
    SELECT department_name INTO v_department_name_by_id FROM dept_lcm WHERE department_id = v_department_id;
    dbms_output.PUT_LINE('Departamentul din locatia cu id ' || v_location_id || ' este ' || v_department_name_by_location);
    dbms_output.PUT_LINE('Departamentul cu id-ul ' || v_department_id || ' este ' || v_department_name_by_id);
EXCEPTION
    WHEN no_data_found THEN
        IF v_department_name_by_location IS NULL THEN
            dbms_output.put_line('Nu exista niciun departament in locatia precizata.');
        ELSIF v_department_name_by_id is null then
            dbms_output.put_line('Nu exista niciun departament cu id-ul respectiv.');
        END IF;
END;

-- v2
DECLARE
    v_location_id                 locations.LOCATION_ID%TYPE  := &v_location_id;
    v_department_id               dept_lcm.DEPARTMENT_ID%TYPE := &v_department_id;
    v_department_name_by_location dept_lcm.DEPARTMENT_NAME%TYPE;
    v_department_name_by_id       dept_lcm.DEPARTMENT_NAME%TYPE;
    v_count                       NUMBER;
    error_location EXCEPTION;
    error_id EXCEPTION;
BEGIN
    SELECT COUNT(*) INTO v_count FROM dept_lcm WHERE location_id = v_location_id;
    IF v_count != 1 THEN
        RAISE error_location;
    END IF;

    SELECT COUNT(*) INTO v_count FROM dept_lcm WHERE department_id = v_department_id;
    IF v_count != 1 THEN
        RAISE error_id;
    END IF;

    SELECT department_name INTO v_department_name_by_location FROM dept_lcm WHERE location_id = v_location_id;
    SELECT department_name INTO v_department_name_by_id FROM dept_lcm WHERE department_id = v_department_id;

    dbms_output.put_line('Departamentul din locatia cu id ' || v_location_id || ' este ' || v_department_name_by_location);
    dbms_output.put_line('Departamentul cu id-ul ' || v_department_id || ' este ' || v_department_name_by_id);

EXCEPTION
    WHEN error_location THEN
        dbms_output.put_line('Nu exista niciun departament in locatia precizata.');
    WHEN error_id THEN
        dbms_output.put_line('Nu exista niciun departament cu id-ul respectiv.');
END;

