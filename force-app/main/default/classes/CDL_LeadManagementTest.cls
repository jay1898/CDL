@isTest
public class CDL_LeadManagementTest {
    
    @isTest
    static void testGetOrderLit() {
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
        CDL_LeadManagement.getOrderLit('ALL','90');
        CDL_LeadManagement.getnewOrderList(null);
        
        
        Order__c objo1 = new Order__c();
        objo1.Account__c = a.Id;
        objo1.Name = '28445';
        objo1.Order_Id__c = '5390802518072';
        objo1.RecordTypeId = recordTypeId;
        objo1.Status__c = 'Confirm';
        objo1.Payment_Status__c = 'Paid';
        objo1.Order_Delivery_Status__c = 'RTO';
        insert objo1;

        CDL_LeadManagement.getnewOrderList(null);
        CDL_LeadManagement.getnewOrderList(objo1.id);
    }

    @isTest
    static void testVerifiedOrder() {
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
        string data = '{"Id":"'+objo.Id+'","CreatedDate":"2023-12-05T10:01:06.000+0000","Name":"2935","Status__c":"Confirm","Payment_Status__c":"pending","isVerified__c":false,"Total_Price__c":1449,"Grand_Total__c":1449,"Order_Amount__c":1499,"Account__c":"0017E00001WEBkHQAX","Billing_Street__c":"D/004,MAHIMA DESIRE,JAISINGHPURA,BHANKROTA,AJMER ROAD","Billing_City__c":"JAIPUR","Billing_State__c":"Rajasthan","Billing_PostalCode__c":"302029","Billing_Country__c":"India","Shipping_Street__c":"D/004,MAHIMA DESIRE,JAISINGHPURA,BHANKROTA,AJMER ROAD","Shipping_City__c":"JAIPUR","Shipping_State__c":"Rajasthan","Shipping_PostalCode__c":"302029","Shipping_Country__c":"India","Account__r":{"attributes":{"type":"Account","url":"/services/data/v59.0/sobjects/Account/0017E00001WEBkHQAX"},"Name":"Mona Kalia","Phone__c":"9571199846","Id":"0017E00001WEBkHQAX"}}';
        CDL_LeadManagement.verifiedOrder(data);
        CDL_LeadManagement.updateOrderDetails(data);
    }

    @isTest
    static void testOrderItemList() {
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
        CDL_LeadManagement.orderItemList(objo.Id);
    }

    @isTest
    static void testFollowupItemsList() {
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
        Order_Follow_Up__c obj = new Order_Follow_Up__c();
        obj.Order__c = objo.Id;
        obj.Expected_Follow_Up_Time__c = system.Datetime.now();
        obj.Follow_Up_Order__c = 1;
        obj.Status__c = 'Pending';
        insert obj;
        CDL_LeadManagement.followupItemsList(objo.Id);
    }

    @isTest
    static void testLatestfollowupItem() {
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
        Order_Follow_Up__c obj = new Order_Follow_Up__c();
        obj.Order__c = objo.Id;
        obj.Expected_Follow_Up_Time__c = system.Datetime.now();
        obj.Follow_Up_Order__c = 1;
        obj.Status__c = 'Pending';
        insert obj;
        CDL_LeadManagement.latestfollowupItem(objo.Id);
    }

    @isTest
    static void testUpdateFollowUp() {
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
        objo.Order_Delivery_Status__c = 'Confirmed';
        insert objo;
        Order_Item__c objline = new Order_Item__c();
        objline.Order_Item_ID__c = '3423423423';
        objline.Order__c = objo.Id;
        objline.Quantity__c = 1;
        objline.Trello_Card_ID__c = '153654654622';
        insert objline;
        Order_Follow_Up__c obj = new Order_Follow_Up__c();
        obj.Order__c = objo.Id;
        obj.Expected_Follow_Up_Time__c = system.Datetime.now();
        obj.Follow_Up_Order__c = 1;
        obj.Status__c = 'Pending';
        insert obj;
        string data = '{"Id":"'+obj.Id+'","Order__c":"'+obj.Order__c+'","Expected_Follow_Up_Time__c":"2023-12-05T15:29:32.000+0000","Status__c":"Missed","Follow_Up_Order__c":1,"Actual_Follow_Up_Time__c":"2023-12-06T15:29:32.000+0000","Comment__c":"test"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CDL_LeadManagement.UpdateFollowUp(data); 
        CDL_LeadManagement.UpdateFollowUpIsVerified(data,'2024-03-07T04:00:00.000+0000',false);
        CDL_LeadManagement.UpdateFollowUpIsVerified(data,'2024-03-07T04:00:00.000+0000',true);
    }

    @isTest
    static void testGetAllfollowupByStatus() {
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
        objo.Order_Delivery_Status__c = 'Confirmed';
        insert objo;
        Order_Item__c objline = new Order_Item__c();
        objline.Order_Item_ID__c = '3423423423';
        objline.Order__c = objo.Id;
        objline.Quantity__c = 1;
        objline.Trello_Card_ID__c = '153654654622';
        insert objline;
        Order_Follow_Up__c obj = new Order_Follow_Up__c();
        obj.Order__c = objo.Id;
        obj.Expected_Follow_Up_Time__c = system.Datetime.now();
        obj.Follow_Up_Order__c = 1;
        obj.Status__c = 'Pending';
        insert obj;
        CDL_LeadManagement.getAllfollowupByStatus('Confirmed');  
    }
    
   	@isTest
    static void testVoidOrder() {
		Account a = new Account();
        a.Name = 'test test';
        a.AccountNumber = '6353252483127';
        a.AccountSource = 'Other';
        insert a;
        Order__c objo = new Order__c();
        objo.Account__c = a.Id;
        objo.Name = '2844';
        objo.Order_Id__c = '5390802518071';
        objo.Status__c = 'Confirm';
        objo.Payment_Status__c = 'Paid';
        objo.Order_Delivery_Status__c = 'Confirmed';
        objo.FollowUp_Stage__c = 'Manifest';
        insert objo;
        
        
        Order__c updatedOrder = [SELECT Id, Status__c, FollowUp_Stage__c FROM Order__c WHERE Id = :objo.Id];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        CDL_LeadManagement.voidOrder(objo.Id);
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