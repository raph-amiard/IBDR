Use IBDR_SAR
GO

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
					@liste_genres='|Fantastique|Science fiction|Action|';
					
Select f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias, Rolle='Acteur'
	 From Film f inner join FilmActeur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias,Rolle='R�alisateur'
 From Film f inner join FilmRealisateur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
Union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.NomProducteur Nom, f_pres.PrenomProducteur Prenom, f_pres.AliasProducteur Alias,Rolle='producteur'
 From Film f inner join FilmProducteur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie;