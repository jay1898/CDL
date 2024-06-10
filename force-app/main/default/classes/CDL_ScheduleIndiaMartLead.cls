global class CDL_ScheduleIndiaMartLead implements Schedulable 
{
   global void execute(SchedulableContext SC) 
   {
      //CDL_CreatedLeadController.createLead();
      createLead();  
   }
   @future(callout=true)
    public static void createLead()
    {
        Id indiaMartRecordTypeId = Schema.SObjectType.Lead__c.getRecordTypeInfosByName().get('IndiaMart').getRecordTypeId();
        Datetime todays = Datetime.now();
        Datetime startDate = todays.addDays(-6);
        
        String startDateFormatted = startDate.format('dd-MMM-yyyy');
        String endDateFormatted = todays.format('dd-MMM-yyyy');
        
        // Define other dynamic parameters
        String glusr_crm_key = System.Label.IndiaMartSecretKey;
        
        // Build the endpoint URL with dynamic parameters
        String endpointUrl = 'https://mapi.indiamart.com/wservce/crm/crmListing/v2/?glusr_crm_key=' + glusr_crm_key
            + '&start_time=' + startDateFormatted
            + '&end_time=' + endDateFormatted;
        
        System.debug('endpointUrl:: '+endpointUrl);      
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        System.debug('response data: '+res.getBody());
        map<String,object> jsonbody = (map<String,object>)json.deserializeuntyped(res.getbody());
        
        List<object> responseList = (List<object>)jsonbody.get('RESPONSE');
        List<Lead__c> LeadList = new List<Lead__c>();
        
        for(Object ob: responseList)
        {
            Map<String,Object> leadMap = (Map<String,Object>) ob;
            Lead__c newLead = new Lead__c(); 
            newLead.RecordTypeId = indiaMartRecordTypeId;
            newLead.Query_Id__c = String.valueOf(leadMap.get('UNIQUE_QUERY_ID'));
            newLead.Query_Type__c = String.valueOf(leadMap.get('QUERY_TYPE'));
            newLead.Quert_Time__c = Datetime.valueOf(String.valueOf(leadMap.get('QUERY_TIME')));
            newLead.Name__c = String.valueOf(leadMap.get('SENDER_NAME'));
            newLead.Mobile__c = String.valueOf(leadMap.get('SENDER_MOBILE'));
            newLead.Email__c = String.valueOf(leadMap.get('SENDER_EMAIL'));
            newLead.Subject__c= String.valueOf(leadMap.get('SUBJECT'));
            newLead.Company__c = String.valueOf(leadMap.get('SENDER_COMPANY'));
            newLead.Address__c = String.valueOf(leadMap.get('SENDER_ADDRESS'));
            newLead.City__c = String.valueOf(leadMap.get('SENDER_CITY'));
            newLead.State__c = String.valueOf(leadMap.get('SENDER_STATE'));
            newLead.Pincode__c = String.valueOf(leadMap.get('SENDER_PINCODE'));
            newLead.Country_ISO__c = String.valueOf(leadMap.get('SENDER_COUNTRY_ISO'));
            newLead.Phone__c= String.valueOf(leadMap.get('SENDER_PHONE'));
            newLead.Query_Product_Name__c = String.valueOf(leadMap.get('QUERY_PRODUCT_NAME'));
            newLead.Query_Message__c = String.valueOf(leadMap.get('QUERY_MESSAGE'));
            LeadList.add(newLead);
          
        } 
        
        Database.UpsertResult[] upsertResults = Database.upsert(LeadList, Lead__c.Fields.Query_Id__c, false);
        
        
        for (Database.UpsertResult result : upsertResults) {
            if (result.isSuccess()) {
                // Record was inserted or updated successfully
            } else {
                // Handle the error for the failed upsert
                Database.Error error = result.getErrors()[0];
                System.debug('Error message: ' + error.getMessage());
                System.debug('Fields that caused the error: ' + error.getFields());
            }
        }
        
    } 
}