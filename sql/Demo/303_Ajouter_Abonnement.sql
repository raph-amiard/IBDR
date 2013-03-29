Use IBDR_SAR
GO

Declare @dateDebut DATE
SET @dateDebut = CURRENT_TIMESTAMP+1;
Declare @dateFin DATE
SET @dateFin = CURRENT_TIMESTAMP+40;

EXEC abonnement_creer
	@DateDebut =  @dateDebut,
	@DateFin = @dateFin,
	@NomClient =  'DUPOND',
	@PrenomClient = 'Fran�ois',
	@MailClient='Fran�ois.DUPOND@gmail.com',
	@TypeAbonnement = 'Complet'

select Abonnement.*, TypeAbonnement.Nom, Client.Nom, Client.Prenom, Client.Mail 
	from Abonnement 
	inner join TypeAbonnement 
		on Abonnement.TypeAbonnement = TypeAbonnement.Nom
	inner join Client 
		on Abonnement.NomClient = Client.Nom 
		and Abonnement.PrenomClient = Client.Prenom
		and Abonnement.MailClient = Client.Mail