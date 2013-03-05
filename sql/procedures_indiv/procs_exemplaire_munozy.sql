---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour ajouter un ensemble d'exemplaires (FilmStock)                */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_insert_exemplaire
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Procedure pour supprimer un exemplaire (FilmStock)                          */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE proc_delete_exemplaire
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