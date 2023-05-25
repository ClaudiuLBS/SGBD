-- 1. Mențineți într-o colecție codurile celor mai prost plătiți 5 angajați care nu câștigă comision. Folosind această
-- colecție măriți cu 5% salariul acestor angajați. Afișați valoarea veche a salariului, respectiv valoarea nouă a
-- salariului.

DECLARE
    TYPE vector IS VARRAY(5) OF NUMBER;
    the_poorest_employees vector := vector();
    old_salary employees_lcm.salary%TYPE;
    new_salary employees_lcm.salary%TYPE;
BEGIN
    SELECT * BULK COLLECT INTO the_poorest_employees FROM (SELECT employee_id FROM employees_lcm WHERE commission_pct IS NULL ORDER BY salary) WHERE rownum <= 5;
    FOR i IN the_poorest_employees.first..the_poorest_employees.last LOOP
        SELECT salary into old_salary FROM employees_lcm WHERE employee_id = the_poorest_employees(i);
        UPDATE employees_lcm set salary = salary + salary * 0.05 WHERE employee_id = the_poorest_employees(i);
        SELECT salary into new_salary FROM employees_lcm WHERE employee_id = the_poorest_employees(i);
        dbms_output.PUT_LINE(the_poorest_employees(i) || ' avea salariul ' || old_salary || ' iar acum are ' || new_salary);
    END LOOP;
END;



-- 2. Definiți un tip colecție denumit tip_orase_***. Creați tabelul excursie_*** cu următoarea structură:
-- cod_excursie NUMBER(4), denumire VARCHAR2(20), orase tip_orase_*** (ce va conține lista
-- orașelor care se vizitează într-o excursie, într-o ordine stabilită; de exemplu, primul oraș din listă va fi primul
-- oraș vizitat), status (disponibilă sau anulată).

CREATE OR REPLACE TYPE tip_orase_lcm IS TABLE OF VARCHAR2(200);
CREATE TABLE excursie_lcm (
    cod_excursie NUMBER(4) PRIMARY KEY,
    denumire VARCHAR(20),
    orase tip_orase_lcm,
    status VARCHAR(20) CONSTRAINT check_status_lcm CHECK (status in ('DISPONIBILA', 'ANULATA'))
)
NESTED TABLE orase STORE AS tabel_orase_lcm;

-- a. Inserați 5 înregistrări în tabel.
INSERT INTO excursie_lcm
VALUES (1, 'ROMANIA', tip_orase_lcm('BUCURESTI', 'BRASOV', 'TECUCI', 'GOHOR'), 'DISPONIBILA');

INSERT INTO excursie_lcm
VALUES (2, 'ITALIA', tip_orase_lcm('ROMA', 'MILANO'), 'ANULATA');

INSERT INTO excursie_lcm
VALUES (3, 'GRECIA', tip_orase_lcm('ATENA'), 'DISPONIBILA');

INSERT INTO excursie_lcm
VALUES (4, 'FRANTA', tip_orase_lcm('PARIS', 'STRANSBOURG', 'LYON'), 'DISPONIBILA');

INSERT INTO excursie_lcm
VALUES (5, 'SPANiA', tip_orase_lcm('MADRID', 'BARCELONA', 'VALENCIA'), 'ANULATA');

SELECT * FROM excursie_lcm;


-- b. Actualizați coloana orase pentru o excursie specificată:
-- - adăugați un oraș nou în listă, ce va fi ultimul vizitat în excursia respectivă;

DECLARE
    id NUMBER(4) := &id;
    oras VARCHAR(200) := '&oras';
BEGIN
    INSERT INTO TABLE (SELECT orase FROM excursie_lcm WHERE cod_excursie = id) VALUES (upper(oras));
END;

SELECT * FROM excursie_lcm;

-- - adăugați un oraș nou în listă, ce va fi al doilea oraș vizitat în excursia respectivă;
DECLARE
    id NUMBER(4) := &id;
    oras VARCHAR(200) := '&oras';
    v_orase tip_orase_lcm;
BEGIN
    SELECT orase INTO v_orase FROM excursie_lcm WHERE cod_excursie = id;
    v_orase.extend;
    FOR i IN REVERSE 2..v_orase.last LOOP
        v_orase(i) := v_orase(i-1);
    END LOOP;
    v_orase(2) := upper(oras);
    UPDATE excursie_lcm SET orase = v_orase where cod_excursie = id;
END;
SELECT * FROM excursie_lcm;

-- - inversați ordinea de vizitare a două dintre orașe al căror nume este specificat;
DECLARE
    id NUMBER(4) := &id;
    oras1 VARCHAR(200) := '&oras1';
    oras2 VARCHAR(200) := '&oras2';
    v_orase tip_orase_lcm;
BEGIN
    select orase INTO v_orase FROM excursie_lcm WHERE cod_excursie = id;
    FOR i IN v_orase.first..v_orase.last LOOP
        IF upper(v_orase(i)) = upper(oras1) THEN v_orase(i) := upper(oras2);
        ELSIF upper(v_orase(i)) = upper(oras2) THEN v_orase(i) := upper(oras1);
        END IF;
    END LOOP;
    UPDATE excursie_lcm SET orase = v_orase where cod_excursie = id;
END;
SELECT * FROM excursie_lcm;

-- - eliminați din listă un oraș al cărui nume este specificat.
DECLARE
    id NUMBER(4) := &id;
    oras VARCHAR(200) := '&oras';
    v_orase tip_orase_lcm;
BEGIN
    select orase INTO v_orase FROM excursie_lcm WHERE cod_excursie = id;
    FOR i IN v_orase.first..v_orase.last LOOP
        IF upper(v_orase(i)) = upper(oras) THEN v_orase.delete(i);
        END IF;
    END LOOP;
    UPDATE excursie_lcm SET orase = v_orase where cod_excursie = id;
END;
SELECT * FROM excursie_lcm;

-- c. Pentru o excursie al cărui cod este dat, afișați numărul de orașe vizitate, respectiv numele orașelor.
DECLARE
    id NUMBER(4) := &id;
    v_orase tip_orase_lcm;
BEGIN
    select orase INTO v_orase FROM excursie_lcm WHERE cod_excursie = id;
    dbms_output.PUT_LINE('Au fost vizitate urmatoarele ' || v_orase.count || ' orase:');
    FOR i IN v_orase.first..v_orase.last LOOP
        dbms_output.PUT_LINE(v_orase(i));
    END LOOP;
END;

-- d. Pentru fiecare excursie afișați lista orașelor vizitate.
DECLARE
    TYPE lista_orase IS TABLE OF tip_orase_lcm;
    TYPE lista_tari IS TABLE OF excursie_lcm.denumire%TYPE;
    toate_orasele lista_orase := lista_orase();
    toate_tarile lista_tari := lista_tari();
    v_orase tip_orase_lcm;
BEGIN
    SELECT denumire, orase BULK COLLECT INTO toate_tarile, toate_orasele FROM excursie_lcm;
    FOR i IN toate_orasele.first..toate_orasele.last LOOP
        dbms_output.PUT_LINE('Excursia in ' || toate_tarile(i) || ' are urmatoarele orase: ');
        v_orase := toate_orasele(i);
        FOR j IN v_orase.first..v_orase.last LOOP
            dbms_output.PUT_LINE(v_orase(j));
        END LOOP;
    END LOOP;
END;

-- e. Anulați excursiile cu cele mai puține orașe vizitate.
DECLARE
    TYPE lista_orase IS TABLE OF tip_orase_lcm;
    TYPE lista_coduri IS TABLE OF excursie_lcm.cod_excursie%TYPE;
    toate_orasele lista_orase := lista_orase();
    toate_tarile lista_coduri := lista_coduri();
    v_orase tip_orase_lcm;
    min_orase NUMBER := 9999999;
BEGIN
    SELECT cod_excursie, orase BULK COLLECT INTO toate_tarile, toate_orasele FROM excursie_lcm;
    FOR i IN toate_orasele.first..toate_orasele.last LOOP
        v_orase := toate_orasele(i);
        IF v_orase.count < min_orase THEN min_orase := v_orase.count;
        END IF;
    END LOOP;
    FOR i IN toate_orasele.first..toate_orasele.last LOOP
        v_orase := toate_orasele(i);
        IF v_orase.count = min_orase THEN
            UPDATE excursie_lcm SET status = 'ANULATA' where cod_excursie = toate_tarile(i);
        END IF;
    END LOOP;
END;
SELECT * FROM excursie_lcm;

-- 3. Rezolvați problema anterioară folosind un alt tip de colecție studiat
CREATE OR REPLACE TYPE tip_orase_lcm IS VARRAY(100) OF VARCHAR2(200);
-- in rest la fel ca mai sus