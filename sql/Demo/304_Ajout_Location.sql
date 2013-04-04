Use IBDR_SAR
GO

DECLARE @edi_ID INT
DECLARE @abo_ID INT
DECLARE @date_fin_loc DATETIME
SELECT @date_fin_loc = DATEADD(day, 2, CURRENT_TIMESTAMP)

SELECT TOP(1) @edi_ID = Edition.Id from Edition
SELECT TOP(1) @abo_ID = Abonnement.Id from Abonnement

	EXEC compte_reapprovisioner
		@Id = @abo_ID,
		@AjoutSolde = 20000

EXEC dbo.location_ajouter
	@id_abonnement = @abo_ID,
	@id_edition = @edi_ID,
	@date_fin = @date_fin_loc

select @edi_ID, 'Edition' union select @abo_ID, 'Abonnement'
select fs.IdEdition, Location.* from Location
inner join FilmStock as fs
on Location.FilmStockId = fs.Id

