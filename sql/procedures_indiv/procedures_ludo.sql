Use IBDR_SAR;
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de nettoyage pour les réservations non   */
/* honorées                                          */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF OBJECT_ID ( 'nettoyage_Reservation', 'P' ) IS NOT NULL 
    DROP PROCEDURE nettoyage_Reservation;
GO

CREATE PROCEDURE [dbo].[nettoyage_Reservation]
AS 
BEGIN
	DELETE Location
	WHERE DateLocation < CURRENT_TIMESTAMP and Confirmee = 0;
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de nettoyage pour les clients           */
/* blacklistés                                       */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF (OBJECT_ID('dbo.films_disponibles_le_reser') IS NOT NULL)
  DROP FUNCTION dbo.films_disponibles_le_reser
GO
CREATE FUNCTION dbo.films_disponibles_le_reser(@id_edition INT, @date_debut DATETIME, @date_fin DATETIME)
RETURNS TABLE
AS
RETURN
    SELECT fs.* FROM FilmStock as fs
    WHERE fs.IdEdition = @id_edition
    and fs.DateArrivee <= @date_debut
    and fs.Supprimer = 0
    -- on enléve les films dont les comptes sont bloqués (car on va aussi les supprimers)
    and fs.Id not in (
		SELECT l.FilmStockId FROM Location as l 
		inner join Abonnement as a
		 on l.AbonnementId = a.Id
		inner join Client as c
		 on a.NomClient = c.Nom and a.MailClient = c.Mail and a.PrenomClient = c.Prenom
		WHERE l.Confirmee = 1 and l.DateRetourPrev <= CURRENT_TIMESTAMP and l.DateRetourEff is null
		 and c.BlackListe = 1
	)
	-- on enléve les films dont les dates de la réservation sont déja occupé
	and fs.Id not in (
        SELECT loc.FilmStockId FROM Location as loc
        WHERE loc.FilmStockId = fs.Id
        and ((@date_debut <= loc.DateRetourPrev AND @date_debut >= loc.DateLocation) 
			 OR
             (@date_fin >= loc.DateLocation AND @date_fin <= loc.DateRetourPrev))
    )
		
GO

-- retourne les reservations et l'id de l'édition concernée qui doivent être mise à jour
IF OBJECT_ID ('nettoyage_Blacklist_Reservation_concern', 'V') IS NOT NULL
    DROP VIEW nettoyage_Blacklist_Reservation_concern ;
GO
CREATE VIEW [dbo].[nettoyage_Blacklist_Reservation_concern]
AS
	SELECT DISTINCT l2.*, fs.IdEdition FROM Location	as l
		inner join FilmStock as fs
		 on l.FilmStockId = fs.Id
		inner join Abonnement as a
		 on l.AbonnementId = a.Id
		inner join Client as c
		 on a.NomClient = c.Nom and a.MailClient = c.Mail and a.PrenomClient = c.Prenom
		 -- on vérifie que les resevations selectionnées ne concernent pas les des clients blacklistés
		inner join Location as l2
		 on l2.FilmStockId = fs.Id
		inner join Abonnement as a2
		 on l2.AbonnementId = a2.Id
		inner join Client as c2
		 on a2.NomClient = c2.Nom and a2.MailClient = c2.Mail and a2.PrenomClient = c2.Prenom
		where c.BlackListe = 1 and l2.Confirmee = 0 and c2.BlackListe = 0 and l.DateRetourEff is null
GO

-- retourne les locations dont les films stock vont être supprimés
IF OBJECT_ID ('nettoyage_Blacklist_Location_a_suppr', 'V') IS NOT NULL
    DROP VIEW nettoyage_Blacklist_Location_a_suppr ;
GO
CREATE VIEW [dbo].[nettoyage_Blacklist_Location_a_suppr]
AS
	SELECT DISTINCT l2.* FROM Location	as l
		inner join FilmStock as fs
		 on l.FilmStockId = fs.Id
		inner join Abonnement as a
		 on l.AbonnementId = a.Id
		inner join Client as c
		 on a.NomClient = c.Nom and a.MailClient = c.Mail and a.PrenomClient = c.Prenom
		inner join Location as l2
		 on l2.FilmStockId = fs.Id
		where c.BlackListe = 1 and l.DateRetourEff is null
GO

-- retourne les films stock qui serons jamais ramené
IF OBJECT_ID ('nettoyage_Blacklist_FS_a_suppr', 'V') IS NOT NULL
    DROP VIEW nettoyage_Blacklist_FS_a_suppr ;
GO
CREATE VIEW [dbo].[nettoyage_Blacklist_FS_a_suppr]
AS
	SELECT DISTINCT fs.* FROM FilmStock as fs
		inner join Location as l
		 on l.FilmStockId = fs.Id
		inner join Abonnement as a
		 on l.AbonnementId = a.Id
		inner join Client as c
		 on a.NomClient = c.Nom and a.MailClient = c.Mail and a.PrenomClient = c.Prenom
		where c.BlackListe = 1 and l.DateRetourEff is null
GO

-- returne les films a supprimer (on se base sur le flag et le fait qu'ilq n'ont pas de location
IF OBJECT_ID ('nettoyage_Blacklist_FS_a_suppr_l', 'V') IS NOT NULL
    DROP VIEW nettoyage_Blacklist_FS_a_suppr_l ;
GO
CREATE VIEW [dbo].[nettoyage_Blacklist_FS_a_suppr_l]
AS
	SELECT DISTINCT fs.Id FROM FilmStock as fs
		left outer join Location as l
		 on l.FilmStockId = fs.Id
		where l.Id is null and fs.Supprimer = 1
GO

IF OBJECT_ID ( 'nettoyage_Blacklist', 'P' ) IS NOT NULL 
    DROP PROCEDURE nettoyage_Blacklist;
GO

CREATE PROCEDURE [dbo].[nettoyage_Blacklist]
AS 
BEGIN
	DECLARE @id_location INT
	DECLARE @IdEdition INT
	DECLARE @FilmStockId INT
	DECLARE @dateRetourPrev DATETIME
	DECLARE @DateLocation DATETIME
	DECLARE @newFilmStockId INT
	
	
	DECLARE reservation_a_modifier CURSOR FOR
		SELECT Id, FilmStockId, DateLocation, DateRetourPrev, IdEdition 
		from nettoyage_Blacklist_Reservation_concern;
	OPEN reservation_a_modifier
	FETCH NEXT FROM reservation_a_modifier
		INTO @id_location, @FilmStockId, @DateLocation, @DateRetourPrev, @IdEdition
	WHILE @@FETCH_STATUS = 0
	BEGIN
		SET @newFilmStockId = -1;
		SELECT TOP(1) @newFilmStockId = Id
		FROM films_disponibles_le_reser(@IdEdition, @DateLocation, @dateRetourPrev)
		IF @newFilmStockId = -1
		BEGIN
			PRINT 'La location ' + CAST(@id_location AS VARCHAR) + 'n'' as pas put être reporté.';
		END
		ELSE
		BEGIN
			UPDATE Location
			SET FilmStockId = @newFilmStockId
			where Id = @id_location
		END
		FETCH NEXT FROM reservation_a_modifier
			INTO @id_location, @FilmStockId, @DateLocation, @DateRetourPrev, @IdEdition
	END
	CLOSE reservation_a_modifier
	DEALLOCATE reservation_a_modifier
	
	-- on va supprimer les filmsStock qui ne serons pas rendus (on met le flag a vrai)
	UPDATE FilmStock
	SET Supprimer = 1
	FROM FilmStock as fs
	inner join nettoyage_Blacklist_FS_a_suppr as fsn
	on fs.Id = fsn.Id
	
	-- on va supprimer les locations et reservation concernant ces films stock
	DELETE Location 
	From Location
	inner join nettoyage_Blacklist_Location_a_suppr as nbls
	on nbls.Id = Location.Id
	
	-- on va supprimer les filmsStock dont le flag supprime est a 1 et dont il n'a pas de location
	DELETE FilmStock 
	From FilmStock
	inner join nettoyage_Blacklist_FS_a_suppr_l as nbls
	on nbls.Id = FilmStock.Id
	
	-- on va supprimer les locations concernant les abonnement blacklistés
	DELETE Location 
	From Location
	inner join Abonnement
	on Location.AbonnementId = Abonnement.Id
	inner join Client
	on Abonnement.NomClient = Client.Nom and Abonnement.MailClient = Client.Mail and Abonnement.PrenomClient = Client.Prenom
	where Client.BlackListe = 1
	
	-- on va supprimer les comptes concernant les abonnement blacklistés
	DELETE Abonnement 
	From Abonnement
	inner join Client
	on Abonnement.NomClient = Client.Nom and Abonnement.MailClient = Client.Mail and Abonnement.PrenomClient = Client.Prenom
	where Client.BlackListe = 1
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

IF OBJECT_ID ( 'niveau_relance_sur_retard_out', 'P' ) IS NOT NULL 
    DROP PROCEDURE niveau_relance_sur_retard_out;
GO
CREATE PROCEDURE [dbo].[niveau_relance_sur_retard_out]
	@id_location INT
AS
Begin
	DECLARE @id_abonnement INT
	DECLARE @NomClient NVARCHAR(64)
	DECLARE @MailClient NVARCHAR(128)
	DECLARE @PrenomClient NVARCHAR(64)
	DECLARE @Civilite NVARCHAR(64)
	DECLARE @FilmTitreVF NVARCHAR(128)

	
	SELECT @NomClient = a.NomClient,
		@PrenomClient = a.PrenomClient,
		@MailClient = a.MailClient,
		@Civilite = c.Civilite,
		@id_abonnement = a.Id,
		@FilmTitreVF = e.FilmTitreVF
		from Location as l
		inner join Abonnement as a
		on l.AbonnementId = a.Id
		inner join Client as c
		on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient
		inner join FilmStock as fs 
		on l.FilmStockId = fs.Id
		inner join Edition as e
		on fs.IdEdition = e.Id
		where l.Id = @id_location;
		
	PRINT 'TO : ' + @MailClient + ' : '
	PRINT '   ' + @Civilite + ' ' + @NomClient + ' ' + @PrenomClient
	PRINT '     Vous ne nous avez toujours pas rendut le film : ' + @FilmTitreVF + '.'
	PRINT '     Merci de nous le ramener.'
End
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
				EXEC niveau_relance_sur_retard_out @id_location;
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
					EXEC niveau_relance_sur_retard_out @id_location;
					PRINT '     Vous êtes maintenant blacklisté.'
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
					EXEC niveau_relance_sur_retard_out @id_location;
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

IF OBJECT_ID ( 'relance_sur_découvert_out', 'P' ) IS NOT NULL 
    DROP PROCEDURE relance_sur_découvert_out;
GO
CREATE PROCEDURE [dbo].[relance_sur_découvert_out]
	@id_abonnement INT
AS
Begin
	DECLARE @NomClient NVARCHAR(64)
	DECLARE @MailClient NVARCHAR(128)
	DECLARE @PrenomClient NVARCHAR(64)
	DECLARE @Civilite NVARCHAR(64)

	
	SELECT @NomClient = a.NomClient,
		@PrenomClient = a.PrenomClient,
		@MailClient = a.MailClient,
		@Civilite = c.Civilite
		from Abonnement as a
		inner join Client as c
		on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient 
		where a.Id = @id_abonnement;
		
	PRINT 'TO : ' + @MailClient + ' : '
	PRINT '   ' + @Civilite + ' ' + @NomClient + ' ' + @PrenomClient
	PRINT '     Votre abonnement : ' + CAST(@id_abonnement AS VARCHAR) + ' est à decouvert.'
End
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
			EXEC relance_sur_découvert_out @id_abonnement;
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
			EXEC relance_sur_découvert_out @id_abonnement;
			PRINT '     Vous êtes maintenant blacklisté.'
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
			EXEC relance_sur_découvert_out @id_abonnement;
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
/* Procédure de relance échéance abonnement          */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF OBJECT_ID (N'dbo.DateDiff_echeance_prochaine', N'FN') IS NOT NULL
    DROP FUNCTION dbo.DateDiff_echeance_prochaine;
GO
CREATE FUNCTION [dbo].[DateDiff_echeance_prochaine]() Returns int
AS
Begin
	Return (5);
End;
GO

IF OBJECT_ID ( 'echeance_prochaine_abonnement_out', 'P' ) IS NOT NULL 
    DROP PROCEDURE echeance_prochaine_abonnement_out;
GO
CREATE PROCEDURE [dbo].[echeance_prochaine_abonnement_out]
	@id_abonnement INT
AS
Begin
	DECLARE @NomClient NVARCHAR(64)
	DECLARE @MailClient NVARCHAR(128)
	DECLARE @PrenomClient NVARCHAR(64)
	DECLARE @Civilite NVARCHAR(64)

	
	SELECT @NomClient = a.NomClient,
		@PrenomClient = a.PrenomClient,
		@MailClient = a.MailClient,
		@Civilite = c.Civilite
		from Abonnement as a
		inner join Client as c
		on c.Nom = a.NomClient and c.Prenom = a.PrenomClient and c.Mail = a.MailClient 
		where a.Id = @id_abonnement;
		
	PRINT 'TO : ' + @MailClient + ' : '
	PRINT '   ' + @Civilite + ' ' + @NomClient + ' ' + @PrenomClient
	PRINT '     Votre abonnement : ' + CAST(@id_abonnement AS VARCHAR) + ' arrive à échéance prochainement.'
End
GO

IF OBJECT_ID ( 'echeance_prochaine_abonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE echeance_prochaine_abonnement;
GO
CREATE PROCEDURE [dbo].[echeance_prochaine_abonnement]
AS
BEGIN
	DECLARE @id_abonnement INT
	DECLARE @DateDiff INT
	SELECT @DateDiff = dbo.DateDiff_echeance_prochaine();
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
		exec echeance_prochaine_abonnement_out @id_abonnement;
		FETCH NEXT FROM AbonementFin
			INTO @id_abonnement, @dateFIN
	END
	CLOSE AbonementFin
	DEALLOCATE AbonementFin
END
GO