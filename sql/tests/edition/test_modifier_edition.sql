---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour mettre à jour tous les attributs d'une Edition    */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Supprimer données **/
EXEC _Vide_BD

/** Ajouter données necessaires **/
INSERT INTO Film
           (TitreVF
           ,TitreVO
           ,AnneeSortie
           ,Langue
           ,Synopsis)
     VALUES
           ('Qu''il était bon mon petit français'
           ,'Como era gostoso o meu francês'
           ,convert(smallint,'1971')
           ,'Portugais'
           ,'À l’époque de l’épisode de la France Antarctique et dans le contexte des affrontements au xvi siècle entre Français et Portugais pour la colonisation du Brésil, le film raconte l’histoire d’un jeune Français recueilli par une tribu cannibale Tupinambas...')

EXEC dbo.edition_creer 
		@FilmTitreVF = 'Qu''il était bon mon petit français',
		@FilmAnneeSortie = '1971',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2011',
		@Support = 'DVD',
		@Couleur = 0,
		@Pays = 'Brésil',
		@NomEdition = 'Box Edition',
		@AgeInterdiction = 18,
		@ListEditeurs = '|Globo Filmes|Condor Filmes|',
		@ListLangueAudio = '|Portugais|Français|',
		@ListLangueSousTitres = '|Portugais|Français|Anglais|'
		
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'

/** L'état de la base données par rapport les tables qui seront modifiés **/
SELECT * FROM Edition

/** Exécution de la procedure **/
EXEC dbo.edition_modifier_nom
	@ID_Edition = @ID_EDITION,
	@NomEdition = 'Box Special Edition'

EXEC  dbo.edition_modifier_duree
	@ID_Edition = @ID_EDITION,
	@Duree = '01:54:00'
	
EXEC dbo.edition_modifier_date_sortie
	@ID_Edition = @ID_EDITION,
	@DateSortie = '25/02/2012'

EXEC dbo.edition_modifier_support
	@ID_Edition = @ID_EDITION,
	@Support = 'Blu-ray'
	
EXEC dbo.edition_modifier_couleur
	@ID_Edition = @ID_EDITION,
	@Couleur = 1

EXEC dbo.edition_modifier_pays
	@ID_Edition = @ID_EDITION,
	@Pays = 'France'
		
EXEC dbo.edition_modifier_age_interdiction
	@ID_Edition = @ID_EDITION,
	@AgeInterdiction = 12
	
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT * FROM Edition

