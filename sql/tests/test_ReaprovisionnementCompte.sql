---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
EXEC _Vide_BD
EXEC _Ajout_Abonnement
PRINT 'Avant execution'

select * from Abonnement

BEGIN TRY
	EXEC ReaprovisionnementCompte
		@Id = 0,
		@AjoutSolde = 20
END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT 'Ajout abonnement identique'
BEGIN TRY
	EXEC ReaprovisionnementCompte
		@Id = 70,
		@AjoutSolde = 20
END TRY
BEGIN CATCH
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT ' '
PRINT 'Fin test'
select * from Abonnement
EXEC _Vide_BD