IF (OBJECT_ID('dbo.configurer_siege_social_init_distribution') IS NOT NULL)
  DROP PROCEDURE dbo.edition_creer
GO
CREATE PROCEDURE dbo.configurer_siege_social_init_distribution
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

IF (OBJECT_ID('dbo.configurer_siege_social_drop_distribution') IS NOT NULL)
  DROP PROCEDURE dbo.edition_creer
GO
CREATE PROCEDURE configurer_siege_social_drop_distribution
AS
BEGIN
	exec sp_dropdistpublisher @publisher = @@SERVERNAME
	exec sp_dropdistributiondb @database = N'distribution'
	exec sp_dropdistributor @no_checks = 1, @ignore_distributor = 1
END
GO

exec configurer_siege_social_drop_distribution;