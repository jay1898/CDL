public class CDL_LeadTriggerHandler {
    
    public static void beforeInsert(List<Lead__c> leadList)
    {
        String setOwnerId;  
        Map<String,Object> outputMap = (Map<String,Object>) JSON.deserializeUntyped(CDL_AssignOwner.setSobjectOwner('Lead__c'));
        Map<String,Object> availableUserId = (Map<String,Object>) outputMap.get('availableUserId');
        Map<String,Object> ownerIdCount = (Map<String,Object>) outputMap.get('ownerIdCount');
        
        for(Lead__c currentLead : leadList)
        {
            
            setOwnerId = CDL_AssignOwner.selectOwnerId(availableUserId,ownerIdCount);
            if(String.isNotBlank(setOwnerId))
            {
                currentLead.OwnerId = setOwnerId;
                Integer recordCount = Integer.valueOf(ownerIdCount.get(setOwnerId)) + 1;
                ownerIdCount.put(setOwnerId,recordCount);
            }
        } 
    }   
    /*public static String selectOwnerId(Map<String,Object> availableUserId,Map<String,Object> ownerIdCount)
{
String setOwnerId;
Integer minCount = null;
Integer maxCount = null;

List<String> ownerIdWithLessRecord = new List<String>();
for (String ownerId : ownerIdCount.keySet()) {
Integer count = Integer.valueOf(ownerIdCount.get(ownerId));
if (minCount == null || count < minCount) {
minCount = count;
ownerIdWithLessRecord.clear(); // Clear the list when a new minimum is found
ownerIdWithLessRecord.add(ownerId);
} else if (count == minCount) {
ownerIdWithLessRecord.add(ownerId); // Add to the list if count is the same as the current minimum
}
}

if(ownerIdWithLessRecord.size() > 0)
{
if(ownerIdWithLessRecord.size() <= 1)
{
setOwnerId = ownerIdWithLessRecord[0];
}
else
{
for(String sortbyOrdering : ownerIdWithLessRecord)
{
Integer count = Integer.valueOf(availableUserId.get(sortbyOrdering));
if (maxCount == null || count > maxCount) 
{
maxCount = count;
}
} 

for(String ownerId : availableUserId.keySet())
{
if(Integer.valueOf(availableUserId.get(ownerId)) == maxCount){
setOwnerId = ownerId;
}
}                
}
}

return setOwnerId;
} */
    /*public static String setLeadOwner()
{       
List<String>setOwnerIdList = new List<String>();

//Map to set ownerId with order Number
Map<String,Decimal> availableUserId = new Map<String,Decimal>();

//Map to set ownerId with own total records
Map<String,Integer> ownerIdCount = new Map<String,Integer>();

//Map to set availableUserId,ownerIdCount Data
Map<String,Object> returnMap = new Map<String,Object>();
Date today = Date.today();
// Calculate the start and end of today
Datetime startOfDay = Datetime.newInstance(today.year(), today.month(), today.day(), 0, 0, 0);
Datetime endOfDay = Datetime.newInstance(today.year(), today.month(), today.day(), 23, 59, 59);

Map<String,String> userNameandIdMap = new Map<String,String>();
List<String> dayOffUsersId = new List<String>();
List<String> queueUsersId = new List<String>();

//get list of user who on leave today
for(Event getEvent: [SELECT Id, Subject,Leave__c, StartDateTime, EndDateTime, EndDate, OwnerId
FROM Event
WHERE Leave__c = 'DayOff'
AND StartDateTime <= :endOfDay
AND EndDateTime >= :startOfDay Limit 50000])
{         
dayOffUsersId.add(getEvent.OwnerId);
}

//get list of use who is in queue and not on leave today
for(GroupMember getUserIdList : [SELECT Id,Group.Name,UserOrGroupId FROM GroupMember where UserOrGroupId Not In: dayOffUsersId Limit 50000])
{
queueUsersId.add(getUserIdList.UserOrGroupId);
}
System.debug('@@queueUsersId:: '+queueUsersId);
for(User setUser: [Select Id,Username,Ordering__c from User where Id In: queueUsersId Limit 50000])
{
if(setUser.Ordering__c != null)
{
if(!availableUserId.ContainsKey(setUser.Id))
{
availableUserId.put(setUser.Id,setUser.Ordering__c);
}
}
}

returnMap.put('availableUserId',availableUserId);
System.debug('@@availableUserId:: '+availableUserId);
for(String resource : availableUserId.Keyset())
{
if(!ownerIdCount.Containskey(resource))
{
ownerIdCount.put(resource,0);
}
}

for(AggregateResult ins: [Select OwnerId, COUNT(Id) recordCount From Lead__c Where OwnerId In : availableUserId.Keyset() Group by OwnerId Limit 50000])
{        

Id ownerId = (Id)ins.get('OwnerId');
Integer recordCount = (Integer)ins.get('recordCount');
ownerIdCount.put(ownerId, recordCount);
}
returnMap.put('ownerIdCount',ownerIdCount);
System.debug('@@returnMap:: '+returnMap);	        
return  JSON.serialize(returnMap);
} */
}