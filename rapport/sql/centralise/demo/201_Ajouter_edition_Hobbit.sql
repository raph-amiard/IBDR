---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter une Edition                               */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO


/** L'état de la base données par rapport les tables qui seront modifiés **/
SELECT e.NomEdition, ee.NomEditeur FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition

/** Exécution de la procedure **/
EXEC dbo.edition_creer 
		@FilmTitreVF = 'Le Hobbit',
		@FilmAnneeSortie = '2012',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2013',
		@Support = 'DVD',
		@Couleur = 1,
		@Pays = 'États-Unis',
		@NomEdition = 'Box Edition',
		@AgeInterdiction = 12,
		@ListEditeurs = '|DW Films|WingNut Films|Warner Bros|',
		@ListLangueAudio = '|Anglais|Français|',
		@ListLangueSousTitres = '|Français|Anglais|'
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT ee.NomEditeur, e.NomEdition, e.FilmTitreVF, e.FilmAnneeSortie FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition
GO