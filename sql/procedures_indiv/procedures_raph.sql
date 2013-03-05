CREATE VIEW dbo.V_FILMSTOCKS
AS
SELECT    *
FROM      dbo.FilmStock
WHERE     (DateArrivee IS NULL)
          OR (DateArrivee >= GETDATE());

CREATE FUNCTION dbo.films_disponibles_le(@id_edition INT, @date_debut DATETIME, @date_fin DATETIME)
RETURNS TABLE
AS
BEGIN
    SELECT * FROM V_FILMSTOCKS vfs
    WHERE vfs.IdEdition = @id_edition
    AND vfs.Id NOT IN (
        SELECT loc.FilmStockId FROM Location loc
        WHERE loc.FilmStockId = Id
        AND ((@date_debut <= loc.DateRetourPrev) OR
             (@date_fin >= loc.DateLocation))
    )
END

CREATE PROCEDURE dbo.rendre_location(@id_filmstock INT)
AS
BEGIN
	-- Variables
    DECLARE @id_compte INT, @id_client INT
    DECLARE @id_location INT
    
    -- Met à jour la location
    UPDATE Location
    SET DateRetourEff = GETDATE()
    WHERE FilmStockId = @id_filmstock
    AND DateRetourEff = NULL;
END

CREATE PROCEDURE dbo._ajouter_location (
	@id_abonnement INT, 
    @id_edition INT,
    @date_debut DATETIME,
    @date_fin DATETIME,
    @confirmee BIT
)
AS
BEGIN
    -- Variables
    DECLARE @age_interdiction_film INT
    DECLARE @id_filmstock INT
    DECLARE @nb_max_jour_loc INT
    DECLARE @duree_max_loc INT
    DECLARE @duree_loc INT
    DECLARE @montant MONEY
    DECLARE @age_client INT
    

    -- Récupère un id_filmstock disponible de l'édition
    SELECT TOP(1) @id_filmstock = id_filmstock
    FROM dbo.films_disponibles_le(@id_edition, @date_debut, @date_fin)
            
    -- Récupère :
    -- le prix d'une location, 
    -- le nombre de jours maximum de location
    SELECT @prix_loc = ta.PrixLocation, 
           @nb_max_jour_loc = ta.MaxJoursLocation
    FROM TypeAbonnement ta
    WHERE ta.Nom = (SELECT TypeAbonnement FROM Abonnement WHERE Id = @id_abonnement)
    SET @duree_max_loc = @nb_max_jour_loc * 24 * 60 * 60

    SELECT @age_client = (DATEPART(year, getdate()) - DATEPART(year, c.DateNaissance))
    FROM Client c, Abonnement a
    WHERE c.Nom = a.NomClient AND c.Prenom = a.PrenomClient AND c.Mail = a.MailClient
    AND a.Id = @id_abonnement;

    SELECT @age_interdiction_film = AgeInterdiction
    FROM Edition
    WHERE Id = @id_edition;

    -- Calcule le prix final de la location
    -- TODO : This is todo biatch
    SET @montant = @prix_loc_final * @nb_jours_prevus

    -- Calculer la durée de la location
    SELECT @duree_loc = DATEDIFF(second, @date_debut, date_fin)

    -- Si le client ne peut louer autant de jours
    IF @duree_loc > @duree_max_loc
    BEGIN    	
        RAISERROR('Le client ne peut louer autant de temps car son abonnement ne le permet pas', 16, 1)
        PRINT('Nombre de jour max ' + CAST(@nb_max_jour_loc AS VARCHAR))
    END
    
    -- Si le client n'a pas l'âge requis
    ELSE IF @age_interdiction_film > @age_client
        RAISERROR('Le client n''a pas l''age requis pour louer ce film', 16, 1)    
    
    ELSE
    BEGIN                
        -- Créer la location
        INSERT INTO Location (	AbonnementId,
                                DateLocation,
                                DateRetourPrev,
                                FilmStockId,
                                Confirmee)
                    VALUES   (	@id_abonnement,
                                @date_debut,
                                @date_fin,
                                @id_filmstock,
                                @confirmee)
	END
END

CREATE PROCEDURE dbo.confirmer_location(@id_location INT)
AS
BEGIN
    -- TODO : Ajouter check temps, impossible de confirmer réservation en dehors d'un intervalle défini
    UPDATE Location
    SET Confirmee = 1
    WHERE Id = @id_location
END

CREATE PROCEDURE dbo.ajouter_location (
	@id_abonnement INT, 
    @id_edition INT,
    @date_fin DATETIME,
)
AS
BEGIN
    CALL dbo._ajouter_location(@id_abonnement, @id_edition, getdate(), @date_fin, 1)
END

CREATE PROCEDURE dbo.ajouter_reservation (
	@id_abonnement INT, 
    @id_edition INT,
    @date_debut DATETIME,
    @date_fin DATETIME,
)
AS
BEGIN
    CALL dbo._ajouter_location(@id_abonnement, @id_edition, @date_debut, @date_fin, 0)
END
