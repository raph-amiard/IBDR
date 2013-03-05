---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour ajouter une Edition                                          */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_insert_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour supprimer une Edition                                        */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_delete_edition
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
	
---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'NomEdition'           */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_nom_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'Duree'                */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_duree_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'DateSortie'           */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_date_sortie_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'Support'              */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_support_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'Couleur'              */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_couleur_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'Pays'                 */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_pays_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition de l'attribut 'AgeInterdiction'      */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_age_interdi_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition en ajoutant une langue audio         */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_insert_langueaudio_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition en ajoutant une langue sous-titres   */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_insert_languesoustitres_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition en supprimant une langue audio         */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_delete_langueaudio_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition en supprimant une langue sous-titres */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_delete_languesoustitres_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition en supprimant un editeur             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_supp_editeur_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour l'edition en ajoutant un nouveau editeur       */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_ajout_editeur_edition
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour mettre à jour un editeur                                       */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_update_editeur
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