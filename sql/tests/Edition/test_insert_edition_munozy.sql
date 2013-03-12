---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter une Edition                               */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Supprimer données **/
EXEC _Vide_BD

/** L'état de la base données par rapport les tables qui seront modifiés **/
SELECT e.NomEdition, ee.NomEditeur FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition

/** Ajouter données necessaires **/

--INSERT INTO [IBDR_SAR].[dbo].[Langue] ([Nom]) VALUES ('Portugais')
--INSERT INTO [IBDR_SAR].[dbo].[Langue] ([Nom]) VALUES ('Anglais')
--INSERT INTO [IBDR_SAR].[dbo].[Langue] ([Nom]) VALUES ('Français')

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
           ,'Portugais'
           ,'À l’époque de l’épisode de la France Antarctique et dans le contexte des affrontements au xvi siècle entre Français et Portugais pour la colonisation du Brésil, le film raconte l’histoire d’un jeune Français recueilli par une tribu cannibale Tupinambas...')
GO

--INSERT INTO [IBDR_SAR].[dbo].[Pays]
--           ([Nom])
--     VALUES
--           ('Brésil')
--GO

/** Exécution de la procedure **/
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
		@ListLangueAudio = '|Portugais|Français|',
		@ListLangueSousTitres = '|Portugais|Français|Anglais|'
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT * FROM [IBDR_SAR].[dbo].[Edition]
GO

SELECT * FROM [IBDR_SAR].[dbo].[Editeur]
GO

SELECT * FROM [IBDR_SAR].[dbo].[EditeurEdition]
GO