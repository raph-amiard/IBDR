USE master;
IF (OBJECT_ID('dbo.siege_social_init_distribution') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_init_distribution
GO
CREATE PROCEDURE dbo.siege_social_init_distribution
AS
BEGIN
	exec sp_adddistributor @distributor = @@SERVERNAME, @password = N''

	exec sp_MSupdate_agenttype_default @profile_id = 1
	exec sp_MSupdate_agenttype_default @profile_id = 2
	exec sp_MSupdate_agenttype_default @profile_id = 4
	exec sp_MSupdate_agenttype_default @profile_id = 6
	exec sp_MSupdate_agenttype_default @profile_id = 11

	exec sp_adddistributiondb @database = N'distribution', 
							  @min_distretention = 0, 
							  @max_distretention = 72, 
							  @history_retention = 48, 
							  @security_mode = 1

	exec sp_adddistpublisher @publisher = @@SERVERNAME, 
							 @distribution_db = N'distribution', 
							 @security_mode = 1, 
							 @trusted = N'false', 
							 @thirdparty_flag = 0, 
							 @publisher_type = N'MSSQLSERVER'
END
GO

USE IBDR_SAR;
IF (OBJECT_ID('dbo.siege_social_drop_distribution') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_drop_distribution
GO
CREATE PROCEDURE dbo.siege_social_drop_distribution
AS
BEGIN
	exec sp_dropdistpublisher @publisher = @@SERVERNAME
	exec sp_dropdistributiondb @database = N'distribution'
	exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
END
GO

IF (OBJECT_ID('dbo.siege_social_creer_global_publication') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_creer_global_publication
GO
CREATE PROCEDURE dbo.siege_social_creer_global_publication
AS
BEGIN

	exec sp_replicationdboption @dbname = N'IBDR_SAR', @optname = N'publish', @value = N'true'


	exec sp_addpublication @publication = N'IBDR_Global', 
						   @description = N'Transactional publication', 
						   @sync_method = N'concurrent', 
						   @retention = 0, 
						   @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', 
						   @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', 
						   @compress_snapshot = N'false', @ftp_port = 21, @allow_subscription_copy = N'false', 
						   @add_to_active_directory = N'false', @repl_freq = N'continuous', 
						   @status = N'active', @independent_agent = N'true', 
						   @immediate_sync = N'true', @allow_sync_tran = N'false', @allow_queued_tran = N'false', 
						   @allow_dts = N'false', @replicate_ddl = 1, @allow_initialize_from_backup = N'false', 
						   @enabled_for_p2p = N'false', @enabled_for_het_sub = N'false'

	exec sp_addpublication_snapshot @publication = N'IBDR_Global', 
									@frequency_type = 1, 
									@frequency_interval = 1, 
									@frequency_relative_interval = 1, 
									@frequency_recurrence_factor = 0, 
									@frequency_subday = 8, @frequency_subday_interval = 1, 
									@active_start_time_of_day = 0, @active_end_time_of_day = 235959, 
									@active_start_date = 0, @active_end_date = 0, 
									@job_login = null, @job_password = null, @publisher_security_mode = 1


	exec sp_addarticle @publication = N'IBDR_Global', 
					   @article = N'Editeur', @source_owner = N'dbo', @source_object = N'Editeur', 
					   @type = N'logbased', @description = null, @creation_script = null, 
					   @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, 
					   @identityrangemanagementoption = N'manual', @destination_table = N'Editeur', 
					   @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboEditeur', 
					   @del_cmd = N'CALL sp_MSdel_dboEditeur', @upd_cmd = N'SCALL sp_MSupd_dboEditeur'

	exec sp_addarticle @publication = N'IBDR_Global', 
					   @article = N'EditeurEdition', @source_owner = N'dbo', @source_object = N'EditeurEdition', 
					   @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', 
					   @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', 
					   @destination_table = N'EditeurEdition', @destination_owner = N'dbo', @vertical_partition = N'false', 
					   @ins_cmd = N'CALL sp_MSins_dboEditeurEdition', @del_cmd = N'CALL sp_MSdel_dboEditeurEdition', 
					   @upd_cmd = N'SCALL sp_MSupd_dboEditeurEdition'

	exec sp_addarticle @publication = N'IBDR_Global', @article = N'Edition', @source_owner = N'dbo', @source_object = N'Edition', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Edition', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboEdition', @del_cmd = N'CALL sp_MSdel_dboEdition', @upd_cmd = N'SCALL sp_MSupd_dboEdition'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'EditionLangueAudio', @source_owner = N'dbo', @source_object = N'EditionLangueAudio', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'EditionLangueAudio', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboEditionLangueAudio', @del_cmd = N'CALL sp_MSdel_dboEditionLangueAudio', @upd_cmd = N'SCALL sp_MSupd_dboEditionLangueAudio'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'EditionLangueSousTitres', @source_owner = N'dbo', @source_object = N'EditionLangueSousTitres', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'EditionLangueSousTitres', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboEditionLangueSousTitres', @del_cmd = N'CALL sp_MSdel_dboEditionLangueSousTitres', @upd_cmd = N'SCALL sp_MSupd_dboEditionLangueSousTitres'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'Film', @source_owner = N'dbo', @source_object = N'Film', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Film', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboFilm', @del_cmd = N'CALL sp_MSdel_dboFilm', @upd_cmd = N'SCALL sp_MSupd_dboFilm'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'FilmActeur', @source_owner = N'dbo', @source_object = N'FilmActeur', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'FilmActeur', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboFilmActeur', @del_cmd = N'CALL sp_MSdel_dboFilmActeur', @upd_cmd = N'SCALL sp_MSupd_dboFilmActeur'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'FilmDistinction', @source_owner = N'dbo', @source_object = N'FilmDistinction', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'FilmDistinction', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboFilmDistinction', @del_cmd = N'CALL sp_MSdel_dboFilmDistinction', @upd_cmd = N'SCALL sp_MSupd_dboFilmDistinction'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'FilmGenre', @source_owner = N'dbo', @source_object = N'FilmGenre', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'FilmGenre', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboFilmGenre', @del_cmd = N'CALL sp_MSdel_dboFilmGenre', @upd_cmd = N'SCALL sp_MSupd_dboFilmGenre'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'FilmProducteur', @source_owner = N'dbo', @source_object = N'FilmProducteur', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'FilmProducteur', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboFilmProducteur', @del_cmd = N'CALL sp_MSdel_dboFilmProducteur', @upd_cmd = N'SCALL sp_MSupd_dboFilmProducteur'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'FilmRealisateur', @source_owner = N'dbo', @source_object = N'FilmRealisateur', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'FilmRealisateur', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboFilmRealisateur', @del_cmd = N'CALL sp_MSdel_dboFilmRealisateur', @upd_cmd = N'SCALL sp_MSupd_dboFilmRealisateur'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'Genre', @source_owner = N'dbo', @source_object = N'Genre', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Genre', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboGenre', @del_cmd = N'CALL sp_MSdel_dboGenre', @upd_cmd = N'SCALL sp_MSupd_dboGenre'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'Langue', @source_owner = N'dbo', @source_object = N'Langue', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Langue', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboLangue', @del_cmd = N'CALL sp_MSdel_dboLangue', @upd_cmd = N'SCALL sp_MSupd_dboLangue'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'Pays', @source_owner = N'dbo', @source_object = N'Pays', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Pays', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboPays', @del_cmd = N'CALL sp_MSdel_dboPays', @upd_cmd = N'SCALL sp_MSupd_dboPays'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'Personne', @source_owner = N'dbo', @source_object = N'Personne', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'Personne', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboPersonne', @del_cmd = N'CALL sp_MSdel_dboPersonne', @upd_cmd = N'SCALL sp_MSupd_dboPersonne'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'PersonneDistinction', @source_owner = N'dbo', @source_object = N'PersonneDistinction', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'PersonneDistinction', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboPersonneDistinction', @del_cmd = N'CALL sp_MSdel_dboPersonneDistinction', @upd_cmd = N'SCALL sp_MSupd_dboPersonneDistinction'
	exec sp_addarticle @publication = N'IBDR_Global', @article = N'TypeDistinction', @source_owner = N'dbo', @source_object = N'TypeDistinction', @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', @destination_table = N'TypeDistinction', @destination_owner = N'dbo', @vertical_partition = N'false', @ins_cmd = N'CALL sp_MSins_dboTypeDistinction', @del_cmd = N'CALL sp_MSdel_dboTypeDistinction', @upd_cmd = N'SCALL sp_MSupd_dboTypeDistinction'
	exec sp_addarticle @publication = N'IBDR_Global', 
					   @article = N'Succursales', @source_owner = N'dbo', @source_object = N'Succursales', 
					   @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', 
					   @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', 
					   @destination_table = N'Succursales', @destination_owner = N'dbo', @vertical_partition = N'false', 
					   @ins_cmd = N'CALL sp_MSins_dboSuccursales', @del_cmd = N'CALL sp_MSdel_dboSuccursales', 
					   @upd_cmd = N'SCALL sp_MSupd_dboSuccursales'
	exec sp_startpublication_snapshot @publication = N'IBDR_Global';
END
GO

IF (OBJECT_ID('dbo.siege_social_init') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_init
GO
CREATE PROCEDURE dbo.siege_social_init
AS
BEGIN
	INSERT INTO Succursales (NomServeur, SiegeSocial) VALUES (@@SERVERNAME, 1);
	exec ('use master; exec dbo.siege_social_init_distribution')
	exec dbo.siege_social_creer_global_publication;
END
GO

-- exec dbo.succursale_init 'RAPH-DESKTOP-W7\IBDR_1';
-- exec dbo.siege_social_drop_distribution;
-- exec dbo.siege_social_init;


IF (OBJECT_ID('dbo.siege_social_creer_global_souscription') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_creer_global_souscription
GO
CREATE PROCEDURE dbo.siege_social_creer_global_souscription
	@nom_serveur_succursale NVARCHAR(512)
AS
BEGIN
	exec sp_addsubscription @publication = N'IBDR_Global', 
							@subscriber = @nom_serveur_succursale,
							@destination_db = N'IBDR_SAR', 
							@sync_type = N'Automatic', 
							@subscription_type = N'pull', 
							@update_mode = N'read only'
END
GO

IF (OBJECT_ID('dbo.siege_social_add_succursale') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_add_succursale
GO
CREATE PROCEDURE dbo.siege_social_add_succursale
	@Succursale NVARCHAR(512)
AS
BEGIN
	INSERT INTO Succursales (NomServeur, SiegeSocial) VALUES (@Succursale, 0);
	exec dbo.siege_social_creer_global_souscription @Succursale;
END
GO

IF (OBJECT_ID('dbo.succursale_creer_global_souscription') IS NOT NULL)
  DROP PROCEDURE dbo.succursale_creer_global_souscription
GO
CREATE PROCEDURE dbo.succursale_creer_global_souscription
	@serveur_siege_social NVARCHAR(512)
AS
BEGIN
	exec sp_addpullsubscription @publisher = @serveur_siege_social, @publication = N'IBDR_Global', @publisher_db = N'IBDR_SAR', @independent_agent = N'True', @subscription_type = N'pull', @description = N'', @update_mode = N'read only', @immediate_sync = 1
	exec sp_addpullsubscription_agent @publisher = @serveur_siege_social, @publisher_db = N'IBDR_SAR', @publication = N'IBDR_Global', @distributor = N'RAPH-DESKTOP-W7\IBDR_1', @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20130325, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
END
GO

IF (OBJECT_ID('dbo.succursale_init') IS NOT NULL)
  DROP PROCEDURE dbo.succursale_init
GO
CREATE PROCEDURE dbo.succursale_init
	@serveur_siege_social nvarchar(512)
AS
BEGIN
	exec sp_addlinkedserver @server='SIEGE_SOCIAL', @provider='SQLNCLI', @datasrc=@serveur_siege_social, @srvproduct=N'';
	exec sp_serveroption @server='SIEGE_SOCIAL', @optname='rpc', @optvalue='true'
	exec sp_serveroption @server='SIEGE_SOCIAL', @optname='rpc out', @optvalue='true'
	
	declare @sql nvarchar(max)
	exec SIEGE_SOCIAL.IBDR_SAR.dbo.siege_social_add_succursale @@SERVERNAME;
	exec succursale_creer_global_souscription @serveur_siege_social
END
GO