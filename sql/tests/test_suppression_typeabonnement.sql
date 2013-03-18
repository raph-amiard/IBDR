---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : RAHMMOUN Imane - SAR , GOUYOUY Ludovic - TA					  */
---------------------------------------------------------------------------------
USE IBDR_SAR
GO

EXEC _Vide_BD
EXEC _Ajout_Abonnement
PRINT 'Avant execution'
INSERT INTO [dbo].[TypeAbonnement] ([Nom], [PrixMensuel], [PrixLocation], [MaxJoursLocation], [NbMaxLocations], [PrixRetard], [DureeEngagement],[estdispo]) VALUES (N'ClassicNew', CAST(20.0000 AS SmallMoney), CAST(1.0000 AS SmallMoney), 10, 4, CAST(10.0000 AS SmallMoney), 31,1)


select TypeAbonnement.Nom, TypeAbonnement.estdispo, Abonnement.Id, Abonnement.NomClient, Abonnement.PrenomClient 
	from TypeAbonnement 
	left outer join Abonnement 
	on TypeAbonnement.Nom = Abonnement.TypeAbonnement

BEGIN TRY
	EXEC type_abonnement_supprimer 
	@Nom = 'Classic' 
	END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH
PRINT ' '

BEGIN TRY
	EXEC type_abonnement_supprimer 
	@Nom = 'ClassicNew' 
	END TRY
BEGIN CATCH
	PRINT 'ERREUR : ' + CONVERT (varchar, ERROR_NUMBER()) + ' : ' + ERROR_MESSAGE();
END CATCH
PRINT ' '

PRINT 'Fin Test'
select TypeAbonnement.Nom, TypeAbonnement.estdispo, Abonnement.Id, Abonnement.NomClient, Abonnement.PrenomClient 
	from TypeAbonnement 
	left outer join Abonnement 
	on TypeAbonnement.Nom = Abonnement.TypeAbonnement
EXEC _Vide_BD