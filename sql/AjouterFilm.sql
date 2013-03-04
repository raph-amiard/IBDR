 -------------------------------------
/* IBDR 2013 – Groupe SAR */
/* Precedure d'ajoute de film */
/* Auteur : AISSAT Mustapha - SAR */
/* Testeur :   */
-------------------------------------

Use IBDR_SAR
GO

IF (OBJECT_ID('ajouter_film') IS NOT NULL)
  DROP PROCEDURE ajouter_film
GO



CREATE PROCEDURE [dbo].[ajouter_film]
	/* catalogue */
	@titre_VF NVARCHAR(128),
	@complement_titre NVARCHAR(256),
	@titre_VO NVARCHAR(128),
	@annee_Sortie SMALLINT,	
	@synopsis NTEXT ,
	@langue NVARCHAR(64) ,
	@site_web NVARCHAR(512),	

    
    /* acteur(s) */
    @liste_acteurs VARCHAR(1000),
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
    -- 0 si film sans acteur

    /*
    @nom_act VARCHAR(64), @pre_act VARCHAR(64), @alias_act NVARCHAR(64), @dat_act VARCHAR(50), @dat_deces_act VARCHAR(50), @biographie_act NVARCHAR(MAX);
    */
    
    /* realisateur(s) */
    @liste_realisateurs VARCHAR(500),
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
	-- pas de film sans réalisateur
      
    /*
	@nom_act VARCHAR(64), @pre_act VARCHAR(64), @alias_act NVARCHAR(64), @dat_act VARCHAR(50), @dat_deces_act VARCHAR(50), @biographie_act NVARCHAR(MAX);
	*/
	/* producteur(s) */
	@liste_producteurs VARCHAR(500),
	-- |Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|Nom,Prenom,Alias,DateNaissance,DateDecesn,Biographie|...
	-- pas de film sans réalisateur
      
    /*
	@nom_act VARCHAR(64), @pre_act VARCHAR(64), @alias_act NVARCHAR(64), @dat_act VARCHAR(50), @dat_deces_act VARCHAR(50), @biographie_act NVARCHAR(MAX);
	*/
	
    /* distinction(s)
    @liste_distinctions VARCHAR(1000), */
    -- |typeDistinction,nom_distinction,annee_distinction,titre_VF,annee_film[,nom_pers,pre_pers,alias_pers]|
    -- 0 si film sans distinction
    
    -- typeDistinction = film ou bien personne
    /*
	-- analogue
	*/
	
    /* genre(s) */
	@liste_genres varchar(100)
	-- |genre|genre|genre|...
	-- pas de film sans genre
	    
    /*
	@genre_film varchar(15)
	*/

	
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
	
	IF CHARINDEX('|',@liste_genres)=1
		RAISERROR('Un film doit au moins avoir un genre', 128, 1);
	
		
	Select @tmp=count(*) From Film where Film.TitreVF=@titre_VF AND 
				Film.AnneeSortie=@annee_Sortie;
	IF @tmp>= 1 /* film déjà au catalogue */
	
		RAISERROR('%s %d : film déjà au catalogue', 128, 1, @titre_VF, @annee_Sortie);
		
	
	ELSE /* film absent du catalogue, a inserer */
		BEGIN TRY
			Print 'L''ajout du film '+ cast(@titre_VF as varchar)+ ' dans la tables Film';
			BEGIN TRAN
			INSERT Film VALUES ( @titre_VF, @complement_titre, @titre_VO, 
								 @annee_Sortie, @synopsis, @langue, @site_web);
			COMMIT TRAN
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
					Begin Tran
						INSERT FilmActeur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					Commit Tran
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
						Begin Tran
							INSERT Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
							INSERT FilmActeur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
						Commit Tran
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
					Begin Tran
						INSERT FilmRealisateur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act)
					Commit Tran
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
						Begin Tran
							INSERT Personne Values (@nom_act,@pre_act,@alias_act,@dat_act,@dat_deces_act,@biographie_act);
							INSERT FilmRealisateur Values (@titre_VF,@annee_Sortie,@nom_act,@pre_act,@alias_act);
						Commit Tran
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