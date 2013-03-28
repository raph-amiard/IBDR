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
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'



/** L'état de la base données par rapport les tables qui seront modifiés **/
SELECT ee.NomEditeur, e.NomEdition FROM Edition e, EditeurEdition ee 
	WHERE  e.Id = ee.IdEdition AND e.Id = @ID_EDITION
	
/** Exécution de la procedure **/
EXEC dbo.edition_supprimer_reparti
	@ID_Edition = @ID_EDITION
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT ee.NomEditeur, e.NomEdition FROM Edition e, EditeurEdition ee 
	WHERE  e.Id = ee.IdEdition
GO
