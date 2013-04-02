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

/** Supprimer donn�es **/
EXEC _Vide_BD

/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT e.NomEdition, ee.NomEditeur FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition

/** Ajouter donn�es necessaires **/

/** Ex�cution de la procedure **/
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
		@ListLangueAudio = '|Portugais|Fran�ais|',
		@ListLangueSousTitres = '|Portugais|Fran�ais|Anglais|'
		
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT ee.NomEditeur, e.NomEdition, e.FilmTitreVF, e.FilmAnneeSortie FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition
GO