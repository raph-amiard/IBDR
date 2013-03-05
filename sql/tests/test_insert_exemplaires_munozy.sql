---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter un ensemble d'exemplaires (FilmStock)     */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

/** Supprimer données **/
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

/** L'état de la base données par rapport les tables qui seront modifiés **/
SELECT * FROM [IBDR_SAR].[dbo].[FilmStock]
GO

/** Ajouter données necessaires **/

INSERT INTO [IBDR_SAR].[dbo].[Langue]
           ([Nom])
     VALUES
           ('Portugue')
GO

INSERT INTO [IBDR_SAR].[dbo].[Film]
           ([TitreVF]
           ,[TitreVO]
           ,[AnneeSortie]
           ,[Langue]
           ,[Synopsis])
     VALUES
           ('Qu''il était bon mon petit français'
           ,'Como era gostoso o meu francês'
           ,convert(smallint,'1971')
           ,'Portugue'
           ,'À l’époque de l’épisode de la France Antarctique et dans le contexte des affrontements au xvi siècle entre Français et Portugais pour la colonisation du Brésil, le film raconte l’histoire d’un jeune Français recueilli par une tribu cannibale Tupinambas...')
GO

INSERT INTO [IBDR_SAR].[dbo].[Pays]
           ([Nom])
     VALUES
           ('Brésil')
GO

EXEC dbo.edition_creer 
		@FilmTitreVF = 'Qu''il était bon mon petit français',
		@FilmAnneeSortie = '1971',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2011',
		@Support = 'DVD',
		@Couleur = 1,
		@Pays = 'Brésil',
		@NomEdition = 'Box Edition',
		@AgeInterdiction = 18,
		@ListEditeurs = '|Globo Filmes|Condor Filmes|',
		@ListLangueAudio = '|Portugue|',
		@ListLangueSousTitres = '|Portugue|'

/** Exécution de la procedure **/

DECLARE @ID_EDITION INT

SELECT @ID_EDITION = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 3
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT * FROM [IBDR_SAR].[dbo].[FilmStock]
GO
