---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter une Edition                               */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Supprimer donn�es **/
DELETE FROM EditeurEdition
GO

DELETE FROM Edition
GO

DELETE FROM Editeur
GO

DELETE FROM Film WHERE TitreVF = 'Qu''il �tait bon mon petit fran�ais' AND TitreVO = 'Como era gostoso o meu franc�s' AND AnneeSortie = 1971
GO

/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT e.NomEdition, ee.NomEditeur FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition

/** Ajouter donn�es necessaires **/

INSERT INTO Film
           (TitreVF
           ,TitreVO
           ,AnneeSortie
           ,Langue
           ,Synopsis)
     VALUES
           ('Qu''il �tait bon mon petit fran�ais'
           ,'Como era gostoso o meu franc�s'
           ,convert(smallint,'1971')
           ,'Portugais'
           ,'� l��poque de l��pisode de la France Antarctique et dans le contexte des affrontements au xvi si�cle entre Fran�ais et Portugais pour la colonisation du Br�sil, le film raconte l�histoire d�un jeune Fran�ais recueilli par une tribu cannibale Tupinambas...')
GO

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
		@ListLangueAudio = '|Portugais|',
		@ListLangueSousTitres = '|Portugais|Anglais|'
		
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT ee.NomEditeur, e.NomEdition, e.FilmTitreVF, e.FilmAnneeSortie FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition
GO