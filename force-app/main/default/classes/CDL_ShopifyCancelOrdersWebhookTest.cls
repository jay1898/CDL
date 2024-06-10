@isTest
public class CDL_ShopifyCancelOrdersWebhookTest {
    
    @isTest
    public static void testReceiveShopifyWebhook() {
        Test.setMock(HttpCalloutMock.class, new MyHttpCalloutMock());
        Account a = new Account();
        a.Name = 'test test';
        a.AccountNumber = '6353252483127';
        a.AccountSource = 'Other';
        insert a;
        Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Confirm Order').getRecordTypeId();
        Order__c objo = new Order__c();
        objo.Account__c = a.Id;
        objo.Name = '2844';
        objo.Order_Id__c = '5390802518071';
        objo.RecordTypeId = recordTypeId;
        objo.Status__c = 'Confirm';
        objo.Payment_Status__c = 'Paid';
        insert objo;
        
        Order_Item__c objline = new Order_Item__c();
        objline.Order_Item_ID__c = '3423423423';
        objline.Order__c = objo.Id;
        objline.Quantity__c = 1;
        objline.Trello_Card_ID__c = '153654654622';
        insert objline;
        // Create test data for the RestRequest
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/shopifyWebhookCancel/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"id":"5390802518071", "financial_status":"voided", "cancel_reason":"Testing", "cancelled_at":"2023-01-01T00:00:00Z"}');
        
        // Call the receiveShopifyWebhook method
        Test.startTest();
        CDL_ShopifyCancelOrdersWebhook.receiveShopifyWebhook();
        CDL_ShopifyCancelOrdersWebhook.moveToCancelTrelloCard(objo.Id);
        Test.stopTest();
        
        // Assert the expected results
        List<Shopify_Data__c> responseRecords = [SELECT Name, Response_Data__c FROM Shopify_Data__c WHERE Name = 'Cancel Order 2844'];
       //System.assertNotEquals(0, responseRecords.size());
        
        // Add more assertions as needed
    }
    @isTest
    public static void testReceiveShopifyWebhookFail() {
        
        // Create test data for the RestRequest
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/shopifyWebhookCancel/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"id":"539080251807123", "financial_statuss":"voidesd", "cancel_reason":"Testing", "cancelled_at":"2023-01-01T00:00:00Z"}');
        
        // Call the receiveShopifyWebhook method
        Test.startTest();
        try{
        	CDL_ShopifyCancelOrdersWebhook.receiveShopifyWebhook();
        }
        catch(Exception ex){
            
        }
        Test.stopTest();
        
        // Assert the expected results
        List<Shopify_Data__c> responseRecords = [SELECT Name, Response_Data__c FROM Shopify_Data__c WHERE Name = 'Cancel Order 2844'];
        
    }
    @isTest
    public static void moveToCancelTrelloCardFail() {
        
        Account a = new Account();
        a.Name = 'test test';
        a.AccountNumber = '6353252483127';
        a.AccountSource = 'Other';
        insert a;
        Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Confirm Order').getRecordTypeId();
        Order__c objo = new Order__c();
        objo.Account__c = a.Id;
        objo.Name = '2844';
        objo.Order_Id__c = '5390802518071';
        objo.RecordTypeId = recordTypeId;
        objo.Status__c = 'Confirm';
        objo.Payment_Status__c = 'Paid';
        insert objo;
        // Create test data for the RestRequest
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/shopifyWebhookCancel/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        
        // Call the receiveShopifyWebhook method
        Test.startTest();
        CDL_ShopifyCancelOrdersWebhook.moveToCancelTrelloCard(objo.Id);
        Test.stopTest();
        
        // Assert the expected results
        List<Shopify_Data__c> responseRecords = [SELECT Name, Response_Data__c FROM Shopify_Data__c WHERE Name = 'Cancel Order 2844'];
        
    }
    @isTest
    public static void moveToCancelTrelloCardFail2() {
        
        Account a = new Account();
        a.Name = 'test test';
        a.AccountNumber = '6353252483127';
        a.AccountSource = 'Other';
        insert a;
        Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Confirm Order').getRecordTypeId();
        Order__c objo = new Order__c();
        objo.Account__c = a.Id;
        objo.Name = '2844';
        objo.Order_Id__c = '5390802518071';
        objo.RecordTypeId = recordTypeId;
        objo.Status__c = 'Confirm';
        objo.Payment_Status__c = 'Paid';
        insert objo;
        // Create test data for the RestRequest
        RestRequest req = new RestRequest();
        RestContext.request = req;
        req.requestURI = '/services/apexrest/shopifyWebhookCancel/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('');
        
        // Call the receiveShopifyWebhook method
        Test.startTest();
        CDL_ShopifyCancelOrdersWebhook.receiveShopifyWebhook();
        CDL_ShopifyCancelOrdersWebhook.moveToCancelTrelloCard('wew33434');
        Test.stopTest();
        
        // Assert the expected results
        List<Shopify_Data__c> responseRecords = [SELECT Name, Response_Data__c FROM Shopify_Data__c WHERE Name = 'Cancel Order 2844'];
        
    }
    public class MyHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTPResponse to simulate the response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"key": "value"}');
            res.setStatusCode(200);
            return res;
        }
    }
   
}