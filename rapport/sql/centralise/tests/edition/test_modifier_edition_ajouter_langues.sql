---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour mettre � jour les langues d'une Edition           */
/* - Ajoueter langues (Audio et Sous-Titres)                                   */
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


/** L'�tat de la base donn�es par rapport les tables qui qui seront modifi�s **/
SELECT e.NomEdition, eda.NomLangue AS LangueAudio FROM Edition e inner join EditionLangueAudio eda ON e.Id = eda.IdEdition

SELECT e.NomEdition, eds.NomLangue AS LangueSousTitres FROM Edition e inner join EditionLangueSousTitres eds ON e.Id = eds.IdEdition


/** Ex�cution de la procedure **/
EXEC dbo.edition_ajouter_langue_audio
	@ID_Edition = @ID_EDITION,
	@LangueAudio = 'Chinois'

EXEC dbo.edition_ajouter_langue_sous_titres
	@ID_Edition = @ID_EDITION,
	@LangueSousTitres = 'Chinois'
	
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT e.NomEdition, eda.NomLangue AS LangueAudio FROM Edition e inner join EditionLangueAudio eda ON e.Id = eda.IdEdition

SELECT e.NomEdition, eds.NomLangue AS LangueSousTitres FROM Edition e inner join EditionLangueSousTitres eds ON e.Id = eds.IdEdition


