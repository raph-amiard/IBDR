---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : RAHMMOUN Imane - SAR , GOUYOUY Ludovic - TA					  */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO
EXEC _Vide_BD
EXEC _Ajout_Type_Abonnement
PRINT 'Avant execution'



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
select * from TypeAbonnement
BEGIN TRY
EXEC typeAbonnement_modifier 
 	 	@Nom = 'Complet' ,
		@PrixMensuel = 200 ,
		@PrixLocation =0.05 ,
		@MaxJoursLocation = 5 ,
		@NbMaxLocations = 10 ,
		@PrixRetard = 5 ,
		@DureeEngagement = 720 
END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH
PRINT 'Fin Test'
select * from TypeAbonnement
EXEC _Vide_BD