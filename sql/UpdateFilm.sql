 -------------------------------------
/* IBDR 2013 – Groupe SAR */
/* Precedures modifier film,personne,distinction */
/* Auteur : AISSAT Mustapha - SAR */
/* Testeur :   */
-------------------------------------


Use IBDR_SAR
GO

IF OBJECT_ID ('set_date_deces_personne') IS NOT NULL
    DROP PROCEDURE set_date_deces_personne
GO
--Mettre à jours la date déces d'une personne
CREATE PROCEDURE [dbo].[set_date_deces_personne]
	@nom_pers NVARCHAR(64) ,
    @prenom_pers NVARCHAR(64),
    @alias_pers NVARCHAR(64),
    @date_deces DATE
AS
BEGIN
	declare @tmp int
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s : personne n''existe pas dans la tables personne', 128, 1, @nom_pers, @prenom_pers);
		
	Update Personne Set Personne.DateDeces=@date_deces Where  Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers  
END 
GO

IF OBJECT_ID ('set_bio_personne') IS NOT NULL
    DROP PROCEDURE set_bio_personne
GO
--Mettre à jours la biographie d'une personne
CREATE PROCEDURE [dbo].[set_bio_personne]
	@nom_pers NVARCHAR(64) ,
    @prenom_pers NVARCHAR(64),
    @alias_pers NVARCHAR(64),
    @bio_pers NVARCHAR(500)
AS
BEGIN
	declare @tmp int
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s : personne n''existe pas dans la tables personne', 128, 1, @nom_pers, @prenom_pers);
		
	Update Personne Set Personne.Biographie=@bio_pers Where  Nom=@nom_pers And Prenom=@prenom_pers And Alias=@alias_pers  
END 
GO


IF OBJECT_ID ('set_siteWeb_film') IS NOT NULL
    DROP PROCEDURE set_siteWeb_film
GO

--MAJ du site web du film
CREATE PROCEDURE [dbo].[set_siteWeb_film]
	@titre_VF NVARCHAR(128),
	@annee_Sortie SMALLINT,
	@site_web NVARCHAR(512)
AS
BEGIN
	declare @tmp int;
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp=0
		RAISERROR('%s : personne n''existe pas dans la tables personne', 128, 1, @titre_VF);
	
	Update Film Set Film.SiteWeb=@site_web where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	
	
END  
GO

IF (OBJECT_ID('add_acteur_film') IS NOT NULL)
  DROP PROCEDURE add_acteur_film
GO

-- ajouter un acteur à un film
CREATE PROCEDURE [dbo].[add_acteur_film]
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 128, 1, @titre_VF);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act)
	
	--créer le lien entre film et personne
	Insert FilmActeur values(@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
	
END	
GO


IF (OBJECT_ID('del_acteur_film') IS NOT NULL)
  DROP PROCEDURE del_acteur_film
GO
--supprimer le lien entre film et acteur
CREATE PROCEDURE [dbo].[del_acteur_film]
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 128, 1, @titre_VF);
		
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_act And Prenom=@pre_act And Alias=@alias_act
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 128, 1, @nom_act,@pre_act);
		
	Delete FilmActeur where FilmActeur.Nom=@titre_VF AND FilmActeur.AnneeSortie=@annee_Sortie AND
							FilmActeur.Nom=@nom_act AND FilmActeur.Prenom=@pre_act AND
							FilmActeur.Alias=@alias_act;
END		
GO

IF (OBJECT_ID('add_realisateur_film') IS NOT NULL)
  DROP PROCEDURE add_realisateur_film
GO

CREATE PROCEDURE [dbo].[add_realisateur_film]
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 128, 1, @titre_VF);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_real And Prenom=@pre_real And Alias=@alias_real
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_real,@pre_real,@alias_real,@dat_real,@dat_deces_real,@biographie_real)
	
	--créer le lien entre film et personne
	Insert FilmRealisateur values(@titre_VF,@annee_Sortie,@nom_real,@pre_real,@alias_real);
	
End
GO


IF (OBJECT_ID('del_realisateur_film') IS NOT NULL)
  DROP PROCEDURE del_realisateur_film
GO

CREATE PROCEDURE [dbo].[del_realisateur_film]
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 128, 1, @titre_VF);
		
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_real And Prenom=@pre_real And Alias=@alias_real
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 128, 1, @nom_real,@pre_real);
		
	Delete FilmRealisateur where FilmRealisateur.Nom=@titre_VF AND FilmRealisateur.AnneeSortie=@annee_Sortie AND
							FilmRealisateur.Nom=@nom_real AND FilmRealisateur.Prenom=@pre_real AND
							FilmRealisateur.Alias=@alias_real;
END			
GO


IF (OBJECT_ID('add_producteur_film') IS NOT NULL)
  DROP PROCEDURE add_producteur_film
GO

CREATE PROCEDURE [dbo].[add_producteur_film]
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 128, 1, @titre_VF);
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_prod,@pre_prod,@alias_prod,@dat_prod,@dat_deces_prod,@biographie_prod)
	
	--créer le lien entre film et personne
	Insert FilmRealisateur values(@titre_VF,@annee_Sortie,@nom_prod,@pre_prod,@alias_prod);
	
End
GO


IF (OBJECT_ID('del_producteur_film') IS NOT NULL)
  DROP PROCEDURE del_producteur_film
GO
CREATE PROCEDURE [dbo].[del_producteur_film]
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
		RAISERROR('%s : Film n''existe pas dans le catalogue', 128, 1, @titre_VF);
		
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, erreur
		RAISERROR('%s %s: La personne n''existe pas', 128, 1, @nom_prod,@pre_prod);
		
	Delete FilmRealisateur where FilmRealisateur.Nom=@titre_VF AND FilmRealisateur.AnneeSortie=@annee_Sortie AND
							FilmRealisateur.Nom=@nom_prod AND FilmRealisateur.Prenom=@pre_prod AND
							FilmRealisateur.Alias=@alias_prod;
END
GO



IF (OBJECT_ID('add_producteur_film') IS NOT NULL)
  DROP PROCEDURE add_producteur_film
GO
--ajouter une personne(acteur, réalisateur, producteur) à la table Personne
CREATE PROCEDURE [dbo].[add_producteur_film]
	@nom_prod VARCHAR(64),
	@pre_prod VARCHAR(64),
	@alias_prod NVARCHAR(64), 
	@dat_prod DATE, 
	@dat_deces_prod DATE, 
	@biographie_prod NVARCHAR(MAX)	
AS
Begin
	declare @tmp int;
	
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_prod And Prenom=@pre_prod And Alias=@alias_prod
	IF @tmp=0--No, inserer la
		Insert Personne Values (@nom_prod,@pre_prod,@alias_prod,@dat_prod,@dat_deces_prod,@biographie_prod)
	
	
End
GO

IF (OBJECT_ID('add_distinction_film') IS NOT NULL)
  DROP PROCEDURE add_distinction_film
GO
--ajouter une personne(acteur, réalisateur, producteur) à la table Personne
CREATE PROCEDURE [dbo].[add_distinction_film]
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
		RAISERROR('%s %d: Film n''existe pas dans le catalogue', 128, 1, @titre_VF,@annee_film);
	
	--vérifié si la distionction existe déjà
	Select @tmp = count(*) from TypeDistinction Where TypeDistinction.Nom=@nom_dist;
	IF @tmp=0--No, inserer la
		Insert TypeDistinction Values (@nom_dist);
	
	Insert FilmDistinction Values(@annee_dist,@titre_VF,@annee_film,@nom_dist);
	
End

GO

IF (OBJECT_ID('add_distinction_personne') IS NOT NULL)
  DROP PROCEDURE add_distinction_personne
GO
--ajouter une personne(acteur, réalisateur, producteur) à la table Personne
CREATE PROCEDURE [dbo].[add_distinction_personne]
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
				RAISERROR('%s %d: Film n''existe pas dans le catalogue', 128, 1, @titre_VF,@annee_film);
		
		END
	
	--vérifié si la personne existe déjà	
	Select @tmp = count(*) from Personne Where Nom=@nom_pers And Prenom=@pre_pers And Alias=@alias_pers
	IF @tmp=0
		RAISERROR('%s %s: Personne n''existe pas dans le catalogue', 128, 1,@nom_pers,@pre_pers);
	--vérifié si la distionction existe déjà
	Select @tmp = count(*) from TypeDistinction Where TypeDistinction.Nom=@nom_dist;
	IF @tmp=0--No, inserer la
		Insert TypeDistinction Values (@nom_dist);

	--inserer la distionction	
	Insert PersonneDistinction Values(@annee_dist,@titre_VF,@annee_film,@nom_dist,@nom_pers,@pre_pers,@alias_pers);
	
End


GO

