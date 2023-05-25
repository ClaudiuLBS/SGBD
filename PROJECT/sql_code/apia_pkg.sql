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
        v_id_parcela NUMBER
    ) RETURN VARCHAR2;
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
--      Aplicam formula Shoelace
        FOR i IN v_lat.first..(v_lat.last - 1)
            LOOP
                v_suprafata := v_suprafata + (v_long(i) + v_long(i + 1)) * (v_lat(i + 1) - v_lat(i));
            END LOOP;

--      Aici avem suprafata in grade la patrat
        v_suprafata := ABS(v_suprafata) / 2;

--      Facem conversie in km2
        v_suprafata := v_suprafata * conv_factor * conv_factor;

--      Inmultim cu 100 sa obtine hectare
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
        v_id_parcela NUMBER
    ) RETURN VARCHAR2 AS
        TYPE LOC_LIST IS VARRAY(10) OF VARCHAR2(100);
        v_nume_localitati LOC_LIST := loc_list();
        v_lat_parcela     NUM_LIST;
        v_long_parcela    NUM_LIST;
        v_lat_localitate  NUM_LIST;
        v_long_localitate NUM_LIST;
    BEGIN
        dbms_output.put_line(v_id_parcela);
        -- Salvam coordonatele parcelei
        SELECT c.latitudine, c.longitudine
        INTO v_lat_parcela, v_long_parcela
        FROM parcela p
                 JOIN coordonate c ON c.id = p.id_coordonate
        WHERE p.id = v_id_parcela;
        FOR l IN (SELECT * FROM localitate)
            LOOP
                -- Salvam coordonatele localitatii
                SELECT c.latitudine, c.longitudine
                INTO v_lat_localitate, v_long_localitate
                FROM coordonate c
                WHERE c.id = l.id;
                IF geo_apia_pkg.intersectie_poligoane(
                           v_lat_parcela, v_long_parcela,
                           v_lat_localitate, v_long_localitate
                       ) = 1 THEN
--                     v_nume_localitati.extend;
--                     v_nume_localitati(v_nume_localitati.last) := l.denumire;
                    dbms_output.put_line(l.denumire);
                END IF;
            END LOOP;
        IF v_nume_localitati.count > 0 THEN
            RETURN v_nume_localitati(0);
        END IF;
        RETURN 'nothing';
    END;
END apia_pkg;