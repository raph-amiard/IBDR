---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : RAHMOUN Imane - SAR,GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
EXEC _Vide_BD
EXEC _Ajout_Client
PRINT 'Avant execution'

select * from Client
Declare @date DATE
SET @date = '01/01/1960'
BEGIN TRY
	EXEC client_creer
		@Civilite='Monsieur',
		@Nom='DUPOND',
		@Prenom='François',
		@DateNaissance=@date,
		@Mail='toto.tata@gmail.com',
		@Telephone1='0525636595',
		@Telephone2='0145786933',	
		@NumRue=6,
		@TypeRue='rue',
		@NomRue='Carnot',
		@ComplementAdresse = '2ieme étage porte gauche',
		@CodePostal='33170',
		@Ville='GRADIGNAN'
END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT 'Ajout de la même personne'
BEGIN TRY
	EXEC client_creer
		@Civilite='Monsieur',
		@Nom='DUPOND',
		@Prenom='François',
		@DateNaissance=@date,
		@Mail='toto.tata@gmail.com',
		@Telephone1='0525636595',
		@Telephone2='0145786933',	
		@NumRue=6,
		@TypeRue='rue',
		@NomRue='Carnot',
		@ComplementAdresse = '2ieme étage porte gauche',
		@CodePostal='33170',
		@Ville='GRADIGNAN'
END TRY
BEGIN CATCH
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH

PRINT 'TEST D''Ajout d''un client avec champs vide'
BEGIN TRY
	EXEC client_creer
		@Civilite='Monsieur',
		@Nom=NULL,
		@Prenom='François',
		@DateNaissance=@date,
		@Mail='toto.tata@gmail.com',
		@Telephone1='0525636595',
		@Telephone2='0145786933',	
		@NumRue=6,
		@TypeRue='',
		@NomRue='Carnot',
		@ComplementAdresse = '2ieme étage porte gauche',
		@CodePostal='33170',
		@Ville='GRADIGNAN'
END TRY
BEGIN CATCH
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH
PRINT 'TEST de contraintes'
BEGIN TRY
	EXEC client_creer
		@Civilite='Monsieur',
		@Nom='DUPON',
		@Prenom='Françoi',
		@DateNaissance=@date,
		@Mail='toto.tata@gmail.com',
		@Telephone1='0525636595',
		@Telephone2='0145786933',	
		@NumRue=6,
		@TypeRue='aaaa',
		@NomRue='Carnot',
		@ComplementAdresse = '2ieme étage porte gauche',
		@CodePostal='33170',
		@Ville='GRADIGNAN'
END TRY
BEGIN CATCH
	PRINT 'ERREUR ATTENDU : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH


PRINT ' '
PRINT 'Fin test'
select * from Client
EXEC _Vide_BD