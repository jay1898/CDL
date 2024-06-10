@isTest
public class CDL_UtilityTest {

    
    @isTest
    static void testCalculateFollowupDateForVerifyOrders() {
        // Test for scenario where latest order update is before 5:30 PM today
        Date today = Date.today();
        Time currentTime = Time.newInstance(16, 30, 0, 0);
        Datetime latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is after 5:30 PM today
        currentTime = Time.newInstance(18, 30, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
         CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is yesterday and current time before 9:30 AM
        currentTime = Time.newInstance(8, 30, 0, 0);
        Datetime yesterday = today.addDays(-1);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is yesterday and current time is between 9:30 AM and 5:30 PM
        currentTime = Time.newInstance(12, 30, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is yesterday and current time is after 5:30 PM
        currentTime = Time.newInstance(20, 30, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is 2 days ago and current time is before 12:00 PM
        Datetime twoDaysAgo = today.addDays(-2);
        currentTime = Time.newInstance(10, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(twoDaysAgo.year(), twoDaysAgo.month(), twoDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
         CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is 2 days ago and current time is after 12:00 PM
        currentTime = Time.newInstance(14, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(twoDaysAgo.year(), twoDaysAgo.month(), twoDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Test for scenario where latest order update is 3 days ago and current time is before 3:00 PM
        Datetime threeDaysAgo = today.addDays(-3);
        currentTime = Time.newInstance(14, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(threeDaysAgo.year(), threeDaysAgo.month(), threeDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Manifest', currentTime);
        
        // Add more test scenarios covering other conditions...
    }
    
    @isTest
    static void testCalculateFollowupDateForNDR() {
        // Test for scenario where latest order update is today before 9:30 PM
        Date today = Date.today();
        Time currentTime = Time.newInstance(12, 0, 0, 0);
        Datetime latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'NDR', currentTime);
        
        // Test for scenario where latest order update is today after 9:30 PM
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'NDR', currentTime);
        
        // Test for scenario where latest order update is yesterday before 9:30 PM
        Date yesterday = today.addDays(-1);
        currentTime = Time.newInstance(18, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'NDR', currentTime);
        
        // Test for scenario where latest order update is yesterday after 9:30 PM
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'NDR', currentTime);
        
        // Test for scenario where latest order update is before 9:30 PM two days ago
        Date twoDaysAgo = today.addDays(-2);
        currentTime = Time.newInstance(14, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(twoDaysAgo.year(), twoDaysAgo.month(), twoDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'NDR', currentTime);
        
        // Test for scenario where latest order update is after 9:30 PM two days ago
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(twoDaysAgo.year(), twoDaysAgo.month(), twoDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'NDR', currentTime);
        
        // Add more test scenarios covering other conditions...
    }
    
    @isTest
    static void testCalculateFollowupDateForOFD() {
        // Test for scenario where latest order update is today before 9:30 PM
        Date today = Date.today();
        Time currentTime = Time.newInstance(12, 0, 0, 0);
        Datetime latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Out for Delivery', currentTime);
        
        
        // Test for scenario where latest order update is today after 9:30 PM
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Out for Delivery', currentTime);
        
        // Test for scenario where latest order update is yesterday before 9:30 PM
        Date yesterday = today.addDays(-1);
        currentTime = Time.newInstance(18, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Out for Delivery', currentTime);
        
        // Test for scenario where latest order update is yesterday after 9:30 PM
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(yesterday.year(), yesterday.month(), yesterday.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Out for Delivery', currentTime);
        
        // Test for scenario where latest order update is before 9:30 PM two days ago
        Date twoDaysAgo = today.addDays(-2);
        currentTime = Time.newInstance(14, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(twoDaysAgo.year(), twoDaysAgo.month(), twoDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Out for Delivery', currentTime);
        
        // Test for scenario where latest order update is after 9:30 PM two days ago
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(twoDaysAgo.year(), twoDaysAgo.month(), twoDaysAgo.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Out for Delivery', currentTime);
        
        // Add more test scenarios covering other conditions...
    }
    
     @isTest
    static void testCalculateFollowupDateForAbandoned() {
        // Test for scenario where latest order update is today before 9:30 PM
        Date today = Date.today();
        Time currentTime = Time.newInstance(12, 0, 0, 0);
        Datetime latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Abandoned', currentTime);
        
        // Test for scenario where latest order update is today after 9:30 PM
        currentTime = Time.newInstance(22, 0, 0, 0);
        latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), currentTime.hour(), currentTime.minute(), currentTime.second());
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'Abandoned', currentTime);
        
        
        // Add more test scenarios covering other conditions...
    }
    
    @isTest
    static void testCalculateFollowupDateForRTO() {
        // Test for scenario where latest order update is today
        Date today = Date.today();
        Time currentTime = Time.newInstance(14, 0, 0, 0);
        Datetime latestOrderUpdateDate = Datetime.newInstance(today.year(), today.month(), today.day(), 13, 0, 0);
        CDL_Utility.getNextFollowUpDate(latestOrderUpdateDate, 'RTO', currentTime);
        
        // Add more test scenarios covering other conditions...
    }
    
}