@isTest
public class CDL_OrderNotesTest 
{

    static testMethod void orderNotes() 
    {
    	Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = '77801128915';
        createOrder.Name = 'Test Order';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder.Note__c = '';
        insert createOrder;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
        Order__c updateOrder = [Select Id,Note__c from Order__c where Id =: createOrder.Id limit 1];  //Id =: createOrder.Id
        updateOrder.Note__c = 'Hello test Message';
        Update updateOrder; 
        CDL_OrderNotes.getOrderNotes(createOrder.Id);
        CDL_OrderNotes.addNotes(createOrder.Id, 'Test');
        CDL_OrderNotes.AttachmentList(createOrder.Id);
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            String jsonData = '{"data":{"success":true,"error":false,"response":[{"awbno":"77801128915","orderno":"2726","ordertype":"FORWARD","shipment_latest_status_code":"753","shipment_latest_status":"DELIVERED","edd":"2023-09-23","scan_detail":[{"awbno":"77801128915","orderno":"2726","status":"PENDING PICKUP","status_code":"454","updated_date":"2023-09-18 12:52:00","location":"SURAT","exp_delivery":"2023-09-23","reason_code":"PENDING PICKUP","remarks":"Online shipment booked"}]}]}}';
            res.setBody(jsonData);
            res.setStatusCode(200);
            return res;
        }
    }
}