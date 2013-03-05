IF OBJECT_ID ( 'niveau_relance_sur_retard', 'P' ) IS NOT NULL 
    DROP PROCEDURE niveau_relance_sur_retard;
GO

CREATE PROCEDURE [dbo].[niveau_relance_sur_retard]
AS 
BEGIN
	DECLARE @id_location INT
	DECLARE @dateRetourPrev DATETIME
	DECLARE Retard CURSOR FOR
		SELECT Id, DateRetourPrev FROM Location
		WHERE DateRetourEff is null
	OPEN Retard
	FETCH NEXT FROM Retard
		INTO @id_location, @dateRetourPrev
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @dateRetourPrev < CURRENT_TIMESTAMP
		BEGIN
			IF NOT EXISTS (	
				SELECT * FROM RelanceRetard 
				WHERE LocationId = @id_location
			)
			BEGIN
				INSERT INTO RelanceRetard (Date, LocationId, Niveau) 
				VALUES (CURRENT_TIMESTAMP, @id_location, 1);
			END
			ELSE
			BEGIN
				UPDATE RelanceRetard
                SET Niveau += 1, Date = CURRENT_TIMESTAMP
                WHERE LocationId = @id_location
			END
		END
		FETCH NEXT FROM Retard
			INTO @id_location, @dateRetourPrev
	END
	CLOSE Retard
	DEALLOCATE Retard
END
GO


IF OBJECT_ID ( 'relance_sur_découvert', 'P' ) IS NOT NULL 
    DROP PROCEDURE relance_sur_découvert;
GO
CREATE PROCEDURE [dbo].[relance_sur_découvert] (
	@MinSolde SMALLMONEY
)
AS
BEGIN
	DECLARE @id_abonnement INT
	DECLARE Decouvert CURSOR FOR
		SELECT Id FROM Abonnement
		WHERE Solde < @MinSolde
	OPEN Decouvert
	FETCH NEXT FROM Decouvert
		INTO @id_abonnement
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF NOT EXISTS (	
			SELECT * FROM RelanceDecouvert 
			WHERE AbonnementId = @id_abonnement
		)
		BEGIN
			INSERT INTO RelanceDecouvert (Date, AbonnementId, Niveau) 
			VALUES (CURRENT_TIMESTAMP, @id_abonnement, 1);
		END
		ELSE
		BEGIN
			UPDATE RelanceDecouvert
            SET Niveau += 1, Date = CURRENT_TIMESTAMP
            WHERE AbonnementId = @id_abonnement
		END
		FETCH NEXT FROM Decouvert
			INTO @id_abonnement
	END
	CLOSE Decouvert
	DEALLOCATE Decouvert 
END 
GO

IF OBJECT_ID ( 'echeance_prochaine_abonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE echeance_prochaine_abonnement;
GO
CREATE PROCEDURE [dbo].[echeance_prochaine_abonnement] (
	@DateDiff INT
)
AS
BEGIN
	DECLARE @id_abonnement INT
	DECLARE @dateFIN DATETIME 
	DECLARE AbonementFin CURSOR FOR
		SELECT Id,DateFin FROM Abonnement
		WHERE (DateFin - CURRENT_TIMESTAMP) < @DateDiff and (DateFin - CURRENT_TIMESTAMP) > 0
	OPEN AbonementFin
	FETCH NEXT FROM AbonementFin
		INTO @id_abonnement, @dateFIN
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT('Abonnement ' + CAST(@id_abonnement AS VARCHAR) + ' arrive a son terme le ' + CAST(@dateFIN AS VARCHAR))
		FETCH NEXT FROM AbonementFin
			INTO @id_abonnement, @dateFIN
	END
	CLOSE AbonementFin
	DEALLOCATE AbonementFin
END