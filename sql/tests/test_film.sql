 -------------------------------------
/* IBDR 2013 – Groupe SAR          */
/* Script d'ajout de deux film     */
/* Auteur :  AISSAT Mustapha - SAR */
/* Testeur : AISSAT Mustapha - SAR
			 AMIARD Raphaël - SAR  */
-------------------------------------


USE IBDR_SAR
GO

-- Vider les tables 
EXEC dbo._Vide_BD


-- Insérer les langues
Insert into Langue Values('anglais');

-- Insérer les genres
Insert into Genre values('Action');
Insert into Genre values('Fantastique');
Insert into Genre values('Aventure');
Insert into Genre values('Science fiction');

-- Afficher les tables
Select * From Film;
Select * From Personne;
Select * From FilmActeur;
Select * From FilmRealisateur;
Select * From FilmDistinction;


-- Ajouter le film 'hobbit'
Exec dbo.film_creer  
					'Le Hobbit',
					'un voyage inattendu',
					'The hobbit',
					2012,
					'Dans UN VOYAGE INATTENDU, Bilbon Sacquet cherche à reprendre le Royaume perdu des Nains d''Erebor, conquis par le redoutable dragon Smaug. Alors qu''il croise par hasard la route du magicien Gandalf le Gris, Bilbon rejoint une bande de 13 nains dont le chef n''est autre que le légendaire guerrier Thorin Écu-de-Chêne. Leur périple les conduit au cœur du Pays Sauvage, où ils devront affronter des Gobelins, des Orques, des Ouargues meurtriers, des Araignées géantes, des Métamorphes et des Sorciers…',
					'anglais',
					'http://www.thehobbit.com',
					'|Ian,McKellen, ,25/05/1939,null,C''est dès son plus jeune âge que la famille de Ian McKellen encourage sa passion pour le théâtre. Son père et son grand-père sont prédicateurs et le jeune Ian baigne dans un environnement profondément ancré dans la religion chrétienne. Toutefois, sa famille pratique une religion dénuée de toute considération dogmatique en érigeant la croyance en tant que système de valeurs|Freeman,Martin, ,08/09/1971,null,Après des études d''art dramatique à Londres, Martin Freeman décide de se lancer dans la comédie en intégrant la "Young Action Theatre Of Teddington", une troupe de théâtre amateur qui connait un petit succès et qui va surtout permettre au comédien de se faire repérer. A partir de 1997, il enchaîne ainsi les apparitions télévisées dans des séries telles que The Bill (1997) et Casualty (1998). Ses nombreuses prestations à la télévision le font peu à peu connaître du grand public|',
					'|Jackson, Peter Robert, ,31/10/1961,null,Signe du destin ? Peter Jackson, spécialiste du cinéma fantastique, est né le jour d''Halloween. Après avoir tourné des films de vampires au cours de son enfance, il travaille en tant que photograveur dans un journal puis décide de se lancer dans le cinéma. En 1988, il accouche de Bad taste, un premier film très gore tourné pendant ses week-end, et qui se fait remarquer au marché du film du Festival de Cannes.|',
					'',
					'|Action|Fantastique|Aventure|';
					
-- Ajouter une distinction à 'Hobbit'					
Exec dbo.film_ajouter_distinction 'Oscar des Meilleurs décors',2013,'Le Hobbit',2012; 

EXEC dbo.film_modifier_site_web 'Le Hobbit', 2012, 'http://www.lehobbit.fr/'

-- Afficher les tables
Select * From Film;
Select * From Personne;
Select * From FilmActeur;
Select * From FilmRealisateur;
Select * From FilmDistinction;


-- Ajouté le film 'X-Men'
Exec dbo.film_creer  
					@titre_VF='X-Men',
					@complement_titre='Le Commencement',
					@titre_VO='X-Men',
					@annee_sortie=2011,
					@synopsis='1944, dans un camp de concentration. Séparé par la force de ses parents, le jeune Erik Magnus Lehnsherr se découvre d''étranges pouvoirs sous le coup de la colère : il peut contrôler les métaux. C''est un mutant. Soixante ans plus tard, l''existence des mutants est reconnue mais provoque toujours un vif émoi au sein de la population. Puissant télépathe, le professeur Charles Xavier dirige une école destinée à recueillir ces êtres différents, souvent rejetés par les humains, et accueille un nouveau venu solitaire au passé mystérieux : Logan, alias Wolverine. En compagnie de Cyclope, Tornade et Jean Grey, les deux hommes forment les X-Men et vont affronter les sombres mutants ralliés à la cause de Erik Lehnsherr / Magnéto, en guerre contre l''humanité.',
					@langue='anglais',
					@site_web='http://www.thehobbit.com',
					@liste_acteurs='|Ian,McKellen, ,25/05/1939,null,C''est dès son plus jeune âge que la famille de Ian McKellen encourage sa passion pour le théâtre. Son père et son grand-père sont prédicateurs et le jeune Ian baigne dans un environnement profondément ancré dans la religion chrétienne. Toutefois, sa famille pratique une religion dénuée de toute considération dogmatique en érigeant la croyance en tant que système de valeurs|Jackman,Michael, ,12/10/1968,null,Diplômé en journalisme de l''University of Technology de Sydney, Hugh Jackman étudie la comédie à la Western Australian Academy of Performing Arts, avant de débuter devant la caméra dans la série télévisée australienne Correlli (1995).L''acteur fait ses débuts sur grand écran en 1998 dans la comédie romantique Paperback hero. C''est en 2000 qu''il connaît la consécration internationale en remplaçant au pied levé Dougray Scott, monopolisé par le tournage de Mission : impossible 2, dans X-Men|',
					@liste_realisateurs='|Singer,Bryan, ,17/09/1965,null,Diplômé en 1989 de l''USC School of Cinema-Television où il rencontre le compositeur John Ottman.|',
					@liste_producteurs='',
					@liste_genres='|Fantastique|Science fiction|Thriller|Action|';

-- Afficher les tables
Select * From Film;
Select * From Personne;
Select * From FilmActeur;
Select * From FilmRealisateur;
Select * From FilmDistinction;

ALTER TABLE dbo.Film WITH CHECK CHECK CONSTRAINT chk_film_anneesortie;