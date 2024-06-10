public class CDL_LeaveManagement {
    
    @AuraEnabled
    public static String getUserList(){ 
        
        List<User> userList = [SELECT Id,Username, Name, On_Leave__c,Email, Assign_Order_Above__c  FROM User Where IsActive = true AND Profile.Name = 'Standard Platform User'];
        
        return Json.Serialize(userList);
    }
    
    @AuraEnabled
    public static Boolean updateUserStatus(String userId,Boolean leaveStatus){ 
        
        List<User> userList = [SELECT Id,Username, LastName, FirstName, Name,On_Leave__c,Profile.Name FROM User where Id =:userId ];
        if(!userList.isEmpty())
        {
            for(User us: userList){
                us.On_Leave__c = leaveStatus;
            }
            update userList;
            
          return userList[0].On_Leave__c;  
        }else{
          return false;  
        }             
    }
    
    @AuraEnabled
    public static String getUserOrderList(String userId)
    {
    	List<Order__c> orderList = [SELECT Id, Account__r.Name, Name, Pending_Followup_Time__c, FollowUp_Stage__c, Next_FollowUp_Time__c, Status__c,
                                    Order_Delivery_Status__c, Grand_Total__c From Order__c Where ownerId =:userId AND FollowUp_Stage__c != null AND
                                   FollowUp_Stage__c !='No Stage' AND Status__c != 'voided'];
        
        
        return JSON.Serialize(orderList);
    }
    
    @AuraEnabled
    public static String updateOrderOwner(String orderList){ 
    	 System.debug('orderList---'+orderList); 
         List<Order__c> updateOrderList = (List<Order__c>) JSON.deserialize(orderList,List<Order__c>.class);
		 System.debug('updateOrderList---'+updateOrderList);        
        try{ 
            CDL_AssignOrderOwner.updateOrderOwner(updateOrderList);
            return 'success';
        }catch(Exception e){
          	return 'Error '+e.getMessage();  
        } 
 
    }
    
}