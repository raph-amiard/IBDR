-------------------------------------------------------
/* IBDR 2013 – Groupe SAR                            */ 
/* Création de la base de données IBDR_SAR           */ 
/* Date de la version 22/02/2013                     */
-------------------------------------------------------

USE IBDR_SAR 
GO

------------------------------------------
/* IBDR 2013 – Groupe SAR               */
/* Contraintes pour la table Personne   */
/* Auteur  : MUNOZ Yupanqui - SAR       */
/* Testeur : MUNOZ Yupanqui - SAR       */
------------------------------------------
ALTER TABLE [dbo].[Personne]
ADD 
	CONSTRAINT chk_personne_nom CHECK ([Nom] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_personne_prenom CHECK ([Prenom] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_personne_alias CHECK ([Alias] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_personne_datenaissance CHECK ([DateNaissance] >= '01/01/1800'),
	CONSTRAINT chk_personne_dateDeces CHECK ([DateDeces] >= '01/01/1800')
	-- CONSTRAINT chk_personne_biographie CHECK ([Biographie] NOT LIKE '%[^A-Za-z '']%')
GO

------------------------------------------
/* IBDR 2013 – Groupe SAR               */
/* Contraintes pour la table Film       */
/* Auteurs : MUNOZ Yupanqui - SAR       */
/*			 AMIARD Raphaël - SAR       */
/* Testeur : MUNOZ Yupanqui - SAR       */
------------------------------------------
ALTER TABLE [dbo].[Film]
ADD 
	CONSTRAINT chk_film_titrevo CHECK ([TitreVO] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_film_titrevf CHECK ([TitreVF] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_film_anneesortie CHECK (([AnneeSortie] >= '1800') AND ([AnneeSortie] < DATEPART(yyyy,GETDATE()))),
	CONSTRAINT chk_film_complementtitre CHECK ([ComplementTitre] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_film_siteweb CHECK ([SiteWeb] LIKE 'http://%')
	-- CONSTRAINT chk_film_synopsis CHECK ([Synopsis] NOT LIKE '%[^A-Za-z '']%')
GO

------------------------------------------
/* IBDR 2013 – Groupe SAR               */
/* Contraintes pour la table Edition    */
/* Auteur  : MUNOZ Yupanqui - SAR       */
/* Testeur : MUNOZ Yupanqui - SAR       */
------------------------------------------
ALTER TABLE [dbo].[Edition]
ADD 
	CONSTRAINT chk_edition_support CHECK ([Support] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_edition_datesortie CHECK ([DateSortie] >= '01/01/1800'),
	CONSTRAINT chk_edition_nomedition CHECK ([NomEdition] NOT LIKE '%[^A-Za-z ''-]%'),
	CONSTRAINT chk_edition_duree CHECK ([Duree] > '00:10:00'),
	CONSTRAINT chk_edition_ageinterdiction CHECK ([AgeInterdiction] >= 0)
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Editeur          */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Editeur]
ADD 
	CONSTRAINT chk_editeur_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z ''-]%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Genre            */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Genre]
ADD 
	CONSTRAINT chk_genre_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z ''-]%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Langue           */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Langue]
ADD 
	CONSTRAINT chk_langue_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z ''-]%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Pays             */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Pays]
ADD 
	CONSTRAINT chk_pays_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z ''-]%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table TypeAbonnement   */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[TypeAbonnement]
ADD 
	CONSTRAINT chk_typeabonnement_nom CHECK ([Nom] NOT LIKE '%[^A-Za-z ''-]%'), 
	CONSTRAINT chk_typeabonnement_prixmensuel CHECK ([PrixMensuel] > 0),
	CONSTRAINT chk_typeabonnement_prixlocation CHECK ([PrixLocation] > 0),
	CONSTRAINT chk_typeabonnement_maxjourslocation CHECK ([MaxJoursLocation] > 0),
	CONSTRAINT chk_typeabonnement_nbmaxlocations CHECK ([NbMaxLocations] > 0),
	CONSTRAINT chk_typeabonnement_prixretard CHECK ([PrixRetard] >= 0),
	CONSTRAINT chk_typeabonnement_dureeengagement CHECK ([DureeEngagement] >= 0)
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table TypeDistinction  */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[TypeDistinction]
ADD 
	CONSTRAINT chk_relance_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z ''-]%')
GO
