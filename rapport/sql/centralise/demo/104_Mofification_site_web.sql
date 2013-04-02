Use IBDR_SAR
GO

EXEC dbo.film_modifier_site_web 'Le Hobbit', 2012, 'http://www.lehobbit.fr/';

Select f.TitreVF TitreVF,f.ComplementTitre ComplementTitre,f.TitreVO TitreVO, f.AnneeSortie AnneeSortie, f.SiteWeb
	 From Film f;