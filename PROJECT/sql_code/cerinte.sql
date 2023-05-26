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

-- 7.



