Use IBDR_SAR
GO

Declare @date DATE
SET @date = '01/01/1960'
EXEC client_creer
	@Civilite='Monsieur',
	@Nom='DUPOND',
	@Prenom='Fran�ois',
	@DateNaissance=@date,
	@Mail='Fran�ois.DUPOND@gmail.com',
	@Telephone1='0525636595',
	@Telephone2='0145786933',	
	@NumRue=6,
	@TypeRue='rue',
	@NomRue='Carnot',
	@ComplementAdresse = '2ieme �tage porte gauche',
	@CodePostal='33170',
	@Ville='GRADIGNAN'

Select * from Client;