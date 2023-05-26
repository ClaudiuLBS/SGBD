--------------------- JUDETE ---------------------

INSERT INTO judet (id, denumire)
VALUES (1, 'GALATI');

INSERT INTO judet (id, denumire)
VALUES (2, 'BRAILA');

INSERT INTO judet (id, denumire)
VALUES (3, 'VASLUI');

INSERT INTO judet (id, denumire)
VALUES (4, 'BACAU');

INSERT INTO judet (id, denumire)
VALUES (5, 'VRANCEA');

INSERT INTO judet (id, denumire)
VALUES (6, 'IASI');

INSERT INTO judet (id, denumire)
VALUES (7, 'BOTOSANI');

INSERT INTO judet (id, denumire)
VALUES (8, 'SUCEAVA');

INSERT INTO judet (id, denumire)
VALUES (9, 'NEAMT');


--------------------- LOCALITATI ---------------------

-- LOCALITATEA GOHOR JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (1,
    num_list(27.39161962867713, 27.3977011786161, 27.41281369928096, 27.41881062811418, 27.41687172860411, 27.38768868566172, 27.38271472882957, 27.3859247954278, 27.39161962867713),
    num_list(46.03393372205996, 46.03327340459964, 46.03390946936025, 46.05685225501913, 46.07902668392548, 46.07759022911947, 46.06915891427744, 46.05405095434615, 46.03393372205996)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (1, 1, 1, 'GOHOR');

-- LOCALITATEA BRAHASESTI JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (2,
    num_list(27.39150981566837, 27.38632028310777, 27.35684697473988, 27.34011091314626, 27.35486483457116,27.39150981566837),
    num_list(46.03393695904147, 46.05240507171655, 46.06365802308543, 46.04412346015004, 46.02046400140826,46.03393695904147)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (2, 1, 2, 'BRAHASESTI');

-- LOCALITATEA PRIPONESTI JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (3,
    num_list(27.41921895511155, 27.45827412435824, 27.47551770786777, 27.43367699767672, 27.41688754795232, 27.41921895511155),
    num_list(46.05694929632945, 46.04764136124308, 46.07447363984426, 46.09529935684129, 46.07900764979539, 46.05694929632945)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (3, 1, 3, 'PRIPONESTI');

-- LOCALITATEA IREASCA JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (4,
    num_list(27.41325114131805, 27.44645755402078, 27.45811956574869, 27.41902903631780, 27.41325114131805),
    num_list(46.03369719650642, 46.02557399447304, 46.04747873821847, 46.05669478830567, 46.03369719650642)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (4, 1, 4, 'IREASCA');

-- LOCALITATEA NARTESTI JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (5,
    num_list(27.37813114389741, 27.386242696567, 27.42425485802519, 27.41752180950916, 27.41213609624842,27.39109844189572, 27.37813114389741),
    num_list(46.02827466190055, 45.99575378323244, 45.99864067681271, 46.03226579570294, 46.03351094716646,46.03318238568578, 46.02827466190055)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (5, 1, 5, 'NARTESTI');

-- LOCALITATEA COSITENI JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (6,
    num_list(27.34912762932924, 27.35719774714538, 27.38593148149474, 27.38230606242307, 27.39099056446655,27.34912762932924),
    num_list(46.07949063204272, 46.06378101287717, 46.05275157886128, 46.06880432585608, 46.0848629484237,46.07949063204272)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (6, 1, 6, 'COSITENI');

-- LOCALITATEA TOFLEA JUD GALATI
INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (7,
    num_list(27.33994255276722, 27.35662493723997, 27.34823986607441, 27.30197983249452, 27.33994255276722),
    num_list(46.04436514880626, 46.06366427799998, 46.07948826950219, 46.0766026858324, 46.04436514880626)
);
INSERT INTO localitate (id, id_judet, id_coordonate, denumire)
VALUES (7, 1, 7, 'TOFLEA');

--------------------- PERSOANE FIZICE ---------------------

INSERT INTO persoana_fizica (id, id_domiciliu, nume, prenume, gen, cnp)
VALUES (1, 1, 'LĂBUȘ', 'FLORIN', 'M', '5038493839384');

INSERT INTO persoana_fizica (id, id_domiciliu, nume, prenume, gen, cnp)
VALUES (2, 1, 'TITIRE', 'GHEORGHITA', 'M', '2947394755204');

INSERT INTO persoana_fizica (id, id_domiciliu, nume, prenume, gen, cnp)
VALUES (3, 5, 'PORUMB', 'EMANOIL', 'M', '8164028395215');

INSERT INTO persoana_fizica (id, id_domiciliu, nume, prenume, gen, cnp)
VALUES (4, 7, 'IEPURE', 'SPERANTIA', 'F', '1856302716492');

INSERT INTO persoana_fizica (id, id_domiciliu, nume, prenume, gen, cnp)
VALUES (5, 3, 'POPESCU', 'VASILE', 'M', '5943129092213');


--------------------- CODURI CAEN ---------------------

INSERT INTO caen (cod, activitate)
VALUES ('0111', 'Cultivarea cerealelor, plantelor leguminoase și a plantelor producătoare de semințe oleaginoase');

INSERT INTO caen (cod, activitate)
VALUES ('0112', 'Cultivarea orezului');

INSERT INTO caen (cod, activitate)
VALUES ('0113', 'Cultivarea legumelor și a pepenilor, a rădăcinoaselor și tuberculilor');

INSERT INTO caen (cod, activitate)
VALUES ('0114', 'Cultivarea trestiei de zahăr');

INSERT INTO caen (cod, activitate)
VALUES ('0115', 'Cultivarea tutunului');

INSERT INTO caen (cod, activitate)
VALUES ('0116', 'Cultivarea plantelor pentru fibre textile');

INSERT INTO caen (cod, activitate)
VALUES ('0119', 'Cultivarea altor plante din culturi nepermanente');


--------------------- FIRME ---------------------

INSERT INTO firma (id, id_administrator, id_sediu, denumire, cui)
VALUES (1, 1, 1, 'Lăbuș Florin I.I.', '481021');

INSERT INTO firma (id, id_administrator, id_sediu, denumire, cui)
VALUES (2, 3, 4, 'PNL FARM SRL', '138982');

INSERT INTO firma (id, id_administrator, id_sediu, denumire, cui)
VALUES (3, 5, 2, 'POPEPENI SRL', '640923');

INSERT INTO firma (id, id_administrator, id_sediu, denumire, cui)
VALUES (4, 4, 7, 'IEPURE SPERANTIA PFA', '430832');

INSERT INTO firma (id, id_administrator, id_sediu, denumire, cui)
VALUES (5, 2, 1, 'GHITZA SRL', '358230');


--------------------- CODURI CAEN - FIRME ---------------------

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (1, '0111');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (1, '0113');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (2, '0111');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (2, '0116');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (2, '0119');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (3, '0113');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (3, '0119');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (4, '0119');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (4, '0115');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (5, '0111');

INSERT INTO firma_caen (id_firma, cod_caen)
VALUES (5, '0113');


--------------------- CULTURI ---------------------

INSERT INTO cultura (id, denumire)
VALUES (101, 'GRAU');

INSERT INTO cultura (id, denumire)
VALUES (105, 'ORZ');

INSERT INTO cultura (id, denumire)
VALUES (108, 'PORUMB');

INSERT INTO cultura (id, denumire)
VALUES (201, 'FLOAREA SOARELUI');

INSERT INTO cultura (id, denumire)
VALUES (974, 'LUCERNA');

INSERT INTO cultura (id, denumire)
VALUES (639, 'PEPENI');

INSERT INTO cultura (id, denumire)
VALUES (298, 'TUTUN');

INSERT INTO cultura (id, denumire)
VALUES (1923, 'ROSII');

INSERT INTO cultura (id, denumire)
VALUES (1924, 'CASTRAVETI');


--------------------- UTILIZATORI ---------------------

INSERT INTO utilizator (id, id_firma, nume_utilizator, parola)
VALUES (1, 3, 'RO28491848', 'oa9oIR4r');

INSERT INTO utilizator (id, id_firma, nume_utilizator, parola)
VALUES (2, 1, 'RO59103943', 'ORoe11mC');

INSERT INTO utilizator (id, id_firma, nume_utilizator, parola)
VALUES (3, 5, 'RO10382048', 'AOWu42ef');

INSERT INTO utilizator (id, id_firma, nume_utilizator, parola)
VALUES (4, 2, 'RO82359740', '69Aok24h');

INSERT INTO utilizator (id, id_firma, nume_utilizator, parola)
VALUES (5, 4, 'RO01582956', 'F8i320J8');


--------------------- PARCELE ---------------------

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (8,
    num_list(27.38398646394512, 27.39258889279089, 27.39245499456955, 27.38437029168849, 27.38398646394512),
    num_list(46.06741616081491, 46.06818620108033, 46.06941815343022, 46.06861137285969, 46.06741616081491)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (9,
    num_list(27.38706186121867, 27.38372092263574, 27.38257023972949, 27.38494319475576, 27.38706186121867),
    num_list(46.07794878154138, 46.078682380151, 46.07452221760423, 46.07378407098127, 46.07794878154138)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (10,
    num_list(27.39020485220995, 27.38992583160482, 27.38402103254766, 27.38302410294547, 27.39020485220995),
    num_list(46.06941826247543, 46.07123592490891, 46.07120713946931, 46.06888883563936, 46.06941826247543)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (11,
    num_list(27.38381329136287, 27.38305109443528, 27.38694970290969, 27.38897010176537, 27.38381329136287),
    num_list(46.08172547415104, 46.07826979637072, 46.07770254098575, 46.08167806851747, 46.08172547415104)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (12,
    num_list(27.3877039084936, 27.38734406231644, 27.39434708018972, 27.39428283510824, 27.3877039084936),
    num_list(46.04689528702177, 46.04529406337719, 46.04576529734717, 46.0475549000348, 46.04689528702177)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (13,
    num_list(27.34976788295621, 27.35760088880378, 27.35549211887732, 27.34782317441497, 27.34976788295621),
    num_list(46.03161781706404, 46.03266533874119, 46.0379431707833, 46.03708937397057, 46.03161781706404)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (14,
    num_list(27.32094455343529, 27.32412707884729, 27.31962759484149, 27.31555148555098, 27.32094455343529),
    num_list(46.06130511601396, 46.06097914708342, 46.07008455794255, 46.0702208427719, 46.06130511601396)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (15,
    num_list(27.4029522540963, 27.41252539591962, 27.41222563002147, 27.40348523397968, 27.4029522540963),
    num_list(46.02259312073821, 46.02257575726103, 46.02598158270811, 46.02617210608462, 46.02259312073821)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (16,
    num_list(27.44759584443307, 27.44414598390576, 27.45448635311674, 27.45750358170248, 27.44759584443307),
    num_list(46.04974476611227, 46.04439789253986, 46.04187410899225, 46.047362693952, 46.04974476611227)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (17,
    num_list(27.43099358001283, 27.43515795750641, 27.43439728584931, 27.43126365984379, 27.43099358001283),
    num_list(46.05473304412737, 46.05417165707246, 46.05991094145585, 46.06003862017076, 46.05473304412737)
);

INSERT INTO coordonate (id, longitudine, latitudine)
VALUES (18,
    num_list(27.41183783341678, 27.41008127935638, 27.40576076554959, 27.40527322941899, 27.41183783341678),
    num_list(46.04370044785122, 46.04554068857237, 46.04553020242665, 46.04347293790054, 46.04370044785122)
);

-- aici am folosit o functie de inserare care calculeaza automat suprafata parcelelor
BEGIN
    apia_pkg.creare_parcela(2, 8, 201, 1);
    apia_pkg.creare_parcela(2, 11, 108, 2);
    apia_pkg.creare_parcela(2, 18, 101, 3);
    apia_pkg.creare_parcela(1, 9, 639, 1);
    apia_pkg.creare_parcela(1, 10, 639, 2);
    apia_pkg.creare_parcela(3, 12, 974, 1);
    apia_pkg.creare_parcela(3, 13, 1924, 2);
    apia_pkg.creare_parcela(4, 15, 108, 1);
    apia_pkg.creare_parcela(4, 16, 105, 2);
    apia_pkg.creare_parcela(4, 17, 1924, 3);
    apia_pkg.creare_parcela(5, 14, 298, 1);
END;