IF OBJECT_ID ( '_Vide_BD', 'P' ) IS NOT NULL 
    DROP PROCEDURE _Vide_BD;
GO

IF OBJECT_ID ( '_Ajout_Type_Abonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE _Ajout_Type_Abonnement;
GO

IF OBJECT_ID ( '_Ajout_Abonnement', 'P' ) IS NOT NULL 
    DROP PROCEDURE _Ajout_Abonnement;
GO

IF OBJECT_ID ( '_Ajout_Client', 'P' ) IS NOT NULL 
    DROP PROCEDURE _Ajout_Client;
GO
---------------------------------------------------------------------------------
/* IBDR 2013 - Groupe SAR                                                      */
/* Auteurs  : GOUYOU Ludovic - TA                                              */
---------------------------------------------------------------------------------
CREATE PROCEDURE  [dbo].[_Vide_BD]
AS 
BEGIN
	exec sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL'
	exec sp_MSforeachtable 'DISABLE TRIGGER ALL ON ?'
	exec sp_MSforeachtable 'DELETE FROM ?'
	exec sp_MSforeachtable 'ENABLE TRIGGER ALL ON ?'
	exec sp_MSforeachtable 'ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL'
END
GO

CREATE PROCEDURE  [dbo].[_Ajout_Client]
AS 
BEGIN
	INSERT INTO [dbo].[Client] ([Civilite], [Nom], [Prenom], [DateNaissance], [Mail], [Telephone1], [Telephone2], [NumRue], [TypeRue], [NomRue], [ComplementAdresse], [CodePostal], [Ville], [BlackListe]) VALUES (N'Madame', N'DUPONT', N'Lucienne', N'1950-01-01', N'DUPONT.Lucienne@gmail.com', N'0558783340', N'0473269885', 3, N'rue', N'Marelle', NULL, N'93260', N'Les Lilas', 0)
	INSERT INTO [dbo].[Client] ([Civilite], [Nom], [Prenom], [DateNaissance], [Mail], [Telephone1], [Telephone2], [NumRue], [TypeRue], [NomRue], [ComplementAdresse], [CodePostal], [Ville], [BlackListe]) VALUES (N'Monsieur', N'DUPONT', N'Lucien', N'1950-01-01', N'DUPONT.Lucien@gmail.com', N'0558783333', N'0473269833', 3, N'rue', N'Marelle', NULL, N'93260', N'Les Lilas', 0)
	INSERT INTO [dbo].[Client] ([Civilite], [Nom], [Prenom], [DateNaissance], [Mail], [Telephone1], [Telephone2], [NumRue], [TypeRue], [NomRue], [ComplementAdresse], [CodePostal], [Ville], [BlackListe]) VALUES (N'Madame', N'JEAN', N'David', N'1980-01-01', N'JEAN.David@yahoo.fr', N'0558783370', N'0473269809', 3, N'Avenue', N'Marcel Proust', NULL, N'75016', N'Paris', 0)
END
GO

CREATE PROCEDURE  [dbo].[_Ajout_Type_Abonnement]
AS 
BEGIN
	INSERT INTO [dbo].[TypeAbonnement] ([Nom], [PrixMensuel], [PrixLocation], [MaxJoursLocation], [NbMaxLocations], [PrixRetard], [DureeEngagement]) VALUES (N'Basic', CAST(10.0000 AS SmallMoney), CAST(1.0000 AS SmallMoney), 2, 2, CAST(10.0000 AS SmallMoney), 31)
	INSERT INTO [dbo].[TypeAbonnement] ([Nom], [PrixMensuel], [PrixLocation], [MaxJoursLocation], [NbMaxLocations], [PrixRetard], [DureeEngagement]) VALUES (N'Basic évolué', CAST(40.0000 AS SmallMoney), CAST(0.5000 AS SmallMoney), 5, 4, CAST(10.0000 AS SmallMoney), 360)
	INSERT INTO [dbo].[TypeAbonnement] ([Nom], [PrixMensuel], [PrixLocation], [MaxJoursLocation], [NbMaxLocations], [PrixRetard], [DureeEngagement]) VALUES (N'Classic', CAST(20.0000 AS SmallMoney), CAST(1.0000 AS SmallMoney), 5, 4, CAST(10.0000 AS SmallMoney), 31)
END
GO

CREATE PROCEDURE  [dbo].[_Ajout_Abonnement]
AS 
BEGIN
	EXEC _Ajout_Type_Abonnement
	EXEC _Ajout_Client
	SET IDENTITY_INSERT [dbo].[Abonnement] ON
	INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (0, CAST(10.0000 AS SmallMoney), CURRENT_TIMESTAMP-30, CURRENT_TIMESTAMP+60, N'DUPONT', N'Lucien', N'DUPONT.Lucien@gmail.com', N'Basic')
	INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (1, CAST(20.0000 AS SmallMoney), CURRENT_TIMESTAMP-30, CURRENT_TIMESTAMP+30, N'DUPONT', N'Lucienne', N'DUPONT.Lucienne@gmail.com', N'Basic')
	INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (2, CAST(30.0000 AS SmallMoney), CURRENT_TIMESTAMP-60, CURRENT_TIMESTAMP-40, N'DUPONT', N'Lucien', N'DUPONT.Lucien@gmail.com', N'Classic')
	SET IDENTITY_INSERT [dbo].[Abonnement] OFF
END
GO