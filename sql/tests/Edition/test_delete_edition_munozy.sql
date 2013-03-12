---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour supprimer une Edition                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

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

EXEC dbo.edition_creer 
		@FilmTitreVF = 'Qu''il �tait bon mon petit fran�ais',
		@FilmAnneeSortie = '1971',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2011',
		@Support = 'DVD',
		@Couleur = 1,
		@Pays = 'Br�sil',
		@NomEdition = 'Box Edition',
		@AgeInterdiction = 18,
		@ListEditeurs = '|Globo Filmes|Condor Filmes|',
		@ListLangueAudio = '|Portugue|Fran�ais|',
		@ListLangueSousTitres = '|Portugue|Fran�ais|Anglais|'
		
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
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
           ,'01/01/1950' --convert(date,'01/01/1950',103)
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
           ,convert(datetime,'2013-04-01 00:00:00.000',21)
           ,convert(datetime,'2013-04-24 00:00:00.000',21)
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
           ,[FilmStockId]
           ,[Confirmee])
     VALUES
           (@ID_ABONNEMENT
           , '05/04/2013 10:00:00:000'
           , '07/04/2013 10:00:00:000'
           , '07/04/2013 10:00:00:000'
           ,@ID_FILMSTOCK
           ,1)
           
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

SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO

SELECT * FROM [IBDR_SAR].[dbo].[FilmStock]
GO
	
SELECT * FROM [IBDR_SAR].[dbo].[Location]
GO

SELECT * FROM [IBDR_SAR].[dbo].[RelanceRetard]
GO

/** Ex�cution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

EXEC dbo.edition_supprimer
	@ID_Edition = @ID_EDITION
		
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT * FROM [IBDR_SAR].[dbo].[Edition]
GO

SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO

SELECT * FROM [IBDR_SAR].[dbo].[FilmStock]
GO

SELECT * FROM [IBDR_SAR].[dbo].[Location]
GO

SELECT * FROM [IBDR_SAR].[dbo].[RelanceRetard]
GO