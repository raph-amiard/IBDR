---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour mettre � jour l'editeur d'une Edition             */
/* - Supprimer editeur                                                         */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Supprimer donn�es **/
EXEC _Vide_BD

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
		
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'

/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT ee.NomEditeur, e.NomEdition FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition

/** Ex�cution de la procedure **/
EXEC dbo.edition_supprimer_editeur
	@ID_Edition = @ID_EDITION,
	@NomEditeur = 'Globo Filmes'
	
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT ee.NomEditeur, e.NomEdition FROM Edition e inner join EditeurEdition ee ON e.Id = ee.IdEdition
