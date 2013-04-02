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



/** L'�tat de la base donn�es par rapport les tables qui seront modifi�s **/
SELECT ee.NomEditeur, e.NomEdition FROM Edition e, EditeurEdition ee 
	WHERE  e.Id = ee.IdEdition AND e.Id = @ID_EDITION
	
/** Ex�cution de la procedure **/
EXEC dbo.edition_supprimer_reparti
	@ID_Edition = @ID_EDITION
		
/** L'�tat de la base donn�es par rapport les tables qui ont �t� modifi�s **/
SELECT ee.NomEditeur, e.NomEdition FROM Edition e, EditeurEdition ee 
	WHERE  e.Id = ee.IdEdition
GO
