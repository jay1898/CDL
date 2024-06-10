public class CDL_OrderTriggerHandler {
    
    public static void beforeInsert(List<Order__c> orderList)
    {
     	String setOwnerId;
        Map<String,Object> outputMap = (Map<String,Object>) JSON.deserializeUntyped(CDL_AssignOrderOwner.setSobjectOwner('Order__c'));
        Map<Id,User> availableUserId = (Map<Id,User>) JSON.deserialize(Json.Serialize(outputMap.get('availableUserId')),Map<Id,User>.class);
        Map<String,Object> ownerIdCount = (Map<String,Object>) outputMap.get('ownerIdCount');
        
        for(Order__c currentOrder : orderList)
        {
            setOwnerId = CDL_AssignOrderOwner.selectOwnerId(availableUserId,ownerIdCount,currentOrder.Grand_Total__c);
            if(String.isNotBlank(setOwnerId)){               
                currentOrder.OwnerId = setOwnerId;
                Integer recordCount = Integer.valueOf(ownerIdCount.get(setOwnerId)) + 1;
                ownerIdCount.put(setOwnerId,recordCount);
            }
        }  
    }
    
    public static void afterUpdate(List<Order__c> orderList, Map<Id,Order__c> oldMap, Map<Id,User> userDetails)
    {
        for(Order__c currentOrder : orderList)
        {
            if(currentOrder.Status__c != oldMap.get(currentOrder.Id).Status__c)
            {
                String body = 'Hello '+userDetails.get(currentOrder.OwnerId).Name+','+
                    '\\n Order Status has been updated in your bucket\\n\\n Order No: '+currentOrder.Name+
                    '\\n Order Status changed from '+oldMap.get(currentOrder.Id).Status__c+' To '+currentOrder.Status__c;
                
                CDL_Notification.notifyUsers(new Set<String>{currentOrder.OwnerId},currentOrder.Id,'Updated Order Status',body);
            }
            if((currentOrder.Order_Delivery_Status__c != oldMap.get(currentOrder.Id).Order_Delivery_Status__c) &&
               (currentOrder.Order_Delivery_Status__c == 'NDR' || currentOrder.Order_Delivery_Status__c == 'Out for Delivery'))
            {
                String body = 'Hello '+userDetails.get(currentOrder.OwnerId).Name+','+
                    '\\n Order Delivery Status has been updated in your bucket\\n\\n Order No: '+currentOrder.Name+
                    '\\n Order Delivery Status changed from '+oldMap.get(currentOrder.Id).Order_Delivery_Status__c+' To '+currentOrder.Order_Delivery_Status__c;
                
                CDL_Notification.notifyUsers(new Set<String>{currentOrder.OwnerId},currentOrder.Id,'Updated Order Delivery Status',body);
            }
            
        }
         
        //Create FollowUp Records
        //createFollowUpRecords(orderList,oldMap);    
        
        updateOrderNote(orderList,oldMap);
        updateAbandonToConfirmOrderNote(orderList,oldMap);
    }     
    
    public static void afterInsert(List<Order__c> orderList, Map<Id,User> userDetails)
    {
        
        List<newOrderPopup__e> eventsToPublish = new List<newOrderPopup__e>();
        for(Order__c currentOrder: orderList)
        {
            newOrderPopup__e myEvent = new newOrderPopup__e();
            myEvent.userId__c = currentOrder.OwnerId;
            eventsToPublish.add(myEvent);   
            String body = 'Hello '+userDetails.get(currentOrder.OwnerId).Name+','+
                '\\n New order has been created in your bucket\\n\\n Order No: '+currentOrder.Name+
                '\\n Order Status: '+currentOrder.Status__c;
            
            CDL_Notification.notifyUsers(new Set<String>{currentOrder.OwnerId},currentOrder.Id,'new Order',body);          
        }    
        EventBus.publish(eventsToPublish);      
        
    }
    
    
    public static void updateOrderNote(List<Order__c> orderList, Map<Id,Order__c> oldMap) {
        for(Order__c newOrder :orderList){
            Order__c oldOrder = (Order__c)oldMap.get(newOrder.Id); 
            System.debug('newOrder.Id: '+newOrder.Id);
            System.debug('newOrder.Note__c: '+newOrder.Note__c);
            if(oldOrder.Note__c != newOrder.Note__c && newOrder.Note__c != null)
            {
                List<String> lines = newOrder.Note__c.split('\n');
                String concatenatedNote = '';
                for (String line : lines) 
                {                   
                    line = line.trim();                    
                    concatenatedNote += line + '\\n';
                }
                System.debug('Concatenated Note: ' + concatenatedNote);
                System.debug('order Id'+newOrder.Order_Id__c);
                calloutUpdateOrderNoteAsync(newOrder.Order_Id__c, concatenatedNote);
                
            }
        }    
    }
    
    public static void updateAbandonToConfirmOrderNote(List<Order__c> orderList, Map<Id,Order__c> oldMap) {
        for(Order__c newOrder :orderList){
            Order__c oldOrder = (Order__c)oldMap.get(newOrder.Id); 
            System.debug('newOrder.Id: '+newOrder.Id);
            System.debug('newOrder.Note__c: '+newOrder.Note__c);
            if(oldOrder.Status__c != newOrder.Status__c && newOrder.Status__c == 'Confirm')
            {
                //newOrder.Order_Delivery_Status__c = 'Manifest';
                if(!newOrder.IsAbandontoConfirm__c){
                    calloutCreateOrderforAbandonOrderAsync(newOrder.Order_Id__c);
                }
            }
            if(oldOrder.Status__c != newOrder.Status__c && newOrder.Status__c == 'voided')
            {
                //newOrder.Order_Delivery_Status__c = 'voided';
                calloutCancelOrderNoteAsync(newOrder.Order_Id__c);
            }
        }    
    }
    
    @future(callout=true)
    public static void calloutUpdateOrderNoteAsync(string OrderId, String Note) {
        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
        try{
            string body = '{"order": {"id": '+OrderId+',"note": "'+Note+'"}}';
            String endpointUrl = Label.Shopify_Store_URL+'/admin/api/2023-07/orders/'+OrderId+'.json';//'https://hatton-garden.myshopify.com
            //String endthropointUrl = 'https://testsfstoredata.myshopify.com/admin/api/2023-07/orders/'+OrderId+'.json';
            system.debug('endpointUrl: '+endpointUrl);
            system.debug('body: '+body);
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
            req.setMethod('PUT');
            req.setBody(body);
            
            HttpResponse res = h.send(req);
            createResponseRecord.Name = 'Update Note '+ OrderId;
            createResponseRecord.Response_Data__c  = res.getBody();
            createResponseRecord.Status__c = string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
            System.debug('response data: '+res.getBody());
            System.debug('res status code '+res.getStatusCode());
            
        }
        catch(Exception ex){
            createResponseRecord.Name = 'Update Note Fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
            createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
            throw ex;
        }
        
    }
    
    Public class OrderWrapper {
        public OrderData order;
    }
    public class OrderData {
        public CustomerData customer;
        public String financial_status;
        public String source_identifier;
        public String source_name;
        public String phone;
        public address billing_address;
        public address shipping_address;
        public List<Line_items> line_items;
    }
    public class CustomerData {
        public decimal id;
        public String phone; 
    }
    
    public class Line_items {
        public decimal variant_id;
    }
    
    public class address {
        public String address1;
        public String city;
        public String zip;
        public String province;
        public String country;
        public String phone;
        public string first_name;
        public string last_name;
    }
    @future(callout=true)
    public static void calloutCreateOrderforAbandonOrderAsync(string OrderId) {
        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
        try{
            Order__c objo = new Order__c();
            List<Order__c> exist = [Select Id,Order_Id__c, Account__r.Name,Account__r.AccountNumber,Account__r.Phone__c,Billing_City__c,Billing_PostalCode__c,Billing_Country__c,
                                    Billing_State__c,Billing_Street__c,shipping_City__c, shipping_Country__c, shipping_PostalCode__c, shipping_State__c,
                                    shipping_Street__c
                                    from Order__c Where Order_Id__c =: orderId limit 1];
            system.debug('exist------->'+exist);
            if(exist.size()>0){
                objo = exist[0];
                List<Order_Item__c> lstlineitem= [Select Id,Product_Variant_Id__c from Order_Item__c where Order__c =: objo.Id];
                String firstName;
                String lastName;
                String fullName = objo.Account__r.Name;
				  System.debug('fullName ' + fullName);
                if (fullName != null && fullName.contains(' ')) {
                    List<String> nameParts = fullName.split(' ');
                    firstName = nameParts[0]; // First name
                    lastName = nameParts.size() > 1 ? nameParts[1] : ''; // Last name        
                    System.debug('First Name: ' + firstName);
                    System.debug('Last Name: ' + lastName);
                }
                
                
                OrderWrapper objOrderDetail = new OrderWrapper();
                OrderData objOrderW = new OrderData();
                address objBAddr = new address();
                objBAddr.city = objo.Billing_City__c ;
                objBAddr.zip = objo.Billing_PostalCode__c ;
                objBAddr.country = objo.Billing_Country__c ;
                objBAddr.province = objo.Billing_State__c ;
                objBAddr.address1 = objo.Billing_Street__c ;
                objBAddr.phone = objo.Account__r.Phone__c;
                objBAddr.first_name = firstName;
                objBAddr.last_name = lastName;
                system.debug('objBAddr------->'+objBAddr);
                
                address objAddr = new address(); 
                objAddr.city = objo.shipping_City__c ;
                objAddr.country = objo.shipping_Country__c ;
                objAddr.zip = objo.shipping_PostalCode__c;
                objAddr.province = objo.shipping_State__c;
                objAddr.address1 = objo.shipping_Street__c;
                objAddr.phone = objo.Account__r.Phone__c;
                objAddr.first_name = firstName;
                objAddr.last_name = lastName;
                system.debug('objAddr------->'+objAddr);
                
                CustomerData objCus = new CustomerData();
                if(objo.Account__r.AccountNumber != null){
                    objCus.id = Decimal.valueOf(objo.Account__r.AccountNumber);
                }
                
                if(objo.Account__r.Phone__c != null){
                    objCus.phone = objo.Account__r.Phone__c;
                }
                //Address Changes
                if(objAddr.address1 != null){
                    objOrderW.shipping_address =  objAddr;
                }
                
                if(objBAddr.address1 != null){
                    objOrderW.billing_address = objBAddr;
                }
                else{
                    objOrderW.billing_address = objAddr;
                }
                
                objOrderW.source_identifier = 'SF Abandon Order';
                objOrderW.financial_status = 'pending';
                objOrderW.customer = objCus;
                objOrderW.source_name = objo.Id;
				objOrderW.phone = objo.Account__r.Phone__c;
                
                if(lstlineitem.size()>0){
                    List<Line_items> lstLines = new List<Line_items>();
                    for(Order_Item__c ol : lstlineitem){
                        if(ol.Product_Variant_Id__c != null){
                            Line_items objline = new Line_items();
                            objline.variant_id = Decimal.valueOf(ol.Product_Variant_Id__c);
                            lstLines.add(objline);
                        }
                    }
                    objOrderW.line_items = lstLines;
                }
                objOrderDetail.order = objOrderW;
                
                
                String body = JSON.serialize(objOrderDetail);
                //string body = '{"order": {"id": '+OrderId+',"note": "'+Note+'"}}';
                String endpointUrl = Label.Shopify_Store_URL+'/admin/api/2023-10/orders.json';//'https://hatton-garden.myshopify.com
                //String endpointUrl = 'https://testsfstoredata.myshopify.com/admin/api/2023-10/orders.json';
                system.debug('endpointUrl: '+endpointUrl);
                system.debug('objOrderDetail: '+objOrderDetail);
                system.debug('body: '+body);
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpointUrl);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
                req.setMethod('POST');
                req.setBody(body);
                System.debug('response data: '+req.getBody());
                HttpResponse res = h.send(req);
                
                createResponseRecord.Name = 'Create Confirm Order for Abandon Order '+ OrderId;
                createResponseRecord.Response_Data__c  = res.getBody();
                createResponseRecord.Status__c = string.valueOf(res.getStatusCode());
                Insert createResponseRecord;
                System.debug('response data: '+res.getBody());
                System.debug('res status code '+res.getStatusCode());
            }
        }
        catch(Exception ex){
            createResponseRecord.Name = 'Create Confirm Order for Abandon Order FAIL';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
            createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
            throw ex;
        }
        
    }
    
    @future(callout=true)
    public static void calloutCancelOrderNoteAsync(string OrderId) {
        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
        try{
            String endpointUrl = Label.Shopify_Store_URL+'/admin/api/2023-07/orders/'+OrderId+'/cancel.json';//'https://hatton-garden.myshopify.com
            //String endthropointUrl = 'https://testsfstoredata.myshopify.com/admin/api/2023-07/orders/'+OrderId+'.json';
            system.debug('endpointUrl: '+endpointUrl);
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('X-Shopify-Access-Token', System.Label.Shopify_Secret);
            req.setMethod('POST');
            HttpResponse res = h.send(req);
            
            createResponseRecord.Name = 'Cancel Order From SF '+ OrderId;
            createResponseRecord.Response_Data__c  = res.getBody();
            createResponseRecord.Status__c = string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
            System.debug('response data: '+res.getBody());
            System.debug('res status code '+res.getStatusCode());
            
        }
        catch(Exception ex){
            createResponseRecord.Name = 'Cancel Order From SF Fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
            createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
            throw ex;
        }
        
    }
}