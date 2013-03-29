Use IBDR_SAR
GO

-- Ajouter une distinction à 'Hobbit'					
Exec dbo.film_ajouter_distinction  'Oscar des Meilleurs décors',2013,'Le Hobbit',2012; 

Select d.Annee, d.NomDistinction,d.TitreVF,d.AnneeSortie as AnneeSortieFilm From FilmDistinction as d;