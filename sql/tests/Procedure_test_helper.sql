USE IBDR_SAR
GO

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
	INSERT INTO dbo.Langue (Nom) VALUES 
		(N'afrikaans'),	(N'albanais'),	(N'allemand'),	(N'amharic'),
		(N'anglais'),	(N'arabe'),		(N'armenien'),	(N'ashanti'),
		(N'azeri'),		(N'bambara'),	(N'basque'),	(N'bengali'),
		(N'berbere'),	(N'bielorusse'),(N'bosniaque'),	(N'bulgare'),
		(N'burkina'),	(N'capverdien'),(N'catalan'),	(N'cambodgien'),
		(N'chinois'),	(N'cingalais'),	(N'comoreen'),	(N'coreen'),
		(N'creole'),	(N'croate'),	(N'danois'),	(N'dari'),
		(N'dioula'),	(N'djerma'),	(N'espagnol'),	(N'estonien'),
		(N'ewe'),		(N'fang'),		(N'finnois'),	(N'fon'),
		(N'gaelic '),	(N'georgien'),	(N'gou'),		(N'grec'),
		(N'haoussa'),	(N'hebreu'),	(N'hindi'),		(N'hongrois'),
		(N'italien'),	(N'indonesien'),(N'japonais'),	(N'kanakry'),
		(N'kikongo'),	(N'kirghize'),	(N'kirwanda'),	(N'kurde'),
		(N'laotien'),	(N'latin'),		(N'letton'),	(N'lingala'),
		(N'lituanien'),	(N'macedonien'),(N'malais'),	(N'malgache'),
		(N'mandingue'),	(N'maoré'),		(N'minah'),		(N'moldave'),
		(N'mongol'),	(N'nago'),		(N'neerlandais'),(N'nepalais'),
		(N'norvegien'),	(N'oromo'),		(N'ourdou'),	(N'ouzbeque'),
		(N'pashtou'),	(N'pendjabi'),	(N'persan'),	(N'peul'),
		(N'polonais'),	(N'portugais'),	(N'rromani'),	(N'roumain'),
		(N'russe'),		(N'sango'),		(N'sanscrit'),	(N'serbe'),
		(N'slovaque'),	(N'slovene'),	(N'somali'),	(N'soussou'),
		(N'suedois'),	(N'swahili'),	(N'tamajek'),	(N'tamoul'),
		(N'tagalog'),	(N'tcheque'),	(N'tchetchene'),(N'tetela'),
		(N'thai'),		(N'tibetain'),	(N'tigrigna'),	(N'turc'),
		(N'turkmene'),	(N'tsiluba'),	(N'ukrainien'),	(N'vietnamien'),
		(N'visaïa'),	(N'woloff');
	
	INSERT INTO dbo.Pays (Nom) VALUES 
		(N'Afghanistan'),(N'Afrique du Sud'),(N'Albanie'),(N'Algérie'),
		(N'Allemagne'),	(N'Andorre'),	(N'Angola'),	(N'Antigua-et-Barbuda'),
		(N'Arabie Saoudite'),(N'Argentine'),	(N'Arménie'),	(N'Australie'),
		(N'Autriche'),	(N'Azerbaïdjan'),(N'Bahamas'),	(N'Bahreïn'),
		(N'Bangladesh'),(N'Barbade'),	(N'Belau'),		(N'Belgique'),
		(N'Belize'),	(N'Bénin'),		(N'Bhoutan'),	(N'Biélorussie'),
		(N'Birmanie'),	(N'Bolivie'),	(N'Bosnie-Herzégovine'),(N'Botswana'),
		(N'Brésil'),	(N'Brunei'),	(N'Bulgarie'),	(N'Burkina'),
		(N'Burundi'),	(N'Cambodge'),	(N'Cameroun'),	(N'Canada'),
		(N'Cap-Vert'),	(N'Chili'),		(N'Chine'),		(N'Chypre'),
		(N'Colombie'),	(N'Comores'),	(N'Congo'),
		(N'Cook'),		(N'Corée du nord'),		(N'Corée du sud'),		(N'Costa'),
		(N'Côte'),		(N'Croatie'),	(N'Cuba'),		(N'Danemark'),
		(N'Djibouti'),	(N'Dominique'),	(N'Égypte'),	(N'Émirats arabes unis'),
		(N'Équateur'),	(N'Érythrée'),	(N'Espagne'),	(N'Estonie'),
		(N'États-Unis'),(N'Éthiopie'),	(N'Fidji'),		(N'Finlande'),
		(N'France'),	(N'Gabon'),		(N'Gambie'),	(N'Géorgie'),
		(N'Ghana'),		(N'Grèce'),		(N'Grenade'),	(N'Guatemala'),
		(N'Guinée'),	(N'Guinée-Bissao'),(N'Guinée Equatoriale'),	(N'Guyane'),
		(N'Haïti'),		(N'Honduras'),	(N'Hongrie'),	(N'Inde'),
		(N'Indonésie'),	(N'Iran'),		(N'Iraq'),		(N'Irlande'),
		(N'Islande'),	(N'Israël'),	(N'Italie'),	(N'Jamaïque'),
		(N'Japon'),		(N'Jordanie'),	(N'Kazakhstan'),(N'Kenya'),
		(N'Kirghizistan'),(N'Kiribati'),(N'Koweït'),	(N'Laos'),
		(N'Lesotho'),	(N'Lettonie'),	(N'Liban'),		(N'Liberia'),
		(N'Libye'),		(N'Liechtenstein'),(N'Lituanie'),(N'Luxembourg'),
		(N'Macédoine'),	(N'Madagascar'),(N'Malaisie'),	(N'Malawi'),
		(N'Maldives'),	(N'Mali'),		(N'Malte'),		(N'Maroc'),
		(N'Marshall'),	(N'Maurice'),	(N'Mauritanie'),(N'Mexique'),
		(N'Micronésie'),(N'Moldavie'),	(N'Monaco'),	(N'Mongolie'),
		(N'Mozambique'),(N'Namibie'),	(N'Nauru'),		(N'Népal'),
		(N'Nicaragua'),	(N'Niger'),		(N'Nigeria'),	(N'Niue'),
		(N'Norvège'),	(N'Nouvelle-Zélande'),(N'Oman'),(N'Ouganda'),
		(N'Ouzbékistan'),(N'Pakistan'),	(N'Panama'),	(N'Papouasie - Nouvelle Guinée'),
		(N'Paraguay'),	(N'Pays-Bas'),	(N'Pérou'),		(N'Philippines'),
		(N'Pologne'),	(N'Portugal'),	(N'Qatar'),		(N'République centrafricaine'),
		(N'République dominicaine'),(N'République tchèque'),(N'Roumanie'),	(N'Royaume-Uni'),
		(N'Russie'),	(N'Rwanda'),	(N'Saint-Christophe'),(N'Sainte-Lucie'),
		(N'Saint-Marin'),(N'Saint-Siège'),(N'Saint-Vincent'),(N'Salomon'),
		(N'Salvador'),	(N'Samoa occidentales'),(N'Sao Tomé-et-Principe'),(N'Sénégal'),
		(N'Seychelles'),(N'Sierra Leone'),(N'Singapour'),(N'Slovaquie'),
		(N'Slovénie'),	(N'Somalie'),	(N'Soudan'),	(N'Sri Lanka'),
		(N'Suède'),		(N'Suisse'),	(N'Suriname'),	(N'Swaziland'),
		(N'Syrie'),		(N'Tadjikistan'),(N'Tanzanie'),	(N'Tchad'),
		(N'Thaïlande'),	(N'Togo'),		(N'Tonga'),		(N'Trinité-et-Tobago'),
		(N'Tunisie'),	(N'Turkménistan'),(N'Turquie'),	(N'Tuvalu'),
		(N'Ukraine'),	(N'Uruguay'),	(N'Vanuatu'),	(N'Venezuela'),
		(N'Viêt Nam'),	(N'Yémen'),		(N'Yougoslavie'),(N'Zaïre'), (N'Zambie'),	(N'Zimbabwe');
	
	INSERT INTO dbo.Genre ( Nom ) VALUES
		(N'Action'), (N'Aventure'), (N'Comédie'), (N'Drame'), (N'Documentaire');
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
	INSERT INTO [dbo].[TypeAbonnement] ([Nom], [PrixMensuel], [PrixLocation], [MaxJoursLocation], [NbMaxLocations], [PrixRetard], [DureeEngagement]) VALUES (N'Classic', CAST(20.0000 AS SmallMoney), CAST(1.0000 AS SmallMoney), 10, 4, CAST(10.0000 AS SmallMoney), 31)
END
GO

CREATE PROCEDURE  [dbo].[_Ajout_Abonnement]
AS 
BEGIN
	EXEC _Ajout_Type_Abonnement
	EXEC _Ajout_Client
	SET IDENTITY_INSERT [dbo].[Abonnement] ON
	INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (0, CAST(10.0000 AS SmallMoney), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP+60, N'DUPONT', N'Lucien', N'DUPONT.Lucien@gmail.com', N'Basic')
	INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (1, CAST(20.0000 AS SmallMoney), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP+30, N'DUPONT', N'Lucienne', N'DUPONT.Lucienne@gmail.com', N'Basic')
	INSERT INTO [dbo].[Abonnement] ([Id], [Solde], [DateDebut], [DateFin], [NomClient], [PrenomClient], [MailClient], [TypeAbonnement]) VALUES (2, CAST(30.0000 AS SmallMoney), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP+40, N'DUPONT', N'Lucien', N'DUPONT.Lucien@gmail.com', N'Classic')
	SET IDENTITY_INSERT [dbo].[Abonnement] OFF
END
GO