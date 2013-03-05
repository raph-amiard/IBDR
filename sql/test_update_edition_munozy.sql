---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour mettre � jour une Edition                         */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
/** Supprimer donn�es **/
DELETE FROM [IBDR_SAR].[dbo].[Location]
GO

DELETE FROM [IBDR_SAR].[dbo].[Abonnement]
GO

DELETE FROM [IBDR_SAR].[dbo].[TypeAbonnement]
GO

DELETE FROM [IBDR_SAR].[dbo].[Client]
GO

DELETE FROM [IBDR_SAR].[dbo].[FilmStock]
GO

DELETE FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO

DELETE FROM [IBDR_SAR].[dbo].[EditionLangueAudio]
GO

DELETE FROM [IBDR_SAR].[dbo].[EditionLangueSousTitres]
GO

DELETE FROM [IBDR_SAR].[dbo].[Edition]
GO

DELETE FROM [IBDR_SAR].[dbo].[Editeur]
GO

DELETE FROM [IBDR_SAR].[dbo].[Film] 
GO

DELETE FROM [IBDR_SAR].[dbo].[Langue] 
GO

DELETE FROM [IBDR_SAR].[dbo].[Pays] 
GO

/** Ajouter donn�es necessaires **/

INSERT INTO [IBDR_SAR].[dbo].[Langue]
           ([Nom])
     VALUES
           ('Portugue')
           
INSERT INTO [IBDR_SAR].[dbo].[Langue]
           ([Nom])
     VALUES
           ('Anglais')
           
INSERT INTO [IBDR_SAR].[dbo].[Langue]
           ([Nom])
     VALUES
           ('Fran�ais')

INSERT INTO [IBDR_SAR].[dbo].[Film]
           ([TitreVF]
           ,[TitreVO]
           ,[AnneeSortie]
           ,[Langue]
           ,[Synopsis])
     VALUES
           ('Qu''il �tait bon mon petit fran�ais'
           ,'Como era gostoso o meu franc�s'
           ,convert(smallint,'1971')
           ,'Portugue'
           ,'� l��poque de l��pisode de la France Antarctique et dans le contexte des affrontements au xvi si�cle entre Fran�ais et Portugais pour la colonisation du Br�sil, le film raconte l�histoire d�un jeune Fran�ais recueilli par une tribu cannibale Tupinambas...')

INSERT INTO [IBDR_SAR].[dbo].[Pays]
           ([Nom])
     VALUES
           ('Br�sil')
           
INSERT INTO [IBDR_SAR].[dbo].[Pays]
           ([Nom])
     VALUES
           ('France')   

EXEC proc_insert_edition 
		@FilmTitreVF = 'Qu''il �tait bon mon petit fran�ais',
		@FilmAnneeSortie = '1971',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2011',
		@Support = 'DVD',
		@Couleur = 0,
		@Pays = 'Br�sil',
		@NomEdition = 'Box Edition',
		@AgeInterdiction = 18,
		@ListEditeurs = '|Globo Filmes|Condor Filmes|',
		@ListLangueAudio = '|Portugue|Fran�ais|',
		@ListLangueSousTitres = '|Portugue|Fran�ais|Anglais|'

DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

EXEC proc_insert_exemplaire
	@DateArrivee = '03/03/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 1

INSERT INTO [IBDR_SAR].[dbo].[TypeAbonnement]
           ([Nom]
           ,[PrixMensuel]
           ,[PrixLocation]
           ,[MaxJoursLocation]
           ,[NbMaxLocations]
           ,[PrixRetard]
           ,[DureeEngagement])
     VALUES
           ('Solo',1,0.1,1,1,1,1)

INSERT INTO [IBDR_SAR].[dbo].[Client]
           ([Civilite]
           ,[Nom]
           ,[Prenom]
           ,[DateNaissance]
           ,[Mail]
           ,[Telephone1]
           ,[Telephone2]
           ,[NumRue]
           ,[TypeRue]
           ,[NomRue]
           ,[CodePostal]
           ,[Ville]
           ,[BlackListe])
     VALUES
           ('Celib'
           ,'Derrida'
           ,'Ambroise'
           ,'01/01/1950'
           ,'ambroise.derrida@cosmic.net'
           ,'0108050133'
           ,'0123456789'
           ,9
           ,'Rue'
           ,'Pascal-Paoli'
           ,'2B454'
           ,'Corte'
           ,0)
           
INSERT INTO [IBDR_SAR].[dbo].[Abonnement]
           ([Solde]
           ,[DateDebut]
           ,[DateFin]
           ,[NomClient]
           ,[PrenomClient]
           ,[MailClient]
           ,[TypeAbonnement])
     VALUES
           (1
           ,convert(datetime,'2013-02-23 00:00:00.000',21)
           ,convert(datetime,'2013-05-24 00:00:00.000',21)
           ,'Derrida'
           ,'Ambroise'
           ,'ambroise.derrida@cosmic.net'
           ,'Solo')


DECLARE @ID_ABONNEMENT INT
SELECT @ID_ABONNEMENT = @@IDENTITY 

DECLARE @ID_FILMSTOCK INT
SELECT @ID_FILMSTOCK = [ID] FROM  [IBDR_SAR].[dbo].[FilmStock]

INSERT INTO [IBDR_SAR].[dbo].[Location]
           ([AbonnementId]
           ,[DateLocation]
           ,[DateRetourPrev]
           ,[DateRetourEff]
           ,[FilmStockId])
     VALUES
           (@ID_ABONNEMENT
           , '03/03/2013 10:00:00:000'
           , '05/03/2013 10:00:00:000'
           , '07/03/2013 10:00:00:000'
           ,@ID_FILMSTOCK)
           
DECLARE @ID_LOCATION INT
SELECT @ID_LOCATION = @@IDENTITY

INSERT INTO [IBDR_SAR].[dbo].[RelanceRetard]
           ([Date]
           ,[LocationId]
           ,[Niveau])
     VALUES
           ('07/03/2013 10:00:00:000'
           ,@ID_LOCATION
           ,2)
GO

/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Edition]
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

EXEC proc_update_nom_edition
	@ID_Edition = @ID_EDITION,
	@NomEdition = 'Box Special Edition'

EXEC  proc_update_duree_edition
	@ID_Edition = @ID_EDITION,
	@Duree = '01:54:00'
	
EXEC proc_update_date_sortie_edition
	@ID_Edition = @ID_EDITION,
	@DateSortie = '25/02/2012'

EXEC proc_update_support_edition
	@ID_Edition = @ID_EDITION,
	@Support = 'Blu-ray'
	
EXEC proc_update_couleur_edition
	@ID_Edition = @ID_EDITION,
	@Couleur = 1

EXEC proc_update_pays_edition
	@ID_Edition = @ID_EDITION,
	@Pays = 'France'
		
EXEC proc_update_age_interdi_edition
	@ID_Edition = @ID_EDITION,
	@AgeInterdiction = 12
	
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Edition]

/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[EditionLangueAudio] 
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditionLangueSousTitres] 
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Special Edition'

EXEC proc_update_delete_langueaudio_edition
	@ID_Edition = @ID_EDITION,
	@LangueAudio = 'Portugue'

EXEC proc_update_delete_languesoustitres_edition
	@ID_Edition = @ID_EDITION,
	@LangueSousTitres = 'Portugue'
	
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[EditionLangueAudio] 
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditionLangueSousTitres] 
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Special Edition'

EXEC proc_update_insert_langueaudio_edition
	@ID_Edition = @ID_EDITION,
	@LangueAudio = 'Portugue'

EXEC proc_update_insert_languesoustitres_edition
	@ID_Edition = @ID_EDITION,
	@LangueSousTitres = 'Portugue'
	
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[EditionLangueAudio] 
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditionLangueSousTitres] 
GO

/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Special Edition'

EXEC proc_update_supp_editeur_edition
	@ID_Edition = @ID_EDITION,
	@NomEditeur = 'Globo Filmes'
	
/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Special Edition'

EXEC proc_update_ajout_editeur_edition
	@ID_Edition = @ID_EDITION,
	@NomEditeur = 'Globo'
	
/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Special Edition'

EXEC proc_update_editeur
	@NomEditeur = 'Globo',
	@NomEditeurNouv = 'Globo Filmes'
	
/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO
