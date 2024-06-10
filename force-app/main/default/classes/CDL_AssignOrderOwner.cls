public class CDL_AssignOrderOwner {
    
    public static void updateOrderOwner(List<Order__c> orderList){
        String setOwnerId;
        Map<String,Object> outputMap = (Map<String,Object>) JSON.deserializeUntyped(setSobjectOwner('Order__c'));
        Map<Id,User> availableUserId = (Map<Id,User>) JSON.deserialize(Json.Serialize(outputMap.get('availableUserId')),Map<Id,User>.class);
        Map<String,Object> ownerIdCount = (Map<String,Object>) outputMap.get('ownerIdCount');
        for(Order__c currentOrder : orderList)
        {
            setOwnerId = selectOwnerId(availableUserId,ownerIdCount,currentOrder.Grand_Total__c);
            if(String.isNotBlank(setOwnerId)){               
                currentOrder.OwnerId = setOwnerId;
                Integer recordCount = Integer.valueOf(ownerIdCount.get(setOwnerId)) + 1;
                ownerIdCount.put(setOwnerId,recordCount);
            }
        }  

        Update orderList;
    }
    
    public static String selectOwnerId(Map<Id,user> availableUserId,Map<String,Object> ownerIdCount,Decimal orderAmount)
    {
        Map<Id,user> validAvailableUserId = reurnOwnerId(availableUserId,orderAmount);
        System.debug('validAvailableUserId--'+validAvailableUserId);
        
        String setOwnerId;
        Integer minRecordCount = null;
        Integer minOrderNumberCount = null;
        
        List<String> ownerIdWithLessRecord = new List<String>();
        
        for (String ownerId : validAvailableUserId.keySet()) 
        {
            Integer count = Integer.valueOf(ownerIdCount.get(ownerId));
            if (minRecordCount == null || count < minRecordCount) {
                minRecordCount = count;
                ownerIdWithLessRecord.clear(); // Clear the list when a new minimum is found
                ownerIdWithLessRecord.add(ownerId);                
                System.debug('minimum found ownerIdWithLessRecord@@--'+ownerIdWithLessRecord);
            } else if (count == minRecordCount) {
                ownerIdWithLessRecord.add(ownerId); // Add to the list if count is the same as the current minimum
                System.debug('Same found ownerIdWithLessRecord@@--'+ownerIdWithLessRecord);
            }
        }  
        
        if(ownerIdWithLessRecord.size() > 0)
        {
            if(ownerIdWithLessRecord.size() <= 1)
            {
                setOwnerId = ownerIdWithLessRecord[0];
                System.debug('get single user only--'+setOwnerId);
            }
            else
            {                           
                for(String sortbyOrdering : ownerIdWithLessRecord)
                {
                    if(validAvailableUserId.ContainsKey(sortbyOrdering))
                    {
                        System.debug('user:'+ validAvailableUserId.get(sortbyOrdering).Name+' count--'+validAvailableUserId.get(sortbyOrdering).Ordering__c);
                        Integer count = Integer.valueOf(validAvailableUserId.get(sortbyOrdering).Ordering__c);
                        if (minOrderNumberCount == null || count < minOrderNumberCount) 
                        {
                            minOrderNumberCount = count;
                        }
                    }
                    
                    System.debug('minOrderNumberCount--'+minOrderNumberCount);
                } 
                
                for(String ownerId : validAvailableUserId.keySet())
                {
                    if(Integer.valueOf(validAvailableUserId.get(ownerId).Ordering__c) == minOrderNumberCount){
                        setOwnerId = ownerId;
                        System.debug('get user based on amount only--'+setOwnerId);
                    }
                }                              
            }
        }
        return setOwnerId;
    }
    
    public static Map<Id,user> reurnOwnerId(Map<Id,user> availableUserId,Decimal orderAmount)
    {
        
        Map<Id,user> validAvailableUserId = new Map<Id,user>();
        for(Id userId : availableUserId.keySet())
        {
            System.debug('Assign_Order_Above__c '+availableUserId.get(userId).Assign_Order_Above__c);
            System.debug('orderAmount '+orderAmount);
            if(orderAmount >= availableUserId.get(userId).Assign_Order_Above__c && availableUserId.get(userId).Assign_Order_Above__c != 0)
            {
                System.debug('inside ');
                validAvailableUserId.put(userId,availableUserId.get(userId));    
            }
        } 
        if(!validAvailableUserId.isEmpty())
        {
            System.debug('found validAvailableUserId'+validAvailableUserId);
            return validAvailableUserId;
        }else{
            System.debug('not validAvailableUserId'+validAvailableUserId);    
            return validAvailableUserId = availableUserId;
        }      
        
    }
    
    public static String setSobjectOwner(String objectName)
    {       
        
        //Map to set ownerId with order Number
        Map<Id,User> availableUserId = new Map<Id,User>([Select Id,Name,Username,Ordering__c,On_Leave__c,Assign_Order_Above__c from User where On_Leave__c = false AND Ordering__c != Null Limit 50000]);
        
        //Map to set ownerId with own total records
        Map<String,Integer> ownerIdCount = new Map<String,Integer>();
        
        //Map to set availableUserId,ownerIdCount Data
        Map<String,Object> returnMap = new Map<String,Object>();
         
        //Put Available Users
        returnMap.put('availableUserId',availableUserId);
        
        for(Id resource : availableUserId.Keyset())
        {
            if(!ownerIdCount.Containskey(resource))
            {
                ownerIdCount.put(resource,0);
            }
        }
        
        List<Id> ownerIdList = new List<Id>(availableUserId.keySet());
        
        String query = 'SELECT OwnerId, COUNT(Id) recordCount ' +
            'FROM ' + objectName +
            ' WHERE OwnerId IN :ownerIdList ' +
            'GROUP BY OwnerId ' +
            'LIMIT 50000';
        
        for(AggregateResult ins: Database.query(query))
        {        
            
            Id ownerId = (Id)ins.get('OwnerId');
            Integer recordCount = (Integer)ins.get('recordCount');
            ownerIdCount.put(ownerId, recordCount);
        }
        
        //Put OwnerId Counts
        returnMap.put('ownerIdCount',ownerIdCount);
        
        System.debug('@@returnMap:: '+JSON.serialize(returnMap));	        
        return  JSON.serialize(returnMap);
    }
}