---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter une Edition                               */
/* ERRUER : Le film n'existe pas                                               */
/*                                                                             */
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
SELECT ee.NomEditeur, e.NomEdition, e.FilmTitreVF, e.FilmAnneeSortie FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition
GO