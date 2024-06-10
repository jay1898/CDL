@isTest
public class CDL_OrderFollowupTriggerTest {
    
    static testMethod void orderCreateorUpdate() 
    {
        Account acc = new Account();
        acc.Name = 'Test 31';
        Insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'Test 31';
        Insert acc1;
        
        Order__c createOrder = new Order__c();
        createOrder.Order_Id__c = 'Test123';
        createOrder.Name = 'Test Order';
        createOrder.Status__c = 'Abandoned';
        createOrder.Track_Id__c = '77801128915';
        createOrder.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder.Account__c = acc.Id;
        insert createOrder;

        Order__c createOrder1 = new Order__c();
        createOrder1.Order_Id__c = 'Test1233';
        createOrder1.Name = 'Test Order3';
        createOrder1.Status__c = 'Abandoned';
        createOrder1.Track_Id__c = '778011289315';
        createOrder1.Order_Delivery_Status__c = 'IN_PROGRESS';
        createOrder1.Account__c = acc1.Id;
        createOrder1.Note__c = 'testttt';
        insert createOrder1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        User u = new User(Alias = 'standt32', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standardusercdlfineshine@testorg.com');
        insert u;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        
        Order_Follow_Up__c OrderFollow = new Order_Follow_Up__c();
        OrderFollow.Order__c = createOrder.Id;
        insert OrderFollow;
        
        Order_Follow_Up__c OrderFollow1 = new Order_Follow_Up__c();
        OrderFollow1.Order__c = createOrder1.Id;
        insert OrderFollow1;
        
        // Test Update
        Test.startTest();        
        OrderFollow.Comment__c = 'Test 3199';
        update OrderFollow;
        
        OrderFollow1.Comment__c = 'Test 3199rr';
        update OrderFollow1;
        Test.StopTest();
		
		Order__c orderupdate = [Select Id,Order_Id__c, Note__c FROM Order__c wHERE  Order_Id__c ='Test123'];
        Id userId =UserInfo.getUserId();
        User us  = [Select Id,Name From User Where Id =: userId ];
        //System.assertNotEquals('Comments: '+ OrderFollow.Comment__c +'\n'+'User: '+ us.Name +' '+'Time: '+DateTime.Now(), orderupdate.Note__c, 'Note__c field should be updated correctly');
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