Use IBDR_SAR
GO

EXEC type_abonnement_creer 
	@Nom = 'Complet' ,
	@PrixMensuel = 100 ,
	@PrixLocation =0.05 ,
	@MaxJoursLocation = 5 ,
	@NbMaxLocations = 10 ,
	@PrixRetard = 5 ,
	@DureeEngagement = 720 

Select * from TypeAbonnement;