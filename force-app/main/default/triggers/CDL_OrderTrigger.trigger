trigger CDL_OrderTrigger on Order__c (before Insert,after Insert,after Update) {
    
    if (trigger.isAfter) 
    {
        Map<Id,User> userDetails = new Map<Id,User>([Select Id,Name from user limit 50000]);
        if (trigger.isUpdate) 
        {
            CDL_OrderTriggerHandler.afterUpdate(Trigger.new,Trigger.oldMap,userDetails);
        } 
        if(trigger.isInsert)
        {
           CDL_OrderTriggerHandler.afterInsert(Trigger.new,userDetails);
        }
    }
    
    if (trigger.isBefore) 
    {
        CDL_OrderTriggerHandler.beforeInsert(Trigger.new);
    }           
    
}