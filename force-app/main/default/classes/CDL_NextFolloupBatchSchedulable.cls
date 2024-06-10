global class CDL_NextFolloupBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        Datetime currentTime = Datetime.now();
        Id batchJobId = Database.executeBatch(new CDL_NextFolloupBatch(currentTime));
        
        List<CronTrigger> abort_job = [SELECT Id,CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name =:'CDL NextFolloupUp Batch'];
        for (CronTrigger t : abort_job)
        {
        	System.abortJob(t.Id);
        }
        
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(15);

        String cronExp = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        CDL_NextFolloupBatchSchedulable orderStatus = new CDL_NextFolloupBatchSchedulable();
		String jobIDsendmail = System.schedule('CDL NextFolloupUp Batch',cronExp, orderStatus);
    }
}