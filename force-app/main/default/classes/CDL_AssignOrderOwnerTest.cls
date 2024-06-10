@isTest
public class CDL_AssignOrderOwnerTest {
    @isTest
    static void testUpdateOrderOwner() {
        
        Account acc1 = new Account();
        acc1.Name = 'Test 31';
        acc1.AccountNumber = '7198697587006'; 
        acc1.Phone__c = '9898998989';
        acc1.BillingStreet = 'Test Add';
        acc1.ShippingStreet = 'Test Data';
        Insert acc1;
        
    	Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = '77801128915';
        createOrder.Name = 'Test Order';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder.Note__c = '';
        insert createOrder;
        
    	Order__c createOrder1 = new Order__c();
        createOrder1.Order_Id__c = '77801128917';
        createOrder1.Name = 'Test Order1';
        createOrder1.Track_Id__c = '77801128917';
        createOrder1.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder1.Note__c = '';
        insert createOrder1;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();

        List<Id> orderIdsToUpdate = new List<Id>();
        for (Order__c order : [SELECT Id FROM Order__c WHERE Id IN :new List<Order__c>{createOrder, createOrder1}]) {
            orderIdsToUpdate.add(order.Id);
        }
        
        List<Order__c> ordersToUpdate = [SELECT Id, OwnerId,Grand_Total__c FROM Order__c WHERE Id IN :orderIdsToUpdate];
		CDL_AssignOrderOwner.updateOrderOwner(ordersToUpdate);
        
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