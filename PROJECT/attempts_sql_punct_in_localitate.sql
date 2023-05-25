
CREATE OR REPLACE FUNCTION punct_in_localitate(
    v_latitudine NUMBER,
    v_longitudine NUMBER,
    v_id_localitate NUMBER
) RETURN BOOLEAN AS
    v_punct              SDO_GEOMETRY;
    v_poligon            SDO_GEOMETRY;
    v_lat_localitate     NUM_LIST;
    v_long_localitate    NUM_LIST;
    v_coordonate_poligon SDO_ORDINATE_ARRAY := sdo_ordinate_array();
    v_rezultat NUMBER;
BEGIN
--  salvam coordonatele localitatii
    SELECT c.latitudine, c.longitudine
    INTO v_lat_localitate, v_long_localitate
    FROM localitate l
             JOIN coordonate c ON c.id = l.id_coordonate
    WHERE l.id = v_id_localitate;

-- le introducem intr-un singur vector de forma (x1,y1,x2,y2,x3,y3,...xn,yn)
    FOR i in v_lat_localitate.first..v_long_localitate.last loop
        v_coordonate_poligon.extend;
        v_coordonate_poligon(v_coordonate_poligon.last) := v_lat_localitate(i);
        v_coordonate_poligon.extend;
        v_coordonate_poligon(v_coordonate_poligon.last) := v_long_localitate(i);
    END LOOP;

--  Ne definim punctul
    v_punct := sdo_geometry(2001, NULL, sdo_point_type(v_latitudine, v_longitudine, NULL), NULL, NULL);

--  Ne definim poligonul
    v_poligon := sdo_geometry(
        2003, NULL, NULL,
        sdo_elem_info_array(1, 1003, 1),
        v_coordonate_poligon
    );
-- --  Verificam daca e inauntru

    v_rezultat := sdo_geom.relate(SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(5, 5, NULL), NULL, NULL), 'INSIDE', SDO_GEOMETRY(2003, NULL, NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 1),
        SDO_ORDINATE_ARRAY(0, 0, 0, 10, 10, 10, 10, 0, 0, 0)
    ), 0.005);
--     SELECT count(*) into v_rezultat from dual where sdo_inside(
--     SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(5, 5, NULL), NULL, NULL),
--     SDO_GEOMETRY(2003, NULL, NULL,
--         SDO_ELEM_INFO_ARRAY(1, 1003, 1),
--         SDO_ORDINATE_ARRAY(0, 0, 0, 10, 10, 10, 10, 0, 0, 0)
--     )
-- ) = 'TRUE';
    RETURN v_rezultat;
END;

BEGIN
    if punct_in_localitate(1,1,1) then
        dbms_output.PUT_LINE('ok');
    END IF;
END;

SELECT count(*) from dual where sdo_inside(
    SDO_GEOMETRY(2001, NULL, SDO_POINT_TYPE(5, 5, NULL), NULL, NULL),
    SDO_GEOMETRY(2003, NULL, NULL,
        SDO_ELEM_INFO_ARRAY(1, 1003, 1),
        SDO_ORDINATE_ARRAY(0, 0, 0, 10, 10, 10, 10, 0, 0, 0)
    )
) = 'TRUE';