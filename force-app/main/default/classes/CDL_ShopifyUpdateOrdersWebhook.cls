@RestResource(urlMapping='/shopifyWebhookUpdate/*')
global without sharing class CDL_ShopifyUpdateOrdersWebhook {
    
    @HttpPost
    global static void receiveShopifyWebhook() {
        string data = '';
        Shopify_Data__c  createResponseRecord = new Shopify_Data__c();
        try
        {
            RestRequest req = RestContext.request;
            Blob body = req.requestBody;
            system.debug(JSON.serializePretty(body.toString()));
            data = body.toString();
            createResponseRecord.Response_Data__c  = body.toString();
            createResponseRecord.Name = 'get details for Update Order';
            orderDetailsWrapper orderDetailsWrapper = (orderDetailsWrapper)System.JSON.deserialize(body.toString(), orderDetailsWrapper.class);
            if(orderDetailsWrapper != null){
                if(orderDetailsWrapper.id != null){
                    createResponseRecord.Name = 'Update Order '+ orderDetailsWrapper.order_number;
                    Order__c objo = new Order__c();
                    List<Order__c> exist = [Select Id,Fulfillment_Status__c, Track_Id__c,Tracking_URL__c,Tracking_Company__c,Shipment_Status__c,Payment_Status__c from Order__c Where Order_Id__c =: orderDetailsWrapper.id limit 1];
                    if(exist.size()>0){
                        objo = exist[0];
                        objo.Fulfillment_Status__c =  orderDetailsWrapper.fulfillment_status;
						//objo.Status__c = orderDetailsWrapper.financial_status;
						objo.Payment_Status__c = orderDetailsWrapper.financial_status;
                        objo.Note__c = orderDetailsWrapper.note;
                        List<Fulfillments> lstline = new List<Fulfillments>();
                        if(orderDetailsWrapper.fulfillments != null){
                            if(orderDetailsWrapper.fulfillments.size()>0){
                                objo.Track_Id__c =  orderDetailsWrapper.fulfillments[0].tracking_number;
                                objo.Tracking_URL__c =  orderDetailsWrapper.fulfillments[0].tracking_url;
                                objo.Tracking_Company__c =  orderDetailsWrapper.fulfillments[0].tracking_company;
                                objo.Shipment_Status__c =  orderDetailsWrapper.fulfillments[0].shipment_status;
                            }
                        }
                        update objo;
                    }
                }
            }
            Insert createResponseRecord;
        }
        catch(Exception ex)
        {
            createResponseRecord.Name = 'Update Order fail';
            createResponseRecord.Error_Log__c  = 'Line No: '+ex.getLineNumber()+' '+ ex.getMessage();
            Insert createResponseRecord;
        }
    }
    
    public class orderDetailsWrapper{
        public string id {get;set;} 
        public String financial_status {get;set;} 
        public string fulfillment_status {get;set;}  
        public string note {get;set;} 
        public string order_number {get;set;} 
        public List<Fulfillments> fulfillments {get;set;} 
    }
    public class Fulfillments {
		public String shipment_status {get;set;} 
		public String tracking_company {get;set;} 
		public String tracking_number {get;set;} 
		public String tracking_url {get;set;} 
    }
    
}