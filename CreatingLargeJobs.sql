declare @jobnm NVARCHAR(128)
declare @job_nm NVARCHAR(128)
declare @job_query NVARCHAR(MAX)
declare @num_jobs INT
declare @MaxJobs INT
--SET THIS VALUE TO CREATE REQUIRED NUMBER OF JOBS
set @MaxJobs =100
set @jobnm='SampleJobs'

set @num_jobs=1
while @num_jobs < @MaxJobs
begin
	

	/****** Object:  Job [second]    Script Date: 07/06/2012 14:08:47 ******/
	BEGIN TRANSACTION
	DECLARE @ReturnCode INT
	SELECT @ReturnCode = 0
	/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 07/06/2012 14:08:47 ******/
	IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
	BEGIN
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

	END

	DECLARE @jobId BINARY(16)
    
    set @job_nm=@jobnm+Cast(@num_jobs as nvarchar(5));
    print'job name:' + @job_nm;
    set @jobId=NULL;
	EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@job_nm, 
			@enabled=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=0, 
			@notify_level_netsend=0, 
			@notify_level_page=0, 
			@delete_level=0, 
			@description=N'No description available.', 
			@category_name=N'[Uncategorized (Local)]', 
			@owner_login_name=N'pg3\sqladmin', @job_id = @jobId OUTPUT
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	/****** Object:  Step [start]    Script Date: 07/06/2012 14:08:47 ******/
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep  @job_name=@job_nm, @step_name=N'start', 
			@step_id=1, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@command=N'select * from sys.objects', 
			@database_name=N'master', 
			@flags=0
	print'job name:' + @job_nm;
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	/****** Object:  Step [end]    Script Date: 07/06/2012 14:08:47 ******/
	EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_name=@job_nm, @step_name=N'end', 
			@step_id=2, 
			@cmdexec_success_code=0, 
			@on_success_action=1, 
			@on_success_step_id=0, 
			@on_fail_action=2, 
			@on_fail_step_id=0, 
			@retry_attempts=0, 
			@retry_interval=0, 
			@os_run_priority=0, @subsystem=N'TSQL', 
			@database_name=N'master', 
			@flags=0
	print'job name:' + @job_nm;
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_update_job @job_name=@job_nm, @start_step_id = 1
	print'job name:' + @job_nm;
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_name=@job_nm, @server_name = N'(local)'
	print'job name:' + @job_nm;
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
	COMMIT TRANSACTION
	GOTO EndSave
	QuitWithRollback:
		IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
	EndSave:

	
set @num_jobs= @num_jobs +1;
END

