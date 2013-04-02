---------------------------------------------------
/* IBDR 2013 - Groupe SAR                        */
/* Procedure d'ajout d'un film  Sans RoolBack    */
/* Auteur  : AISSAT Mustapha - SAR               */
/* Testeur : AISSAT Mustapha - SAR               */
---------------------------------------------------
Use IBDR_SAR;
GO

IF (OBJECT_ID('dbo.film_creer_sans_RoolBack') IS NOT NULL)
  DROP PROCEDURE dbo.film_creer_sans_RoolBack
GO
CREATE PROCEDURE dbo.film_creer_sans_RoolBack
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
		

	 /* film absent du catalogue, a inserer */
		BEGIN TRY
			Print 'L''ajout du film '+ cast(@titre_VF as varchar)+ ' dans la tables Film';
		
			INSERT into Film(TitreVF,ComplementTitre,TitreVO,AnneeSortie,Synopsis,Langue,SiteWeb,IsDeleted)
					 VALUES ( @titre_VF, @complement_titre, @titre_VO, 
								 @annee_Sortie, @synopsis, @langue, @site_web,0);
			
		END TRY
		BEGIN CATCH
			--erreur
			
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
						
						Print ERROR_MESSAGE();
						RAISERROR('Erreur dans l''ajout du genre %s : ', 16, 1, @genre_film );
						
					End Catch
					
				END
		END
		

	
end	
GO



Exec dbo.film_supprimer 'Le Hobbit',2012;
Exec dbo.film_supprimer 'X-Men',2011;
   

--delete from dbo.Personne ;
delete from dbo.Langue ;
delete from dbo.Genre ;

-- Ins�rer les langues
Insert into Langue Values('anglais');

-- Ins�rer les genres
Insert into Genre values('Action');
Insert into Genre values('Fantastique');
Insert into Genre values('Aventure');
Insert into Genre values('Science fiction');

-- Afficher les tables

-- Afficher les tables
Select f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias, Rolle='Acteur'
	 From Film f inner join FilmActeur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias,Rolle='R�alisateur'
 From Film f inner join FilmRealisateur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
Union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.NomProducteur Nom, f_pres.PrenomProducteur Prenom, f_pres.AliasProducteur Alias,Rolle='producteur'
 From Film f inner join FilmProducteur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie;

Select d.Annee, d.NomDistinction,d.TitreVF,d.AnneeSortie AnneeSortieFilm From FilmDistinction d;




-- Ajouter le film 'hobbit'
Exec dbo.film_creer_sans_RoolBack  
					'Le Hobbit',
					'un voyage inattendu',
					'The hobbit',
					2012,
					'Dans UN VOYAGE INATTENDU, Bilbon Sacquet cherche � reprendre le Royaume perdu des Nains d''Erebor, conquis par le redoutable dragon Smaug. Alors qu''il croise par hasard la route du magicien Gandalf le Gris, Bilbon rejoint une bande de 13 nains dont le chef n''est autre que le l�gendaire guerrier Thorin �cu-de-Ch�ne. Leur p�riple les conduit au c�ur du Pays Sauvage, o� ils devront affronter des Gobelins, des Orques, des Ouargues meurtriers, des Araign�es g�antes, des M�tamorphes et des Sorciers�',
					'anglais',
					'http://www.thehobbit.com',
					'|Ian,McKellen, ,05/05/1939,null,C''est d�s son plus jeune �ge que la famille de Ian McKellen encourage sa passion pour le th��tre. Son p�re et son grand-p�re sont pr�dicateurs et le jeune Ian baigne dans un environnement profond�ment ancr� dans la religion chr�tienne. Toutefois, sa famille pratique une religion d�nu�e de toute consid�ration dogmatique en �rigeant la croyance en tant que syst�me de valeurs|Freeman,Martin, ,08/09/1971,null,Apr�s des �tudes d''art dramatique � Londres, Martin Freeman d�cide de se lancer dans la com�die en int�grant la "Young Action Theatre Of Teddington", une troupe de th��tre amateur qui connait un petit succ�s et qui va surtout permettre au com�dien de se faire rep�rer. A partir de 1997, il encha�ne ainsi les apparitions t�l�vis�es dans des s�ries telles que The Bill (1997) et Casualty (1998). Ses nombreuses prestations � la t�l�vision le font peu � peu conna�tre du grand public|',
					'|Jackson, Peter Robert, ,3/10/1961,null,Signe du destin ? Peter Jackson, sp�cialiste du cin�ma fantastique, est n� le jour d''Halloween. Apr�s avoir tourn� des films de vampires au cours de son enfance, il travaille en tant que photograveur dans un journal puis d�cide de se lancer dans le cin�ma. En 1988, il accouche de Bad taste, un premier film tr�s gore tourn� pendant ses week-end, et qui se fait remarquer au march� du film du Festival de Cannes.|',
					'',
					'|Action|Fantastique|Aventure|';
					
-- Ajouter une distinction � 'Hobbit'					
Exec dbo.film_ajouter_distinction  'Oscar des Meilleurs d�cors',2013,'Le Hobbit',2012; 

EXEC dbo.film_modifier_site_web 'Le Hobbit', 2012, 'http://www.lehobbit.fr/'
/*
-- Afficher les tables
Select * From Film;
--Select * From Personne;
Select * From FilmActeur;
Select * From FilmRealisateur;
Select * From FilmDistinction;
*/

-- Ajout� le film 'X-Men'
Exec dbo.film_creer_sans_RoolBack  
					@titre_VF='X-Men',
					@complement_titre='Le Commencement',
					@titre_VO='X-Men',
					@annee_sortie=2011,
					@synopsis='1944, dans un camp de concentration. S�par� par la force de ses parents, le jeune Erik Magnus Lehnsherr se d�couvre d''�tranges pouvoirs sous le coup de la col�re : il peut contr�ler les m�taux. C''est un mutant. Soixante ans plus tard, l''existence des mutants est reconnue mais provoque toujours un vif �moi au sein de la population. Puissant t�l�pathe, le professeur Charles Xavier dirige une �cole destin�e � recueillir ces �tres diff�rents, souvent rejet�s par les humains, et accueille un nouveau venu solitaire au pass� myst�rieux : Logan, alias Wolverine. En compagnie de Cyclope, Tornade et Jean Grey, les deux hommes forment les X-Men et vont affronter les sombres mutants ralli�s � la cause de Erik Lehnsherr / Magn�to, en guerre contre l''humanit�.',
					@langue='anglais',
					@site_web='http://www.xmen-first-class.com/',
					@liste_acteurs='|Ian,McKellen, ,2/05/1939,null,C''est d�s son plus jeune �ge que la famille de Ian McKellen encourage sa passion pour le th��tre. Son p�re et son grand-p�re sont pr�dicateurs et le jeune Ian baigne dans un environnement profond�ment ancr� dans la religion chr�tienne. Toutefois, sa famille pratique une religion d�nu�e de toute consid�ration dogmatique en �rigeant la croyance en tant que syst�me de valeurs|Jackman,Michael, ,12/10/1968,null,Dipl�m� en journalisme de l''University of Technology de Sydney, Hugh Jackman �tudie la com�die � la Western Australian Academy of Performing Arts, avant de d�buter devant la cam�ra dans la s�rie t�l�vis�e australienne Correlli (1995).L''acteur fait ses d�buts sur grand �cran en 1998 dans la com�die romantique Paperback hero. C''est en 2000 qu''il conna�t la cons�cration internationale en rempla�ant au pied lev� Dougray Scott, monopolis� par le tournage de Mission : impossible 2, dans X-Men|',
					@liste_realisateurs='|Singer,Bryan, ,----------------,null,Dipl�m� en 1989 de l''USC School of Cinema-Television o� il rencontre le compositeur John Ottman.|',
					@liste_producteurs='',
					@liste_genres='|Fantastique|Science fiction|Thriller|Action|';

-- Afficher les tables
Select f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias, Rolle='Acteur'
	 From Film f inner join FilmActeur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias,Rolle='R�alisateur'
 From Film f inner join FilmRealisateur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
Union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.NomProducteur Nom, f_pres.PrenomProducteur Prenom, f_pres.AliasProducteur Alias,Rolle='producteur'
 From Film f inner join FilmProducteur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie;

Select d.Annee, d.NomDistinction,d.TitreVF,d.AnneeSortie AnneeSortieFilm From FilmDistinction d;


