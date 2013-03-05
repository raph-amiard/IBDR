---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : AMIARD Raphaël - SAR                                             */
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
	@Nombre = 1
		
Declare @dateDebut DATE
SET @dateDebut = CURRENT_TIMESTAMP +1
Declare @dateFin DATE
SET @dateFin = DATEADD(week, 10, CURRENT_TIMESTAMP)
SELECT @dateDebut, @dateFin
EXEC dbo.abonnement_creer
	@DateDebut =  @dateDebut,
	@DateFin = @dateFin,
	@NomClient =  'JEAN',
	@PrenomClient = 'David',
	@MailClient = 'JEAN.David@yahoo.fr' ,
	@TypeAbonnement = 'Classic'

DECLARE @date_fin_loc DATETIME
DECLARE @date_debut_res_1 DATETIME
DECLARE @date_debut_res_2 DATETIME
DECLARE @date_debut_res_3 DATETIME
DECLARE @date_fin_res_1 DATETIME
DECLARE @id_abonnement INT
SELECT @id_abonnement = @@identity
SELECT @date_fin_loc = DATEADD(day, 2, CURRENT_TIMESTAMP)
SELECT @date_debut_res_1 = DATEADD(day, 1, CURRENT_TIMESTAMP)
SELECT @date_debut_res_2 = DATEADD(day, 5, CURRENT_TIMESTAMP)
SELECT @date_debut_res_3 = DATEADD(day, 3, CURRENT_TIMESTAMP)
SELECT @date_fin_res_1 = DATEADD(day, 8, CURRENT_TIMESTAMP)


-- TODO : Montrer les tables avant
PRINT 'Avant execution'
select * from Location

PRINT 'Test location'
EXEC dbo.location_ajouter
	@id_abonnement = @id_abonnement,
	@id_edition = @id_edition,
	@date_fin = @date_fin_loc

PRINT 'Test reservation impossible'
EXEC dbo.reservation_ajouter
	@id_abonnement = @id_abonnement,
	@id_edition = @id_edition,
	@date_debut = @date_debut_res_1,
	@date_fin = @date_fin_res_1

PRINT 'Test reservation possible'
EXEC dbo.reservation_ajouter
	@id_abonnement = @id_abonnement,
	@id_edition = @id_edition,
	@date_debut = @date_debut_res_2,
	@date_fin = @date_fin_res_1

PRINT 'Test reservation impossible 2'
EXEC dbo.reservation_ajouter
	@id_abonnement = @id_abonnement,
	@id_edition = @id_edition,
	@date_debut = @date_debut_res_3,
	@date_fin = @date_fin_res_1

-- TODO : Montrer les tables après
PRINT 'Après execution'
select * from Location

/*
DECLARE @date_debut DATETIME
DECLARE @date_fin DATETIME
SET @date_debut = '08/03/2013 18:08:26.250'
SET @date_fin = '10/03/2013 18:08:26.250'

select * from Edition
select * from dbo.films_disponibles_le(15, @date_debut, @date_fin)

SELECT * FROM Location loc
        WHERE loc.FilmStockId = 16
        AND ((@date_debut <= loc.DateRetourPrev AND @date_debut >= loc.DateLocation)
			 OR
             (@date_fin >= loc.DateLocation AND @date_fin <= loc.DateRetourPrev))*/