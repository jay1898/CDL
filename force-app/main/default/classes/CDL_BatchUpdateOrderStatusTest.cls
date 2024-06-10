@isTest
private class CDL_BatchUpdateOrderStatusTest {
    
    static testMethod void testBatchUpdateOrderStatus() {
        
        Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = '77801128915';
        createOrder.Name = 'Test Order';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        insert createOrder;
        
        Delivery_Track__c createDeloveryTrack = new Delivery_Track__c();
        createDeloveryTrack.Name='4905212686946';
        createDeloveryTrack.Order__c=createOrder.Id;
        createDeloveryTrack.Status__c='IN-TRANSIT';
        createDeloveryTrack.Updated_Date__c = System.now();
        createDeloveryTrack.Location__c='test address';
        createDeloveryTrack.Expected_Delivery__c = System.today();
        createDeloveryTrack.Remark__c='Trip Arrived';
        Insert createDeloveryTrack;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        CDL_BatchUpdateOrderStatus batch = new CDL_BatchUpdateOrderStatus();
        Database.executeBatch(batch);
        Test.stopTest();
        
     
		CDL_BatchUpdateOrderStatus b = new CDL_BatchUpdateOrderStatus();
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(30);
        String cronExp = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        System.schedule('ShipDelight Update Order Status', cronExp, b );    
		
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