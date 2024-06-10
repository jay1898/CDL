@isTest
public class CDL_OrderTriggerHandlerTest {

    static testMethod void orderCreateorUpdate() 
    {
        Account acc1 = new Account();
        acc1.Name = 'Test 31';
        acc1.AccountNumber = '7198697587006'; 
        acc1.Phone__c = '9898998989';
        acc1.BillingStreet = 'Test Add';
        acc1.ShippingStreet = 'Test Data';
        Insert acc1;
        
		Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = '77801128915';
        createOrder.Account__c = acc1.Id;
        createOrder.Name = 'Test Order';
        createOrder.Status__c = 'Abandoned';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder.Note__c = '';
        insert createOrder;
        
        Order__c createOrder2 = new Order__c();
        createOrder2.Order_Id__c = '77801128911';
        createOrder.Account__c = acc1.Id;
        createOrder2.Name = 'confirm Order';
        createOrder2.Status__c = 'Abandoned';
        createOrder2.Track_Id__c = '77801128911';
        createOrder2.Order_Delivery_Status__c = 'Manifest';
        createOrder2.Note__c = '';
        insert createOrder2;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Order__c updateOrder = [Select Id,Note__c,Status__c,Order_Id__c from Order__c where Order_Id__c = '77801128915' limit 1];
        updateOrder.Status__c = 'voided';
        updateOrder.Order_Delivery_Status__c = 'NDR';
        updateOrder.Note__c = 'Hello test Message';
        Update updateOrder;
        
        Order__c updateOrder2 = [Select Id,Note__c,Status__c,Order_Id__c from Order__c where Order_Id__c = '77801128911' limit 1];
        updateOrder2.Status__c = 'Confirm';
        //updateOrder.IsAbandontoConfirm__c = true;
        Update updateOrder2;
        
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) 
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            String jsonData = '{"data":{"success":true,"error":false,"response":[{"awbno":"77801128915","orderno":"2726","ordertype":"FORWARD","shipment_latest_status_code":"753","shipment_latest_status":"DELIVERED","edd":"2023-09-23","scan_detail":[{"awbno":"77801128915","orderno":"2726","status":"PENDING PICKUP","status_code":"454","updated_date":"2023-09-18 12:52:00","location":"SURAT","exp_delivery":"2023-09-23","reason_code":"PENDING PICKUP","remarks":"Online shipment booked"}]}]}}';
            res.setBody(jsonData);
            res.setStatusCode(200);
            return res;
        }
    }
}