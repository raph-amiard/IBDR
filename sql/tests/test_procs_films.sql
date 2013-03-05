
USE IBDR_SAR
GO

Exec dbo.delete_film 'Le Hobbit',2012;
delete from dbo.Personne where 1=1;

Select * From Film;
Select * From Personne;
Select * From FilmActeur;
Select * From FilmDistinction;

--Insert into Langue Values('Anglais');
--Insert into Genre values('Action'),('Fantastique'),('Aventure');

Exec dbo.ajouter_film  
					'Le Hobbit',
					'un voyage inattendu',
					'The hobbit',
					2012,
					'Dans UN VOYAGE INATTENDU, Bilbon Sacquet cherche à reprendre le Royaume perdu des Nains d''Erebor, conquis par le redoutable dragon Smaug. Alors qu''il croise par hasard la route du magicien Gandalf le Gris, Bilbon rejoint une bande de 13 nains dont le chef n''est autre que le légendaire guerrier Thorin Écu-de-Chêne. Leur périple les conduit au cœur du Pays Sauvage, où ils devront affronter des Gobelins, des Orques, des Ouargues meurtriers, des Araignées géantes, des Métamorphes et des Sorciers…',
					'Anglais',
					'http://www.thehobbit.com',
					'|Ian,McKellen, ,05/25/1939,null,C''est dès son plus jeune âge que la famille de Ian McKellen encourage sa passion pour le théâtre. Son père et son grand-père sont prédicateurs et le jeune Ian baigne dans un environnement profondément ancré dans la religion chrétienne. Toutefois, sa famille pratique une religion dénuée de toute considération dogmatique en érigeant la croyance en tant que système de valeurs|Freeman,Martin, ,08/09/1971,Après des études d''art dramatique à Londres, Martin Freeman décide de se lancer dans la comédie en intégrant la "Young Action Theatre Of Teddington", une troupe de théâtre amateur qui connait un petit succès et qui va surtout permettre au comédien de se faire repérer. A partir de 1997, il enchaîne ainsi les apparitions télévisées dans des séries telles que The Bill (1997) et Casualty (1998). Ses nombreuses prestations à la télévision le font peu à peu connaître du grand public|',
					'|Jackson, Peter Robert, ,10/31/1961,Signe du destin ? Peter Jackson, spécialiste du cinéma fantastique, est né le jour d''Halloween. Après avoir tourné des films de vampires au cours de son enfance, il travaille en tant que photograveur dans un journal puis décide de se lancer dans le cinéma. En 1988, il accouche de Bad taste, un premier film très gore tourné pendant ses week-end, et qui se fait remarquer au marché du film du Festival de Cannes.|',
					'',
					'|Action|Fantastique|Aventure|';
					
					
Exec IBDR_SAR.dbo.add_distinction_film 'Oscar des Meilleurs décors',2013,'Le Hobbit',2012; 


Select * From Film;
Select * From Personne;
Select * From FilmActeur;
Select * From FilmDistinction;

