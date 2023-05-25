-- 2. Se dă următorul enunț: Pentru fiecare zi a lunii octombrie (se vor lua în considerare și zilele din
-- lună în care nu au fost realizate împrumuturi) obțineți numărul de împrumuturi efectuate.

-- a. Încercați să rezolvați problema în SQL fără a folosi structuri ajutătoare.
DECLARE
    nr_imprumuturi NUMBER(5);
BEGIN
    FOR i IN 1..30
        LOOP
            SELECT COUNT(*)
            INTO nr_imprumuturi
            FROM rental
            WHERE i = TO_CHAR(book_date, 'dd');
            dbms_output.put_line('2020 noiembrie, ' || i || ': ' || nr_imprumuturi);
        END LOOP;
END;

-- b. Definiți tabelul octombrie_*** (id, data). Folosind PL/SQL populați cu date acest tabel.
-- Rezolvați în SQL problema dată.
CREATE TABLE octombrie_lcm
(
    id   NUMBER,
    data DATE
);
-- tabelul desi se cheama octombrie_lcm, am inserat date din luna noiembrie deoarece in tabelul rental era prezenta doar luna a 11a
DECLARE
    data_octombrie DATE := TO_DATE('1/11/2022 13:25:15', 'dd/mm/yyyy hh24:mi:ss') - 1;
BEGIN
    FOR i IN 1..30
        LOOP
            INSERT INTO octombrie_lcm (id, data) VALUES (i, data_octombrie + i);
        END LOOP;
END;

SELECT o.data, COUNT(r.book_date) AS nr_imprumuturi
FROM octombrie_lcm o
         LEFT JOIN rental r ON o.data = r.book_date
GROUP BY o.data
ORDER BY o.data;


-- 3. Definiți un bloc anonim în care să se determine numărul de filme (titluri) împrumutate de un
-- membru al cărui nume este introdus de la tastatură. Tratați următoarele două situații: nu există nici
-- un membru cu nume dat; există mai mulți membrii cu același nume.

DECLARE
    nume_membru VARCHAR2(255) := '&nume_membru';
    id_membru   member.MEMBER_ID%TYPE;
    nr_membrii  NUMBER(5);
    nr_titluri  NUMBER(5);
BEGIN
    SELECT COUNT(*)
    INTO nr_membrii
    FROM member
    WHERE LOWER(last_name) = LOWER(nume_membru);
    IF nr_membrii = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Nu exista niciun membru cu numele ' || nume_membru);
    ELSIF nr_membrii >= 2 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Sunt ' || nr_membrii || ' cu numele ' || nume_membru);
    ELSE
        SELECT member_id INTO id_membru FROM member WHERE last_name = nume_membru;
        SELECT COUNT(*) INTO nr_titluri FROM rental WHERE member_id = id_membru;
        dbms_output.put_line(nume_membru || ' a imprumutat ' || nr_titluri || ' titluri');
    END IF;
END;


-- 4. Modificați problema anterioară astfel încât să afișați și următorul text:
-- - Categoria 1 (a împrumutat mai mult de 75% din titlurile existente)
-- - Categoria 2 (a împrumutat mai mult de 50% din titlurile existente)
-- - Categoria 3 (a împrumutat mai mult de 25% din titlurile existente)
-- - Categoria 4 (altfel)
DECLARE
    nume_membru   VARCHAR2(255) := '&nume_membru';
    id_membru     member.MEMBER_ID%TYPE;
    nr_membrii    NUMBER(5);
    nr_titluri    NUMBER(5);
    total_titluri NUMBER(5);
BEGIN
    SELECT COUNT(*)
    INTO nr_membrii
    FROM member
    WHERE LOWER(last_name) = LOWER(nume_membru);
    IF nr_membrii = 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Nu exista niciun membru cu numele ' || nume_membru);
    ELSIF nr_membrii >= 2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Sunt ' || nr_membrii || ' cu numele ' || nume_membru);
    ELSE
        SELECT member_id INTO id_membru FROM member WHERE last_name = nume_membru;
        SELECT COUNT(*) INTO nr_titluri FROM rental WHERE member_id = id_membru;
        SELECT COUNT(*) INTO total_titluri FROM title;
        dbms_output.put_line(nume_membru || ' a imprumutat ' || nr_titluri || ' titluri');
        IF nr_titluri >= 0.75 * total_titluri THEN
            dbms_output.put_line(nume_membru || ' a împrumutat mai mult de 75% din titlurile existente.');
        ELSIF nr_titluri >= 0.5 * total_titluri THEN
            dbms_output.put_line(nume_membru || ' a împrumutat mai mult de 50% din titlurile existente.');
        ELSIF nr_titluri >= 0.25 * total_titluri THEN
            dbms_output.put_line(nume_membru || ' a împrumutat mai mult de 25% din titlurile existente.');
        ELSE
            dbms_output.put_line(nume_membru || ' a împrumutat mai putin de 25% din titlurile existente.');
        END IF;
    END IF;
END;


-- 5. Creați tabelul member_*** (o copie a tabelului member). Adăugați în acest tabel coloana
-- discount, care va reprezenta procentul de reducere aplicat pentru membrii, în funcție de categoria
-- din care fac parte aceștia:
-- - 10% pentru membrii din Categoria 1
-- - 5% pentru membrii din Categoria 2
-- - 3% pentru membrii din Categoria 3
-- - nimic
-- Actualizați coloana discount pentru un membru al cărui cod este dat de la tastatură. Afișați un
-- mesaj din care să reiasă dacă actualizarea s-a produs sau nu

CREATE TABLE member_lcm AS SELECT * FROM member;
ALTER TABLE member_lcm ADD discount NUMBER;
DECLARE
    id_membru        member_lcm.MEMBER_ID%TYPE := &id_membru;
    nume_membru      VARCHAR2(255);
    nr_titluri       NUMBER(5);
    total_titluri    NUMBER(5);
    discount_curent  NUMBER(5);
    discount_meritat NUMBER(5);
BEGIN
    SELECT last_name, discount
    INTO nume_membru, discount_curent
    FROM member_lcm
    WHERE id_membru = member_id;

    SELECT COUNT(*) INTO nr_titluri FROM rental WHERE member_id = id_membru;
    SELECT COUNT(*) INTO total_titluri FROM title;

    IF nr_titluri >= 0.75 * total_titluri THEN discount_meritat := 10;
    ELSIF nr_titluri >= 0.5 * total_titluri THEN discount_meritat := 5;
    ELSIF nr_titluri >= 0.25 * total_titluri THEN discount_meritat := 3;
    ELSE discount_meritat := 0;
    END IF;

    IF discount_meritat != discount_curent OR discount_curent IS NULL THEN
        dbms_output.put_line('I s-a actualizat discountul membrului ' || nume_membru || ' la ' || discount_meritat || '%.');
        UPDATE member_lcm SET discount = discount_meritat WHERE member_id = id_membru;
    ELSE
        dbms_output.put_line('Membrului ' || nume_membru || ' nu i s-a actualizat discountul. Acesta a ramas ' || discount_curent || '%.');
    END IF;
END;
