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
	CONSTRAINT chk_personne_nom CHECK ([Nom] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_personne_prenom CHECK ([Prenom] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_personne_alias CHECK ([Alias] NOT LIKE '%[^A-Za-z '']%'),
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
	CONSTRAINT chk_film_titrevo CHECK ([TitreVO] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_film_titrevf CHECK ([TitreVF] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_film_anneesortie CHECK (([AnneeSortie] >= '01/01/1800') AND ([AnneeSortie] < GETDATE())),
	CONSTRAINT chk_film_complementtitre CHECK ([ComplementTitre] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_film_siteweb CHECK ([SiteWeb] LIKE 'http://%') -- ????
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
	CONSTRAINT chk_edition_support CHECK ([Support] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_edition_datesortie CHECK ([DateSortie] >= '01/01/1800'),
	CONSTRAINT chk_edition_nomedition CHECK ([NomEdition] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_edition_duree CHECK ([Duree] LIKE '[0-9][0-9]:[1-5][0-9]'), -- Un film doit avoir au moins une duree de 10 minutes
	CONSTRAINT chk_edition_ageinterdiction CHECK ([AgeInterdiction] >= 0)
GO

------------------------------------------
/* IBDR 2013 – Groupe SAR               */
/* Contraintes pour la table FilmStock  */
/* Auteur  : MUNOZ Yupanqui - SAR       */
/* Testeur : MUNOZ Yupanqui - SAR       */
------------------------------------------
ALTER TABLE [dbo].[FilmStock]
ADD 
	CONSTRAINT chk_filmstock_datearrivee CHECK ([DateArrivee] >= GETDATE()),
	CONSTRAINT chk_filmstock_usure CHECK ([Usure] >= 0)
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Location         */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Location]
ADD 
	CONSTRAINT chk_location_datelocation CHECK ([DateLocation] >= GETDATE()),
	CONSTRAINT chk_location_dateretourprev CHECK ([DateRetourPrev] > [DateLocation]),
	CONSTRAINT chk_location_dateretoureff CHECK (([DateRetourEff] <= [DateRetourPrev]) AND ([DateRetourEff] > [DateLocation]))
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Editeur          */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Editeur]
ADD 
	CONSTRAINT chk_editeur_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z '']%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Genre            */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Genre]
ADD 
	CONSTRAINT chk_genre_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z '']%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Langue           */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Langue]
ADD 
	CONSTRAINT chk_langue_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z '']%')
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Pays             */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Pays]
ADD 
	CONSTRAINT chk_pays_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z '']%')
GO

----------------------------------------
/* IBDR 2013 – Groupe SAR             */
/* Contraintes pour la table Client   */
/* Auteur  : MUNOZ Yupanqui - SAR     */
/* Testeur : MUNOZ Yupanqui - SAR     */
----------------------------------------
ALTER TABLE [dbo].[Client]
ADD 
	CONSTRAINT chk_client_nom CHECK ([Nom] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_client_prenom CHECK ([Prenom] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_client_datenaissance CHECK ([DateNaissance] >= '01/01/1900'),
	CONSTRAINT chk_client_civilite CHECK ([Civilite] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_client_numrue CHECK (NumRue > 0), 
	CONSTRAINT chk_client_nomrue CHECK ([NomRue] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_client_typerue CHECK (TypeRue IN ('Rue', 'Avenue', 'Passage', 'Impasse', 'Route')),
	CONSTRAINT chk_client_codepostal CHECK ([CodePostal] LIKE '[0-9][A-Ba-b0-9][0-9][0-9][0-9]'),
	CONSTRAINT chk_client_ville CHECK ([Ville] NOT LIKE '%[^A-Za-z '']%'),
	CONSTRAINT chk_client_mail CHECK (
			CHARINDEX(' ',LTRIM(RTRIM([Mail]))) = 0 
			AND 	LEFT(LTRIM([Mail]),1) <> '@'  
			AND 	RIGHT(RTRIM([Mail]),1) <> '.' 
			AND 	CHARINDEX('.',[Mail],CHARINDEX('@',[Mail])) - CHARINDEX('@',[Mail]) > 1 
			AND 	LEN(LTRIM(RTRIM([Mail]))) - LEN(REPLACE(LTRIM(RTRIM([Mail])),'@','')) = 1 
			AND 	CHARINDEX('.',REVERSE(LTRIM(RTRIM([Mail])))) >= 3 
			AND 	(CHARINDEX('.@',[Mail]) = 0 AND CHARINDEX('..',[Mail]) = 0)
		),
	CONSTRAINT chk_client_telephone1 CHECK ([Telephone1] LIKE '0'+replicate('[0-9]',9)),
	CONSTRAINT chk_client_telephone2 CHECK ([Telephone2] LIKE '0'+replicate('[0-9]',9))
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table TypeAbonnement   */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[TypeAbonnement]
ADD 
	CONSTRAINT chk_typeabonnement_nom CHECK ([Nom] NOT LIKE '%[^A-Za-z '']%'), 
	CONSTRAINT chk_typeabonnement_prixmensuel CHECK ([PrixMensuel] > 0),
	CONSTRAINT chk_typeabonnement_prixlocation CHECK ([PrixLocation] > 0),
	CONSTRAINT chk_typeabonnement_maxjourslocation CHECK ([MaxJoursLocation] > 0),
	CONSTRAINT chk_typeabonnement_nbmaxlocations CHECK ([NbMaxLocations] > 0),
	CONSTRAINT chk_typeabonnement_prixretard CHECK ([PrixRetard] >= 0),
	CONSTRAINT chk_typeabonnement_dureeengagement CHECK ([DureeEngagement] >= 0)
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table Abonnement       */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[Abonnement]
ADD 
	CONSTRAINT chk_abonnement_datedebut CHECK ([DateDebut] >= GETDATE()),
	CONSTRAINT chk_abonnement_datefin CHECK ([DateFin] > [DateDebut])
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table RelanceDecouvert */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[RelanceDecouvert]
ADD 
	CONSTRAINT chk_relancedecouvert_niveau CHECK ([Niveau] > 0)
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table RelanceRetard    */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[RelanceRetard]
ADD 
	CONSTRAINT chk_relanceretard_niveau CHECK ([Niveau] > 0)
GO

------------------------------------------------
/* IBDR 2013 – Groupe SAR                     */
/* Contraintes pour la table TypeDistinction  */
/* Auteur  : MUNOZ Yupanqui - SAR             */
/* Testeur : MUNOZ Yupanqui - SAR             */
------------------------------------------------
ALTER TABLE [dbo].[TypeDistinction]
ADD 
	CONSTRAINT chk_relance_nom CHECK ([Nom]  NOT LIKE '%[^A-Za-z '']%') -- Incomplet, il manque accepter l'apostrophe et l'espace
GO
