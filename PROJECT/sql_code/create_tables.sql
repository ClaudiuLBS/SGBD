

CREATE OR REPLACE TYPE NUM_LIST IS TABLE OF NUMBER;

CREATE TABLE coordonate
(
    id          NUMBER PRIMARY KEY,
    latitudine  NUM_LIST,
    longitudine NUM_LIST
)
    NESTED TABLE latitudine STORE AS lat_coords
    NESTED TABLE longitudine STORE AS long_coords;


CREATE TABLE judet
(
    id       INT PRIMARY KEY,
    denumire VARCHAR2(100)
);


CREATE TABLE localitate
(
    id            INT PRIMARY KEY,
    id_judet      INT,
    id_coordonate INT,
    denumire      VARCHAR2(100),
----------------------------------
    CONSTRAINT fk_judet
        FOREIGN KEY (id_judet)
            REFERENCES judet (id),
----------------------------------
    CONSTRAINT fk_coords
        FOREIGN KEY (id_coordonate)
            REFERENCES coordonate (id)
);


CREATE TABLE persoana_fizica
(
    id           INT PRIMARY KEY,
    id_domiciliu INT,
    nume         VARCHAR2(100),
    prenume      VARCHAR2(100),
    gen          CHAR,
    cnp          VARCHAR2(13),
----------------------------------
    CONSTRAINT fk_domiciliu
        FOREIGN KEY (id_domiciliu)
            REFERENCES localitate (id),
----------------------------------
    CONSTRAINT gen_char
        CHECK ( gen IN ('M', 'F')),
----------------------------------
    CONSTRAINT unique_cnp UNIQUE (cnp)
);

CREATE TABLE caen
(
    cod        VARCHAR2(10) PRIMARY KEY,
    activitate VARCHAR2(100)
);


CREATE TABLE firma
(
    id               INT PRIMARY KEY,
    id_administrator INT,
    id_sediu         INT,
    denumire         VARCHAR2(100),
    cui              VARCHAR2(20),
----------------------------------
    CONSTRAINT fk_administrator
        FOREIGN KEY (id_administrator)
            REFERENCES persoana_fizica (id),
----------------------------------
    CONSTRAINT fk_sediu
        FOREIGN KEY (id_sediu)
            REFERENCES localitate (id),
----------------------------------
    CONSTRAINT unique_cui UNIQUE (cui)
);


CREATE TABLE firma_caen
(
    id_firma INT,
    cod_caen VARCHAR2(10),
----------------------------------
    CONSTRAINT fk_firma
        FOREIGN KEY (id_firma)
            REFERENCES firma (id),
----------------------------------
    CONSTRAINT fk_caen
        FOREIGN KEY (cod_caen)
            REFERENCES caen (cod),
----------------------------------
    CONSTRAINT pk_firma_caen PRIMARY KEY (id_firma, cod_caen)
);


CREATE TABLE cultura
(
    id       INT PRIMARY KEY,
    denumire VARCHAR2(100)
);


CREATE TABLE utilizator
(
    id              INT PRIMARY KEY,
    id_firma        INT,
    nume_utilizator VARCHAR2(100),
    parola          VARCHAR2(100),
    data_inscriere DATE DEFAULT sysdate,
----------------------------------
    CONSTRAINT fk_firma_1
        FOREIGN KEY (id_firma)
            REFERENCES firma (id),
----------------------------------
    CONSTRAINT unique_username UNIQUE (nume_utilizator)
);

CREATE SEQUENCE seq_parcela
    START WITH 1
    INCREMENT BY 1
    NOCACHE;

CREATE TABLE parcela
(
    id                 INT DEFAULT seq_parcela.nextval PRIMARY KEY,
    id_proprietar      INT,
    id_coordonate      INT,
    id_cultura         INT,
    nr_parcela         INT,
    suprafata          NUMBER,
    ultima_actualizare DATE,
----------------------------------
    CONSTRAINT fk_proprietar
        FOREIGN KEY (id_proprietar)
            REFERENCES utilizator (id),
----------------------------------
    CONSTRAINT fk_coords_1
        FOREIGN KEY (id_coordonate)
            REFERENCES coordonate (id),
----------------------------------
    CONSTRAINT fk_cultura
        FOREIGN KEY (id_cultura)
            REFERENCES cultura (id),
----------------------------------
    CONSTRAINT unique_nr_parcela UNIQUE (id, nr_parcela)
);