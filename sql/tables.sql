-------------------------------------------------------
/* IBDR 2013 – Groupe SAR                            */ 
/* Création de la base de données IBDR_SAR           */ 
/* Date de la version 20/02/2013                     */
-------------------------------------------------------

USE [master] 
IF  EXISTS  
(SELECT name FROM sys.databases WHERE name = N'IBDR_SAR') 
BEGIN 
  EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'IBDR_SAR' 
  DROP DATABASE IBDR_SAR 
END 
GO 
CREATE DATABASE IBDR_SAR 
GO  
USE IBDR_SAR 
GO

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Personne   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
/*           MUNOZ Yupanqui - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Personne' AND xtype = 'U')  
DROP TABLE Personne ;
CREATE TABLE Personne (
    Nom             NVARCHAR(64) NOT NULL,
    Prenom          NVARCHAR(64) NOT NULL,
    Alias           NVARCHAR(64) NOT NULL,
    DateNaissance   DATE NOT NULL,
    DateDeces       DATE,
    Biographie      NTEXT,

    CONSTRAINT PK_PERSONNE PRIMARY KEY (
		Nom, Prenom, Alias
    )

)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Langue   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Langue' AND xtype = 'U')  
DROP TABLE Langue ;
CREATE TABLE Langue (
	Nom NVARCHAR(64) NOT NULL,

	CONSTRAINT PK_LANGUE PRIMARY KEY ( Nom )
)

-------------------------------------
/* IBDR 2013 - Groupe SAR          */
/* Création de la table Pays       */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'Pays' AND xtype = 'U') DROP TABLE Pays ;
CREATE TABLE Pays (
	Nom NVARCHAR(64) NOT NULL,

	CONSTRAINT PK_PAYS PRIMARY KEY ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Film   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Film' AND xtype = 'U')  
DROP TABLE Film ;
CREATE TABLE Film (
	TitreVF NVARCHAR(128) NOT NULL,
	ComplementTitre NVARCHAR(256),
	TitreVO NVARCHAR(128) NOT NULL,
	AnneeSortie SMALLINT NOT NULL,	
	Synopsis NTEXT NOT NULL,
	Langue NVARCHAR(64) NOT NULL,
	SiteWeb NVARCHAR(512),	
	

	CONSTRAINT PK_FILM PRIMARY KEY ( TitreVF, AnneeSortie ),
	CONSTRAINT FK_FILM_LANGUE FOREIGN KEY ( Langue ) REFERENCES Langue ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Edition   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
/*           MUNOZ Yupanqui - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Edition' AND xtype = 'U')  
DROP TABLE Edition ;
CREATE TABLE Edition (
	Id INT NOT NULL IDENTITY(0,1),
	FilmTitreVF NVARCHAR(128) NOT NULL,
	FilmAnneeSortie SMALLINT NOT NULL,
	Duree TIME NOT NULL,
	DateSortie DATE NOT NULL,
	Support NVARCHAR(32) NOT NULL,
	Couleur BIT NOT NULL,
	Pays NVARCHAR(64) NOT NULL,
	NomEdition NVARCHAR(256) NOT NULL UNIQUE,
	AgeInterdiction INT NOT NULL,
	Supprimer BIT NOT NULL,

	CONSTRAINT PK_EDITION PRIMARY KEY ( Id ),
	CONSTRAINT FK_EDITION_FILM
		FOREIGN KEY ( FilmTitreVF, FilmAnneeSortie )
		REFERENCES Film (TitreVF, AnneeSortie ),
	CONSTRAINT FK_EDITION_PAYS 
		FOREIGN KEY ( Pays ) REFERENCES Pays ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmStock   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
/*           MUNOZ Yupanqui - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'FilmStock' AND xtype = 'U')  
DROP TABLE FilmStock ;
CREATE TABLE FilmStock (
	Id INT NOT NULL IDENTITY(0,1),
	DateArrivee DATETIME NOT NULL,
	Usure INT,
	IdEdition INT NOT NULL,

	CONSTRAINT PK_FILMSTOCK PRIMARY KEY ( Id ),
	CONSTRAINT FK_FILMSTOCK_EDITION
		FOREIGN KEY ( IdEdition ) REFERENCES Edition ( Id ) ON DELETE CASCADE
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Editeur   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Editeur' AND xtype = 'U')  
DROP TABLE Editeur ;
CREATE TABLE Editeur (
	Nom NVARCHAR(64) NOT NULL,

	CONSTRAINT PK_EDITEUR PRIMARY KEY ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Genre   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Genre' AND xtype = 'U')  
DROP TABLE Genre ;
CREATE TABLE Genre (
	Nom NVARCHAR(64) NOT NULL,

	CONSTRAINT PK_GENRE PRIMARY KEY ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Client   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Client' AND xtype = 'U')  
DROP TABLE Client ;
CREATE TABLE Client (
    Civilite          NVARCHAR(24) NOT NULL,
	Nom               NVARCHAR(64) NOT NULL,
	Prenom            NVARCHAR(64) NOT NULL,
	DateNaissance     DATE NOT NULL,
	Mail              NVARCHAR(128) NOT NULL,
	Telephone1        NVARCHAR(20) NOT NULL,
	Telephone2        NVARCHAR(20),	
	NumRue			  INT NOT NULL,
	TypeRue			  NVARCHAR(64) NOT NULL,
	NomRue            NVARCHAR(128) NOT NULL,
	ComplementAdresse NVARCHAR(256),
	CodePostal        NVARCHAR(10) NOT NULL,
	Ville             NVARCHAR(64) NOT NULL,
	BlackListe        BIT NOT NULL,

	CONSTRAINT PK_CLIENT PRIMARY KEY ( Nom, Prenom, Mail )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table TypeAbonnement   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'TypeAbonnement' AND xtype = 'U')  
DROP TABLE TypeAbonnement ;
CREATE TABLE TypeAbonnement (
	Nom NVARCHAR(32) NOT NULL,
	PrixMensuel SMALLMONEY NOT NULL,
	PrixLocation SMALLMONEY NOT NULL,
	MaxJoursLocation INT NOT NULL,
	NbMaxLocations INT NOT NULL,
	PrixRetard SMALLMONEY NOT NULL,
	DureeEngagement INT NOT NULL,

	CONSTRAINT PK_TYPEABONNEMENT PRIMARY KEY ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Abonnement   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Abonnement' AND xtype = 'U')  
DROP TABLE Abonnement ;
CREATE TABLE Abonnement (
	Id INT NOT NULL IDENTITY(0,1),
    Solde SMALLMONEY NOT NULL,
	DateDebut DATETIME NOT NULL,
	DateFin DATETIME NOT NULL,
	NomClient NVARCHAR(64) NOT NULL,
	PrenomClient NVARCHAR(64) NOT NULL,
	MailClient NVARCHAR(128) NOT NULL,
	TypeAbonnement NVARCHAR(32) NOT NULL,

	CONSTRAINT PK_ABONNEMENT 
		PRIMARY KEY ( Id ),
	CONSTRAINT FK_ABONNEMENT_TYPEABONNEMENT
		FOREIGN KEY ( TypeAbonnement ) REFERENCES TypeAbonnement ( Nom ),
	CONSTRAINT FK_ABONNEMENT_CLIENT
		FOREIGN KEY ( NomClient, PrenomClient, MailClient )
		REFERENCES Client ( Nom, Prenom, Mail )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Location   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
/*           MUNOZ Yupanqui - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'Location' AND xtype = 'U')  
DROP TABLE Location ;
CREATE TABLE Location (
	Id                INT NOT NULL IDENTITY(0,1),
	AbonnementId      INT NOT NULL,
	DateLocation      DATETIME NOT NULL,
	DateRetourPrev    DATETIME NOT NULL,
	DateRetourEff     DATETIME,
	FilmStockId       INT NOT NULL,
    Confirmee         BIT NOT NULL,

	CONSTRAINT PK_LOCATION PRIMARY KEY ( Id ),
	CONSTRAINT FK_LOCATION_FILMSTOCK
		FOREIGN KEY ( FilmStockId ) REFERENCES FilmStock ( Id ) ON DELETE CASCADE,
	CONSTRAINT FK_LOCATION_ABONNEMENT
		FOREIGN KEY ( AbonnementId ) 
		REFERENCES Abonnement ( Id )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table RelanceDecouvert   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'RelanceDecouvert' AND xtype = 'U')  
DROP TABLE RelanceDecouvert ;
CREATE TABLE RelanceDecouvert (
	AbonnementId   INT NOT NULL,
	Date           DATETIME NOT NULL,
	Niveau         SMALLINT NOT NULL,

	CONSTRAINT PK_RELANCEDECOUVERT PRIMARY KEY ( AbonnementId ),
	CONSTRAINT FK_RELANCEDECOUVERT 
		FOREIGN KEY ( AbonnementId )
		REFERENCES Abonnement ( Id )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table RelanceRetard   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'RelanceRetard' AND xtype = 'U')  
DROP TABLE RelanceRetard ;
CREATE TABLE RelanceRetard (
	Date DATETIME NOT NULL,
	LocationId INT NOT NULL,
	Niveau         SMALLINT NOT NULL,

	CONSTRAINT PK_RELANCERETARD PRIMARY KEY ( LocationId ),
	CONSTRAINT FK_RELANCERETARD_LOCATION
		FOREIGN KEY ( LocationId )
		REFERENCES Location ( Id ) ON DELETE CASCADE
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table TypeDistinction   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'TypeDistinction' AND xtype = 'U')  
DROP TABLE TypeDistinction ;
CREATE TABLE TypeDistinction (
	Nom NVARCHAR(128) NOT NULL,
	CONSTRAINT PK_TYPEDISTINCTION PRIMARY KEY ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmDistinction   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'FilmDistinction' AND xtype = 'U')  
DROP TABLE FilmDistinction ;
CREATE TABLE FilmDistinction (
	Annee SMALLINT NOT NULL,
	TitreVF NVARCHAR(128) NOT NULL,
	AnneeSortie SMALLINT NOT NULL,
	NomDistinction NVARCHAR(128) NOT NULL,

	CONSTRAINT PK_FILMDISTINCTION 
		PRIMARY KEY ( Annee, TitreVF, AnneeSortie, NomDistinction ),
	CONSTRAINT FK_FILMDISTINCTION_FILM
		FOREIGN KEY ( TitreVF, AnneeSortie )
		REFERENCES Film ( TitreVF, AnneeSortie ),
	CONSTRAINT FK_FILMDISTINCTION_TYPEDISTFILM
		FOREIGN KEY ( NomDistinction )
		REFERENCES TypeDistinction ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table PersonneDistinction   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'PersonneDistinction' AND xtype = 'U')  
DROP TABLE PersonneDistinction ;
CREATE TABLE PersonneDistinction (
	Annee           SMALLINT NOT NULL,
	TitreVF         NVARCHAR(128) NOT NULL,
	AnneeSortie     SMALLINT NOT NULL,
    Nom             NVARCHAR(64) NOT NULL,
    Prenom          NVARCHAR(64) NOT NULL,
    Alias           NVARCHAR(64),
	NomDistinction  NVARCHAR(128) NOT NULL,

	CONSTRAINT FK_ACTEURDISTINCTION_FILM
		FOREIGN KEY ( TitreVF, AnneeSortie )
		REFERENCES Film ( TitreVF, AnneeSortie ),
	CONSTRAINT FK_ACTEURDISTINCTION_PERSONNE
		FOREIGN KEY ( Nom, Prenom, Alias )
		REFERENCES Personne ( Nom, Prenom, Alias ),
	CONSTRAINT FK_ACTEURDISTINCTION_TYPEDISTINCTION
		FOREIGN KEY ( NomDistinction )
		REFERENCES TypeDistinction ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmActeur   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'FilmActeur' AND xtype = 'U')  
DROP TABLE FilmActeur ;
CREATE TABLE FilmActeur (
	TitreVF         NVARCHAR(128) NOT NULL,
	AnneeSortie      SMALLINT NOT NULL,
    Nom             NVARCHAR(64) NOT NULL,
    Prenom          NVARCHAR(64) NOT NULL,
    Alias           NVARCHAR(64),

	CONSTRAINT FK_FILMACTEUR_FILM
		FOREIGN KEY ( TitreVF, AnneeSortie )
        REFERENCES Film ( TitreVF, AnneeSortie ),
	CONSTRAINT FK_FILMACTEUR_ACTEUR
		FOREIGN KEY ( Nom, Prenom, Alias )
        REFERENCES Personne (  Nom, Prenom, Alias )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmRealisateur   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'FilmRealisateur' AND xtype = 'U')  
DROP TABLE FilmRealisateur ;
CREATE TABLE FilmRealisateur (
	TitreVF         NVARCHAR(128) NOT NULL,
	AnneeSortie     SMALLINT NOT NULL,
    Nom             NVARCHAR(64) NOT NULL,
    Prenom          NVARCHAR(64) NOT NULL,
    Alias           NVARCHAR(64),

	CONSTRAINT FK_FILMREALISATEUR_FILM
		FOREIGN KEY ( TitreVF, AnneeSortie )
        REFERENCES Film ( TitreVF, AnneeSortie ),
	CONSTRAINT FK_FILMREALISATEUR_REALISATEUR
		FOREIGN KEY ( Nom, Prenom, Alias )
        REFERENCES Personne (  Nom, Prenom, Alias )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmGenre   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'FilmGenre' AND xtype = 'U')  
DROP TABLE FilmGenre ;
CREATE TABLE FilmGenre (
	TitreVF         NVARCHAR(128) NOT NULL,
	AnneeSortie     SMALLINT NOT NULL,
	NomGenre        NVARCHAR(64) NOT NULL,

	CONSTRAINT FK_FILMGENRE_GENRE
	FOREIGN KEY ( NomGenre ) REFERENCES Genre ( Nom ),
	CONSTRAINT FK_FILMGENRE_FILM
		FOREIGN KEY ( TitreVF, AnneeSortie )
        REFERENCES Film ( TitreVF, AnneeSortie ),
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table EditionLangueSousTitres   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'EditionLangueSousTitres' AND xtype = 'U')  
DROP TABLE EditionLangueSousTitres ;
CREATE TABLE EditionLangueSousTitres (
	IdEdition INT NOT NULL,
	NomLangue  NVARCHAR(64) NOT NULL,

	CONSTRAINT FK_SOUSTITRES_EDITION 
		FOREIGN KEY ( IdEdition ) REFERENCES Edition ( Id ) ON DELETE CASCADE,
	CONSTRAINT FK_SOUSTITRES_LANGUE 
		FOREIGN KEY ( NomLangue ) REFERENCES Langue ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table EditionLangueAudio   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'EditionLangueAudio' AND xtype = 'U')  
DROP TABLE EditionLangueAudio ;
CREATE TABLE EditionLangueAudio (
	IdEdition INT NOT NULL,
	NomLangue  NVARCHAR(64) NOT NULL,

	CONSTRAINT FK_AUDIO_EDITION 
		FOREIGN KEY ( IdEdition ) REFERENCES Edition ( Id ) ON DELETE CASCADE,
	CONSTRAINT FK_AUDIO_LANGUE 
		FOREIGN KEY ( NomLangue ) REFERENCES Langue ( Nom )
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table EditeurEdition   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'EditeurEdition' AND xtype = 'U')  
DROP TABLE EditeurEdition ;
CREATE TABLE EditeurEdition (
	IdEdition INT NOT NULL,
	NomEditeur NVARCHAR(64) NOT NULL,

	CONSTRAINT FK_EDITEUREDITION_EDITION
		FOREIGN KEY ( IdEdition ) REFERENCES Edition ( Id ),
	CONSTRAINT FK_EDITEUREDITION_EDITEUR
		FOREIGN KEY ( NomEditeur ) REFERENCES Editeur ( Nom ) ON UPDATE CASCADE
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmProducteur   */
/* Auteur  : AMIARD Raphaël - SAR  */
/* Testeur : AMIARD Raphaël - SAR  */
-------------------------------------
IF EXISTS  (SELECT 1 FROM sysobjects WHERE name = 'FilmProducteur' AND xtype = 'U')  
DROP TABLE FilmProducteur ;
CREATE TABLE FilmProducteur (
	TitreVF            NVARCHAR(128) NOT NULL,
	AnneeSortie        SMALLINT NOT NULL,
    NomProducteur      NVARCHAR(64) NOT NULL,
    PrenomProducteur   NVARCHAR(64) NOT NULL,
    AliasProducteur    NVARCHAR(64),

	CONSTRAINT FK_FILMPRODUCTEUR_FILM
		FOREIGN KEY ( TitreVF, AnneeSortie )
        REFERENCES Film ( TitreVF, AnneeSortie ),
	CONSTRAINT FK_FILMPRODUCTEUR_PRODUCTEUR
		FOREIGN KEY ( NomProducteur, PrenomProducteur, AliasProducteur )
		REFERENCES Personne ( Nom, Prenom, Alias )
)
