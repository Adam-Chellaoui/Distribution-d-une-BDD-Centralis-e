CREATE DATABASE LINK linkToRyori
CONNECT TO achellaoui IDENTIFIED BY MDPORACLE USING 'DB11'; CREATE DATABASE LINK linkToEDN
CONNECT TO achellaoui IDENTIFIED BY MDPORACLE USING 'DB12'; CREATE DATABASE LINK linkToEDS
CONNECT TO achellaoui IDENTIFIED BY MDPORACLE USING 'DB13';



------------------------Création et peuplement de Clients_A------------------------------- CREATE TABLE Clients_A AS (
SELECT * FROM ryori.Clients@linkToRyori
WHERE Pays IN ('Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize', 'Bolivie',
'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica','Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 'Saint-Christophe-et- Nieves', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et- Tobago', 'Uruguay', 'Venezuela')
);
---------------------------Création et peuplement de Stock_A------------------------------- CREATE TABLE Stock_A AS (
SELECT * FROM ryori.Stock@linkToRyori
WHERE Pays IN ('Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize', 'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica','Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Pérou', 'Saint-Christophe-et- Nieves', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et- Tobago', 'Uruguay', 'Venezuela')
);
-------------------------Création et peuplement de commandes_A-------------------------- CREATE TABLE Commandes_A AS (
SELECT com.*
FROM ryori.Commandes@linkToRyori com, Clients_A cl
WHERE com.Code_Client = cl.Code_Client);
-----------------------Création et peuplement de details_Commandes_A------------------- CREATE TABLE Detail_Commandes_A AS (
SELECT dcom.*
FROM ryori.Details_Commandes@linkToRyori dcom, Commandes_A com
WHERE dcom.NO_COMMANDE = com.NO_COMMANDE);
---------------------------Création et peuplement de Employes------------------------------- -
CREATE TABLE Employes AS (
SELECT * FROM ryori.Employes@linkToRyori);


--------------------------------Création des Clés primaires------------------------------------ ALTER TABLE Clients_ES ADD CONSTRAINT PK_CLIENT_ES ALTER TABLE Clients_A ADD CONSTRAINT PK_Clients_A PRIMARY KEY (CODE_CLIENT);
ALTER TABLE Commandes_A ADD CONSTRAINT PK_Commandes_A PRIMARY KEY (NO_COMMANDE);
ALTER TABLE Detail_Commandes_A ADD CONSTRAINT PK_Detail_Commandes PRIMARY KEY (NO_COMMANDE,REF_PRODUIT);
ALTER TABLE Employes ADD CONSTRAINT PK_Employes PRIMARY KEY (NO_EMPLOYE); ALTER TABLE Stock_A ADD CONSTRAINT PK_Stock_A PRIMARY KEY (REF_PRODUIT, PAYS);

--------------------------------Création des Clés étrangères---------------------------------- ALTER TABLE Commandes_A ADD CONSTRAINT FK_Commandes_Clients
FOREIGN KEY (CODE_CLIENT) REFERENCES Clients_A (CODE_CLIENT);
ALTER TABLE Commandes_A ADD CONSTRAINT FK_Commande_Employes
FOREIGN KEY (NO_EMPLOYE) REFERENCES Employes (NO_EMPLOYE) ;
ALTER TABLE Details_Commandes_A ADD CONSTRAINT FK_Details_Commandes_Commandes
FOREIGN KEY (NO_COMMANDE) REFERENCES Commandes_A (REF_PRODUIT); ALTER TABLE Employes ADD CONSTRAINT FK_Employes_Employes
FOREIGN KEY (REND_COMPTE) REFERENCES Employes (REND_COMPTE);
-------CREATION DE TRIGGER POUR VERIFIER LA CONFORMITE DES DONNEES------ create or replace Trigger Delete_Employes_Commandes
before delete ON Employes
for each row
declare
nbKeys number; Begin
select count(*)
into nbKeys
from Commandes
where No_Employe = :NEW.No_Employe; If nbKeys > 0
then
RAISE_APPLICATION_ERROR(-20009, 'Cannot Delete tuple in this table'); END IF;
END;

-------CREATION DES CLES ETRANGERES SUR DES TABLES DISTANTES (Trigger)-------- -----Trigger remplaçant la clé étrangère de COMMANDES
CREATE or REPLACE Trigger FK_Details_Commandes_Produits
BEFORE INSERT or UPDATE ON Detail_Commandes_A
FOR EACH ROW DECLARE nbElements number; BEGIN
SELECT count(*)
INTO nbElements
FROM gdelambert.Produits@linkToEDS WHERE ref_produit = :NEW.ref_produit; if nbElements = 0
then
RAISE_APPLICATION_ERROR(-20009, 'Cannot Insert tuple in this table'); END if;
END;



-----Trigger remplaçant la clé étrangère de Stock_A CREATE or REPLACE Trigger FK_Stock_A_Produits BEFORE INSERT or UPDATE ON Stock_A
FOR EACH ROW
DECLARE nbElements number; BEGIN
SELECT count(*) INTO nbElements
FROM gdelambert.produits@linkToEDS
WHERE ref_produit = :NEW.ref_produit;
if nbElements = 0
then
RAISE_APPLICATION_ERROR(-20009, 'Cannot Insert tuple in this table');
END if; END;

------------------------Contraintes de type CHECK-------------------------------------------
ALTER TABLE Clients_A ADD CONSTRAINT soc_notnull CHECK (SOCIETE is not null); ALTER TABLE Clients_A ADD CONSTRAINT adr_notnull CHECK (ADRESSE is not null); ALTER TABLE Clients_A ADD CONSTRAINT vil_notnull CHECK (VILLE is not null);
ALTER TABLE Clients_A ADD CONSTRAINT cdpstl_notnull CHECK (CODE_POSTAL is not null);
ALTER TABLE Clients_A ADD CONSTRAINT pays_notnull CHECK (PAYS is not null); ALTER TABLE Clients_A ADD CONSTRAINT tel_notnull CHECK (TELEPHONE is not null);
ALTER TABLE Commandes_A ADD CONSTRAINT codcl_notnull CHECK (CODE_CLIENT is not null);
ALTER TABLE Commandes_A ADD CONSTRAINT noemp_notnull CHECK (NO_EMPLOYE is not null);
ALTER TABLE Commandes_A ADD CONSTRAINT datecom_notnull CHECK (DATE_COMMANDE is not null);
ALTER TABLE Detail_Commandes_A ADD CONSTRAINT nocom_notnull CHECK (NO_COMMANDE is not null);
ALTER TABLE Detail_Commandes_A ADD CONSTRAINT ref_notnull CHECK (REF_PRODUIT is not null);
ALTER TABLE Detail_Commandes_A ADD CONSTRAINT prix_notnull CHECK (PRIX_UNITAIRE is not null);
ALTER TABLE Detail_Commandes_A ADD CONSTRAINT qte_notnull CHECK (QUANTITE is not null);
ALTER TABLE Detail_Commandes_A ADD CONSTRAINT rem_notnull CHECK (REMISE is not null);
ALTER TABLE Employes ADD CONSTRAINT nomemp_notnull CHECK (NOM is not null); ALTER TABLE Employes ADD CONSTRAINT pren_notnull CHECK (PRENOM is not null);

GRANT SELECT ON Commandes_A TO sngov ,gdelambert; GRANT SELECT ON Detail_Commandes_A TO sngov ,gdelambert; GRANT SELECT ON Employes TO sngov ,gdelambert;
GRANT SELECT ON Stock_A TO sngov ,gdelambert;
GRANT SELECT ON Clients_A TO sngov ,gdelambert;


--------------------------------------- View clients ------------------------------------------- CREATE OR REPLACE VIEW Clients AS (
SELECT * FROM Clients_A
WHERE Pays IN ('Antigua-et-Barbuda','Argentine','Bahamas', 'Barbade', 'Belize',
'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'Republique dominicaine',
'Dominique', 'Equateur', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique', 'Mexique',
'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte-Lucie','Etats- Unis',
'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT * FROM sngov.Clients_EN@linkToEDN
WHERE Pays IN ('Allemagne', 'Irlande', 'Norvege', 'Suede', 'Danemark', 'Islande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Pologne', 'Finlande', 'Royaume-Uni')
UNION ALL
SELECT * FROM sngov.Clients_RM@linkToEDN
WHERE
Pays NOT IN ('Allemagne', 'Irlande','Norvege','Suede','Danemark','Islande','Belgique', 'Luxembourg', 'Pays-Bas','Pologne','Finlande','Royaume-Uni','Espagne', 'Portugal','Andorre','France','Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzegovine', 'Croatie', 'Grece', 'Macedoine', 'Montenegro','Serbie','Slovenie','Bulgarie', 'Antigua-et-Barbuda', 'Argentine', 'Bahamas','Barbade', 'Belize','Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica','Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana','Haiti', 'Honduras', 'Jamaique', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT * FROM gdelambert.Clients_ES@linkToEDS
WHERE pays IN ('Espagne', 'Portugal','Andorre','France','Gibraltar','Italie', 'Saint-Marin', 'Vatican','Malte','Albanie','Bosnie-Herzegovine','Croatie','Grece', 'Macedoine', 'Montenegro', 'Serbie', 'Slovenie', 'Bulgarie'));

---------------------------------------- View stock ------------------------------------------ CREATE OR REPLACE VIEW Stock AS (
SELECT * FROM stock_A
WHERE Pays IN ('Antigua-et-Barbuda','Argentine','Bahamas', 'Barbade', 'Belize','Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombi', 'Costa Rica', 'Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte- Lucie','Etats-Unis', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et- Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT * FROM sngov.stock_EN@linkToEDN
WHERE Pays IN ('Allemagne', 'Irlande','Norvege','Suede','Danemark','Islande','Belgique', 'Luxembourg','Pays-Bas','Pologne','Finlande','Royaume-Uni')
UNION ALL
SELECT * FROM sngov.stock_RM@linkToEDN
WHERE Pays NOT IN ('Allemagne', 'Irlande','Norvege','Suede','Danemark','Islande','Belgique', 'Luxembourg',
'Pays-Bas','Pologne','Finlande','Royaume-Uni','Espagne', 'Portugal','Andorre','France','Gibraltar',
'Italie','Saint-Marin', 'Vatican','Malte','Albanie','Bosnie-Herzegovine','Croatie','Grece', 'Macedoine','Montenegro','Serbie','Slovenie','Bulgarie', 'Antigua-et-Barbuda', 'Argentine','Bahamas',
'Barbade', 'Belize','Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica','Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana',
'Haiti', 'Honduras', 'Jamaique','Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT * FROM gdelambert.stock_ES@linkToEDS
WHERE Pays IN ('Espagne', 'Portugal', 'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican' ,'Malte' ,'Albanie', 'Bosnie-Herzegovine', 'Croatie', 'Grece', 'Macedoine', 'Montenegro', 'Serbie', 'Slovenie', 'Bulgarie'));

--------------------------------- View commandes -------------------------------------------- CREATE OR REPLACE VIEW Commandes AS (
SELECT ca.* FROM Commandes_A ca,Clients c
WHERE c.Code_Client=ca.Code_Client AND c.Pays IN ('Antigua-et-Barbuda', 'Argentine', 'Bahamas', 'Barbade', 'Belize','Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique', 'Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint- Christophe-et-Nieves', 'Sainte-Lucie','Etats-Unis', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT cen.* FROM sngov.Commandes_EN@linkToEDN cen,Clients c
WHERE c.Code_Client=cen.Code_Client AND c.Pays IN ('Allemagne', 'Irlande', 'Norvege', 'Suede', 'Danemark', 'Islande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Pologne', 'Finlande', 'Royaume-Uni')
UNION ALL
SELECT crm.* FROM sngov.Commandes_RM@linkToEDN crm,Clients c
WHERE c.Code_Client=crm.Code_Client AND
c.Pays NOT IN ('Allemagne', 'Irlande','Norvege','Suede','Danemark','Islande','Belgique', 'Luxembourg',
'Pays-Bas','Pologne','Finlande','Royaume-Uni','Espagne', 'Portugal','Andorre','France','Gibraltar',
'Italie','Saint-Marin', 'Vatican' ,'Malte', 'Albanie', 'Bosnie-Herzegovine', 'Croatie', 'Grece', 'Macedoine', 'Montenegro', 'Serbie', 'Slovenie', 'Bulgarie', 'Antigua-et-Barbuda', 'Argentine','Bahamas',
'Barbade', 'Belize','Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica','Cuba',
'Republique dominicaine', 'Dominique', 'Equateur', 'Etats-Unis', 'Grenade', 'Guatemala', 'Guyana',
'Haiti', 'Honduras', 'Jamaique','Mexique', 'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte-Lucie', 'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT ces.* FROM gdelambert.Commandes_ES@linkToEDS ces,Clients c
WHERE c.Code_Client=ces.Code_Client AND c.Pays IN ('Espagne', 'Portugal','Andorre','France','Gibraltar','Italie', 'Saint-Marin',
'Vatican' ,'Malte', 'Albanie', 'Bosnie-Herzegovine', 'Croatie', 'Grece', 'Macedoine', 'Montenegro',
'Serbie', 'Slovenie', 'Bulgarie'));

--------------------------------- View Détails_commande ------------------------------------- CREATE OR REPLACE VIEW Details_Commandes AS (
SELECT dca.* FROM detail_Commandes_A dca,Commandes co,Clients c
WHERE c.Code_Client=co.Code_Client AND co.no_Commande=dca.no_commande AND c.Pays IN ('Antigua-et-Barbuda','Argentine','Bahamas', 'Barbade', 'Belize',
'Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica', 'Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique', 'Mexique',
'Nicaragua', 'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte-Lucie','Etats- Unis',
'Saint-Vincent-et-les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT dcen.* FROM sngov.Detail_Commandes_EN@linkToEDN dcen,Clients c,Commandes co
WHERE c.Code_Client=co.Code_Client
AND co.no_commande = dcen.no_commande
AND c.Pays IN ('Allemagne', 'Irlande', 'Norvege', 'Suede', 'Danemark', 'Islande', 'Belgique', 'Luxembourg', 'Pays-Bas', 'Pologne', 'Finlande', 'Royaume-Uni')
UNION ALL
SELECT dcrm.* FROM sngov.Detail_Commandes_RM@linkToEDN dcrm,Clients c, Commandes co
WHERE c.Code_Client=co.Code_Client
AND co.no_commande = dcrm.no_commande
AND c.Pays NOT IN ('Allemagne', 'Irlande','Norvege','Suede','Danemark','Islande','Belgique', 'Luxembourg','Pays-Bas','Pologne','Finlande','Royaume-Uni','Espagne', 'Portugal', 'Andorre', 'France', 'Gibraltar', 'Italie', 'Saint-Marin', 'Vatican', 'Malte', 'Albanie', 'Bosnie-Herzegovine', 'Croatie', 'Grece', 'Macedoine', 'Montenegro', 'Serbie', 'Slovenie', 'Bulgarie', 'Antigua-et- Barbuda', 'Argentine','Bahamas','Barbade', 'Belize','Bolivie', 'Bresil', 'Canada', 'Chili', 'Colombie', 'Costa Rica','Cuba', 'Republique dominicaine', 'Dominique', 'Equateur', 'Etats- Unis', 'Grenade', 'Guatemala', 'Guyana', 'Haiti', 'Honduras', 'Jamaique','Mexique', 'Nicaragua',
'Panama', 'Paraguay', 'Perou', 'Saint-Christophe-et-Nieves', 'Sainte-Lucie', 'Saint-Vincent-et- les Grenadines', 'Salvador', 'Suriname', 'Trinite-et-Tobago', 'Uruguay', 'Venezuela')
UNION ALL
SELECT dces.* FROM gdelambert.details_Commandes_ES@linkToEDS dces,Clients c, Commandes co
WHERE c.Code_Client=co.Code_Client
AND co.no_commande = dces.no_commande
AND c.Pays IN ('Espagne', 'Portugal','Andorre','France','Gibraltar','Italie', 'Saint- Marin','Vatican', 'Malte','Albanie','Bosnie- Herzegovine','Croatie','Grece','Macedoine','Montenegro','Serbie', 'Slovenie', 'Bulgarie'));

---------------------------CREATION DES SYNONYMES-------------------------------------
CREATE OR REPLACE SYNONYM produits FOR gdelambert.produits@LinkToEDS; CREATE OR REPLACE SYNONYM categories FOR gdelambert.categories@LinkToEDS; CREATE OR REPLACE SYNONYM fournisseurs FOR sngov.fournisseurs@LinkToEDN;

DROP DATABASE LINK lienVersDB11 – Suppression du lien vers la base de données centralisée

-------------------------Réplicat de la table Categories--------------------------- CREATE MATERIALIZED VIEW DMV_Categories REFRESH COMPLETE
NEXT sysdate + (1)
AS
SELECT * FROM gdelambert.categories@LinkToEDS;
CREATE OR REPLACE EDITIONABLE SYNONYM "CATEGORIES" FOR DMV_Categories;
--------------------------- Réplicat de la table Fournisseurs--------------------
CREATE MATERIALIZED VIEW DMV_Fournisseurs REFRESH COMPLETE NEXT sysdate + (1)
AS
SELECT * FROM sngov.fournisseurs@LinkToEDN;
CREATE OR REPLACE EDITIONABLE SYNONYM "FOURNISSEURS" FOR DM_Fournisseurs;
--------------------------- Réplicat de la table Produits--------------------
CREATE MATERIALIZED VIEW MV_Produits REFRESH FAST NEXT sysdate + (0/1)
AS
SELECT * FROM gdelambert.produits@LinkToEDS;


