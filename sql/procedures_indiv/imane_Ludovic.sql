---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Ajoute un nouveau client (Clien)                                            */
/* Auteurs  : RAHMOUN Imane - SAR   ,  GOUYOU Ludovic - TA                     */
/* Testeur : GOUYOU Ludovic - TA                                               */
---------------------------------------------------------------------------------

IF OBJECT_ID ( 'inserer_client', 'P' ) IS NOT NULL 
    DROP PROCEDURE inserer_client;
GO

CREATE PROCEDURE [dbo].[inserer_client]
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Ajoute un nouveau Type d'abonnement (TypeAbonnement)                        */
/* Auteurs  : RAHMOUN Imane - SAR   ,  GOUYOU Ludovic - TA                     */
/* Testeur : GOUYOU Ludovic - TA                                               */
---------------------------------------------------------------------------------

IF OBJECT_ID ( 'inserer_TypeAbonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE inserer_TypeAbonnement;
GO
CREATE PROCEDURE [dbo].[inserer_TypeAbonnement]
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Ajoute un nouveau abonnement (Abonnement)                                   */
/* Auteurs  : RAHMOUN Imane - SAR   ,  GOUYOU Ludovic - TA                     */
/* Testeur : GOUYOU Ludovic - TA                                               */
---------------------------------------------------------------------------------
IF OBJECT_ID ( 'inserer_Abonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE inserer_Abonnement;
GO
CREATE PROCEDURE [dbo].[inserer_Abonnement]
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

---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Réapprovisionne un abonement (Abonnement)                                   */
/* Auteurs  : RAHMOUN Imane - SAR   ,  GOUYOU Ludovic - TA                     */
/* Testeur : GOUYOU Ludovic - TA                                               */
---------------------------------------------------------------------------------
IF OBJECT_ID ( 'ReaprovisionnementCompte', 'P' ) IS NOT NULL 
    DROP PROCEDURE ReaprovisionnementCompte;
GO
CREATE PROCEDURE [dbo].[ReaprovisionnementCompte]
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