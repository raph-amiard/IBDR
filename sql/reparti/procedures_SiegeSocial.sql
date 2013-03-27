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
		RAISERROR('Ce film n''existe pas dans la base donn�e!', 11, 1);
		RETURN
	END
	
	IF @NomEdition = '' OR @NomEdition = ' '
	BEGIN
		RAISERROR('Le nom d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE NomEdition = @NomEdition)
	BEGIN
		RAISERROR('Existe d�j� une edition avec ce nom!', 11, 1);
		RETURN
	END
	
	IF @Duree = '' OR @Duree = ' '
	BEGIN
		RAISERROR('La duree d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF @DateSortie = '' OR @DateSortie = ' '
	BEGIN
		RAISERROR('La date de sortie d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF @Support = '' OR @Support = ' '
	BEGIN
		RAISERROR('Le support d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END

	IF NOT EXISTS (SELECT *	FROM Pays WHERE Nom = @Pays )
	BEGIN
		RAISERROR('Ce pays n''existe pas dans la base donn�e!', 11, 1);
		RETURN
	END
	
	IF @AgeInterdiction = '' OR @AgeInterdiction = ' '
	BEGIN
		RAISERROR('L''age d''interdiction d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
    DECLARE @vide INT
    SET @vide = 1
    
    /** V�rifier s'il y a 'Editeur' **/
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
	
	/** V�rifier s'il y a 'LangueAudio' **/
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
	
	/** V�rifier s'il y a 'LangueSousTitres' **/
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
				
				PRINT 'Editeur "' + cast(@NomEditeur AS NVARCHAR) +'" ajout�!'
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
				RAISERROR('L''op�ration avort�e : cette langue n''existe pas dans la base donn�e!', 11, 1);
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
				RAISERROR('L''op�ration avort�e : cette langue n''existe pas dans la base donn�e!', 11, 1);
				ROLLBACK TRAN ADD_EDITION
				RETURN
			END CATCH
			
			SET @index = @fin
			
		END
	
	COMMIT TRAN ADD_EDITION
	PRINT 'Edition "' + cast(@NomEdition AS NVARCHAR) +'" ajout�e!'
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
    * V�rifier le nombre d'exemplaires (FilmStock) et le nombre d'exemplaires lou�s
    * et supprimer les exemplaire que ne sont pas lou�
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
				RAISERROR('L''op�ration avort�e : erreur en supprimer exemplaire!', 11, 1);
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
    -- FIN de v�rifier le nombre d'exemplaires (FilmStock) et le nombre d'exemplaires lou�s
    
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
						
						PRINT 'Editeur "' + cast(@NomEditeur AS NVARCHAR) + '" supprim�!'
					END
				END TRY
				BEGIN CATCH		
					RAISERROR('L''op�ration avort�e : erreur en supprimer editeur!', 11, 1);
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
				RAISERROR('L''op�ration avort�e : erreur en supprimer edition!', 11, 1);
				ROLLBACK TRAN SUPP_EDITION
				RETURN
			END CATCH
			
			PRINT 'Edition supprim�e!'
		COMMIT TRAN SUPP_EDITION
	END
	ELSE
	BEGIN
		UPDATE Edition SET Supprimer = 1 WHERE ID = @ID_Edition		
		RAISERROR('Edition ne peut pas �tre supprim�e, car il y a un examplaire lou�!', 11, 1);
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
		RAISERROR('Le nom d''edition ne peut pas �tre vide!', 11, 1);
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
			PRINT 'Mis � jour le nom!'
		END
		ELSE
		BEGIN
			RAISERROR('Existe d�j� une edition avec ce nom!', 11, 1);
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
		RAISERROR('La duree d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET Duree = @Duree WHERE ID = @ID_Edition
		PRINT 'Mis � jour la dur�e!'
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
		RAISERROR('La date de sortie d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET DateSortie = convert(date,@DateSortie,103)WHERE ID = @ID_Edition
		PRINT 'Mis � jour la date de sortie!'
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
		RAISERROR('Le support d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition  WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET Support = @Support WHERE ID = @ID_Edition
		PRINT 'Mis � jour le support!'
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
		PRINT 'Mis � jour la couleur!'
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
			PRINT 'Mis � jour le pays!'
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
		RAISERROR('L''age d''interdiction d''edition ne peut pas �tre vide!', 11, 1);
		RETURN
	END
	
	IF EXISTS (SELECT * FROM Edition WHERE ID = @ID_Edition)
	BEGIN
		UPDATE Edition SET AgeInterdiction = @AgeInterdiction WHERE ID = @ID_Edition
		PRINT 'Mis � jour l''age d''interdiction!'
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
			PRINT 'La langue d''audio a �t� ajout�e!'
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
			PRINT 'La langue de sous-titres a �t� ajout�e!'
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
				PRINT 'La langue d''audio a �t� supprim�e!'
			END
			ELSE
			BEGIN
				RAISERROR('La langue d''audio ne peut pas �tre supprimer, car il faut au moins une langue � l''edition!', 11, 1);
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
			PRINT 'La langue de sous-titres a �t� supprim�e!'
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
					PRINT 'L''editeur "' + cast(@NomEditeur AS NVARCHAR) +'" a �t� supprim� de la base donn�es!'
				END
				
				FETCH NEXT FROM Editeur
    				INTO @NomEditeur
			END
			CLOSE Editeur
			DEALLOCATE Editeur
			PRINT 'L''editeur a �t� supprim� de l''edition!'
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
		RAISERROR('Le nom d''editeur ne peut pas �tre vide!', 11, 1);
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
			PRINT 'L''editeur "' + cast(@NomEditeur AS NVARCHAR) +'" a �t� ajout� � la base donn�es!'
		END

		INSERT INTO EditeurEdition
				   (IdEdition
				   ,NomEditeur)
			 VALUES
				   (@ID_Edition
				   ,@NomEditeur)
		PRINT 'L''editeur a �t� ajout� � l''edition!'
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
			PRINT 'Mis � jour le nom!'
		END
		ELSE
		BEGIN
		RAISERROR('Existe d�j� un editeur avc ce nom!', 11, 1);
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
	-- pas de film sans r�alisateur
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
			print 'Un film doit au moins avoir un r�alisateur';
			return 0;
		END
	
	IF CHARINDEX('|',@liste_genres)=0
		RAISERROR('Un film doit au moins avoir un genre', 16, 1);
	
		
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp>= 1 /* film d�j� au catalogue */
	
		RAISERROR('%s %d : film d�j� au catalogue', 16, 1, @titre_VF, @annee_Sortie);
		
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
			
			--Pr�nom
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
			
			--v�rifi� si la personne existe d�ja dans la base de donn�es
			Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
			IF @tmp = 1 -- elle �xiste 
			Begin
				Print 'L''acteur '+cast(@nom_act as varchar)+' existe d�j� dans la table Personne';	
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
			ELSE /* l'acteur n'existe pas dans la table Acteurs, ins�rer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'L''acteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, ins�rer dans la table Personne';				
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
			
			--Pr�nom
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
			
			--v�rifi� si la personne existe d�ja dans la base de donn�es
			Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
			IF @tmp = 1 -- elle �xiste 
			Begin
				Print 'Le r�alisateur '+cast(@nom_act as varchar)+' existe d�j� dans la table Personne';	
				Begin Try
					
						INSERT FilmRealisateur (TitreVF,AnneeSortie,Nom,Prenom,Alias)
							Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					
				END Try
				Begin Catch
					ROLLBACK TRAN @TransactionMain;
					Print ERROR_MESSAGE();
					RAISERROR('Erreur lors de l''ajouter de "%s %s" dans la tables FilmR�alisateur : ', 16, 1, @nom_act,@pre_act);
					
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, ins�rer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'Le r�alisateur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, ins�rer dans la table Personne';				
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
			
			--Pr�nom
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
			
			--v�rifi� si la personne existe d�ja dans la base de donn�es
			Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
			IF @tmp = 1 -- elle �xiste 
			Begin
				Print 'Le producteur '+cast(@nom_act as varchar)+' existe d�j� dans la table Personne';	
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
			ELSE /* le producteur n'existe pas dans la table Producteurs, ins�rer dans la table Producteurs et dans la table Joue  */
				BEGIN
					Print 'Le producteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, ins�rer dans la table Personne';				
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
			
			--v�rifi� si la personne existe d�ja dans la base de donn�es
			Select @tmp = count(*) from Genre Where Genre.Nom=@genre_film;
			IF @tmp = 1 -- le genre �xiste d�j�
			Begin
				--Print 'Le genre '+cast(@genre_film as varchar)+' existe d�j� dans la table Genre';	
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
			ELSE /* l'acteur n'existe pas dans la table Acteurs, ins�rer dans la table Acteurs et dans la table Joue  */
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
	--v�rifi� si la personne existe d�j�	
	Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act)
	
	--cr�er le lien entre film et personne
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
	--v�rifi� si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0--no, erreur
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
		
	--v�rifi� si la personne existe d�j�	
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
/* Procedure d'ajout d'un r�alisateur a un film  */
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
	--v�rifi� si la personne existe d�j�	
	Select @tmp = count(*) from Personne Where Nom=@nom_real And Prenom=@pre_real And Alias=@alias_real
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_real,@pre_real,@alias_real,@dat_real,@dat_deces_real,@biographie_real)
	
	--cr�er le lien entre film et personne
	Insert FilmRealisateur(TitreVF,AnneeSortie,Nom,Prenom,Alias)
			 values(@titre_VF,@annee_Sortie,@nom_real,@pre_real,@alias_real);
	
	Print 'Le r�alisateur '+@nom_real+' '+@pre_real+' est bien ins�r� pour '+@titre_VF+' '+@annee_Sortie;
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
	--v�rifi� si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0--no, erreur
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
		
	--v�rifi� si la personne existe d�j�	
	Select @tmp = count(*) from Personne Where Nom=@nom_real And Prenom=@pre_real And Alias=@alias_real
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 16, 1, @nom_real,@pre_real);
		
	Delete FilmRealisateur where FilmRealisateur.TitreVF=@titre_VF AND FilmRealisateur.AnneeSortie=@annee_Sortie AND
							FilmRealisateur.Nom=@nom_real AND FilmRealisateur.Prenom=@pre_real AND
							FilmRealisateur.Alias=@alias_real;
							
	Print 'Le r�alisateur '+@nom_real+' '+@pre_real+' est bien suprrimer de '+@titre_VF+' '+@annee_Sortie;
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
	--v�rifi� si la personne existe d�j�	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_prod,@pre_prod,@alias_prod,@dat_prod,@dat_deces_prod,@biographie_prod)
	
	--cr�er le lien entre film et personne
	Insert FilmProducteur(TitreVF,AnneeSortie,NomProducteur,PrenomProducteur,AliasProducteur)
			values(@titre_VF,@annee_Sortie,@nom_prod,@pre_prod,@alias_prod);
	
	Print 'Le producteur '+@nom_prod+' '+@pre_prod+' est bien ins�r� pour '+@titre_VF+' '+@annee_Sortie;
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
	--v�rifi� si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0--no, erreur
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
		
	--v�rifi� si la personne existe d�j�	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 16, 1, @nom_prod,@pre_prod);
		
	Delete FilmProducteur where FilmProducteur.TitreVF=@titre_VF AND FilmProducteur.AnneeSortie=@annee_Sortie AND
							FilmProducteur.NomProducteur=@nom_prod AND FilmProducteur.PrenomProducteur=@pre_prod AND
							FilmProducteur.AliasProducteur=@alias_prod;
							
							
	Print 'Le producteur '+@nom_prod+' '+@pre_prod+' est bien supprim� de '+@titre_VF+' '+@annee_Sortie;
	
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
	--v�rifi� si le film existe
	Select @tmp = count(*) from Film Where Film.TitreVF=@titre_VF And Film.AnneeSortie=@annee_film;
	IF @tmp=0--No, erreur
		RAISERROR('%s %d: Film n''existe pas dans le catalogue', 16, 1, @titre_VF,@annee_film);
	
	--v�rifi� si la distionction existe d�j�
	Select @tmp = count(*) from TypeDistinction Where TypeDistinction.Nom=@nom_dist;
	IF @tmp=0--No, inserer la
		Insert TypeDistinction Values (@nom_dist);
	
	Insert FilmDistinction (Annee,TitreVF,AnneeSortie,NomDistinction)
			 Values(@annee_dist,@titre_VF,@annee_film,@nom_dist);
	
	Print 'Le distinction '+@nom_dist+' est bien rajout� pour '+@titre_VF;
		
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
	
	--v�rifi� si le film existe
	IF(@titre_VF=null)
		Begin
			Select @tmp = count(*) from Film Where Film.TitreVF=@titre_VF And Film.AnneeSortie=@annee_film;
			IF @tmp=0--No, erreur
				RAISERROR('%s %d: Film n''existe pas dans le catalogue', 16, 1, @titre_VF,@annee_film);
		
		END
	
	--v�rifi� si la personne existe d�j�	
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@pre_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s: Personne n''existe pas dans le catalogue', 16, 1,@nom_pers,@pre_pers);
	--v�rifi� si la distionction existe d�j�
	Select @tmp = count(*) from TypeDistinction Where TypeDistinction.Nom=@nom_dist;
	IF @tmp=0--No, inserer la
		Insert TypeDistinction Values (@nom_dist);

	--inserer la distionction	
	Insert PersonneDistinction (Annee,TitreVF,AnneeSortie,NomDistinction,Nom,Prenom,Alias)
			Values(@annee_dist,@titre_VF,@annee_film,@nom_dist,@nom_pers,@pre_pers,@alias_pers);
	
	Print 'Le distinction '+@nom_dist+' est bien rajout� pour '+@titre_VF+' '+@annee_film;
END
GO

 -------------------------------------
/* IBDR 2013 � Groupe SAR		  */
/* Precedure du suppression des 
   personnes non r�f�renci�s      */
/* Auteur : AISSAT Mustapha - SAR */
/* Testeur : AISSAT Mustapha      */
-------------------------------------
IF OBJECT_ID ('Personne_nettoyage') IS NOT NULL
    DROP PROCEDURE Personne_nettoyage
GO
--procedure periodique pour supprimer les distinction plus r�f�renc�
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
    --it�rer  sur la list des personnes non r�f�renci�s
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



	--v�rifi� si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0 /* film d�j� au catalogue */
		begin
			print cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar)+' film n''est pas dans le catalogue';
			
			return 0;
		end
		
BEGIN TRAN @TransactionMain	
	Begin Try	
		--indiquer que le film est supprimer
		Update Film set IsDeleted=1 Where Film.TitreVF=@titre_VF AND 
					Film.AnneeSortie=@annee_Sortie;
					
		
		--supprimer les �ditions
		
		
		DECLARE @id_edition INT;
	
		DECLARE EdtionToDelete CURSOR FOR
			Select id From dbo.Edition where Edition.FilmTitreVF=@titre_VF AND 
					Edition.FilmTitreVF=@annee_Sortie;
				

		OPEN EdtionToDelete
		FETCH NEXT FROM EdtionToDelete
    		INTO @id_edition
		--it�rer  sur la list des personnes non r�f�renci�s
		WHILE @@FETCH_STATUS = 0
		BEGIN
			--Print 'suppression de N�: '+cast(@id_edition as varchar);
			Exec IBDR_SAR.dbo.edition_supprimer @id_edition;
			
			FETCH NEXT FROM EdtionToDelete
    			INTO @id_edition
		END
		CLOSE EdtionToDelete
		DEALLOCATE EdtionToDelete		
				
				--//TODO		
			
		--On supprime en cascade le film
		
		Begin
			print 'Suppr�ssion du film :'+cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar)+' des tables FilmActeur,FilmR�alisateur,FilmGenre,FilmProducteur, FilmDistinction';
			
				
			Delete FilmActeur Where FilmActeur.TitreVF=@titre_VF and FilmActeur.AnneeSortie=@annee_Sortie;
			Delete FilmDistinction Where FilmDistinction.TitreVF=@titre_VF and FilmDistinction.AnneeSortie=@annee_Sortie;
			Delete FilmGenre Where FilmGenre.TitreVF=@titre_VF and FilmGenre.AnneeSortie=@annee_Sortie;
			Delete FilmProducteur Where FilmProducteur.TitreVF=@titre_VF and FilmProducteur.AnneeSortie=@annee_Sortie;
			Delete FilmRealisateur Where FilmRealisateur.TitreVF=@titre_VF and FilmRealisateur.AnneeSortie=@annee_Sortie;
			Delete PersonneDistinction Where PersonneDistinction.TitreVF=@titre_VF and PersonneDistinction.AnneeSortie=@annee_Sortie;
			exec dbo.Personne_nettoyage ;
			
			--verifi� qu'il n'y a pas d'edition li� � ce film
			Select @tmp=count(*) From Edition where Edition.FilmTitreVF=@titre_VF AND 
					Edition.FilmTitreVF=@annee_Sortie;
					
			IF @tmp=0
				Delete Film Where Film.TitreVF=@titre_VF and Film.AnneeSortie=@annee_Sortie;
					
		End	
			
	End Try
	Begin Catch
		ROLLBACK TRAN @TransactionMain;
		Print ERROR_MESSAGE();
		RAISERROR('Erreur lors de la suppr�ssion du film %s %d : ', 16, 1,@titre_VF ,@annee_Sortie );
		
	End Catch

Commit TRAN @TransactionMain		
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de cr�ation d'un type d'abonnement      */
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
		RAISERROR(' Le nom  ne doit pas �tre null', 9, 1);
		RETURN;
	END	
	IF @PrixMensuel IS NULL
	BEGIN
		RAISERROR(' le prix mensuel ne doit pas �tre null', 9, 1);
		RETURN;
	END
	
	IF @PrixLocation IS NULL
	BEGIN
		RAISERROR(' le prix location ne doit pas �tre null', 9, 1);
		RETURN;
	END
	
	IF @MaxJoursLocation IS NULL
	BEGIN
		RAISERROR(' le nombre de jour de location ne doit pas �tre null', 9, 1);
		RETURN;
	END
	
	IF @NbMaxLocations IS NULL
	BEGIN
		RAISERROR(' Nombe de location ne doit pas �tre null', 9, 1);
		RETURN;
	END
	
	IF @PrixRetard IS NULL
	BEGIN
		RAISERROR(' le prix du retard ne doit pas �tre null', 9, 1);
		RETURN;
	END
	
	IF @DureeEngagement IS NULL
	BEGIN
		RAISERROR(' La duree d''engagement  ne doit pas �tre null', 9, 1);
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
		-- Ins�re Type Abonnement
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
		PRINT 'Type Abonnement bien ajout�'			
	END
	ELSE
	BEGIN
		RAISERROR('Ce type d''abonnement existe deja', 9, 1);   
	END
END
GO


-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Proc�dure de supression d'un type d'abonnement    */
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
	PRINT 'Il esxiste un abonnement utilisant ce type d''abonnement mise � jour du flag'
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
/* Proc�dure de modification d'un type d'abonnement  */
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