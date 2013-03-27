---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour mettre à jour les langues d'une Edition           */
/* - Ajoueter langues (Audio et Sous-Titres)                                   */
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
		@Couleur = 1,
		@Pays = 'Brésil',
		@NomEdition = 'Box Edition',
		@AgeInterdiction = 18,
		@ListEditeurs = '|Globo Filmes|Condor Filmes|',
		@ListLangueAudio = '|Portugais|Français|',
		@ListLangueSousTitres = '|Portugais|Français|Anglais|'
		
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'


/** L'état de la base données par rapport les tables qui qui seront modifiés **/
SELECT e.NomEdition, eda.NomLangue AS LangueAudio FROM Edition e inner join EditionLangueAudio eda ON e.Id = eda.IdEdition

SELECT e.NomEdition, eds.NomLangue AS LangueSousTitres FROM Edition e inner join EditionLangueSousTitres eds ON e.Id = eds.IdEdition


/** Exécution de la procedure **/
EXEC dbo.edition_ajouter_langue_audio
	@ID_Edition = @ID_EDITION,
	@LangueAudio = 'Chinois'

EXEC dbo.edition_ajouter_langue_sous_titres
	@ID_Edition = @ID_EDITION,
	@LangueSousTitres = 'Chinois'
	
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT e.NomEdition, eda.NomLangue AS LangueAudio FROM Edition e inner join EditionLangueAudio eda ON e.Id = eda.IdEdition

SELECT e.NomEdition, eds.NomLangue AS LangueSousTitres FROM Edition e inner join EditionLangueSousTitres eds ON e.Id = eds.IdEdition


