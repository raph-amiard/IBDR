---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter un ensemble d'exemplaires (FilmStock)     */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Exécution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Full Edition'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 3
	
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Full Edition Special'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 2
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT * FROM FilmStock
GO
