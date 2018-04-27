USE [msdb]
GO

declare @jobnm NVARCHAR(128)
declare @job_nm NVARCHAR(128)
declare @MaxJobs INT
declare @num_jobs INT
set @MaxJobs =5				--number of jobs to be deleted
set @jobnm='SampleJobs'		--name of job created using job creation script

set @num_jobs=1
while @num_jobs < @MaxJobs
begin
	set @job_nm=@jobnm+Cast(@num_jobs as nvarchar(5));
	EXEC msdb.dbo.sp_delete_job @job_name=@job_nm, @delete_unused_schedule=1
	set @num_jobs= @num_jobs +1;
end


