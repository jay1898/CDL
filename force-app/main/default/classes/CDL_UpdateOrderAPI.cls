@RestResource(urlMapping='/OrderStatus/*')
global without sharing class CDL_UpdateOrderAPI 
{
    global class Response
    {
        public String status; 
        public String httpStatusCode;
        public String errorMessage ;
        public Response()
        {
            status = 'SUCCESS';
            httpStatusCode = '200' ;
        }
    }    
    
    global class Request
    {
        public String awb_number ; 
        public String latest_scan_time ; 
        public String live_status ; 
        public String status ; 
        public String remark ; 
        public String location ; 
        public String edd_date ; 
        public String key;
        
    }
    
    @HttpPost 
    global static Response getRequestData() 
    {
        RestRequest reqst = Restcontext.request;
        Response res = new Response();
        RestResponse restRes = RestContext.response;
        restRes.headers.put('Content-Type','application/json');
        restRes.headers.put('Access-Control-Allow-Origin','*');
        String headerKey = reqst.headers.get('token'); 
        String reqBody = reqst.requestBody.toString();
        try{         
            String result;           
            Request req = (Request)JSON.deserialize(reqBody,Request.class);
            
            Shopify_Data__c newShopifyData = new Shopify_Data__c();
            newShopifyData.Name = 'Ithink - '+req.awb_number;
            newShopifyData.Response_Data__c = reqBody;         
            
            if(headerKey == System.label.IthingAPIKey)
            {                                  
                List<Delivery_Track__c> deliveryTrackList = new List<Delivery_Track__c>(); 
                List<order__c> orderList = [SELECT Id,Order_Id__c,Name,Track_Id__c,Order_Delivery_Status__c  FROM order__c where Track_Id__c !=null and  Track_Id__c =: req.awb_number];
                if(!orderList.isEmpty())
                {
                    Delivery_Track__c createDeliveryTrack = new Delivery_Track__c();
                    if(String.isNotBlank(req.awb_number))
                    {
                        createDeliveryTrack.Name = req.awb_number;    
                    }                    
                    createDeliveryTrack.Order__c = orderList[0].Id;
                    if(String.isNotBlank(req.status))
                    {
                        createDeliveryTrack.Status__c = req.status;
                    }
                    if(String.isNotBlank(req.latest_scan_time))
                    {
                        createDeliveryTrack.Updated_Date__c = Datetime.valueOf(req.latest_scan_time);
                    }
                    if(String.isNotBlank(req.location))
                    {
                        createDeliveryTrack.Location__c = req.location;
                    }
                    //createDeliveryTrack.Expected_Delivery__c = '';
                    if(String.isNotBlank(req.remark))
                    {
                        createDeliveryTrack.Remark__c = req.remark;
                    }
                    Insert createDeliveryTrack;       
                    //String formattedDateTime = DateTime.now().format('yyyy-MM-dd hh:mm:ss');
                    for(order__c od: orderList)
                    {
                        if(od.Order_Delivery_Status__c!= req.status){
                            od.Last_Delivery_Status_Change_Date__c=DateTime.now();
                        }
                        od.Order_Delivery_Status__c = req.status;
                    }
                    
                    //Update orderList;
                    Database.SaveResult [] updateResult = Database.update(orderList, false);
                    for (Database.SaveResult r : updateResult)
                    {
                        if (r.isSuccess())
                        {
                            res.status ='Success';
                            //res.errorMessage = 'Order has Successfully been Updated'; 
                           System.debug('Order has Successfully been Updated');
                        }
                        else
                        {
                            for (Database.Error e : r.getErrors())
                            {
                                res.status ='Error';
                                res.errorMessage = 'Order not Updated';
                                newShopifyData.Error_Log__c = 'Error: '+e.getMessage();
                                result = e.getMessage() ;
                            }
                        }
                    }
                }   
                
            } 
            else{
                res.status ='Error';
                res.errorMessage = 'Invalid Key';
                newShopifyData.Error_Log__c = 'Error: Invalid key: '+headerKey;
            }
            Insert newShopifyData;
        }catch(Exception e){
            res.status = e.getMessage();
            res.errorMessage = 'INVALID_INPUT_FORMAT:';
            res.httpStatusCode = '400';
            Shopify_Data__c newShopifyData = new Shopify_Data__c();
            newShopifyData.Name = 'Ithink Error:';
            newShopifyData.Response_Data__c = reqBody;
            newShopifyData.Error_Log__c = 'Line No: '+e.getLineNumber()+' '+e.getMessage();
            Insert newShopifyData;
        }
        return res;
    }
}