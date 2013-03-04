 -------------------------------------
/* IBDR 2013 – Groupe SAR */
/* Precedure du suppression de film */
/* Auteur : AISSAT Mustapha - SAR */
/* Testeur :   */
-------------------------------------


Use IBDR_SAR
GO

IF OBJECT_ID ('netoyage_Distinction') IS NOT NULL
    DROP PROCEDURE netoyage_Distinction
GO
--procedure periodique pour supprimer les distinction plus référencé
CREATE PROCEDURE [dbo].[netoyage_Distinction]
AS

  
GO

IF OBJECT_ID ('netoyage_Personne') IS NOT NULL
    DROP PROCEDURE netoyage_Personne
GO

--procedure periodique pour supprimer les personne plus référencé
CREATE PROCEDURE [dbo].[netoyage_Personne]
AS

  
GO

IF (OBJECT_ID('delete_film') IS NOT NULL)
  DROP PROCEDURE delete_film
GO

CREATE PROCEDURE [dbo].[delete_film]
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