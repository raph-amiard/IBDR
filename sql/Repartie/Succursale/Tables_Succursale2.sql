-------------------------------------------------------
/* IBDR 2013 – Groupe SAR                            */ 
/* Création de la base de données IBDR_SAR           */ 
/* Date de la version 20/02/2013                     */
-------------------------------------------------------

USE IBDR_SAR2
GO

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table FilmStock  */
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
	Supprimer BIT NOT NULL,

	CONSTRAINT PK_FILMSTOCK PRIMARY KEY ( Id ),
	CONSTRAINT FK_FILMSTOCK_EDITION
		FOREIGN KEY ( IdEdition ) REFERENCES Edition ( Id ) ON DELETE CASCADE
)

-------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Création de la table Client     */
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
/* Création de la table Abonnement */
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