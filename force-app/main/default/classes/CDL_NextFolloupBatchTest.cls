@isTest
public class CDL_NextFolloupBatchTest {

    @isTest
    static void testGetAbandonedCheckoutsQueue() 
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
        createOrder.Order_Delivery_Status__c = 'Manifest';
        createOrder.FollowUp_Stage__c = 'Manifest';
        createOrder.Account__c = acc.Id;
        createOrder.Next_FollowUp_Time__c =System.now().addhours(-24);
        createOrder.Last_Delivery_Status_Change_Date__c=System.now().addhours(-30);
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
        
        Order_Follow_Up__c OrderFollow = new Order_Follow_Up__c();
        OrderFollow.Order__c = createOrder.Id;
        OrderFollow.Status__c = 'Pending';
        insert OrderFollow;
        
        
     	Test.startTest();
        Datetime now = Datetime.now();
        Datetime nextRunTime = now.addMinutes(15);
        String cronExp = '' + nextRunTime.second() + ' ' + nextRunTime.minute() + ' ' + nextRunTime.hour() + ' ' + nextRunTime.day() + ' ' + nextRunTime.month() + ' ? ' + nextRunTime.year();
        CDL_NextFolloupBatchSchedulable orderStatus = new CDL_NextFolloupBatchSchedulable();
        String jobIDsendmail = System.schedule('CDL NextFolloupUp Batch',cronExp, orderStatus);
        Test.StopTest();
        
        
        
    }
}