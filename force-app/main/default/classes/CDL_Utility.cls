public class CDL_Utility {
    public static DateTime getNextFollowUpDate(DateTime latestOrderUpdateDate,String Status, Time currentTime){
        Datetime followupDate = null;
        
        if(status.equalsIgnoreCase('Manifest')) {
            followupDate = calculateFollowupDateForVerifyOrders(latestOrderUpdateDate,currentTime);
        } else if(status.equalsIgnoreCase('NDR')) {
            followupDate = calculateFollowupDateForNDR(latestOrderUpdateDate,currentTime);
        } else if(status.equalsIgnoreCase('Out for Delivery')) {
            followupDate = calculateFollowupDateForOFD(latestOrderUpdateDate,currentTime);
        } else if(status.equalsIgnoreCase('Abandoned')) {
            followupDate = calculateFollowupDateForAbandonedCart(latestOrderUpdateDate,currentTime);
        } else if(status.equalsIgnoreCase('RTO')) {
            followupDate = calculateFollowupDateForRTO(latestOrderUpdateDate,currentTime);
        }
        
        
        return followupDate;
    }
    
    
    private static Datetime calculateFollowupDateForVerifyOrders(Datetime latestOrderUpdateDate,Time currentTime) {
        Datetime followupDate = null;
        Date today = DateTime.now().date();
        //Time currentTime = DateTime.now().time();
        Time time_5_30_PM = Time.newInstance(17, 30, 0, 0);
        Time time_9_30_AM = Time.newInstance(9, 30, 0, 0);
        Time time_12_00_PM = Time.newInstance(12, 0, 0, 0);
        Time time_3_00_PM = Time.newInstance(15, 0, 0, 0);
        
        Time latestTime = latestOrderUpdateDate.time();
        Date latestDate = latestOrderUpdateDate.date();
        System.debug('latestDate@@@--'+latestDate);
        System.debug('today@@@--'+today);
        System.debug('currentTime@@@--'+currentTime);
        System.debug('latestTime@@@--'+latestTime);
        
       
        if (latestDate==today && latestTime < time_5_30_PM) { 
            // Last order date is before 5:30 PM today
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 17, 30, 0);
            
        } else if ( latestDate==today && latestTime >= time_5_30_PM) {
            // Last order date is after 5:30 PM today
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 9, 30, 0).addDays(1);
            
        } else if (latestDate == today.addDays(-1) && currentTime < time_9_30_AM) {
            // Last order date is yesterday and current time before 9:30 AM 
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 9, 30, 0);
        } else if (latestDate == today.addDays(-1) && currentTime >= time_9_30_AM && currentTime < time_5_30_PM) {
            // Last order date is yesterday and current time after 9:30 AM and before 5:30PM
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 17, 30, 0);
            
        } else if (latestDate == today.addDays(-1) && currentTime >= time_5_30_PM) {
           // Last order date is yesterday and current time after 5:30 PM 
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 9, 30, 0).addDays(1);
            
        } else if (latestDate == today.addDays(-2) && currentTime < time_12_00_PM) {
           // Last order date is 2day ago and current time before 12:00 PM
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 12, 00, 0);
        } else if (latestDate == today.addDays(-2) && currentTime >= time_12_00_PM) {
           // Last order date is 2day ago and current time after 12:00 PM
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 15, 00, 0).addDays(1);
        } else if (latestDate == today.addDays(-3) && currentTime < time_3_00_PM) {
           // Last order date is 3day ago and current time before 3:00 PM
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 15, 00, 0);
        }
       
        
        return followupDate;
    }
    
    private static Datetime calculateFollowupDateForNDR(Datetime latestOrderUpdateDate,Time currentTime) {
        Datetime followupDate = null;
        Date today = Datetime.now().date();
        //Time currentTime = Datetime.now().time();
        
        Time latestTime = latestOrderUpdateDate.time();
        Date latestDate = latestOrderUpdateDate.date();
        if(latestDate==today ) { // After 9:30 PM
            if(currentTime<latestTime.addHours(3)){
               followupDate = latestOrderUpdateDate.addHours(3); 
            }
            else{
                followupDate = latestOrderUpdateDate.addDays(1);
            }
            
        } else {
            followupDate = latestOrderUpdateDate.addDays(latestOrderUpdateDate.date().daysBetween(today));
        }
        
        return followupDate;
    }
    
    private static Datetime calculateFollowupDateForOFD(Datetime latestOrderUpdateDate,Time currentTime) {
        Datetime followupDate = null;
        Date today = Datetime.now().date();
        //Time currentTime = Datetime.now().time();
        
        Time latestTime = latestOrderUpdateDate.time();
        Date latestDate = latestOrderUpdateDate.date();
        if(latestDate==today  && latestTime.addMinutes(90)>currentTime ) { // After 9:30 PM
            followupDate = latestOrderUpdateDate.addMinutes(90);
        }else if(latestDate==today  && latestTime.addMinutes(180)>currentTime ) { // After 9:30 PM
            followupDate = latestOrderUpdateDate.addMinutes(180);
        } 
        
        return followupDate;
       
    }
    
    private static Datetime calculateFollowupDateForAbandonedCart(Datetime latestOrderUpdateDate,Time currentTime) {
        Datetime followupDate = null;
        Date today = Datetime.now().date();
        //Time currentTime = Datetime.now().time();
        Time time_10_00_AM = Time.newInstance(10, 0, 0, 0);
        Time latestTime = latestOrderUpdateDate.time();
        Date latestDate = latestOrderUpdateDate.date();
        
        if(latestDate==today ) { 
            if(latestTime.addHours(3)>currentTime){
                followupDate = latestOrderUpdateDate.addHours(3);
            }else{
                 followupDate = Datetime.newInstance(today.year(), today.month(), today.day()+1, 10, 00, 0);
            }
            
        } else if(today<= latestDate.addDays(2)) {
            if(currentTime < time_10_00_AM){
                followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 10, 00, 0);
            }else{
                followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 03, 00, 0);
            }
            
        }
        
        return followupDate;
    }
    
    private static Datetime calculateFollowupDateForRTO(Datetime latestOrderUpdateDate,Time currentTime) {
        Datetime followupDate = null;
        Date today = Datetime.now().date();
        //Time currentTime = Datetime.now().time();
        
        Time latestTime = latestOrderUpdateDate.time();
        Date latestDate = latestOrderUpdateDate.date();
        if(today<= latestDate.addDays(2)) {
            followupDate = Datetime.newInstance(today.year(), today.month(), today.day(), 0, 0, 0);
        }
        return followupDate;
    }
    
}