Use IBDR_SAR
GO



--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure pour ajouter une Edition           */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_creer') IS NOT NULL)
  DROP PROCEDURE dbo.edition_creer
GO
CREATE PROCEDURE dbo.edition_creer
	@FilmTitreVF NVARCHAR(128),
	@FilmAnneeSortie NVARCHAR(5),
	@Duree NVARCHAR(9),
	@DateSortie NVARCHAR(11),
	@Support NVARCHAR(32),
	@Couleur BIT,
	@Pays NVARCHAR(64),
	@NomEdition NVARCHAR(256),
	@AgeInterdiction INT,
	@ListEditeurs NVARCHAR(640),
	@ListLangueAudio NVARCHAR(640),
	@ListLangueSousTitres NVARCHAR(640)
	

AS
BEGIN

	IF NOT EXISTS (SELECT *	FROM Film WHERE TitreVF = @FilmTitreVF AND AnneeSortie = @FilmAnneeSortie )
	BEGIN
		RAISERROR('Ce film n''existe pas dans la base donnée!', 11, 1);
		RETURN
	END
	
	IF @NomEdition = '' OR @NomEdition = ' '
	BEGIN
		RAISERROR('Le nom d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE NomEdition = @NomEdition)
	BEGIN
		RAISERROR('Existe déjà une edition avec ce nom!', 11, 1);
		RETURN
	END
	
	IF @Duree = '' OR @Duree = ' '
	BEGIN
		RAISERROR('La duree d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF @DateSortie = '' OR @DateSortie = ' '
	BEGIN
		RAISERROR('La date de sortie d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF @Support = '' OR @Support = ' '
	BEGIN
		RAISERROR('Le support d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END

	IF NOT EXISTS (SELECT *	FROM Pays WHERE Nom = @Pays )
	BEGIN
		RAISERROR('Ce pays n''existe pas dans la base donnée!', 11, 1);
		RETURN
	END
	
	IF @AgeInterdiction = '' OR @AgeInterdiction = ' '
	BEGIN
		RAISERROR('L''age d''interdiction d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
    DECLARE @vide INT
    SET @vide = 1
    
    /** Vérifier s'il y a 'Editeur' **/
    IF CHARINDEX('|', @ListEditeurs) = 0
	BEGIN
		RAISERROR('Il faut ajouter au moins un editeur pour ajouter une edition!', 11, 1);
		SET @vide = 0
		RETURN
	END
	IF CHARINDEX('|',@ListEditeurs) <> 1
	BEGIN
		SET @ListEditeurs = '|' + @ListEditeurs
	END

	IF CHARINDEX('|',@ListEditeurs, len(@ListEditeurs)) = 0
	BEGIN
		SET @ListEditeurs = @ListEditeurs +'|'
	END
	
	/** Vérifier s'il y a 'LangueAudio' **/
	IF CHARINDEX('|', @ListEditeurs) = 0
	BEGIN
		RAISERROR('Il faut ajouter au moins une langue d''audio pour ajouter une edition!', 11, 1);
		SET @vide = 0
		RETURN
	END
	IF CHARINDEX('|',@ListLangueAudio) <> 1
	BEGIN
		SET @ListLangueAudio = '|' + @ListLangueAudio
	END

	IF CHARINDEX('|',@ListLangueAudio, len(@ListLangueAudio)) = 0
	BEGIN
		SET @ListLangueAudio = @ListLangueAudio +'|'
	END
	
	/** Vérifier s'il y a 'LangueSousTitres' **/
	IF CHARINDEX('|', @ListLangueSousTitres) = 0
	BEGIN
		RAISERROR('Il faut ajouter au moins une langue de sous-titres pour ajouter une edition!', 11, 1);
		SET @vide = 0
		RETURN
	END
	IF CHARINDEX('|',@ListLangueSousTitres) <> 1
	BEGIN
		SET @ListLangueSousTitres = '|' + @ListLangueSousTitres
	END

	IF CHARINDEX('|',@ListLangueSousTitres, len(@ListLangueSousTitres)) = 0
	BEGIN
		SET @ListLangueSousTitres = @ListLangueSousTitres +'|'
	END
	
	DECLARE @ID_Edition INT
	DECLARE @ERROR_LANGUE INT
	DECLARE @ROWCOUNT INT
	SET @ROWCOUNT = 0
	
	BEGIN TRAN ADD_EDITION
		IF (@vide=1)
		BEGIN 
			INSERT INTO Edition
					   (FilmTitreVF
					   ,FilmAnneeSortie
					   ,Duree
					   ,DateSortie
					   ,Support
					   ,Couleur
					   ,Pays
					   ,NomEdition
					   ,AgeInterdiction
					   , Supprimer)
				 VALUES
						(@FilmTitreVF,
						convert(smallint,@FilmAnneeSortie),
						convert(time,@Duree,108),
						convert(date,@DateSortie,103),
						@Support,
						@Couleur,
						@Pays,
						@NomEdition,
						@AgeInterdiction,
						0)
			
			
			SET @ROWCOUNT = @@ROWCOUNT
			
			IF (@ROWCOUNT = 1)
			BEGIN
				SET @ID_Edition = @@IDENTITY
			END
		END
		
		DECLARE @index INT, @fin INT
		SET @index = 1
		
		WHILE @index <> LEN(@ListEditeurs) AND @vide=1 AND @ROWCOUNT = 1
		BEGIN
			DECLARE @NomEditeur NVARCHAR(64)
			
			SET @fin = CHARINDEX('|', @ListEditeurs, @index+1)
			
			SET @NomEditeur = LTRIM(SUBSTRING(@ListEditeurs , @index+1, @fin - @index-1))
			
			IF NOT EXISTS (SELECT *
					FROM Editeur
					WHERE Nom = @NomEditeur)
			BEGIN

				INSERT INTO Editeur
						   (Nom)
					 VALUES
						   (@NomEditeur)
				
				PRINT 'Editeur "' + cast(@NomEditeur AS NVARCHAR) +'" ajouté!'
			END

			INSERT INTO EditeurEdition
					   (IdEdition
					   ,NomEditeur)
				 VALUES
					   (@ID_Edition
					   ,@NomEditeur)
			
			SET @index = @fin
			
		END
			
		SET @index = 1
		
		WHILE @index <> LEN(@ListLangueAudio) AND @vide=1 AND @ROWCOUNT = 1
		BEGIN
			DECLARE @LangueAudio NVARCHAR(64)
			
			SET @fin = CHARINDEX('|', @ListLangueAudio, @index+1)
			
			SET @LangueAudio = LTRIM(SUBSTRING(@ListLangueAudio , @index+1, @fin - @index-1))
			
			BEGIN TRY 
				INSERT INTO EditionLangueAudio
						   (IdEdition
						   ,NomLangue)
					 VALUES
						   (@ID_Edition
						   ,@LangueAudio)
			END TRY
			BEGIN CATCH		
				RAISERROR('L''opération avortée : cette langue n''existe pas dans la base donnée!', 11, 1);
				ROLLBACK TRAN ADD_EDITION
				RETURN
			END CATCH
					   
			SET @index = @fin
			
		END
		
		SET @index = 1
		
		WHILE @index <> LEN(@ListLangueSousTitres) AND @vide=1 AND @ROWCOUNT = 1
		BEGIN
			DECLARE @LangueSousTitres NVARCHAR(64)
			
			SET @fin = CHARINDEX('|', @ListLangueSousTitres, @index+1)
			
			SET @LangueSousTitres = LTRIM(SUBSTRING(@ListLangueSousTitres , @index+1, @fin - @index-1))
			
			BEGIN TRY
				INSERT INTO EditionLangueSousTitres
					   (IdEdition
					   ,NomLangue)
				 VALUES
					   (@ID_Edition
					   ,@LangueSousTitres)
				
			END TRY
			BEGIN CATCH		
				RAISERROR('L''opération avortée : cette langue n''existe pas dans la base donnée!', 11, 1);
				ROLLBACK TRAN ADD_EDITION
				RETURN
			END CATCH
			
			SET @index = @fin
			
		END
	
	COMMIT TRAN ADD_EDITION
	PRINT 'Edition "' + cast(@NomEdition AS NVARCHAR) +'" ajoutée!'
END			
GO

--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure pour supprimer une Edition         */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_supprimer') IS NOT NULL)
  DROP PROCEDURE dbo.edition_supprimer
GO
CREATE PROCEDURE dbo.edition_supprimer
	@ID_Edition INT
AS
BEGIN

	IF NOT EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
		RETURN
	END
	
    /**
    * Vérifier le nombre d'exemplaires (FilmStock) et le nombre d'exemplaires loués
    * et supprimer les exemplaire que ne sont pas loué
    **/
	DECLARE @NombreFilmStock INT
	SELECT @NombreFilmStock = COUNT(*) FROM FilmStock WHERE IdEdition = @ID_Edition
	
	DECLARE @NombreNonLocation INT
	SET @NombreNonLocation = 0
	
	DECLARE @ID_FilmStock INT
	DECLARE FilmStock CURSOR FOR
		SELECT ID FROM FilmStock WHERE IdEdition = @ID_Edition
	OPEN FilmStock
	FETCH NEXT FROM FilmStock
    	INTO @ID_FilmStock
    WHILE @@FETCH_STATUS = 0
    BEGIN
		 		 
		 IF NOT EXISTS (SELECT *
            			FROM Location
                        WHERE FilmStockId = @ID_FilmStock AND DateRetourEff IS NULL )
		BEGIN
			SET @NombreNonLocation = @NombreNonLocation + 1
			BEGIN TRY	
				DELETE FROM FilmStock WHERE Id = @ID_FilmStock
			END TRY
			BEGIN CATCH		
				RAISERROR('L''opération avortée : erreur en supprimer exemplaire!', 11, 1);
				RETURN
			END CATCH
		END
		ELSE
		BEGIN
			UPDATE FilmStock SET Supprimer = 1 WHERE ID = @ID_FilmStock	
		END
		
		FETCH NEXT FROM FilmStock
    		INTO @ID_FilmStock
    END
    CLOSE FilmStock
    DEALLOCATE FilmStock
    -- FIN de vérifier le nombre d'exemplaires (FilmStock) et le nombre d'exemplaires loués
    
    -- S'il n'y pas d'exemplaire de l'edition loue 
    IF (@NombreFilmStock = @NombreNonLocation)
    BEGIN
		BEGIN TRAN SUPP_EDITION
			DECLARE @NomEditeur NVARCHAR(64)
			DECLARE Editeur CURSOR FOR
				SELECT NomEditeur FROM EditeurEdition WHERE IdEdition = @ID_Edition
			OPEN Editeur
			FETCH NEXT FROM Editeur
    			INTO @NomEditeur
			WHILE @@FETCH_STATUS = 0
			BEGIN
				BEGIN TRY
					 DELETE FROM EditeurEdition WHERE IdEdition = @ID_Edition AND NomEditeur = @NomEditeur
					 
					 IF NOT EXISTS (SELECT * FROM EditeurEdition WHERE NomEditeur = @NomEditeur)
					BEGIN
						DELETE FROM Editeur WHERE Nom = @NomEditeur
						
						PRINT 'Editeur "' + cast(@NomEditeur AS NVARCHAR) + '" supprimé!'
					END
				END TRY
				BEGIN CATCH		
					RAISERROR('L''opération avortée : erreur en supprimer editeur!', 11, 1);
					ROLLBACK TRAN SUPP_EDITION
					RETURN
				END CATCH
				
				FETCH NEXT FROM Editeur
    				INTO @NomEditeur
			END
			CLOSE Editeur
			DEALLOCATE Editeur
		    
		    BEGIN TRY
				DELETE FROM Edition WHERE ID = @ID_Edition
			END TRY
			BEGIN CATCH		
				RAISERROR('L''opération avortée : erreur en supprimer edition!', 11, 1);
				ROLLBACK TRAN SUPP_EDITION
				RETURN
			END CATCH
			
			PRINT 'Edition supprimée!'
		COMMIT TRAN SUPP_EDITION
	END
	ELSE
	BEGIN
		UPDATE Edition SET Supprimer = 1 WHERE ID = @ID_Edition		
		RAISERROR('Edition ne peut pas être supprimée, car il y a un examplaire loué!', 11, 1);
	END
END    
GO
	
--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure MAJ Nom de l'edition               */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_nom') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_nom
GO
CREATE PROCEDURE dbo.edition_modifier_nom
	@ID_Edition INT,
	@NomEdition NVARCHAR(256)
AS
BEGIN
	IF @NomEdition = '' OR @NomEdition = ' '
	BEGIN
		RAISERROR('Le nom d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	DECLARE @ROWCOUNT INT
	SET @ROWCOUNT = 0
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET NomEdition = @NomEdition WHERE ID = @ID_Edition
		
		SET @ROWCOUNT = @@ROWCOUNT
		
		IF (@ROWCOUNT = 1)
		BEGIN
			PRINT 'Mis à jour le nom!'
		END
		ELSE
		BEGIN
			RAISERROR('Existe déjà une edition avec ce nom!', 11, 1);
		END
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure MAJ Duree de l'edition             */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_duree') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_duree
GO
CREATE PROCEDURE dbo.edition_modifier_duree
	@ID_Edition INT,
	@Duree NVARCHAR(9)
AS
BEGIN
	IF @Duree = '' OR @Duree = ' '
	BEGIN
		RAISERROR('La duree d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET Duree = @Duree WHERE ID = @ID_Edition
		PRINT 'Mis à jour la durée!'
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure MAJ Date de sortie de l'edition    */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_date_sortie') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_date_sortie
GO
CREATE PROCEDURE dbo.edition_modifier_date_sortie
	@ID_Edition INT,
	@DateSortie NVARCHAR(11)
AS
BEGIN
	IF @DateSortie = '' OR @DateSortie = ' '
	BEGIN
		RAISERROR('La date de sortie d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET DateSortie = convert(date,@DateSortie,103)WHERE ID = @ID_Edition
		PRINT 'Mis à jour la date de sortie!'
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure MAJ Support de l'edition           */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_support') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_support
GO
CREATE PROCEDURE dbo.edition_modifier_support
	@ID_Edition INT,
	@Support NVARCHAR(32)
AS
BEGIN
	IF @Support = '' OR @Support = ' '
	BEGIN
		RAISERROR('Le support d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition  WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET Support = @Support WHERE ID = @ID_Edition
		PRINT 'Mis à jour le support!'
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure MAJ Attribut couleur  de l'edition */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_couleur') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_couleur
GO
CREATE PROCEDURE edition_modifier_couleur
	@ID_Edition INT,
	@Couleur BIT
AS
BEGIN
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET Couleur = @Couleur WHERE ID = @ID_Edition
		PRINT 'Mis à jour la couleur!'
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

--------------------------------------------------
/* IBDR 2013 - Groupe SAR                       */
/* Procedure MAJ Pays de l'edition              */
/* Auteur  : MUNOZ Yupanqui - SAR               */
/* Testeur : MUNOZ Yupanqui - SAR               */
--------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_pays') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_pays
GO
CREATE PROCEDURE dbo.edition_modifier_pays
	@ID_Edition INT,
	@Pays NVARCHAR(64)
AS
BEGIN
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM Pays WHERE Nom = @Pays)
		BEGIN
			UPDATE Edition SET Pays = @Pays	WHERE ID = @ID_Edition
			PRINT 'Mis à jour le pays!'
		END
		ELSE
		BEGIN
			RAISERROR('Ce pays n''existe pas!', 11, 1);
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
/* Procedure MAJ Age d'interdiction de l'edition */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_modifier_age_interdiction') IS NOT NULL)
  DROP PROCEDURE dbo.edition_modifier_age_interdiction
GO
CREATE PROCEDURE dbo.edition_modifier_age_interdiction
	@ID_Edition INT,
	@AgeInterdiction INT
AS
BEGIN
	IF @AgeInterdiction = '' OR @AgeInterdiction = ' '
	BEGIN
		RAISERROR('L''age d''interdiction d''edition ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET AgeInterdiction = @AgeInterdiction WHERE ID = @ID_Edition
		PRINT 'Mis à jour l''age d''interdiction!'
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure ajout langue audio a une edition    */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_ajouter_langue_audio') IS NOT NULL)
  DROP PROCEDURE dbo.edition_ajouter_langue_audio
GO
CREATE PROCEDURE dbo.edition_ajouter_langue_audio
	@ID_Edition INT,
	@LangueAudio NVARCHAR(64)
AS
BEGIN
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM Langue WHERE Nom = @LangueAudio)
		BEGIN
			INSERT INTO EditionLangueAudio
					   (IdEdition
					   ,NomLangue)
				 VALUES
					   (@ID_Edition
					   ,@LangueAudio)
			PRINT 'La langue d''audio a été ajoutée!'
		END
		ELSE
		BEGIN
			RAISERROR('Cette langue n''existe pas!', 11, 1);
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
/* Procedure ajout langue ST a une edition       */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_ajouter_langue_sous_titres') IS NOT NULL)
  DROP PROCEDURE dbo.edition_ajouter_langue_sous_titres
GO
CREATE PROCEDURE dbo.edition_ajouter_langue_sous_titres
	@ID_Edition INT,
	@LangueSousTitres NVARCHAR(64)
AS
BEGIN
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM Langue WHERE Nom = @LangueSousTitres)
		BEGIN
			INSERT INTO EditionLangueSousTitres
					   (IdEdition
					   ,NomLangue)
				 VALUES
					   (@ID_Edition
					   ,@LangueSousTitres)
			PRINT 'La langue de sous-titres a été ajoutée!'
		END
		ELSE
		BEGIN
			RAISERROR('Cette langue n''existe pas!', 11, 1);
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
/* Procedure suppression langue audio edition    */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_supprimer_langue_audio') IS NOT NULL)
  DROP PROCEDURE dbo.edition_supprimer_langue_audio
GO
CREATE PROCEDURE dbo.edition_supprimer_langue_audio
	@ID_Edition INT,
	@LangueAudio NVARCHAR(64)
AS
BEGIN
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM Langue WHERE Nom = @LangueAudio)
		BEGIN
			IF ((SELECT COUNT(*) FROM EditionLangueAudio ) > 1)
			BEGIN
				DELETE FROM EditionLangueAudio WHERE IdEdition = @ID_Edition AND NomLangue = @LangueAudio
				PRINT 'La langue d''audio a été supprimée!'
			END
			ELSE
			BEGIN
				RAISERROR('La langue d''audio ne peut pas être supprimer, car il faut au moins une langue à l''edition!', 11, 1);
			END
		END
		ELSE
		BEGIN
			RAISERROR('Cette langue n''existe pas!', 11, 1);
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
/* Procedure suppression langue ST edition       */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_supprimer_langue_sous_titres') IS NOT NULL)
  DROP PROCEDURE dbo.edition_supprimer_langue_sous_titres
GO
CREATE PROCEDURE dbo.edition_supprimer_langue_sous_titres
	@ID_Edition INT,
	@LangueSousTitres NVARCHAR(64)
AS
BEGIN
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM Langue WHERE Nom = @LangueSousTitres)
		BEGIN
			DELETE FROM EditionLangueSousTitres WHERE IdEdition = @ID_Edition AND NomLangue = @LangueSousTitres
			PRINT 'La langue de sous-titres a été supprimée!'
		END
		ELSE
		BEGIN
			RAISERROR('Cette langue n''existe pas!', 11, 1);
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
/* Procedure suppression editeur d'une edition   */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_supprimer_editeur') IS NOT NULL)
  DROP PROCEDURE dbo.edition_supprimer_editeur
GO
CREATE PROCEDURE dbo.edition_supprimer_editeur
	@ID_Edition INT,
	@NomEditeur NVARCHAR(64)
AS
BEGIN

	IF NOT EXISTS (SELECT * FROM Editeur WHERE Nom = @NomEditeur)
	BEGIN
		RAISERROR('Cet editieur n''existe pas!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		DECLARE @NombreEditeurs INT
		SELECT @NombreEditeurs = COUNT(*) FROM EditeurEdition WHERE IdEdition = @ID_Edition
		
		IF (@NombreEditeurs > 1)
		BEGIN
			DECLARE @Editeur NVARCHAR(64)
			DECLARE Editeur CURSOR FOR
				SELECT NomEditeur FROM EditeurEdition WHERE IdEdition = @ID_Edition AND NomEditeur = @NomEditeur
			OPEN Editeur
			FETCH NEXT FROM Editeur
    			INTO @Editeur
			WHILE @@FETCH_STATUS = 0
			BEGIN
				 DELETE FROM EditeurEdition WHERE IdEdition = @ID_Edition AND NomEditeur = @NomEditeur
				 
				 IF NOT EXISTS (SELECT * FROM EditeurEdition WHERE NomEditeur = @NomEditeur)
				BEGIN
					DELETE FROM Editeur WHERE Nom = @NomEditeur
					PRINT 'L''editeur "' + cast(@NomEditeur AS NVARCHAR) +'" a été supprimé de la base données!'
				END
				
				FETCH NEXT FROM Editeur
    				INTO @NomEditeur
			END
			CLOSE Editeur
			DEALLOCATE Editeur
			PRINT 'L''editeur a été supprimé de l''edition!'
		END
		ELSE
		BEGIN
			RAISERROR('Impossible supprimer, car il faut moins un editeur!', 11, 1);
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
/* Procedure ajout d'editeur a une edition       */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.edition_ajouter_editeur') IS NOT NULL)
  DROP PROCEDURE dbo.edition_ajouter_editeur
GO
CREATE PROCEDURE dbo.edition_ajouter_editeur
	@ID_Edition INT,
	@NomEditeur NVARCHAR(64)
AS
BEGIN
	IF @NomEditeur = '' OR @NomEditeur = ' '
	BEGIN
		RAISERROR('Le nom d''editeur ne peut pas être vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		IF NOT EXISTS (SELECT * FROM Editeur WHERE Nom = @NomEditeur)
		BEGIN

			INSERT INTO Editeur
					   (Nom)
				 VALUES
					   (@NomEditeur)
			PRINT 'L''editeur "' + cast(@NomEditeur AS NVARCHAR) +'" a été ajouté à la base données!'
		END

		INSERT INTO EditeurEdition
				   (IdEdition
				   ,NomEditeur)
			 VALUES
				   (@ID_Edition
				   ,@NomEditeur)
		PRINT 'L''editeur a été ajouté à l''edition!'
	END
	ELSE
	BEGIN
		RAISERROR('Cette edition n''existe pas!', 11, 1);
	END
END
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure MAJ d'editeur                       */
/* Auteur  : MUNOZ Yupanqui - SAR                */
/* Testeur : MUNOZ Yupanqui - SAR                */
---------------------------------------------------
IF (OBJECT_ID('dbo.editeur_modifier') IS NOT NULL)
  DROP PROCEDURE dbo.editeur_modifier
GO
CREATE PROCEDURE dbo.editeur_modifier
	@NomEditeur NVARCHAR(64),
	@NomEditeurNouv NVARCHAR(64)
AS
BEGIN
	DECLARE @ROWCOUNT INT
	SET @ROWCOUNT = 0
		
	IF EXISTS (SELECT * FROM Editeur WHERE Nom = @NomEditeur)
	BEGIN
					
		UPDATE Editeur SET Nom = @NomEditeurNouv WHERE Nom = @NomEditeur
		
		SET @ROWCOUNT = @@ROWCOUNT
		
		IF (@ROWCOUNT = 1)
		BEGIN 
			PRINT 'Mis à jour le nom!'
		END
		ELSE
		BEGIN
		RAISERROR('Existe déjà un editeur avc ce nom!', 11, 1);
		END
	END
	ELSE
	BEGIN
		RAISERROR('Cet editeur n''existe pas!', 11, 1);
	END
END
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

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure d'ajout d'un film                   */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF (OBJECT_ID('dbo.film_creer') IS NOT NULL)
  DROP PROCEDURE dbo.film_creer
GO
CREATE PROCEDURE dbo.film_creer
	@titre_VF NVARCHAR(128),
	@complement_titre NVARCHAR(256),
	@titre_VO NVARCHAR(128),
	@annee_Sortie SMALLINT,	
	@synopsis NTEXT ,
	@langue NVARCHAR(64) ,
	@site_web NVARCHAR(512),	
    @liste_acteurs VARCHAR(1000),
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
    -- 0 si film sans acteur
    @liste_realisateurs VARCHAR(500),
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
	-- pas de film sans réalisateur
	@liste_producteurs VARCHAR(500),
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
	-- pas de film sans producteur
	@liste_genres varchar(100)
	-- |genre|genre|genre|...
	-- pas de film sans genre
AS

BEGIN

	declare @tmp int
	declare @index int
	declare @fin int
	declare @vide int
	declare @er int
	DECLARE @TransactionMain varchar(20) = 'TransactionPrincipale';
	

	/* catalogue */
	print '-- FIlM --'
	IF CHARINDEX('|', @liste_acteurs)=0
		BEGIN
			print 'Un film doit au moins avoir un réalisateur';
			return 0;
		END
	
	IF CHARINDEX('|',@liste_genres)=0
		RAISERROR('Un film doit au moins avoir un genre', 16, 1);
	
		
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp>= 1 /* film déjà au catalogue */
	
		RAISERROR('%s %d : film déjà au catalogue', 16, 1, @titre_VF, @annee_Sortie);
		
BEGIN TRAN @TransactionMain		
	 /* film absent du catalogue, a inserer */
		BEGIN TRY
			Print 'L''ajout du film '+ cast(@titre_VF as varchar)+ ' dans la tables Film';
		
			INSERT into Film(TitreVF,ComplementTitre,TitreVO,AnneeSortie,Synopsis,Langue,SiteWeb,isDeleted)
					 VALUES ( @titre_VF, @complement_titre, @titre_VO, 
								 @annee_Sortie, @synopsis, @langue, @site_web,0);
			
		END TRY
		BEGIN CATCH
			--erreur
			ROLLBACK TRAN @TransactionMain;
			Print ERROR_MESSAGE();
			RAISERROR('%s %d : Erreur lors de l''insertion du film :', 16, 1, @titre_VF, @annee_Sortie);
			
			return -1;
		END CATCH
	
	
	/* ACTEUR(S) */
	print '-- ACTEUR(S) --'
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
	-- 0 si film sans acteur
	set @index= 1
	set @vide = 1
	IF CHARINDEX('|', @liste_acteurs)=0
		BEGIN
			Print ' film sans acteur'
			Set @vide = 0
		END
	-- ajout cara | en debut
	IF CHARINDEX('|', @liste_acteurs) <> 1
		BEGIN
			Set @liste_acteurs = '|' + @liste_acteurs
		END
	-- ajout cara | en fin
	IF CHARINDEX('|',@liste_acteurs, Len(@liste_acteurs)) = 0
		BEGIN
			SET @liste_acteurs = @liste_acteurs +'|'
		END
	
	WHILE @index <> LEN(@liste_acteurs) AND @vide=1
		BEGIN
			declare @virg1 int, @virg2 int, @virg3 int, @virg4 int, @virg5 int ;
			declare @nom_act VARCHAR(64), @pre_act VARCHAR(64), @alias_act NVARCHAR(64), @dat_act VARCHAR(50), @dat_deces_act VARCHAR(50), @biographie_act NVARCHAR(MAX);
			set @virg1 = CHARINDEX(',', @liste_acteurs, @index+1)
			set @virg2 = CHARINDEX(',', @liste_acteurs, @virg1+1)
			set @virg3 = CHARINDEX(',', @liste_acteurs, @virg2+1)
			set @virg4 = CHARINDEX(',', @liste_acteurs, @virg3+1)	
			set @virg5 = CHARINDEX(',', @liste_acteurs, @virg4+1)
				
			set @fin = CHARINDEX('|', @liste_acteurs, @index+1)
			
			--nom
			set @nom_act = LTRIM(SUBSTRING(@liste_acteurs, @index+1, @virg1 - @index -1))
			
			--Prénom
			set @pre_act = LTRIM(SUBSTRING(@liste_acteurs, @virg1+1, @virg2 - @virg1 -1))
			
			--Alias
			Set @alias_act = LTRIM(SUBSTRING(@liste_acteurs, @virg2+1, @virg3 - @virg2 -1))
			
			--date naissance
			set @dat_act = LTRIM(SUBSTRING(@liste_acteurs, @virg3+1, @virg4 - @virg3 -1))
			
			--date deces
			declare @tmpDate varchar(50)
			set @tmpDate = LTRIM(SUBSTRING(@liste_acteurs, @virg4+1, @virg5 - @virg4 -1))
			IF (@tmpDate='' OR @tmpDate=' ' OR @tmpDate='null' OR @tmpDate='NULL')
				set @dat_deces_act =null
			ELSE set @dat_deces_act =@tmpDate
			
			--Biographie
			set @biographie_act = LTRIM(SUBSTRING(@liste_acteurs, @virg5+1, @fin - @virg5 -1))
			
			
			set @index = @fin
			
			--vérifié si la personne existe déja dans la base de données
			Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
			IF @tmp = 1 -- elle éxiste 
			Begin
				Print 'L''acteur '+cast(@nom_act as varchar)+' existe déjà dans la table Personne';	
				Begin Try
					
						INSERT FilmActeur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
							Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					
				END Try
				Begin Catch
					
					ROLLBACK TRAN @TransactionMain;
					Print ERROR_MESSAGE();
					RAISERROR('Erreur lors de l''ajouter de %s %s dans la tables FILMActeur : ', 16, 1, @nom_act, @pre_act);
					return -1;
					
					Print ERROR_MESSAGE();
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, insérer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'L''acteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, insérer dans la table Personne';				
					Begin Try
					
							INSERT Personne (Nom,Prenom,Alias,DateNaissance,DateDeces,Biographie)
								Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
								
							INSERT FilmActeur(TitreVF,AnneeSortie,Nom,Prenom,Alias)
								 Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
					
					END Try
					Begin Catch
						ROLLBACK TRAN @TransactionMain;
						Print ERROR_MESSAGE();
						RAISERROR('Erreur lors de l''ajouter de %s %s dans la tables FilmActeur : ', 16, 1, @nom_act, @pre_act);
					End Catch
				
				END
		END
		

	/* --------------------------------------------realisateur(s)------------------------------------------ */
	print '-- REALISATEUR(S) --'
	
	set @index= 1
	
	-- ajout cara | en debut
	IF CHARINDEX('|', @liste_realisateurs) <> 1
		BEGIN
			Set @liste_realisateurs = '|' + @liste_realisateurs
		END
	-- ajout cara | en fin
	IF CHARINDEX('|',@liste_realisateurs, Len(@liste_realisateurs)) = 0
		BEGIN
			SET @liste_realisateurs = @liste_realisateurs +'|'
		END
	
	WHILE @index <> LEN(@liste_realisateurs)
		BEGIN
			
			set @virg1 = CHARINDEX(',', @liste_realisateurs, @index+1)
			set @virg2 = CHARINDEX(',', @liste_realisateurs, @virg1+1)
			set @virg3 = CHARINDEX(',', @liste_realisateurs, @virg2+1)
			set @virg4 = CHARINDEX(',', @liste_realisateurs, @virg3+1)	
			set @virg5 = CHARINDEX(',', @liste_realisateurs, @virg4+1)
				
			set @fin = CHARINDEX('|', @liste_realisateurs, @index+1)
			
			--nom
			set @nom_act = LTRIM(SUBSTRING(@liste_realisateurs, @index+1, @virg1 - @index -1))
			
			--Prénom
			set @pre_act = LTRIM(SUBSTRING(@liste_realisateurs, @virg1+1, @virg2 - @virg1 -1))
			
			--Alias
			Set @alias_act = LTRIM(SUBSTRING(@liste_realisateurs, @virg2+1, @virg3 - @virg2 -1))
			
			--date naissance
			set @dat_act = LTRIM(SUBSTRING(@liste_realisateurs, @virg3+1, @virg4 - @virg3 -1))
			
			--date deces
			set @tmpDate = LTRIM(SUBSTRING(@liste_realisateurs, @virg4+1, @virg5 - @virg4 -1))
			IF (@tmpDate='' OR @tmpDate=' ' OR @tmpDate='null' OR @tmpDate='NULL')
				set @dat_deces_act =null
			ELSE set @dat_deces_act =@tmpDate
			
			--Biographie
			set @biographie_act = LTRIM(SUBSTRING(@liste_realisateurs, @virg5+1, @fin - @virg5 -1))
			
			
			set @index = @fin
			
			--vérifié si la personne existe déja dans la base de données
			Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
			IF @tmp = 1 -- elle éxiste 
			Begin
				Print 'Le réalisateur '+cast(@nom_act as varchar)+' existe déjà dans la table Personne';	
				Begin Try
					
						INSERT FilmRealisateur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
							Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					
				END Try
				Begin Catch
					ROLLBACK TRAN @TransactionMain;
					Print ERROR_MESSAGE();
					RAISERROR('Erreur lors de l''ajouter de "%s %s" dans la tables FilmRéalisateur : ', 16, 1, @nom_act,@pre_act);
					
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, insérer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'Le réalisateur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, insérer dans la table Personne';				
					Begin Try
						
							INSERT Personne (Nom,Prenom,Alias,DateNaissance,DateDeces,Biographie)
								Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
								
							INSERT FilmRealisateur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
								Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
						
					END Try
					Begin Catch
						ROLLBACK TRAN @TransactionMain;
						Print ERROR_MESSAGE();
						RAISERROR('Erreur lors de dans l''ajout de "%s %s" : ', 16, 1, @nom_act,@pre_act );
					End Catch
				
				END
		END
	
		/* ---------------------------------------------------------------Producteur(S) ---------------------------------------------*/
	print '-- PRODUCTEUR(S) --'
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
	-- 0 si film sans producteur
	set @index= 1
	set @vide = 1
	
	IF CHARINDEX('|',@liste_producteurs )=0
		BEGIN
			Print ' Film sans producteur'
			Set @vide = 0
		END
	-- ajout cara | en debut
	IF CHARINDEX('|', @liste_producteurs) <> 1
		BEGIN
			Set @liste_producteurs = '|' + @liste_producteurs
		END
	-- ajout cara | en fin
	IF CHARINDEX('|',@liste_producteurs, Len(@liste_producteurs)) = 0
		BEGIN
			SET @liste_producteurs = @liste_producteurs +'|'
		END
	
	WHILE @index <> LEN(@liste_producteurs) AND @vide=1
		BEGIN
			set @virg1 = CHARINDEX(',', @liste_producteurs, @index+1)
			set @virg2 = CHARINDEX(',', @liste_producteurs, @virg1+1)
			set @virg3 = CHARINDEX(',', @liste_producteurs, @virg2+1)
			set @virg4 = CHARINDEX(',', @liste_producteurs, @virg3+1)	
			set @virg5 = CHARINDEX(',', @liste_producteurs, @virg4+1)
				
			set @fin = CHARINDEX('|', @liste_producteurs, @index+1)
			
			--nom
			set @nom_act = LTRIM(SUBSTRING(@liste_producteurs, @index+1, @virg1 - @index -1))
			
			--Prénom
			set @pre_act = LTRIM(SUBSTRING(@liste_producteurs, @virg1+1, @virg2 - @virg1 -1))
			
			--Alias
			Set @alias_act = LTRIM(SUBSTRING(@liste_producteurs, @virg2+1, @virg3 - @virg2 -1))
			
			--date naissance
			set @dat_act = LTRIM(SUBSTRING(@liste_producteurs, @virg3+1, @virg4 - @virg3 -1))
			
			--date deces
			--declare @tmpDate varchar(50)
			set @tmpDate = LTRIM(SUBSTRING(@liste_producteurs, @virg4+1, @virg5 - @virg4 -1))
			IF (@tmpDate='' OR @tmpDate=' ' OR @tmpDate='null' OR @tmpDate='NULL')
				set @dat_deces_act =null
			ELSE set @dat_deces_act =@tmpDate
			
			--Biographie
			set @biographie_act = LTRIM(SUBSTRING(@liste_producteurs, @virg5+1, @fin - @virg5 -1))
			
			
			set @index = @fin
			
			--vérifié si la personne existe déja dans la base de données
			Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
			IF @tmp = 1 -- elle éxiste 
			Begin
				Print 'Le producteur '+cast(@nom_act as varchar)+' existe déjà dans la table Personne';	
				Begin Try
					
						INSERT FilmActeur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
							Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					
				END Try
				Begin Catch
					ROLLBACK TRAN @TransactionMain;
					Print ERROR_MESSAGE();
					RAISERROR('Erreur lors dans l''ajouter de %s %s: ', 16, 1,@nom_act ,@pre_act );
					
					Print ERROR_MESSAGE();
					
				End Catch
			End
			ELSE /* le producteur n'existe pas dans la table Producteurs, insérer dans la table Producteurs et dans la table Joue  */
				BEGIN
					Print 'Le producteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, insérer dans la table Personne';				
					Begin Try
						
							INSERT Personne (Nom,Prenom,Alias,DateNaissance,DateDeces,Biographie)
								Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
								
							INSERT FilmActeur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
								Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
						
					END Try
					Begin Catch
						ROLLBACK TRAN @TransactionMain;
						Print ERROR_MESSAGE();
						RAISERROR('Erreur lors dans l''ajouter de %s %s: ', 16, 1,@nom_act ,@pre_act );
					End Catch
				
				END
		END
		



	/* --------------------------------------------genre(s)-------------------------------------------- */
	print '-- GENRE(S) --'
	-- |genre|genre|genre|...
	
	set @index= 1
	
	-- ajout cara | en debut
	IF CHARINDEX('|', @liste_genres) <> 1
		BEGIN
			Set @liste_genres = '|' + @liste_genres
		END
	-- ajout cara | en fin
	IF CHARINDEX('|',@liste_genres, Len(@liste_genres)) = 0
		BEGIN
			SET @liste_genres = @liste_genres +'|'
		END
	
	WHILE @index <> LEN(@liste_genres)
		BEGIN
				
			set @fin = CHARINDEX('|', @liste_genres, @index+1)
			
			
			declare @genre_film NVARCHAR(15);
			--genre
			set @genre_film = LTRIM(SUBSTRING(@liste_genres, @index+1, @fin - @index -1))
			
			set @index = @fin
			
			--vérifié si la personne existe déja dans la base de données
			Select @tmp = count(*) from Genre Where Genre.Nom=@genre_film;
			IF @tmp = 1 -- le genre éxiste déjà
			Begin
				--Print 'Le genre '+cast(@genre_film as varchar)+' existe déjà dans la table Genre';	
				Begin Try
						INSERT FilmGenre (TitreVF,AnneeSortie,NomGenre)
							Values (@titre_VF,@annee_Sortie,@genre_film)
					
				END Try
				Begin Catch
					ROLLBACK TRAN @TransactionMain;
					Print ERROR_MESSAGE();
					RAISERROR('Erreur dans l''ajout du genre %s : ', 16, 1, @genre_film );
					
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, insérer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'Le genre : '+cast(@genre_film as varchar)+' n''existe pas dans la table Genre';				
					
					Begin Try
							INSERT Genre (Nom)
								Values (@genre_film);
								
							INSERT FilmGenre (TitreVF,AnneeSortie,NomGenre)
								Values (@titre_VF,@annee_Sortie,@genre_film);
					
					END Try
					Begin Catch
						ROLLBACK TRAN @TransactionMain;
						Print ERROR_MESSAGE();
						RAISERROR('Erreur dans l''ajout du genre %s : ', 16, 1, @genre_film );
						
					End Catch
					
				END
		END
		
COMMIT TRAN @TransactionMain
	
end	
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure modification date deces d'1 personne*/
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF OBJECT_ID ('dbo.personne_modifier_date_deces') IS NOT NULL
    DROP PROCEDURE dbo.personne_modifier_date_deces
GO
CREATE PROCEDURE dbo.personne_modifier_date_deces
	@nom_pers NVARCHAR(64) ,
    @prenom_pers NVARCHAR(64),
    @alias_pers NVARCHAR(64),
    @date_deces DATE
AS
BEGIN
	declare @tmp int
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s : personne n''existe pas dans la table personne', 16, 1, @nom_pers, @prenom_pers);
		
	Update Personne Set Personne.DateDeces=@date_deces Where  Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers  
END 
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure modification biographie d'1 personne*/
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF OBJECT_ID ('dbo.personne_modifier_biographie') IS NOT NULL
    DROP PROCEDURE dbo.personne_modifier_biographie
GO
CREATE PROCEDURE dbo.personne_modifier_biographie
	@nom_pers NVARCHAR(64) ,
    @prenom_pers NVARCHAR(64),
    @alias_pers NVARCHAR(64),
    @bio_pers NVARCHAR(500)
AS
BEGIN
	declare @tmp int
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s : personne n''existe pas dans la tables personne', 16, 1, @nom_pers, @prenom_pers);
		
	Update Personne Set Personne.Biographie=@bio_pers Where  Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers  
END 
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure modification site web d'un film     */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF OBJECT_ID ('dbo.film_modifier_site_web') IS NOT NULL
    DROP PROCEDURE dbo.film_modifier_site_web
GO
CREATE PROCEDURE dbo.film_modifier_site_web
	@titre_VF NVARCHAR(128),
	@annee_Sortie SMALLINT,
	@site_web NVARCHAR(512)
AS
BEGIN
	declare @tmp int;
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0
		RAISERROR('%s %d: film n''existe pas dans la tables Film', 16, 1, @titre_VF,@annee_Sortie);
	
	Update Film Set Film.SiteWeb=@site_web where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	
	
END  
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure d'ajout d'un acteur a un film       */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF (OBJECT_ID('dbo.film_ajouter_acteur') IS NOT NULL)
  DROP PROCEDURE dbo.film_ajouter_acteur
GO
CREATE PROCEDURE dbo.film_ajouter_acteur
	@titre_VF NVARCHAR(128),
	@annee_Sortie SMALLINT,
	@nom_act VARCHAR(64),
	@pre_act VARCHAR(64),
	@alias_act NVARCHAR(64), 
	@dat_act VARCHAR(50), 
	@dat_deces_act VARCHAR(50), 
	@biographie_act NVARCHAR(MAX)
AS
BEGIN
	declare @tmp int;
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0
		RAISERROR('%s %d: Film n''existe pas dans le catalogue', 16, 1, @titre_VF,@annee_Sortie);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act)
	
	--créer le lien entre film et personne
	Insert FilmActeur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
			 values(@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
	
END	
GO


---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure de suppression d'un acteur d'un film*/
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF (OBJECT_ID('dbo.film_supprimer_acteur') IS NOT NULL)
  DROP PROCEDURE dbo.film_supprimer_acteur
GO
CREATE PROCEDURE dbo.film_supprimer_acteur
	@titre_VF NVARCHAR(128),
	@annee_Sortie SMALLINT,
	@nom_act VARCHAR(64),
	@pre_act VARCHAR(64),
	@alias_act NVARCHAR(64)
AS
Begin
	declare @tmp int;
	--vérifié si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0--no, erreur
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
		
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 16, 1, @nom_act,@pre_act);
		
	Delete FilmActeur where FilmActeur.Nom=@titre_VF AND FilmActeur.AnneeSortie=@annee_Sortie AND
							FilmActeur.Nom=@nom_act AND FilmActeur.Prenom=@pre_act AND
							FilmActeur.Alias=@alias_act;
END		
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure d'ajout d'un réalisateur a un film  */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF (OBJECT_ID('dbo.film_ajouter_realisateur') IS NOT NULL)
  DROP PROCEDURE dbo.film_ajouter_realisateur
GO
CREATE PROCEDURE dbo.film_ajouter_realisateur
	@titre_VF NVARCHAR(128),
	@annee_sortie SMALLINT,
	@nom_real VARCHAR(64),
	@pre_real VARCHAR(64),
	@alias_real NVARCHAR(64), 
	@dat_real VARCHAR(50), 
	@dat_deces_real VARCHAR(50), 
	@biographie_real NVARCHAR(MAX)	
AS
Begin
	declare @tmp int;
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
								Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_real And Prenom=@pre_real And Alias=@alias_real
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_real,@pre_real,@alias_real,@dat_real,@dat_deces_real,@biographie_real)
	
	--créer le lien entre film et personne
	Insert FilmRealisateur(TitreVF,AnneeSortie,Nom,Prenom,Alias)
			 values(@titre_VF,@annee_Sortie,@nom_real,@pre_real,@alias_real);
	
	Print 'Le réalisateur '+@nom_real+' '+@pre_real+' est bien inséré pour '+@titre_VF+' '+@annee_Sortie;
End
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure de suppression d'un real d'un film  */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF (OBJECT_ID('dbo.film_supprimer_realisateur') IS NOT NULL)
  DROP PROCEDURE dbo.film_supprimer_realisateur
GO
CREATE PROCEDURE dbo.film_supprimer_realisateur
	@titre_VF NVARCHAR(128),
	@annee_Sortie SMALLINT,
	@nom_real VARCHAR(64),
	@pre_real VARCHAR(64),
	@alias_real NVARCHAR(64)
AS
Begin
	declare @tmp int;
	--vérifié si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0--no, erreur
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
		
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_real And Prenom=@pre_real And Alias=@alias_real
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 16, 1, @nom_real,@pre_real);
		
	Delete FilmRealisateur where FilmRealisateur.TitreVF=@titre_VF AND FilmRealisateur.AnneeSortie=@annee_Sortie AND
							FilmRealisateur.Nom=@nom_real AND FilmRealisateur.Prenom=@pre_real AND
							FilmRealisateur.Alias=@alias_real;
							
	Print 'Le réalisateur '+@nom_real+' '+@pre_real+' est bien suprrimer de '+@titre_VF+' '+@annee_Sortie;
END			
GO

---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure d'ajout d'un producteur a un film   */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
IF (OBJECT_ID('dbo.film_ajouter_producteur') IS NOT NULL)
  DROP PROCEDURE dbo.film_ajouter_producteur
GO

CREATE PROCEDURE dbo.film_ajouter_producteur
	@titre_VF NVARCHAR(128),
	@annee_sortie SMALLINT,
	@nom_prod VARCHAR(64),
	@pre_prod VARCHAR(64),
	@alias_prod NVARCHAR(64), 
	@dat_prod VARCHAR(50), 
	@dat_deces_prod VARCHAR(50), 
	@biographie_prod NVARCHAR(MAX)	
AS
Begin
	declare @tmp int;
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
								Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_prod,@pre_prod,@alias_prod,@dat_prod,@dat_deces_prod,@biographie_prod)
	
	--créer le lien entre film et personne
	Insert FilmProducteur(TitreVF,AnneeSortie,NomProducteur,PrenomProducteur,AliasProducteur)
			values(@titre_VF,@annee_Sortie,@nom_prod,@pre_prod,@alias_prod);
	
	Print 'Le producteur '+@nom_prod+' '+@pre_prod+' est bien inséré pour '+@titre_VF+' '+@annee_Sortie;
End
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de suppression d'un producteur d'1 film */
/* Auteur  : AISSAT Mustapha - SAR                   */
/* Testeur : AISSAT Mustapha - SAR                   */
-------------------------------------------------------
IF (OBJECT_ID('dbo.film_supprimer_producteur') IS NOT NULL)
  DROP PROCEDURE dbo.film_supprimer_producteur
GO
CREATE PROCEDURE dbo.film_supprimer_producteur
	@titre_VF NVARCHAR(128),
	@annee_sortie SMALLINT,
	@nom_prod VARCHAR(64),
	@pre_prod VARCHAR(64),
	@alias_prod NVARCHAR(64)	
AS
Begin
	declare @tmp int;
	--vérifié si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0--no, erreur
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
		
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 16, 1, @nom_prod,@pre_prod);
		
	Delete FilmProducteur where FilmProducteur.TitreVF=@titre_VF AND FilmProducteur.AnneeSortie=@annee_Sortie AND
							FilmProducteur.NomProducteur=@nom_prod AND FilmProducteur.PrenomProducteur=@pre_prod AND
							FilmProducteur.AliasProducteur=@alias_prod;
							
							
	Print 'Le producteur '+@nom_prod+' '+@pre_prod+' est bien supprimé de '+@titre_VF+' '+@annee_Sortie;
	
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure d'ajout d'une distinction a un film     */
/* Auteur  : AISSAT Mustapha - SAR                   */
/* Testeur : AISSAT Mustapha - SAR                   */
-------------------------------------------------------
IF (OBJECT_ID('dbo.film_ajouter_distinction') IS NOT NULL)
  DROP PROCEDURE dbo.film_ajouter_distinction
GO
CREATE PROCEDURE dbo.film_ajouter_distinction
	@nom_dist VARCHAR(64),
	@annee_dist SMALLINT,
	@titre_VF VARCHAR(64),
	@annee_film SMALLINT
AS
Begin
	declare @tmp int;	
	--vérifié si le film existe
	Select @tmp = count(*) from Film Where Film.TitreVF=@titre_VF And Film.AnneeSortie=@annee_film;
	IF @tmp=0--No, erreur
		RAISERROR('%s %d: Film n''existe pas dans le catalogue', 16, 1, @titre_VF,@annee_film);
	
	--vérifié si la distionction existe déjà
	Select @tmp = count(*) from TypeDistinction Where TypeDistinction.Nom=@nom_dist;
	IF @tmp=0--No, inserer la
		Insert TypeDistinction Values (@nom_dist);
	
	Insert FilmDistinction (Annee,TitreVF,AnneeSortie,NomDistinction)
			 Values(@annee_dist,@titre_VF,@annee_film,@nom_dist);
	
	Print 'Le distinction '+@nom_dist+' est bien rajouté pour '+@titre_VF;
		
End

GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure d'ajout d'une distinction a une personne*/
/* Auteur  : AISSAT Mustapha - SAR                   */
/* Testeur : AISSAT Mustapha - SAR                   */
-------------------------------------------------------
IF (OBJECT_ID('dbo.personne_ajouter_distinction') IS NOT NULL)
  DROP PROCEDURE dbo.personne_ajouter_distinction
GO
CREATE PROCEDURE dbo.personne_ajouter_distinction
	@nom_dist VARCHAR(64),
	@annee_dist SMALLINT,
	@titre_VF VARCHAR(64),
	@annee_film SMALLINT,
	@nom_pers VARCHAR(64),
	@pre_pers VARCHAR(64),
	@alias_pers NVARCHAR(64)
AS
Begin
	declare @tmp int;
	IF (@titre_VF='' OR @titre_VF=' ' OR @titre_VF='null' OR @titre_VF='NULL' OR @titre_VF=null OR @annee_film=null)
		Begin
			set @titre_VF =null
			set @annee_film=null	
		END
	
	--vérifié si le film existe
	IF(@titre_VF=null)
		Begin
			Select @tmp = count(*) from Film Where Film.TitreVF=@titre_VF And Film.AnneeSortie=@annee_film;
			IF @tmp=0--No, erreur
				RAISERROR('%s %d: Film n''existe pas dans le catalogue', 16, 1, @titre_VF,@annee_film);
		
		END
	
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@pre_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s: Personne n''existe pas dans le catalogue', 16, 1,@nom_pers,@pre_pers);
	--vérifié si la distionction existe déjà
	Select @tmp = count(*) from TypeDistinction Where TypeDistinction.Nom=@nom_dist;
	IF @tmp=0--No, inserer la
		Insert TypeDistinction Values (@nom_dist);

	--inserer la distionction	
	Insert PersonneDistinction (Annee,TitreVF,AnneeSortie,NomDistinction,Nom,Prenom,Alias)
			Values(@annee_dist,@titre_VF,@annee_film,@nom_dist,@nom_pers,@pre_pers,@alias_pers);
	
	Print 'Le distinction '+@nom_dist+' est bien rajouté pour '+@titre_VF+' '+@annee_film;
END
GO

 -------------------------------------
/* IBDR 2013 – Groupe SAR		  */
/* Precedure du suppression des 
   personnes non référenciés      */
/* Auteur : AISSAT Mustapha - SAR */
/* Testeur : AISSAT Mustapha      */
-------------------------------------
IF OBJECT_ID ('Personne_nettoyage') IS NOT NULL
    DROP PROCEDURE Personne_nettoyage
GO
--procedure periodique pour supprimer les distinction plus référencé
CREATE PROCEDURE [dbo].Personne_nettoyage
AS
Begin

  DECLARE @nom_pers NVARCHAR(64);
	DECLARE @prenom_pers NVARCHAR(64);
	DECLARE @alias_pers NVARCHAR(64);
	
	DECLARE PersonneNonRef CURSOR FOR
		Select Nom,Prenom,Alias
			from (
				Select p.Nom,p.Prenom,p.Alias, f.TitreVF as TitreFilm from Personne p Left Outer join FilmActeur f On p.Nom=f.Nom AND p.Prenom=f.Prenom AND p.Alias=f.Alias
				union
				Select p.Nom,p.Prenom,p.Alias, f.TitreVF as TitreFilm from Personne p Left Outer join FilmRealisateur f On p.Nom=f.Nom AND p.Prenom=f.Prenom AND p.Alias=f.Alias
				union
				Select p.Nom,p.Prenom,p.Alias, f.TitreVF as TitreFilm from Personne p Left Outer join FilmProducteur f On p.Nom=f.NomProducteur AND p.Prenom=f.PrenomProducteur AND p.Alias=f.AliasProducteur
				)as a
				
			Group by Nom,Prenom,Alias
			having count(TitreFilm)=0;

	OPEN PersonneNonRef
	FETCH NEXT FROM PersonneNonRef
    	INTO @nom_pers,@prenom_pers,@alias_pers
    --itérer  sur la list des personnes non référenciés
    WHILE @@FETCH_STATUS = 0
    BEGIN
		Print 'suppression de : '+@nom_pers+' '+@prenom_pers;
		DELETE FROM Personne WHERE Personne.Nom=@nom_pers and Personne.Prenom=@prenom_pers and Personne.Alias=@alias_pers;
		
		FETCH NEXT FROM PersonneNonRef
    		INTO @nom_pers,@prenom_pers,@alias_pers
    END
    CLOSE PersonneNonRef
    DEALLOCATE PersonneNonRef
    
END
GO
	
-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de suppression d'un film                */
/* Auteur  : AISSAT Mustapha - SAR                   */
/* Testeur : AISSAT Mustapha - SAR                   */
-------------------------------------------------------
IF (OBJECT_ID('dbo.film_supprimer') IS NOT NULL)
  DROP PROCEDURE dbo.film_supprimer
GO
CREATE PROCEDURE dbo.film_supprimer
	@titre_VF NVARCHAR(128),
	@annee_Sortie SMALLINT
	
AS
Begin	
	declare @tmp int
	DECLARE @TransactionMain varchar(20) = 'TransactionPrincipale';
	declare @deleteFilm bit=1;



	--vérifié si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0 /* film déjà au catalogue */
		begin
			print cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar)+' film n''est pas dans le catalogue';
			
			return 0;
		end
		
BEGIN TRAN @TransactionMain	
	Begin Try	
		--indiquer que le film est supprimer
		Update Film set IsDeleted=1 Where Film.TitreVF=@titre_VF AND 
					Film.AnneeSortie=@annee_Sortie;
					
		
		--supprimer les éditions
		
		
		DECLARE @id_edition INT;
	
		DECLARE EdtionToDelete CURSOR FOR
			Select id From dbo.Edition where Edition.FilmTitreVF=@titre_VF AND 
					Edition.FilmTitreVF=@annee_Sortie;
				

		OPEN EdtionToDelete
		FETCH NEXT FROM EdtionToDelete
    		INTO @id_edition
		--itérer  sur la list des personnes non référenciés
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Print 'suppression de N°: '+cast(@id_edition as varchar);
			Exec IBDR_SAR.dbo.edition_supprimer @id_edition;
			
			FETCH NEXT FROM EdtionToDelete
    			INTO @id_edition
		END
		CLOSE EdtionToDelete
		DEALLOCATE EdtionToDelete		
				
				--//TODO		
			
		--On supprime en cascade le film
		
		Begin
			print 'Suppréssion du film :'+cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar)+' des tables FilmActeur,FilmRéalisateur,FilmGenre,FilmProducteur, FilmDistinction';
			
				
			Delete FilmActeur Where FilmActeur.TitreVF=@titre_VF and FilmActeur.AnneeSortie=@annee_Sortie;
			Delete FilmDistinction Where FilmDistinction.TitreVF=@titre_VF and FilmDistinction.AnneeSortie=@annee_Sortie;
			Delete FilmGenre Where FilmGenre.TitreVF=@titre_VF and FilmGenre.AnneeSortie=@annee_Sortie;
			Delete FilmProducteur Where FilmProducteur.TitreVF=@titre_VF and FilmProducteur.AnneeSortie=@annee_Sortie;
			Delete FilmRealisateur Where FilmRealisateur.TitreVF=@titre_VF and FilmRealisateur.AnneeSortie=@annee_Sortie;
			Delete PersonneDistinction Where PersonneDistinction.TitreVF=@titre_VF and PersonneDistinction.AnneeSortie=@annee_Sortie;
			exec dbo.Personne_nettoyage ;
			
			--verifié qu'il n'y a pas d'edition lié à ce film
			Select @tmp=count(*) From Edition where Edition.FilmTitreVF=@titre_VF AND 
					Edition.FilmTitreVF=@annee_Sortie;
					
			IF @tmp=0
				Delete Film Where Film.TitreVF=@titre_VF and Film.AnneeSortie=@annee_Sortie;
					
		End	
			
	End Try
	Begin Catch
		ROLLBACK TRAN @TransactionMain;
		Print ERROR_MESSAGE();
		RAISERROR('Erreur lors de la suppréssion du film %s %d : ', 16, 1,@titre_VF ,@annee_Sortie );
		
	End Catch
		
		
	

Commit TRAN @TransactionMain		
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
/* Procedure de création d'un type d'abonnement      */
/* Auteur  : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
/* Testeur : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
-------------------------------------------------------
IF OBJECT_ID ('dbo.type_abonnement_creer', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.type_abonnement_creer;
GO
CREATE PROCEDURE dbo.type_abonnement_creer
(
    @Nom NVARCHAR(32) ,
	@PrixMensuel SMALLMONEY ,
	@PrixLocation SMALLMONEY ,
	@MaxJoursLocation INT ,
	@NbMaxLocations INT ,
	@PrixRetard SMALLMONEY ,
	@DureeEngagement INT 
)
AS
BEGIN

	IF @Nom IS NULL
	BEGIN
		RAISERROR(' Le nom  ne doit pas être null', 9, 1);
		RETURN;
	END	
	IF @PrixMensuel IS NULL
	BEGIN
		RAISERROR(' le prix mensuel ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @PrixLocation IS NULL
	BEGIN
		RAISERROR(' le prix location ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @MaxJoursLocation IS NULL
	BEGIN
		RAISERROR(' le nombre de jour de location ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @NbMaxLocations IS NULL
	BEGIN
		RAISERROR(' Nombe de location ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @PrixRetard IS NULL
	BEGIN
		RAISERROR(' le prix du retard ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @DureeEngagement IS NULL
	BEGIN
		RAISERROR(' La duree d''engagement  ne doit pas être null', 9, 1);
		RETURN;
	END
	
	IF @Nom LIKE '%[^A-Za-z ''-]%'
	BEGIN
		RAISERROR(' Le nom  non valide', 9, 1);
		RETURN;
	END	
	IF @PrixMensuel <= 0
	BEGIN
		RAISERROR(' le prix mensuel non valide', 9, 1);
		RETURN;
	END
	
	IF @PrixLocation <= 0
	BEGIN
		RAISERROR(' le prix location non valide', 9, 1);
		RETURN;
	END
	
	IF @MaxJoursLocation <= 0
	BEGIN
		RAISERROR(' le nombre de jour de location non valide', 9, 1);
		RETURN;
	END
	
	IF @NbMaxLocations <= 0
	BEGIN
		RAISERROR(' Nombre de location non valide', 9, 1);
		RETURN;
	END
	
	IF @PrixRetard < 0
	BEGIN
		RAISERROR(' le prix du retard non valide', 9, 1);
		RETURN;
	END
	
	IF @DureeEngagement < 0
	BEGIN
		RAISERROR(' La duree d''engagement  non valide', 9, 1);
		RETURN;
	END
	

	IF  NOT EXISTS (SELECT *
		FROM TypeAbonnement
		WHERE Nom=@Nom)
	BEGIN
		-- Insère Type Abonnement
		 INSERT INTO TypeAbonnement
					   (
				Nom, 
				PrixLocation,
				PrixMensuel,  
				MaxJoursLocation, 
				NbMaxLocations,
				PrixRetard,  
				DureeEngagement,
				estdispo) 

				VALUES (	  
				@Nom, 
				@PrixLocation,
				@PrixMensuel, 
				@MaxJoursLocation, 
				@NbMaxLocations,
				@PrixRetard, 
				@DureeEngagement ,
				1     )
		PRINT 'Type Abonnement bien ajouté'			
	END
	ELSE
	BEGIN
		RAISERROR('Ce type d''abonnement existe deja', 9, 1);   
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
	INSERT 	INTO dbo.Abonnement (
			Succursale,
			Solde ,
			DateDebut ,
			DateFin ,
			NomClient ,
			PrenomClient ,
			MailClient ,
			TypeAbonnement
			) VALUES (
			@@SERVERNAME,	  	
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
/* Procédure de supression d'un type d'abonnement    */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
-------------------------------------------------------

IF OBJECT_ID ( 'dbo.type_abonnement_supprimer', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.type_abonnement_supprimer;
GO
CREATE PROCEDURE [dbo].[type_abonnement_supprimer]
@Nom NVARCHAR(32) 
AS 
BEGIN  
	IF EXISTS (	SELECT * FROM Abonnement WHERE Abonnement.TypeAbonnement =@Nom)
	BEGIN
	PRINT 'Il existe un abonnement utilisant ce type d''abonnement mise à jour du flag'
	UPDATE dbo.TypeAbonnement 
	SET dbo.TypeAbonnement.estdispo = 0
	WHERE @Nom=Nom
	END 
	 
	ELSE
	BEGIN
	DELETE dbo.TypeAbonnement
	FROM dbo.TypeAbonnement 
	WHERE  @Nom=Nom
	END 
END
GO


-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure de modification d'un type d'abonnement  */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
-------------------------------------------------------
IF OBJECT_ID ( 'dbo.typeAbonnement_modifier', 'P' ) IS NOT NULL 
    DROP PROCEDURE dbo.typeAbonnement_modifier;
GO
CREATE PROCEDURE [dbo].[typeAbonnement_modifier]
	@Nom NVARCHAR(32) ,
	@PrixMensuel SMALLMONEY ,
	@PrixLocation SMALLMONEY ,
	@MaxJoursLocation INT ,
	@NbMaxLocations INT ,
	@PrixRetard SMALLMONEY ,
	@DureeEngagement INT 
AS
BEGIN 
IF EXISTS (SELECT * FROM TypeAbonnement WHERE  TypeAbonnement.Nom =@Nom)
BEGIN 
UPDATE TypeAbonnement 
SET 
	TypeAbonnement.PrixMensuel= @PrixMensuel,
	TypeAbonnement.Prixlocation = @Prixlocation,
	TypeAbonnement.MaxJoursLocation = @MaxJoursLocation,
	TypeAbonnement.NbMaxLocations = @NbMaxLocations,
	TypeAbonnement.PrixRetard = @PrixRetard,
	TypeAbonnement.DureeEngagement = @DureeEngagement 
WHERE 
	TypeAbonnement.Nom =@Nom
END
ELSE 
BEGIN
PRINT 'Ce type d abonnement n existe pas'
END

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
