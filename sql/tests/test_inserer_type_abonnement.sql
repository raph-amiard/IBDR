---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
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

PRINT ' '
PRINT 'Fin Test'
select * from TypeAbonnement
EXEC _Vide_BD