-- Projekt 3. cast - SQL skript s nekolika dotazy SELECT
-- Course: Databazove systemy (IDS)
-- Institution: Brno University of Technology, Faculty of Information Technology
-- Authors: Filip Jerabek (xjerab24), Daniel Konecny (xkonec75)
-- Version: 3.1
-- Date: 22. 4. 2019

-----------------------------------------------------------
----------------------- DROP TABLES -----------------------
-----------------------------------------------------------

DROP TABLE uzivatel             CASCADE CONSTRAINTS;
DROP TABLE automobil            CASCADE CONSTRAINTS;
DROP TABLE jizda                CASCADE CONSTRAINTS;
DROP TABLE ucastni_se_jizdy     CASCADE CONSTRAINTS;
DROP TABLE hodnoceni            CASCADE CONSTRAINTS;
DROP TABLE vylet                CASCADE CONSTRAINTS;
DROP TABLE ucastni_se_vyletu    CASCADE CONSTRAINTS;
DROP TABLE clanek               CASCADE CONSTRAINTS;
DROP TABLE vlog                 CASCADE CONSTRAINTS;

-----------------------------------------------------------
---------------------- DROP SEQUENCE ----------------------
-----------------------------------------------------------

DROP SEQUENCE uzivatel_inc;

-----------------------------------------------------------
---------------------- CREATE TABLES ----------------------
-----------------------------------------------------------

CREATE TABLE uzivatel (
 -- id_uzivatel           NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  id_uzivatel           NUMBER(15)      PRIMARY KEY NOT NULL,   -- Pri pouziti triggeru na inkrementaci ID.
  jmeno                 VARCHAR2(100)   NOT NULL,
  datum_narozeni        DATE            NOT NULL,
  email                 VARCHAR2(100)   NOT NULL    CHECK(REGEXP_LIKE(email,'^[-0-9a-zA-Z.!#$%&*+/=?^_`{|}~]+@[-0-9a-zA-Z.]+$')),
  telefon               NUMBER(16)      NOT NULL,
  text_o_uzivateli      NCLOB,
  profilova_fotka       VARCHAR2(1000),
  oblibenost_hudby      NUMBER(1)                   CHECK(oblibenost_hudby > 0 AND oblibenost_hudby <= 5),
  komunikativnost       NUMBER(1)                   CHECK(komunikativnost > 0 AND komunikativnost <= 5),
  koureni               NUMBER(1)                   CHECK(koureni = 0 OR koureni = 1),
  zvirata               NUMBER(1)                   CHECK(zvirata = 0 OR zvirata = 1)
);

CREATE TABLE automobil (
  id_automobil          NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  vlastnik              NUMBER(15)      NOT NULL,
  jmeno                 VARCHAR2(100)   NOT NULL
);

CREATE TABLE jizda (
  id_jizda              NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  nabizejici            NUMBER(15)      NOT NULL,
  automobil             NUMBER(15)      NOT NULL,
  trasa                 VARCHAR2(1000)  NOT NULL,
  zajizdka              NUMBER          NOT NULL,
  cas_odjezdu           TIMESTAMP       NOT NULL,
  casova_flexibilita    NUMBER(4)       NOT NULL    CHECK(casova_flexibilita >= 0 AND casova_flexibilita < 1440),   -- v minutach (max 1 den)
  cena_za_km            NUMBER(9,3)     NOT NULL,
  zavazadla             VARCHAR2(1000)
);

CREATE TABLE ucastni_se_jizdy (
  cestujici             NUMBER(15)      NOT NULL,
  jizda                 NUMBER(15)      NOT NULL,
  misto_nastupu_s       NUMBER(11,8)    NOT NULL,   -- souradnice sirky
  misto_nastupu_d       NUMBER(11,8)    NOT NULL,   -- souradnice delky
  misto_vystupu_s       NUMBER(11,8)    NOT NULL,   -- souradnice sirky
  misto_vystupu_d       NUMBER(11,8)    NOT NULL    -- souradnice delky
);

CREATE TABLE hodnoceni (
  id_hodnoceni          NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  hodnotici             NUMBER(15)      NOT NULL,
  hodnoceny             NUMBER(15)      NOT NULL,
  hvezdicky             NUMBER(1)       NOT NULL    CHECK(hvezdicky > 0 AND hvezdicky <= 5),
  slovni_hodnoceni      VARCHAR2(1000),
  dochvilnost           NUMBER(1)                   CHECK(dochvilnost > 0 AND dochvilnost <= 5),
  pratelskost           NUMBER(1)                   CHECK(pratelskost > 0 AND pratelskost <= 5)
);

CREATE TABLE vylet (
  id_vylet              NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  nabizejici            NUMBER(15)      NOT NULL,
  harmonogram           VARCHAR2(1000),
  ubytovani             VARCHAR2(1000),
  naklady               VARCHAR2(1000),
  aktivity              VARCHAR2(1000),
  mista                 VARCHAR2(1000),
  narocnost             NUMBER(1)                   CHECK(narocnost > 0 AND narocnost <= 5),
  vybaveni              VARCHAR2(1000)
);

CREATE TABLE ucastni_se_vyletu (
  ucastnik              NUMBER(15)      NOT NULL,
  vylet                 NUMBER(15)      NOT NULL
);

CREATE TABLE clanek (
  id_clanek             NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  autor                 NUMBER(15)      NOT NULL,
  vylet                 NUMBER(15)      NOT NULL,
  opravneni             NUMBER(1)       NOT NULL    CHECK(opravneni = 0 OR opravneni = 1 OR opravneni = 2),
  text                  NCLOB           NOT NULL
);

CREATE TABLE vlog (
  id_vlog               NUMBER GENERATED ALWAYS AS IDENTITY(START with 1 INCREMENT by 1) PRIMARY KEY NOT NULL,
  autor                 NUMBER(15)      NOT NULL,
  vylet                 NUMBER(15)      NOT NULL,
  opravneni             NUMBER(1)       NOT NULL    CHECK(opravneni = 0 OR opravneni = 1 OR opravneni = 2), -- 0 (autor) / 1 (ucastnici vyletu) / 2 (vsichni)
  video                 VARCHAR2(1000)  NOT NULL,
  popisek               VARCHAR2(1000)
);

-----------------------------------------------------------
--------------------  FOREIGN KEYS ------------------------
-----------------------------------------------------------

ALTER TABLE automobil ADD (
  CONSTRAINT FK_vlastnik            FOREIGN KEY (vlastnik)      REFERENCES uzivatel
);

ALTER TABLE jizda ADD (
  CONSTRAINT FK_jizda_nabizejici    FOREIGN KEY (nabizejici)    REFERENCES uzivatel,
  CONSTRAINT FK_automobil           FOREIGN KEY (automobil)     REFERENCES automobil
);

ALTER TABLE ucastni_se_jizdy ADD (
  CONSTRAINT PK_ucastni_se_jizdy    PRIMARY KEY (cestujici, jizda)
);

ALTER TABLE hodnoceni ADD (
  CONSTRAINT FK_hodnotici           FOREIGN KEY (hodnotici)     REFERENCES uzivatel,
  CONSTRAINT FK_hodnoceny           FOREIGN KEY (hodnoceny)     REFERENCES uzivatel
);

ALTER TABLE vylet ADD (
  CONSTRAINT FK_vylet_nabizejici    FOREIGN KEY (nabizejici)    REFERENCES uzivatel
);

ALTER TABLE ucastni_se_vyletu ADD (
  CONSTRAINT PK_ucastni_se_vyletu   PRIMARY KEY (ucastnik, vylet)
);

ALTER TABLE clanek ADD (
  CONSTRAINT FK_clanek_autor        FOREIGN KEY (autor)         REFERENCES uzivatel,
  CONSTRAINT FK_clanek_vylet        FOREIGN KEY (vylet)         REFERENCES vylet
);

ALTER TABLE vlog ADD (
  CONSTRAINT FK_vlog_autor          FOREIGN KEY (autor)         REFERENCES uzivatel,
  CONSTRAINT FK_vlog_vylet          FOREIGN KEY (vylet)         REFERENCES vylet
);

-----------------------------------------------------------
------------------------- TRIGGERS ------------------------
-----------------------------------------------------------

CREATE SEQUENCE uzivatel_inc;
CREATE OR REPLACE TRIGGER uzivatel_insert BEFORE INSERT ON uzivatel FOR EACH ROW
BEGIN
  SELECT uzivatel_inc.nextval INTO :new.id_uzivatel FROM dual;
END;

CREATE OR REPLACE TRIGGER check_souradnice BEFORE INSERT ON ucastni_se_jizdy FOR EACH ROW
BEGIN
  IF :new.misto_nastupu_s < -90 OR :new.misto_nastupu_s > 90 THEN
    Raise_Application_Error(-20001, 'ERROR: Nespravny format zemepisne sirky mista nastupu!');
  END IF;
  IF :new.misto_nastupu_d < -180 OR :new.misto_nastupu_d > 180 THEN
    Raise_Application_Error(-20001, 'ERROR: Nespravny format zemepisne delky mista nastupu!');
  END IF;
  IF :new.misto_vystupu_s < -90 OR :new.misto_nastupu_s > 90 THEN
    Raise_Application_Error(-20001, 'ERROR: Nespravny format zemepisne sirky mista vystupu!');
  END IF;
  IF :new.misto_vystupu_d < -180 OR :new.misto_nastupu_s > 180 THEN
    Raise_Application_Error(-20001, 'ERROR: Nespravny format zemepisne delky mista vystupu!');
  END IF;
END;

-----------------------------------------------------------
--------------------- INSERT TEST DATA --------------------
-----------------------------------------------------------

-- UZIVATEL
INSERT INTO uzivatel (jmeno, datum_narozeni, email, telefon, text_o_uzivateli, profilova_fotka, oblibenost_hudby, komunikativnost, koureni, zvirata)
    VALUES ('Daniel Konecny', TO_DATE('01-09-1939', 'dd-mm-yyyy'), 'xkonec75@stud.fit.vutbr.cz', 420111222333, 'Ridim fakt dobre.', '/server/profilove_fotky/sdfhb93lkd.jpg', 5, 3, 0, 1);
INSERT INTO uzivatel (jmeno, datum_narozeni, email, telefon, text_o_uzivateli, profilova_fotka, oblibenost_hudby, komunikativnost, koureni, zvirata)
    VALUES ('Filip Jerabek', TO_DATE('02-09-1945', 'dd-mm-yyyy'), 'xjerab24@stud.fit.vutbr.cz', 420444555666, 'Ridim jako prase.', '/server/profilove_fotky/asdlfh876a.jpg', 4, 2, 1, 1);
INSERT INTO uzivatel (jmeno, datum_narozeni, email, telefon, text_o_uzivateli, profilova_fotka, oblibenost_hudby, komunikativnost, koureni, zvirata)
    VALUES ('Nejakej Slovak', TO_DATE('01-01-1993', 'dd-mm-yyyy'), 'xlogin00@stud.fit.vutbr.cz', 421897434987, 'Neumim ani slovo slovensky, takze...', '/server/profilove_fotky/asdklkh098.jpg', 1, 1, 0, 0);
INSERT INTO uzivatel (jmeno, datum_narozeni, email, telefon, text_o_uzivateli, profilova_fotka, oblibenost_hudby, komunikativnost, koureni, zvirata)
    VALUES ('Martin Kladnak', TO_DATE('01-03-2001', 'dd-mm-yyyy'), 'xkladn52@stud.fit.vutbr.cz', 421958745698, 'Mam rad hrusky.', '/server/profilove_fotky/fotecka001.jpg', 3, 3, 0, 0);

-- AUTOMOBIL
INSERT INTO automobil (jmeno, vlastnik)
    VALUES ('Ofce f cipu', 1);
INSERT INTO automobil (jmeno, vlastnik)
    VALUES ('Dodavka', 1);
INSERT INTO automobil (jmeno, vlastnik)
    VALUES ('Motorka', 2);
INSERT INTO automobil (jmeno, vlastnik)
    VALUES ('Ford', 4);
INSERT INTO automobil (jmeno, vlastnik)
    VALUES ('Dacia', 3);

-- JIZDA
INSERT INTO jizda (nabizejici, automobil, trasa, zajizdka, cas_odjezdu, casova_flexibilita, cena_za_km, zavazadla)
    VALUES (1, 1, '/server/trasy/00001.xml', 23, TO_DATE('27-03-19 20:18:07','DD-MM-YY HH24:MI:SS'), 15, 368, 1);
INSERT INTO jizda (nabizejici, automobil, trasa, zajizdka, cas_odjezdu, casova_flexibilita, cena_za_km, zavazadla)
    VALUES (2, 3, '/server/trasy/00002.xml', 5, TO_DATE('21-02-19 10:16:07','DD-MM-YY HH24:MI:SS'), 10, 130, 0);
INSERT INTO jizda (nabizejici, automobil, trasa, zajizdka, cas_odjezdu, casova_flexibilita, cena_za_km, zavazadla)
    VALUES (4, 4, '/server/trasy/00003.xml', 15, TO_DATE('6-02-19 9:16:07','DD-MM-YY HH24:MI:SS'), 20, 100, 1);
INSERT INTO jizda (nabizejici, automobil, trasa, zajizdka, cas_odjezdu, casova_flexibilita, cena_za_km, zavazadla)
    VALUES (3, 5, '/server/trasy/00004.xml', 25, TO_DATE('18-02-19 10:14:03','DD-MM-YY HH24:MI:SS'), 100, 60, 1);
INSERT INTO jizda (nabizejici, automobil, trasa, zajizdka, cas_odjezdu, casova_flexibilita, cena_za_km, zavazadla)
    VALUES (3, 5, '/server/trasy/00005.xml', 50, TO_DATE('18-04-19 10:14:03','DD-MM-YY HH24:MI:SS'), 0, 80, 0);

-- UCASTNI_SE_JIZDY
INSERT INTO ucastni_se_jizdy (cestujici, jizda, misto_nastupu_s, misto_nastupu_d, misto_vystupu_s, misto_vystupu_d)
    VALUES (2, 1, 37.248018, -115.812186, 43.645074, -115.993081);
INSERT INTO ucastni_se_jizdy (cestujici, jizda, misto_nastupu_s, misto_nastupu_d, misto_vystupu_s, misto_vystupu_d)
    VALUES (1, 2, 41.84201, -89.485937, 12.370367, 23.322272);
INSERT INTO ucastni_se_jizdy (cestujici, jizda, misto_nastupu_s, misto_nastupu_d, misto_vystupu_s, misto_vystupu_d)
    VALUES (4, 1, 21.85401, -75.789432, 22.874567, 14.341232);
INSERT INTO ucastni_se_jizdy (cestujici, jizda, misto_nastupu_s, misto_nastupu_d, misto_vystupu_s, misto_vystupu_d)
    VALUES (3, 1, 23.79541, -35.465787, 16.378517, 5.327896);

-- HODNOCENI
INSERT INTO hodnoceni (hodnotici, hodnoceny, hvezdicky, slovni_hodnoceni, dochvilnost, pratelskost)
    VALUES (2, 1, 2, 'Keca, neumi ridit. Radsi bych jel s zenskou. Aspon je ale hodnej.', 5, 5);
INSERT INTO hodnoceni (hodnotici, hodnoceny, hvezdicky, slovni_hodnoceni, dochvilnost, pratelskost)
    VALUES (1, 2, 5, 'To byla jizda', 3, 4);
INSERT INTO hodnoceni (hodnotici, hodnoceny, hvezdicky, slovni_hodnoceni, dochvilnost, pratelskost)
    VALUES (4, 1, 3, 'Uz nikdy nechci sednout do auta', 5, 4);
INSERT INTO hodnoceni (hodnotici, hodnoceny, hvezdicky, slovni_hodnoceni, dochvilnost, pratelskost)
    VALUES (3, 1, 2, 'Kdo tobe dal papiry..', 4, 4);

-- VYLET
INSERT INTO vylet (nabizejici, harmonogram, ubytovani, naklady, aktivity, mista, narocnost, vybaveni)
    VALUES (1,  'Cesta do centra pece o telo. Zajdeme si na matikuru, pedikuru, masaze. Bude to supr :*', 'Berem stany.', 'Klukum vse platim. A holky neberu.', 'Lazne.', 'Lazenske stredisko', '1', 'Zupanek a backurky.');
INSERT INTO vylet (nabizejici, harmonogram, ubytovani, naklady, aktivity, mista, narocnost, vybaveni)
    VALUES (2,  'Jizda po hospodach.', 'Spime v aute.', '1000-1500 kc.', 'Piti piva', 'Plzen, Policka, Cerna Hora.', '2', 'Statecnej zaludek.');
INSERT INTO vylet (nabizejici, harmonogram, ubytovani, naklady, aktivity, mista, narocnost, vybaveni)
    VALUES (3,  'Jedem domu na slovensko. PObudeme tam par dni a jedeme zpet.', 'Hotel.', 'S sebou penize na jidlo a piti. Hotel budeme platit predem', 'Piti borovicky.', 'Nitra', '2', 'Nic.');
INSERT INTO vylet (nabizejici, harmonogram, ubytovani, naklady, aktivity, mista, narocnost, vybaveni)
    VALUES (4,  'Vylet na Snezku a do Pece', 'Pod sirakem.', 'Jenom prispevek na benzin.', 'Chozeni po horach', 'Snezka, Pec pod..', '3', 'DObra obuv.');
INSERT INTO vylet (nabizejici, harmonogram, ubytovani, naklady, aktivity, mista, narocnost, vybaveni)
    VALUES (4,  'Vylet na motosalon', 'Jedeme ten den domu', 'Vstup je 250 + cesta', 'Koukani na motorky', 'Vystaviste v Brne', '1', 'Dobra nalada');

-- UCASTNI_SE_VYLETU
INSERT INTO ucastni_se_vyletu (ucastnik, vylet)
    VALUES (1, 1);
INSERT INTO ucastni_se_vyletu (ucastnik, vylet)
    VALUES (2, 2);
INSERT INTO ucastni_se_vyletu (ucastnik, vylet)
    VALUES (3, 5);
INSERT INTO ucastni_se_vyletu (ucastnik, vylet)
    VALUES (2, 5);
INSERT INTO ucastni_se_vyletu (ucastnik, vylet)
    VALUES (1, 5);

-- CLANEK
INSERT INTO clanek (autor, vylet, opravneni, text)
    VALUES (1, 1, 1, 'Vylet to byl paradni. A ted o nem budu psat nejakej clanek. Bla bla. :)');
INSERT INTO clanek (autor, vylet, opravneni, text)
    VALUES (2, 2, 1, 'Super, urcite pojedu priste zase. Videl jsem to a to...');
INSERT INTO clanek (autor, vylet, opravneni, text)
    VALUES (1, 5, 0, 'Takovy trochu chaoticky, ale libilo se mi to.');
INSERT INTO clanek (autor, vylet, opravneni, text)
    VALUES (1, 1, 1, 'Nejakej dlouhej text o vyletu.');

-- VLOG
INSERT INTO vlog (autor, vylet, opravneni, video, popisek)
    VALUES (2, 2, 1, '/server/video/0001.avi', 'Pivecko jako kren, bylo to naprosto dokonaly.');
INSERT INTO vlog (autor, vylet, opravneni, video, popisek)
    VALUES (2, 5, 1, '/server/video/0002.avi', 'Po ceste tam celkem komplikace...');
INSERT INTO vlog (autor, vylet, opravneni, video, popisek)
    VALUES (3, 5, 1, '/server/video/0002.avi', 'Moc doporucuji...');

-----------------------------------------------------------
----------------------- SELECT DATA -----------------------
-----------------------------------------------------------

-- -- Spojeni 2 tabulek - Zobrazi vsechny jizdy jednoho ridice.
-- SELECT jizda.*
-- FROM jizda
-- JOIN uzivatel ON jizda.nabizejici = uzivatel.id_uzivatel
-- WHERE uzivatel.id_uzivatel = '3';
--
-- -- Spojeni 2 tabulek - Zobrazi vsechna slovni hodnoceni udelena danemu ridici.
-- SELECT uzivatel.jmeno, hodnoceni.slovni_hodnoceni
-- FROM hodnoceni
-- JOIN uzivatel ON hodnoceni.hodnoceny = uzivatel.id_uzivatel
-- WHERE hodnoceni.hodnoceny = '1';
--
-- -- Spojeni 3 tabulek - Zobrazi jizdu, cestujiciho, misto odkud a kam jede a cas odjezdu.
-- SELECT jizda.id_jizda, uzivatel.jmeno AS cestujici, jizda.cas_odjezdu,
--     ucastni_se_jizdy.misto_nastupu_s, ucastni_se_jizdy.misto_nastupu_d,
--     ucastni_se_jizdy.misto_vystupu_s, ucastni_se_jizdy.misto_vystupu_d
-- FROM ucastni_se_jizdy
-- JOIN uzivatel ON ucastni_se_jizdy.cestujici = uzivatel.id_uzivatel
-- JOIN jizda ON ucastni_se_jizdy.jizda = jizda.id_jizda;
--
-- -- Klauzule GROUP BY a agregacni funkce - Zobrazi pocet ucastniku jednotlivych vyletu.
-- SELECT vylet.id_vylet, vylet.harmonogram, COUNT(vylet.id_vylet) AS pocet_ucastniku
-- FROM ucastni_se_vyletu
-- JOIN vylet ON ucastni_se_vyletu.vylet = vylet.id_vylet
-- JOIN uzivatel ON ucastni_se_vyletu.ucastnik = uzivatel.id_uzivatel
-- GROUP BY vylet.id_vylet, vylet.harmonogram;
--
-- -- Klauzule GROUP BY a agregacni funkce - Zobrazi prumerne hodnoceni kazdeho uzivatele a seradi od nejlepsiho.
-- SELECT uzivatel.id_uzivatel, uzivatel.jmeno, AVG(hodnoceni.hvezdicky) AS hodnoceni
-- FROM uzivatel
-- JOIN hodnoceni ON uzivatel.id_uzivatel = hodnoceni.hodnoceny
-- GROUP BY uzivatel.id_uzivatel, uzivatel.jmeno
-- ORDER BY hodnoceni DESC;
--
-- -- Predikat EXISTS - Zobrazi vsechny vylety, ktere maji clanek i vlog.
-- SELECT DISTINCT vylet.id_vylet, vylet.harmonogram
-- FROM vylet
-- JOIN vlog ON vylet.id_vylet = vlog.vylet
-- WHERE EXISTS (SELECT clanek.id_clanek FROM vylet JOIN clanek ON clanek.vylet = vylet.id_vylet);
--
-- -- Predikat IN s vnorenym SELECTem - Zobrazi jmena uzivatelu, kteri nabizi jizdy bez flexibility.
-- SELECT DISTINCT jmeno
-- FROM uzivatel
-- WHERE id_uzivatel IN (SELECT nabizejici FROM jizda WHERE casova_flexibilita = 0);

-----------------------------------------------------------
------------------------ PROCEDURES -----------------------
-----------------------------------------------------------

-- TODO - zjistit zkusenost ridice podle poctu nabizenych jizd a nejak vyjadrit na intervalu od 1 do 5
-- TODO - vypocet hodnoceni ridice pomoci hvezdicek (neco chytrejsiho nez prumer, viz. lamer)

-----------------------------------------------------------
-------------------------- OTHERS -------------------------
-----------------------------------------------------------

-- TODO - index
-- TODO - EXPLAIN PLAN
-- TODO - pristupova prava druhemu uzivateli
-- TODO - materializovany pohled
