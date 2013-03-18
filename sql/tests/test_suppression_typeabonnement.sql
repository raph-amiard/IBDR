---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : RAHMMOUN Imane - SAR											  */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC type_abonnement_creer
PRINT 'Avant execution'

select * from TypeAbonnement

BEGIN TRY
	EXEC type_abonnement_creer 
		@Nom = 'Complet' ,
		@PrixMensuel = 100 ,
		@PrixLocation =0.05 ,
		@MaxJoursLocation = 5 ,
		@NbMaxLocations = 10 ,
		@PrixRetard = 5 ,
		@DureeEngagement = 720 
END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

BEGIN TRY
	EXEC type_abonnement_supprimer 
	@Nom = 'Complet' 
	END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH
PRINT ' '
PRINT 'Fin Test'
select * from TypeAbonnement
EXEC _Vide_BD