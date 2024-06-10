global class CDL_UpdateOrderStatusSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) 
    {
        Id batchJobId = Database.executeBatch(new CDL_BatchUpdateOrderStatus());
        
        List<CronTrigger> abort_job = [SELECT Id,CronJobDetail.Name FROM CronTrigger where CronJobDetail.Name =:'Update Order Delivery Status'];
        for (CronTrigger t : abort_job)
        {
        	System.abortJob(t.Id);
        }
        
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(20);

        String cronExp = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        CDL_UpdateOrderStatusSchedulable orderStatus = new CDL_UpdateOrderStatusSchedulable();
		String jobIDsendmail = System.schedule('Update Order Delivery Status',cronExp, orderStatus);
    }
}