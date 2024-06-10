@isTest
public class CDL_LeadTriggerHandlerTest 
{
    static testMethod void updateLeadOwner() 
    {
    	Lead__c objLead = new Lead__c();
        objLead.Name__c = 'test';
        insert objLead;
    }
}