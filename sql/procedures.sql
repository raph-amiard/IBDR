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

    DECLARE @vide INT
    SET @vide = 1
    
    /** Vérifier s'il y a 'Editeur' **/
    IF CHARINDEX('|', @ListEditeurs) = 0
	BEGIN
		PRINT 'IL FAUT AJOUTER UN EDITEUR!'
		SET @vide = 0
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
		PRINT 'IL FAUT AJOUTER UNE LANGUE AUDIO!'
		SET @vide = 0
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
		PRINT 'IL FAUT AJOUTER UNE LANGUE SOUS-TITRES!'
		SET @vide = 0
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
	SET @ERROR_LANGUE = 0
	
	--BEGIN TRAN ADD_EDITION
		IF (@vide=1)
		BEGIN 
			INSERT INTO [IBDR_SAR].[dbo].[Edition]
					   ([FilmTitreVF]
					   ,[FilmAnneeSortie]
					   ,[Duree]
					   ,[DateSortie]
					   ,[Support]
					   ,[Couleur]
					   ,[Pays]
					   ,[NomEdition]
					   ,[AgeInterdiction])
				 VALUES
						(@FilmTitreVF,
						convert(smallint,@FilmAnneeSortie),
						convert(time,@Duree,108),
						convert(date,@DateSortie,103),
						@Support,
						@Couleur,
						@Pays,
						@NomEdition,
						@AgeInterdiction)
			
			
			SET @ROWCOUNT = @@ROWCOUNT
			
			IF (@ROWCOUNT = 1)
			BEGIN
				SET @ID_Edition = @@IDENTITY
				PRINT 'EDITION AJOUTE!'
			END
			ELSE
			BEGIN
				PRINT 'EXISTE DEJA UNE EDITION AVEC CE NOM!'
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
					FROM [IBDR_SAR].[dbo].[Editeur]
					WHERE [Nom] = @NomEditeur)
			BEGIN

				INSERT INTO [IBDR_SAR].[dbo].[Editeur]
						   ([Nom])
					 VALUES
						   (@NomEditeur)
				
				PRINT 'EDITEUR "' + cast(@NomEditeur AS NVARCHAR) +'" AJOUTE!'
			END

			INSERT INTO [IBDR_SAR].[dbo].[EditeurEdition]
					   ([IdEdition]
					   ,[NomEditeur])
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
	
			INSERT INTO [IBDR_SAR].[dbo].[EditionLangueAudio]
					   ([IdEdition]
					   ,[NomLangue])
				 VALUES
					   (@ID_Edition
					   ,@LangueAudio)
					   
			SET @ERROR_LANGUE = @ERROR_LANGUE + @@ERROR
						
			SET @index = @fin
			
		END
		
		SET @index = 1
		
		WHILE @index <> LEN(@ListLangueSousTitres) AND @vide=1 AND @ROWCOUNT = 1
		BEGIN
			DECLARE @LangueSousTitres NVARCHAR(64)
			
			SET @fin = CHARINDEX('|', @ListLangueSousTitres, @index+1)
			
			SET @LangueSousTitres = LTRIM(SUBSTRING(@ListLangueSousTitres , @index+1, @fin - @index-1))
			
			INSERT INTO [IBDR_SAR].[dbo].[EditionLangueSousTitres]
				   ([IdEdition]
				   ,[NomLangue])
			 VALUES
				   (@ID_Edition
				   ,@LangueSousTitres)
			SET @ERROR_LANGUE = @ERROR_LANGUE + @@ERROR
			
			SET @index = @fin
			
		END
		
	--IF (@ERROR_LANGUE = 0)
	--BEGIN
	--	COMMIT ADD_EDITION
	--END
	--ELSE
	--BEGIN
	--	ROLLBACK ADD_EDITION
	--	PRINT 'L''OPERATION ANNULEE : UNE LANGUE N''EXISTE PAS !'
	--END
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

    /**
    * Vérifier le nombre d'exemplaires (FilmStock) et le nombre d'exemplaires loués
    **/
	DECLARE @NombreFilmStock INT
	SELECT @NombreFilmStock = COUNT(*) FROM [IBDR_SAR].[dbo].[FilmStock] WHERE [IdEdition] = @ID_Edition
	
	DECLARE @NombreNonLocation INT
	SET @NombreNonLocation = 0
	
	DECLARE @ID_FilmStock INT
	DECLARE FilmStock CURSOR FOR
		SELECT [ID] FROM [IBDR_SAR].[dbo].[FilmStock] WHERE [IdEdition] = @ID_Edition
	OPEN FilmStock
	FETCH NEXT FROM FilmStock
    	INTO @ID_FilmStock
    WHILE @@FETCH_STATUS = 0
    BEGIN
		 		 
		 IF NOT EXISTS (SELECT *
            			FROM [IBDR_SAR].[dbo].[Location]
                        WHERE [FilmStockId] = @ID_FilmStock AND [DateRetourEff] IS NULL )
		BEGIN
			SET @NombreNonLocation = @NombreNonLocation + 1
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
		DECLARE @NomEditeur NVARCHAR(64)
		DECLARE Editeur CURSOR FOR
			SELECT [NomEditeur] FROM [IBDR_SAR].[dbo].[EditeurEdition] WHERE [IdEdition] = @ID_Edition
		OPEN Editeur
		FETCH NEXT FROM Editeur
    		INTO @NomEditeur
		WHILE @@FETCH_STATUS = 0
		BEGIN
			 DELETE FROM [IBDR_SAR].[dbo].[EditeurEdition] WHERE [IdEdition] = @ID_Edition AND [NomEditeur] = @NomEditeur
			 
			 IF NOT EXISTS (SELECT *
            				FROM [IBDR_SAR].[dbo].[EditeurEdition]
							WHERE [NomEditeur] = @NomEditeur)
			BEGIN
				DELETE FROM [IBDR_SAR].[dbo].[Editeur] WHERE [Nom] = @NomEditeur
				
				PRINT 'EDITEUR "' + cast(@NomEditeur AS NVARCHAR) + '" SUPPRIME!'
			END
			
			FETCH NEXT FROM Editeur
    			INTO @NomEditeur
		END
		CLOSE Editeur
		DEALLOCATE Editeur
	    
		DELETE FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition
		PRINT 'EDITION SUPPRIME!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION NE PEUT PAS ETRE SUPPRIME, CAR IL Y A UN EXEMPLAIRE LOUE!'
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
	DECLARE @ROWCOUNT INT
	SET @ROWCOUNT = 0
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		UPDATE [IBDR_SAR].[dbo].[Edition]
		SET [NomEdition] = @NomEdition
		WHERE [ID] = @ID_Edition
		
		SET @ROWCOUNT = @@ROWCOUNT
		
		IF (@ROWCOUNT = 1)
		BEGIN
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'EXISTE DEJA UNE EDITION AVEC CE NOM!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition]  WHERE [ID] = @ID_Edition)
	BEGIN
		UPDATE [IBDR_SAR].[dbo].[Edition]
		SET [Duree] = @Duree
		WHERE [ID] = @ID_Edition
		PRINT 'MIS A JOUR!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		UPDATE [IBDR_SAR].[dbo].[Edition]
		SET [DateSortie] = convert(date,@DateSortie,103)
		WHERE [ID] = @ID_Edition
		PRINT 'MIS A JOUR!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition]  WHERE [ID] = @ID_Edition)
	BEGIN
		UPDATE [IBDR_SAR].[dbo].[Edition]
		SET [Support] = @Support
		WHERE [ID] = @ID_Edition
		PRINT 'MIS A JOUR!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		UPDATE [IBDR_SAR].[dbo].[Edition]
		SET [Couleur] = @Couleur
		WHERE [ID] = @ID_Edition
		PRINT 'MIS A JOUR!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Pays] WHERE [Nom] = @Pays)
		BEGIN
			UPDATE [IBDR_SAR].[dbo].[Edition]
			SET [Pays] = @Pays
			WHERE [ID] = @ID_Edition
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'PAYS N''EXITE PAS!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		UPDATE [IBDR_SAR].[dbo].[Edition]
		SET [AgeInterdiction] = @AgeInterdiction
		WHERE [ID] = @ID_Edition
		PRINT 'MIS A JOUR!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Langue] WHERE [Nom] = @LangueAudio)
		BEGIN
			INSERT INTO [IBDR_SAR].[dbo].[EditionLangueAudio]
					   ([IdEdition]
					   ,[NomLangue])
				 VALUES
					   (@ID_Edition
					   ,@LangueAudio)
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'LANGUE N''EXITE PAS!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Langue] WHERE [Nom] = @LangueSousTitres)
		BEGIN
			INSERT INTO [IBDR_SAR].[dbo].[EditionLangueSousTitres]
					   ([IdEdition]
					   ,[NomLangue])
				 VALUES
					   (@ID_Edition
					   ,@LangueSousTitres)
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'LANGUE N''EXITE PAS!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Langue] WHERE [Nom] = @LangueAudio)
		BEGIN
			DELETE FROM [IBDR_SAR].[dbo].[EditionLangueAudio] 
				WHERE [IdEdition] = @ID_Edition AND [NomLangue] = @LangueAudio
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'LANGUE N''EXITE PAS!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Langue] WHERE [Nom] = @LangueSousTitres)
		BEGIN
			DELETE FROM [IBDR_SAR].[dbo].[EditionLangueSousTitres]
				WHERE [IdEdition] = @ID_Edition AND [NomLangue] = @LangueSousTitres
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'LANGUE N''EXITE PAS!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition]  WHERE [ID] = @ID_Edition)
	BEGIN
	
		DECLARE @NombreEditeurs INT
		SELECT @NombreEditeurs = COUNT(*) FROM [IBDR_SAR].[dbo].[EditeurEdition] WHERE [IdEdition] = @ID_Edition
		
		IF (@NombreEditeurs > 1)
		BEGIN
			DECLARE @Editeur NVARCHAR(64)
			DECLARE Editeur CURSOR FOR
				SELECT [NomEditeur] FROM [IBDR_SAR].[dbo].[EditeurEdition] 
									WHERE [IdEdition] = @ID_Edition AND [NomEditeur] = @NomEditeur
			OPEN Editeur
			FETCH NEXT FROM Editeur
    			INTO @Editeur
			WHILE @@FETCH_STATUS = 0
			BEGIN
				 DELETE FROM [IBDR_SAR].[dbo].[EditeurEdition] WHERE [IdEdition] = @ID_Edition AND [NomEditeur] = @NomEditeur
				 
				 IF NOT EXISTS (SELECT *
            					FROM [IBDR_SAR].[dbo].[EditeurEdition]
								WHERE [NomEditeur] = @NomEditeur)
				BEGIN
					DELETE FROM [IBDR_SAR].[dbo].[Editeur] WHERE [Nom] = @NomEditeur
					PRINT 'EDITEUR "' + cast(@NomEditeur AS NVARCHAR) +'" SUPPRIME!'
				END
				
				FETCH NEXT FROM Editeur
    				INTO @NomEditeur
			END
			CLOSE Editeur
			DEALLOCATE Editeur
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'IMPOSSIBLE SUPPIRMER IL FAUT AU MOINS UN EDITEUR!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @ID_Edition)
	BEGIN
		IF NOT EXISTS (SELECT *
        				FROM [IBDR_SAR].[dbo].[Editeur]
						WHERE [Nom] = @NomEditeur)
		BEGIN

			INSERT INTO [IBDR_SAR].[dbo].[Editeur]
					   ([Nom])
				 VALUES
					   (@NomEditeur)
			PRINT 'EDITEUR "' + cast(@NomEditeur AS NVARCHAR) +'" AJOUTE!'
		END

		INSERT INTO [IBDR_SAR].[dbo].[EditeurEdition]
				   ([IdEdition]
				   ,[NomEditeur])
			 VALUES
				   (@ID_Edition
				   ,@NomEditeur)
		PRINT 'MIS A JOUR!'
	END
	ELSE
	BEGIN
		PRINT 'EDITION N''EXITE PAS!'
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
		
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Editeur] WHERE [Nom] = @NomEditeur)
	BEGIN
					
		UPDATE [IBDR_SAR].[dbo].[Editeur]
		SET [Nom] = @NomEditeurNouv
		WHERE [Nom] = @NomEditeur
		
		SET @ROWCOUNT = @@ROWCOUNT
		
		IF (@ROWCOUNT = 1)
		BEGIN 
			PRINT 'MIS A JOUR!'
		END
		ELSE
		BEGIN
			PRINT 'EXISTE DEJA UN EDITEUR AVEC CE NOM!'
		END
	END
	ELSE
	BEGIN
		PRINT 'EDITEUR N''EXITE PAS!'
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
	IF EXISTS (SELECT * FROM [IBDR_SAR].[dbo].[Edition] WHERE [ID] = @IdEdition)
	BEGIN
		WHILE @Nombre > 0
		BEGIN
			INSERT INTO [IBDR_SAR].[dbo].[FilmStock]
					   ([DateArrivee]
					   ,[Usure]
					   ,[IdEdition])
				 VALUES
					   (convert(datetime,@DateArrivee,103) 
					   ,@Usure
					   ,@IdEdition)
		
			SET @Nombre -= 1	
			PRINT 'UN EXEMPLAIRE AJOUTE!'				  
		END				   
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
	IF NOT EXISTS (SELECT *
            			FROM [IBDR_SAR].[dbo].[Location]
                        WHERE [FilmStockId] = @ID_FilmStock  AND [DateRetourEff] IS NULL)
		BEGIN
			DELETE FROM [IBDR_SAR].[dbo].[FilmStock] WHERE [ID] = @ID_FilmStock
			PRINT 'EXEMPLAIRE SUPPRIME!'
		END
	ELSE
		BEGIN
			PRINT 'EXEMPLAIRE NE PEUT PAS ETRE SUPPRIME, CAR IL EST LOUE!'	
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
		
	
	ELSE /* film absent du catalogue, a inserer */
		BEGIN TRY
			Print 'L''ajout du film '+ cast(@titre_VF as varchar)+ ' dans la tables Film';
		
			INSERT into Film VALUES ( @titre_VF, @complement_titre, @titre_VO, 
								 @annee_Sortie, @synopsis, @langue, @site_web);
			
		END TRY
		
		BEGIN CATCH
			Print 'Erreur lors de l''insertion du film';
			Print ERROR_MESSAGE();
			return 0;
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
					
						INSERT FilmActeur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					
				END Try
				Begin Catch
					Print 'Erreur lors de l''ajouter de '+cast(@nom_act as varchar)+' '+cast(@pre_act as varchar)+' '+cast(@alias_act as varchar)+' dans la tables FILMActeur';
						Print ERROR_MESSAGE();
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, insérer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'L''acteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, insérer dans la table Personne';				
					Begin Try
					
							INSERT Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
							INSERT FilmActeur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
					
					END Try
					Begin Catch
						Print 'Erreur lors de l''ajouter  de l''acteur : '+cast(@nom_act as varchar)+' '+cast(@pre_act as varchar)+' '+cast(@alias_act as varchar);
						Print ERROR_MESSAGE();
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
				Print 'L''acteur '+cast(@nom_act as varchar)+' existe déjà dans la table Personne';	
				Begin Try
					
						INSERT FilmRealisateur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					
				END Try
				Begin Catch
					Print 'Erreur lors de l''ajouter de '+cast(@nom_act as varchar)+' '+cast(@pre_act as varchar)+' '+cast(@alias_act as varchar)+' dans la tables FilmRéalisateur';
					
					Print ERROR_MESSAGE();
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, insérer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'L''acteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, insérer dans la table Personne';				
					Begin Try
						
							INSERT Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
							INSERT FilmRealisateur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
						
					END Try
					Begin Catch
						Print 'Erreur lors de l''ajouter de '+cast(@nom_act as varchar)+' '+cast(@pre_act as varchar)+' '+cast(@alias_act as varchar);
						Print ERROR_MESSAGE();
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
				Print 'L''acteur '+cast(@nom_act as varchar)+' existe déjà dans la table Personne';	
				Begin Try
					Begin Tran
						INSERT FilmActeur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					Commit Tran
				END Try
				Begin Catch
					Print 'Erreur lors de l''ajouter de '+cast(@nom_act as varchar)+' '+cast(@pre_act as varchar)+' '+cast(@alias_act as varchar)+' dans la tables FilmProducteur';
						Print ERROR_MESSAGE();
				End Catch
			End
			ELSE /* le producteur n'existe pas dans la table Producteurs, insérer dans la table Producteurs et dans la table Joue  */
				BEGIN
					Print 'Le producteur '+cast(@nom_act as varchar)+' n''existe pas dans la table Personne, insérer dans la table Personne';				
					Begin Try
						Begin Tran
							INSERT Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
							INSERT FilmActeur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
						Commit Tran
					END Try
					Begin Catch
						Print 'Erreur lors de l''ajouter  du producteur : '+cast(@nom_act as varchar)+' '+cast(@pre_act as varchar)+' '+cast(@alias_act as varchar);
						Print ERROR_MESSAGE();
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
					Begin Tran
						INSERT FilmGenre Values (@titre_VF,@annee_Sortie,@genre_film)
					Commit Tran
				END Try
				Begin Catch
					Print 'Erreur lors de le genre '+cast(@genre_film as varchar);
					Print ERROR_MESSAGE();
				End Catch
			End
			ELSE /* l'acteur n'existe pas dans la table Acteurs, insérer dans la table Acteurs et dans la table Joue  */
				BEGIN
					Print 'Le genre : '+cast(@genre_film as varchar)+' n''existe pas dans la table Genre';				
					Print 'Veuillez l''inserer avant.'
					/*
					Begin Try
						Begin Tran
							INSERT Genre Values (@genre_film);
							INSERT FilmGenre Values (@titre_VF,@annee_Sortie,@genre_film);
						Commit Tran
					END Try
					Begin Catch
						Print 'Erreur lors de le genre '+cast(@genre_film as varchar);
						Print ERROR_MESSAGE();
					End Catch
					*/
				END
		END
	
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
		RAISERROR('%s %s : personne n''existe pas dans la tables personne', 16, 1, @nom_pers, @prenom_pers);
		
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
		RAISERROR('%s : personne n''existe pas dans la tables personne', 16, 1, @titre_VF);
	
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 16, 1, @titre_VF);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act)
	
	--créer le lien entre film et personne
	Insert FilmActeur values(@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
	
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
	Insert FilmRealisateur values(@titre_VF,@annee_Sortie,@nom_real,@pre_real,@alias_real);
	
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
		
	Delete FilmRealisateur where FilmRealisateur.Nom=@titre_VF AND FilmRealisateur.AnneeSortie=@annee_Sortie AND
							FilmRealisateur.Nom=@nom_real AND FilmRealisateur.Prenom=@pre_real AND
							FilmRealisateur.Alias=@alias_real;
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
	Insert FilmRealisateur values(@titre_VF,@annee_Sortie,@nom_prod,@pre_prod,@alias_prod);
	
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
		
	Delete FilmRealisateur where FilmRealisateur.Nom=@titre_VF AND FilmRealisateur.AnneeSortie=@annee_Sortie AND
							FilmRealisateur.Nom=@nom_prod AND FilmRealisateur.Prenom=@pre_prod AND
							FilmRealisateur.Alias=@alias_prod;
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
	
	Insert FilmDistinction Values(@annee_dist,@titre_VF,@annee_film,@nom_dist);
	
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
	Insert PersonneDistinction Values(@annee_dist,@titre_VF,@annee_film,@nom_dist,@nom_pers,@pre_pers,@alias_pers);
	
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
	--vérifié si le film existe
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0 /* film déjà au catalogue */
		begin
			print cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar)+' film n''est pas dans le catalogue';
			return 0;
		end
		
	--verifié qu'il n'y a pas d'edition lié à ce film
	Select @tmp=count(*) From Edition where Edition.FilmTitreVF=@titre_VF AND 
				Edition.FilmTitreVF=@annee_Sortie;
	IF @tmp>0 /* il y a au moins un film relié à edition */
		begin
			Print 'Impossible de supprimer  film :'+cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar);
			print 'Film en relation avec Edition. Supprimer tous ces edition avant de le suprimer!';
			return 0;
		end
	--On supprime en cascade le film
	
		Begin
			print 'Suppréssion du film :'+cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar)+' des tables FilmActeur,FilmRéalisateur,FilmGenre,FilmProducteur, FilmDistinction';
			Begin Try
				Begin Tran
					Delete FilmActeur Where FilmActeur.TitreVF=@titre_VF and FilmActeur.AnneeSortie=@annee_Sortie;
					Delete FilmDistinction Where FilmDistinction.TitreVF=@titre_VF and FilmDistinction.AnneeSortie=@annee_Sortie;
					Delete FilmGenre Where FilmGenre.TitreVF=@titre_VF and FilmGenre.AnneeSortie=@annee_Sortie;
					Delete FilmProducteur Where FilmProducteur.TitreVF=@titre_VF and FilmProducteur.AnneeSortie=@annee_Sortie;
					Delete FilmRealisateur Where FilmRealisateur.TitreVF=@titre_VF and FilmRealisateur.AnneeSortie=@annee_Sortie;
					Delete PersonneDistinction Where PersonneDistinction.TitreVF=@titre_VF and PersonneDistinction.AnneeSortie=@annee_Sortie;
					Delete Film Where Film.TitreVF=@titre_VF and Film.AnneeSortie=@annee_Sortie;
					
				Commit Tran
			End Try
			Begin Catch
				Print 'Erreur lors de la suppréssion du film :'+cast(@titre_VF as varchar)+', '+cast(@annee_Sortie as varchar);
			End Catch
			
			
		End
		
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de création d'un client                 */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : GOUYOU Ludovic - TA                     */
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
	@NumRue		   INT,
	@TypeRue	   NVARCHAR(64),
	@NomRue            NVARCHAR(128),
	@ComplementAdresse NVARCHAR(256),
	@CodePostal        NVARCHAR(10),
	@Ville             NVARCHAR(64)
)
AS
BEGIN
	-- Insère le client
	INSERT 	INTO CLIENT
                   (
			Civilite  ,        
			Nom        ,      
			Prenom      ,      
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
END

GO


-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de création d'un client                 */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : GOUYOU Ludovic - TA                     */
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
	-- Insère Type Abonnement
	INSERT INTO TypeAbonnement
                   (
			Nom, 
			PrixLocation,
			PrixMensuel,  
			MaxJoursLocation, 
			NbMaxLocations,
			PrixRetard,  
			DureeEngagement) 

            VALUES (	  
			@Nom, 
			@PrixLocation,
			@PrixMensuel, 
			@MaxJoursLocation, 
			@NbMaxLocations,
			@PrixRetard, 
			@DureeEngagement      
			  )
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de creation d'un abonnement             */
/* Auteur  : RAHMOUN Imane - SAR                     */
/* Testeur : GOUYOU Ludovic - TA                     */
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
			  print @@IDENTITY
END
GO

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procedure de réapprovisionnement d'un compte      */
/* Auteur  : RAHMOUN Imane - SAR, GOUYOU Ludovic - TA*/
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
/* Vue des films arrivés                             */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.V_FILMSTOCKS') IS NOT NULL)
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
IF (OBJECT_ID('dbo.location_rendre') IS NOT NULL)
  DROP PROCEDURE dbo.location_rendre
GO
CREATE PROCEDURE dbo.location_rendre(@id_filmstock INT)
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

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure privée pour ajouter une location        */
/* NE PAS UTILISER DIRECTEMENT                       */
/* Utiliser location_ajouter ou reservation_ajouter  */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo._ajouter_location') IS NOT NULL)
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
	END
END

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure pour confirmer une location             */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.location_confirmer') IS NOT NULL)
  DROP PROCEDURE dbo.location_confirmer
GO
CREATE PROCEDURE dbo.location_confirmer(@id_location INT)
AS
BEGIN
    -- TODO : Ajouter check temps, impossible de confirmer réservation en dehors d'un intervalle défini
    UPDATE Location
    SET Confirmee = 1
    WHERE Id = @id_location
END

-------------------------------------------------------
/* IBDR 2013 - Groupe SAR                            */
/* Procédure pour ajouter une location               */
/* Auteur  : AMIARD Raphaël - SAR                    */
/* Testeur : AMIARD Raphaël - SAR                    */
-------------------------------------------------------
IF (OBJECT_ID('dbo.location_ajouter') IS NOT NULL)
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
