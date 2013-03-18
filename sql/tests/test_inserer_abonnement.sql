---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC _Ajout_Abonnement
PRINT 'Avant execution'

select Abonnement.*, TypeAbonnement.Nom, Client.Nom, Client.Prenom, Client.Mail 
	from Abonnement 
	inner join TypeAbonnement 
		on Abonnement.TypeAbonnement = TypeAbonnement.Nom
	inner join Client 
		on Abonnement.NomClient = Client.Nom 
		and Abonnement.PrenomClient = Client.Prenom
		and Abonnement.MailClient = Client.Mail

Declare @dateDebut DATE
SET @dateDebut = CURRENT_TIMESTAMP+1;
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

select Abonnement.*, TypeAbonnement.Nom, Client.Nom, Client.Prenom, Client.Mail 
	from Abonnement 
	inner join TypeAbonnement 
		on Abonnement.TypeAbonnement = TypeAbonnement.Nom
	inner join Client 
		on Abonnement.NomClient = Client.Nom 
		and Abonnement.PrenomClient = Client.Prenom
		and Abonnement.MailClient = Client.Mail

EXEC _Vide_BD