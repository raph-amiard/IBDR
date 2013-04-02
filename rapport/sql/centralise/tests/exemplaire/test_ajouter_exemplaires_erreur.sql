---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter un ensemble d'exemplaires (FilmStock)     */
/* ERRRUR : L'édition n'existe pas                                             */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Supprimer données **/
EXEC _Vide_BD

/** L'état de la base données par rapport les tables qui seront modifiés **/
SELECT * FROM FilmStock

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

/** Exécution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 3
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT * FROM FilmStock
GO
