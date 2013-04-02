### Le But

Ce test a pour but montrer le cas de suppression d'une édition. 
Cette suppression vas supprimer aussi tous les exemplaires de cette édition 
qui se trouvent dans les succursales.

### Mode d'emploi

Pour executer ce test, il faut executer les scripts dans l'ordre suivant :

01_ajouter_editon_SiegeSocial.sql (executer dans la Siège Social)

02_ajouter_exemplaires_Succursale.sql (executer dans chaque Succursale)

03_supprimer_editon_SiegeSocial.sql (executer dans la Siège Social)

04_lister_exemplaires_Succursale.sql (executer dans chaque Succursale)