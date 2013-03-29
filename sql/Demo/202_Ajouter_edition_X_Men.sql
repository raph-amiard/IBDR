---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter une Edition                               */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Exécution de la procedure **/
EXEC dbo.edition_creer 
		@FilmTitreVF = 'X-Men',
		@FilmAnneeSortie = '2011',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2013',
		@Support = 'DVD',
		@Couleur = 1,
		@Pays = 'États-Unis',
		@NomEdition = 'Box Full Edition',
		@AgeInterdiction = 12,
		@ListEditeurs = '|Fox Films|',
		@ListLangueAudio = '|Anglais|Français|',
		@ListLangueSousTitres = '|Français|Anglais|'
		

EXEC dbo.edition_creer 
		@FilmTitreVF = 'X-Men',
		@FilmAnneeSortie = '2011',
		@Duree = '01:24:00',
		@DateSortie = '20/02/2013',
		@Support = 'Blu-ray',
		@Couleur = 1,
		@Pays = 'États-Unis',
		@NomEdition = 'Box Full Edition Special',
		@AgeInterdiction = 12,
		@ListEditeurs = '|Fox Films|Flip Pictures',
		@ListLangueAudio = '|Anglais|Français|',
		@ListLangueSousTitres = '|Français|Anglais|'
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT ee.NomEditeur, e.NomEdition, e.FilmTitreVF, e.FilmAnneeSortie FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition
GO