﻿---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : RAHMMOUN Imane - SAR ,GOUYOU Ludovic - TA                        */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC _Ajout_Type_Abonnement
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
	EXEC type_abonnement_creer 
		@Nom = 'classic' ,
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
PRINT 'Ajout du même TypeAbonnement'
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
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT 'Ajout d''un champ TypeAbonnement null'
BEGIN TRY
	EXEC type_abonnement_creer 
		@Nom = 'Complet' ,
		@PrixMensuel = null ,
		@PrixLocation =0.05 ,
		@MaxJoursLocation = 5 ,
		@NbMaxLocations = 10 ,
		@PrixRetard = 5 ,
		@DureeEngagement = 720 

END TRY
BEGIN CATCH
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT ' Contrainte non respecté'
BEGIN TRY
	EXEC type_abonnement_creer 
		@Nom = 'Complet' ,
		@PrixMensuel = 100 ,
		@PrixLocation =0.05 ,
		@MaxJoursLocation = 5 ,
		@NbMaxLocations = 0 ,
		@PrixRetard = 5 ,
		@DureeEngagement = 720 

END TRY
BEGIN CATCH
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH
PRINT ' '
PRINT 'Fin Test'
select * from TypeAbonnement
EXEC _Vide_BD