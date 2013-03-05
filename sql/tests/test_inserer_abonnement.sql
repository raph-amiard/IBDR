---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC _Ajout_Abonnement
PRINT 'Avant execution'

select * from Client
select * from TypeAbonnement
select * from Abonnement

Declare @dateDebut DATE
SET @dateDebut = CURRENT_TIMESTAMP-50;
Declare @dateFin DATE
SET @dateFin = CURRENT_TIMESTAMP+40;
BEGIN TRY
	EXEC abonnement_creer
		@DateDebut =  @dateDebut,
		@DateFin = @dateFin,
		@NomClient =  'JEAN',
		@PrenomClient = 'David',
		@MailClient = 'JEAN.David@yahoo.fr' ,
		@TypeAbonnement = 'Classic'
END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT 'Ajout abonnement identique'
BEGIN TRY
	EXEC abonnement_creer
		@DateDebut =  @dateDebut,
		@DateFin = @dateFin,
		@NomClient =  'JEAN',
		@PrenomClient = 'David',
		@MailClient = 'JEAN.David@yahoo.fr' ,
		@TypeAbonnement = 'Classic'
END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT ' '
PRINT 'Fin test'
select * from Client
select * from TypeAbonnement
select * from Abonnement
EXEC _Vide_BD