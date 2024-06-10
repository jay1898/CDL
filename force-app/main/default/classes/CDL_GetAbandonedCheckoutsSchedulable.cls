global class CDL_GetAbandonedCheckoutsSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        System.enqueueJob(new CDL_GetAbandonedCheckoutsQueue());
        
        List<CronTrigger> abort_job = [SELECT Id,CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name =:'Retrieve Shopify Abandoned Order'];
        for (CronTrigger t : abort_job)
        {
        	System.abortJob(t.Id);
        }
        
        // Schedule the same Schedulable class again in 15 minutes
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(15);

        String cronExp = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        CDL_GetAbandonedCheckoutsSchedulable abandonedOrder = new CDL_GetAbandonedCheckoutsSchedulable();
		String jobIDsendmail = System.schedule('Retrieve Shopify Abandoned Order',cronExp, abandonedOrder); 
    }
}