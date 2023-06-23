-- 6. Scrieti o functie care returneaza numele localitatii in care se afla o parcela.
-- Daca nu se afla in nicio localitate atunci returneaza 'FARA LOCALITATE'.
-- Daca sunt mai multe atunci returneaza toate localitatile separate prin virgula.
-- Folositi 2 tipuri diferite de colectii.

DECLARE
    x VARCHAR2(100);
BEGIN
    FOR p IN (SELECT * FROM parcela)
        LOOP
            x := apia_pkg.localitate_parcela(p.id);
            dbms_output.put_line(p.id || ': ' || x);
        END LOOP;
END;

-- 7. Scrieti o procedura care afiseaza suprafata totala pentru fiecare cultura a utilizatorilor
-- cu vechime mai mare de 5 ani. Folositi 2 cursoare diferite, dintre care unul sa fie parametrizat.
BEGIN
    apia_pkg.suprafete_useri_5ani();
END;

-- 8. Scrieti o functie care returneaza cel mai folosit cod CAEN al firmelor
-- dintr-o localitate al carei nume este dat ca parametru.
-- Tratati cazul in care localitatea nu exista, in localitate nu exista firme,
-- sau exista 2 coduri folosite la fel de des
SELECT apia_pkg.cel_mai_frecvent_caen('Gohor')
FROM dual;

SELECT apia_pkg.cel_mai_frecvent_caen('Targu Neamt')
FROM dual;

SELECT apia_pkg.cel_mai_frecvent_caen('Nartesti')
FROM dual;

SELECT apia_pkg.cel_mai_frecvent_caen('Brahasesti')
FROM dual;

-- 9. Procedura care verifica daca suprafata totala a firmei unde este
-- administrator persoana fizica cu domiciliu in localitatea data ca
-- parametru este mai mare de 50 hectare

BEGIN
    apia_pkg.suprafata_persoana_din_localitate('gohor');
END;
BEGIN
    apia_pkg.suprafata_persoana_din_localitate('brahasesti');
END;
BEGIN
    apia_pkg.suprafata_persoana_din_localitate('nartesti');
END;

-- 10. Trigger de tip LMD la nivel de comandă: Anuleaza inserarea utilizatorilor in intervalul 21:00 - 07:00
CREATE OR REPLACE TRIGGER anuleaza_inserare_utilizator
    BEFORE INSERT
    ON utilizator
DECLARE
    v_current_time VARCHAR2(8);
BEGIN
    v_current_time := TO_CHAR(SYSDATE, 'HH24:MI:SS');

    IF v_current_time >= '21:00:00' OR v_current_time < '07:00:00' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nu se pot adauga utilizatori intre 21:00 si 07:00.');
    END IF;
END;

INSERT INTO utilizator (id, id_firma, nume_utilizator, parola)
VALUES (9, 4, 'test', 'test');

-- 11. Trigger de tip LMD la nivel de comandă: Modifica suprafta si ultima_actualizare a parcelei
CREATE OR REPLACE TRIGGER actualizare_parcela
    BEFORE UPDATE
    ON parcela
    FOR EACH ROW
BEGIN
    :new.ultima_actualizare := SYSDATE;
    :new.suprafata := apia_pkg.calculare_suprafata(:new.id_coordonate);
END;

CREATE OR REPLACE TRIGGER actualizare_coordonate
    AFTER UPDATE
    ON coordonate
    FOR EACH ROW
DECLARE
    v_id_parcela parcela.ID%TYPE;
BEGIN
    SELECT id INTO v_id_parcela FROM parcela WHERE id_coordonate = :new.id;
    UPDATE parcela
    SET suprafata          = apia_pkg.calculare_suprafata(:new.id),
        ultima_actualizare = SYSDATE
    WHERE id = v_id_parcela;
END;

SELECT *
FROM parcela WHERE id = 25;

UPDATE parcela
SET nr_parcela = 6
WHERE id = 25;

SELECT *
FROM parcela WHERE id = 25;


-- 12. Trigger de tip LDD: Eroare cand alt user in afara de ADMIN incearca sa modifice tabele
CREATE OR REPLACE TRIGGER modificare_tabele
    AFTER DROP OR ALTER
    ON SCHEMA
    WHEN (USER != 'ADMIN')
BEGIN
    RAISE_APPLICATION_ERROR(-20010, 'Doar userul ADMIN poate sterge sau modifica tabele!');
END;

DROP TABLE firma_caen;
