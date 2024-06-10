@RestResource(urlMapping='/shopifyWebhookCancel/*')
global without sharing class CDL_ShopifyCancelOrdersWebhook {
    
    @HttpPost
    global static void receiveShopifyWebhook() {
        string data = '';
        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
        try
        {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            data = body.toString();
            createResponseRecord.Name = 'get details for Cancel Order ';
            createResponseRecord.Response_Data__c  = body.toString();
            system.debug(JSON.serializePretty(body.toString()));
            orderDetailsWrapper orderDetailsWrapper = (orderDetailsWrapper)System.JSON.deserialize(body.toString(), orderDetailsWrapper.class);
            if(orderDetailsWrapper != null){
                if(orderDetailsWrapper.id != null){
                    
                    createResponseRecord.Name = 'Cancel Order '+ orderDetailsWrapper.order_number;
                    
                    Order__c objo = new Order__c();
                    Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Voided').getRecordTypeId();
                    List<Order__c> exist = [Select Id,Fulfillment_Status__c,Order_Cancel_Date__c, Cancel_Reason__c,Order_Id__c, Track_Id__c,Tracking_URL__c,Tracking_Company__c,Shipment_Status__c,Payment_Status__c from Order__c Where Order_Id__c =: orderDetailsWrapper.id limit 1];
                    if(exist.size()>0){
                        objo = exist[0];
                        //objo.Status__c = orderDetailsWrapper.financial_status;
                        objo.RecordTypeId = recordTypeId;
                        objo.Status__c = 'voided';
                        objo.Payment_Status__c = orderDetailsWrapper.financial_status;
                        objo.Cancel_Reason__c = orderDetailsWrapper.cancel_reason;
                        objo.Order_Cancel_Date__c = date.valueOf(orderDetailsWrapper.cancelled_at);
                        update objo;
                        moveToCancelTrelloCard(objo.Order_Id__c);
                    }
                    
                }
            }
            Insert createResponseRecord;
        }
        catch(Exception ex)
        {
            createResponseRecord.Name = 'Cancel Order fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage();
            Insert createResponseRecord;
        }
    }
    @future(callout=true)
    public static void moveToCancelTrelloCard(String orderId) {
        List<Shopify_Data__c>  createResponseRecordlst = new List<Shopify_Data__c>();
        try{
            Order__c objo = new Order__c();
            List<Order__c> exist = [Select Id,Name,Trello_Card_Id__c,Status__c,Payment_Status__c from Order__c Where Order_Id__c =: orderId limit 1];
            if(exist.size()>0){
                objo = exist[0];
            }
            if(objo != null && objo.Status__c == 'voided'){
                String Key = system.Label.Trelllo_Key;
                string Token = System.Label.Trello_Token;
                
                //String endpointUrl = 'https://api.trello.com/1/cards?idList='+System.Label.Trello_Card_List_Id+'&name='+objo.Name+'&desc='+productList+'&key='+Key+'&token='+Token;//Board Id OsQICQy5
                List<Order_Item__c> prolst = [select id,Trello_Card_ID__c from Order_Item__c where Order__c =: objo.Id ];
                if(prolst.size()>0){
                    for(Order_Item__c p : prolst){
                        if(p.Trello_Card_ID__c != null && p.Trello_Card_ID__c != ''){
                            String endpointUrl = 'https://api.trello.com/1/cards/' +p.Trello_Card_ID__c+
                                //'?idList=' + '645ce773ea3d4e031cd7c80f' +
                                //'&name=' + EncodingUtil.urlEncode('#'+objo.Name, 'UTF-8') +
                                //'&desc=' + EncodingUtil.urlEncode(productList, 'UTF-8') +
                                '?key=' + Key +
                                '&token=' + Token;
                            system.debug('endpointUrl: '+endpointUrl);
                            Http h = new Http();
                            HttpRequest req = new HttpRequest();
                            req.setEndpoint(endpointUrl);
                            req.setHeader('Content-Type', 'application/json');
                            req.setMethod('PUT');
                            req.setBody('{"idList": "64a8de1b385d6773f0985239"}');
                            HttpResponse res = h.send(req);
                            System.debug('response data: '+res.getBody());
                            System.debug('res status code '+res.getStatusCode());
                            Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
                            createResponseRecord.Name = 'move Trello Card '+ OrderId;
                            createResponseRecord.Response_Data__c  = res.getBody();
                            createResponseRecord.Status__c = string.valueOf(res.getStatusCode());
                            createResponseRecordlst.add(createResponseRecord);
                        }
                        else{
                            Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
                            createResponseRecord.Name = 'move Trello Card Fail not match';
                            createResponseRecord.Error_Log__c  = 'not updated Payment_Status__c'+objo.Payment_Status__c+ ' Trello_Card_Id__c'+objo.Trello_Card_Id__c;//'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
                            createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
                            createResponseRecordlst.add(createResponseRecord);
                        }
                    }
                }
                Insert createResponseRecordlst;
            }
            else{
                Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
                createResponseRecord.Name = 'move Trello Card Fail not match';
                createResponseRecord.Error_Log__c  = 'not updated Payment_Status__c'+objo.Payment_Status__c+ ' Trello_Card_Id__c'+objo.Trello_Card_Id__c;//'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
                createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
                Insert createResponseRecord;
            }
        }
        catch(Exception ex){
            Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
            createResponseRecord.Name = 'move Trello Card Fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage(); 
            createResponseRecord.Status__c = ''; //string.valueOf(res.getStatusCode());
            Insert createResponseRecord;
        }
    }
    public class orderDetailsWrapper{
        public string id {get;set;} 
        public String financial_status {get;set;} 
        public string order_number {get;set;} 
        public String cancel_reason {get;set;} 
        public String cancelled_at {get;set;} 
        
        
    }
    
    
}