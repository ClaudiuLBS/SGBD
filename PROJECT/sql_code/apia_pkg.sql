CREATE OR REPLACE PACKAGE apia_pkg AS
    FUNCTION calculare_suprafata(
        v_id_coordonate coordonate.ID%TYPE
    ) RETURN NUMBER;

    PROCEDURE creare_parcela(
        v_id_proprietar utilizator.ID%TYPE,
        v_id_coordonate coordonate.ID%TYPE,
        v_id_cultura cultura.ID%TYPE,
        v_id_parcela parcela.NR_PARCELA%TYPE
    );

    FUNCTION localitate_parcela(
        v_id_parcela parcela.ID%TYPE
    ) RETURN VARCHAR2;

    PROCEDURE suprafete_useri_5ani;

    FUNCTION cel_mai_frecvent_caen(
        v_nume_localitate localitate.DENUMIRE%TYPE
    ) RETURN caen.COD%TYPE;

    PROCEDURE suprafata_persoana_din_localitate(
        v_nume_localitate localitate.DENUMIRE%TYPE
    );
END apia_pkg;

CREATE OR REPLACE PACKAGE BODY apia_pkg AS
    FUNCTION calculare_suprafata(
        v_id_coordonate coordonate.ID%TYPE
    ) RETURN NUMBER AS
        v_suprafata NUMBER := 0;
        v_lat       NUM_LIST;
        v_long      NUM_LIST;
        conv_factor NUMBER := 93;
    BEGIN
        SELECT latitudine, longitudine INTO v_lat, v_long FROM coordonate WHERE id = v_id_coordonate;
        -- Aplicam formula Shoelace
        FOR i IN v_lat.first..(v_lat.last - 1)
            LOOP
                v_suprafata := v_suprafata + (v_long(i) + v_long(i + 1)) * (v_lat(i + 1) - v_lat(i));
            END LOOP;

        -- Aici avem suprafata in grade la patrat
        v_suprafata := ABS(v_suprafata) / 2;

        -- Facem conversie in km2
        v_suprafata := v_suprafata * conv_factor * conv_factor;

        -- Inmultim cu 100 sa obtine hectare
        v_suprafata := v_suprafata * 100;
        RETURN ROUND(v_suprafata, 2);
    END;

    PROCEDURE creare_parcela(
        v_id_proprietar utilizator.ID%TYPE,
        v_id_coordonate coordonate.ID%TYPE,
        v_id_cultura cultura.ID%TYPE,
        v_id_parcela parcela.NR_PARCELA%TYPE
    ) AS
        v_suprafata NUMBER;
    BEGIN
        v_suprafata := calculare_suprafata(v_id_coordonate);
        INSERT INTO parcela (id_proprietar, id_coordonate, id_cultura, nr_parcela, suprafata, ultima_actualizare)
        VALUES (v_id_proprietar, v_id_coordonate, v_id_cultura, v_id_parcela, v_suprafata, SYSDATE);
    END;

    FUNCTION localitate_parcela(
        v_id_parcela parcela.ID%TYPE
    ) RETURN VARCHAR2 AS
        TYPE LOC_LIST IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
        v_nume_localitati LOC_LIST;
        v_lat_parcela     NUM_LIST;
        v_long_parcela    NUM_LIST;
        v_lat_localitate  NUM_LIST;
        v_long_localitate NUM_LIST;
        v_idx             NUMBER := 0;
    BEGIN
        -- Salvam coordonatele parcelei
        SELECT c.latitudine, c.longitudine
        INTO v_lat_parcela, v_long_parcela
        FROM parcela p
                 JOIN coordonate c ON c.id = p.id_coordonate
        WHERE p.id = v_id_parcela;
        -- Pentru fiecra localitate
        FOR l IN (SELECT * FROM localitate)
            LOOP
                -- Salvam coordonatele localitatii
                SELECT c.latitudine, c.longitudine
                INTO v_lat_localitate, v_long_localitate
                FROM coordonate c
                WHERE c.id = l.id;
                -- Daca se intersecteaza cu parcela atunci o salvam
                IF geo_apia_pkg.intersectie_poligoane(
                           v_lat_parcela, v_long_parcela,
                           v_lat_localitate, v_long_localitate
                       ) = 1 THEN
                    v_idx := v_idx + 1;
                    v_nume_localitati(v_idx) := l.denumire;
                END IF;
            END LOOP;

        -- Daca nu am gasit nicio localitate
        IF v_nume_localitati.count = 0 THEN
            RETURN 'FARA LOCALITATE';
        END IF;

        -- Aici lipesc toate localitatile in prima localitate
        FOR i IN 2..v_nume_localitati.last
            LOOP
                v_nume_localitati(1) := v_nume_localitati(1) || ', ' || v_nume_localitati(i);
            END LOOP;

        RETURN v_nume_localitati(1);
    END;

    PROCEDURE suprafete_useri_5ani IS
        -- Toti userii mai vechi de 5 ani
        CURSOR c_utilizatori IS
            SELECT nume_utilizator
            FROM utilizator
            WHERE ADD_MONTHS(data_inscriere, 12 * 5) < SYSDATE;

        -- id-ul culturii si suprafata totala pt fiecare user data parametru
        CURSOR c_parcele_utilizator (username utilizator.NUME_UTILIZATOR%TYPE) IS
            SELECT id_cultura, SUM(suprafata) AS suprafata
            FROM parcela
            WHERE id_proprietar = (SELECT id FROM utilizator WHERE nume_utilizator = username)
            GROUP BY id_cultura;
        v_nume_cultura cultura.DENUMIRE%TYPE;
    BEGIN
        dbms_output.put_line('_____________________');
        FOR v_user IN c_utilizatori
            LOOP
                dbms_output.put_line(v_user.nume_utilizator || ': ');
                FOR v_parcela IN c_parcele_utilizator(v_user.nume_utilizator)
                    LOOP
                        SELECT denumire INTO v_nume_cultura FROM cultura WHERE id = v_parcela.id_cultura;
                        dbms_output.put_line(TO_CHAR(v_parcela.suprafata) || ' hectare de ' || v_nume_cultura);
                    END LOOP;
                dbms_output.put_line('_____________________');
            END LOOP;
    END;

    FUNCTION cel_mai_frecvent_caen(
        v_nume_localitate localitate.DENUMIRE%TYPE
    ) RETURN caen.COD%TYPE AS
        -- codul si frecventa maxima
        v_cod           caen.COD%TYPE;
        v_max           NUMBER;

        -- codul si a doua frecventa maxima
        v_second_max    NUMBER := 0;
        v_second_code   caen.COD%TYPE;

        -- numarul localitatilor cu denumirea respectiva
        v_nr_localitati NUMBER := 0;

        -- codurile caen si frecventa lor in firmele din localitate data ca parametru
        CURSOR c_coduri IS
            SELECT fc.cod_caen, COUNT(fc.cod_caen) AS frecventa
            FROM firma f
                     JOIN firma_caen fc ON f.id = fc.id_firma
            WHERE f.id_sediu = (SELECT l.id FROM localitate l WHERE LOWER(l.denumire) = LOWER(v_nume_localitate))
            GROUP BY fc.cod_caen
            ORDER BY COUNT(fc.cod_caen) DESC;

        localitate_inexistenta EXCEPTION;
        prea_multe_localitati EXCEPTION;
        localitatea_fara_firme EXCEPTION;
        prea_multe_coduri_caen EXCEPTION;
    BEGIN
        SELECT COUNT(*)
        INTO v_nr_localitati
        FROM localitate
        WHERE LOWER(denumire) = LOWER(v_nume_localitate);

        IF v_nr_localitati = 0 THEN
            RAISE localitate_inexistenta;
        ELSIF v_nr_localitati > 1 THEN
            RAISE prea_multe_localitati;
        END IF;

        OPEN c_coduri;
        FETCH c_coduri INTO v_cod, v_max;

        -- daca nu exista niciun cod inseamna ca nu exista firme
        IF v_cod IS NULL THEN
            RAISE localitatea_fara_firme;
        END IF;

        -- daca exista mai mult de un cod
        IF NOT c_coduri%NOTFOUND THEN
            FETCH c_coduri INTO v_second_code, v_second_max;
        END IF;
        CLOSE c_coduri;

        -- daca primele 2 coduri sunt la fel de frecvente
        IF v_second_max = v_max THEN
            RAISE prea_multe_coduri_caen;
        END IF;

        RETURN v_cod;
    EXCEPTION
        WHEN localitatea_fara_firme THEN
            RAISE_APPLICATION_ERROR(-20000, 'Nu exista firme in localitatea specificata.');
        WHEN localitate_inexistenta THEN
            RAISE_APPLICATION_ERROR(-20001, 'Localitatea specificata nu exista.');
        WHEN prea_multe_localitati THEN
            RAISE_APPLICATION_ERROR(-20002, 'Prea multe localitati cu numele specificat.');
        WHEN prea_multe_coduri_caen THEN
            RAISE_APPLICATION_ERROR(-20003, 'Exista mai mult de un cod caen cu frecventa ' || v_max || '.');
    END;

    PROCEDURE suprafata_persoana_din_localitate(
        v_nume_localitate localitate.DENUMIRE%TYPE
    ) IS
        v_suprafata NUMBER;
    BEGIN
        -- calculam suprafata detinuta de firma persoanei fizice din localitatea specificata
        SELECT SUM(p.suprafata)
        INTO v_suprafata
        FROM utilizator u
                 JOIN parcela p ON u.id = p.id_proprietar
                 JOIN firma f ON f.id = u.id_firma
                 JOIN persoana_fizica pf ON pf.id = f.id_administrator
                 JOIN localitate l ON pf.id_domiciliu = l.id
        WHERE LOWER(l.denumire) = LOWER(v_nume_localitate)
        GROUP BY u.nume_utilizator;

        IF v_suprafata >= 50 then
            dbms_output.PUT_LINE('Suprafata este mai mare de 50 hectare');
        ELSE
            dbms_output.PUT_LINE('Suprafata este mai mica de 50 hectare');
        END IF;

    EXCEPTION
        WHEN too_many_rows THEN
            RAISE_APPLICATION_ERROR(-20004, 'Prea multe persoane fizice cu domiciliu in ' || v_nume_localitate);
        WHEN no_data_found THEN
            RAISE_APPLICATION_ERROR(-20005, 'Nu exista nicio persoana fizica cu domiciliu in ' || v_nume_localitate);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(SQLCODE, SQLERRM);
    END;
END apia_pkg;
