---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC _Ajout_Abonnement

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

DECLARE @id_edition INT
SELECT @id_edition = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

SET IDENTITY_INSERT [dbo].[FilmStock] ON
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (1, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (2, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (3, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (4, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (5, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (6, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (7, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (8, N'2013-04-01 10:00:00', 0, @id_edition, 0)
INSERT INTO [dbo].[FilmStock] ([Id], [DateArrivee], [Usure], [IdEdition], [Supprimer]) VALUES (9, N'2013-04-01 10:00:00', 0, @id_edition, 0)
SET IDENTITY_INSERT [dbo].[FilmStock] OFF

SET IDENTITY_INSERT [dbo].[Location] ON
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (1, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP+10, NULL, 1, 1)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (2, 1, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-1, NULL, 2, 1)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (5, 2, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-1, NULL, 5, 1)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (3, 1, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-1, CURRENT_TIMESTAMP, 3, 1)

INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (4, 1, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-5, CURRENT_TIMESTAMP-3, 4, 1)
SET IDENTITY_INSERT [dbo].[Location] OFF

UPDATE Abonnement
	set DateFin = CURRENT_TIMESTAMP+5
	where Id = 2

UPDATE Abonnement
	set DateFin = CURRENT_TIMESTAMP+4
	where Id = 1

UPDATE Abonnement
	set DateFin = CURRENT_TIMESTAMP-1
	where Id = 0

SET IDENTITY_INSERT [dbo].[Abonnement] ON
INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (3, CAST(30.0000 AS SmallMoney), CURRENT_TIMESTAMP-20, CURRENT_TIMESTAMP+3, N'DUPONT', N'Lucien', N'DUPONT.Lucien@gmail.com', N'Classic')
SET IDENTITY_INSERT [dbo].[Abonnement] OFF

UPDATE Client
	set BlackListe = 1
	where Prenom = 'Lucienne'

INSERT INTO [dbo].[RelanceDecouvert] ([AbonnementId], [Date], [Niveau]) VALUES (2, N'2013-03-18 22:35:20', 5)

INSERT INTO [dbo].[RelanceRetard] ([Date], [LocationId], [Niveau]) VALUES (N'2013-03-18 22:01:21', 5, 5)

PRINT 'Avant execution'
select	Abonnement.Id, Abonnement.DateFin, 
		Abonnement.NomClient, Abonnement.PrenomClient, Abonnement.MailClient,
		Client.BlackListe
	from Abonnement
	inner join Client 
	on Abonnement.NomClient = Client.Nom
	and Abonnement.PrenomClient = Client.Prenom
	and Abonnement.MailClient = Client.Mail

EXEC echeance_prochaine_abonnement
	@DateDiff = 5

PRINT 'Apres execution'

EXEC _Vide_BD