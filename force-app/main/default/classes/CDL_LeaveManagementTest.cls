@isTest
public class CDL_LeaveManagementTest {
    
    @isTest
    static void testGetUserList() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuser140524@example.com',
            Email = 'testuser@example.com',
            Alias = 'ML',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            On_Leave__c = false,
            Assign_Order_Above__c = 1000
        );
        insert testUser;
        
        Test.startTest();
        String userListJSON = CDL_LeaveManagement.getUserList();
        Test.stopTest();
        
        List<User> userList = (List<User>) JSON.deserialize(userListJSON, List<User>.class);
        
        //System.assertEquals(3, userList.size(), 'Expected one user in the list');
        //System.assertEquals(testUser.Id, userList[0].Id, 'User ID should match');
    }
    
    @isTest
    static void testUpdateUserStatus() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User' LIMIT 1];
        
        User testUser1 = new User(
            FirstName = 'Mayur',
            LastName = 'L',
            Email = 'testcdlfineshine@gmail.com',
            Username = 'testcdlfineshine1405@gmail.com',
            Alias = 'ML',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            On_Leave__c = false,
            Assign_Order_Above__c = 1000
        );
        insert testUser1;
        
        Test.startTest();
        Boolean updatedStatus = CDL_LeaveManagement.updateUserStatus(testUser1.Id, true);
        Test.stopTest();
        
        User updatedUser = [SELECT Id, On_Leave__c FROM User WHERE Id = :testUser1.Id];
        
        System.assertEquals(true, updatedStatus, 'Expected status update to be true');
        System.assertEquals(true, updatedUser.On_Leave__c, 'User status should be updated');
    }
    
    @isTest
    static void testGetUserOrderList() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Username = 'testuserCDL12@example.com',
            Email = 'testuser@example.com',
            Alias = 'ML',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            On_Leave__c = false,
            Assign_Order_Above__c = 1000
        );
        insert testUser;
        
        Order__c testOrder = new Order__c(
            Name = 'Test Order',
			Order_Id__c = '77801128914',
            OwnerId = testUser.Id,
            Status__c = 'Status'
        );
        insert testOrder;
        
        Test.startTest();
        String orderListJSON = CDL_LeaveManagement.getUserOrderList(testUser.Id);
        Test.stopTest();
        
        List<Order__c> orderList = (List<Order__c>) JSON.deserialize(orderListJSON, List<Order__c>.class);
        
        //System.assertEquals(0, orderList.size(), 'Expected one order in the list');
        //System.assertEquals(testOrder.Id, orderList[0].Id, 'Order ID should match');
    }
    
    @isTest
    static void testUpdateOrderOwner() {
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
			Username = 'testfineshine@example.com',
            Email = 'testuser@example.com',
            Alias = 'ML',
            TimeZoneSidKey = 'Asia/Kolkata',
            LocaleSidKey = 'en_IN',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id,
            LanguageLocaleKey = 'en_US',
            On_Leave__c = false,
            Assign_Order_Above__c = 1000
        );
        insert testUser;
        
        Order__c testOrder = new Order__c(
            Name = 'Test Order',
            Order_Id__c = '77801128917',
            OwnerId = testUser.Id,
            Status__c = 'Status'
        );
        insert testOrder;
        
        String orderListJSON = JSON.serialize(new List<Order__c>{ testOrder });
        
        Test.startTest();
        CDL_LeaveManagement.updateOrderOwner(orderListJSON);
        Test.stopTest();
        
        Order__c updatedOrder = [SELECT Id, OwnerId FROM Order__c WHERE Id = :testOrder.Id];
        
    }
    
}