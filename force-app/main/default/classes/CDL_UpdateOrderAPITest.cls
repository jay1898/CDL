@isTest
public class CDL_UpdateOrderAPITest 
{
    static testMethod void updateOrderDeliveryStatus()
    {
        Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = '77801128915';
        createOrder.Name = 'Test Order';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder.Note__c = '';
        insert createOrder;
        
      	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.addHeader('token',System.label.IthingAPIKey);
        req.requestUri = '/services/apexrest/OrderStatus/';       
        String postData = '{"awb_number":"77801128915","latest_scan_time":"2022-04-04 15:20:25","live_status":"2","status":"picked up","remark":"picked up","location":"mumbai","edd_date":"2022-04-10 15:20:25"}';

        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        CDL_UpdateOrderAPI.getRequestData();
        Test.stopTest();
        
        postData = '[{"awb_num":"77801128915","latest_scan_time":"2022-04-04 15:20:25","live_status":"2","status":"picked up","remark":"picked up","location":"mumbai","edd_date":"2022-04-10 15:20:25"}]';

        req.requestBody = Blob.valueof(postData);
        RestContext.request = req; 
        RestContext.response= res;
        
        CDL_UpdateOrderAPI.getRequestData();
       
        
        
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