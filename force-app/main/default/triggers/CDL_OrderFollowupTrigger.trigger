trigger CDL_OrderFollowupTrigger on Order_Follow_Up__c (after update) {
    if (trigger.isAfter) 
    {
        if (trigger.isUpdate) 
        {
            CDL_OrderFollowupTriggerHandler.updateOrderNote(Trigger.new,Trigger.oldMap);
        }
    }
}