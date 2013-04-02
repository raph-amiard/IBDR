Use IBDR_SAR
GO

DECLARE @edi_ID INT
DECLARE @abo_ID INT
DECLARE @date_debut_res_2 DATETIME
DECLARE @date_fin_res_1 DATETIME
SELECT @date_debut_res_2 = DATEADD(day, 5, CURRENT_TIMESTAMP)
SELECT @date_fin_res_1 = DATEADD(day, 8, CURRENT_TIMESTAMP)

SELECT TOP(1) @edi_ID = Edition.Id from Edition
SELECT TOP(1) @abo_ID = Abonnement.Id from Abonnement

EXEC dbo.reservation_ajouter
	@id_abonnement = @abo_ID,
	@id_edition = @edi_ID,
	@date_debut = @date_debut_res_2,
	@date_fin = @date_fin_res_1

select @edi_ID, 'Edition' union select @abo_ID, 'Abonnement'
select fs.IdEdition, Location.* from Location
inner join FilmStock as fs
on Location.FilmStockId = fs.Id