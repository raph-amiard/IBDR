---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : AMIARD Raphaël - SAR                                             */
---------------------------------------------------------------------------------
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

DECLARE @id_edition INT
SELECT @id_edition = [ID] FROM  [IBDR_SAR].[dbo].[Edition] WHERE [NomEdition] = 'Box Edition'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 3
		
Declare @dateDebut DATE
SET @dateDebut = CURRENT_TIMESTAMP
Declare @dateFin DATE
SET @dateFin = DATEADD(week, 10, CURRENT_TIMESTAMP)
EXEC dbo.abonnement_creer
	@DateDebut =  @dateDebut,
	@DateFin = @dateFin,
	@NomClient =  'JEAN',
	@PrenomClient = 'David',
	@MailClient = 'JEAN.David@yahoo.fr' ,
	@TypeAbonnement = 'Classic'

DECLARE @date_fin_loc DATETIME
DECLARE @id_abonnement INT
SELECT @id_abonnement = @@identity
SELECT @date_fin_loc = DATEADD(day, 1, CURRENT_TIMESTAMP)


-- TODO : Montrer les tables avant
PRINT 'Avant execution'
select * from Location

EXEC dbo.location_ajouter
	@id_abonnement = @id_abonnement,
	@id_edition = @id_edition,
	@date_fin = @date_fin_loc

-- TODO : Montrer les tables après
PRINT 'Après execution'
select * from Location
