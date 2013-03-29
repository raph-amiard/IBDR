---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour supprimer une Edition                             */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO
		
DECLARE @ID_EDITION INT

/** Exécution de la procedure **/
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'
EXEC dbo.edition_supprimer
	@ID_Edition = @ID_EDITION
	
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Full Edition'
EXEC dbo.edition_supprimer
	@ID_Edition = @ID_EDITION
	
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Full Edition Special'
EXEC dbo.edition_supprimer
	@ID_Edition = @ID_EDITION
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT ee.NomEditeur, e.NomEdition, fs.Id AS Exemplaire_ID, l.Id AS Location_ID, rr.Date AS RelanceRetard_Date
	FROM Edition e, EditeurEdition ee, FilmStock fs, Location l, RelanceRetard rr 
	WHERE  e.Id = ee.IdEdition AND fs.IdEdition = e.Id AND fs.Id = l.FilmStockId AND l.Id = rr.LocationId
GO