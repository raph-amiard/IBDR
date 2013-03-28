---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC _Ajout_Abonnement

/** Ajouter donn�es necessaires **/
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
           ('Qu''il �tait bon mon petit fran�ais'
           ,'Como era gostoso o meu franc�s'
           ,convert(smallint,'1971')
           ,'Portugue'
           ,'� l��poque de l��pisode de la France Antarctique et dans le contexte des affrontements au xvi si�cle entre Fran�ais et Portugais pour la colonisation du Br�sil, le film raconte l�histoire d�un jeune Fran�ais recueilli par une tribu cannibale Tupinambas...')
GO

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
	VALUES (1, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP+10, NULL, 1, 0)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (2, 1, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-1, NULL, 2, 0)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (5, 2, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-1, NULL, 5, 1)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (3, 1, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-1, CURRENT_TIMESTAMP, 3, 1)

INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (4, 1, CURRENT_TIMESTAMP-10, CURRENT_TIMESTAMP-5, CURRENT_TIMESTAMP-3, 4, 1)
INSERT INTO [dbo].[Location] 
	([Id], [AbonnementId], [DateLocation], [DateRetourPrev], [DateRetourEff], [FilmStockId], [Confirmee]) 
	VALUES (6, 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP+10, NULL, 1, 1)
SET IDENTITY_INSERT [dbo].[Location] OFF




PRINT 'Avant execution'
select Location.DateLocation, Location.DateRetourPrev, Location.DateRetourEff, Location.AbonnementId, Location.Confirmee, 
		Abonnement.NomClient, Abonnement.PrenomClient, Abonnement.MailClient,
		Client.BlackListe
	from Location
	inner join Abonnement
	on Location.AbonnementId = Abonnement.Id
	inner join Client 
	on Abonnement.NomClient = Client.Nom
	and Abonnement.PrenomClient = Client.Prenom
	and Abonnement.MailClient = Client.Mail

EXEC nettoyage_Reservation;

select Location.DateRetourPrev, Location.DateRetourEff, Location.AbonnementId, Location.Confirmee, 
		Abonnement.NomClient, Abonnement.PrenomClient, Abonnement.MailClient,
		Client.BlackListe
	from Location
	inner join Abonnement
	on Location.AbonnementId = Abonnement.Id
	inner join Client 
	on Abonnement.NomClient = Client.Nom
	and Abonnement.PrenomClient = Client.Prenom
	and Abonnement.MailClient = Client.Mail

EXEC _Vide_BD