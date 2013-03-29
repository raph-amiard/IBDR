Use IBDR_SAR
GO

Declare @date DATE
SET @date = '01/01/1960'
EXEC client_creer
	@Civilite='Monsieur',
	@Nom='DUPOND',
	@Prenom='François',
	@DateNaissance=@date,
	@Mail='François.DUPOND@gmail.com',
	@Telephone1='0525636595',
	@Telephone2='0145786933',	
	@NumRue=6,
	@TypeRue='rue',
	@NomRue='Carnot',
	@ComplementAdresse = '2ieme étage porte gauche',
	@CodePostal='33170',
	@Ville='GRADIGNAN'

Select * from Client;