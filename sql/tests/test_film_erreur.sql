 -------------------------------------
/* IBDR 2013 � Groupe SAR          */
/* Script d'ajout de deux film     */
/* Auteur :  AISSAT Mustapha - SAR */
/* Testeur : AISSAT Mustapha - SAR
			 AMIARD Rapha�l - SAR  */
-------------------------------------


USE IBDR_SAR
GO

-- Vider les tables 
--EXEC dbo._Vide_BD



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
Exec dbo.film_creer  
					'Le Hobbit',
					'un voyage inattendu',
					'The hobbit',
					2012,
					'Dans UN VOYAGE INATTENDU, Bilbon Sacquet cherche � reprendre le Royaume perdu des Nains d''Erebor, conquis par le redoutable dragon Smaug. Alors qu''il croise par hasard la route du magicien Gandalf le Gris, Bilbon rejoint une bande de 13 nains dont le chef n''est autre que le l�gendaire guerrier Thorin �cu-de-Ch�ne. Leur p�riple les conduit au c�ur du Pays Sauvage, o� ils devront affronter des Gobelins, des Orques, des Ouargues meurtriers, des Araign�es g�antes, des M�tamorphes et des Sorciers�',
					'anglais',
					'http://www.thehobbit.com',
					'|Ian,McKellen, ,------------,null,C''est d�s son plus jeune �ge que la famille de Ian McKellen encourage sa passion pour le th��tre. Son p�re et son grand-p�re sont pr�dicateurs et le jeune Ian baigne dans un environnement profond�ment ancr� dans la religion chr�tienne. Toutefois, sa famille pratique une religion d�nu�e de toute consid�ration dogmatique en �rigeant la croyance en tant que syst�me de valeurs|Freeman,Martin, ,08/09/1971,null,Apr�s des �tudes d''art dramatique � Londres, Martin Freeman d�cide de se lancer dans la com�die en int�grant la "Young Action Theatre Of Teddington", une troupe de th��tre amateur qui connait un petit succ�s et qui va surtout permettre au com�dien de se faire rep�rer. A partir de 1997, il encha�ne ainsi les apparitions t�l�vis�es dans des s�ries telles que The Bill (1997) et Casualty (1998). Ses nombreuses prestations � la t�l�vision le font peu � peu conna�tre du grand public|',
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
Exec dbo.film_creer  
					@titre_VF='X-Men',
					@complement_titre='Le Commencement',
					@titre_VO='X-Men',
					@annee_sortie=2011,
					@synopsis='1944, dans un camp de concentration. S�par� par la force de ses parents, le jeune Erik Magnus Lehnsherr se d�couvre d''�tranges pouvoirs sous le coup de la col�re : il peut contr�ler les m�taux. C''est un mutant. Soixante ans plus tard, l''existence des mutants est reconnue mais provoque toujours un vif �moi au sein de la population. Puissant t�l�pathe, le professeur Charles Xavier dirige une �cole destin�e � recueillir ces �tres diff�rents, souvent rejet�s par les humains, et accueille un nouveau venu solitaire au pass� myst�rieux : Logan, alias Wolverine. En compagnie de Cyclope, Tornade et Jean Grey, les deux hommes forment les X-Men et vont affronter les sombres mutants ralli�s � la cause de Erik Lehnsherr / Magn�to, en guerre contre l''humanit�.',
					@langue='anglais',
					@site_web='http://www.xmen-first-class.com/',
					@liste_acteurs='|Ian,McKellen, ,2/05/1939,null,C''est d�s son plus jeune �ge que la famille de Ian McKellen encourage sa passion pour le th��tre. Son p�re et son grand-p�re sont pr�dicateurs et le jeune Ian baigne dans un environnement profond�ment ancr� dans la religion chr�tienne. Toutefois, sa famille pratique une religion d�nu�e de toute consid�ration dogmatique en �rigeant la croyance en tant que syst�me de valeurs|Jackman,Michael, ,12/10/1968,null,Dipl�m� en journalisme de l''University of Technology de Sydney, Hugh Jackman �tudie la com�die � la Western Australian Academy of Performing Arts, avant de d�buter devant la cam�ra dans la s�rie t�l�vis�e australienne Correlli (1995).L''acteur fait ses d�buts sur grand �cran en 1998 dans la com�die romantique Paperback hero. C''est en 2000 qu''il conna�t la cons�cration internationale en rempla�ant au pied lev� Dougray Scott, monopolis� par le tournage de Mission : impossible 2, dans X-Men|',
					@liste_realisateurs='|Singer,Bryan, ,1/09/1965,null,Dipl�m� en 1989 de l''USC School of Cinema-Television o� il rencontre le compositeur John Ottman.|',
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

Exec dbo._Vide_BD

--ALTER TABLE dbo.Film WITH CHECK CHECK CONSTRAINT chk_film_anneesortie;