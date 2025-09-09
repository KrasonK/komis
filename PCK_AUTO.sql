/* 
Autor: Karolina Krason

Data utworzenia: 14/06/2020

Opis: przykladowy pakiet zawierajacy min. funkcje i procedury sluzace do obslugi komisu samochodowego.
*/
CREATE OR REPLACE PACKAGE PCK_AUTO AS
n_ile NUMBER;
PROCEDURE PRZEN_AUTO(pVIN VARCHAR2, pOSOBAID NUMBER);
PROCEDURE DODAJ_KLIENTA(pImie VARCHAR2,pNazwisko VARCHAR2,pData DATE,pPesel NUMBER,pMiejsc VARCHAR2,pUlica VARCHAR2,pNrDmu NUMBER,
    pNrMieszk NUMBER,pNrTel VARCHAR2,pKodPocz VARCHAR2,pIdentyfikacja NUMBER);
PROCEDURE DODAJ_OFERTE (pVIN VARCHAR2, pOSOBAID NUMBER);
FUNCTION KLIENCI_MIEJSCOWOSC (MIEJSCOWOSC VARCHAR2)
    RETURN NUMBER;
FUNCTION KLIENCI_FUNKCJA (fFUNKCJA VARCHAR2)
    RETURN NUMBER; 
PROCEDURE DostepneOferty(pvin VARCHAR2, posobaid NUMBER);

END PCK_AUTO;

----------------------------------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY PCK_AUTO AS

pVIN VARCHAR2 (15);
pOSOBAID NUMBER (10);


PROCEDURE PRZEN_AUTO (pVIN VARCHAR2, pOSOBAID NUMBER) IS

vMarka VARCHAR2(15);
vModel VARCHAR2(10);

BEGIN 
    SELECT 
        t.MARKA, t.MODEL
    INTO 
        vMarka, vModel
    FROM 
        "TSAMOCHOD" t
    WHERE 
        t.VIN = pVIN;

    INSERT INTO SPRZEDANE s ( s.VIN, s.OSOBA_ID, s.DATA_SPRZEDAZY)
    VALUES (pVIN,pOSOBAID,sysdate);
         dbms_output.put_line('AUTO O NUMERZE VIN  ' || pVIN || ' PRZENIESIONO');

    DELETE FROM OFERTYSPRZEDAZ WHERE VIN = pVIN;

    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN dbms_output.put_line('AUTO O NUMERZE VIN  ' || pVIN || ' NIE ISTNIEJE');
        WHEN VALUE_ERROR
        THEN dbms_output.put_line('NIEPOPRAWNIE WPROWADZONE DANE');
        WHEN OTHERS 
        THEN dbms_output.put_line('COS POSZO NIE TAK :( ');
    COMMIT;   

END PRZEN_AUTO;

--- end-------------------------------------------------

PROCEDURE dodaj_klienta
    (pImie VARCHAR2,pNazwisko VARCHAR2,pData DATE,pPesel NUMBER,pMiejsc VARCHAR2,pUlica VARCHAR2,pNrDmu NUMBER,
    pNrMieszk NUMBER,pNrTel VARCHAR2,pKodPocz VARCHAR2,pIdentyfikacja NUMBER) 
IS 
BEGIN
    INSERT INTO "TKLIENCI"(IMIE, NAZWISKO, DATAURODZENIA, PESEL, MIEJSCOWOSC, ULICA, NUMERDOMU, NUMERMIESZKANIA, NUMERTELEFONU, 
        KODPOCZTOWY, IDENTYFIKACJA)
    VALUES  (pImie, pNazwisko, pData,pPesel, pMiejsc, pUlica, pNrDmu, pNrMieszk, pNrTel, pKodPocz, pIdentyfikacja);

        COMMIT;
        dbms_output.put_line('KLIENTA  ' || pImie ||' '||pNazwisko|| ' DODANO');
END dodaj_klienta; 

-- koniec   -------------------------------------------------


PROCEDURE DODAJ_OFERTE(pVIN VARCHAR2, pOSOBAID NUMBER)IS 

   vVIN TSAMOCHOD.VIN%TYPE :=pVIN;
   vOSOBAID TKLIENCI.IDOSOBA%TYPE := pOSOBAID;
  BEGIN 
  
    INSERT INTO "OFERTYSPRZEDAZ" (VIN,OSOBAID)
    VALUES (vVIN, vOSOBAID);
      COMMIT;
dbms_output.put_line
('OFERTA  ' || vVIN ||' '||vOSOBAID|| ' DODANA');
END DODAJ_OFERTE;  

-- koniec -----------------------------------------------


FUNCTION KLIENCI_MIEJSCOWOSC (MIEJSCOWOSC VARCHAR2)
         RETURN NUMBER
          IS n_ile NUMBER;
    BEGIN 
        SELECT COUNT (*) INTO n_ile
        FROM TKLIENCI 
        WHERE TKLIENCI.MIEJSCOWOSC = MIEJSCOWOSC;
            RETURN n_ile;
               dbms_output.put_line ('KLIENTÓW Z  MIEJSCOWOŚCI' || MIEJSCOWOSC|| ' JEST '||n_ile||'TYLU');
END KLIENCI_MIEJSCOWOSC; 

-- koniec   -------------------------------------------------

FUNCTION KLIENCI_FUNKCJA (fFUNKCJA VARCHAR2)
  RETURN NUMBER
    IS n_ile NUMBER;
BEGIN 
    SELECT COUNT (*) INTO n_ile
     FROM TKLIENCI 
     WHERE TKLIENCI.IDENTYFIKACJA = fFUNKCJA;
         RETURN n_ile;
           dbms_output.put_line ('OSOB' || fFUNKCJA|| ' JEST '||n_ile||'TYLU');
END KLIENCI_FUNKCJA; 

-- koniec   -------------------------------------------------

PROCEDURE DostepneOferty (pVIN VARCHAR2, pOSOBAID NUMBER)IS
  VinId VARCHAR2 (15);
  NrOsoba NUMBER (10);
CURSOR dostepne_cur IS
    SELECT o.VIN, o.OSOBAID  
    FROM "OFERTYSPRZEDAZ" o 
    INNER JOIN "TSAMOCHOD" t ON o.vin=t.vin 
    ORDER BY o.osobaid;

BEGIN OPEN dostepne_cur;
LOOP
FETCH dostepne_cur INTO VinId, NrOsoba; 
dbms_output.put_line('dostepne oferty  ' || pVIN ||' '||pOSOBAID|| '  ');
 
        EXIT WHEN dostepne_cur%notfound;

        END LOOP;
         EXCEPTION
            WHEN too_many_rows THEN
            dbms_output.put_line('blad  ');
        CLOSE dostepne_cur;
    END DostepneOferty;

END PCK_AUTO;
