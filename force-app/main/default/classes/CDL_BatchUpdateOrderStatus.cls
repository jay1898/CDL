global class CDL_BatchUpdateOrderStatus implements Database.Batchable<sObject>,Schedulable,Database.AllowsCallouts {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        List<AsyncApexJob> listAA=[Select Id, Status,ApexClassId,ApexClass.Name, NumberOfErrors, 
                                   JobItemsProcessed,TotalJobItems, ExtendedStatus 
                                   From AsyncApexJob 
                                   Where ApexClass.Name='CDL_BatchUpdateOrderStatus'
                                   And Status in ('Holding','Processing')];
        if(listAA.size()>0){
            return Database.getQueryLocator([SELECT Id,Order_Id__c,Name,Track_Id__c,Last_Delivery_Status_Change_Date__c,Order_Delivery_Status__c FROM order__c
                                             where Track_Id__c !=null and Order_Delivery_Status__c != 'DELIVERED'  Limit 0]); 
        }
        return Database.getQueryLocator([SELECT Id,Order_Id__c,Name,Track_Id__c,Last_Delivery_Status_Change_Date__c,Order_Delivery_Status__c FROM order__c
                                         where Track_Id__c !=null and Order_Delivery_Status__c != 'DELIVERED'  Limit 50000]);
    }
    global void execute(Database.BatchableContext bc, List<order__c> scope)
    {
        Map<String,String> updateOrderStatus = new Map<String,String>();
        Map<String,String>TrackIdandOrderIdMap = new Map<String,String>();
        
        for(order__c gettrackId : scope)
        {                          
            TrackIdandOrderIdMap.put(gettrackId.Track_Id__c,gettrackId.Id);           
        }
        
        String trackingIds = String.join(TrackIdandOrderIdMap.keySet(), ',');
        String ResponseBody = getorderStatus(trackingIds);
        if(String.isNotBlank(ResponseBody))
        {            
            map<String,object> jsonbody = (map<String,object>)json.deserializeuntyped(ResponseBody);
            Map<String, Object> dataObject = (Map<String, Object>) jsonBody.get('data');
            List<object> responseList = (List<object>)dataObject.get('response');
            List<String> existingDeliveryTracks = new List<String>();
            
            for(Delivery_Track__c deliverytrack : [SELECT Id,Name, Order__c, Status__c, Updated_Date__c, Location__c, Expected_Delivery__c, Remark__c FROM Delivery_Track__c  Limit 50000])
            {
                String trackIdandDateTime = String.valueof(deliverytrack.Updated_Date__c) +' '+ deliverytrack.Name +' '+deliverytrack.Remark__c;
                existingDeliveryTracks.add(trackIdandDateTime);
            }              
            List<Delivery_Track__c> deliveryTrackList = new List<Delivery_Track__c>();            
            if(existingDeliveryTracks.Size() >0)
            {             
                for(Object rob: responseList)
                {
                    Map<String,Object> orderMap = (Map<String,Object>) rob;                 
                    List<Object> scanDetailList = (List<Object>) orderMap.get('scan_detail');
                    updateOrderStatus.put((String) orderMap.get('awbno'),(String) orderMap.get('shipment_latest_status'));
                    for(Object sob: scanDetailList)
                    {	
                        Map<String, Object> scanDetailMap = (Map<String, Object>) sob;
                        String trackIdandDateTime = (String) scanDetailMap.get('updated_date') +' '+ (String) scanDetailMap.get('awbno')+' '+(String) scanDetailMap.get('remarks');
                        if(!existingDeliveryTracks.contains(trackIdandDateTime))
                        {
                            Delivery_Track__c createDeliveryTrack = new Delivery_Track__c();
                            if(String.isNotBlank((String) scanDetailMap.get('awbno')))
                            {
                                //String[] parts = TrackIdandOrderIdMap.get((String) scanDetailMap.get('awbno')).split(' ');                                                           
                                createDeliveryTrack.Name = (String) scanDetailMap.get('awbno'); 
                                createDeliveryTrack.Order__c = TrackIdandOrderIdMap.get((String) scanDetailMap.get('awbno'));
                                //createDeliveryTrack.OwnerId = parts[1];                         
                            }
                            if(String.isNotBlank((String) scanDetailMap.get('status')))
                            {
                                createDeliveryTrack.Status__c = (String) scanDetailMap.get('status');
                            }
                            if(String.isNotBlank((String) scanDetailMap.get('updated_date')))
                            {
                                createDeliveryTrack.Updated_Date__c = Datetime.valueOf((String) scanDetailMap.get('updated_date'));
                            }
                            if(String.isNotBlank((String) scanDetailMap.get('location')))
                            {
                                createDeliveryTrack.Location__c = (String) scanDetailMap.get('location');
                            }
                            if(String.isNotBlank((String) scanDetailMap.get('exp_delivery')))
                            {
                                createDeliveryTrack.Expected_Delivery__c = Date.valueOf((String) scanDetailMap.get('exp_delivery'));
                            }
                            if(String.isNotBlank((String) scanDetailMap.get('remarks')))
                            {
                                createDeliveryTrack.Remark__c = (String) scanDetailMap.get('remarks');
                            }
                            deliveryTrackList.add(createDeliveryTrack);
                        }                                
                    }
                    
                }
                Insert deliveryTrackList;
                
                //Update Dilivery Status on Order Object
                for(order__c gettrackId : scope)
                {
                    gettrackId.Order_Delivery_Status__c = updateOrderStatus.get(gettrackId.Track_Id__c);
                    gettrackId.Last_Delivery_Status_Change_Date__c=DateTime.valueof(DateTime.now().format('yyyy-MM-dd hh:mm:ss'));//DateTime.now();
                }
                Update scope;    
            } 
        }     
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    public void execute(SchedulableContext sc) 
    {    
        CDL_BatchUpdateOrderStatus b = new CDL_BatchUpdateOrderStatus();
        database.executebatch(b);
        
    }   
    
    global static String getorderStatus(String trackingIds)
    {
        String api_key = System.Label.instashipinAPIKey;
        String endpointUrl = 'https://api.instashipin.com/api/ilogix/track?api_key=' + api_key
            + '&airwaybilno=' + trackingIds;
        
        System.debug('endpointUrl:: '+endpointUrl);      
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpointUrl);
        req.setMethod('GET');
        req.setTimeout(120000);
        try{
            HttpResponse res = h.send(req);
            System.debug('response data: '+res.getBody());
            map<String,object> jsonbody = (map<String,object>)json.deserializeuntyped(res.getBody());
            Map<String, Object> dataObject = (Map<String, Object>) jsonBody.get('data'); 
            boolean error = boolean.valueof(dataObject.get('error'));
            
            if((res.getStatusCode() == 200 || res.getStatusCode() == 201) && error != true)
            {
                return res.getBody();   
            }else
            {
                return null;
            }
        }catch(Exception e){
            Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
            createResponseRecord.Name = 'Batch Failed CDL_BatchUpdateOrderStatus';
            createResponseRecord.Error_Log__c  = 'Line No: '+e.getLineNumber()+' '+ e.getMessage();
            //createResponseRecord.Response_Data__c = e.getMessage();
            Insert createResponseRecord;
            return null;          
        }
    }
}