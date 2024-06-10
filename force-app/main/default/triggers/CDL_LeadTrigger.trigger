trigger CDL_LeadTrigger on Lead__c (before insert) 
{
    if (trigger.isInsert) 
    {
        if (trigger.isBefore) 
        {
            CDL_LeadTriggerHandler.beforeInsert(Trigger.new);
        }           
    }
}