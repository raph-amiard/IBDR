Use IBDR_SAR
GO

-- Ajouté le film 'X-Men'
Exec dbo.film_creer  
					@titre_VF='X-Men',
					@complement_titre='Le Commencement',
					@titre_VO='X-Men',
					@annee_sortie=2011,
					@synopsis='1944, dans un camp de concentration. Séparé par la force de ses parents, le jeune Erik Magnus Lehnsherr se découvre d''étranges pouvoirs sous le coup de la colère : il peut contrôler les métaux. C''est un mutant. Soixante ans plus tard, l''existence des mutants est reconnue mais provoque toujours un vif émoi au sein de la population. Puissant télépathe, le professeur Charles Xavier dirige une école destinée à recueillir ces êtres différents, souvent rejetés par les humains, et accueille un nouveau venu solitaire au passé mystérieux : Logan, alias Wolverine. En compagnie de Cyclope, Tornade et Jean Grey, les deux hommes forment les X-Men et vont affronter les sombres mutants ralliés à la cause de Erik Lehnsherr / Magnéto, en guerre contre l''humanité.',
					@langue='anglais',
					@site_web='http://www.xmen-first-class.com/',
					@liste_acteurs='|Ian,McKellen, ,2/05/1939,null,C''est dès son plus jeune âge que la famille de Ian McKellen encourage sa passion pour le théâtre. Son père et son grand-père sont prédicateurs et le jeune Ian baigne dans un environnement profondément ancré dans la religion chrétienne. Toutefois, sa famille pratique une religion dénuée de toute considération dogmatique en érigeant la croyance en tant que système de valeurs|Jackman,Michael, ,12/10/1968,null,Diplômé en journalisme de l''University of Technology de Sydney, Hugh Jackman étudie la comédie à la Western Australian Academy of Performing Arts, avant de débuter devant la caméra dans la série télévisée australienne Correlli (1995).L''acteur fait ses débuts sur grand écran en 1998 dans la comédie romantique Paperback hero. C''est en 2000 qu''il connaît la consécration internationale en remplaçant au pied levé Dougray Scott, monopolisé par le tournage de Mission : impossible 2, dans X-Men|',
					@liste_realisateurs='|Singer,Bryan, ,1/09/1965,null,Diplômé en 1989 de l''USC School of Cinema-Television où il rencontre le compositeur John Ottman.|',
					@liste_producteurs='',
					@liste_genres='|Fantastique|Science fiction|Action|';
					
Select f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias, Rolle='Acteur'
	 From Film f inner join FilmActeur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.Nom Nom, f_pres.Prenom Prenom, f_pres.Alias Alias,Rolle='Réalisateur'
 From Film f inner join FilmRealisateur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie
Union
Select  f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f_pres.NomProducteur Nom, f_pres.PrenomProducteur Prenom, f_pres.AliasProducteur Alias,Rolle='producteur'
 From Film f inner join FilmProducteur f_pres ON f.TitreVF=f_pres.TitreVF and f.AnneeSortie=f_pres.AnneeSortie;