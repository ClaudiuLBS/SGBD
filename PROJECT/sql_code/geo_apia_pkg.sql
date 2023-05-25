CREATE OR REPLACE PACKAGE geo_apia_pkg AS
    FUNCTION test_orientare(
        x1 NUMBER, y1 NUMBER,
        x2 NUMBER, y2 NUMBER,
        x3 NUMBER, y3 NUMBER
    ) RETURN NUMBER;

    FUNCTION intersectie_linii(
        x_start_1 NUMBER, y_start_1 NUMBER,
        x_end_1 NUMBER, y_end_1 NUMBER,
        x_start_2 NUMBER, y_start_2 NUMBER,
        x_end_2 NUMBER, y_end_2 NUMBER
    ) RETURN NUMBER;

    FUNCTION punct_in_poligon(
        x_poligon NUM_LIST, y_poligon NUM_LIST,
        x_punct NUMBER, y_punct NUMBER,
        x_referinta NUMBER DEFAULT 0, y_referinta NUMBER DEFAULT 0
    ) RETURN NUMBER;

    FUNCTION intersectie_poligoane(
        x_poligon_1 NUM_LIST, y_poligon_1 NUM_LIST,
        x_poligon_2 NUM_LIST, y_poligon_2 NUM_LIST
    ) RETURN NUMBER;

END geo_apia_pkg;

CREATE OR REPLACE PACKAGE BODY geo_apia_pkg AS
    FUNCTION test_orientare(
        x1 NUMBER, y1 NUMBER,
        x2 NUMBER, y2 NUMBER,
        x3 NUMBER, y3 NUMBER
    ) RETURN NUMBER
    AS
        v_rezultat NUMBER;
    BEGIN
        v_rezultat := x3 * y1 + x1 * y2 - x3 * y2 - x1 * y3 + x2 * y3 - x2 * y1;
        RETURN v_rezultat;
    END;

    FUNCTION intersectie_linii(
        x_start_1 NUMBER, y_start_1 NUMBER,
        x_end_1 NUMBER, y_end_1 NUMBER,
        x_start_2 NUMBER, y_start_2 NUMBER,
        x_end_2 NUMBER, y_end_2 NUMBER
    ) RETURN NUMBER
    AS
        pos1       NUMBER;
        pos2       NUMBER;
        pos3       NUMBER;
        pos4       NUMBER;
        v_rezultat NUMBER := 1;
    BEGIN
        pos1 := geo_apia_pkg.test_orientare(x_start_1, y_start_1, x_end_1, y_end_1, x_start_2, y_start_2);
        pos2 := geo_apia_pkg.test_orientare(x_start_1, y_start_1, x_end_1, y_end_1, x_end_2, y_end_2);
        pos3 := geo_apia_pkg.test_orientare(x_start_2, y_start_2, x_end_2, y_end_2, x_start_1, y_start_1);
        pos4 := geo_apia_pkg.test_orientare(x_start_2, y_start_2, x_end_2, y_end_2, x_end_1, y_end_1);
        IF ((pos1 > 0 AND pos2 > 0) OR (pos1 < 0 AND pos2 < 0)) OR
           ((pos3 > 0 AND pos4 > 0) OR (pos3 < 0 AND pos4 < 0)) THEN
            v_rezultat := 0;
        END IF;
        RETURN v_rezultat;
    END;

    FUNCTION punct_in_poligon(
        x_poligon NUM_LIST, y_poligon NUM_LIST,
        x_punct NUMBER, y_punct NUMBER,
        x_referinta NUMBER DEFAULT 0, y_referinta NUMBER DEFAULT 0
    ) RETURN NUMBER AS
        intersectii      NUMBER := 0;
        se_intersecteaza NUMBER;
    BEGIN
        --      numaram intersectiile dintre laturile poligonului si linia dusa din punct catre referinta
        FOR i IN x_poligon.first..(x_poligon.last - 1)
            LOOP
                se_intersecteaza := geo_apia_pkg.intersectie_linii(
                        x_punct, y_punct, x_referinta, y_referinta,
                        x_poligon(i), y_poligon(i), x_poligon(i + 1), y_poligon(i + 1)
                    );
                IF (se_intersecteaza = 1) THEN
                    intersectii := intersectii + 1;
                END IF;
            END LOOP;
--      daca e nr par, nu e inauntru, si daca e impar, e inauntru
        IF MOD(intersectii, 2) = 0 THEN
            RETURN 0;
        ELSE
            RETURN 1;
        END IF;
    END;

    FUNCTION intersectie_poligoane(
        x_poligon_1 NUM_LIST, y_poligon_1 NUM_LIST,
        x_poligon_2 NUM_LIST, y_poligon_2 NUM_LIST
    ) RETURN NUMBER AS
    BEGIN
        FOR i IN x_poligon_1.first..x_poligon_1.last
            LOOP
--              Daca unul dintre punctele primului poligon se afla pe al doilea poligon
                IF geo_apia_pkg.punct_in_poligon(x_poligon_2, y_poligon_2, x_poligon_1(i), y_poligon_1(i)) = 1 THEN
                    RETURN 1;
                END IF;
            END LOOP;
        FOR i IN x_poligon_2.first..x_poligon_2.last
            LOOP
--              Daca unul dintre punctele celui de-al doilea poligon se afla pe primul poligon
                IF geo_apia_pkg.punct_in_poligon(x_poligon_1, y_poligon_1, x_poligon_2(i), y_poligon_2(i)) = 1 THEN
                    RETURN 1;
                END IF;
            END LOOP;
        RETURN 0;
    END;
END geo_apia_pkg;
