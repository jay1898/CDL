trigger CDL_AccountTrigger on Account (before insert) 
{
	if (trigger.isInsert) 
    {
        if (trigger.isBefore) 
        {
            CDL_AccountTriggerHandler.beforeInsert(Trigger.new);
        }           
    }
}