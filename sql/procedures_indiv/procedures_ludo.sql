Use IBDR_SAR;
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de nettoyage pour les réservation non   */
/* honorées                                          */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF OBJECT_ID ( 'nottoyage_Reservation', 'P' ) IS NOT NULL 
    DROP PROCEDURE nottoyage_Reservation;
GO

CREATE PROCEDURE [dbo].[nottoyage_Reservation]
AS 
BEGIN
	DELETE Location
	WHERE DateLocation < CURRENT_TIMESTAMP and Confirmee = 0;
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de relance sur retard                   */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF OBJECT_ID (N'dbo.maxRelanceRetard', N'FN') IS NOT NULL
    DROP FUNCTION dbo.maxRelanceRetard;
GO
CREATE FUNCTION [dbo].[maxRelanceRetard]() Returns int
AS
Begin
	Return (5);
End;
GO

IF OBJECT_ID ( 'niveau_relance_sur_retard', 'P' ) IS NOT NULL 
    DROP PROCEDURE niveau_relance_sur_retard;
GO

CREATE PROCEDURE [dbo].[niveau_relance_sur_retard]
AS 
BEGIN
	DECLARE @max INT
	SELECT @max = dbo.maxRelanceRetard();
	DECLARE @id_location INT
	DECLARE @dateRetourPrev DATETIME
	DECLARE Retard CURSOR FOR
		SELECT Id, DateRetourPrev FROM Location
		WHERE DateRetourEff is null and Confirmee = 1
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
				IF EXISTS (
					SELECT * from RelanceRetard 
					WHERE LocationId = @id_location and Niveau >= @max
				)
				BEGIN
					IF NOT EXISTS (SELECT * from Client as c 
					inner join Abonnement as a 
					on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient
					inner join Location as l 
					on a.Id = l.AbonnementId
					where c.BlackListe = 1 and l.Id = @id_location
					)
					BEGIN
					UPDATE Client
					SET BlackListe = 1
					from Client as c
					inner join Abonnement as a 
					on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient
					inner join Location as l
					on a.Id = l.AbonnementId
					where l.Id = @id_location
					END
				END
				ELSE
				BEGIN
					UPDATE RelanceRetard
					SET Niveau += 1, Date = CURRENT_TIMESTAMP
					WHERE LocationId = @id_location
				END
			END
		END
		FETCH NEXT FROM Retard
			INTO @id_location, @dateRetourPrev
	END
	CLOSE Retard
	DEALLOCATE Retard
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de relance sur decouvert                */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF OBJECT_ID (N'dbo.maxRelanceDécouvert', N'FN') IS NOT NULL
    DROP FUNCTION dbo.maxRelanceDécouvert;
GO
CREATE FUNCTION [dbo].[maxRelanceDécouvert]() Returns int
AS
Begin
	Return (5);
End;
GO

IF OBJECT_ID (N'dbo.MinSoldeDécouvert', N'FN') IS NOT NULL
    DROP FUNCTION dbo.MinSoldeDécouvert;
GO
CREATE FUNCTION [dbo].[MinSoldeDécouvert]() Returns int
AS
Begin
	Return (0);
End;
GO

IF OBJECT_ID ( 'relance_sur_découvert', 'P' ) IS NOT NULL 
    DROP PROCEDURE relance_sur_découvert;
GO
CREATE PROCEDURE [dbo].[relance_sur_découvert]
AS
BEGIN
	DECLARE @MinSolde SMALLMONEY
	SELECT @MinSolde = dbo.MinSoldeDécouvert();
	DECLARE @MaxRelance INT
	SELECT @MaxRelance = dbo.maxRelanceDécouvert();
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
			IF EXISTS (
			SELECT * from RelanceDecouvert 
			WHERE AbonnementId = @id_abonnement and Niveau >= @MaxRelance
		)
		BEGIN
			IF NOT EXISTS (SELECT * from Client as c 
			inner join Abonnement as a 
			on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient
			where c.BlackListe = 1 and a.Id = @id_abonnement
			)
			BEGIN
			UPDATE Client
			SET BlackListe = 1
			from Client as c
			inner join Abonnement as a 
			on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient
			where a.Id = @id_abonnement
			END
		END
		ELSE
		BEGIN
			UPDATE RelanceDecouvert
            SET Niveau += 1, Date = CURRENT_TIMESTAMP
            WHERE AbonnementId = @id_abonnement
			END
		END
		FETCH NEXT FROM Decouvert
			INTO @id_abonnement
	END
	CLOSE Decouvert
	DEALLOCATE Decouvert 
END 
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de relace sur decouvert                 */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------

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
		SELECT Abonnement.Id, Abonnement.DateFin FROM Abonnement
		inner join Client
		on Abonnement.NomClient = Client.Nom
		and Abonnement.PrenomClient = Client.Prenom
		and Abonnement.MailClient = Client.Mail
		WHERE DATEDIFF(day, CURRENT_TIMESTAMP, DateFin) < @DateDiff 
			and DATEDIFF(day, CURRENT_TIMESTAMP, DateFin) > 0
			and Client.BlackListe = 0
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
GO