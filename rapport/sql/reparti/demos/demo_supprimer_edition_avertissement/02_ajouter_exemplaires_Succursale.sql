---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Test de la procedure pour ajouter un ensemble d'exemplaires (FilmStock)     */
/*                                                                             */
/* Auteur  : MUNOZ Yupanqui - SAR                                              */
/* Testeur : MUNOZ Yupanqui - SAR                                              */
---------------------------------------------------------------------------------

USE IBDR_SAR
GO

/** Supprimer données **/
DELETE FROM RelanceRetard
GO

DELETE FROM Location
GO

DELETE FROM Abonnement
GO

DELETE FROM TypeAbonnement
GO

DELETE FROM Client
GO

/** Exécution de la procedure **/
DECLARE @ID_EDITION INT
SELECT @ID_EDITION = ID FROM  Edition WHERE NomEdition = 'Box Edition'

EXEC dbo.filmstock_ajouter
	@DateArrivee = '01/04/2013 10:00:00:000', -- dd/mon/yyyy hh:mi:ss:mmm(24h)
	@Usure  = 0,
	@IdEdition = @ID_EDITION,
	@Nombre = 1

INSERT INTO TypeAbonnement
           (Nom
           ,PrixMensuel
           ,PrixLocation
           ,MaxJoursLocation
           ,NbMaxLocations
           ,PrixRetard
           ,DureeEngagement, estdispo)
     VALUES
           ('Solo',1,0.1,1,1,1,1,1)

INSERT INTO Client
           (Civilite
           ,Nom
           ,Prenom
           ,DateNaissance
           ,Mail
           ,Telephone1
           ,Telephone2
           ,NumRue
           ,TypeRue
           ,NomRue
           ,CodePostal
           ,Ville
           ,BlackListe)
     VALUES
           ('Celib'
           ,'Derrida'
           ,'Ambroise'
           ,'01/01/1950' --convert(date,'01/01/1950',103)
           ,'ambroise.derrida@cosmic.net'
           ,'0108050133'
           ,'0123456789'
           ,9
           ,'Rue'
           ,'Pascal-Paoli'
           ,'2B454'
           ,'Corte'
           ,0)
           
INSERT INTO Abonnement
           (Succursale
           ,SuccursaleClient
           ,Solde
           ,DateDebut
           ,DateFin
           ,NomClient
           ,PrenomClient
           ,MailClient
           ,TypeAbonnement)
     VALUES
           (@@SERVERNAME
           ,@@SERVERNAME
           ,1
           ,convert(datetime,'2013-04-01 00:00:00.000',21)
           ,convert(datetime,'2013-04-24 00:00:00.000',21)
           ,'Derrida'
           ,'Ambroise'
           ,'ambroise.derrida@cosmic.net'
           ,'Solo')


DECLARE @ID_ABONNEMENT INT
SET @ID_ABONNEMENT = @@IDENTITY

DECLARE @ID_FILMSTOCK INT
SELECT @ID_FILMSTOCK = MAX(ID) FROM  FilmStock

INSERT INTO Location
           (AbonnementId
           ,AbonnementSuc
           ,DateLocation
           ,DateRetourPrev
           ,FilmStockId
           ,Confirmee)
     VALUES
           (@ID_ABONNEMENT
           ,@@SERVERNAME
           , '05/04/2013 10:00:00:000'
           , '07/04/2013 10:00:00:000'
           ,@ID_FILMSTOCK
           ,1)
           
DECLARE @ID_LOCATION INT
SET @ID_LOCATION = @@IDENTITY

INSERT INTO RelanceRetard
           (Date
           ,LocationId
           ,Niveau)
     VALUES
           ('07/04/2013 10:00:00:000'
           ,@ID_LOCATION
           ,2)
		
/** L'état de la base données par rapport les tables qui ont été modifiés **/
SELECT fs.Id AS Exemplaire_ID, l.Id AS Location_ID, rr.Date AS RelanceRetard_Date
	FROM FilmStock fs, Location l, RelanceRetard rr 
	WHERE  fs.Id = l.FilmStockId AND l.Id = rr.LocationId