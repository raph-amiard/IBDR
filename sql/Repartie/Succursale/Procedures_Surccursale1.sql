Use IBDR_SAR1
GO


---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure d'ajout de plusieurs FilmStocks     */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.filmstock_ajouter') IS NOT NULL)
  DROP PROCEDURE dbo.filmstock_ajouter
GO
CREATE PROCEDURE dbo.filmstock_ajouter
	@DateArrivee NVARCHAR(32), -- dd mon yyyy hh:mi:ss:mmm(24h)
	@Usure INT,
	@IdEdition INT,
	@Nombre INT

AS
BEGIN
	IF @Nombre < 1
	BEGIN
		RAISERROR('Il faut ajouter au moins un exemplaire!', 11, 1);
		RETURN
	END
	
	IF @DateArrivee = '' OR @DateArrivee = ' '
	BEGIN
		RAISERROR('La date d''arrive d''exemplaires ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @IdEdition)
	BEGIN
		WHILE @Nombre > 0
		BEGIN
			INSERT INTO FilmStock
					   (DateArrivee
					   ,Usure
					   ,IdEdition
					   ,Supprimer)
				 VALUES
					   (convert(datetime,@DateArrivee,103) 
					   ,@Usure
					   ,@IdEdition
					   ,0)
		
			SET @Nombre -= 1	
			PRINT 'Un exemplaire a été ajouté!'				  
		END				   
   END
   ELSE
   BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
   END
END
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure de suppression d'un FilmStock       */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.filmstock_supprimer') IS NOT NULL)
  DROP PROCEDURE dbo.filmstock_supprimer
GO
CREATE PROCEDURE filmstock_supprimer
	@ID_FilmStock INT
AS
BEGIN
	
	IF NOT EXISTS (SELECT *	FROM FilmStock WHERE Id = @ID_FilmStock)
		BEGIN
			RAISERROR('Cet exemplaire n''exite pas!', 11, 1);
			RETURN
		END
		
	IF NOT EXISTS (SELECT * FROM Location WHERE FilmStockId = @ID_FilmStock  AND DateRetourEff IS NULL)
		BEGIN
			DELETE FROM FilmStock WHERE ID = @ID_FilmStock
			PRINT 'Un exemplaire a été supprimé!'
		END
	ELSE
		BEGIN
			UPDATE FilmStock SET Supprimer = 1 WHERE ID = @ID_FilmStock
			RAISERROR('l''exempliare ne peut pas être supprimer, car il est loué!', 11, 1);
		END
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de création d'un client                 */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : RAHMOUN Imane , GOUYOU Ludovic - TA     */
-------------------------------------------------------
IF OBJECT_ID ('dbo.client_creer', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.client_creer;
GO
CREATE PROCEDURE dbo.client_creer
(

    @Civilite          NVARCHAR(10),
	@Nom               NVARCHAR(64),
	@Prenom            NVARCHAR(64),
	@DateNaissance     DATE,
	@Mail              NVARCHAR(128),
	@Telephone1        NVARCHAR(20),
	@Telephone2        NVARCHAR(20),	
	@NumRue		       INT,
	@TypeRue	       NVARCHAR(64),
	@NomRue            NVARCHAR(128),
	@ComplementAdresse NVARCHAR(256),
	@CodePostal        NVARCHAR(10),
	@Ville             NVARCHAR(64)
)
AS
BEGIN
	IF @Civilite IS NULL
	BEGIN
		RAISERROR('La civilite ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Nom IS NULL
	BEGIN
		RAISERROR(' Le nom ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Prenom IS NULL
	BEGIN
		RAISERROR(' Le prenom ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @DateNaissance IS NULL
	BEGIN
		RAISERROR(' La DateNaissance ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Mail IS NULL
	BEGIN
		RAISERROR(' Mail ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Telephone1 IS NULL
	BEGIN
		RAISERROR(' Le numero de téléphone  ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @NumRue IS NULL
	BEGIN
		RAISERROR(' Le numero de la rue  ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @TypeRue IS NULL
	BEGIN
		RAISERROR(' Le type de la rue ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @NomRue IS NULL
	BEGIN
		RAISERROR(' Le nom de la rue ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @CodePostal IS NULL
	BEGIN
		RAISERROR(' Le code postal ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Ville IS NULL
	BEGIN
		RAISERROR(' Le nom de la ville ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Nom LIKE '%[^A-Za-z ''-]%'
	BEGIN
		RAISERROR(' Nom non valide', 9, 1);
		RETURN;
	END
	
	IF @Prenom LIKE '%[^A-Za-z ''-]%'
	BEGIN
		RAISERROR(' Prenom non valide', 9, 1);
		RETURN;
	END
	
	IF @DateNaissance < '01/01/1900'
	BEGIN
		RAISERROR(' Date de	Naissance non valide', 9, 1);
		RETURN;
	END
	
	IF @Civilite LIKE '%[^A-Za-z ''-]%'
	BEGIN
		RAISERROR(' Civilité non valide', 9, 1);
		RETURN;
	END
	
	IF @NomRue LIKE '%[^A-Za-z ''-]%'
	BEGIN
		RAISERROR(' Nom de rue non valide', 9, 1);
		RETURN;
	END
	
	IF @NumRue <= 0
	BEGIN
		RAISERROR(' Numero de rue  non valide', 9, 1);
		RETURN;
	END
	
	IF @TypeRue  NOT IN ('Rue', 'Avenue', 'Passage', 'Impasse', 'Route')
	BEGIN
		RAISERROR(' Type de rue non valide', 9, 1);
		RETURN;
	END
	
	IF @CodePostal NOT LIKE '[0-9][A-Ba-b0-9][0-9][0-9][0-9]'
	BEGIN
		RAISERROR(' Code postal non valide', 9, 1);
		RETURN;
	END
	
	IF @Ville  LIKE '%[^A-Za-z ''-]%'
	BEGIN
		RAISERROR('ville non valide', 9, 1);
		RETURN;
	END
	
	IF @Telephone1 NOT LIKE '0'+replicate('[0-9]',9)
	BEGIN
		RAISERROR('ville non valide', 9, 1);
		RETURN;
	END
	
	IF @Telephone2 NOT LIKE '0'+replicate('[0-9]',9)
	BEGIN
		RAISERROR('ville non valide', 9, 1);
		RETURN;
	END
	
	IF  EXISTS (SELECT *
		FROM Client
		WHERE Nom=@NOM  and  Prenom=@Prenom  and  Mail=@Mail)
	BEGIN
		RAISERROR('Ce client existe deja', 9, 1);
	END
	ELSE
	BEGIN										
		-- Insère le client
		INSERT 	INTO CLIENT
					   (
				Civilite     ,        
				Nom        ,      
				Prenom       ,      
				DateNaissance,     
				Mail          ,    
				Telephone1     ,   
				Telephone2      , 	
				NumRue		,	
				TypeRue		,	
				NomRue           , 
				ComplementAdresse ,
				CodePostal       ,
				Ville             ,
				BlackListe 
				)

				VALUES (	
				@Civilite          ,
				@Nom              ,
				@Prenom            ,
				@DateNaissance     ,
				@Mail              ,
				@Telephone1        ,
				@Telephone2       ,	
				@NumRue		,	
				@TypeRue	,		
				@NomRue          ,  
				@ComplementAdresse, 
				@CodePostal       ,
				@Ville             ,
				0       
				  )
				  
		PRINT 'Client bien ajouté'
	END
END

GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de creation d'un abonnement             */
/* Auteur  : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
/* Testeur : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
-------------------------------------------------------
IF OBJECT_ID ('dbo.abonnement_creer', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.abonnement_creer;
GO
CREATE PROCEDURE dbo.abonnement_creer
(
	@DateDebut DATETIME ,
	@DateFin DATETIME ,
	@NomClient NVARCHAR(64) ,
	@PrenomClient NVARCHAR(64) ,
	@MailClient NVARCHAR(128) ,
	@TypeAbonnement NVARCHAR(32) 

    
)
AS

BEGIN

	IF @DateDebut IS NULL
	BEGIN
		RAISERROR(' La date du debut de l''abonnement ne doit pas être null', 9, 1);
		RETURN;
	END	

	IF @DateFin IS NULL
	BEGIN
		RAISERROR(' La date de fin de l''abonnement ne doit pas être null', 9, 1);
		RETURN;
	END	
	
	IF @NomClient IS NULL
	BEGIN
		RAISERROR(' Le nom du client ne doit pas être null', 9, 1);
		RETURN;
	END	
	
	IF @PrenomClient IS NULL
	BEGIN
		RAISERROR(' Le prenom du client ne doit pas être null', 9, 1);
		RETURN;
	END	
	
	IF @MailClient IS NULL
	BEGIN
		RAISERROR(' Le mail du client ne doit pas être null', 9, 1);
		RETURN;
	END	
	
	IF @TypeAbonnement IS NULL
	BEGIN
		RAISERROR(' Le type de l''abonnement ne doit pas être null', 9, 1);
		RETURN;
	END	
	
	IF  NOT EXISTS (SELECT * FROM dbo.TypeAbonnement WHERE @TypeAbonnement=dbo.TypeAbonnement.Nom)  
	BEGIN
		RAISERROR(' Type d''abonnement non valide', 9, 1);
		RETURN;
	END	
	
	IF  EXISTS (SELECT * FROM dbo.TypeAbonnement WHERE @TypeAbonnement=dbo.TypeAbonnement.Nom AND dbo.TypeAbonnement.estdispo=0)  
	BEGIN
		RAISERROR(' Type d''abonnement non valide', 9, 1);
		RETURN;
	END	
	
	IF @DateDebut < CURRENT_TIMESTAMP
	BEGIN
		RAISERROR(' Date de debut non valide', 9, 1);
		RETURN;
	END
	IF @DateFin <= @DateDebut
	BEGIN
		RAISERROR(' Date fin non valide', 9, 1);
		RETURN;
	END
   
	-- Insère Type Abonnement
	INSERT 	INTO dbo.Abonnement
				   (
			Solde ,
			DateDebut ,
			DateFin ,
			NomClient ,
			PrenomClient ,
			MailClient ,
			TypeAbonnement
			)


			VALUES (	  	
			0, 
			@DateDebut, 
			@DateFin ,
			@NomClient ,
			@PrenomClient, 
			@MailClient ,
			@TypeAbonnement 
			)
	PRINT 'Type d''abonnement'			  
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de réapprovisionnement d'un compte      */
/* Auteur  : RAHMOUN Imane - SAR,GOUYOU Ludovic - TA */
/* Testeur : GOUYOU Ludovic - TA                     */
-------------------------------------------------------
IF OBJECT_ID ( 'dbo.compte_reapprovisioner', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.compte_reapprovisioner;
GO
CREATE PROCEDURE dbo.compte_reapprovisioner
    @Id INT,
	@AjoutSolde SMALLMONEY

AS
	BEGIN
	IF NOT EXISTS (SELECT * FROM Abonnement WHERE Id = @Id) 
	BEGIN
		DECLARE @mess VARCHAR(1000)
		SET @mess = 'Abonnement ' + CONVERT (varchar, @Id) + ' inconnu'
		RAISERROR (@mess, 17, 2)
	END
	UPDATE dbo.Abonnement 
	SET dbo.Abonnement.solde += @AjoutSolde
	WHERE id = @id
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de modification d'un abonnement         */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : RAHMOUN Imane - SAR                     */
-------------------------------------------------------
IF OBJECT_ID ( 'dbo.renouvellement_abonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.renouvellement_abonnement;
GO
CREATE PROCEDURE[dbo].[renouvellement_abonnement]
	@Id INT  ,
    @Solde SMALLMONEY ,
	@DateDebut DATETIME ,
	@DateFin DATETIME ,
	@NomClient NVARCHAR(64) ,
	@PrenomClient NVARCHAR(64) ,
	@MailClient NVARCHAR(128) ,
	@TypeAbonnement NVARCHAR(32) 
AS

BEGIN
IF EXISTS (SELECT * FROM Abonnemet WHERE Abonnement.Id = @Id) 
BEGIN 
UPDATE dbo.Abonnement 
SET 
Abonnement.Solde = @Solde,
Abonnement.DateDebut= @DateDebut,
Abonnement.DateFin = @DateFin,
Abonnement.NomClient = @NomClient,
Abonnement.PrenomClient = @PrenomClient,
Abonnement.MailClient = @MailClient,
Abonnement.TypeAbonnement = @TypeAbonnement 
WHERE 
dbo.Abonnement.Id =@Id
END
ELSE
BEGIN
print 'cet abonnement n''existe pas'
END
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de relance sur retard                   */
/* Auteur  : GOUYOU Ludovic - TA                     */
/* Auteur  : GOUYOU Ludovic - TA                     */
-------------------------------------------------------

IF OBJECT_ID ( 'niveau_relance_sur_retard', 'P' ) IS NOT NULL 
    DROP PROCEDURE niveau_relance_sur_retard;
GO

CREATE PROCEDURE [dbo].[niveau_relance_sur_retard]
AS 
BEGIN
	DECLARE @max INT
	SET @max = 5
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

IF OBJECT_ID ( 'relance_sur_découvert', 'P' ) IS NOT NULL 
    DROP PROCEDURE relance_sur_découvert;
GO
CREATE PROCEDURE [dbo].[relance_sur_découvert]
AS
BEGIN
	DECLARE @MinSolde SMALLMONEY
	SET @MinSolde = 0
	DECLARE @MaxRelance INT
	SET @MaxRelance = 5
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

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Vue des films arrivés                             */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.V_FILMSTOCKS', 'V') IS NOT NULL)
  DROP VIEW dbo.V_FILMSTOCKS
GO
CREATE VIEW dbo.V_FILMSTOCKS
AS
SELECT    *
FROM      dbo.FilmStock
WHERE     (DateArrivee IS NULL)
          OR (DateArrivee >= GETDATE());
GO          

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Fonction retournant les films disponibles         */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.films_disponibles_le') IS NOT NULL)
  DROP FUNCTION dbo.films_disponibles_le
GO
CREATE FUNCTION dbo.films_disponibles_le(@id_edition INT, @date_debut DATETIME, @date_fin DATETIME)
RETURNS TABLE
AS
RETURN
    SELECT * FROM V_FILMSTOCKS vfs
    WHERE vfs.IdEdition = @id_edition
    AND vfs.Id NOT IN (
        SELECT loc.FilmStockId FROM Location loc
        WHERE loc.FilmStockId = vfs.Id
        AND ((@date_debut <= loc.DateRetourPrev AND @date_debut >= loc.DateLocation) 
			 OR
             (@date_fin >= loc.DateLocation AND @date_fin <= loc.DateRetourPrev))
    )
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure pour rendre une location                */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.location_rendre', 'P' ) IS NOT NULL)
  DROP PROCEDURE dbo.location_rendre
GO
CREATE PROCEDURE dbo.location_rendre(@id_filmstock INT)
AS
BEGIN
	-- Variables
    DECLARE @id_compte INT, @id_client INT
    DECLARE @id_location INT
    
    SET @id_location = -1
    
    SELECT @id_location = Id FROM Location
    WHERE FilmStockId = @id_filmstock
    AND DateRetourEff = NULL;
    
    IF @id_location = -1
	BEGIN
		RAISERROR('Pas de location correspondante', 10, 1);
		RETURN
	END

    -- Met à jour la location
    UPDATE Location
    SET DateRetourEff = GETDATE()
    WHERE FilmStockId = @id_filmstock
    AND DateRetourEff = NULL;
    
    PRINT 'Film rendu'
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure privée pour ajouter une location        */
/* NE PAS UTILISER DIRECTEMENT                       */
/* Utiliser location_ajouter ou reservation_ajouter  */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo._ajouter_location', 'P' ) IS NOT NULL)
  DROP PROCEDURE dbo._ajouter_location
GO
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
    DECLARE @prix_loc SMALLMONEY
    
	SET @id_filmstock = -1
    -- Récupère un id_filmstock disponible de l'édition
    SELECT TOP(1) @id_filmstock = Id
    FROM dbo.films_disponibles_le(@id_edition, @date_debut, @date_fin)
    IF @id_filmstock = -1
    BEGIN
		RAISERROR('Pas d''exemplaire disponible pour cette édition et cette plage de temps !', 9, 1)
		RETURN
	END
            
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

    -- Calculer la durée de la location
    SELECT @duree_loc = DATEDIFF(second, @date_debut, @date_fin)

    -- Calcule le prix final de la location
    -- TODO : This is todo biatch
    SET @montant = @prix_loc * (@duree_loc / (24*60*60))
    
    -- Si le client ne peut louer autant de jours
    IF @duree_loc > @duree_max_loc
    BEGIN
        RAISERROR('Le client ne peut louer autant de temps car son abonnement ne le permet pas', 9, 1)
        RETURN
        PRINT('Nombre de jour max ' + CAST(@nb_max_jour_loc AS VARCHAR))
    END
    
    -- Si le client n'a pas l'âge requis
    ELSE IF @age_interdiction_film > @age_client
        RAISERROR('Le client n''a pas l''age requis pour louer ce film', 9, 1) 
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
		PRINT 'Location ajoutée'
		RETURN @id_filmstock
	END
END
GO
-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure pour confirmer une location             */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.location_confirmer', 'P' ) IS NOT NULL)
  DROP PROCEDURE dbo.location_confirmer
GO
CREATE PROCEDURE dbo.location_confirmer(@id_location INT)
AS
BEGIN
	IF (SELECT COUNT(*) FROM Location WHERE Id = @id_location) < 1
	BEGIN
		RAISERROR('Pas de location correspondante', 10, 1)
		RETURN
	END
	
    -- TODO : Ajouter check temps, impossible de confirmer réservation en dehors d'un intervalle défini
    UPDATE Location
    SET Confirmee = 1
    WHERE Id = @id_location
    
    PRINT 'Location confirmée'
END
GO
-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure pour ajouter une location               */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.location_ajouter', 'P' ) IS NOT NULL)
  DROP PROCEDURE dbo.location_ajouter
GO
CREATE PROCEDURE dbo.location_ajouter (
	@id_abonnement INT, 
    @id_edition INT,
    @date_fin DATETIME
)
AS
BEGIN
	DECLARE @date_now DATETIME
	SET @date_now = DATEADD(second, 1, CURRENT_TIMESTAMP)
    EXEC dbo._ajouter_location @id_abonnement, @id_edition, @date_now, @date_fin, 1
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure pour ajouter une reservation            */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.reservation_ajouter') IS NOT NULL)
  DROP PROCEDURE dbo.reservation_ajouter
GO
CREATE PROCEDURE dbo.reservation_ajouter (
	@id_abonnement INT, 
    @id_edition INT,
    @date_debut DATETIME,
    @date_fin DATETIME
)
AS
BEGIN
    EXEC dbo._ajouter_location @id_abonnement, @id_edition, @date_debut, @date_fin, 0
END
GO
