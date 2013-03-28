USE master;

IF (OBJECT_ID('dbo.drop_distribution') IS NOT NULL)
  DROP PROCEDURE dbo.drop_distribution
GO
CREATE PROCEDURE dbo.drop_distribution
AS
BEGIN
	exec sp_dropdistpublisher @publisher = @@SERVERNAME
	exec sp_dropdistributiondb @database = N'distribution'
	exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
END
GO


IF (OBJECT_ID('dbo.init_distribution') IS NOT NULL)
  DROP PROCEDURE dbo.init_distribution
GO
CREATE PROCEDURE dbo.init_distribution
AS
BEGIN
	BEGIN TRY
		exec dbo.drop_distribution
	END TRY
	BEGIN CATCH
		PRINT 'First run of init distribution'
	END CATCH
	
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

IF  EXISTS (SELECT * FROM sys.objects 
            WHERE object_id = OBJECT_ID(N'dbo.Internal_Server_Name') 
            AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
  DROP FUNCTION dbo.Internal_Server_Name
GO
CREATE FUNCTION dbo.Internal_Server_Name(@server_name nvarchar(512)) 
RETURNS nvarchar(512)
AS
BEGIN
	RETURN SUBSTRING(@server_name, CHARINDEX('\', @server_name)+1, 512);
END
GO

IF (OBJECT_ID('dbo.ajouter_serveur_lie') IS NOT NULL)
  DROP PROCEDURE dbo.ajouter_serveur_lie
GO
CREATE PROCEDURE dbo.ajouter_serveur_lie
	@serveur_lie nvarchar(512)
AS
BEGIN
	BEGIN TRY
		DECLARE @ServerName NVARCHAR(512);
		SET @ServerName = dbo.Internal_Server_Name(@serveur_lie)
		exec sp_addlinkedserver @server=@ServerName, @provider='SQLNCLI', @datasrc=@serveur_lie, @srvproduct=N'';
		exec sp_serveroption @server=@ServerName, @optname='rpc', @optvalue='true'
		exec sp_serveroption @server=@ServerName, @optname='rpc out', @optvalue='true'
	END TRY
	BEGIN CATCH
		PRINT 'Server already exists'
	END CATCH
END

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
	exec sp_addarticle @publication = N'IBDR_Global', 
					   @article = N'Client', @source_owner = N'dbo', @source_object = N'Client', 
					   @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', 
					   @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', 
					   @destination_table = N'Client', @destination_owner = N'dbo', @vertical_partition = N'false', 
					   @ins_cmd = N'CALL sp_MSins_dboClient', @del_cmd = N'CALL sp_MSdel_dboClient', 
					   @upd_cmd = N'SCALL sp_MSupd_dboClient'
	exec sp_addarticle @publication = N'IBDR_Global', 
					   @article = N'TypeAbonnement', @source_owner = N'dbo', @source_object = N'TypeAbonnement', 
					   @type = N'logbased', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', 
					   @schema_option = 0x000000000803509F, @identityrangemanagementoption = N'manual', 
					   @destination_table = N'TypeAbonnement', @destination_owner = N'dbo', @vertical_partition = N'false', 
					   @ins_cmd = N'CALL sp_MSins_dboTypeAbonnement', @del_cmd = N'CALL sp_MSdel_dboTypeAbonnement', 
					   @upd_cmd = N'SCALL sp_MSupd_dboTypeAbonnement'
	exec sp_startpublication_snapshot @publication = N'IBDR_Global';
END
GO

IF (OBJECT_ID('dbo.siege_social_init') IS NOT NULL)
  DROP PROCEDURE dbo.siege_social_init
GO
CREATE PROCEDURE dbo.siege_social_init
AS
BEGIN
	INSERT INTO Succursales (NomServeur, NomServeurFull, SiegeSocial) 
	VALUES (dbo.Internal_Server_Name(@@SERVERNAME), @@SERVERNAME, 1);
	
	exec ('use master; exec dbo.init_distribution')
	exec dbo.siege_social_creer_global_publication;
END
GO

-- exec dbo.succursale_init 'RAPH-PC\IBDR_0';
-- exec dbo.drop_distribution;
-- exec dbo.siege_social_init;
-- exec dbo.succursale_ajouter_abonnement_souscription_souscriveur 'RAPH-PC\IBDR_2';

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
	INSERT INTO Succursales (NomServeur, NomServeurFull, SiegeSocial) 
	VALUES (dbo.Internal_Server_Name(@Succursale), @Succursale, 0);
	
	exec dbo.siege_social_creer_global_souscription @Succursale;
END
GO

IF (OBJECT_ID('dbo.succursale_ajouter_abonnement_souscription_publieur') IS NOT NULL)
  DROP PROCEDURE dbo.succursale_ajouter_abonnement_souscription_publieur
GO
CREATE PROCEDURE dbo.succursale_ajouter_abonnement_souscription_publieur
	@serveur_souscripteur NVARCHAR(128)
AS
BEGIN
	exec sp_addmergesubscription @publication = N'IBDR_Abonnements', 
		@subscriber = @serveur_souscripteur, @subscriber_db = N'IBDR_SAR', 
		@subscription_type = N'pull', @subscriber_type = N'global', 
		@subscription_priority = 75, @sync_type = N'Automatic'
END
GO

IF (OBJECT_ID('dbo.succursale_ajouter_abonnement_souscription_souscriveur') IS NOT NULL)
  DROP PROCEDURE dbo.succursale_ajouter_abonnement_souscription_souscriveur
GO
CREATE PROCEDURE dbo.succursale_ajouter_abonnement_souscription_souscriveur
	@serveur_publieur NVARCHAR(128)
AS
BEGIN
	exec dbo.ajouter_serveur_lie @serveur_publieur;
	declare @isname nvarchar(512)
	SET @isname = dbo.Internal_Server_Name(@serveur_publieur);
	
	exec ('exec ' + @isname + '.IBDR_SAR.dbo.succursale_ajouter_abonnement_souscription_publieur @@SERVERNAME');
	
	exec sp_addmergepullsubscription @publisher = @serveur_publieur, 
									 @publication = N'IBDR_Abonnements', @publisher_db = N'IBDR_SAR', 
									 @subscriber_type = N'Global', @subscription_priority = 75, 
									 @description = N'', @sync_type = N'Automatic'
									 
	exec sp_addmergepullsubscription_agent @publisher = @serveur_publieur, 
										   @publisher_db = N'IBDR_SAR', @publication = N'IBDR_Abonnements', 
										   @distributor = @serveur_publieur, @distributor_security_mode = 1, 
										   @distributor_login = N'', @distributor_password = null, 
										   @enabled_for_syncmgr = N'False', @frequency_type = 64, 
										   @frequency_interval = 0, @frequency_relative_interval = 0, 
										   @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, 
										   @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20130328, 
										   @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', 
										   @use_ftp = N'False', @job_login = null, @job_password = null, @publisher_security_mode = 1, 
										   @publisher_login = null, @publisher_password = null, @use_interactive_resolver = N'False', 
										   @dynamic_snapshot_location = null, @use_web_sync = 0
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
	exec sp_addpullsubscription_agent @publisher = @serveur_siege_social, @publisher_db = N'IBDR_SAR', @publication = N'IBDR_Global', @distributor = @serveur_siege_social, @distributor_security_mode = 1, @distributor_login = N'', @distributor_password = null, @enabled_for_syncmgr = N'False', @frequency_type = 64, @frequency_interval = 0, @frequency_relative_interval = 0, @frequency_recurrence_factor = 0, @frequency_subday = 0, @frequency_subday_interval = 0, @active_start_time_of_day = 0, @active_end_time_of_day = 235959, @active_start_date = 20130325, @active_end_date = 99991231, @alt_snapshot_folder = N'', @working_directory = N'', @use_ftp = N'False', @job_login = null, @job_password = null, @publication_type = 0
END
GO

IF (OBJECT_ID('dbo.succursale_init') IS NOT NULL)
  DROP PROCEDURE dbo.succursale_init
GO
CREATE PROCEDURE dbo.succursale_init
	@serveur_siege_social nvarchar(512)
AS
BEGIN

	exec ('use master; exec dbo.init_distribution')
	exec dbo.ajouter_serveur_lie @serveur_siege_social
	
	declare @server_name nvarchar(128)
	SET @server_name = dbo.Internal_Server_Name(@serveur_siege_social)
	
	-- Init Publication Abonnements
	exec sp_replicationdboption @dbname = N'IBDR_SAR', @optname = N'merge publish', @value = N'true'
	exec sp_addmergepublication @publication = N'IBDR_Abonnements', @description = N'Merge publication of database ''IBDR_SAR'' from Publisher ''RAPH-PC\IBDR_1''.', @sync_mode = N'native', @retention = 14, @allow_push = N'true', @allow_pull = N'true', @allow_anonymous = N'true', @enabled_for_internet = N'false', @snapshot_in_defaultfolder = N'true', @compress_snapshot = N'false', @ftp_port = 21, @ftp_subdirectory = N'ftp', @ftp_login = N'anonymous', @allow_subscription_copy = N'false', @add_to_active_directory = N'false', @dynamic_filters = N'false', @conflict_retention = 14, @keep_partition_changes = N'false', @allow_synctoalternate = N'false', @max_concurrent_merge = 0, @max_concurrent_dynamic_snapshots = 0, @use_partition_groups = null, @publication_compatibility_level = N'100RTM', @replicate_ddl = 1, @allow_subscriber_initiated_snapshot = N'false', @allow_web_synchronization = N'false', @allow_partition_realignment = N'true', @retention_period_unit = N'days', @conflict_logging = N'both', @automatic_reinitialization_policy = 0
	exec sp_addpublication_snapshot @publication = N'IBDR_Abonnements', @frequency_type = 4, @frequency_interval = 1, @frequency_relative_interval = 1, @frequency_recurrence_factor = 0, @frequency_subday = 1, @frequency_subday_interval = 5, @active_start_time_of_day = 500, @active_end_time_of_day = 235959, @active_start_date = 0, @active_end_date = 0, @job_login = null, @job_password = null, @publisher_security_mode = 1
	exec sp_addmergearticle @publication = N'IBDR_Abonnements', @article = N'Abonnement', @source_owner = N'dbo', @source_object = N'Abonnement', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'auto', @pub_identity_range = 10000, @identity_range = 1000, @threshold = 80, @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = null, @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
	exec sp_addmergearticle @publication = N'IBDR_Abonnements', @article = N'Abonnement_Partage', @source_owner = N'dbo', @source_object = N'Abonnement_Partage', @type = N'table', @description = null, @creation_script = null, @pre_creation_cmd = N'drop', @schema_option = 0x000000010C034FD1, @identityrangemanagementoption = N'manual', @destination_owner = N'dbo', @force_reinit_subscription = 1, @column_tracking = N'false', @subset_filterclause = N'[SuccursaleDest]  = @@SERVERNAME', @vertical_partition = N'false', @verify_resolver_signature = 1, @allow_interactive_resolver = N'false', @fast_multicol_updateproc = N'true', @check_permissions = 0, @subscriber_upload_options = 0, @delete_tracking = N'true', @compensate_for_errors = N'false', @stream_blob_columns = N'false', @partition_options = 0
	exec sp_addmergefilter @publication = N'IBDR_Abonnements', @article = N'Abonnement', @filtername = N'Abonnement_Abonnement_Partage', @join_articlename = N'Abonnement_Partage', @join_filterclause = N'[Abonnement_Partage].[IdAbonnement] = [Abonnement].[Id] AND [Abonnement_Partage].[SuccursaleAbo] = [Abonnement].[Succursale]', @join_unique_key = 1, @filter_type = 1, @force_invalidate_snapshot = 1, @force_reinit_subscription = 1

	declare @sql nvarchar(max)
	exec ('exec ' + @server_name + '.IBDR_SAR.dbo.siege_social_add_succursale @@SERVERNAME')
	exec succursale_creer_global_souscription @serveur_siege_social
END
GO